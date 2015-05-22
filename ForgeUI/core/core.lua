----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		core.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI core script
-----------------------------------------------------------------------------------------------

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeUI GUI library
local M = _G["ForgeLibs"]["ForgeModule"] -- ForgeUI module prototype
local A = _G["ForgeLibs"]["ForgeAddon"] -- ForgeUI addon prototype

-- libraries
local GeminiHook = Apollo.GetPackage("Gemini:Hook-1.0").tPackage
local GeminiDB = Apollo.GetPackage("Gemini:DB-1.1").tPackage
GeminiDB.callbacks = GeminiDB.callbacks or Apollo.GetPackage("Gemini:CallbackHandler-1.0").tPackage:New(GeminiDB)

-----------------------------------------------------------------------------------------------
-- ForgeUI Module Definition
-----------------------------------------------------------------------------------------------
local Core = {
	_NAME = "core",
	_API_VERSION = 3,
	VERSION = "1.0-alpha",

	tSettings = {
		profile = {
			bAdvanced = false,
			tClassColors = {
				crEngineer = "FFEFAB48",
				crEsper = "FF1591DB",
				crMedic = "FFFFE757",
				crSpellslinger = "FF98C723",
				crStalker = "FFD23EF4",
				crWarrior = "FFF54F4F"
			},
			tClassColorsSecondary = {
				crEngineer = "FFFFA740",
				crEsper = "FF31B9FF",
				crMedic = "FFFFDB34",
				crSpellslinger = "FFC0FFA0",
				crStalker = "FFBD68FF",
				crWarrior = "FFFF7272"
			},
			bDebug = false,
		}
	},
	tDefaults = {
		profile = {},
		char = {},
		global = {},
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
function Core:ForgeAPI_PreInit()
	local ForgeUI = Apollo.GetAddon("ForgeUI")
	
	self.db = GeminiDB:New(ForgeUI, self.tDefaults)
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnDatabaseStartup", "DatabaseStartup")
end

function Core:DatabaseStartup()
	self.db:SetProfile(self.db:GetCurrentProfile())
end

function Core:ForgeAPI_Init()
	Print("ForgeUI v" .. F:API_GetVersion() .. " has been loaded")
	
	GeminiHook:Embed(F)
end

function Core:RefreshConfig()

end

function Core:SetupDatabase(o)
	if o.tSettings then
		-- db defaults
		local tDefaults = self.copyTable(self.db.defaults, tDefaults)
		tDefaults.profile[o._NAME] = Core.copyTable(o.tSettings.profile, tDefaults.profile[o._NAME])
		tDefaults.global[o._NAME] = Core.copyTable(o.tSettings.global, tDefaults.global[o._NAME])
		tDefaults.char[o._NAME] = Core.copyTable(o.tSettings.char, tDefaults.char[o._NAME])
		self.db:RegisterDefaults(tDefaults)
	end
end

-----------------------------------------------------------------------------------------------
-- ForgeUI public API
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- ForgeUI Addon API
-----------------------------------------------------------------------------------------------
function F:API_NewAddon(tAddon, tParams)
	if not tAddon._NAME or tAddons[tAddon._NAME] then
		error("ForgeUI - Wrong addon name or nonexistent!")
		return
	end
	if tAddon._API_VERSION ~= F:API_GetApiVersion() then
		error("ForgeUI - Wrong API version! [" .. tAddon._NAME .. "]")
		return
	end

	if tAddon.ForgeAPI_PreInit then
		tAddon:ForgeAPI_PreInit()
	end
	
	Core:SetupDatabase(tAddon)
	
	-- new instance
	local addon = A:NewAddon(tAddon)
	
	-- db callbacks
	Core.db.RegisterCallback(addon, "OnProfileChanged", "RefreshConfig")
	Core.db.RegisterCallback(addon, "OnProfileDeleted", "RefreshConfig")
	Core.db.RegisterCallback(addon, "OnProfileReset", "RefreshConfig")
	
	Apollo.RegisterAddon(addon)
	
	tAddons[tAddon._NAME] = {
        ["tAddon"] = addon,
        ["tParams"] = tParams,
    }
	
	if bInit and addon.ForgeAPI_Init then
		addon:ForgeAPI_Init()
		addon.bInit = true
	end
	
	if addon.OnDocLoaded then
		GeminiHook:PostHook(addon, "OnDocLoaded", function()
			addon._DB.profile = F:API_GetDB(addon, "profile")
			addon:ForgeAPI_LoadSettings()
		end)
		tAddons[tAddon._NAME].bHooked = true
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
-- ForgeUI Module API
-----------------------------------------------------------------------------------------------
function F:API_NewModule(tModule, tParams)
	if not tModule._NAME or tModules[tModule._NAME] then
		error("ForgeUI - Wrong module name or nonexistent!")
		return
	end
	if tModule._API_VERSION ~= F:API_GetApiVersion() then
		error("ForgeUI - Wrong API version! [" .. tModule._NAME .. "]")
		return
	end

	if tModule.ForgeAPI_PreInit then
		tModule:ForgeAPI_PreInit()
	end
	
	Core:SetupDatabase(tModule)
	
	local module = M:NewModule(tModule)
	
	-- db callbacks
	Core.db.RegisterCallback(module, "OnProfileChanged", "RefreshConfig")
	Core.db.RegisterCallback(module, "OnProfileDeleted", "RefreshConfig")
	Core.db.RegisterCallback(module, "OnProfileReset", "RefreshConfig")
	
	tModules[tModule._NAME] = {
        ["tModule"] = module,
        ["tParams"] = tParams or {},
    }
	
	if tModule.tSettings then
		Core.db.profile[tModule._NAME] = tModule.tSettings.profile or {}
	end

	if bInit and module.ForgeAPI_Init then
		module:ForgeAPI_Init()
		module.bInit = true
	end
	
	if module.OnDocLoaded then
		GeminiHook:PostHook(module, "OnDocLoaded", module.ForgeAPI_LoadSettings)
		tModules[tModule._NAME].bHooked = true
	else
		if bInit and module.ForgeAPI_LoadSettings then
			module:ForgeAPI_LoadSettings()
		end
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
-- ForgeUI API
-----------------------------------------------------------------------------------------------
function F:API_GetDB(o, strType)
	if Core.db then
		if Core.db[strType] then
			return Core.db[strType][o._NAME]
		else
			return nil
		end
	else
		return nil
	end
end

function F:API_GetProfileName() return Core.db:GetCurrentProfile() end
function F:API_GetProfiles() return Core.db:GetProfiles() end
function F:API_ChangeProfile(...) Core.db:SetProfile(...) end
function F:API_RemoveProfile(...) Core.db:DeleteProfile(...) end
function F:API_NewProfile(...) Core.db:SetProfile(...) end

function F:API_GetClassColor(strClass)
	return Core._DB.profile.tClassColors["cr" .. strClass]
end

-----------------------------------------------------------------------------------------------
-- ForgeUI intern API
-----------------------------------------------------------------------------------------------
function F:Init()
	if bInit then return end
	bInit = true
	
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
function F:Reset() Core.db:ResetDB() F:Save(); end

-- helpers
function Core.copyTable(src, dest)
	if type(dest) ~= "table" then dest = {} end
	if type(src) == "table" then
		for k,v in pairs(src) do
			if type(v) == "table" then
				-- try to index the key first so that the metatable creates the defaults, if set, and use that table
				v = Core.copyTable(v, dest[k])
			end
			dest[k] = v
		end
	end
	return dest
end

Core = F:API_NewModule(Core)

