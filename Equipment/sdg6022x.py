import cmd
from pylablib.core.devio import SCPI
import numpy as np

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from core.Registry import register_command
import time

class SDG6022X(SCPI.SCPIDevice):
    def __init__(self, addr):
        super().__init__(addr, term_write="\n", term_read="\n")

        # Access the raw PyVISA resource to adjust timeouts
        raw_dev = self.instr.instr
        raw_dev.timeout = 20_000          # 20s timeout (uploading large ARBs takes time)
        raw_dev.chunk_size = 4 * 1024 * 1024  # 4MB chunk size
        
    # --------------------------------------------------
    # Set functions
    # --------------------------------------------------
        
    def set_frequency(self, freq, channel): 
        self.write(f"C{channel}:BSWV FRQ,{freq}")
        
    def set_amplitude(self, amp, channel): 
        self.write(f"C{channel}:BSWV AMP,{amp}")
        
    def set_offset(self, offset, channel): 
        self.write(f"C{channel}:BSWV OFST,{offset}")
        
    def set_duty_cycle(self, duty, channel):
        self.write(f"C{channel}:BSWV DUTY,{duty}")
        
    def set_phase(self, phase, channel): 
        self.write(f"C{channel}:BSWV PHSE,{phase}")
        
    def set_ramp_symmetry(self, sym, channel): 
        self.write(f"C{channel}:BSWV SYM,{sym}")
        
    def set_pulse_width(self, width, channel): 
        self.write(f"C{channel}:BSWV WIDTH,{width}")
        
    def set_load(self, load, channel): 
        # 0 to 1e5 Ohms, and then 1e6 or above sets it to HiZ. 1e5 to 1e6 just set it to 1e5.
        self.write(f"C{channel}:OUTP LOAD,{load}")
        
    def enable_output(self, enabled, channel): 
        self.write(f"C{channel}:OUTP {'ON' if enabled else 'OFF'}")

    def set_reference(self, reference):
        self.write(f"ROSC {"INT" if reference == 1 else "EXT"}")

    def set_reference(self, reference):
        self.write(f"ROSC {"INT" if reference == 1 else "EXT"}")
        


    def set_length(self, channel, length):
        self.write(f"C{channel}:BSWV LENGTH,{length}")

    def set_edge_time(self, channel, edge_time):
        self.write(f"C{channel}:BSWV EDGE,{edge_time:.15f}")


    def set_differential_mode(self, channel, differential_mode):
        self.write(f"C{channel}:BSWV DIFFSTATE,{"ON" if differential_mode else "OFF"}")
    

    def change_reference_out(self):
            self.write('VKEY VALUE,18,STATE,1')
            self.write('VKEY VALUE,23,STATE,1')
    # --------------------------------------------------
    # Get functions
    # --------------------------------------------------
    def get_frequency(self, channel): 
        return self.ask(f"C{channel}:BSWV?")
    
    def is_output_enabled(self, channel): 
        return 'OUTP ON' in self.ask(f"C{channel}:OUTP?")

    def get_reference_out(self):
        return self.ask(f"ROSC?")
    
    def upload_custom_waveform(self, name, waveform, channel=1):
        """
        Uploads a waveform to the Siglent AWG.
        Command: C1:WVDT WVNM,name,WAVEDATA,binary_block
        """
        # Ensure data is float32
        waveform = np.asarray(waveform, dtype=np.float32)
        payload = waveform.tobytes()
        
        # 1. Prepare Header
        byte_count = len(payload)
        len_str = str(byte_count)
        # IEEE 488.2 Header: # + digits_in_length + length
        header = f"#{len(len_str)}{len_str}".encode("ascii")
        
        # 2. Prepare Command String
        # Siglent uses C1, C2 etc.
        cmd_str = f"C{channel}:WVDT WVNM,{name},WAVEDATA,"
        cmd_bytes = cmd_str.encode("ascii")
        
        # 3. Send Binary Block
        # We write directly to the raw instrument to handle binary data safely
        self.instr.instr.write_raw(cmd_bytes + header + payload)
        self.write("*WAI")
        
        # 4. Select the uploaded wave
        self.write(f"C{channel}:ARWV NAME,{name}")

    def set_sample_rate(self, sample_rate, channel=1):
        """Sets sample rate in Sa/s"""
        self.write(f"C{channel}:BSWV SRATE,{sample_rate}")



@register_command
def SDGTestFunc (instr, arg1, arg2, arg3):
    instr.test_print(arg1, arg2)


