params ["_heli","_hGrp","_tGrp","_wreck", "_dummy"];
try {
  if (!isNull _heli) then { _heli setSlingLoad objNull; };
  if (!isNull _wreck) then { deleteVehicle _wreck; };
  if (!isNull _dummy) then { detach _dummy; deleteVehicle _dummy; };
} catch {};

private _all = [];
if (!isNull _heli) then { _all pushBack _heli; };
{ if (!isNull _x) then { _all pushBack _x; }; } forEach (units _tGrp);

{ deleteVehicle _x; } forEach _all;

if (!isNull _hGrp) then { deleteGroup _hGrp; };
if (!isNull _tGrp) then { deleteGroup _tGrp; };