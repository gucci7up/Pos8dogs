@echo off
REM Compila las dos variantes del POS (Trifecta completo y solo Exacta) y las
REM deja listas en dist\trifecta y dist\exacta para que POS6Dogs.iss arme el
REM instalador con ambas opciones. Correr desde la carpeta installer\.

setlocal
cd /d "%~dp0\.."

echo === Compilando variante TRIFECTA ===
call flutter build windows --release
if errorlevel 1 goto :error
if exist installer\dist\trifecta rmdir /s /q installer\dist\trifecta
mkdir installer\dist\trifecta
xcopy /e /i /y build\windows\x64\runner\Release installer\dist\trifecta

echo === Compilando variante EXACTA ===
call flutter build windows --release --dart-define=BET_MODE=exacta
if errorlevel 1 goto :error
if exist installer\dist\exacta rmdir /s /q installer\dist\exacta
mkdir installer\dist\exacta
xcopy /e /i /y build\windows\x64\runner\Release installer\dist\exacta

echo.
echo Listo. Ahora compila installer\POS6Dogs.iss con Inno Setup (ISCC.exe).
goto :eof

:error
echo.
echo Fallo la compilacion de Flutter. Revisa el error arriba.
exit /b 1