@register_command
def SDG60RefClock(instr, ref_source, ref_out):
    #10MHz clock in and out
    #ref_source True gives internal reference, False external reference

    instr.set_reference(ref_source)
    time.sleep(3.0)

    reference_out_str = instr.get_reference_out()

    reference_out_device = '10MOUT,ON' in reference_out_str

    if reference_out_device != ref_out:
        instr.change_reference_out()

    print(instr.get_reference_out())


@register_command
def SDG60ConfPRBS(instr, channel, bit_rate_period, bit_rate, period, amp, offset, differential_mode, length, edge_time):
    """
    Configures all PRBS settings in a single SCPI command string.
    Format: C1:BSWV WVTP,PRBS,BITRATE,10,AMP,2.0,...
    """
    cmd_parts = [f"C{channel}:BSWV WVTP,PRBS"]

    # 2. Bitrate OR Period
    if bit_rate_period:
        # #.12g formats the float to 12 significant digits (high precision)
        cmd_parts.append(f"BITRATE,{bit_rate:#.12g}")
    else:
        cmd_parts.append(f"PERI,{period:#.12g}")

    cmd_parts.append(f"AMP,{amp:#.12g}")

    cmd_parts.append(f"OFST,{offset:#.12g}")

    cmd_parts.append(f"LENGTH,{length}")

    diff_state = "ON" if differential_mode else "OFF"
    cmd_parts.append(f"DIFFSTATE,{diff_state}")

    cmd_parts.append(f"EDGE,{edge_time:#.12g}")

    full_command = ",".join(cmd_parts)
    
    print(f"[SENT] {full_command}")
    
    instr.write(full_command)

@register_command
def SDG60ConfSTDWFM(instr, **kwargs):

    channel = kwargs.get('channel', 1)
    wv_type = kwargs.get('waveform_type', 'SINE') 
    
    cmd_parts = [f"C{channel}:BSWV WVTP,{wv_type}"]

    is_freq_mode = kwargs.get('is_freq_mode', True)
    
    if is_freq_mode:
        if 'freq' in kwargs:
            cmd_parts.append(f"FRQ,{kwargs['freq']:#.12g}")
    else:
        if 'period' in kwargs:
            cmd_parts.append(f"PERI,{kwargs['period']:#.12g}")

    # 3. Dynamic Parameter Mapping
    param_map = {
        'amp': 'AMP',
        'offset': 'OFST',
        'phase': 'PHSE',
        'duty_cycle': 'DUTY',
        'ramp_symmetry': 'SYM',
        'pulse_width': 'WIDTH',
        # Add 'edge_time' here if standard waveforms (like Pulse) need it later
        'edge_time': 'EDGE' 
    }

    for json_key, scpi_key in param_map.items():
        if json_key in kwargs:
            value = kwargs[json_key]
            # Append formatted string
            cmd_parts.append(f"{scpi_key},{value:#.12g}")

    # 5. Join and Send
    full_command = ",".join(cmd_parts)
    print(f"[SENT] {full_command}")
    instr.write(full_command)

@register_command

def SDG60ConfPulse1(instr,kwargs):

    channel = kwargs.get('channel', 1)

    cmd_parts = [f"C{channel}:BSWV WVTP,PULSE"]

    if 'period' in kwargs:
        cmd_parts.append(f"PERI,{kwargs['period']:#.12g}")
    else:
        cmd_parts.append(f"FRQ,{kwargs['freq']:#.12g}")

    if 'amp' in kwargs:
        cmd_parts.append(f"AMP,{kwargs['amp']:#.12g}")
    else:
        cmd_parts.append(f"HLEV,{kwargs['amp']:#.12g}")

    if 'offset' in kwargs:
        cmd_parts.append(f"OFST,{kwargs['offset']:#.12g}")
    else:
        cmd_parts.append(f"LLEV,{kwargs['offset']:#.12g}")

    if 'pulse_width' in kwargs:
        cmd_parts.append(f"WIDTH,{kwargs['pulse_width']:#.12g}")
    else:
        cmd_parts.append(f"DUTY,{kwargs['duty_cycle']:#.12g}")

    if 'rise_time' in kwargs:
        cmd_parts.append(f"RIS,{kwargs['rise_time']:#.12g}")
    
    if 'fall_edge' in kwargs:
        cmd_parts.append(f"FALL,{kwargs['fall_edge']:#.12g}")

    if 'delay_time' in kwargs:
        cmd_parts.append(f"EDGE,{kwargs['delay_time']:#.12g}")

    full_command = ",".join(cmd_parts)
    print(f"[SENT] {full_command}")
    instr.write(full_command)


