#include "config.hpp";
if (isnil "DDOPP_pvSay") then {DDOPP_pvSay = [objNull,""]};
if (isnil "DDOPP_pvAnim") then {DDOPP_pvAnim = [objNull,""]};
if (isnil "DDOPP_pvSpawn") then {DDOPP_pvSpawn = ["",""]};
if (isnil "DDOPP_pvChat") then {DDOPP_pvChat = [objNull,"",""]};
DDOPP_public_say = {
	private ["_parameters","_who","_what","_pvUpdate"];
	_parameters = _this select 0;
	_who        = _parameters select 0;
	_what       = _parameters select 1;
	_pvUpdate   = _this select 1;
	_who say _what;
	if (_pvUpdate && isMultiplayer) then {
					diag_log("entrando en modo stun 3");
		DDOPP_pvSay = [_who,_what];
		publicVariable "DDOPP_pvSay";
	};
};
DDOPP_public_anim = {
	private ["_parameters","_who","_what","_pvUpdate"];
	_parameters = _this select 0;
	_who        = ((_parameters) select 0);
	_what       = ((_parameters) select 1);
	_pvUpdate   = _this select 1;
	_who switchMove _what;
	if (_pvUpdate && isMultiplayer) then {
		DDOPP_pvAnim = [_who,_what];
		publicVariable "DDOPP_pvAnim";
	};
};
DDOPP_public_spawn = {
	private ["_parameters","_fncName","_pvUpdate"];
	_parameters = ((_this select 0) select 0);
	_fncName    = ((_this select 0) select 1);
	_victim = _parameters select 0;
	_firer  = _parameters select 1;
	_timeStun = _parameters select 2;
	_pvUpdate   = _this select 1;
	diag_log(format [" esto:%1 spawn %2",str(_parameters),_fncName]);
	call compile format ["[_victim,_firer,_timeStun] spawn %1",_fncName];
	if (_pvUpdate && isMultiplayer) then {
		DDOPP_pvSpawn = [_parameters,_fncName];
		publicVariable "DDOPP_pvSpawn";
	};
};
DDOPP_taser_VictimCheck = {
	private ["_victim","_shooter","_stunTime"];
	_victim    = _this select 0;
	_shooter   = _this select 1;
	_stunTime  = _this select 2;
	if (_victim == player) then {
		[_victim, _shooter, _stunTime] call DDOPP_taser_victimFx;
	};
	if !(isPlayer _victim) then {
		switch isMultiplayer do {
			case true  : {
				if (isServer) then {
					[_victim, _shooter, _stunTime] call DDOPP_taser_victimFx;
					diag_log format ["D.DOPPLER Taser Mod: An AI unit was drive-stunned - %1 (AI) was stunned by %2 (%3) for %4 seconds. The calculation was handled by the server.", _victim, _shooter, name _shooter, _stunTime];		
				};
			};
			case false : {
				[_victim, _shooter, _stunTime] call DDOPP_taser_victimFx;
			}; 
		};
	};
};
DDOPP_taser_driveStun = {    
    private ["_shooter","_victim","_stunTime"];
    _shooter  = player;
    _victim   = cursortarget;
    _stunTime = DDOPP_taser_koTimeDS;
	
    if ((((weaponState _shooter) select 0) in DDOPP_taser_arrHandgun) && (((weaponState _shooter) select 1)== "Drive_Stun_Mode")) then {
        if !(_victim iskindof "Man") exitWith {};
            if (_shooter distance _victim < DDOPP_taser_maxTouchRange) then {
            diag_log("entrando en modo stun 2");
            [[_shooter,"Taser_Spark"],true] call DDOPP_public_say;
            [[[_victim,_shooter,_stunTime],"DDOPP_taser_VictimCheck"],true] call DDOPP_public_spawn;
            diag_log("entrando en modo stun 4");
        };
    };
	
};
DDOPP_taser_handleHit = {
    private ["_shooter","_selection","_damage","_shooter","_bullet"];
    Stop RPT SPAM//diag_log(format["Taser effect incoming %1",str(_this)]);
    _victim    = _this select 0;
    _selection = _this select 1;
    _damage    = _this select 2;
    _shooter   = _this select 3;
    _bullet    = _this select 4;
    if (_bullet in DDOPP_taser_arrBullet) then {
        [_victim, _shooter, DDOPP_taser_koTime] spawn DDOPP_taser_victimFx;
    };
    _damage
};

DDOPP_taser_victimFx = {
    private ["_victim","_shooter","_stunTime"];
    diag_log(format["Taser effect incoming: FX added kike %1",str(_this)]);
    _victim    = _this select 0;
    _shooter   = _this select 1;
    _stunTime  = _this select 2;
	
	if (_victim getVariable "isTazed") exitWith {}; 						            
	if ((animationState _victim) in DDOPP_taser_arrRestrainAnims) exitWith {};  
    if (!(isnull _victim) && (alive  _victim) && (vehicle _victim == _victim)) then {
        [[_victim,"Taser_Hit"],true] call DDOPP_public_say;
        if (animationState _victim in DDOPP_taser_arrProneAnims) then {
            [[_victim,"adthppnemstpsraswpstdnon_2"],true] call DDOPP_public_anim;
        } else {
            [[_victim,"adthpercmstpslowwrfldnon_4"],true] call DDOPP_public_anim;
        };
		if (_victim == player) then {
			(_stunTime/5) spawn {
				private "_loopTimes";
				_loopTimes = ((_this)-2);
				if (DDOPP_taser_enableHints) then {
					hintSilent parseText "<t size='1.25' font='Zeppelin32' color='#ff0000'>You have been tased!</t>";
				};
				disableuserinput true;
				"dynamicBlur" ppEffectEnable true; 
				"dynamicBlur" ppEffectAdjust [15]; 
				"dynamicBlur" ppEffectCommit 2; 
				"dynamicBlur" ppEffectAdjust [10]; 
				"dynamicBlur" ppEffectCommit ((_loopTimes*5)+10);
				for "_i" from 0 to (_loopTimes) do {
					cutRsc ["taser_hit_fx","PLAIN",1.5];
					sleep 5;
				};
				disableuserinput false;
				"dynamicBlur" ppEffectAdjust [0]; 
				"dynamicBlur" ppEffectCommit (10);
				sleep 3;
				if (DDOPP_taser_enableHints) then {
					hintSilent "";
				};
			};
        };
        _victim setVariable ["isTazed",true,true];
        sleep _stunTime;
        _victim setVariable ["isTazed",false,true];
		if !((animationState _victim) in DDOPP_taser_arrRestrainAnims) then {
            [[_victim,"amovppnemrunsnonwnondf"],true] call DDOPP_public_anim;
		};
    };
};
"DDOPP_pvSay" addPublicVariableEventHandler {[(_this select 1),false] call DDOPP_public_say};
"DDOPP_pvAnim" addPublicVariableEventHandler {[(_this select 1),false] call DDOPP_public_anim};
"DDOPP_pvSpawn" addPublicVariableEventHandler {[(_this select 1),false] call DDOPP_public_spawn};

if (isNil "isClient") then {isClient = (if (isMultiplayer) then [{!isServer},{true}])};
DDOPP_taser_version      	 = "v1.1 (23/2/2013)";
if (isClient) then {
	if (isNil "drive_stun_hotkey") then {
		drive_stun_hotkey = (findDisplay 46) displayAddEventHandler ["MouseButtonDown", "if(_this select 1 == 0) then {[] spawn DDOPP_taser_driveStun}"];
	};
};
