from awg_scpi import AWG

from time import sleep    
import argparse
parser = argparse.ArgumentParser(description='Access and control an AWG')
parser.add_argument('chan', nargs='?', type=int, help='Channel to access/control (starts at 1)', default=1)
args = parser.parse_args()

from os import environ
resource = environ.get('AWG_IP', 'TCPIP::169.254.11.24::INSTR')
instr = AWG(resource)

## Upgrade Object to best match based on IDN string
instr = instr.getBestClass()

## Open this object and work with it
instr.open()

print('Using SCPI Device:     ' + instr.idn() + ' of series: ' + instr.series + '\n')

# set the channel (can pass channel to each method or just set it
# once and it becomes the default for all following calls)
instr.channel = str(args.chan)

if instr.isOutputHiZ(instr.channel):
    print("Output High Impedance")
else:
    print("Output 50 ohm load")

instr.beeperOn()

# return to default parameters
instr.reset()               

instr.setWaveType('SQUARE')
instr.setFrequency(34.4590897823e3)
instr.setVoltageProtection(6.6)
instr.setAmplitude(3.2)
instr.setOffset(1.6)
instr.setPhase(0.45)

print("Voltage Protection is set to maximum: {}V Amplitude (assumes 0V offset)".format(instr.queryVoltageProtection()))

# turn on the channel
instr.outputOn()

# return to LOCAL mode
instr.setLocal()

instr.close()