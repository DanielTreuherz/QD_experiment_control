import socket, threading, os, time

last = {"DEV_1": "", "DEV_2": ""}

def start_device(port, name):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('', port))
    server.listen()
    server.settimeout(1.0) # Allows main thread to catch Ctrl+C
    print(f"Simulator {name} listening on port {port}...")

    while True:
        try:
            conn, addr = server.accept()
            with conn:
                print(f"\n[{name}] Client connected from {addr}")
                while data := conn.recv(1024):
                    cmd = data.decode().strip()
                    if not cmd: continue
                    
                    last[name] = cmd
                    other = last["DEV_2" if name == "DEV_1" else "DEV_1"]
                    
                    if cmd == other:
                        print(f"IDENTICAL: {cmd}")
                    else:
                        pre = os.path.commonprefix([last["DEV_1"], last["DEV_2"]])
                        d1, d2 = last["DEV_1"][len(pre):], last["DEV_2"][len(pre):]
                        print(f"COMMON: '{pre}'\nDIFF: \nDEV_1='{d1}'\nDEV_2='{d2}'")
        except socket.timeout:
            continue
        except KeyboardInterrupt:
            break

# Run
threading.Thread(target=start_device, args=(5025, "DEV_1"), daemon=True).start()
try:
    start_device(5026, "DEV_2")
except KeyboardInterrupt:
    print("\nShutting down...")