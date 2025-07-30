REM @echo off
cd
c:\scripts\
REM this script expects properly named files in the source folder defined below
REM each file should be a signle AofAs named with only an <accountnumber>agent<6dgtagt>.pdf
REM and renames them all to the proper Visiflow import filename format
REM set tax year
set taxyr=2025
echo tax year: %taxyr%
REM define source folder for files to rename (leave off trailing backslash)
set source=S:\Shared Folders\INA\AofA
set comptgt=S:\Shared Folders\INA\AofA Complete
set skiptgt=S:\Shared Folders\INA\AofA Invalid
echo source: %source%
REM renamed files will go into the following folder (include trailing backslash\)
set destination=\\vfdb\images\IMPORT\Agent\ApptofAgent - Renamed - test\
echo destination: %destination%
REM set working folder to source folder
pushd %source%
echo %ERRORLEVEL%
ren multipleagent*.pdf MULTIPLEagent*.pdf
ren newagent*.pdf NEWagent*.pdf
setlocal EnableExtensions EnableDelayedExpansion

REM this will remove spaces, but how do handle duplicate filenames?
REM for %%f in ("* *.*") do (
REM set ARG=%%~nxf
REM echo rename "%%f" !ARG: =!
REM )

REM begin a loop through file within the folder
for /F "tokens=1,2 delims=agent" %%F in ('dir /b *agent*.pdf') do (

set Filename=%%Fagent%%G
echo Filename: !Filename!
set "Acct=%%~F"
set Acct=!Acct:NEW=8888888!
set Acct=!Acct:MULTIPLE=8888888888888!
set Acct=!Acct:MULTI=8888888888888!
set Agent=%%~G
set Agent=!Agent:.pdf=!
echo Acct: !Acct!
echo Agent: !Agent!

REM if Acct contains nonnumeric characters, don't process
SET "var="&for /f "delims=0123456789" %%i in ("!Acct!") do set var=%%i
if not defined var (

call :strlen result Acct
IF !result! gtr 7 (
    echo real
    set Acct=00!Acct!
    set Acct=!Acct:~-13!
  ) else (
    echo pers
    set Acct=00000!Acct!
    set Acct=!Acct:~-7!
  )
echo Clean Acct: !Acct!

REM added this to parse out (1) etc from end of filename so it becomes Ext instead of part of Agent
for /F "tokens=1,2 delims=()" %%I in ("!Agent!") do (
set Agent=%%~I
set Ext=%%~J
)

REM if agent contains nonnumeric characters, don't process
SET "var="&for /f "delims=0123456789" %%i in ("!Agent!") do set var=%%i
if not defined var (

set Agent=00000!Agent!
set Agent=!Agent:~-6!
echo Clean Agent: !Agent!
echo Ext: !Ext!
IF not [!Ext!] == [] set Ext=^(!Ext!^)
echo Ext: !Ext!

REM move file to destination with proper filename format for import
copy "!Filename!" "%destination%!Acct!%taxyr%af351agent#!Agent!!Ext!.pdf"
copy "!Filename!" "%comptgt%"
del "!Filename!"
REM 3 commands above should be copy/copy/del

REM end if not defined var (only do when agent is entirely numeric)
) else (echo agent contains non-numeric)
REM end if not defined var (only do when acct is entirely numeric)
) else (echo acct contains non-numeric)
REM end loop through files
  )

echo move complete, invalids now


REM loop back through all files remaining and move to invalid folder
for /F "delims=" %%F in ('dir /b *.*') do (
copy "%%~F" "%skiptgt%"
del "%%~F"
REM 2 commands above should be copy/del
)

endlocal

goto :eof

REM ********* function *****************************
:strlen <resultVar> <stringVar>
(   
    setlocal EnableDelayedExpansion
    (set^ tmp=!%~2!)
    if defined tmp (
        set "len=1"
        for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
            if "!tmp:~%%P,1!" NEQ "" ( 
                set /a "len+=%%P"
                set "tmp=!tmp:~%%P!"
            )
        )
    ) ELSE (
        set len=0
    )
)
( 
    endlocal
    set "%~1=%len%"
)
cmd /k