@register_command
def SDG60LoadPolarity(instr, kwargs):
    channel = kwargs.get('channel', 1)
    Base_cmd = f"C{channel}:OUTP"
    cmd_parts = []
    if kwargs.get('Impedance', 50) >= 1e6:
        cmd_parts.append("LOAD,HZ")
    else:
        cmd_parts.append(f"LOAD,{kwargs['Impedance']:#.14g}")
    if 'polarity' in kwargs:
        cmd_parts.append(f"PLRT,{kwargs['polarity']}")
    full_command = ",".join(cmd_parts)
    full_command = f"{Base_cmd} {full_command}"
    print(f"[SENT] {full_command}")
    
    instr.write(full_command)

@register_command
def SDG60ModulationOff(instr, channel, OUTPUT_ENABLED):
    base_cmd = f"C{channel}:MDWV"
    cmd_parts = []
    if  OUTPUT_ENABLED:
        cmd_parts.append("STATE,ON")
    else:
        cmd_parts.append("STATE,OFF")

    full_command = ",".join(cmd_parts)
    full_command = f"{base_cmd} {full_command}"
    print(f"[SENT] {full_command}")

    instr.write(full_command)

def SDG60Trg(instr):
    full_command = "%.;BTWV MTRIG"
    print(f"[SENT] {full_command}")
    instr.write(full_command)

def SDG60SelectChannel(instr, channel):
    full_command = f"C{channel}:BSWV"
    print(f"[SENT] {full_command}")
    instr.write(full_command)
    time.sleep(0.5)

@register_command
def SDG60SelectArbitraryWFM(instr, **kwargs):
    """
    Selects an Arbitrary Waveform.
    - Handles 'User Created' ARBs (ARB1, ARB2...) with a delay.
    - Handles 'Built-in' ARBs using a mapping table for specific indices.
    """
    channel = kwargs.get('channel', 1)

    # --- MAPPING TABLE ---
    # Maps the easy name to the specific Siglent Index
    BUILTIN_MAP = {
        "SINE": 0,
        "NOISE": 1,
        "PULSE": 5,
        "RAMP": 8,
        "TRIANGLE": 36,
        "SQUARE": 47
    }

    # --- CASE 1: User Created Arb ---
    if 'user_arb_number' in kwargs:
        arb_num = kwargs['user_arb_number']
        arb_name = f"ARB{arb_num}"
        
        cmd = f"C{channel}:ARWV NAME,{arb_name}"
        print(f"[SENT] {cmd}")
        instr.write(cmd)
        
        print("Waiting 3.0s for User Arb load...")
        time.sleep(3.0)

    # --- CASE 2: Built-in Waveform ---
    elif 'builtin_index' in kwargs:
        raw_input = kwargs['builtin_index']
        
        # Logic: Determine the correct Index
        if isinstance(raw_input, str):
            # If input is "SQUARE", look up 47
            # .upper() makes it case-insensitive ("Square" -> "SQUARE")
            index = BUILTIN_MAP.get(raw_input.upper())
            
            if index is None:
                print(f"[ERROR] Unknown Built-in Name: '{raw_input}'. Sending as 0.")
                index = 0
        else:
            # If input is already a number (e.g. 47), use it directly
            index = int(raw_input)

        cmd = f"C{channel}:ARWV INDEX,{index}"
        print(f"[SENT] {cmd}")
        instr.write(cmd)

    else:
        print("[ERROR] Arguments missing. Provide 'user_arb_number' or 'builtin_index'.")


@register_command
def SDG60ReadParameters(instr, **kwargs):
    channel = kwargs.get('channel', 1)
    queries = ["BSWV", "MDWV", "SWWV", "BTWV", "SRATE"]
    
    base_cmd = f"C{channel}:"
    results = {}

    print(f"--- Reading Parameters for Channel {channel} ---")

    for q in queries:
        # 1. ADD \n HERE 
        # The instrument needs this to know the command is finished.
        full_command = f"{base_cmd}{q}?\n"
        
        try:
            # 2. Write (Frame 1)
            instr.write(full_command)
            
            # 3. Wait (Frame 2)
            time.sleep(0.1) 
            
            # 4. Read (Frame 3)
            raw_response = instr.read()
            results[q] = raw_response.strip()

        except Exception as e:
            print(f"[ERROR] Failed to read {q}: {e}")
            results[q] = "ERROR"
            
            # OPTIONAL: Clear the buffer if an error occurs so it doesn't jam the next one
            try:
                instr.instr.clear()
            except:
                pass

    print(f"[RESPONSE] {results}")
    return results

