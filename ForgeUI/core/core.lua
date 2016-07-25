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

local ForgeUI = Apollo.GetAddon("ForgeUI")

-- libraries
local GeminiHook = Apollo.GetPackage("Gemini:Hook-1.0").tPackage
local GeminiEvent = Apollo.GetPackage("Gemini:Event-1.0").tPackage
local GeminiDB = Apollo.GetPackage("Gemini:DB-1.0").tPackage
GeminiDB.callbacks = GeminiDB.callbacks or Apollo.GetPackage("Gemini:CallbackHandler-1.0").tPackage:New(GeminiDB)

-----------------------------------------------------------------------------------------------
-- ForgeUI Module Definition
-----------------------------------------------------------------------------------------------
local Core = {
	_NAME = "core",
	_API_VERSION = 3,
	_VERSION = "1.0",

	tSettings = {
		profile = {
			nColorPreset = 0,
			b24Hour = true,
			tClassColors = {
				[GameLib.CodeEnumClass.Engineer] = "FFEFAB48",
				[GameLib.CodeEnumClass.Esper] = "FF1591DB",
				[GameLib.CodeEnumClass.Medic]= "FFFFE757",
				[GameLib.CodeEnumClass.Spellslinger] = "FF98C723",
				[GameLib.CodeEnumClass.Stalker] = "FFD23EF4",
				[GameLib.CodeEnumClass.Warrior] = "FFF54F4F"
			},
			tDispositionColors = {
				[Unit.CodeEnumDisposition.Friendly] = "FF75CC26",
				[Unit.CodeEnumDisposition.Neutral] = "FFF3D829",
				[Unit.CodeEnumDisposition.Hostile] = "FFE50000",
				[Unit.CodeEnumDisposition.Unknown] = "FF666666",
			},
		},
	},
}

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local error = error

-----------------------------------------------------------------------------------------------
-- Local variables
-----------------------------------------------------------------------------------------------
local tModules = {}
local tPreloadModules = {}
local tAddons = {}
local tPreloadAddons = {}

local bInit = false
local bResetSettings = false

-----------------------------------------------------------------------------------------------
-- ForgeUI module functions
-----------------------------------------------------------------------------------------------
function Core:ForgeAPI_PreInit()
	self.db = GeminiDB:New(ForgeUI)

	-- db callbacks
	self.db.RegisterCallback(self, "OnProfileChanged", "OnDatabaseUpdate")
	self.db.RegisterCallback(self, "OnProfileDeleted", "OnDatabaseUpdate")
	self.db.RegisterCallback(self, "OnProfileReset", "OnDatabaseUpdate")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnDatabaseUpdate")
end

function Core:ForgeAPI_Init()
	Print("ForgeUI v" .. F:API_GetVersion() .. " has been loaded")

	GeminiHook:Embed(F)

	Apollo.RegisterEventHandler("UnitEnteredCombat", "OnUnitEnteredCombat", self)
end

function Core:OnUnitEnteredCombat(unit, bInCombat)
	if not unit:IsThePlayer() then return end

	F:API_SendEvent("PlayerEnteredCombat", bInCombat)
end

function Core:OnDatabaseUpdate()
	self:RefreshConfig()

	for k, v in pairs(tModules) do
		if k ~= "core" then v.tModule:RefreshConfig() end
	end

	for _, v in pairs(tAddons) do
		v.tAddon:RefreshConfig()
	end

	ForgeUI:CollapseAllMenuItems()
end

-----------------------------------------------------------------------------------------------
-- ForgeUI public API
--
-- ForgeUI Addon API
-----------------------------------------------------------------------------------------------
local function InitAddon(tAddon, tParams)
	if tAddon.bInit then return true end

	for _, v in ipairs(tParams.arDependencies or {}) do
		local pkg = tAddons[v]
		if not pkg.tAddon.bInit then
			if not InitAddon(pkg.tAddon, pkg.tParams) then return false end
		end
	end

	if tAddon.tSettings then
		local db = Core.db:RegisterNamespace(tAddon._NAME)
		db:RegisterDefaults(tAddon.tSettings)

		tAddon._DB = {
			profile = db.profile,
			global = db.global,
			char = db.char,
		}
	end

	if tAddon.OnDocLoaded then
		GeminiHook:PostHook(tAddon, "OnDocLoaded", function()
			tAddon:ForgeAPI_LoadSettings()
			tAddon:ForgeAPI_PopulateOptions()

			tAddon.bLoaded = true
		end)

		tAddon:ForgeAPI_Init()
	else
		tAddon:ForgeAPI_Init()
		tAddon:ForgeAPI_LoadSettings()
		tAddon:ForgeAPI_PopulateOptions()

		tAddon.bLoaded = true
	end

	tAddon.bInit = true

	return true
