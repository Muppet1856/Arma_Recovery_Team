params ["_wreck"];
if (isNull _wreck) exitWith {};
if (!hasInterface) exitWith {};

[_wreck] spawn {
  params ["_wreck"];
  waitUntil { !isNull player };
  private _actId = -1;
  while { !isNull _wreck } do {
    private _queue = missionNamespace getVariable ["RT_WRECK_QUEUE", []];
    private _queued = (_queue findIf { _x == _wreck }) >= 0;
    private _distOK = (player distance _wreck) < 25;
    if (_actId < 0 && !_queued && _distOK) then {
      _actId = _wreck addAction [
        "📞 Call Recovery Team",
        {
          params ["_target", "_caller"];
          [_target, _caller] remoteExec ["RT_fnc_startRecovery", 2];
        },
        nil, 2, true, true, "", "true", 5
      ];
    } else {
      if ((_actId >= 0 && (!_distOK || _queued)) || isNull _wreck) then {
        _wreck removeAction _actId;
        _actId = -1;
      };
    };
    uiSleep 1.25;
  };
};