@echo off
REM Compila el POS de DS8 (8 perros, Ganador + Exacta) y lo deja en dist\
REM listo para que POS8Dogs.iss arme el instalador.
REM Correr desde la carpeta installer\.

setlocal
cd /d "%~dp0\.."

echo === Compilando POS DS8 ===
call flutter build windows --release
if errorlevel 1 goto :error
if exist installer\dist rmdir /s /q installer\dist
mkdir installer\dist
xcopy /e /i /y build\windows\x64\runner\Release installer\dist

echo.
echo Listo. Ahora compila installer\POS8Dogs.iss con Inno Setup (ISCC.exe).
goto :eof

:error
echo.
echo Fallo la compilacion de Flutter. Revisa el error arriba.
exit /b 1
