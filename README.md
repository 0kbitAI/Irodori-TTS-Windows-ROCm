# Irodori-TTS (Windows Native ROCm Fork)

This repository is a specialized fork of [Aratako/Irodori-TTS](https://github.com/Aratako/Irodori-TTS) that enables **native AMD ROCm (GPU) acceleration on Windows 10/11 without any local C++ builds**.

- **Upstream Base Commit:** [`8224dafb46d0aba89209a8f905f1cb7e3299d9c1`](https://github.com/Aratako/Irodori-TTS/commit/8224dafb46d0aba89209a8f905f1cb7e3299d9c1) (v4.1)
- **Verified Hardware:** AMD Radeon RX 6600 XT (RDNA 2 / `gfx1032`)
- **Python Version:** 3.12

---

## Key Feature: Zero-Build One-Command Setup

In upstream Irodori-TTS, `--extra rocm` is intended for Linux/WSL. When run on Windows, it silently falls back to CPU mode because official PyTorch ROCm wheels for Windows do not exist on standard channels.

This fork leverages AMD's official pre-built preview wheels (ROCm TheRock). **You do not need Visual Studio, C++ compilers, or CMake.** Everything is resolved and installed in a single command using `uv`.

> **Note on GPU Generations:**  
> ROCm packages differ by GPU architecture. Please choose the appropriate extra for your hardware:
> - **RDNA 2 (RX 6000 Series):** `uv sync --extra rocm-win`
> - **RDNA 3 (RX 7000 Series):** `uv sync --extra rocm-win-rdna3`

---

## Supported Environments

This fork is **specifically tailored for native Windows**.

| Hardware | Sync Command | Status |
| :--- | :--- | :---: |
| **AMD Radeon RX 6000 Series (RDNA 2)** | `uv sync --extra rocm-win` | **Verified (RX 6600 XT)** |
| **AMD Radeon RX 7000 Series (RDNA 3)** | `uv sync --extra rocm-win-rdna3` | Configured |
| **AMD Radeon RX 9000 Series (RDNA 4)** | See note below | Community Testing Welcome |
| **NVIDIA GeForce (CUDA)** | `uv sync --extra cu128` | Supported |
| **CPU Only** | `uv sync --extra cpu` | Supported |

> **About RDNA 4 (RX 9000 Series):**  
> AMD TheRock provides `gfx120X-all` wheels for RDNA 4 architectures. While theoretically compatible with a similar setup, it is currently untested on this repository. Verification and feedback from RDNA 4 users are warmly welcomed!

> **Note for Linux / macOS users:**  
> Please use the upstream repository [Aratako/Irodori-TTS](https://github.com/Aratako/Irodori-TTS).

---

## Quick Start
### 📋 Prerequisites

Before getting started, make sure you have the following installed on your Windows system:
- **`git`**
- **`uv`** (Fast Python package manager)

*(Installation of `git` and `uv` is outside the scope of this project).*

### 1. Clone & Sync

```powershell
# Clone this repository
git clone https://github.com/0kbitAI/Irodori-TTS-Windows-ROCm.git
cd Irodori-TTS-Windows-ROCm

# Install dependencies according to your GPU:
# For RX 6000 series:
uv sync --extra rocm-win

# For RX 7000 series:
uv sync --extra rocm-win-rdna3
```

### 2. Launch

You can easily launch by double-clicking the included `.bat` files, or running via command line:

- **Reference Voice WebUI:** Double-click `run_webui.bat`  
  *(CLI: `uv run --no-sync python gradio_app.py`)*
- **Voice Design WebUI:** Double-click `run_voicedesign.bat`  
  *(CLI: `uv run --no-sync python gradio_app_voicedesign.py`)*

*(The batch files use `--no-sync` to prevent accidental re-downloads or package overwrites).*

---

## Key Modifications & Why They Were Necessary

1. **`pyproject.toml` (Dependency Resolution & Platform Isolation):**  
   Restricted `environments = ["sys_platform == 'win32'"]` and `requires-python = ">=3.12, <3.13"` to prevent `uv` from evaluating incompatible Linux/XPU dependencies. Added AMD's preview indexes with proper mutual exclusions (`conflicts`).
2. **`sentencepiece` Version Bump (`>=0.2.0`):**  
   Old versions (0.1.99) lack pre-built Windows wheels on Python 3.12, triggering a CMake build failure.
3. **`irodori_tts/_compat.py` (Distributed Stub for audiotools):**  
   Injected a dummy `torch.distributed.ReduceOp` to avoid `AttributeError` on Windows PyTorch builds that lack distributed training modules.
4. **`irodori_tts/watermark.py` (CPU Fallback for SilentCipher):**  
   Forced `SilentCipherWatermarker` backend to initialize on `cpu`. This completely bypasses MIOpen's BatchNorm JIT compilation error (`hiprtcCompileProgram: 'type_traits' file not found`) while preserving 100% of the inaudible watermark functionality without noticeable latency (~0.05s).
5. **Default Codec Device Set to CPU (`codec_device="cpu"`):**  
   - **Why:** On Windows ROCm (`gfx1032`), MIOpen lacks optimized Composable Kernel (CK) libraries for `ConvTranspose1d` used in DACVAE decoding. Executing the codec on GPU triggers continuous fallback searches (`GemmFwdRest`) and massive workspace memory allocations (400MB+), resulting in extreme latency (~300s+) and Windows TDR (driver timeout / `HIP error: unspecified launch failure`).  
   - **Fix:** Separated the codec device from the main model device and set its default to `cpu`. While the main diffusion model runs on the GPU (~4–7s), DACVAE decoding runs safely on the CPU in just ~2–3s without triggering MIOpen bugs. This completely eliminates driver crashes and reduces total generation time from ~6 minutes to ~7–10 seconds.

---

⭐ **If you find this project useful, please consider giving it a star! It helps others discover ROCm support on Windows.**

---

## Disclaimer

This fork was created and verified by a **non-engineer using AI assistance**.  
- There is **no warranty or official technical support**.

---

## Acknowledgements & Prior Works

- **Upstream Project:** [Aratako/Irodori-TTS](https://github.com/Aratako/Irodori-TTS) by Aratako - Sincere gratitude for creating this state-of-the-art Japanese TTS model.
- **Upstream PR #25:** [PR #25](https://github.com/Aratako/Irodori-TTS/pull/25) by tink - Invaluable inspiration for the `_compat.py` stub pattern and `sentencepiece` compatibility.
- **Windows ROCm Technical Articles:** Articles by [LP (note.com)](https://note.com/lpp) providing foundational insights into AMD TheRock wheels on Windows.
- **AMD ROCm / TheRock:** AMD's official preview wheels enabling zero-build Windows acceleration.
- **Astral uv:** Ultra-fast Python package and project manager.
