private _basePos = [0,0,0];
if ((getMarkerColor RT_BASE_MARKER) != "") then { _basePos = getMarkerPos RT_BASE_MARKER; } else { _basePos = [worldSize * 0.1, worldSize * 0.1, 0]; };

private _heliType = RT_HELI_CLASS;
if (RT_AUTO_FACTION) then {
  private _side = RT_SIDE;
  private _pls = allPlayers;
  if (!isNil "_pls" && {count _pls > 0}) then { _side = side (_pls select 0); };
  switch (_side) do {
    case west:        { _heliType = RT_HELI_CLASS_WEST; };
    case east:        { _heliType = RT_HELI_CLASS_EAST; };
    case resistance:  { _heliType = RT_HELI_CLASS_RESIST; };
    case civilian:    { _heliType = RT_HELI_CLASS_CIV; };
    default           { _heliType = RT_HELI_CLASS; };
  };
};

private _heli = createVehicle [_heliType, _basePos, [], 0, "FLY"];
_heli setDir (random 360);
_heli setPosATL (_basePos vectorAdd [0,0,15]);

createVehicleCrew _heli;
private _heliGrp = group effectiveCommander _heli;
_heliGrp setBehaviour "AWARE";
_heliGrp setCombatMode "GREEN";
_heliGrp setSpeedMode "FULL";

private _teamGrp = createGroup [RT_SIDE, true];
private _unitClass = RT_TEAM_CLASS;
if (RT_AUTO_FACTION) then {
  switch (RT_SIDE) do {
    case west:        { _unitClass = RT_TEAM_CLASS_WEST; };
    case east:        { _unitClass = RT_TEAM_CLASS_EAST; };
    case resistance:  { _unitClass = RT_TEAM_CLASS_RESIST; };
    case civilian:    { _unitClass = RT_TEAM_CLASS_CIV; };
  };
};
for "_i" from 1 to (RT_TEAM_SIZE max 1) do { _teamGrp createUnit [_unitClass, _basePos, [], 0, "NONE"]; };
{ _x enableAI "PATH"; _x setSkill 0.6 } forEach units _teamGrp;

{ _x assignAsCargo _heli; _x moveInCargo _heli; } forEach units _teamGrp;
_heli flyInHeight RT_CRUISE_ALT;

[_heli, _heliGrp, _teamGrp, _basePos]