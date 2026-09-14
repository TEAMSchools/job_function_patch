@echo off
REM Runs the job function check and posts the result to Slack.
REM Safe to point Windows Task Scheduler at this file.
REM
REM Arguments are passed through, so this works too:
REM     run_check.bat --test-slack
REM
REM Do NOT use --dry-run here. It prints staff names and employee numbers,
REM which would then sit in the log file in plain text.

setlocal

REM Run from the repo folder so .env and function_check.sql resolve no matter
REM what working directory the caller (or Task Scheduler) started us in.
cd /d "%~dp0"

REM Task Scheduler often runs with a thinner PATH than your shell. If it can't
REM find Python, set the full path here instead: C:\Python314\python.exe
if not defined PYTHON set "PYTHON=python"

if not exist "logs" mkdir "logs"
set "LOGFILE=logs\job_function_check.log"
set "RUNLOG=logs\last_run.txt"

echo [%DATE% %TIME%] starting >> "%LOGFILE%"

"%PYTHON%" job_function_check.py %* > "%RUNLOG%" 2>&1
set "EXITCODE=%ERRORLEVEL%"

REM Show this run's output on screen (for a double-click) and keep it in the
REM rolling log (for a scheduled run nobody is watching).
type "%RUNLOG%"
type "%RUNLOG%" >> "%LOGFILE%"
del "%RUNLOG%"

echo [%DATE% %TIME%] finished with exit code %EXITCODE% >> "%LOGFILE%"

if not "%EXITCODE%"=="0" echo.& echo FAILED with exit code %EXITCODE%. See %LOGFILE%.

REM Hand the code to Task Scheduler so a failure shows up as a failure.
exit /b %EXITCODE%
