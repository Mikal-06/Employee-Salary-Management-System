@echo off
echo =========================================
echo Compiling Employee Salary Management System
echo =========================================

set FILE_NAME=Project

echo [1/3] Assembling...
ml /c /coff /Cp %FILE_NAME%.asm
if errorlevel 1 goto terminate

echo [2/3] Linking...
link /subsystem:console %FILE_NAME%.obj Irvine32.lib Kernel32.lib User32.lib
if errorlevel 1 goto terminate

echo [3/3] Build Successful! Running program...
echo.
%FILE_NAME%.exe
echo.
pause
exit

:terminate
echo.
echo [ERROR] Build Failed! Check the error messages above.
pause