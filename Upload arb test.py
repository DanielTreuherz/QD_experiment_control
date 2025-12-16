#!/usr/bin/env python

import pyvisa
import numpy as np

# -----------------------
# Hard-coded parameters
# -----------------------
address = 'TCPIP::169.254.11.23::INSTR'
ARB_NAME = "khzsine"
PULSEHEIGHT = "0.1"

# -----------------------
# Generate a numpy waveform
# -----------------------
num_points = 1000
sample_rate = 1e6  # 1 MSa/s
t = np.linspace(0, 1, num_points, endpoint=False)

# Simple test waveform: sine wave
sig = np.sin(2 * np.pi * 5 * t).astype("f4")

# Normalize to [-1, 1] (AWG requirement)
sig /= np.max(np.abs(sig))

# -----------------------
# VISA connection
# -----------------------
rm = pyvisa.ResourceManager('@py')
inst = rm.open_resource(address)

print(inst.query("*IDN?"))

# -----------------------
# Upload waveform
# -----------------------
inst.write("DISP:TEXT 'Uploading ARB'")
inst.write("FORM:BORD SWAP")
inst.write("SOUR1:DATA:VOL:CLE")

inst.write_binary_values(
    f"SOUR1:DATA:ARB {ARB_NAME},",
    sig,
    datatype='f',
    is_big_endian=False
)

inst.write("*WAI")

# -----------------------
# Configure output
# -----------------------
inst.write(f"SOUR1:FUNC:ARB {ARB_NAME}")
inst.write(f"SOUR1:FUNC:ARB:SRAT {sample_rate}")
inst.write("SOUR1:VOLT:OFFS 0")
inst.write("SOUR1:FUNC ARB")
inst.write(f"SOUR1:VOLT {PULSEHEIGHT}")

inst.write("DISP:TEXT ''")



inst.close()
