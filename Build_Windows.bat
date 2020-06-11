@echo off

@REM 
@REM Please make sure the following environment variables are set before calling this script:
@REM PROTOBUF_UE4_VERSION - Release version string.
@REM PROTOBUF_UE4_PREFIX  - Absolute install path prefix string.
@REM 

@if "%PROTOBUF_UE4_VERSION%"=="" (
    echo PROTOBUF_UE4_VERSION is not set, exit.
    exit /b 1
)

@if "%PROTOBUF_UE4_PREFIX%"=="" (
    echo PROTOBUF_UE4_PREFIX is not set, exit.
    exit /b 1
)

@if "%COMPILER%"=="" (
    echo COMPILER_VERSION is not set, exit.
    exit /b 1
)

set CURRENT_DIR=%cd%
@REM We only need x64 (VsDevCmd.bat defaults arch to x86, pass -help to see all available options)
set PROTOBUF_ARCH=x64
@REM Tell CMake to use dynamic CRT (/MD) instead of static CRT (/MT)
set PROTOBUF_CMAKE_OPTIONS=-Dprotobuf_MSVC_STATIC_RUNTIME=OFF

@REM -----------------------------------------------------------------------
@REM Set Environment Variables for the Visual Studio %COMPILER% Command Line
set VSDEVCMD=C:\Program Files (x86)\Microsoft Visual Studio\%COMPILER%\Community\Common7\Tools\VsDevCmd.bat
if exist "%VSDEVCMD%" (
    @REM Tell VsDevCmd.bat to set the current directory, in case [USERPROFILE]\source exists. See:
    @REM C:\Program Files (x86)\Microsoft Visual Studio\%COMPILER%\Community\Common7\Tools\vsdevcmd\core\vsdevcmd_end.bat
     set VSCMD_START_DIR=%CD%
     call "%VSDEVCMD%" -arch=%PROTOBUF_ARCH%
      ) else (
     echo ERROR: Cannot find Visual Studio %COMPILER%
     exit /b 2
)

set PROTOBUF_URL=https://github.com/google/protobuf/releases/download/v%PROTOBUF_UE4_VERSION%/protobuf-cpp-%PROTOBUF_UE4_VERSION%.zip
set PROTOBUF_DIR=protobuf-%PROTOBUF_UE4_VERSION%
set PROTOBUF_ZIP=protobuf-%PROTOBUF_UE4_VERSION%.zip

echo "Downloading: %PROTOBUF_URL%"
REM Force Invoke-WebRequest to use TLS 1.2
powershell -Command [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ^
    Invoke-WebRequest -Uri %PROTOBUF_URL% -OutFile %PROTOBUF_ZIP%

powershell -Command Expand-Archive -Path %PROTOBUF_ZIP% -DestinationPath .

set FIX_FILE=%cd%\Fix-%PROTOBUF_UE4_VERSION%.bat
if exist "%FIX_FILE%" (
    call %FIX_FILE%
) else (
    echo protobuf-%PROTOBUF_UE4_VERSION% has not been modified
)

mkdir "%PROTOBUF_UE4_PREFIX%"

cd "%CURRENT_DIR%"

pushd %PROTOBUF_DIR%\cmake
    cmake -G "NMake Makefiles" ^
        -DCMAKE_BUILD_TYPE=Release ^
        -DCMAKE_INSTALL_PREFIX="%PROTOBUF_UE4_PREFIX%" ^
        %PROTOBUF_CMAKE_OPTIONS% .
    nmake
    nmake check
    nmake install
popd
