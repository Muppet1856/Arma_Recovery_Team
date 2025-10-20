params ["_heli", "_teamGrp", "_ropeHeight"];
if (!isServer) exitWith { false };
if (isNull _heli || { isNull _teamGrp }) exitWith { false };
if (!RT_ENABLE_FASTROPE) exitWith { false };

private _used = false;

private _hasACE = isClass (configFile >> "CfgPatches" >> "ace_fastroping");
private _fnEquip  = missionNamespace getVariable ["ace_fastroping_fnc_equipFRIES", scriptNull];
private _fnDeploy = missionNamespace getVariable ["ace_fastroping_fnc_deployAI", scriptNull];

if (_hasACE && {!isNil "_fnEquip"} && {!isNil "_fnDeploy"}) then {
  try {
    { if (vehicle _x != _heli) then { _x assignAsCargo _heli; _x moveInCargo _heli; }; } forEach units _teamGrp;
    [_heli] call _fnEquip;
    _heli flyInHeightASL [_ropeHeight max 12, _ropeHeight max 12, _ropeHeight max 12];
    (group effectiveCommander _heli) setSpeedMode "LIMITED";
    [_heli] call _fnDeploy;
    _used = true;
  } catch {
    diag_log format ["[RT] ACE fast-rope attempt failed: %1", _exception];
  };
};

if (!_used) then {
  private _hasAR = isClass (configFile >> "CfgPatches" >> "AdvancedRappelling");
  private _fnAR  = missionNamespace getVariable ["AR_Rappel_All_Cargo", scriptNull];
  if (_hasAR && {!isNil "_fnAR"}) then {
    try {
      { if (vehicle _x != _heli) then { _x assignAsCargo _heli; _x moveInCargo _heli; }; } forEach units _teamGrp;
      _heli flyInHeightASL [_ropeHeight max 15, _ropeHeight max 15, _ropeHeight max 15];
      (group effectiveCommander _heli) setSpeedMode "LIMITED";
      private _posASL = getPosASL _heli;
      [_heli, _ropeHeight max 15, _posASL] call _fnAR;
      _used = true;
    } catch {
      diag_log format ["[RT] Advanced Rappelling attempt failed: %1", _exception];
    };
  };
};

_used