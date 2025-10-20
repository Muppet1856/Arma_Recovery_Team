params ["_logic", "_units", "_activated"];
if (!isServer) exitWith {};

private _radius = (_logic getVariable ["Radius", 50]) max 5;
private _pos = getPos _logic;
private _cands = (nearestObjects [_pos, ["LandVehicle","Air","Ship"], _radius]) select { !alive _x };
if (_cands isEqualTo []) exitWith { deleteVehicle _logic; };

private _wreck = _cands select 0;
private _tagged = missionNamespace getVariable ["RT_WRECK_TAGGED", []];
_tagged pushBackUnique _wreck;
missionNamespace setVariable ["RT_WRECK_TAGGED", _tagged, true];
_wreck setVariable ["BIS_fnc_GC_ignore", true, true];

[_wreck, objNull] remoteExec ["RT_fnc_startRecovery", 2];
deleteVehicle _logic;