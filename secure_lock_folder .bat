@echo off
setlocal enabledelayedexpansion
cls
title Dynamic Folder Locker v10.0

set "config_file=.sys_locker_config.dat"
set "locker_string=Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}"

:MAIN_MENU
cls
echo ========================================================
echo                 SECURE LOCKER SYSTEM
echo ========================================================
echo 1. Access / Lock Existing Folder
echo 2. Create a Brand New Folder
echo 3. Exit
echo.
set /p "main_cho=Select an option (1-3): "

if "%main_cho%"=="1" goto CHECK_EXISTING
if "%main_cho%"=="2" goto CREATE_NEW_FOLDER
if "%main_cho%"=="3" exit
echo Invalid choice.
pause
goto MAIN_MENU

:: ===================================================================
:: PHASE 1: CREATE NEW FOLDER
:: ===================================================================
:CREATE_NEW_FOLDER
cls
echo ========================================================
echo               CREATE NEW STORAGE FOLDER
echo ========================================================
set /p "new_folder=Enter your desired folder name: "
if "%new_folder%"=="" goto CREATE_NEW_FOLDER

set "new_folder=%new_folder: =%"

if exist "%new_folder%" (
    echo [ERROR] A folder named '%new_folder%' already exists here!
    pause
    goto MAIN_MENU
)
if exist "%locker_string%" (
    echo [ERROR] A locked folder already exists! Unlock that one first.
    pause
    goto MAIN_MENU
)

md "%new_folder%"
cls
echo ========================================================
echo               FOLDER CREATED SUCCESSFULLY
echo ========================================================
echo A new folder named '%new_folder%' has been created.
echo.
echo Move your files inside it now, then press any key to lock it.
echo.
pause

:LOCK_SETUP_PROMPT
echo.
echo Are you ready to lock '%new_folder%' and secure it now? (Y/N)
set /p "lock_now=>"
if /I "%lock_now%"=="N" goto MAIN_MENU
if /I "%lock_now%"=="Y" goto SETUP_SECURITY
echo Invalid choice.
goto LOCK_SETUP_PROMPT

:SETUP_SECURITY
cls
echo ========================================================
echo               INITIALIZE SECURITY PARAMETERS
echo ========================================================
set /p "pass1=Create a New Password: "
set /p "pass2=Confirm Password Again: "
if not "%pass1%"=="%pass2%" (
    echo msgbox "Passwords do not match!", 16, "Error" > "%temp%\msg.vbs"
    wscript "%temp%\msg.vbs" && del "%temp%\msg.vbs"
    goto SETUP_SECURITY
)
if "%pass1%"=="" goto SETUP_SECURITY

set /p "m_key=Create a Recovery Master Key: "
if "%m_key%"=="" goto SETUP_SECURITY

set "pass1=%pass1: =%"
set "m_key=%m_key: =%"

if exist "%config_file%" attrib -h -s "%config_file%"
(
echo NAME:%new_folder%
echo PASS:%pass1%
echo MAST:%m_key%
) > "%config_file%"
attrib +h +s "%config_file%"

set "folder_name=%new_folder%"
goto EXECUTE_LOCK

:: ===================================================================
:: PHASE 2: CHECK & ACCESS EXISTING LOCKER
:: ===================================================================
:CHECK_EXISTING
if not exist "%config_file%" (
    cls
    echo msgbox "No configuration detected! Create a folder first.", 48, "Alert" > "%temp%\msg.vbs"
    wscript "%temp%\msg.vbs" && del "%temp%\msg.vbs"
    goto MAIN_MENU
)

set "folder_name="
set "stored_pass="
set "master_key="
for /f "tokens=1* delims=:" %%a in ('type "%config_file%"') do (
    if "%%a"=="NAME" set "folder_name=%%b"
    if "%%a"=="PASS" set "stored_pass=%%b"
    if "%%a"=="MAST" set "master_key=%%b"
)

if defined folder_name for /f "delims=" %%a in ("!folder_name!") do set "folder_name=%%~nxa"
if defined stored_pass for /f "delims=" %%a in ("!stored_pass!") do set "stored_pass=%%~nxa"
if defined master_key for /f "delims=" %%a in ("!master_key!") do set "master_key=%%~nxa"

