@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Determine the drive letter of the USB drive
SET USBDrive=%~d0

:: Set directories on the USB drive
SET ForensicFolder=%USBDrive%\ForensicData
SET SystemInfoFile=%ForensicFolder%\SystemInfo.txt
SET PictureFolder=%ForensicFolder%\Pictures
SET BrowserDataFolder=%ForensicFolder%\BrowserData
SET DNSCacheFile=%ForensicFolder%\DNSCache.txt
SET VMInfo=%ForensicFolder%\VMInfo.txt
SET EncryptionProcesses=%ForensicFolder%\EncryptionProcesses.txt
SET ARPTable=%ForensicFolder%\ARPTable.txt
SET IPConfigAll=%ForensicFolder%\IPConfigAll.txt
SET MemoryDump=%ForensicFolder%\MemoryDump
SET ProcessList=%ForensicFolder%\ProcessList.txt
SET NetworkConnections=%ForensicFolder%\NetworkConnections.txt
SET BitLockerInfo=%ForensicFolder%\BitLockerInfo.txt
SET ActiveNetworkSessions=%ForensicFolder%\ActiveNetworkSessions.txt

:: Turn off the screensaver
REG ADD "HKEY_CURRENT_USER\Control Panel\Desktop" /v ScreenSaveActive /t REG_SZ /d 0 /f

:: Prevent the computer from entering sleep mode
powercfg -change -standby-timeout-ac 0
powercfg -change -standby-timeout-dc 0
powercfg -change -monitor-timeout-ac 0
powercfg -change -monitor-timeout-dc 0

:: Check and Create Folders
IF NOT EXIST "%ForensicFolder%" MKDIR "%ForensicFolder%"
IF NOT EXIST "%PictureFolder%" MKDIR "%PictureFolder%"
IF NOT EXIST "%BrowserDataFolder%" MKDIR "%BrowserDataFolder%"
IF NOT EXIST "%MemoryDump%" MKDIR "%MemoryDump%"

:: Check for BitLocker Encryption and Retrieve Recovery Key for each drive
ECHO Retrieving BitLocker Status and Recovery Keys > "%BitLockerInfo%"
FOR %%D IN (C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO (
    manage-bde -status %%D: >> "%BitLockerInfo%"
    manage-bde -protectors -get %%D: >> "%BitLockerInfo%"
)

:: Copy Browser Data using Robocopy
ECHO Copying Browser Data...
:: Google Chrome
IF EXIST "%LOCALAPPDATA%\Google\Chrome\User Data\" (
    robocopy "%LOCALAPPDATA%\Google\Chrome\User Data" "%BrowserDataFolder%\Chrome" /E /COPYALL /R:3 /W:2
)
:: Mozilla Firefox
IF EXIST "%APPDATA%\Mozilla\Firefox\Profiles\" (
    robocopy "%APPDATA%\Mozilla\Firefox\Profiles" "%BrowserDataFolder%\Firefox" /E /COPYALL /R:3 /W:2
)
:: Microsoft Edge
IF EXIST "%LOCALAPPDATA%\Microsoft\Edge\User Data\" (
    robocopy "%LOCALAPPDATA%\Microsoft\Edge\User Data" "%BrowserDataFolder%\Edge" /E /COPYALL /R:3 /W:2
)

:: Collect DNS Cache Information
ECHO Collecting DNS Cache Information...
ipconfig /displaydns > "%DNSCacheFile%"

:: Collect Information about Running Processes
ECHO Collecting Running Processes...
tasklist > "%ProcessList%"

:: Collect Information about Active Network Connections
ECHO Collecting Active Network Connections...
netstat -ano > "%NetworkConnections%"

:: Check for Running Virtual Machines
ECHO Checking for Running Virtual Machines...
tasklist | findstr "vmware-vmx.exe VirtualBoxVM.exe vmwp.exe" > "%VMInfo%"

:: Check for Running Encryption Processes
ECHO Checking for Running Encryption Processes...
tasklist | findstr "VeraCrypt.exe TrueCrypt.exe BitLocker.exe" > "%EncryptionProcesses%"

:: Collect ARP Table
ECHO Collecting ARP Table...
arp -a > "%ARPTable%"

:: Collect IP Configuration
ECHO Collecting IP Configuration...
ipconfig /all > "%IPConfigAll%"

:: Collect System Information (Hostname, User, OS Details)
ECHO Collecting System Information...
ECHO Hostname: > "%SystemInfoFile%"
hostname >> "%SystemInfoFile%"
ECHO. >> "%SystemInfoFile%"
ECHO Current User: >> "%SystemInfoFile%"
echo %USERNAME% >> "%SystemInfoFile%"
ECHO. >> "%SystemInfoFile%"
ECHO Operating System Details: >> "%SystemInfoFile%"
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" >> "%SystemInfoFile%"
ECHO. >> "%SystemInfoFile%"

:: Collect Active Network Sessions
ECHO Collecting Active Network Sessions...
net session > "%ActiveNetworkSessions%"

ECHO Forensic data collection complete.
ENDLOCAL
