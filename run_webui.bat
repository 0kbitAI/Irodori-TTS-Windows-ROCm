@echo off
setlocal
title Irodori-TTS WebUI (Windows ROCm)

echo =======================================================
echo Starting Irodori-TTS WebUI...
echo =======================================================

echo Checking active environment...
uv pip list | findstr "gfx103x" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [Environment] Detected: rocm-win (RDNA 2 / RX 6000 Series)
    goto :env_done
)
uv pip list | findstr "gfx110x" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [Environment] Detected: rocm-win-rdna3 (RDNA 3 / RX 7000 Series)
    goto :env_done
)
echo [Environment] Detected: CUDA or CPU mode
:env_done
echo =======================================================

uv run --no-sync python gradio_app.py
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo =======================================================
    echo [ERROR] Failed to start Irodori-TTS.
    echo.
    echo If you haven't set up the environment yet, please run:
    echo   uv sync --extra rocm-win        (For RX 6000 Series)
    echo   uv sync --extra rocm-win-rdna3  (For RX 7000 Series)
    echo =======================================================
    echo.
)

pause