if exist "%folder_name%" goto CONFIRM_LOCK_EXISTING
if exist "%locker_string%" goto UNLOCK_PROMPT

cls
echo [WARNING] The folder '%folder_name%' was missing. Re-creating directory.
md "%folder_name%"
pause
goto MAIN_MENU

:CONFIRM_LOCK_EXISTING
cls
echo Your folder '%folder_name%' is currently open.
echo Do you want to lock it up now? (Y/N)
set /p "lock_cho=>"
if /I "%lock_cho%"=="Y" goto EXECUTE_LOCK
if /I "%lock_cho%"=="N" exit
goto CONFIRM_LOCK_EXISTING

:UNLOCK_PROMPT
cls
echo ========================================================
echo                 SECURE UNLOCK DETECTED
echo ========================================================
echo Locked Folder: %folder_name%
echo.
set /p "pass_input=Enter password to unlock: "

if "%pass_input%"=="" goto LOGIN_FAIL
set "pass_input=%pass_input: =%"

if "%pass_input%"=="%stored_pass%" goto EXECUTE_UNLOCK
goto LOGIN_FAIL

:: ===================================================================
:: OPERATIONS BLOCKS (With Auto-Refresh)
:: ===================================================================
:EXECUTE_LOCK
attrib -h -s "%folder_name%" 2>nul
ren "%folder_name%" "%locker_string%"
attrib +h +s "%locker_string%"

:: Force Windows File Explorer to refresh visual cache immediately
powershell -command "(New-Object -ComObject Shell.Application).Windows() | ForEach-Object { $_.Refresh() }"

cls
echo msgbox "Folder locked successfully!", 64, "Success" > "%temp%\msg.vbs"
wscript "%temp%\msg.vbs" && del "%temp%\msg.vbs"
exit

:EXECUTE_UNLOCK
attrib -h -s "%locker_string%"
ren "%locker_string%" "%folder_name%"

:: Force Windows File Explorer to refresh visual cache immediately
powershell -command "(New-Object -ComObject Shell.Application).Windows() | ForEach-Object { $_.Refresh() }"

cls
echo msgbox "Folder unlocked successfully!", 64, "Success" > "%temp%\msg.vbs"
wscript "%temp%\msg.vbs" && del "%temp%\msg.vbs"
goto MAIN_MENU

:LOGIN_FAIL
cls
echo msgbox "Access Denied: Incorrect Password!", 16, "Security System" > "%temp%\msg.vbs"
wscript "%temp%\msg.vbs" && del "%temp%\msg.vbs"
echo 1. Try Again
echo 2. Forgot Password? (Use Master Key)
set /p "fail_cho=Select an option (1-2): "
if "%fail_cho%"=="1" goto UNLOCK_PROMPT
if "%fail_cho%"=="2" goto MASTER_RECOVERY
goto MAIN_MENU

:MASTER_RECOVERY
cls
set /p "master_input=Enter your Master Key: "
if "%master_input%"=="" goto MAIN_MENU
set "master_input=%master_input: =%"

if "%master_input%"=="%master_key%" goto CHANGE_PASSWORD
echo msgbox "Invalid Master Key!", 16, "Alert" > "%temp%\msg.vbs"
wscript "%temp%\msg.vbs" && del "%temp%\msg.vbs"
goto MAIN_MENU

:CHANGE_PASSWORD
cls
set /p "new_pass=Enter NEW Password: "
set /p "new_pass_conf=Confirm NEW Password: "
if not "%new_pass%"=="%new_pass_conf%" (
    echo [ERROR] Passwords do not match.
    pause
    goto CHANGE_PASSWORD
)
set "new_pass=%new_pass: =%"
set "stored_pass=%new_pass%"

attrib -h -s "%config_file%"
(
echo NAME:%folder_name%
echo PASS:%stored_pass%
echo MAST:%master_key%
) > "%config_file%"
attrib +h +s "%config_file%"
goto UNLOCK_PROMPT