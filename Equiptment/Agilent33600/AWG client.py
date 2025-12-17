from yaqc import Client

awg = Client("awg-33600a")

awg.set_function("sine", channel=1)
awg.set_frequency(1e6, channel=1)
awg.set_amplitude(0.5, channel=1)
awg.enable_output(True, channel=1)

awg.enable_burst(True, channel=1)
awg.set_burst_ncycles(10, channel=1)