@register_command
def SDG60ReadArbitraryWFMQ(instr,waveform_name):
    base_cmd = f"WVDT?"
    cmd_parts = []
    cmd_parts.append("USER")
    cmd_parts.append(f"{waveform_name}")
    full_command = ",".join(cmd_parts)
    base_cmd = f"{base_cmd}{full_command}"
    print(f"[SENT] {base_cmd}")
    response = instr.ask(base_cmd)
    print(f"[RESPONSE] {response}")
    return response  


@register_command
def SDG60Initialize(instr, **kwargs):
    should_be_on = kwargs.get('OUTPUT_ENABLED', False)

    print("--- Initializing Instrument ---")
    time.sleep(1.0)
    for channel in [1, 2]:
        if should_be_on:
            cmd = f"C{channel}:OUTP ON"
        else:
            cmd = f"C{channel}:OUTP OFF"
            
        print(f"[SENT] {cmd}")
        instr.write(cmd + "\n")
        time.sleep(0.2)
    print(f"[SENT] *RST")
    instr.write("*RST\n") 

@register_command
def SDG60ConfNoise(instr, channel, std_dev, voltage_mean, is_bandstate, bandwidth):
    """

    
    SCPI Keys:
    - STDEV: Standard Deviation (Amplitude RMS)
    - MEAN:  Mean Voltage (Offset)
    - BAND:  Bandwidth (only sent if is_bandstate is True)
    """
    

    cmd_parts = [f"C{channel}:BSWV WVTP,NOISE"]
    cmd_parts.append(f"STDEV,{std_dev:#.4f}")
    cmd_parts.append(f"MEAN,{voltage_mean:#.3f}")
    if is_bandstate:
        # Note: Siglent uses 'BAND', not 'BANDWIDTH'
        cmd_parts.append(f"BANDSTATE,ON,BANDWIDTH,{bandwidth:#.23g}")
    else:
        cmd_parts.append("BANDSTATE,OFF")

    full_command = ",".join(cmd_parts)
    print(f"[SENT] {full_command}")
    instr.write(full_command)



@register_command
def SDG60ConfArbWaveform3(instr, **kwargs):
    channel = kwargs.get('channel', 1)
    is_DDS = kwargs.get('is_DDS', True)
    if is_DDS:
        instr.write(f"C{channel}:SRATE MODE,DDS")
        time.sleep(0.1)
        
        cmd_parts = []
        if 'frequency' in kwargs:
            cmd_parts.append(f"FRQ,{kwargs['frequency']:#.15g}")
        elif 'period' in kwargs:
            cmd_parts.append(f"PERI,{kwargs['period']:#.15g}")
        
        cmd_parts.append(f"AMP,{kwargs.get('amp', 1.0):#.15g}")
        cmd_parts.append(f"OFST,{kwargs.get('offset', 0.0):#.15g}")
        cmd_parts.append(f"PHSE,{kwargs.get('phase', 0.0):#.15g}")
        
        full_cmd = f"C{channel}:BSWV {','.join(cmd_parts)}"
        print(f"[SENT] {full_cmd}")
        instr.write(full_cmd)
    else:
        interp_idx = kwargs.get('interpolation_index', 1) 
        has_freq = 'frequency' in kwargs
        has_period = 'period' in kwargs
        has_srate = 'sample_rate' in kwargs
        if has_srate:
            val_to_send = kwargs['sample_rate']
        elif has_period:
            val_to_send = kwargs['period']
        else:
            val_to_send = 1000.0
        if has_freq:
            cmd = f"C{channel}:SRATE MODE,TARB,INTER,HOLD"
        else:
            interp_str = "LINE" if interp_idx == 1 else "HOLD"
            cmd = f"C{channel}:SRATE MODE,TARB,INTER,{interp_str},VALUE,{val_to_send:#.15g}"

        print(f"[SENT] {cmd}")
        instr.write(cmd)
        time.sleep(0.1)

        cmd_parts = []
        
        if has_freq:
             cmd_parts.append(f"FRQ,{kwargs['frequency']:#.15g}")
        elif has_period:
             cmd_parts.append(f"PERI,{kwargs['period']:#.15g}")
        
        cmd_parts.append(f"AMP,{kwargs.get('amp', 1.0):#.15g}")
        cmd_parts.append(f"OFST,{kwargs.get('offset', 0.0):#.15g}")
        cmd_parts.append(f"PHSE,{kwargs.get('phase', 0.0):#.15g}")
        
        full_cmd = f"C{channel}:BSWV {','.join(cmd_parts)}"
        print(f"[SENT] {full_cmd}")
        instr.write(full_cmd)
        time.sleep(0.1)

        if interp_idx in [2, 3, 4]:
            MAGIC_KEYS = {
                2: 18,  # Sinc
                3: 13,  # Sinc27
                4: 8    # Sinc13
            }
            target_key = MAGIC_KEYS[interp_idx]
            sequence = [5, 3, 23, target_key, 3]
            
            print(f"--- Triggering VKEY Sequence for Interpolation {interp_idx} ---")
            for key in sequence:
                cmd = f"VKEY VALUE,{key},STATE,1"
                print(f"[SENT] {cmd}")
                instr.write(cmd)
                time.sleep(0.3)


