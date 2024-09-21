@echo off
rem this file expects the following args
rem   (nothing) to build all libraries
rem   xyz      to build library xyz 
rem this is not intended to compile and run a file

if "%1"=="" goto buildall

:build
echo.
echo Building %1
cd %1
md c:\bin >nul
config -set "cpu cycles=max"
tpc -q -b -ec:\bin -uc:\bin -dDEBUG build.pas
if errorlevel 1 goto fail
echo success
cd ..
goto end

:fail
echo.
echo fail
goto end

:buildall
echo.
echo Building all libraries
del /q c:\bin\*.* >nul
call build leanlib
call build common
call build lc
call build lrt
del /q c:\bin\*.exe >nul

:end