private ["_damage","_headShots"];
_zed = _this select 0;
_selection = _this select 1;
_damage = _this select 2;
_hitter = _this select 3;
_projectile = _this select 4;
_this call DDOPP_taser_handleHit;

if (_projectile in MeleeAmmo) then {
	_damage = _damage * 10;
};
if (local _zed) then {
	if (_damage > 1 and _projectile != "") then {
		switch (_selection) do {
			case "head_hit": {
				if (!(_zed getVariable["hitRegistered",false])) then {
					_headShots = _hitter getVariable["headShots",0];
					_hitter setVariable["headShots",(_headShots + 1),true];
					_zed setVariable["hitRegistered",true];
				};
			};
		};
		if (_projectile isKindOf "Bolt") then {
			_damageOrg = _hitter getVariable["firedDamage",0];
			if (_damageOrg < _damage) then {
				_hitter setVariable["firedHit",[_zed,_selection],true];
				_hitter setVariable["firedDamage",_damage,true];
			};
		};
	};
};
_damage