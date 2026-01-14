from Agilent33600A import Agilent33600A

ip = 'TCPIP0::A-33622A-00172.local::inst0::INSTR'
awg = Agilent33600A(ip)


def A33ArbPhaseSync():
   awg.arb_phase_sync()

def A33ClearArbitrary():
   awg.clear_arbritrary()

def A33ConfigureAM(channel, AM_source, modulation_waveform, modulation_frequency, enable_carrier_supression, enable_amplitude_modulation, modulation_depth):
   

