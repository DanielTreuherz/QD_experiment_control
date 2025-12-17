"""
yaq daemon for GenericAWG / Agilent 33600A using pylablib

This daemon exposes (nearly) the full GenericAWG surface in a safe,
channel-aware way. One daemon instance corresponds to one physical AWG.

Config (YAML):
  daemon:
    name: awg-33600a
    port: 39001
  device:
    addr: TCPIP0::192.168.1.50::inst0::INSTR
"""

import numpy as np
from typing import Tuple, Optional

from yaqd_core import IsDaemon

from pylablib.devices import AWG


class GenericAWGDaemon(IsDaemon):
    """yaq daemon wrapping pylablib GenericAWG."""

    _kind = "generic-awg"

    def __init__(self, name, config, **kwargs):
        super().__init__(name, config, **kwargs)

        addr = config["addr"]
        self._awg = AWG.GenericAWG(addr)
        self._channels = self._awg.get_channels_number()

    # -----------------
    # Channel utilities
    # -----------------

    def get_channels_number(self) -> int:
        return self._channels

    def select_current_channel(self, channel: int):
        self._validate_channel(channel)
        self._awg.select_current_channel(channel)

    def _validate_channel(self, channel: Optional[int]):
        if channel is None:
            return
        if channel < 1 or channel > self._channels:
            raise ValueError(f"channel must be in [1, {self._channels}]")

    # -----------------
    # Output control
    # -----------------

    def is_output_enabled(self, channel: int = None) -> bool:
        self._validate_channel(channel)
        return self._awg.is_output_enabled(channel=channel)

    def enable_output(self, enabled: bool = True, channel: int = None) -> bool:
        self._validate_channel(channel)
        return self._awg.enable_output(enabled, channel=channel)

    def get_output_polarity(self, channel: int = None) -> str:
        self._validate_channel(channel)
        return self._awg.get_output_polarity(channel=channel)

    def set_output_polarity(self, polarity: str = "norm", channel: int = None) -> str:
        self._validate_channel(channel)
        return self._awg.set_output_polarity(polarity, channel=channel)

    def is_sync_output_enabled(self, channel: int = None) -> bool:
        self._validate_channel(channel)
        return self._awg.is_sync_output_enabled(channel=channel)

    def enable_sync_output(self, enabled: bool = True, channel: int = None) -> bool:
        self._validate_channel(channel)
        return self._awg.enable_sync_output(enabled, channel=channel)

    # -----------------
    # Load / range
    # -----------------

    def get_load(self, channel: int = None) -> float:
        self._validate_channel(channel)
        return self._awg.get_load(channel=channel)

    def set_load(self, load: Optional[float] = None, channel: int = None) -> float:
        self._validate_channel(channel)
        return self._awg.set_load(load, channel=channel)

    def get_output_range(self, channel: int = None) -> Tuple[float, float]:
        self._validate_channel(channel)
        return self._awg.get_output_range(channel=channel)

    def set_output_range(self, rng, channel: int = None) -> Tuple[float, float]:
        self._validate_channel(channel)
        return self._awg.set_output_range(rng, channel=channel)

    # -----------------
    # Function control
    # -----------------

    def get_function(self, channel: int = None) -> str:
        self._validate_channel(channel)
        return self._awg.get_function(channel=channel)

    def set_function(self, func: str, channel: int = None) -> str:
        self._validate_channel(channel)
        return self._awg.set_function(func, channel=channel)

    def get_amplitude(self, channel: int = None) -> float:
        self._validate_channel(channel)
        return self._awg.get_amplitude(channel=channel)

    def set_amplitude(self, amplitude: float, channel: int = None) -> float:
        self._validate_channel(channel)
        return self._awg.set_amplitude(amplitude, channel=channel)

    def get_offset(self, channel: int = None) -> float:
        self._validate_channel(channel)
        return self._awg.get_offset(channel=channel)

    def set_offset(self, offset: float, channel: int = None) -> float:
        self._validate_channel(channel)
        return self._awg.set_offset(offset, channel=channel)

    def get_frequency(self, channel: int = None) -> float:
        self._validate_channel(channel)
        return self._awg.get_frequency(channel=channel)

    def set_frequency(self, frequency: float, channel: int = None) -> float:
        self._validate_channel(channel)
        return self._awg.set_frequency(frequency, channel=channel)

    def get_phase(self, channel: int = None) -> Optional[float]:
        self._validate_channel(channel)
        return self._awg.get_phase(channel=channel)

    def set_phase(self, phase: float, channel: int = None) -> Optional[float]:
        self._validate_channel(channel)
        return self._awg.set_phase(phase, channel=channel)

    def sync_phase(self):
        return self._awg.sync_phase()

    # -----------------
    # Waveform specifics
    # -----------------

    def get_duty_cycle(self, channel: int = None) -> float:
        self._validate_channel(channel)
        return self._awg.get_duty_cycle(channel=channel)

    def set_duty_cycle(self, duty_cycle: float, channel: int = None) -> float:
        self._validate_channel(channel)
        return self._awg.set_duty_cycle(duty_cycle, channel=channel)

    def get_ramp_symmetry(self, channel: int = None) -> float:
        self._validate_channel(channel)
        return self._awg.get_ramp_symmetry(channel=channel)

    def set_ramp_symmetry(self, symmetry: float, channel: int = None) -> float:
        self._validate_channel(channel)
        return self._awg.set_ramp_symmetry(symmetry, channel=channel)

    def get_pulse_width(self, channel: int = None) -> float:
        self._validate_channel(channel)
        return self._awg.get_pulse_width(channel=channel)

    def set_pulse_width(self, width: float, channel: int = None) -> float:
        self._validate_channel(channel)
        return self._awg.set_pulse_width(width, channel=channel)

    # -----------------
    # Burst / trigger
    # -----------------

    def is_burst_enabled(self, channel: int = None) -> bool:
        self._validate_channel(channel)
        return self._awg.is_burst_enabled(channel=channel)

    def enable_burst(self, enabled: bool = True, channel: int = None) -> bool:
        self._validate_channel(channel)
        return self._awg.enable_burst(enabled, channel=channel)

    def get_burst_mode(self, channel: int = None) -> str:
        self._validate_channel(channel)
        return self._awg.get_burst_mode(channel=channel)

    def set_burst_mode(self, mode: str, channel: int = None) -> str:
        self._validate_channel(channel)
        return self._awg.set_burst_mode(mode, channel=channel)

    def get_burst_ncycles(self, channel: int = None) -> int:
        self._validate_channel(channel)
        return self._awg.get_burst_ncycles(channel=channel)

    def set_burst_ncycles(self, ncycles: Optional[int] = 1, channel: int = None) -> int:
        self._validate_channel(channel)
        return self._awg.set_burst_ncycles(ncycles, channel=channel)

    def get_gate_polarity(self, channel: int = None) -> str:
        self._validate_channel(channel)
        return self._awg.get_gate_polarity(channel=channel)

    def set_gate_polarity(self, polarity: str = "norm", channel: int = None) -> str:
        self._validate_channel(channel)
        return self._awg.set_gate_polarity(polarity, channel=channel)

    def get_trigger_source(self, channel: int = None) -> str:
        self._validate_channel(channel)
        return self._awg.get_trigger_source(channel=channel)

    def set_trigger_source(self, src: str, channel: int = None) -> str:
        self._validate_channel(channel)
        return self._awg.set_trigger_source(src, channel=channel)

    def get_trigger_slope(self, channel: int = None) -> str:
        self._validate_channel(channel)
        return self._awg.get_trigger_slope(channel=channel)

    def set_trigger_slope(self, slope: str, channel: int = None) -> str:
        self._validate_channel(channel)
        return self._awg.set_trigger_slope(slope, channel=channel)

    def is_trigger_output_enabled(self, channel: int = None) -> bool:
        self._validate_channel(channel)
        return self._awg.is_trigger_output_enabled(channel=channel)

    def enable_trigger_output(self, enabled: bool = True, channel: int = None) -> bool:
        self._validate_channel(channel)
        return self._awg.enable_trigger_output(enabled, channel=channel)

    def get_output_trigger_slope(self, channel: int = None) -> str:
        self._validate_channel(channel)
        return self._awg.get_output_trigger_slope(channel=channel)

    def set_output_trigger_slope(self, slope: str, channel: int = None) -> str:
        self._validate_channel(channel)
        return self._awg.set_output_trigger_slope(slope, channel=channel)
    





