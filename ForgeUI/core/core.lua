----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		core.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI core script
-----------------------------------------------------------------------------------------------

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local P = _G["ForgeLibs"]["ForgeProfiles"] -- ForgeUI profiles library
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeUI GUI library
local M = _G["ForgeLibs"]["ForgeModule"] -- ForgeUI module prototype
local A = _G["ForgeLibs"]["ForgeAddon"] -- ForgeUI addon prototype

-- libraries
local GeminiHook = Apollo.GetPackage("Gemini:Hook-1.0").tPackage

-----------------------------------------------------------------------------------------------
-- ForgeUI Module Definition
-----------------------------------------------------------------------------------------------
local Core = {
	NAME = "core",
	API_VERSION = 3,
	VERSION = "1.0-alpha",

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
local tForgeSavedData = { -- template for saving data
	tGeneral = {
		_tInfo = {},
		tProfiles = {},
	},
	tCharacter = {
		tProfiles = {},
	}
}

local tModules = {}
local tAddons = {}
local bInit = false
local bResetSettings = false

-----------------------------------------------------------------------------------------------
-- ForgeUI module functions
-----------------------------------------------------------------------------------------------
function Core:ForgeAPI_Init()
	Print("ForgeUI v" .. F:API_GetVersion() .. " has been loaded")
	
	GeminiHook:Embed(F)
end

-----------------------------------------------------------------------------------------------
-- ForgeUI public API
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- ForgeUI Addon API
-----------------------------------------------------------------------------------------------
function F:API_NewAddon(tAddon, tParams)
	if not tAddon.NAME or tAddons[tAddon.NAME] then return end
	if tAddon.API_VERSION ~= F:API_GetApiVersion() then return end

	local addon = A:NewAddon(tAddon)
	Apollo.RegisterAddon(addon)
	
	tAddons[tAddon.NAME] = {
        ["tAddon"] = addon,
        ["tParams"] = tParams,
    }
	
	if addon.ForgeAPI_PreInit then
		addon:ForgeAPI_PreInit()
	end

	if bInit and addon.ForgeAPI_Init then
		addon:ForgeAPI_Init()
		addon.bInit = true
	end
	
	if addon.OnDocLoaded then
		GeminiHook:PostHook(addon, "OnDocLoaded", addon.ForgeAPI_LoadSettings)
		tAddons[tAddon.NAME].bHooked = true
	else
		if bInit and addon.ForgeAPI_LoadSettings then
			addon:ForgeAPI_LoadSettings()
		end
	end
	
	if bInit and addon.ForgeAPI_PopulateOptions then
		addon:ForgeAPI_PopulateOptions()
	end
	
	return addon
end

function F:API_GetAddon(strName)
    if tAddons[strName] then
        return tAddons[strName].tAddon
	end
end

function F:API_ListAddons()
	for k, v in pairs(tAddons) do
		Print(k)
	end
end

-----------------------------------------------------------------------------------------------
-- ForgeUI API
-----------------------------------------------------------------------------------------------
function F:API_GetClassColor(strClass)
	return Core.tGlobalSettings.tClassColors["cr" .. strClass]
end

-----------------------------------------------------------------------------------------------
-- ForgeUI Module API
-----------------------------------------------------------------------------------------------
function F:API_NewModule(tModule, tParams)
	if not tModule.NAME or tModules[tModule.NAME] then return end
	if tModule.API_VERSION ~= F:API_GetApiVersion() then return end

	local module = M:NewModule(tModule)
	
	tModules[tModule.NAME] = {
        ["tModule"] = module,
        ["tParams"] = tParams or {},
    }
	
	if module.ForgeAPI_PreInit then
		module:ForgeAPI_PreInit()
	end

	if bInit and module.ForgeAPI_Init then
		module:ForgeAPI_Init()
		module.bInit = true
	end
	
	if bInit and module.ForgeAPI_LoadSettings then
		module:ForgeAPI_LoadSettings()
	end
	
	if bInit and module.ForgeAPI_PopulateOptions then
		module:ForgeAPI_PopulateOptions()
	end
	
	return module
end

function F:API_GetModule(strName)
    if tModules[strName] and not tModules[strName].tParams.bLocal then
        return tModules[strName].tModule
    else
        return nil
    end
end

function F:API_ListModules()
	for k, v in pairs(tModules) do
		if v.tModule.VERSION then
			Print(v.tModule.NAME .. " v" .. v.tModule.VERSION)
		else
			Print(v.tModule.NAME)
		end
	end
end

-----------------------------------------------------------------------------------------------
-- ForgeUI intern API
-----------------------------------------------------------------------------------------------
function F:Init()
	if bInit then return end
	bInit = true
	
	F:AfterRestore()
	
	for k, v in pairs(tModules) do
		if not v.tModule.ForgeAPI_Init then
			Print("ERR: " .. k .. " module cannot be loaded!")
		else
			v.tModule:ForgeAPI_Init()
			v.tModule.bInit = true
		end
		
		if v.tModule.ForgeAPI_LoadSettings then
			v.tModule:ForgeAPI_LoadSettings()
		end
		
		if v.tModule.ForgeAPI_PopulateOptions then
			v.tModule:ForgeAPI_PopulateOptions()
		end
	end
	
	for k, v in pairs(tAddons) do
		if not v.tAddon.ForgeAPI_Init then
			Print("ERR: " .. k .. " addon cannot be loaded!")
		else
			v.tAddon:ForgeAPI_Init(v.tAddon)
			v.tAddon.bInit = true
		end
		
		if v.tAddon.ForgeAPI_LoadSettings and not v.bHooked then
			v.tAddon:ForgeAPI_LoadSettings()
		end
		
		if v.tAddon.ForgeAPI_PopulateOptions then
			v.tAddon:ForgeAPI_PopulateOptions()
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
		local tData = P:API_GetProfile(tForgeSavedData.tCharacter)
		local tNewData = {}
		
		if tData then
			tData.tModules = {}
			for k, v in pairs(tModules) do
				if v.tModule.tCharSettings then
					tData.tModules[k] = {}
					tData.tModules[k].tCharSettings = {}
					
					tData.tModules[k].tCharSettings = v.tModule.tCharSettings
				end
			end
			
			tData.tAddons = {}
			for k, v in pairs(tAddons) do
				if v.tAddon.tCharSettings then
					tData.tAddons[k] = {}
					tData.tAddons[k].tCharSettings = {}
					
					tData.tAddons[k].tCharSettings = v.tAddon.tCharSettings
				end
			end
		end
		
		tNewData = Util:CopyTable(tNewData, tForgeSavedData.tCharacter)
		return tNewData
	elseif eType == GameLib.CodeEnumAddonSaveLevel.General then
		P:OnSave(tForgeSavedData)
	
		local tData = P:API_GetProfile(tForgeSavedData.tGeneral)
		
		tData.tModules = {}
		for k, v in pairs(tModules) do
			if v.tModule.tGlobalSettings then
				tData.tModules[k] = {}
				tData.tModules[k].tGlobalSettings = {}
				
				tData.tModules[k].tGlobalSettings = v.tModule.tGlobalSettings
			end
		end
		
		tData.tAddons = {}
		for k, v in pairs(tAddons) do
			if v.tAddon.tGlobalSettings then
				tData.tAddons[k] = {}
				tData.tAddons[k].tGlobalSettings = {}
				
				tData.tAddons[k].tGlobalSettings = v.tAddon.tGlobalSettings
			end
		end
		
		tNewData = Util:CopyTable(tNewData, tForgeSavedData.tGeneral)
		return tNewData
	end
end

function F:OnRestore(eType, tData)
	local Util = F:API_GetModule("util")
	
	if eType == GameLib.CodeEnumAddonSaveLevel.General then
		tForgeSavedData.tGeneral = Util:CopyTable(tForgeSavedData.tGeneral, tData)
	elseif eType == GameLib.CodeEnumAddonSaveLevel.Character then
		tForgeSavedData.tCharacter = Util:CopyTable(tForgeSavedData.tCharacter, tData)
	end
end

function F:AfterRestore()
	P:AfterRestore(tForgeSavedData)

	local Util = F:API_GetModule("util")
	
	local tData = {}
	
	-- character settings
	tData = P:API_GetProfile(tForgeSavedData.tCharacter)
	
	if tData.tModules then
		for k, v in pairs(tData.tModules) do
			if tModules[k] then
				tModules[k].tModule.tCharSettings = Util:CopyTable(tModules[k].tModule.tCharSettings, v.tCharSettings)
			end
		end
	end
	if tData.tAddons then
		for k, v in pairs(tData.tAddons) do
			if tAddons[k] then
				tAddons[k].tAddon.tCharSettings = Util:CopyTable(tAddons[k].tAddon.tCharSettings, v.tCharSettings)
			end
		end
	end

	-- global settings
	tData = P:API_GetProfile(tForgeSavedData.tGeneral)
	
	if tData.tModules then
		for k, v in pairs(tData.tModules) do
			if tModules[k] then
				tModules[k].tModule.tGlobalSettings = Util:CopyTable(tModules[k].tModule.tGlobalSettings, v.tGlobalSettings)
			end
		end
	end
	if tData.tAddons then
		for k, v in pairs(tData.tAddons) do
			if tAddons[k] then
				tAddons[k].tAddon.tGlobalSettings = Util:CopyTable(tAddons[k].tAddon.tGlobalSettings, v.tGlobalSettings)
			end
		end
	end
end

Core = F:API_NewModule(Core)

