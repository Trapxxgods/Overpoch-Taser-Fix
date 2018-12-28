# Overpoch-Taser-Fix

Step 1 Copy over the ddopp file to your mpmissions file or wherever you want.

Step 2 in your init.sqf under 
call compile preprocessFileLineNumbers "\z\addons\dayz_code\system\mission\chernarus11.sqf";
paste this execVM "ddopp\init.sqf";

Step 3 in dayz_code init compiles after the if (!isDedicated) then { section paste this 

local_zombieDamage = compile preprocessFileLineNumbers "dayz_code\compile\fn_damageHandlerZ.sqf";	
fnc_usec_damageHandler = compile preprocessFileLineNumbers "dayz_code\compile\fn_damageHandler.sqf";

Step 3 Now open dayz_code\compiles and paste the following fn_damageHandlerZ.sqf";	 fn_damageHandler.sqf"; in that folder.

Now your done
