import pyvisa
import socket

rm = pyvisa.ResourceManager()

for r in rm.list_resources():
    print(f"Original: {r}")

    if not r.startswith("TCPIP"):
        continue

    parts = r.split("::")

    # parts example:
    # ['TCPIP0', 'A-33622A-00172.local', 'inst0', 'INSTR']

    host = parts[1]

    try:
        ip = socket.gethostbyname(host)

        # replace hostname with IP, keep inst0 and INSTR
        ip_resource = "::".join([parts[0], ip, *parts[2:]])

        print(f"IP VISA:  {ip_resource}")

    except OSError:
        print("IP VISA:  <hostname unresolved>")

    print()
