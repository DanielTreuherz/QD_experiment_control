from pylablib.devices import AWG
import numpy as np
import time
from typing import Literal, Annotated, Union, TextIO, BinaryIO

from pydantic import validate_call, Field
import os
import streamlit as st

os.environ["PYVISA_LIBRARY"] = "@py"

ChannelType = Literal[1, 2]

class Agilent33600A(AWG.GenericAWG):
    """
    Driver for Keysight/Agilent 33600A series AWGs with Pydantic validation
    and integrated command registry.
    """

    def __init__(self, addr, channels_number=2):
        self._channels_number = channels_number
        super().__init__(addr)
        visa_instr = self.instr.instr
        visa_instr.timeout = 10_000
        visa_instr.chunk_size = 4 * 1024 * 1024

    # def _upload_custom_waveform_binary(self, name, waveform, channel=1):
    #     waveform = np.asarray(waveform, dtype=np.float32)
    #     payload = waveform.tobytes()
    #     visa_instr = self.instr.instr
    #     self.write("DISP:TEXT 'Uploading ARB'")
    #     self.write("FORM:BORD SWAP")
    #     self.A33ClearArbitrary(channel)
    #     byte_count = len(payload)
    #     len_str = str(byte_count)
    #     header = f"#{len(len_str)}{len_str}".encode("ascii")
    #     cmd = f"SOUR{channel}:DATA:ARB {name},".encode("ascii")
    #     message = cmd + header + payload + b"\n"
    #     visa_instr.write_raw(message)
    #     self.write("*WAI")
    #     self.write("DISP:TEXT ''")

    def _upload_custom_waveform_dac_binary(
        self,
        waveform,
        arb_index: int,
        channel: int = 1,
        max_attempts: int=10
        ):
        """
        Upload arbitrary waveform using DATA:ARB:DAC (raw DAC codes).
        waveform : array-like
            Integer DAC samples (already scaled/clipped).
        arb_index : int
            ARB memory index (e.g. 1 -> ARB1).
        channel : int
            Output channel (1 or 2).
        """
        # Convert to signed 16-bit integers (33600A DAC mode expects integers)
        waveform = np.asarray(waveform, dtype=np.int16)
        payload = waveform.tobytes()
        visa_instr = self.instr.instr
        
        old_timeout = visa_instr.timeout
        visa_instr.timeout = 60_000
        
        byte_count = len(payload)
        len_str = str(byte_count)
        header = f"#{len(len_str)}{len_str}".encode("ascii")

        cmd = (
            f"FORM:BORD SWAP;:SOUR{channel}:DATA:ARB:DAC ARB{arb_index},"
            .encode("ascii")
        )
        # Full message
        message = cmd + header + payload# + b";\n"


        last_err = None
        for attempt in range(1, max_attempts + 1):
            try:
                # Write waveform
                visa_instr.write_raw(message)

                # Short wait between attempts (like 100 ms)
                time.sleep(0.1)

                opc_reply = self.ask("*OPC?")
     
                if opc_reply != "1":
                    # Optional: if not done, wait longer (LabVIEW style)
                    time.sleep(20)  # 20 seconds, emulate LabVIEW long wait

                # Check instrument error
                err = self.ask("SYST:ERR?")
                
                if err==('+0,"No error"'):
                    # Success
                    print(f"Waveform ARB{arb_index} uploaded successfully on attempt {attempt}")
                    visa_instr.timeout = old_timeout
                    return
                else:
                    last_err = err
                    print(f"Attempt {attempt}: Instrument busy/error -> {err}")

            except Exception as e:
                last_err = str(e)
                print(f"Attempt {attempt}: Exception -> {last_err}")
        
        visa_instr.timeout = old_timeout
        # If we exit the loop without success
        raise RuntimeError(
            f"Failed to upload ARB waveform after {max_attempts} attempts. Last error: {last_err}"
        )


    # -----------------------------------------------------------------------
    # Registered Commands
    # -----------------------------------------------------------------------

    @validate_call
    def A33ArbPhaseSync(self):
        """Syncs Arb phase."""
        self.write(":FUNC:ARB:SYNC;")

    @validate_call
    def A33ClearArbitrary(self, channel: ChannelType):
        """Clears volatile memory for the specified channel."""
        self.write(f"SOUR{channel}:DATA:VOL:CLE")
        self.ask("*OPC?")

    @validate_call
    def A33ConfigureAM(
        self, 
        channel: ChannelType, 
        am_source: Annotated[int, Field(ge=0, le=3)], # ['INT','EXT','CH1','CH2']
        modulation_waveform: Annotated[int, Field(ge=0, le=7)], # ['SIN','SQU'...]
        modulation_frequency: Annotated[float, Field(gt=0)], 
        enable_carrier_supression: bool, 
        enable_amplitude_modulation: bool, 
        modulation_depth: Annotated[float, Field(ge=0, le=120)]
    ):
        sources_str = ['INT','EXT','CH1','CH2'][am_source]
        waveforms_str = ['SIN','SQU','TRI','RAMP','NRAM','NOIS','PRBS','ARB'][modulation_waveform]
        
        cmd = f"SOUR{channel}:AM:STAT {'ON' if enable_amplitude_modulation else 'OFF'};"
        cmd+= f":SOUR{channel}:AM:SOUR {sources_str};"

        if am_source == 0: # INT
            cmd += f":SOUR{channel}:AM:INT:FUNC {waveforms_str};"
            cmd += f":SOUR{channel}:AM:INT:FREQ {modulation_frequency:#.12g};"

        cmd+= f":SOUR{channel}:AM:DEPT {modulation_depth:#.12g};"
        cmd+= f":SOUR{channel}:AM:DSSC {'ON' if enable_carrier_supression else 'OFF'};"

        self.write(cmd)

    @validate_call
    def A33ConfigureARB(
        self, 
        channel: ChannelType, 
        arb_number: int, 
        amplitude: Annotated[float, Field(ge=0)], 
        f_sr_p: Annotated[int, Field(ge=0, le=2)], # ["FREQ", "SRAT", "PER"]
        phase: Annotated[float, Field(ge=-360, le=360)], 
        filter_key: Annotated[int, Field(ge=0, le=2)], # ["OFF", "STEP", "NORM"]
        dc_offset: float, 
        advance_mode: bool, # 0=SRAT, 1=TRIG
        freq_sample_rate_period: Annotated[float, Field(gt=0)] 
    ):
        if arb_number > 0:
            arb_string = f'{arb_number}:.0f'
        else:
            arb_string = f'"INT:\\332XX_ARBS\\ARBF{abs(arb_number):.0f}.ARB"'
        
        cmd = f':SOUR{channel}:FUNC:ARB ARB{arb_string};:'
        cmd += f'SOUR{channel}:FUNC ARB;:'
        cmd += f'SOUR{channel}:FUNC ARB:FILT {["OFF", "STEP", "NORM"][filter_key]};:'
        cmd += f'SOUR{channel}:FUNC ARB:ADV {"TRIG" if advance_mode else "SRAT"};:'
        cmd += f'SOUR{channel}:VOLT {amplitude:#.12g};:'
        cmd += f'SOUR{channel}:VOLT:OFFS {dc_offset:#.12g};:'
        cmd += f'SOUR{channel}:FUNC ARB:{["FREQ", "SRAT", "PER"][f_sr_p]} {freq_sample_rate_period:#.12g};:'
        
        if (phase >= -360) and (phase < 360):
            cmd += f'SOUR{channel}:PHASE:ARB {phase:#.12g};:'
 
        self.write(cmd)

    @validate_call
    def A33ConfigureBurst(
        self, 
        channel: ChannelType, 
        burst_mode: bool, # 0=Triggered, 1=Gated
        burst_phase: Annotated[float, Field(ge=-360, le=360)], 
        burst_count: Annotated[int, Field(ge=1)], 
        gate_polarity: bool, # 0=Norm, 1=Inv
        internal_period: Annotated[float, Field(gt=0)], 
        enable_burst: bool
    ):
        if enable_burst:
            if burst_mode: # Gated
                cmd = f'SOUR{channel}:BURS:MODE GAT;:'
                cmd += f'SOUR{channel}:BURS:GATE:POL {"INV" if gate_polarity else "NORM"};:'
                cmd += f'SOUR{channel}:BURS:INT:PER {internal_period:#.12g};:'
            else: # Triggered
                cmd = f'SOUR{channel}:BURS:MODE TRIG;:'
                cmd += f'SOUR{channel}:BURS:PHAS {burst_phase:#.12g};:'
                cmd += f'SOUR{channel}:BURS:NCYC {burst_count:.0f};:'
            
            cmd += f'SOUR{channel}:BURS:STAT ON'
        else:
            cmd = f'SOUR{channel}:BURS:STAT OFF'
        self.write(cmd)

    @validate_call
    def A33ConfigureFM(
        self, 
        channel: ChannelType, 
        enable_frequency_modulation: bool, 
        fm_source: Annotated[int, Field(ge=0, le=3)], # ['INT', 'EXT', 'CH1', 'CH2']
        modulation_waveform: Annotated[int, Field(ge=0, le=7)], 
        modulation_deviation: Annotated[float, Field(ge=0)], 
        modulation_frequency: Annotated[float, Field(gt=0)] 
    ):
        modulation_waveform_str = ['SIN', 'SQU', 'TRI', 'RAMP', 'NRAM', 'NOIS', 'PRBS', 'ARB'][modulation_waveform]
        fm_source_str = ['INT', 'EXT', 'CH1', 'CH2'][fm_source]

        if enable_frequency_modulation:
            cmd = f'SOUR{channel}:FM:STAT ON;:'
            cmd += f'SOUR{channel}:FM:SOUR {fm_source_str};:' 

            if fm_source_str == 'INT':
                cmd += f'SOUR{channel}:FM:INT:FUNC {modulation_waveform_str};:'
                cmd += f'SOUR{channel}:FM:INT:FREQ {modulation_frequency:#.12g};:'
            cmd += f'SOUR{channel}:FM:DEV {modulation_deviation:#.12g};'
            
        else:
            cmd = f'SOUR{channel}:FM:STAT OFF;:'
        
        self.write(cmd)

    @validate_call
    def A33ConfigureFSweep(
        self, 
        channel: ChannelType, 
        enable_frequency_sweep: bool, 
        sweep_spacing: Annotated[int, Field(ge=0, le=1)], # ['LIN', 'LOG']
        sweep_time: Annotated[float, Field(gt=0)], 
        hold_time: Annotated[float, Field(ge=0)], 
        return_time: Annotated[float, Field(ge=0)], 
        start_frequency: Annotated[float, Field(ge=0)], 
        stop_frequency: Annotated[float, Field(ge=0)] 
    ):
        sweep_spacing_str = ['LIN', 'LOG'][sweep_spacing]

        if enable_frequency_sweep:
            cmd = f':SWE{channel}:STAT ON;:'
            cmd += f'SWE{channel}:SPAC {sweep_spacing_str};:'
            cmd += f'SWE{channel}:TIME {sweep_time:#.7g};:'
            cmd += f'FREQ{channel}:STAR {start_frequency:#.12g};:'
            cmd += f'FREQ{channel}:STOP {stop_frequency:#.12g};:'
            cmd += f'SWE{channel}:HTIME {hold_time:#.7g};:'
            cmd += f'SWE{channel}:RTIME {return_time:#.7g};'            
        else:
            cmd = f':SWE{channel}:STAT OFF;'
        
        self.write(cmd.upper())

    @validate_call
    def A33ConfigurePulse(
        self, 
        channel: ChannelType, 
        pulse_period: Annotated[float, Field(gt=0)], 
        pulse_width: Annotated[float, Field(gt=0)], 
        leading_edge: Annotated[float, Field(gt=0)], 
        trailing_edge: Annotated[float, Field(gt=0)] 
    ):
        cmd = f':SOUR{channel}:FUNC:PULS:PER {pulse_period:#.12g};:'
        cmd += f'SOUR{channel}:FUNC:PULS:WIDT {pulse_width:#.12g};:'
        cmd += f'SOUR{channel}:FUNC:PULS:TRAN:LEAD {leading_edge:#.12g};:'
        cmd += f'SOUR{channel}:FUNC:PULS:TRAN:TRA {trailing_edge:#.12g};'
        
        self.write(cmd)

    @validate_call
    def A33ConfigureTrigger(
        self, 
        channel: ChannelType, 
        trigger_source: Annotated[int, Field(ge=0, le=3)], # ['IMM', 'TIM', 'EXT', 'BUS']
        trigger_slope: Annotated[int, Field(ge=0, le=1)], # ['POS', 'NEG']
        delay: Annotated[float, Field(ge=0)], 
        int_period: Annotated[float, Field(gt=0)], 
        trigger_level: float 
    ):
        trigger_source_str = ['IMM', 'TIM', 'EXT', 'BUS'][trigger_source]
        trigger_slope_str = ['POS', 'NEG'][trigger_slope]        

        cmd = f':TRIG{channel}: SOUR {trigger_source_str};:'
        cmd += f'TRIG{channel}:SLOP {trigger_slope_str};:'
        cmd += f'TRIG{channel}:DEL {delay:#.12g};:'
        cmd += f'TRIG{channel}:TIM {int_period:#.12g};:'
        cmd += f'TRIG{channel}:LEV {trigger_level:#.12g};'
        
        self.write(cmd)

    @validate_call
    def A33ConfigureWFM(
        self, 
        channel: ChannelType, 
        waveform: Annotated[int, Field(ge=0, le=7)], # ['SIN'...'TRI']
        amplitude: Annotated[float, Field(ge=0)], 
        dc_offset: float, 
        frequency_bw_bitrate: Annotated[float, Field(gt=0)], 
        phase: Annotated[float, Field(ge=-360, le=360)]
    ):
        waveform_str = ['SIN','SQU','PULS','RAMP','NOIS','DC','PRBS','TRI'][waveform]
        
        cmd = f':SOUR{channel}:FUNC {waveform_str};:'

        if waveform_str != 'DC':
            cmd += f'SOUR{channel}:VOLT {amplitude:#.12g};:'
        
        cmd += f'SOUR{channel}:VOLT:OFFS {dc_offset:#.12g};:'
        
        if waveform_str == 'NOIS':
            cmd += f'SOUR{channel}:FUNC NOISE:BAND {frequency_bw_bitrate:#.12g};:'  
        elif waveform_str == 'PRBS':
            cmd += f'SOUR{channel}:FUNC:PRBS:BRAT {frequency_bw_bitrate:#.12g};:'
        else:
            cmd += f'SOUR{channel}:FREQ {frequency_bw_bitrate:#.12g};:'

        if waveform_str not in ['NOIS', 'DC']:        
            cmd += f'SOUR{channel}:PHASE {phase:#.12g};'
        
        self.write(cmd)

    @validate_call
    def A33Initialize(self, reset: bool): 
        if reset:
            self.write('*RST')
            time.sleep(0.5)
        self.write('*CLS;*ESE 1;*SRE 32;')
        time.sleep(0.5)        
        self.write('*WAI')
        time.sleep(0.5)
        self.write(':ROSCillator:SOURce:AUTO  ON;')

    @validate_call
    def A33OutputOnOff(
        self, 
        channel: ChannelType, 
        enable_output: bool, 
        output_mode: bool, # 0=NORM, 1=GATED
        polarity: bool, # 0=NORM, 1=INV
        impedance: Annotated[float, Field(gt=0)] 
    ):
        polarity_str = ['NORM', 'INV'][int(polarity)]
        enable_output_str = ['OFF', 'ON'][int(enable_output)]
        output_mode_str = ['NORM', 'GATED'][int(output_mode)]
        
        cmd = f':OUTP{channel}:LOAD {impedance:#.12g};:'
        cmd+= f'OUTP{channel}:POL {polarity_str};:'
        cmd+= f'OUTP{channel}:MODE {output_mode_str};:'
        cmd+= f'OUTP{channel} {enable_output_str};'
        self.write(cmd)

    @validate_call
    def A33PhaseSync(self):
        self.write(':SOUR1:PHASE:SYNC;')

    @validate_call
    def A33ReadError(self):  
        err = self.ask('SYST:ERR?')
        return err

    @validate_call
    def A33Trg(self):  
        self.write('*TRG;')

    @validate_call
    def A33ConfigurePRBS(
        self, 
        channel: ChannelType, 
        sequence_type: Annotated[int, Field(ge=0)], 
        edge: Annotated[float, Field(gt=0)] 
    ):  
        cmd = f':SOUR{channel}:FUNC:PRBS:DATA PN{sequence_type:.0f};:'
        cmd+= f'SOUR{channel}:FUNC:PRBS:TRAN {edge:#.12g};' 
        self.write(cmd)

    @validate_call    
    def A33ConfigureRamp(
        self,
        channel : ChannelType,
        ramp_symmetry: Annotated[float, Field(ge=0, le=100)]    
        ):
        cmd = f':SOUR{channel}:FUNC:RAMP:SYMM {ramp_symmetry:#.12g};'
        self.write(cmd)

    @validate_call
    def A33ConfigureSquare(
        self,
        channel : ChannelType,
        duty_cycle: Annotated[float, Field(ge=0, le=100)]    
            ):
        cmd = f':SOUR{channel}:FUNC:SQU:DCYC {duty_cycle};'
        self.write(cmd)
        
    @validate_call
    def A33LoadARB(self, channel: ChannelType, arb_number: int):
        visa = self.instr.instr
        old_timeout = visa.timeout
        
        # Build command with *OPC? for synchronization
        cmd = f':MMEM:LOAD:DATA{channel} "INT:\\332XX_ARBS\\ARBF{arb_number}.ARB";*OPC?'
        
        self.write(cmd)
        visa.timeout = 60_000 # 60s timeout for large file transfer
        
        # Read blocks until *OPC? returns '1'
        response = visa.read()
        visa.timeout = old_timeout
        return response
    

    def load_split_and_upload_dac(
        self,
        data: Union[str, np.ndarray, TextIO, BinaryIO],
        arb_start_index: int,
        channel: int = 1,
        chunk_size: int = 4_000_000,
    ):
        """
        Load waveform data, split into chunks, auto-increment names with _XX suffix,
        and upload each chunk using DATA:ARB:DAC.

        Parameters
        ----------
        data : str | Path | array-like
            Path to file (loaded via np.load) or waveform array.
        arb_start_index : int
            Starting ARB memory index (ARBn).
        channel : int
            Output channel.
        chunk_size : int
            Number of points per chunk (default: 4M).
        """

        # ---- Load data ---------------------------------------------------------
        if hasattr(data, "read"):
            try:
                waveform = np.loadtxt(data, dtype=np.int32)
            except Exception as exc:
                raise ValueError(
                    f"Failed to load DAC waveform from '{data}'. "
                    "File must contain 1D integer ASCII data "
                    "(valid for DATA:ARB:DAC)."
                ) from exc

            if waveform.ndim != 1:
                raise ValueError(
                    f"Waveform data in '{data}' must be 1D, got shape {waveform.shape}."
                )
        else:
            waveform = np.asarray(data)

        total_points = waveform.shape[0]

        counter = arb_start_index
        # ---- Split and upload --------------------------------------------------
        num_chunks = (total_points + chunk_size - 1) // chunk_size

        for i in range(num_chunks):
            chunk = waveform[i * chunk_size : (i + 1) * chunk_size]

            name = f"{counter + i:01d}"
            arb_index = arb_start_index + i

            self._upload_custom_waveform_dac_binary(
                waveform=chunk,
                arb_index=arb_index,
                channel=channel,
            )
            time.sleep(5)



