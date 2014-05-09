/*	
	For DayZ Epoch
	Addons Credits: Jetski Yanahui by Kol9yN, Zakat, Gerasimow9, YuraPetrov, zGuba, A.Karagod, IceBreakr, Sahbazz
*/
startLoadingScreen ["","RscDisplayLoadCustom"];
cutText ["","BLACK OUT"];
enableSaving [false, false];

//REALLY IMPORTANT VALUES
dayZ_instance =	24;				//The instance
dayzHiveRequest = [];
initialized = false;
dayz_previousID = 0;
server_name = "Shadow Squad";

//disable greeting menu 
player setVariable ["BIS_noCoreConversations", true];
//disable radio messages to be heard and shown in the left lower corner of the screen
enableRadio false;
// May prevent "how are you civillian?" messages from NPC
enableSentences false;

// DayZ Epochconfig
spawnShoremode = 1; // Default = 1 (on shore)
spawnArea= 1500; // Default = 1500
dayz_MapArea = 18000; // Default = 10000
dayz_minpos = -1000; 
dayz_maxpos = 26000;

//Epoch Config Variables
call compile preprocessFileLineNumbers "config\epochconfig.sqf";	

// Dayz Epoch Events
EpochEvents = [["any","any","any","any",30,"crash_spawner"],["any","any","any","any",0,"crash_spawner"],["any","any","any","any",15,"supply_drop"]];


//Load in compiled functions
call compile preprocessFileLineNumbers "init\variables.sqf";				//Initilize the Variables (IMPORTANT: Must happen very early)
progressLoadingScreen 0.1;
call compile preprocessFileLineNumbers "init\publicEH.sqf";				//Initilize the publicVariable event handlers
progressLoadingScreen 0.2;
call compile preprocessFileLineNumbers "\z\addons\dayz_code\medical\setup_functions_med.sqf";	//Functions used by CLIENT for medical
progressLoadingScreen 0.4;
call compile preprocessFileLineNumbers "init\compiles.sqf";				//Compile regular functions
progressLoadingScreen 0.5;
call compile preprocessFileLineNumbers "traders\server_traders.sqf";				//Compile trader configs
progressLoadingScreen 1.0;

"filmic" setToneMappingParams [0.153, 0.357, 0.231, 0.1573, 0.011, 3.750, 6, 4]; setToneMapping "Filmic";

if (isServer) then {
	//Compile vehicle configs
	call compile preprocessFileLineNumbers "\z\addons\dayz_server\missions\DayZ_Epoch_24.Napf\dynamic_vehicle.sqf";				
	// Add trader citys
	_nil = [] execVM "\z\addons\dayz_server\missions\DayZ_Epoch_24.Napf\mission.sqf";

	_serverMonitor = 	[] execVM "\z\addons\dayz_code\system\server_monitor.sqf";
};

if (!isDedicated) then {
[] execVM "compile\Server_WelcomeCredits.sqf";
	//Conduct map operations
	0 fadeSound 0;
	waitUntil {!isNil "dayz_loadScreenMsg"};
	dayz_loadScreenMsg = (localize "STR_AUTHENTICATING");
	
	//Run the player monitor
	_id = player addEventHandler ["Respawn", {_id = [] spawn player_death;}];
	_playerMonitor = 	[] execVM "\z\addons\dayz_code\system\player_monitor.sqf";	

};

//Start Dynamic Weather
execVM "\z\addons\dayz_code\external\DynamicWeatherEffects.sqf";
//

[] execVM "admintools\AdminList.sqf";
if ( !((getPlayerUID player) in AdminList) && !((getPlayerUID player) in ModList) && !((getPlayerUID player) in tempList)) then 
{
    [] execVM "\z\addons\dayz_code\system\antihack.sqf";
};


#include "\z\addons\dayz_code\system\BIS_Effects\init.sqf"

//Mod Config 
execVM  "config\modconfig.sqf";	

p2_newspawn = compile preprocessFileLineNumbers "Scripts\Newspawn\newspawn_execute.sqf";
waitUntil {!isNil ("PVDZE_plr_LoginRecord")};
if (dayzPlayerLogin2 select 2) then
{
    player spawn p2_newspawn;
};

[] execVM "ActionMenu\actionmenu_activate.sqf";

[] execVM "admintools\Activate.sqf";

//DayZ Watermark
if (!isNil "server_name") then {
[] spawn {
waitUntil {(!isNull Player) and (alive Player) and (player == player)};
waituntil {!(isNull (findDisplay 46))};
5 cutRsc ["wm_disp","PLAIN"];
((uiNamespace getVariable "wm_disp") displayCtrl 1) ctrlSetText server_name;
};
};

[] execvm 'SDS\sds_SafeZoneCommander.sqf';

if (!isDedicated) then {[] execVM "Stats\j0k3r5_stats.sqf"};

