@echo off
setlocal enabledelayedexpansion

:: Verifica si estamos en un repositorio Git
git rev-parse --is-inside-work-tree >nul 2>&1
if %errorlevel% neq 0 (
    echo No se encuentra un repositorio Git en esta carpeta.
    pause
    exit /b
)

:: Obtiene la última versión del tag
set "last_tag="
for /f "delims=" %%a in ('git describe --tags --abbrev^=0 2^>nul') do set "last_tag=%%a"
if "!last_tag!"=="" (
    set "last_tag=v1.0"
    echo No se encontraron tags existentes. Comenzando con !last_tag!
) else (
    echo Último tag encontrado: !last_tag!
)

:: Extrae el número de versión y lo incrementa
if "!last_tag!"=="v1.0" (
    set "new_tag=v1.1"
) else (
    for /f "tokens=1,2 delims=." %%a in ("!last_tag!") do (
        set "prefix=%%a"
        set "major=%%b"
    )
    for /f "tokens=3 delims=." %%c in ("!last_tag!") do (
        set /a "minor=%%c+1"
    )
    set "new_tag=!prefix!.!major!.!minor!"
)

echo Nuevo tag: !new_tag!

:: Actualiza el repositorio
git pull origin main

:: Añade todos los cambios
git add .

:: Pide mensaje de commit
set /p "commit_msg=Introduce el mensaje del commit: "

:: Hace commit
git commit -m "!commit_msg!"

:: Crea el tag
git tag !new_tag!

:: Sube los cambios y tags
git push origin main
git push origin !new_tag!

echo Operación completada. Versión !new_tag! subida.
pause