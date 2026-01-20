import socket, threading, os, difflib

last = {"DEV_1": "", "DEV_2": ""}

def start_device(port, name):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('', port))
    server.listen()
    server.settimeout(1.0)
    print(f"Simulator {name} listening on port {port}...")

    while True:
        try:
            conn, addr = server.accept()
            with conn:
                while data := conn.recv(1024):
                    cmd = data.decode().strip()
                    if not cmd : 
                        continue

                    other_name = "DEV_2" if name == "DEV_1" else "DEV_1"
                    other = last[other_name]
                    
                    print(f"\n[{name}] Update:")
                    if last[name] == cmd:
                        print('No change to command')
                        continue     
                    
                    last[name] = cmd                 

                    G, R, E = "\033[92m", "\033[91m", "\033[0m"

                    if cmd == other:
                        print(f"IDENTICAL: {cmd}")
                    else:
                        s1, s2 = last["DEV_1"], last["DEV_2"]
                        res1, pairs = "", []
                        for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(None, s1, s2).get_opcodes():
                            p1, p2 = s1[i1:i2], s2[j1:j2]
                            if tag == 'equal':
                                res1 += p1
                            elif tag == 'insert':
                                res1 += f"{R}{p2}{E}"
                                pairs.append((f"MISSING {p2}", p2))
                            else:
                                res1 += f"{G}{p1}{E}"
                                pairs.append((p1, p2))

                        print(f'Python:  {res1}')
                        print(f'Labview: {s2}')
                        
                        w = max(len(p[0]) for p in pairs) if pairs else 0
                        w+=2
                        print(f"{f"Python":<{w}} - Labview")
                        for p1, p2 in pairs:
                            print(f"{f"'{p1}'":<{w}} - '{p2}'")
                            
        except (socket.timeout, KeyboardInterrupt): continue

threading.Thread(target=start_device, args=(5025, "DEV_1"), daemon=True).start()
try:
    start_device(5026, "DEV_2")
except KeyboardInterrupt:
    print("\nShutting down...")