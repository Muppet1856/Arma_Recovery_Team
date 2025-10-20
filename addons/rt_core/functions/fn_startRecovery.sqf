if (!isServer) exitWith {};
params ["_wreck", "_caller"];

if (isNull _wreck) exitWith {};
if (alive _wreck) exitWith {};

private _queue = missionNamespace getVariable ["RT_WRECK_QUEUE", []];
if (_queue find _wreck < 0) then {
  _queue pushBack _wreck;
  missionNamespace setVariable ["RT_WRECK_QUEUE", _queue, true];
  if (!isNull _caller) then { ["Recovery requested. Team is en route."] remoteExec ["hint", _caller]; };
};

if (isNil "RT_ACTIVE_PROC" || { !(RT_ACTIVE_PROC) }) then {
  RT_ACTIVE_PROC = true;
  [] spawn {
    while { true } do {
      private _queue = missionNamespace getVariable ["RT_WRECK_QUEUE", []];
      _queue = _queue select { !isNull _x };
      if (_queue isEqualTo []) exitWith {};
      private _next = _queue deleteAt 0;
      missionNamespace setVariable ["RT_WRECK_QUEUE", _queue, true];
      try { [_next] call RT_fnc_recoverWreck; } catch { diag_log format ["[RT] Recovery error: %1", _exception]; };
    };
    RT_ACTIVE_PROC = false;
  };
};