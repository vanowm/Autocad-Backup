@echo off

pushd %~dp0
set header=Windows Registry Editor Version 5.00
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set mydate=%%j
set mydate=%mydate:~0,4%%mydate:~4,2%%mydate:~6,2%_%mydate:~8,2%%mydate:~10,2%%mydate:~12,2%
set file="inventor2023_settings_%mydate%"


set fileFinal="%file%.reg"
echo %header%>%fileFinal%
echo.>>%fileFinal%

call:re "HKEY_LOCAL_MACHINE\SOFTWARE\Autodesk\Inventor" LM
call:re "HKEY_LOCAL_MACHINE\SOFTWARE\Autodesk\Inventor Interoperability" LMII
call:re "HKEY_CURRENT_USER\SOFTWARE\Autodesk\Inventor Interoperability" CUII
call:re "HKEY_CURRENT_USER\SOFTWARE\Autodesk\Inventor" CU
popd
goto:eof

:re
set key=%~1
set name=%~2
@REM echo %key%
set tempFile="%file%_%name%"
reg export "%key%" %tempFile% /y

echo.>>%fileFinal%
echo.>>%fileFinal%
echo.>>%fileFinal%
echo ;-------[ %name% ]------->>%fileFinal%
echo.>>%fileFinal%
echo.>>%fileFinal%
echo.>>%fileFinal%

type %tempFile% | find /v "%header%" >>%fileFinal%

del %tempFile%

goto:eof


