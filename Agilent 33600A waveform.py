# import pyvisa
# rm = pyvisa.ResourceManager('@py')
# rm.list_resources()
# inst = rm.open_resource(ip)
# print(inst.query("*IDN?"))


from pylablib.devices import AWG


ip = 'TCPIP::169.254.11.23::INSTR'



class Agilent33600A(AWG.GenericAWG):
    """Minimal driver wrapper for Keysight/Agilent 33600A series AWGs."""
    def __init__(self, addr):
        self._channels_number = 2  # 33600A has 2 channels
        super().__init__(addr)


awg=Agilent33600A(ip)

awg.set_amplitude(1.2, channel=1)

awg.close()
