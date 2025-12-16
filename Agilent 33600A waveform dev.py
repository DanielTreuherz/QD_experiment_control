from pylablib.devices import AWG
import numpy as np



ip = 'TCPIP::169.254.11.23::INSTR'

class Agilent33600A(AWG.GenericAWG):
    """Minimal driver wrapper for Keysight/Agilent 33600A series AWGs."""
    _default_operation_timeout = 10.0
    _default_backend_timeout = 5.0
    
    def __init__(self, addr):
        self._channels_number = 2 
        super().__init__(addr)
        
        raw_dev = self.instr.instr

        # Set once, never touch again
        raw_dev.timeout = 20_000          # ms
        raw_dev.chunk_size = 4 * 1024 * 1024  # 4 MB safe value|

    def upload_custom_waveform(self, name, waveform, channel=1):
        waveform = np.asarray(waveform, dtype=np.float32)
        payload = waveform.tobytes()

        raw_dev = self.instr.instr

        # 1. Setup
        self.write("DISP:TEXT 'Uploading ARB'")
        self.write("FORM:BORD SWAP")
        self.write(f"SOUR{channel}:DATA:VOL:CLE")

        # 2. Manual binary upload
        byte_count = len(payload)
        len_str = str(byte_count)
        header = f"#{len(len_str)}{len_str}".encode("ascii")

        cmd = f"SOUR{channel}:DATA:ARB {name},".encode("ascii")
        message = cmd + header + payload + b"\n"

        raw_dev.write_raw(message)

        self.write("*WAI")

        # 3. Configure
        self.write(f"SOUR{channel}:FUNC:ARB {name}")
        self.write("DISP:TEXT ''")


    def set_sample_rate(self, sample_rate, channel):
        # Access the raw PyVISA resource
        self.write("*WAI")
        self.write(f"SOUR{channel}:FUNC:ARB:SRAT {sample_rate}") #Set sample rate


# Generate waveform
num_points = 4e6
sample_rate = 1e6
t = np.linspace(0, 1, int(num_points))
sig = np.sin(2 * np.pi * np.random.random()*50 * t) + np.sin(2 * np.pi * np.random.random()*50 * t) + np.sin(2 * np.pi * np.random.random()*50 * t) 
sig /= np.max(np.abs(sig))


import random
import string
length = 4
random_string = ''.join(random.choices(string.ascii_letters, k=length))



# Run class wrapper
awg = Agilent33600A(ip)

awg.upload_custom_waveform(random_string, sig)
awg.set_function('arb')

# print(awg.ask("SYST:ERR?"))

# awg.set_sample_rate(1000, 1)
# awg.set_offset(0)
# awg.set_amplitude(1.5)

awg.close()


