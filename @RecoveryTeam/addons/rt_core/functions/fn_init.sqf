/*
  Recovery Team: init (reads settings, sets defaults, hooks handlers)
*/
if (isNil "RT_ENABLE_FASTROPE") then { RT_ENABLE_FASTROPE = true; };
if (isNil "RT_USE_AUTOSCAN") then { RT_USE_AUTOSCAN = false; };
if (isNil "RT_AUTOSCAN_INTERVAL") then { RT_AUTOSCAN_INTERVAL = 60; };
if (isNil "RT_DELETE_WRECK_ON_RTB") then { RT_DELETE_WRECK_ON_RTB = true; };

if (isNil "RT_HOVER_ALT") then { RT_HOVER_ALT = 18; };
if (isNil "RT_CRUISE_ALT") then { RT_CRUISE_ALT = 60; };
if (isNil "RT_LIFT_ALT") then { RT_LIFT_ALT = 40; };
if (isNil "RT_APPROACH_SLOW") then { RT_APPROACH_SLOW = true; };

if (isNil "RT_ALLOW_ATTACH_FALLBACK") then { RT_ALLOW_ATTACH_FALLBACK = true; };
if (isNil "RT_SLING_DUMMY_CLASS") then { RT_SLING_DUMMY_CLASS = "CargoNet_01_box_F"; };

if (isNil "RT_SMOKE_TYPE") then { RT_SMOKE_TYPE = "SmokeShellBlue"; };

if (isNil "RT_HELI_CLASS") then { RT_HELI_CLASS = "B_Heli_Transport_03_F"; };
if (isNil "RT_TEAM_CLASS") then { RT_TEAM_CLASS = "B_engineer_F"; };
if (isNil "RT_TEAM_SIZE") then { RT_TEAM_SIZE = 4; };
if (isNil "RT_SIDE") then { RT_SIDE = west; };

if (isNil "RT_BASE_MARKER") then { RT_BASE_MARKER = "mrk_recovery_base"; };

if (isNil "RT_AUTO_FACTION") then { RT_AUTO_FACTION = true; };
if (isNil "RT_HELI_CLASS_WEST") then { RT_HELI_CLASS_WEST = "B_Heli_Transport_03_F"; };
if (isNil "RT_HELI_CLASS_EAST") then { RT_HELI_CLASS_EAST = "O_Heli_Transport_04_F"; };
if (isNil "RT_HELI_CLASS_RESIST") then { RT_HELI_CLASS_RESIST = "I_Heli_Transport_02_F"; };
if (isNil "RT_HELI_CLASS_CIV") then { RT_HELI_CLASS_CIV = "C_Heli_Light_01_civil_F"; };
if (isNil "RT_TEAM_CLASS_WEST") then { RT_TEAM_CLASS_WEST = "B_engineer_F"; };
if (isNil "RT_TEAM_CLASS_EAST") then { RT_TEAM_CLASS_EAST = "O_engineer_F"; };
if (isNil "RT_TEAM_CLASS_RESIST") then { RT_TEAM_CLASS_RESIST = "I_engineer_F"; };
if (isNil "RT_TEAM_CLASS_CIV") then { RT_TEAM_CLASS_CIV = "C_man_w_worker_F"; };

if (isServer) then {
  private _ok = false;
  private _rootCfg = preprocessFileLineNumbers "userconfig\RT\RT_settings.sqf";
  if !(_rootCfg isEqualTo "") then { call compile _rootCfg; _ok = true; } else {
    private _modCfg = preprocessFileLineNumbers "@RecoveryTeam\userconfig\RT\RT_settings.sqf";
    if !(_modCfg isEqualTo "") then { call compile _modCfg; _ok = true; };
  };
  if (_ok) then { diag_log "[RT] Settings loaded."; } else { diag_log "[RT] Using built-in defaults."; };
};

if (isServer) then {
  missionNamespace setVariable ["RT_WRECK_QUEUE", [], true];
  missionNamespace setVariable ["RT_WRECK_TAGGED", [], true];

  addMissionEventHandler ["EntityKilled", {
    params ["_killed"];
    if (!isNull _killed && { (_killed isKindOf "LandVehicle") || (_killed isKindOf "Air") || (_killed isKindOf "Ship") }) then {
      private _tagged = missionNamespace getVariable ["RT_WRECK_TAGGED", []];
      _tagged pushBackUnique _killed;
      missionNamespace setVariable ["RT_WRECK_TAGGED", _tagged, true];
      _killed setVariable ["BIS_fnc_GC_ignore", true, true];
      [_killed] remoteExec ["RT_fnc_addWreckAction", 0, _killed];
    };
  }];
};

if (isServer && { RT_USE_AUTOSCAN }) then {
  [] spawn {
    while { true } do {
      uiSleep (RT_AUTOSCAN_INTERVAL max 10);
      private _cand = (allVehicles select { !alive _x && { (_x isKindOf "LandVehicle") || (_x isKindOf "Air") || (_x isKindOf "Ship") } });
      private _done = missionNamespace getVariable ["RT_WRECK_TAGGED", []];
      {
        if !(_x in _done) then {
          _done pushBackUnique _x;
          _x setVariable ["BIS_fnc_GC_ignore", true, true];
          [_x] remoteExec ["RT_fnc_addWreckAction", 0, _x];
        };
      } forEach _cand;
      missionNamespace setVariable ["RT_WRECK_TAGGED", _done, true];
    };
  };
};