end

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

	-- new instance
	local addon = A:NewAddon(tAddon)

	local arDependencies = tParams and tParams.arDependencies or {}

	Apollo.RegisterAddon(tAddon, false, "", arDependencies)

	tAddons[addon._NAME] = {
		["tAddon"] = addon,
		["tParams"] = tParams or {},
		["arDependencies"] = arDependencies,
	}

	if bInit then
		InitAddon(addon, tParams)
	else
		table.insert(tPreloadAddons, tAddons[addon._NAME])
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
local function InitModule(tModule, tParams)
	if tModule.bInit then return true end

	if tModule.tSettings then
		local db = Core.db:RegisterNamespace(tModule._NAME)
		db:RegisterDefaults(tModule.tSettings)

		tModule._DB = {
			profile = db.profile,
			global = db.global,
			char = db.char,
		}
	end

	if tModule.OnDocLoaded then
		GeminiHook:PostHook(tModule, "OnDocLoaded", function()
			tModule:ForgeAPI_LoadSettings()
			tModule:ForgeAPI_PopulateOptions()

			tModule.bLoaded = true
		end)

		tModule:ForgeAPI_Init()
	else
		tModule:ForgeAPI_Init()
		tModule:ForgeAPI_LoadSettings()
		tModule:ForgeAPI_PopulateOptions()

		tModule.bLoaded = true
	end

	tModule.bInit = true

	return true
end

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

	-- new instance
	local module = M:NewModule(tModule)

	tModules[tModule._NAME] = {
		["tModule"] = module,
		["tParams"] = tParams or {},
	}

	if bInit then
		InitModule(tModule, tParams)
	else
		table.insert(tPreloadModules, tModules[tModule._NAME])
	end

	return module
end

function F:API_GetModule(strName)
	return tModules[strName].tModule
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
function F:API_GetNamespace(strName)
	return Core.db:GetNamespace(strName, true)
end

function F:API_GetProfileName() return Core.db:GetCurrentProfile() end
function F:API_ChangeProfile(...) Core.db:SetProfile(...) end
function F:API_CopyProfile(...) Core.db:CopyProfile(...) end
function F:API_RemoveProfile(...) Core.db:DeleteProfile(...) end
function F:API_NewProfile(...) Core.db:SetProfile(...) end
function F:API_ResetProfile(...) Core.db:ResetProfile(...) end

-- This fixes a problem of not seeing default profiles of other characters
-- function F:API_GetProfiles() return Core.db:GetProfiles() end
function F:API_GetProfiles()
	local tProfiles = Core.db:GetProfiles()

	for _, i in pairs(Core.db.sv.profileKeys) do
		local ok = true
		for _, j in pairs(tProfiles) do
			if i == j then ok = false end
		end
		if ok then table.insert(tProfiles, i) end
	end

	return tProfiles
end

function F:API_GetCoreDB() return Core._DB.profile end

function F:API_GetClassColor(unit)
	if type(unit) == "string" then
		return Core._DB.profile.tClassColors[GameLib.CodeEnumClass[unit]]
	else
		if not unit then return "FFFFFFFF" end
		if not Core._DB.profile.tClassColors then return "FFFFFFFF" end
		if unit:GetClassId() ~= 23 then
			return Core._DB.profile.tClassColors[unit:GetClassId()]
		else
			return Core._DB.profile.tDispositionColors[unit:GetDispositionTo(GameLib.GetPlayerUnit())]
		end
	end
end

function F:API_RegisterNamespaceDefaults(o, tDefaults)
	local db = Core.db:GetNamespace(o._NAME, true)
	db:RegisterDefaults(tDefaults)
end

function F:API_SendEvent(...) GeminiEvent.SendEvent(...) end
function F:API_UnregisterEvent(...) GeminiEvent.UnregisterEvent(...) end
function F:API_RegisterEvent(...) GeminiEvent.RegisterEvent(...) end

-----------------------------------------------------------------------------------------------
-- ForgeUI intern API
-----------------------------------------------------------------------------------------------
function F:Init()
	if bInit then return end
	bInit = true

	for _, pkg in ipairs(tPreloadModules) do
		InitModule(pkg.tModule, pkg.tParams)
	end
	tPreloadModules = {}

	for _, pkg in ipairs(tPreloadAddons) do
		InitAddon(pkg.tAddon, pkg.tParams)
	end
	tPreloadAddons = {}
end

function F:Save() RequestReloadUI() end
function F:Reset() Core.db:ResetDB() F:Save() end

-- helpers
function Core:CopyTable(src, dest)
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

function Core:TableConcat(t1, t2)
	for i = 1, #t2 do
		t1[#t1 + 1] = t2[i]
	end
	return t1
end

Core = F:API_NewModule(Core)
