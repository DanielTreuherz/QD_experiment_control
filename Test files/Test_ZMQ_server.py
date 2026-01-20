#
#   Hello World server in Python
#   Binds REP socket to tcp://*:5555
#   Expects b"Hello" from client, replies with b"World"
#

import time
import zmq
import traceback

context = zmq.Context()
socket = context.socket(zmq.REP)
socket.bind("tcp://*:5555")
socket.RCVTIMEO = 1000

while True:
    #  Wait for next request from client

    try:
        message = socket.recv_json()
        print("Received request: %s" % message)
        time.sleep(1)

        socket.send_string(f"Python succesfully received {message}")
    except zmq.Again:
        # print('Waiting for command')
        continue
    except Exception as e:
        error_msg = f"ERROR: Python ERROR: {type(e).__name__} - {str(e)}\n{traceback.format_exc()}"
        socket.send_string(f"ERROR: Python ERROR: {error_msg}")