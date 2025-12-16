def control_sdg6022x_OFF():
    if __name__ == "__main__":
        import pyvisa # type: ignore
        rm = pyvisa.ResourceManager()
        print(rm.list_resources())
        my_instrument = rm.open_resource(rm.list_resources()[0])
        print(my_instrument.query('*IDN?'))
        my_instrument.write("C1:OUTP OFF")
        
control_sdg6022x_OFF()

def control_sdg6022x_ON():
    if __name__ == "__main__":
        import pyvisa # type: ignore
        rm = pyvisa.ResourceManager()
        print(rm.list_resources())
        my_instrument = rm.open_resource(rm.list_resources()[0])
        print(my_instrument.query('*IDN?'))
        my_instrument.write("C1:OUTP ON")
        
#control_sdg6022x_ON()

def control_sdg6022x_set_freq():
    if __name__ == "__main__":
        import pyvisa # type: ignore
        rm = pyvisa.ResourceManager()
        print(rm.list_resources())
        my_instrument = rm.open_resource(rm.list_resources()[0])
        print(my_instrument.query('*IDN?'))
        my_instrument.write("C1:BSWV WVTP,SQUARE,FRQ,100000,AMP,1")

control_sdg6022x_set_freq()