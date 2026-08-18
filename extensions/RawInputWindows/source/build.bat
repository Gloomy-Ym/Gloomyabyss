@echo off
setlocal
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
set "MSBUILD="

if exist "%VSWHERE%" (
    for /f "usebackq delims=" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do set "MSBUILD=%%i"
)

if not defined MSBUILD set "MSBUILD=msbuild"

"%MSBUILD%" "%~dp0RawInputWindows.sln" /p:Configuration=Release /p:Platform=x64 /m
exit /b %ERRORLEVEL%
