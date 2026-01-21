import zmq
import json
from core import devices

def handle_tcp(message):
    message_json = json.loads(message)
    cmd = message_json.pop('cmd')
    instr = message_json.pop('instr')
    result_msg = devices[instr].commands[cmd](**message_json)

    if result_msg is None:
        return 'Operation complete'
    else:
        return result_msg