@register_command
def SDG60ConfBurst2(instr, **kwargs):
    """
    Configures Burst Waveform matching LabVIEW logic.
    
    Arguments (LabVIEW Names):
    - Channel, Enable_Burst, Start_Phase
    - Triggered_Gated (0=Triggered, 1=Gated)
    - TRG_Gate_Source (0=Int, 1=Ext, 2=Man)
    - Trg_Gate_Polarity (0=Pos/Rise, 1=Neg/Fall)
    - Burst_Cycle (0=N-Cycle, 1=Infinite)
    - Number_of_Cycles (Integer)
    - Burst_Period (Float)
    - Burst_Delay (Float)
    """
    
    channel = kwargs.get('Channel', 1)
    enable = kwargs.get('Enable_Burst', False)
    
    # --- 1. STATE ---
    state_str = "ON" if enable else "OFF"
    cmd_parts = [f"STATE,{state_str}"]

    if not enable:
        full_command = f"C{channel}:BTWV {','.join(cmd_parts)}"
        print(f"[SENT] {full_command}")
        instr.write(full_command)
        return

    # --- 2. STPS (Start Phase) ---
    stps = kwargs.get('Start_Phase', 0.0)
    cmd_parts.append(f"STPS,{stps:#.15g}")

    # --- 3. GATE_NCYC (Carrier Mode) ---
    # 0=Triggered (NCYC), 1=Gated (GATE)
    trig_mode_input = kwargs.get('Triggered_Gated', 0)
    if trig_mode_input == 1:
        carrier_mode = "GATE"
    else:
        carrier_mode = "NCYC"
    cmd_parts.append(f"GATE_NCYC,{carrier_mode}")

    # --- 4. TRSR (Trigger Source) ---
    # 0=INT, 1=EXT, 2=MAN
    src_input = kwargs.get('TRG_Gate_Source', 0)
    TRSR_MAP = {0: 'INT', 1: 'EXT', 2: 'MAN'}
    trsr = TRSR_MAP.get(src_input, 'INT') 

    # LOCKOUT: Gated cannot be Manual -> Force EXT
    if carrier_mode == "GATE" and trsr == "MAN":
        print("[WARN] Manual Trigger not allowed in Gated mode. Switching to EXT.")
        trsr = "EXT"
    cmd_parts.append(f"TRSR,{trsr}")

    # --- 5. EDGE / PLRT ---
    pol_input = kwargs.get('Trg_Gate_Polarity', 0) 

    if carrier_mode == "GATE":
        # Gated -> PLRT (POS/NEG)
        val_str = "NEG" if pol_input == 1 else "POS"
        cmd_parts.append(f"PLRT,{val_str}")
    
    elif carrier_mode == "NCYC":
        # Triggered -> EDGE (RISE/FALL) - Only if EXT
        if trsr == "EXT":
            val_str = "FALL" if pol_input == 1 else "RISE"
            cmd_parts.append(f"EDGE,{val_str}")

    # --- 6. DLAY (Delay) ---
    delay = kwargs.get('Burst_Delay', 0.0)
    cmd_parts.append(f"DLAY,{delay:.15E}") 

    # --- 7. TIME (Cycle Count) ---
    # RULE: TIME is sent ONLY in NCYC mode. 
    # Gated mode NEVER sends TIME.
    if carrier_mode == "NCYC":
        cycle_mode_input = kwargs.get('Burst_Cycle', 0) # 0=N-Cycle, 1=Infinite
        
        if cycle_mode_input == 1:
            # Triggered + Infinite -> TIME,INF
            cmd_parts.append("TIME,INF")
        else:
            # Triggered + N-Cycle -> TIME,val
            val = kwargs.get('Number_of_Cycles', 1)
            cmd_parts.append(f"TIME,{val}")

    # --- 8. PRD (Period) ---
    # RULE: Sent ONLY if INT source. 
    # EXCEPTION: Skipped if Gated+Infinite.
    if trsr == 'INT':
        cycle_mode_input = kwargs.get('Burst_Cycle', 0)
        
        # In Gated mode, Infinite usually implies the gate controls everything, so no internal PRD.
        skip_prd = (carrier_mode == "GATE" and cycle_mode_input == 1)
        
        if not skip_prd:
            period = kwargs.get('Burst_Period', 0.0)
            cmd_parts.append(f"PRD,{period:.9E}")

    # --- 9. TRMD ---
    cmd_parts.append("TRMD,OFF")

    # --- Send ---
    full_command = f"C{channel}:BTWV {','.join(cmd_parts)}"
    print(f"[SENT] {full_command}")
    instr.write(full_command)

