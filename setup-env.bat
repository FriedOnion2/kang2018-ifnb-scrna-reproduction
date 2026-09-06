@echo off
REM setup-env.bat — create the conda environment on Windows (double-click or `setup-env.bat`)
REM Prereq: Miniforge/conda already installed.
setlocal

set "MF=%USERPROFILE%\miniforge3"
if not exist "%MF%\Scripts\conda.exe" (
    echo [ERROR] conda not found at %MF%\Scripts\conda.exe
    echo         Install Miniforge first: https://github.com/conda-forge/miniforge
    exit /b 1
)

call "%MF%\Scripts\activate.bat" base

REM Remove any broken previous env, then recreate
call conda env remove -n repro-kang -y 2>NUL
call conda env create -f envs\environment.yml -y
if errorlevel 1 (
    echo [ERROR] env creation failed
    exit /b 1
)

echo.
echo Environment 'repro-kang' created. Activate with:
echo     conda activate repro-kang
endlocal