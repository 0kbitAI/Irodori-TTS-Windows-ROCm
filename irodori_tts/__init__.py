"""Irodori-TTS package: text-conditioned RF diffusion over DACVAE latents."""

from . import _rocm_compatibility  # noqa: F401 - Initialize ROCm runtime compatibility layer

from .config import ModelConfig, TrainConfig
from .lora import LORA_TARGET_PRESETS
from .model import TextToLatentRFDiT
from .tokenizer import PretrainedTextTokenizer

__all__ = [
    "LORA_TARGET_PRESETS",
    "ModelConfig",
    "PretrainedTextTokenizer",
    "TextToLatentRFDiT",
    "TrainConfig",
]
