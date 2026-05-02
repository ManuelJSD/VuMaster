@echo off
REM ======================================================================
REM  VuMaster - Script de empaquetado para CurseForge
REM  Genera VuMaster.zip listo para subir al portal de autores.
REM ======================================================================

setlocal

REM --- Nombre del addon y archivo de salida ---
set ADDON_NAME=VuMaster
set OUTPUT_ZIP=%~dp0%ADDON_NAME%.zip

REM --- Limpiar ZIP anterior si existe ---
if exist "%OUTPUT_ZIP%" (
    echo [*] Eliminando ZIP anterior...
    del "%OUTPUT_ZIP%"
)

REM --- Crear directorio temporal de empaquetado ---
set TEMP_DIR=%~dp0_package_temp
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%\%ADDON_NAME%"

REM --- Copiar archivos del addon ---
echo [*] Copiando archivos...

copy "%~dp0VuMaster.toc"          "%TEMP_DIR%\%ADDON_NAME%\" >nul
copy "%~dp0VuMaster-Classic.toc"  "%TEMP_DIR%\%ADDON_NAME%\" >nul
copy "%~dp0VuMaster.lua"          "%TEMP_DIR%\%ADDON_NAME%\" >nul
copy "%~dp0icon_v2.png"           "%TEMP_DIR%\%ADDON_NAME%\" >nul

REM --- Copiar carpeta de localizaciones ---
mkdir "%TEMP_DIR%\%ADDON_NAME%\Locales"
copy "%~dp0Locales\*.lua"         "%TEMP_DIR%\%ADDON_NAME%\Locales\" >nul

REM --- Comprimir con PowerShell (disponible en Windows 10+) ---
echo [*] Generando %ADDON_NAME%.zip ...
powershell -NoProfile -Command "Compress-Archive -Path '%TEMP_DIR%\%ADDON_NAME%' -DestinationPath '%OUTPUT_ZIP%' -Force"

REM --- Limpiar directorio temporal ---
rmdir /s /q "%TEMP_DIR%"

REM --- Resultado ---
if exist "%OUTPUT_ZIP%" (
    echo.
    echo [OK] Empaquetado completado: %OUTPUT_ZIP%
    echo      Listo para subir a CurseForge.
) else (
    echo.
    echo [ERROR] No se pudo crear el ZIP. Verifica que PowerShell este disponible.
)

echo.
pause
