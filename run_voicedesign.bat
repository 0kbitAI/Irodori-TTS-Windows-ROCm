@echo off
setlocal
title Irodori-TTS Voice Design (Windows ROCm)

echo =======================================================
echo Starting Irodori-TTS Voice Design...
echo =======================================================

uv run --no-sync python gradio_app_voicedesign.py
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo =======================================================
    echo [ERROR] Failed to start Irodori-TTS Voice Design.
    echo.
    echo If you haven't set up the environment yet, please run:
    echo   uv sync --extra rocm-win        (For RX 6000 Series)
    echo   uv sync --extra rocm-win-rdna3  (For RX 7000 Series)
    echo =======================================================
    echo.
)

pause