if __name__=="__main__":
    # num_points = 13e6
    # x = np.arange(num_points)
    # data = 1e4*(np.sin(17 * x * (2*np.pi/num_points)) +  np.sin(6 * x * (2 * np.pi /num_points)))
    # np.savetxt(r'C:\Users\dt360\Documents\GitHub\QD_experiment_control\test_data.txt', data, fmt='%d')


    # with Agilent33600A("TCPIP::169.254.11.23::INSTR") as awg:
    #     awg.A33ClearArbitrary(1)
    #     awg.A33ClearArbitrary(2)
    
    #     with open(r'C:\Users\dt360\Documents\GitHub\QD_experiment_control\test_data.txt') as f:
    #         # with Agilent33600A("TCPIP::169.254.11.23::INSTR") as awg:
    #         awg.load_split_and_upload_dac(f,1)
            

#     st.set_page_config(page_title="Agilent 33600A Controller", layout="wide")
#     st.title("Agilent 33600A Series Controller")
# # "TCPIP::127.0.0.1::5025::SOCKET"
#     # --- Sidebar: Connection ---
#     st.sidebar.header("Connection")
#     visa_addr = st.sidebar.text_input("VISA Address", value="TCPIP::169.254.11.23::INSTR")
    


    # def run_command(func, *args, **kwargs):
    #     try:
    #         # Re-instantiate context for every click to ensure stateless web behavior unless managed by session state
    #         with Agilent33600A(visa_addr) as instr:
    #             result = func(instr, *args, **kwargs)
    #             if result is not None:
    #                 st.success(f"Response: {result}")
    #             else:
    #                 st.success(f"Command executed: {func.__name__}")
    #     except Exception as e:
    #         st.error(f"Error: {e}")

    # # --- Constants for UI ---
    # WAVEFORMS = ['SIN','SQU','PULS','RAMP','NOIS','DC','PRBS','TRI']
    # SOURCES = ['INT','EXT','CH1','CH2']
    # MOD_WAVEFORMS = ['SIN','SQU','TRI','RAMP','NRAM','NOIS','PRBS','ARB']
    # TRIG_SOURCES = ['IMM', 'TIM', 'EXT', 'BUS']
    # TRIG_SLOPES = ['POS', 'NEG']
    # FILTERS = ["OFF", "STEP", "NORM"]
    # F_SR_P = ["FREQ", "SRAT", "PER"]
    # SWEEP_SPACING = ['LIN', 'LOG']
    # CHANNELS = [1, 2]

    # # --- Layout: One Tab Per Function ---
    # tab_list = [
    #     "Output On/Off",
    #     "Configure WFM", 
    #     "Configure Pulse", 
    #     "Configure Sweep", 
    #     "Configure Burst",
    #     "Configure ARB",        
    #     "Configure PRBS", 
    #     "Configure Ramp",
    #     "Configure Square",
    #     "Configure AM", 
    #     "Configure FM",  
    #     "Configure Trigger", 
    #     "Manual Trigger", 
    #     "Load Arb",
    #     "Upload Arb",
    #     "Initialize", 
    #     "Read Error", 
    #     "Clear ARB Mem",
    #     "Phase Sync",
    # ]
    
    # # tabs = st.tabs(tab_list)
    # ui_tab_objects = st.tabs(tab_list)
    # tabs = dict(zip(tab_list, ui_tab_objects))
    


    # # 1. Initialize
    # with tabs['Initialize']:
    #     st.subheader("Initialize Instrument")
    #     with st.form("init_form"):
    #         do_reset = st.checkbox("Perform Reset (*RST)", value=False)
    #         if st.form_submit_button("Run A33Initialize"):
    #             run_command(Agilent33600A.A33Initialize, reset=do_reset)

    # # 2. Read Error
    # with tabs['Read Error']:
    #     st.subheader("Read System Error")
    #     if st.button("Run A33ReadError"):
    #         run_command(Agilent33600A.A33ReadError)

    # # 3. Manual Trigger
    # with tabs["Manual Trigger"]:
    #     st.subheader("Send Bus Trigger")
    #     if st.button("Run A33Trg"):
    #         run_command(Agilent33600A.A33Trg)

    # # 4. Phase Sync
    # with tabs["Phase Sync"]:
    #     st.subheader("Sync Phases")
    #     if st.button("Run A33PhaseSync"):
    #         run_command(Agilent33600A.A33PhaseSync)

    # # 5. Clear ARB
    # with tabs["Clear ARB Mem"]:
    #     st.subheader("Clear Arbitrary Memory")
    #     with st.form("clear_arb_form"):
    #         ch = st.selectbox("Channel", CHANNELS)
    #         if st.form_submit_button("Run A33ClearArbitrary"):
    #             run_command(Agilent33600A.A33ClearArbitrary, channel=ch)

    # # 6. Output On/Off
    # with tabs["Output On/Off"]:
    #     st.subheader("Output Configuration")
    #     with st.form("output_form"):
    #         ch = st.selectbox("Channel", CHANNELS)
    #         enable = st.toggle("Enable Output", value=False)
    #         mode = st.selectbox("Mode", ["Normal", "Gated"]) 
    #         pol = st.selectbox("Polarity", ["Normal", "Inverted"])
    #         # Field(gt=0) -> min_value=1e-9
    #         imp = st.number_input("Impedance (Ohms)", value=50.0, min_value=1e-9)
            
    #         if st.form_submit_button("Run A33OutputOnOff"):
    #             run_command(Agilent33600A.A33OutputOnOff, 
    #                         channel=ch, 
    #                         enable_output=enable, 
    #                         output_mode=(mode=="Gated"), 
    #                         polarity=(pol=="Inverted"), 
    #                         impedance=imp)

    # # 7. Configure WFM
    # with tabs["Configure WFM"]:
    #     st.subheader("Standard Waveform")
    #     with st.form("wfm_form"):
    #         ch = st.selectbox("Channel", CHANNELS)
    #         # Field(ge=0, le=7)
    #         wfm_name = st.selectbox("Waveform", WAVEFORMS)
    #         wfm_idx = WAVEFORMS.index(wfm_name)
    #         # Field(gt=0)
    #         freq = st.number_input("Freq/BW/Bitrate (Hz)", value=1000.0, min_value=1e-9, format="%.4e")
    #         # Field(ge=0)
    #         amp = st.number_input("Amplitude (Vpp)", value=1.0, min_value=0.0)
    #         dc = st.number_input("DC Offset (V)", value=0.0)
    #         # Field(ge=-360, le=360)
    #         phase = st.number_input("Phase (deg)", value=0.0, min_value=-360.0)
            
    #         if st.form_submit_button("Run A33ConfigureWFM"):
    #             run_command(Agilent33600A.A33ConfigureWFM,
    #                         channel=ch,
    #                         waveform=wfm_idx,
    #                         amplitude=amp,
    #                         dc_offset=dc,
    #                         frequency_bw_bitrate=freq,
    #                         phase=phase)

    # # 8. Configure AM
    # with tabs["Configure AM"]:
    #     st.subheader("Amplitude Modulation")
    #     with st.form("am_form"):
    #         ch = st.selectbox("Channel", CHANNELS)
    #         en_am = st.checkbox("Enable AM", value=True)
    #         dssc = st.checkbox("Suppress Carrier", value=False)
    #         # Field(ge=0, le=3)
    #         src_name = st.selectbox("Source", SOURCES)
    #         src_idx = SOURCES.index(src_name)
    #         # Field(ge=0, le=7)
    #         mod_wfm_name = st.selectbox("Modulating Waveform", MOD_WAVEFORMS)
    #         mod_wfm_idx = MOD_WAVEFORMS.index(mod_wfm_name)
    #         # Field(gt=0)
    #         mod_freq = st.number_input("Modulation Freq (Hz)", value=100.0, min_value=1e-9)
    #         # Field(ge=0, le=120)
    #         depth = st.number_input("Depth (%)", value=100.0, min_value=0.0, max_value=120.0)
            
    #         if st.form_submit_button("Run A33ConfigureAM"):
    #             run_command(Agilent33600A.A33ConfigureAM,
    #                         channel=ch,
    #                         am_source=src_idx,
    #                         modulation_waveform=mod_wfm_idx,
    #                         modulation_frequency=mod_freq,
    #                         enable_carrier_supression=dssc,
    #                         enable_amplitude_modulation=en_am,
    #                         modulation_depth=depth)

    # # 9. Configure FM
    # with tabs["Configure FM"]:
    #     st.subheader("Frequency Modulation")
    #     with st.form("fm_form"):
    #         ch = st.selectbox("Channel", CHANNELS)
    #         en_fm = st.checkbox("Enable FM", value=True)
    #         # Field(ge=0, le=3)
    #         src_name = st.selectbox("Source", SOURCES)
    #         src_idx = SOURCES.index(src_name)
    #         # Field(ge=0, le=7)
    #         mod_wfm_name = st.selectbox("Modulating Waveform", MOD_WAVEFORMS)
    #         mod_wfm_idx = MOD_WAVEFORMS.index(mod_wfm_name)
    #         # Field(gt=0)
    #         mod_freq = st.number_input("Modulation Freq (Hz)", value=10.0, min_value=1e-9)
    #         # Field(ge=0)
    #         dev = st.number_input("Deviation (Hz)", value=100.0, min_value=0.0)
            
    #         if st.form_submit_button("Run A33ConfigureFM"):
    #             run_command(Agilent33600A.A33ConfigureFM,
    #                         channel=ch,
    #                         enable_frequency_modulation=en_fm,
    #                         fm_source=src_idx,
    #                         modulation_waveform=mod_wfm_idx,
    #                         modulation_deviation=dev,
    #                         modulation_frequency=mod_freq)

    # # 10. Configure Sweep
    # with tabs["Configure Sweep"]:
    #     st.subheader("Frequency Sweep")
    #     with st.form("sweep_form"):
    #         ch = st.selectbox("Channel", CHANNELS)
    #         en_sw = st.checkbox("Enable Sweep", value=True)
    #         # Field(ge=0, le=1)
    #         space_name = st.selectbox("Spacing", SWEEP_SPACING)
    #         space_idx = SWEEP_SPACING.index(space_name)
    #         # Field(ge=0)
    #         start_f = st.number_input("Start Freq (Hz)", value=100.0, min_value=0.0)
    #         stop_f = st.number_input("Stop Freq (Hz)", value=1000.0, min_value=0.0)
    #         # Field(gt=0)
    #         sw_time = st.number_input("Sweep Time (s)", value=1.0, min_value=1e-9)
    #         # Field(ge=0)
    #         h_time = st.number_input("Hold Time (s)", value=0.0, min_value=0.0)
    #         r_time = st.number_input("Return Time (s)", value=0.0, min_value=0.0)
            
    #         if st.form_submit_button("Run A33ConfigureFSweep"):
    #             run_command(Agilent33600A.A33ConfigureFSweep,
    #                         channel=ch,
    #                         enable_frequency_sweep=en_sw,
    #                         sweep_spacing=space_idx,
    #                         sweep_time=sw_time,
    #                         hold_time=h_time,
    #                         return_time=r_time,
    #                         start_frequency=start_f,
    #                         stop_frequency=stop_f)

    # # 11. Configure Burst
    # with tabs["Configure Burst"]:
    #     st.subheader("Burst Mode")
    #     with st.form("burst_form"):
    #         ch = st.selectbox("Channel", CHANNELS)
    #         en_bu = st.checkbox("Enable Burst", value=True)
    #         mode = st.selectbox("Burst Mode", ["Triggered", "Gated"]) 
    #         # Field(ge=-360, le=360)
    #         phase = st.number_input("Burst Phase (deg)", value=0.0, min_value=-360.0, max_value=360.0)
    #         # Field(ge=1)
    #         count = st.number_input("Burst Count", value=1, min_value=1, step=1)
    #         pol = st.selectbox("Gate Polarity", ["Normal", "Inverted"])
    #         # Field(gt=0)
    #         period = st.number_input("Internal Period (s)", value=0.01, min_value=1e-9)
            
    #         if st.form_submit_button("Run A33ConfigureBurst"):
    #             run_command(Agilent33600A.A33ConfigureBurst,
    #                         channel=ch,
    #                         burst_mode=(mode=="Gated"),
    #                         burst_phase=phase,
    #                         burst_count=count,
    #                         gate_polarity=(pol=="Inverted"),
    #                         internal_period=period,
    #                         enable_burst=en_bu)

    # # 12. Configure Pulse
    # with tabs["Configure Pulse"]:
    #     st.subheader("Pulse Waveform")
    #     with st.form("pulse_form"):
    #         ch = st.selectbox("Channel", CHANNELS)
    #         # All Field(gt=0)
    #         per = st.number_input("Period (s)", value=1e-3, min_value=1e-9, format="%.4e")
    #         width = st.number_input("Width (s)", value=1e-4, min_value=1e-9, format="%.4e")
    #         lead = st.number_input("Leading Edge (s)", value=1e-8, min_value=1e-9, format="%.4e")
    #         trail = st.number_input("Trailing Edge (s)", value=1e-8, min_value=1e-9, format="%.4e")
            
    #         if st.form_submit_button("Run A33ConfigurePulse"):
    #             run_command(Agilent33600A.A33ConfigurePulse,
    #                         channel=ch,
    #                         pulse_period=per,
    #                         pulse_width=width,
    #                         leading_edge=lead,
    #                         trailing_edge=trail)

    # # 13. Configure PRBS
    # with tabs["Configure PRBS"]:
    #     st.subheader("PRBS Data")
    #     with st.form("prbs_form"):
    #         ch = st.selectbox("Channel", CHANNELS)
    #         # Field(ge=0)
    #         seq = st.number_input("Sequence Type (PNx)", value=7, min_value=0, step=1)
    #         # Field(gt=0)
    #         edge = st.number_input("Edge Time (s)", value=1e-8, min_value=1e-9, format="%.4e")
            
    #         if st.form_submit_button("Run A33ConfigurePRBS"):
    #             run_command(Agilent33600A.A33ConfigurePRBS,
    #                         channel=ch,
    #                         sequence_type=seq,
    #                         edge=edge)

    # # 14. Configure Trigger
    # with tabs["Configure Trigger"]:
    #     st.subheader("Trigger Setup")
    #     with st.form("trig_form"):
    #         ch = st.selectbox("Channel", CHANNELS)
    #         # Field(ge=0, le=3)
    #         src = st.selectbox("Trigger Source", TRIG_SOURCES)
    #         src_idx = TRIG_SOURCES.index(src)
    #         # Field(ge=0, le=1)
    #         slope = st.selectbox("Slope", TRIG_SLOPES)
    #         slope_idx = TRIG_SLOPES.index(slope)
    #         # Field(ge=0)
    #         dly = st.number_input("Delay (s)", value=0.0, min_value=0.0)
    #         # Field(gt=0)
    #         per = st.number_input("Timer Period (s)", value=0.001, min_value=1e-9)
    #         # No specific constraint in class except float
    #         lvl = st.number_input("Trigger Level (V)", value=1.0)
            
    #         if st.form_submit_button("Run A33ConfigureTrigger"):
    #             run_command(Agilent33600A.A33ConfigureTrigger,
    #                         channel=ch,
    #                         trigger_source=src_idx,
    #                         trigger_slope=slope_idx,
    #                         delay=dly,
    #                         int_period=per,
    #                         trigger_level=lvl)

    # # 15. Configure ARB
    # with tabs["Configure ARB"]:
    #     st.subheader("Arbitrary Waveform Setup")
    #     with st.form("arb_form"):
    #         ch = st.selectbox("Channel", CHANNELS)
    #         num = st.number_input("Arb Number", value=1, step=1)
    #         # Field(ge=0, le=2)
    #         fsrp_mode = st.selectbox("Timing Mode", F_SR_P)
    #         fsrp_idx = F_SR_P.index(fsrp_mode)
    #         # Field(gt=0)
    #         fsrp_val = st.number_input("Freq/Rate/Per Value", value=1000.0, min_value=1e-9)
    #         # Field(ge=0)
    #         amp = st.number_input("Amplitude (Vpp)", value=1.0, min_value=0.0)
    #         offs = st.number_input("DC Offset (V)", value=0.0)
    #         # Field(ge=-360, le=360)
    #         phase = st.number_input("Phase (deg)", value=0.0, min_value=-360.0, max_value=360.0)
    #         # Field(ge=0, le=2)
    #         filt = st.selectbox("Filter", FILTERS)
    #         filt_idx = FILTERS.index(filt)
    #         adv = st.selectbox("Advance Mode", ["SRAT", "TRIG"])
            
    #         if st.form_submit_button("Run A33ConfigureARB"):
    #             run_command(Agilent33600A.A33ConfigureARB,
    #                         channel=ch,
    #                         arb_number=num,
    #                         amplitude=amp,
    #                         f_sr_p=fsrp_idx,
    #                         phase=phase,
    #                         filter_key=filt_idx,
    #                         dc_offset=offs,
    #                         advance_mode=(adv=="TRIG"),
    #                         freq_sample_rate_period=fsrp_val)
                
    # with tabs['Configure Ramp']:
    #     st.subheader('Ramp setup')
    #     with st.form('ramp_form'):
    #         ch = st.selectbox("Channel", CHANNELS)
    #         ramp_sym = st.number_input('Ramp symmetry %')

    #         if st.form_submit_button("Run A33ConfigureARB"):
    #             run_command(Agilent33600A.A33ConfigureRamp,
    #                         channel=ch,
    #                         ramp_symmetry=ramp_sym,
    #                         )    
                
    # with tabs['Configure Square']:
    #     st.subheader('Square setup')
    #     with st.form('square_form'):
    #         ch = st.selectbox("Channel", CHANNELS)
    #         duty_cycle = st.number_input('Duty cycle %')

    #         if st.form_submit_button("Run A33ConfigureSquare"):
    #             run_command(Agilent33600A.A33ConfigureSquare,
    #                         channel=ch,
    #                         duty_cycle=duty_cycle,
    #                         )    
                
    # with tabs['Load Arb']:
    #     st.subheader('Load arb')
    #     with st.form('Load arb form'):
    #         ch = st.selectbox("Channel", CHANNELS)
    #         arb_number = st.number_input('Arbitrary waveform num (from instrument non-volatile storage)', value=1, step=1)

    #         if st.form_submit_button("Run A33LoadArb"):
    #             run_command(Agilent33600A.A33LoadARB,
    #                         channel=ch,
    #                         arb_number=arb_number,
    #                         )    
                

    # with tabs['Upload Arb']:
    #     st.subheader('Upload arb (DAC)')
    #     with st.form('Upload arb form'):
    #         uploaded_file = st.file_uploader(
    #             'Waveform file (.txt, integer DAC values)',type=['txt'])

    #         arb_name = st.text_input('Arbitrary waveform base name', value='ARB')

    #         ch = st.selectbox("Channel", CHANNELS )

    #         start_index = st.number_input('Starting ARB index', value=1, step=1,  min_value=1)

    #         if st.form_submit_button("Run Upload ARB"):
    #             if uploaded_file is None:
    #                 st.error("Please upload a .txt waveform file.")
    #             else:
    #                 # Streamlit gives a file-like object; np.loadtxt can read it
    #                 run_command(
    #                     Agilent33600A.load_split_and_upload_dac,
    #                     data=uploaded_file,
    #                     base_name=arb_name,
    #                     arb_start_index=start_index,
    #                     channel=ch,
    #                 )
