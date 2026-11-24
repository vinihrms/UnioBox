@echo off
setlocal enabledelayedexpansion

REM ============================================================================
REM Junta as partes da imagem da TV Box BTV B13 (.img.gz.part*) no Windows
REM Uso: coloque este script na mesma pasta dos arquivos .part* e clique 2x.
REM ============================================================================

set "FIRST_PART="
for /f "delims=" %%F in ('dir /b /on *.img.gz.part* 2^>nul') do (
    if not defined FIRST_PART set "FIRST_PART=%%F"
)

if not defined FIRST_PART (
    echo Erro: nenhum arquivo "*.img.gz.part*" encontrado nesta pasta.
    echo Coloque todas as partes baixadas da Release na mesma pasta e tente novamente.
    pause
    exit /b 1
)

for /f "delims=" %%F in ("%FIRST_PART%") do set "OUTPUT_FILE=%%~nF"

echo Partes encontradas:
dir /b /on *.img.gz.part*
echo.
echo Recombinando em "%OUTPUT_FILE%" ...

copy /b "%OUTPUT_FILE%.part*" "%OUTPUT_FILE%" >nul
if errorlevel 1 (
    echo Erro ao recombinar as partes.
    pause
    exit /b 1
)

echo Arquivo gerado com sucesso: "%OUTPUT_FILE%"
echo.

echo Calculando SHA-256 do arquivo final:
certutil -hashfile "%OUTPUT_FILE%" SHA256
if exist "SHA256SUMS.txt" (
    echo.
    echo Hash esperado em SHA256SUMS.txt:
    findstr /C:"%OUTPUT_FILE%" SHA256SUMS.txt
)

echo.
echo Pronto! Agora grave "%OUTPUT_FILE%" no cartao microSD usando BalenaEtcher ou Raspberry Pi Imager.
pause
