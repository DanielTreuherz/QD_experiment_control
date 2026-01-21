import zmq
import json 

context = zmq.Context()
socket = context.socket(zmq.REQ)
socket.connect("tcp://localhost:5555")

    
# Create the dictionary
data = {}

while True:
    data['cmd']=input('cmd: ')
    data['instrument']=input('instr: ')
    data['arg1']=input('arg1: ')

    print(f"Sending: {data}")
    socket.send_json(data)

    # Receive response as a dict
    message = socket.recv_string()
    print(f"Received: {message}")