@register_command
def SDG60OutputOnOff(instr, channel, OUTPUT_ENABLED):

    cmd_parts = []
    cmd_parts.append(f"{OUTPUT_ENABLED}")
    if OUTPUT_ENABLED:
        cmd_parts.append("ON")
        full_command = f"C{channel}:OUTP {'ON'}"
        print(f"[SENT] {full_command}")
    else:
        cmd_parts.append("OFF")
        full_command = f"C{channel}:OUTP {'OFF'}"
        print(f"[SENT] {full_command}")
    instr.write(full_command)


if __name__ == "__main__":
    #awg = SDG6022X('TCPIP::127.0.0.1::5025::SOCKET')

    # 'TCPIP::169.254.11.24::INSTR'

    # TCPIP::127.0.0.1::5026::SOCKET

    with SDG6022X('TCPIP::127.0.0.1::5025::SOCKET') as awg:
        #SDG60RefClock(awg, True, False)
        #SDG60ConfPRBS(awg, channel=1, bit_rate_period=True, bit_rate=1000, period=0.2e-2, amp=1.0, offset=0.0,length=3, differential_mode=False, edge_time=1e-8)
        #SDG60ConfSTDWFM(awg, channel=1, waveform_type="SQUARE", is_freq_mode=True, freq=2.0, period=0.2e-2, amp=0.1, offset=0.0, ramp_symmetry=50.0, phase=0.0,)
        #SDG60ConfPulse1(awg, dict(channel=1, freq=1e3, amp=2.0, offset=0.0, pulse_width=1e-3, rise_time=1e-6))
        #SDG60LoadPolarity(awg, dict(channel=1, Impedance=50, polarity="NOR"))
        #SDG60ModulationOff(awg, channel=1, OUTPUT_ENABLED=True)
        #SDG60Trg(instr=awg)
        #SDG60SelectChannel(awg, channel=1)
        #SDG60SelectArbitraryWFM(awg, channel=1, user_arb_number=10)
        #SDG60SelectArbitraryWFM(awg, channel=1, builtin_index=5)
        #SDG60ReadParameters(awg, channel=1)
        #SDG60ReadArbitraryWFMQ(awg, waveform_name="ARB1")
        #SDG60Initialize(awg, OUTPUT_ENABLED=False)
        #SDG60ConfNoise(awg, channel=1, std_dev=0.0080, voltage_mean=0.0, is_bandstate=False, bandwidth=80e6)
        #SDG60ConfArbWaveform3(awg, channel=1, is_DDS=False, frequency=2.0,amp=0.1, offset=0.0,phase=0.0, interpolation_index=2)
        #SDG60ConfBurst2(awg,Channel=1,Enable_Burst=True,Triggered_Gated=1,TRG_Gate_Source=2, Burst_Cycle=1,Start_Phase=2.0,Number_of_Cycles=-9,Burst_Period=1.352e-6,Burst_Delay=1.352e-6)
        SDG60OutputOnOff(awg, channel=1, OUTPUT_ENABLED=False)
