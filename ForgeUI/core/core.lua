----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		core.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI core script
-----------------------------------------------------------------------------------------------

local F, A, M = unpack(_G["ForgeLibs"]) -- imports ForgeUI, Addon, Module

-----------------------------------------------------------------------------------------------
-- ForgeUI Module Definition
-----------------------------------------------------------------------------------------------
local Core = {
	strVersion = "0.5.0alpha",

	tGlobalSettings = {
		bAdvanced = false,
		tClassColors = {
			crEngineer = "FFEFAB48",
			crEsper = "FF1591DB",
			crMedic = "FFFFE757",
			crSpellslinger = "FF98C723",
			crStalker = "FFD23EF4",
			crWarrior = "FFF54F4F"
		},
		bDebug = false,
	}
}

-----------------------------------------------------------------------------------------------
-- Module variables
-----------------------------------------------------------------------------------------------
Core.tModules = {}

Core.bInit = false

-----------------------------------------------------------------------------------------------
-- Local variables
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-- Settings
-----------------------------------------------------------------------------------------------
local bResetDefaults = false

local tSettings_addons = {}
local tSettings_windows = {}

-----------------------------------------------------------------------------------------------
-- ForgeUI module functions
-----------------------------------------------------------------------------------------------
function Core:Init()
	Print("ForgeUI v" .. self.strVersion .. " has been loaded")
	
	F:API_AddMenuItem(self, "Home")
	local wndGeneral = F:API_AddMenuItem(self, "General")
	F:API_AddMenuToMenuItem(self, wndGeneral, "Colors")
	F:API_AddMenuToMenuItem(self, wndGeneral, "Style")
	F:API_AddMenuToMenuItem(self, wndGeneral, "Layout")
	F:API_AddMenuItem(self, "Advanced")
end

-----------------------------------------------------------------------------------------------
-- ForgeUI public API
-----------------------------------------------------------------------------------------------
function F:API_NewModule(t, strName, tParams)
	if Core.tModules[strName] then return end

	local module = M.new(t, strName)
	
	Core.tModules[strName] = {
        ["tModule"] = module,
        ["tParams"] = tParams,
    }
	
	if Core.bInit then
		module:Init()
		module.bInit = true
	end
	
	return module
end

function F:API_GetModule(strName)
    if Core.tModules[strName].tParams.bGlobal then
        return Core.tModules[strName].tModule
    else
        return nil
    end
end

function F:API_ListModules()
	for k, v in pairs(Core.tModules) do
		Print(k)
	end
end

-----------------------------------------------------------------------------------------------
-- ForgeUI intern API
-----------------------------------------------------------------------------------------------
function F:Init()
	if Core.bInit then return end

	Core.bInit = true
	
	for k, v in pairs(Core.tModules) do
		if not v.tModule.Init then
			Print("ERR: " .. k .. " module cannot be loaded!")
		else
			v.tModule:Init()
			v.tModule.bInit = true
		end
	end
end

-----------------------------------------------------------------------------------------------
-- OnSave/OnRestore
-----------------------------------------------------------------------------------------------
function F:OnSave(eType)
	local Util = F:API_GetModule("util")

	if eType == GameLib.CodeEnumAddonSaveLevel.Character then
		local tData = {}
		
		for k, v in pairs(Core.tModules) do
			tData[k] = {}
		
			if v.tModule.tCharSettings then
				tData[k].tCharSettings = {}
				
				tData[k].tCharSettings = Util:CopyTable(tData[k].tCharSettings , v.tModule.tCharSettings)
			end
		end
		
		return tData
	elseif eType == GameLib.CodeEnumAddonSaveLevel.General then
		local tData = {}
		
		for k, v in pairs(Core.tModules) do
			tData[k] = {}
		
			if v.tModule.tGlobalSettings then
				tData[k].tGlobalSettings = {}
				
				tData[k].tGlobalSettings = Util:CopyTable(tData[k].tGlobalSettings , v.tModule.tGlobalSettings)
			end
		end
		
		return tData
	end
end

function F:OnRestore(eType, tData)
	local Util = F:API_GetModule("util")
	
	if eType == GameLib.CodeEnumAddonSaveLevel.Character then
		for k, v in pairs(tData) do
			Core.tModules[k].tModule.tCharSettings = Util:CopyTable(Core.tModules[k].tModule.tCharSettings, v.tCharSettings)
		end
	elseif eType == GameLib.CodeEnumAddonSaveLevel.General then
		for k, v in pairs(tData) do
			Core.tModules[k].tModule.tGlobalSettings = Util:CopyTable(Core.tModules[k].tModule.tGlobalSettings, v.tGlobalSettings)
		end
	end
end

Core = F:API_NewModule(Core, "core")

