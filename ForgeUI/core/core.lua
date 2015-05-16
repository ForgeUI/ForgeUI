----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		core.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI core script
-----------------------------------------------------------------------------------------------

local F, A, M, G = unpack(_G["ForgeLibs"]) -- imports ForgeUI, Addon, Module, GUI

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
-- Local variables
-----------------------------------------------------------------------------------------------
local tModules = {}
local bInit = false
local bResetSettings = false

-----------------------------------------------------------------------------------------------
-- ForgeUI module functions
-----------------------------------------------------------------------------------------------
function Core:Init()
	Print("ForgeUI v" .. self.strVersion .. " has been loaded")
	
	local wndHome = F:API_AddMenuItem(self, "Home", "ForgeUI_Home")
	local wndHomeContainer = self.tOptionHolders["ForgeUI_Home"]
	
	G:API_AddText(self, wndHomeContainer, "TestText", { tOffsets = { 50, 50, 200, 75 } })
	
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
	if tModules[strName] then return end

	local module = M.new(t, strName)
	
	tModules[strName] = {
        ["tModule"] = module,
        ["tParams"] = tParams,
    }
	
	if bInit then
		module:Init()
		module.bInit = true
	end
	
	return module
end

function F:API_GetModule(strName)
    if not tModules[strName].tParams.bLocal then
        return tModules[strName].tModule
    else
        return nil
    end
end

function F:API_ListModules()
	for k, v in pairs(tModules) do
		Print(k)
	end
end

-----------------------------------------------------------------------------------------------
-- ForgeUI intern API
-----------------------------------------------------------------------------------------------
function F:Init()
	if bInit then return end

	bInit = true
	
	for k, v in pairs(tModules) do
		if not v.tModule.Init then
			Print("ERR: " .. k .. " module cannot be loaded!")
		else
			v.tModule:Init()
			v.tModule.bInit = true
		end
	end
end

function F:Save() RequestReloadUI() end
function F:Reset() bResetSettings = true; F:Save(); end

-----------------------------------------------------------------------------------------------
-- OnSave/OnRestore
-----------------------------------------------------------------------------------------------
function F:OnSave(eType)
	if bResetSettings then return {} end

	local Util = F:API_GetModule("util")

	if eType == GameLib.CodeEnumAddonSaveLevel.Character then
		local tData = {}
		
		for k, v in pairs(tModules) do
			tData[k] = {}
		
			if v.tModule.tCharSettings then
				tData[k].tCharSettings = {}
				
				tData[k].tCharSettings = Util:CopyTable(tData[k].tCharSettings , v.tModule.tCharSettings)
			end
		end
		
		return tData
	elseif eType == GameLib.CodeEnumAddonSaveLevel.General then
		local tData = {}
		
		for k, v in pairs(tModules) do
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
			tModules[k].tModule.tCharSettings = Util:CopyTable(tModules[k].tModule.tCharSettings, v.tCharSettings)
		end
	elseif eType == GameLib.CodeEnumAddonSaveLevel.General then
		for k, v in pairs(tData) do
			tModules[k].tModule.tGlobalSettings = Util:CopyTable(tModules[k].tModule.tGlobalSettings, v.tGlobalSettings)
		end
	end
end

Core = F:API_NewModule(Core, "core", { bLocal = true })

