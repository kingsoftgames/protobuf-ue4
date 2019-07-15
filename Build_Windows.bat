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

set CURRENT_DIR=%cd%
@REM We only need x64 (VsDevCmd.bat defaults arch to x86, pass -help to see all available options)
set PROTOBUF_ARCH=x64
@REM Tell CMake to use dynamic CRT (/MD) instead of static CRT (/MT)
set PROTOBUF_CMAKE_OPTIONS=-Dprotobuf_MSVC_STATIC_RUNTIME=OFF

@REM -----------------------------------------------------------------------
@REM Set Environment Variables for the Visual Studio 2017 Command Line
set VS2017DEVCMD=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat
if exist "%VS2017DEVCMD%" (
    @REM Tell VsDevCmd.bat to set the current directory, in case [USERPROFILE]\source exists. See:
    @REM C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\vsdevcmd\core\vsdevcmd_end.bat
     set VSCMD_START_DIR=%CD%
     call "%VS2017DEVCMD%" -arch=%PROTOBUF_ARCH%
      ) else (
     echo ERROR: Cannot find Visual Studio 2017
     exit /b 2
)

set PROTOBUF_DIR=protobuf-%PROTOBUF_UE4_VERSION%

rd %PROTOBUF_UE4_PREFIX%
mkdir %PROTOBUF_UE4_PREFIX%

cd %CURRENT_DIR%
cd %PROTOBUF_DIR%\cmake
mkdir build & cd build

echo ########## static build ##########
mkdir static
pushd static
    cmake -G "NMake Makefiles" ^
        -DCMAKE_BUILD_TYPE=Release ^
        -DCMAKE_INSTALL_PREFIX="%PROTOBUF_UE4_PREFIX%/static" ^
        %PROTOBUF_CMAKE_OPTIONS% ../..
    nmake
    nmake check
    nmake install
popd

mkdir %PROTOBUF_UE4_PREFIX%\windows\bin
mkdir %PROTOBUF_UE4_PREFIX%\windows\lib

move %PROTOBUF_UE4_PREFIX%\static\lib\libprotobuf.lib %PROTOBUF_UE4_PREFIX%\windows\lib\libprotobuf.lib
move %PROTOBUF_UE4_PREFIX%\static\bin\protoc.exe %PROTOBUF_UE4_PREFIX%\windows\bin\protoc.exe
move %PROTOBUF_UE4_PREFIX%\static\include %PROTOBUF_UE4_PREFIX%\windows\include

rd /S /Q %PROTOBUF_UE4_PREFIX%\static


