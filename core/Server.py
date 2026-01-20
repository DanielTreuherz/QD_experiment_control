import zmq
import json
from core.Registry import commands, devices

def handle_tcp(message):
    message_json = json.loads(message)
    cmd = message_json.pop('cmd')
    instr = message_json.pop('instr')
    devices[instr].commands[cmd](**message_json)



