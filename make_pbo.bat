@echo off
setlocal enabledelayedexpansion
title Recovery Team - PBO Build & Sign Script

:: ─────────────────────────────
:: Paths (edit if needed)
:: ─────────────────────────────
set ADDON_BUILDER="C:\Program Files (x86)\Steam\steamapps\common\Arma 3 Tools\AddonBuilder\AddonBuilder.exe"
set DSSIGN="C:\Program Files (x86)\Steam\steamapps\common\Arma 3 Tools\DSSignFile\DSSignFile.exe"
set DSCREATE="C:\Program Files (x86)\Steam\steamapps\common\Arma 3 Tools\DSSignFile\DSCreateKey.exe"

:: Mod folders
set ROOT=%~dp0
set SRC_DIR=%ROOT%@RecoveryTeam\addons\rt_core
set DEST_DIR=%ROOT%@RecoveryTeam\addons
set KEYS_DIR=%ROOT%keys
set MOD_KEYS_DIR=%ROOT%@RecoveryTeam\keys

:: Key name (files: keys\RecoveryTeam.biprivatekey / .bikey)
set KEY_NAME=RecoveryTeam

echo.
echo ╔═════════════════════════════════════════════════════╗
echo ║   Building and Signing RecoveryTeam addon (rt_core)  ║
echo ╚═════════════════════════════════════════════════════╝
echo.

if not exist %ADDON_BUILDER% ( echo [ERROR] Addon Builder not found: %ADDON_BUILDER% & goto :end )
if not exist %DSSIGN% ( echo [ERROR] DSSignFile not found: %DSSIGN% & goto :end )
if not exist %DSCREATE% ( echo [WARN] DSCreateKey not found: %DSCREATE% )

if not exist "%SRC_DIR%" ( echo [ERROR] Source folder not found: %SRC_DIR% & goto :end )

if not exist "%DEST_DIR%" mkdir "%DEST_DIR%"
if not exist "%KEYS_DIR%" mkdir "%KEYS_DIR%"
if not exist "%MOD_KEYS_DIR%" mkdir "%MOD_KEYS_DIR%"

echo Running AddonBuilder...
%ADDON_BUILDER% "%SRC_DIR%" "%DEST_DIR%" -prefix=rt_core -include=*.sqf;*.cpp;*.hpp -binarize -clear -temp="%TEMP%\ArmaBuildTemp"
if not %ERRORLEVEL%==0 ( echo [ERROR] Build failed. & goto :end )

set PBO=%DEST_DIR%\rt_core.pbo
if not exist "%PBO%" ( echo [ERROR] PBO not found at %PBO% & goto :end )

set BIPRIVATE=%KEYS_DIR%\%KEY_NAME%.biprivatekey
set BIKEY=%KEYS_DIR%\%KEY_NAME%.bikey

if not exist "%BIPRIVATE%" (
  if exist %DSCREATE% (
    echo Creating key pair: %KEY_NAME%
    %DSCREATE% "%BIPRIVATE%" "%BIKEY%"
  ) else (
    echo [WARN] No private key found and DSCreateKey.exe missing.
    echo        Please create keys manually in %KEYS_DIR% and rerun.
    goto :end
  )
)

echo Signing PBO with %BIPRIVATE% ...
%DSSIGN% "%BIPRIVATE%" "%PBO%"
if not %ERRORLEVEL%==0 ( echo [ERROR] Signing failed. & goto :end )

copy /Y "%BIKEY%" "%MOD_KEYS_DIR%\" >nul
echo Public key copied to @RecoveryTeam\keys\%KEY_NAME%.bikey

echo.
echo ✅ Build and signing completed successfully!
echo Output: %PBO%
echo Public key: @RecoveryTeam\keys\%KEY_NAME%.bikey

:end
pause
endlocal
