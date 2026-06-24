@echo off
setlocal EnableExtensions

set "ROOT=%~dp0"
set "SLN=%ROOT%TestTupConsole.sln"
set "CONFIG=Release"
set "PLATFORM=x86"

if not defined MSBUILD (
    set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
    if exist "%VSWHERE%" (
        for /f "usebackq delims=" %%i in (`"%VSWHERE%" -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do (
            set "MSBUILD=%%i"
            goto :msbuild_found
        )
    )
    for %%i in (
        "%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
        "%ProgramFiles%\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
        "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
        "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
        "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe"
        "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
    ) do (
        if exist %%i (
            set "MSBUILD=%%~i"
            goto :msbuild_found
        )
    )
    echo ERROR: MSBuild not found. Install Visual Studio or set MSBUILD environment variable.
    exit /b 1
)
:msbuild_found

if "%~1"=="" goto :build
if /i "%~1"=="help" goto :help
if /i "%~1"=="debug" (
    set "CONFIG=Debug"
    goto :build
)
if /i "%~1"=="release" goto :build
if /i "%~1"=="clean" goto :clean
if /i "%~1"=="rebuild" goto :rebuild
if /i "%~1"=="run" goto :run

echo Unknown target: %~1
goto :help

:build
echo Building %CONFIG%^|%PLATFORM% ...
"%MSBUILD%" "%SLN%" /t:Build /p:Configuration=%CONFIG% /p:Platform=%PLATFORM% /m /v:minimal
if errorlevel 1 exit /b 1
echo.
echo Output: %ROOT%bin\%CONFIG%\
exit /b 0

:clean
echo Cleaning ...
"%MSBUILD%" "%SLN%" /t:Clean /p:Configuration=Debug /p:Platform=%PLATFORM% /v:minimal
if errorlevel 1 exit /b 1
"%MSBUILD%" "%SLN%" /t:Clean /p:Configuration=Release /p:Platform=%PLATFORM% /v:minimal
if errorlevel 1 exit /b 1
exit /b 0

:rebuild
call "%~f0" clean
if errorlevel 1 exit /b 1
call "%~f0" %CONFIG%
exit /b %ERRORLEVEL%

:run
call "%~f0" debug
if errorlevel 1 exit /b 1
echo.
echo Running test console ...
"%ROOT%bin\Debug\ConsoleApplication1.exe"
exit /b %ERRORLEVEL%

:help
echo Usage: make [target]
echo.
echo Targets:
echo   (default)  Build Release^|x86
echo   debug      Build Debug^|x86
echo   release    Build Release^|x86
echo   clean      Clean Debug and Release outputs
echo   rebuild    Clean then build current configuration
echo   run        Build Debug and run test console
echo   help       Show this help
exit /b 0
