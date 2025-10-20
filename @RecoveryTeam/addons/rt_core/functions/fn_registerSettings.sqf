/*
  RT_fnc_registerSettings
  Registers CBA Settings and a keybind (optional). Silently skips if CBA isn't loaded.
*/
if (!isClass (configFile >> "CfgPatches" >> "cba_main")) exitWith { diag_log "[RT] CBA not detected; skipping CBA Settings registration."; };

private _addCB = {
  params ["_var","_title","_tip","_default"];
  [
    _var, "CHECKBOX",
    [_title, _tip],
    ["Recovery Team","Core"],
    _default,
    1
  ] call CBA_fnc_addSetting;
};

private _addSL = {
  params ["_var","_title","_tip","_min","_max","_default","_decimals"];
  [
    _var, "SLIDER",
    [_title, _tip],
    ["Recovery Team","Flight"],
    [_min, _max, _default, _decimals],
    1
  ] call CBA_fnc_addSetting;
};

private _addLIST = {
  params ["_var","_title","_tip","_entries","_values","_defaultIndex","_subcategory"];
  [
    _var, "LIST",
    [_title, _tip],
    ["Recovery Team", _subcategory],
    [_entries, _values, _defaultIndex],
    1
  ] call CBA_fnc_addSetting;
};

["RT_ENABLE_FASTROPE", "Enable Fast-roping", "Attempt ACE/AR fast-roping; otherwise land/disembark.", true] call _addCB;
["RT_USE_AUTOSCAN", "Enable Auto-scan", "Automatically tag destroyed vehicles for recovery on a timer.", false] call _addCB;
["RT_AUTOSCAN_INTERVAL", "Auto-scan Interval (sec)", "Seconds between autoscan sweeps when enabled.", 10, 300, 60, 0] call _addSL;
["RT_DELETE_WRECK_ON_RTB", "Delete Wreck on Arrival", "Delete wreck at base on RTB (off = drop at base).", true] call _addCB;

["RT_HOVER_ALT", "Hover Altitude (m)", "Hover height for fast-roping.", 10, 40, 18, 0] call _addSL;
["RT_CRUISE_ALT", "Cruise Altitude (m)", "Transit altitude to target.", 30, 200, 60, 0] call _addSL;
["RT_LIFT_ALT", "Lift Altitude (m)", "Altitude while transporting wreck.", 20, 150, 40, 0] call _addSL;
["RT_APPROACH_SLOW", "Approach Slowly Near LZ", "Limit speed near the LZ for safety.", true] call _addCB;

["RT_ALLOW_ATTACH_FALLBACK", "Allow Attach Fallback", "If sling fails, hard-attach wreck under belly.", true] call _addCB;

["RT_SMOKE_TYPE", "Rig Smoke Class", "CfgAmmo class spawned at rig point.", ["SmokeShell","SmokeShellBlue","SmokeShellGreen","SmokeShellRed"], ["SmokeShell","SmokeShellBlue","SmokeShellGreen","SmokeShellRed"], 1, "Visuals"] call _addLIST;

["RT_HELI_CLASS", "Helicopter Class", "CfgVehicles classname for transport helicopter.", ["B_Heli_Transport_03_F","I_Heli_Transport_02_F","B_Heli_Transport_03_unarmed_F"], ["B_Heli_Transport_03_F","I_Heli_Transport_02_F","B_Heli_Transport_03_unarmed_F"], 0, "Spawning"] call _addLIST;
["RT_TEAM_CLASS", "Engineer Unit Class", "CfgVehicles classname for team units.", ["B_engineer_F","B_soldier_repair_F","I_engineer_F"], ["B_engineer_F","B_soldier_repair_F","I_engineer_F"], 0, "Spawning"] call _addLIST;
["RT_TEAM_SIZE", "Team Size", "Number of engineers.", 1, 8, 4, 0] call _addSL;
["RT_SIDE_STR", "Spawn Side", "Side for crew/team.", ["BLUFOR","OPFOR","INDEP","CIV"], ["west","east","independent","civilian"], 0, "Spawning"] call _addLIST;

["RT_SIDE_STR", "onApply", {
  private _s = missionNamespace getVariable ["RT_SIDE_STR","west"];
  private _map = [["west", west], ["east", east], ["independent", resistance], ["civilian", civilian]];
  private _val = west;
  {
    if (_x#0 isEqualTo _s) exitWith { _val = _x#1; };
  } forEach _map;
  missionNamespace setVariable ["RT_SIDE", _val, true];
}] call CBA_fnc_addSettingEventHandler;

["Recovery Team", "RT_Key_CallCursor", ["Call Recovery on Cursor", "Request recovery for the destroyed vehicle under your crosshair."], {
    [] call (missionNamespace getVariable ["RT_fnc_keybindCall", {}]);
  }, {}, [0, [false, false, false]], false] call CBA_fnc_addKeybind;

diag_log "[RT] CBA Settings registered.";