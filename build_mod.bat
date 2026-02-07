@echo off
call "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" -arch=amd64

cd /d "%~dp0"

set GEODE_SDK=C:\Users\steven\Documents\geode\geode-sdk

cmake -B build -G Ninja ^
    -DCMAKE_MAKE_PROGRAM="C:/Users/steven/AppData/Local/Microsoft/WinGet/Packages/Ninja-build.Ninja_Microsoft.Winget.Source_8wekyb3d8bbwe/ninja.exe" ^
    -DCMAKE_C_COMPILER="C:/Program Files/LLVM/bin/clang-cl.exe" ^
    -DCMAKE_CXX_COMPILER="C:/Program Files/LLVM/bin/clang-cl.exe" ^
    -DCMAKE_BUILD_TYPE=RelWithDebInfo

if %errorlevel% neq 0 (
    echo CMake configuration failed
    exit /b 1
)

cd /d "%~dp0build"
cmake --build . --config RelWithDebInfo --parallel

if %errorlevel% neq 0 (
    echo Build failed
    exit /b 1
)

echo Build completed successfully!
