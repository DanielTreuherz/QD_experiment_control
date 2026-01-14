import numpy as np
from pylablib.devices import AWG
import random
import string

ip = 'TCPIP::169.254.11.24::INSTR'

class SiglentSDG(AWG.GenericAWG):
    """Driver for Siglent SDG6000X/2000X series AWGs."""
    
    def __init__(self, addr):
        super().__init__(addr)
        
        # Access the raw PyVISA resource to adjust timeouts
        raw_dev = self.instr.instr
        raw_dev.timeout = 20_000          # 20s timeout (uploading large ARBs takes time)
        raw_dev.chunk_size = 4 * 1024 * 1024  # 4MB chunk size

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
        
    def set_amplitude(self, amplitude, channel=1):
        """Sets amplitude in Vpp"""
        self.write(f"C{channel}:BSWV AMP,{amplitude}")
        
    def set_output(self, state, channel=1):
        """Turn output ON or OFF"""
        state_str = "ON" if state else "OFF"
        self.write(f"C{channel}:OUTP {state_str}")


if __name__=="__main__":
    # --- usage example ---
    
    # 1. Generate Signal
    num_points = 10000
    t = np.linspace(0, 1, int(num_points))
    # Mix of sines
    sig = np.sin(2 * np.pi * 50 * t) + np.sin(2 * np.pi * 120 * t)
    # Normalize to -1 to 1
    sig /= np.max(np.abs(sig))

    # 2. Generate Random Name (Siglent names should be short)
    length = 6
    random_string = ''.join(random.choices(string.ascii_letters, k=length))
    
    print(f"Connecting to {ip}...")
    awg = SiglentSDG(ip)
    
    print(f"Device ID: {awg.ask('*IDN?')}")

    print(f"Uploading waveform '{random_string}'...")
    awg.upload_custom_waveform(random_string, sig, channel=1)

    print("Configuring output...")
    awg.set_sample_rate(100000, channel=1) # 100 kSa/s
    awg.set_amplitude(2.0, channel=1)      # 2 Vpp
    
    # Turn it on
    awg.set_output(True, channel=1)
    
    print("Done.")
    awg.close()