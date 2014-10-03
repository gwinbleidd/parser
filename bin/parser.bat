@ECHO OFF
SET TMP_PATH=%PATH%
SET PATH=D:\oracle\instantclient_11_2;%PATH%
SET NLS_LANG=AMERICAN_CIS.CL8MSWIN1251
IF NOT "%~f0" == "~f0" GOTO :WinNT
@"ruby.exe" "./parser" %1 %2 %3 %4 %5 %6 %7 %8 %9
GOTO :EOF
:WinNT
@"ruby.exe" "%~dpn0" %*
SET PATH=%TMP_PATH%