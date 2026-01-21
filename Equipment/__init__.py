
import os
os.environ["PYVISA_LIBRARY"] = "@py"

# from .sdg6022x import SDG6022X
from .agilent33600A import Agilent33600A

