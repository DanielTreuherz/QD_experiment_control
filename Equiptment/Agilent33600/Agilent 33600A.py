from pylablib.devices import AWG
import numpy as np



ip = 'TCPIP::169.254.11.23::INSTR'

import numpy as np


class Agilent33600A(AWG.GenericAWG):
    """
    Minimal driver wrapper for Keysight/Agilent 33600A series AWGs.

    Args:
        addr: VISA address of the instrument.
        channels_number: number of channels; default is 2.
    """

    def __init__(self, addr, channels_number=2):
        self._channels_number = channels_number
        super().__init__(addr)

        # Access the raw PyVISA instrument
        visa_instr = self.instr.instr
        visa_instr.timeout = 20_000          # ms
        visa_instr.chunk_size = 4 * 1024 * 1024  # 4 MB safe value

    def upload_custom_waveform(self, name, waveform, channel=1):
        """
        Upload a custom waveform to the specified channel.

        Args:
            name (str): Name to assign to the waveform in the AWG.
            waveform (array-like): Waveform data as float32 values in [-1, 1].
            channel (int, optional): Channel number. Default is 1.
        """
        waveform = np.asarray(waveform, dtype=np.float32)
        payload = waveform.tobytes()

        visa_instr = self.instr.instr

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

        visa_instr.write_raw(message)
        self.write("*WAI")

        # 3. Configure waveform
        self.write(f"SOUR{channel}:FUNC:ARB {name}")
        self.write("DISP:TEXT ''")

    def set_sample_rate(self, sample_rate, channel=1):
        """
        Set the sample rate for a specified channel.

        Args:
            sample_rate (float): Sample rate in Sa/s.
            channel (int, optional): Channel number. Default is 1.
        """
        self.write("*WAI")
        self.write(f"SOUR{channel}:FUNC:ARB:SRAT {sample_rate}")


if __name__=="__main__":
    num_points = 4e6
    sample_rate = 1e6
    t = np.linspace(0, 1, int(num_points))
    
    sig = np.sin(2 * np.pi * 50 * t) 
    sig /= np.max(np.abs(sig))

    
    awg = Agilent33600A(ip)

    awg.upload_custom_waveform('test', sig)
    awg.set_function('arb')
    awg.set_sample_rate(sample_rate)

    awg.close()


