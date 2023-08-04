# @echo off
# setlocal EnableDelayedExpansion

$WD = (Get-Location)
if ( !Test-Path "$WD\msys-2.0.dll") { $WD = "$PSScriptRoot\usr\bin\" } 
Set-Variable "LOGINSHELL" "bash"
Set-Variable msys2_shiftCounter 0

# rem To activate windows native symlinks uncomment next line
# rem set MSYS=winsymlinks:nativestrict

# rem Set debugging program for errors
# rem set MSYS=error_start:${WD}../../mingw64/bin/qtcreator.exe^ | -debug^ | ^<process-id^>

# rem To export full current PATH from environment into MSYS2 use '-use-full-path' parameter
# rem or uncomment next line
# rem set MSYS2_PATH_TYPE=inherit

:checkparams
# rem Help option
if ("x%~1" -eq "x-help" ) {
    call :printhelp "%~nx0"
    exit /b ${ERRORLEVEL}
}
if ("x%~1" -eq "x--help" ) {
    call :printhelp "%~nx0"
    exit /b ${ERRORLEVEL}
}
if ("x%~1" -eq "x-?" ) {
    call :printhelp "%~nx0"
    exit /b ${ERRORLEVEL}
}
if ("x%~1" -eq "x/?") {
    call :printhelp "%~nx0"
    exit /b ${ERRORLEVEL}
}
# rem Shell types
if ("x%~1" -eq "x-msys") { shift; Set-Variable /a msys2_shiftCounter+=1; Set-Variable MSYSTEM=MSYS; goto :checkparams }
if ("x%~1" -eq "x-msys2") { shift; Set-Variable /a msys2_shiftCounter+=1; Set-Variable MSYSTEM=MSYS; goto :checkparams }
if ("x%~1" -eq "x-mingw32") { shift; Set-Variable /a msys2_shiftCounter+=1; Set-Variable MSYSTEM=MINGW32; goto :checkparams }
if ("x%~1" -eq "x-mingw64") { shift; Set-Variable /a msys2_shiftCounter+=1; Set-Variable MSYSTEM=MINGW64; goto :checkparams }
if ("x%~1" -eq "x-ucrt64") { shift; Set-Variable /a msys2_shiftCounter+=1; Set-Variable MSYSTEM=UCRT64; goto :checkparams }
if ("x%~1" -eq "x-clang64") { shift; Set-Variable /a msys2_shiftCounter+=1; Set-Variable MSYSTEM=CLANG64; goto :checkparams }
if ("x%~1" -eq "x-clang32") { shift; Set-Variable /a msys2_shiftCounter+=1; Set-Variable MSYSTEM=CLANG32; goto :checkparams }
if ("x%~1" -eq "x-clangarm64") { shift; Set-Variable /a msys2_shiftCounter+=1; Set-Variable MSYSTEM=CLANGARM64; goto :checkparams }
if ("x%~1" -eq "x-mingw") { shift; Set-Variable /a msys2_shiftCounter+=1; (if exist "${WD}..\..\mingw64" (Set-Variable MSYSTEM=MINGW64) else (Set-Variable MSYSTEM=MINGW32)); goto :checkparams }
# rem Console types
if ("x%~1" -eq "x-mintty") { shift; Set-Variable /a msys2_shiftCounter+=1; Set-Variable MSYSCON=mintty.exe; goto :checkparams }
if ("x%~1" -eq "x-conemu") { shift; Set-Variable /a msys2_shiftCounter+=1; Set-Variable MSYSCON=conemu; goto :checkparams }
if ("x%~1" -eq "x-defterm") { shift; Set-Variable /a msys2_shiftCounter+=1; Set-Variable MSYSCON=defterm; goto :checkparams }
# rem Other parameters
if ("x%~1" -eq "x-full-path") { shift; Set-Variable /a msys2_shiftCounter+=1; Set-Variable MSYS2_PATH_TYPE=inherit; goto :checkparams }
if ("x%~1" -eq "x-use-full-path") { shift; Set-Variable /a msys2_shiftCounter+=1; Set-Variable MSYS2_PATH_TYPE=inherit; goto :checkparams }
if ("x%~1" -eq "x-here") { shift; Set-Variable /a msys2_shiftCounter+=1; Set-Variable CHERE_INVOKING=enabled_from_arguments; goto :checkparams }
if ("x%~1" -eq "x-where") { 
    if ("x%~2" -eq "x") {
        Write-Output Working directory is not specified for -where parameter. #1>;2
        exit /b 2
    }
    Set-Location "%~2" || {
        Write-Output Cannot set specified working diretory "%~2". #1>;2
        exit /b 2
    }
    Set-Variable CHERE_INVOKING=enabled_from_arguments

    # rem Ensure parentheses in argument do not interfere with FOR IN loop below.
    Set-Variable msys2_arg="%~2"
    call :substituteparens msys2_arg
    call :removequotes msys2_arg

    #  Increment msys2_shiftCounter by number of words in argument {as cmd.exe saw it}.
    #  {Note that this form of FOR IN loop uses same delimiters as parameters.}
    # for %%a in {!msys2_arg!} do set /a msys2_shiftCounter+=1
}; shift; shift; Set-Variable /a msys2_shiftCounter+=1; goto :checkparams
if ("x%~1" -eq "x-no-start") { shift; Set-Variable /a msys2_shiftCounter+=1; Set-Variable MSYS2_NOSTART=yes; goto :checkparams }
if ("x%~1" -eq "x-shell") {
    if ("x%~2" -eq "x") {
        Write-Output Shell not specified for -shell parameter. #1>;2
        exit /b 2
    }
    Set-Variable LOGINSHELL="%~2"
    call :removequotes LOGINSHELL
  
    Set-Variable msys2_arg="%~2"
    call :substituteparens msys2_arg
    call :removequotes msys2_arg
    # for %%a in { !msys2_arg! } do set /a msys2_shiftCounter+=1
}; shift; shift; Set-Variable /a msys2_shiftCounter+=1; goto :checkparams

# rem Collect remaining command line arguments to be passed to shell
if (${msys2_shiftCounter} -eq 0) { Set-Variable SHELL_ARGS=%* ; goto cleanvars }
Set-Variable msys2_full_cmd=%*
# for /f "tokens=${msys2_shiftCounter},* delims=,;=	 " ${%i in {"!msys2_full_cmd!"} do set SHELL_ARGS= }%j

:cleanvars
Set-Variable msys2_arg=
Set-Variable msys2_shiftCounter=
Set-Variable msys2_full_cmd=

# rem Setup proper title and icon
if ("${MSYSTEM}" -eq "MINGW32") {
    Set-Variable "CONTITLE=MinGW x32"
    Set-Variable "CONICON=mingw32.ico"
}
elseif ("${MSYSTEM}" -eq "MINGW64") {
    Set-Variable "CONTITLE=MinGW x64"
    Set-Variable "CONICON=mingw64.ico"
}
elseif ("${MSYSTEM}" -eq "UCRT64") {
    Set-Variable "CONTITLE=MinGW UCRT x64"
    Set-Variable "CONICON=ucrt64.ico"
}
elseif ("${MSYSTEM}" -eq "CLANG64") {
    Set-Variable "CONTITLE=MinGW Clang x64"
    Set-Variable "CONICON=clang64.ico"
}
elseif ("${MSYSTEM}" -eq "CLANG32") {
    Set-Variable "CONTITLE=MinGW Clang x32"
    Set-Variable "CONICON=clang32.ico"
}
elseif ("${MSYSTEM}" -eq "CLANGARM64") {
    Set-Variable "CONTITLE=MinGW Clang ARM64"
    Set-Variable "CONICON=clangarm64.ico"
}
else {
    Set-Variable "CONTITLE=MSYS2 MSYS"
    Set-Variable "CONICON=msys2.ico"
}

if ("x${MSYSCON}" -eq "xmintty.exe") { goto startmintty }
if ("x${MSYSCON}" -eq "xconemu") { goto startconemu }
if ("x${MSYSCON}" -eq "xdefterm") { goto startsh }

if (NOT EXIST "${WD}mintty.exe" ) { goto startsh }
Set-Variable MSYSCON=mintty.exe
:startmintty
if (not defined MSYS2_NOSTART) {
    Start-Process "${CONTITLE}" "${WD}mintty" -i "/${CONICON}" -t "${CONTITLE}" "/usr/bin/${LOGINSHELL}" -l !SHELL_ARGS!
}
else {
    # "${WD}mintty" -i "/${CONICON}" -t "${CONTITLE}" "/usr/bin/${LOGINSHELL}" -l !SHELL_ARGS!
}
exit /b ${ERRORLEVEL}

:startconemu
call :conemudetect || {
    Write-Output ConEmu not found. Exiting. #1>;2
    exit /b 1
}
if (not defined MSYS2_NOSTART) {
    Start-Process "${CONTITLE}" "${ComEmuCommand}" /Here /Icon "${WD}..\..\${CONICON}" /cmd "${WD}\${LOGINSHELL}" -l !SHELL_ARGS!
}
else {
    # "${ComEmuCommand}" / Here /Icon "${WD}..\..\${CONICON}" /cmd "${WD}\${LOGINSHELL}" -l !SHELL_ARGS!
}
exit /b ${ERRORLEVEL}

:startsh
Set-Variable MSYSCON=
if (not defined MSYS2_NOSTART) {
    Start-Process "${CONTITLE}" "${WD}\${LOGINSHELL}" -l !SHELL_ARGS!
}
else {
    # "${WD}\${LOGINSHELL}" -l !SHELL_ARGS!
}
exit /b ${ERRORLEVEL}

:EOF
exit /b 0

:conemudetect
Set-Variable ComEmuCommand=
if (defined ConEmuDir) {
    if (exist "${ConEmuDir}\ConEmu64.exe") {
        Set-Variable "ComEmuCommand=${ConEmuDir}\ConEmu64.exe"
        Set-Variable MSYSCON=conemu64.exe
    }
    elseif (exist "${ConEmuDir}\ConEmu.exe") {
        Set-Variable "ComEmuCommand=${ConEmuDir}\ConEmu.exe"
        Set-Variable MSYSCON=conemu.exe
    }
}
if (not defined ComEmuCommand) {
    ConEmu64.exe /Exit 2>nul ; ; {
        Set-Variable ComEmuCommand=ConEmu64.exe
        Set-Variable MSYSCON=conemu64.exe
    } || {
        ConEmu.exe /Exit 2>nul ; ; {
            Set-Variable ComEmuCommand=ConEmu.exe
            Set-Variable MSYSCON=conemu.exe
        }
    }
}
if (not defined ComEmuCommand) {
    # FOR /F "tokens=*" %%A IN { 'reg.exe QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\ConEmu64.exe" /ve 2^>nul ^| find "REG_SZ"' } DO {
    Set-Variable "ComEmuCommand=%%A"
    # }
    if (defined ComEmuCommand) {
        call set "ComEmuCommand=${%ComEmuCommand:*REG_SZ    =}%"
        Set-Variable MSYSCON=conemu64.exe
    }
    else {
        # FOR /F "tokens=*" %%A IN { 'reg.exe QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\ConEmu.exe" /ve 2^>nul ^| find "REG_SZ"' } DO {
        Set-Variable "ComEmuCommand=%%A"
        # }
        if (defined ComEmuCommand) {
            call set "ComEmuCommand=${%ComEmuCommand:*REG_SZ    =}%"
            Set-Variable MSYSCON=conemu.exe
        }
    }
}
if (not defined ComEmuCommand) { exit /b 2 }
exit /b 0

:printhelp
Write-Output Usage:
Write-Output %~1 [options] [login shell parameters]
echo.
Write-Output Options:
Write-Output -mingw32 ^ | -mingw64 ^ | -ucrt64 ^ | -clang64 ^ | -msys[2] Set shell type
Write-Output -defterm ^ | -mintty ^ | -conemu Set terminal type
Write-Output -here Use current directory as working
Write-Output directory
Write-Output -where DIRECTORY Use specified DIRECTORY as working
Write-Output directory
Write-Output -[use-]full-path Use full current PATH variable
Write-Output instead of trimming to minimal
Write-Output -no-start Do not use "start" command and
Write-Output return login shell resulting 
Write-Output errorcode as this batch file 
Write-Output resulting errorcode
Write-Output -shell SHELL Set login shell
Write-Output '-help ^ | --help ^ | - ? ^ | /? Display this help and exit'
echo.
Write-Output Any parameter that cannot be treated as valid option and all
Write-Output following parameters are passed as login shell command parameters.
echo.
exit /b 0

:removequotes
# FOR /F "delims=" ${%A IN {'echo }${%1}${'} DO set }1 = %%~A
GOTO :eof

:substituteparens
SETLOCAL
# FOR /F "delims=" ${%A IN {'echo }${%1}%'} DO {
#     Set-Variable value=%%A
#     set value=!value:^{=x!
#         set value=!value:^}=x!
# }
ENDLOCAL ; Set-Variable ${1=}value%
GOTO :eof
