if (!hasInterface) exitWith {};
private _obj = cursorObject;
if (isNull _obj) exitWith { hint "No target."; };
if (!(_obj isKindOf "LandVehicle" || _obj isKindOf "Air" || _obj isKindOf "Ship")) exitWith { hint "Look at a vehicle."; };
if (alive _obj) exitWith { hint "Vehicle not destroyed."; };

[_obj, player] remoteExec ["RT_fnc_startRecovery", 2];
hint "Recovery requested for target.";