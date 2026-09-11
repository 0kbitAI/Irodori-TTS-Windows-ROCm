@echo off
setlocal
title Irodori-TTS WebUI (Windows ROCm)

echo =======================================================
echo Starting Irodori-TTS WebUI...
echo =======================================================

:: -------------------------------------------------------
:: AMD ROCm Optimization & Multi-GPU Settings
:: -------------------------------------------------------
:: If you have a Ryzen APU (integrated GPU) and it fails to detect RX 6600 XT,
:: remove the '@REM' from the line below (try 0 or 1):
@REM set HIP_VISIBLE_DEVICES=0

:: Optimize MIOpen kernel search and suppress verbose warnings
set MIOPEN_FIND_MODE=FAST
set MIOPEN_LOG_LEVEL=3
:: -------------------------------------------------------

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