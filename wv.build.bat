
@echo off
setlocal enabledelayedexpansion

set VCPKG_ROOT=c:\vcpkg
set VCPKG_DEFAULT_TRIPLET=x64-windows-static

echo ================================
echo RustDesk Windows Build Script
echo ================================


if exist vcpkg.json (
ren vcpkg.json vcpkg.json.bak
)


vcpkg install opus:x64-windows-static libvpx:x64-windows-static libyuv:x64-windows-static aom:x64-windows-static ffmpeg:x64-windows-static

rem ffmpeg:x64-windows-static
rem vcpkg install --triplet x64-windows-static


:: --- Џа®ўҐаЄ  Rust ---
:: where cargo >nul 2>nul
:: if %errorlevel% neq 0 (
:: echo [ERROR] Rust not installed!
:: pause
:: exit /b
:: )


:: --- Џа®ўҐаЄ  Flutter ---
:: where flutter >nul 2>nul
:: if %errorlevel% neq 0 (
:: echo [ERROR] Flutter not installed!
:: pause
:: exit /b
:: )


:: --- “бв ­ ў«Ёў Ґ¬ ЇҐаҐ¬Ґ­­лҐ ¤«п VS ---
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
rem call "C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools\VC\Auxiliary\Build\vcvars64.bat"

set VCPKG_ROOT=C:\vcpkg
set VCPKG_DEFAULT_TRIPLET=x64-windows-static


:: --- Џа®ўҐаЄ  Visual Studio tools ---
where cl >nul 2>nul
if %errorlevel% neq 0 (
echo [ERROR] MSVC Install Visual Studio C++
pause
exit /b
)

echo [OK] ‚бҐ § ўЁбЁ¬®бвЁ ­ ©¤Ґ­л


:: --- Љ®ЇЁагҐ¬ flutter engine ---
call xcopy c:\wowvendor\windows-x64-release\* c:\flutter\bin\cache\artifacts\engine\windows-x64-release /E /I /Y


:: --- Џ взЁ¬ ­ бва®©ЄЁ бҐаўҐа  Ё TLS ---
:: rem call git apply fix_wowvendor.patch


:: --- ‘®ЎЁа Ґ¬ ЎаЁ¤¦ rustdesk-flutter ---
cd flutter

call flutter config --no-enable-android
:: --- ‚Є«оз Ґ¬ Windows desktop ---
call flutter config --enable-windows-desktop
call flutter doctor -v
call flutter precache --windows

call flutter clean
call flutter pub get

call cargo install flutter_rust_bridge_codegen --version 1.80.1 --features uuid

call flutter_rust_bridge_codegen --rust-input ..\src\flutter_ffi.rs --llvm-path "C:\Program Files\LLVM" --dart-output lib\generated_bridge.dart

cd ..

:: --- ‘Ў®аЄ  Rust ---
echo.
echo === Building Rust backend ===

cargo clean
python3 .\build.py --flutter

if %errorlevel% neq 0 (echo [ERROR] Rust build failed && pause && exit /b)


set OUT_DIR=Release
if exist %OUT_DIR% rmdir /s /q %OUT_DIR%
mkdir %OUT_DIR%

:: Љ®ЇЁагҐ¬ Flutter ЎЁ«¤
xcopy flutter\build\windows\x64\runner\Release %OUT_DIR% /E /I /Y

:: Љ®ЇЁагҐ¬ Rust ЎЁ­ а­ЁЄЁ
rem copy target\release\rustdesk.exe %OUT_DIR%
rem copy target\release\rustdesk_host.exe %OUT_DIR%

echo.
echo ================================
echo BUILD SUCCESS
echo Output: %OUT_DIR%
echo ================================

pause

