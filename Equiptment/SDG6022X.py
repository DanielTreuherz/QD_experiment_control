import pyvisa


class SDG6022X:
    def __init__(self, addr):
        
        rm = pyvisa.ResourceManager()
        self.instrument = rm.open_resource(addr)
        #idn = self.instrument.query('*IDN?')
        #print(f"Connected to: {idn.strip()}")
            

    def control_off(self):
        """Turn output OFF"""
        self.instrument.write("C1:OUTP OFF")

    def control_on(self):
        """Turn output ON"""
        self.instrument.write("C1:OUTP ON")

    def set_freq(self, waveform="SQUARE", freq=500, amp=1):
        """Set frequency, waveform and amplitude"""
        cmd = f"C1:BSWV WVTP,{waveform},FRQ,{freq},AMP,{amp}"
        self.instrument.write(cmd)
        
    def close(self):
        self.instrument.close()

if __name__ == "__main__":
    # Usage
    ip = "TCPIP::169.254.11.24::INSTR"    

    awg = SDG6022X(ip) 

    awg.control_on()
    awg.set_freq()
    #awg.control_off()
    awg.close()