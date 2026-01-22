import socket, threading

Y, G, E = "\033[93m", "\033[92m", "\033[0m"
last = {"DEV_1": "", "DEV_2": ""}

def start_device(port, name):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('', port))
    server.listen()
    server.settimeout(1.0)
    print(f"Simulator {name} listening on port {port}...")

    color = Y if name == "DEV_1" else G
    label = "Python" if name == "DEV_1" else "Labview"

    while True:
        try:
            conn, addr = server.accept()
            with conn:
                while data := conn.recv(1024):
                    cmd = data.decode().strip()
                    if not cmd or cmd == last[name]: 
                        continue

                    last[name] = cmd
                    print(f"{color}[{label}]: {cmd}{E}")
                            
        except (socket.timeout, KeyboardInterrupt): continue

threading.Thread(target=start_device, args=(5025, "DEV_1"), daemon=True).start()
try:
    start_device(5026, "DEV_2")
except KeyboardInterrupt:
    print("\nShutting down...")