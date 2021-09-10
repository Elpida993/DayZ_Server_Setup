@echo off
TITLE DayZ SA Server - Status
COLOR 0A
    :: DEFINE the following variables where applicable to your install
    SET SteamLogin=anonymous
    SET DayZBranch=223350
    SET DayZServerPath="C:\Program Files (x86)\Steam\steamapps\common\DayZServer"
    SET SteamCMDPath="C:\Program Files (x86)\Steam\steamapps\common\DayZServer\SteamCMD"
    SET BECPath="C:\Program Files (x86)\Steam\steamapps\common\DayZServer\BEC\"
    :: DayZ Mod Parameters
    set DayZModList=("C:\Program Files (x86)\Steam\steamapps\common\DayZServer\Modlist.txt")
    set SteamCMDWorkshopPath="C:\Program Files (x86)\Steam\steamapps\workshop\content\221100"
    set SteamCMDDelay=5
    setlocal EnableDelayedExpansion
    :: _______________________________________________________________
 
goto checkServer
pause

:checkServer
tasklist /fi "imagename eq DayZServer_x64.exe" 2>NUL | find /i /n "DayZServer_x64.exe">NUL
if "%ERRORLEVEL%"=="0" goto checkBEC
echo Server is not running, taking care of it..
goto killServer

:checkBEC
tasklist /fi "imagename eq BEC.exe" 2>NUL | find /i /n "BEC.exe">NUL
if "%ERRORLEVEL%"=="0" goto loopServer

echo Bec is not running, taking care of it..
goto startBEC

:loopServer
FOR /L %%s IN (30,-1,0) DO (
	echo Server is running. Checking again in %%s seconds.. 
	timeout 1 >nul
)
goto checkServer

:killServer
taskkill /f /im Bec.exe
taskkill /f /im DayZServer_x64.exe
taskkill /f /im DZSALModServer.exe
goto updateServer

:updateServer

echo Updating DayZ SA Server.
timeout 1 >nul

echo Updating DayZ SA Server..
timeout 1 >nul

echo Updating DayZ SA Server...
cd "%SteamCMDPath%"
steamcmd.exe +login %SteamLogin% +force_install_dir %DayZServerPath% +"app_update %DayZBranch%" +quit
goto updateMods

:startServer

echo Starting DayZ SA Server.
timeout 1 >nul

echo Starting DayZ SA Server..
timeout 1 >nul

echo Starting DayZ SA Server...
cd "%DayZServerPath%"
start DZSALModServer.exe -instanceId=1 -config=serverDZ.cfg -profiles=ServerProfiles -port=2302 -mod="@CF;@UnlimitedStamina;@DrugsPLUS;@HelicoptersForAll;@CannabisPlus;@VanillaPlusPlusMap;@VPPAdminTools;@Trader;@ZTVendingMachine;@Ear-Plugs;@CodeLock;@BaseBuildingPlus;@Banking;@DabsFramework;@BuilderItems;@MasssManyItemOverhaul;@DayZEditorLoader;"% -cpuCount=10 -noFilePatching -dologs -adminlog -freezecheck
FOR /l %%s IN (45,-1,0) DO (
	echo Initializing server, wait %%s seconds to initialize BEC.. 
	timeout 1 >nul
)
goto startBEC

:startBEC

echo Starting BEC.
timeout 1 >nul

echo Starting BEC..
timeout 1 >nul

echo Starting BEC...
timeout 1 >nul
cd "%BECPath%"
start Bec.exe -f Config.cfg --dsc
goto checkServer

:updateMods

FOR /L %%s IN (%SteamCMDDelay%,-1,0) DO (
	echo Checking for mod updates in %%s seconds.. 
	timeout 1 >nul
)
echo Updating Steam Workshop Mods...
@ timeout 1 >nul
cd %SteamCMDPath%
for /f "tokens=1,2 delims=," %%g in %DayZModList% do steamcmd.exe +login %SteamLogin% +workshop_download_item 221100 "%%g" +quit
echo Steam Workshop files are up-to-date! Syncing Workshop source with server destination...
@ timeout 2 >nul
@ for /f "tokens=1,2 delims=," %%g in %DayZModList% do robocopy "%SteamCMDWorkshopPath%\%%g" "%DayZServerPath%\%%h" *.* /mir
@ for /f "tokens=1,2 delims=," %%g in %DayZModList% do forfiles /p "%DayZServerPath%\%%h" /m *.bikey /s /c "cmd /c copy @path %DayZServerPath%\keys"
echo Sync complete!
@ timeout 3 >nul
set "MODS_TO_LOAD="
for /f "tokens=1,2 delims=," %%g in %DayZModList% do (
set "MODS_TO_LOAD=!MODS_TO_LOAD!%%h;"
)
set "MODS_TO_LOAD=!MODS_TO_LOAD:~0,-1!"
ECHO Will start DayZ with the following mods: !MODS_TO_LOAD!%
@ timeout 3 >nul
goto startServer
