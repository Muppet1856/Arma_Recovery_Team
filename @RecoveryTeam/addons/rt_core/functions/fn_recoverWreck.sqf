params ["_wreck"];
if (isNull _wreck) exitWith {};
if (alive _wreck) exitWith {};

private _out = [] call RT_fnc_spawnHelo;
private _heli   = _out # 0;
private _hGrp   = _out # 1;
private _tGrp   = _out # 2;
private _base   = _out # 3;

private _wp1 = _hGrp addWaypoint [getPosASL _wreck, 0];
_wp1 setWaypointType "MOVE";
_wp1 setWaypointSpeed "FULL";
_heli flyInHeight RT_CRUISE_ALT;

waitUntil { sleep 1; (_heli distance _wreck) < 500 || isNull _wreck };
if (isNull _wreck) exitWith { [_heli, _hGrp, _tGrp] call RT_fnc_cleanup; };

private _fastRoped = false;
private _hoverAlt  = RT_HOVER_ALT;
private _hoverPos = _wreck getPos [18 + random 10, random 360];

if (RT_APPROACH_SLOW) then { _hGrp setSpeedMode "LIMITED"; };
_heli doMove _hoverPos;
_heli flyInHeight _hoverAlt;

waitUntil { sleep 0.5; (_heli distance _hoverPos) < 30 || isNull _wreck || !alive _heli };
if (!isNull _heli && {!isNull _wreck}) then {
  _fastRoped = [_heli, _tGrp, _hoverAlt] call RT_fnc_tryFastRope;
};

if (!_fastRoped) then {
  private _lz = _wreck getPos [20 + random 20, random 360];
  private _wpL = _hGrp addWaypoint [_lz, 0];
  _wpL setWaypointType "MOVE";
  _wpL setWaypointCompletionRadius 5;

  waitUntil { sleep 1; (_heli distance _lz) < 35 || isNull _wreck };
  if (isNull _wreck) exitWith { [_heli, _hGrp, _tGrp] call RT_fnc_cleanup; };

  _heli land "GET IN";
  private _landT = time + 60;
  waitUntil { sleep 1; (isTouchingGround _heli) || time > _landT || isNull _wreck };

  { unassignVehicle _x; moveOut _x; } forEach units _tGrp;
} else {
  private _holdT = time + 30;
  while { time < _holdT && {!isNull _heli} } do { sleep 1; };
};

{
  _x doMove (getPos _wreck);
  _x setUnitPos "MIDDLE";
} forEach units _tGrp;

private _rigT = time + 90;
waitUntil { sleep 1; ((units _tGrp) findIf { (_x distance _wreck) < 8 }) >= 0 || time > _rigT || isNull _wreck };
if (isNull _wreck) exitWith { [_heli, _hGrp, _tGrp] call RT_fnc_cleanup; };

{
  _x playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1";
} forEach units _tGrp;

private _smoke = RT_SMOKE_TYPE createVehicle (getPos _wreck);

private _dummy = createVehicle [RT_SLING_DUMMY_CLASS, getPos _wreck, [], 0, "CAN_COLLIDE"];
_dummy hideObjectGlobal true;
_dummy enableSimulationGlobal true;
_dummy allowDamage false;
_dummy attachTo [_wreck, [0,0,0]];

private _needPickup = (units _tGrp) findIf { vehicle _x != _heli } != -1;
if (_needPickup) then {
  private _lz2 = _wreck getPos [25 + random 15, random 360];
  _heli doMove _lz2;
  _heli land "GET IN";
  private _pickupT = time + 60;
  waitUntil { sleep 1; (isTouchingGround _heli) || time > _pickupT || isNull _wreck || isNull _heli };
  { if (alive _x) then { _x assignAsCargo _heli; _x moveInCargo _heli; }; } forEach units _tGrp;
} else {
  { _x assignAsCargo _heli; _x moveInCargo _heli; } forEach units _tGrp;
};

sleep 2;

_heli engineOn true;
_heli land "NONE";
if (RT_APPROACH_SLOW) then { _hGrp setSpeedMode "LIMITED"; };
_heli flyInHeight (RT_HOVER_ALT max 18);

private _attempts = 0;
while { _attempts < 8 && { getSlingLoad _heli != _dummy } && { !isNull _heli } && { !isNull _wreck } } do {
  _attempts = _attempts + 1;
  private _p = getPosASL _wreck;
  _heli doMove _p;
  sleep 2;
  _heli setSlingLoad _dummy;
  sleep 2;
};

if (getSlingLoad _heli != _dummy && {!isNull _heli} && {!isNull _wreck} && { RT_ALLOW_ATTACH_FALLBACK }) then {
  _wreck attachTo [_heli, [0,0,-8]];
};

_hGrp setSpeedMode "FULL";
_heli flyInHeight RT_LIFT_ALT;

private _wpRTB = _hGrp addWaypoint [_base, 0];
_wpRTB setWaypointType "MOVE";

waitUntil { sleep 2; (_heli distance _base) < 300 || isNull _heli };

if (RT_DELETE_WRECK_ON_RTB) then {
  [_heli, _hGrp, _tGrp, _wreck, _dummy] call RT_fnc_cleanup;
} else {
  if (!isNull _heli) then { _heli setSlingLoad objNull; };
  if (!isNull _dummy) then { detach _dummy; deleteVehicle _dummy; };
  if (!isNull _wreck) then { _wreck setPosATL (_base vectorAdd [0,0,0]); };
  [_heli, _hGrp, _tGrp, objNull, objNull] call RT_fnc_cleanup;
};