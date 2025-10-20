class CfgPatches
{
  class rt_core
  {
    name = "Recovery Team (Core)";
    author = "You";
    requiredVersion = 2.06;
    requiredAddons[] = {};
    units[] = {};
    weapons[] = {};
    version = "1.6.0";
  };
};

class CfgFunctions
{
  class RT
  {
    tag = "RT";
    class core
    {
      file = "functions";
      class registerSettings { preInit = 1; };
      class init { postInit = 1; };
      class addWreckAction {};
      class startRecovery {};
      class recoverWreck {};
      class spawnHelo {};
      class cleanup {};
      class tryFastRope {};
      class keybindCall {};
      class moduleCallRecovery {};
    };
  };
};

class CfgFactionClasses
{
  class RT_Modules
  {
    displayName = "Recovery Team";
    priority = 2;
    side = 7;
  };
};

class CfgEditorCategories
{
  class RT_Editor
  {
    displayName = "Recovery Team";
  };
};

class CfgEditorSubcategories
{
  class RT_Editor_Modules
  {
    displayName = "Modules";
  };
};

class CfgVehicles
{
  class Logic;
  class Module_F: Logic
  {
    class ArgumentsBaseUnits
    {
      class Units;
    };
    class ModuleDescription
    {
      class EmptyDetector;
    };
  };

  class RT_Module_CallRecovery: Module_F
  {
    scope = 2;
    displayName = "Call Recovery (Nearest Wreck)";
    icon = "\A3\ui_f\data\map\markers\military\pickup_CA.paa";
    category = "RT_Editor";
    subCategory = "RT_Editor_Modules";
    faction = "RT_Modules";
    function = "RT_fnc_moduleCallRecovery";
    functionPriority = 1;
    isGlobal = 1;
    isTriggerActivated = 0;
    isDisposable = 1;
    curatorCanAttach = 1;

    class Arguments
    {
      class Radius
      {
        displayName = "Search Radius";
        description = "Meters to search for a destroyed vehicle near the module position.";
        typeName = "NUMBER";
        defaultValue = 50;
      };
    };
    class ModuleDescription: ModuleDescription
    {
      description = "Requests recovery for the nearest destroyed vehicle within the given radius.";
    };
  };
};