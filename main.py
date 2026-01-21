import zmq
from contextlib import ExitStack
import traceback

from core.Server import handle_tcp
# from core.Registry import register_device, commands, devices

from Equipment import Agilent33600A
from core import register_device, devices

device_configs = {
    'AG33600A_Gen1' : (Agilent33600A, 'TCPIP::169.254.11.23::INSTR'),
    # 'AG33600A_Gen1' : (Agilent33600A, 'TCPIP::169.254.49.101::5025::SOCKET'),
    # 'SDG6022X_Gen1' : SDG6022X('TCPIP::169.254.11.24::INSTR'),
}


with ExitStack() as stack:
    for instrument_name, (instrument_class, addr) in device_configs.items():
        dev = stack.enter_context(instrument_class(addr))
        register_device(instrument_name, dev)

    context = stack.enter_context(zmq.Context())
    socket = stack.enter_context(context.socket(zmq.REP))
    socket.bind("tcp://*:5555")
    socket.RCVTIMEO = 1000


    run = True
    while run:
        try:
            message = socket.recv_string()
            return_msg = handle_tcp(message)
            socket.send_string(return_msg)
            
        except zmq.Again:
            # print('Waiting for command')
            continue
        
        except KeyboardInterrupt:
            print('Closing connections')
            run = False
            
        except Exception as e:
            print(f'Error: {e}')
            print('Json message:')
            print(message)
            print('lead to an error')

            traceback.print_exc()
            socket.send_string(f'ERROR {e}')

            # run=False

print('Connections closed.')