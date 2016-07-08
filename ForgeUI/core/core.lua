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
local tAddons = {}
local bInit = false
local bResetSettings = false

-----------------------------------------------------------------------------------------------
-- ForgeUI module functions
-----------------------------------------------------------------------------------------------
function Core:ForgeAPI_PreInit()
	local ForgeUI = Apollo.GetAddon("ForgeUI")

	self.db = GeminiDB:New(ForgeUI)
end

function Core:ForgeAPI_Init()
	Print("ForgeUI v" .. F:API_GetVersion() .. " has been loaded")

	GeminiHook:Embed(F)
end

-----------------------------------------------------------------------------------------------
-- ForgeUI public API
--
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

	-- new instance
	local addon = A:NewAddon(tAddon)

	if bInit and addon.tSettings then
		local db = Core.db:RegisterNamespace(addon._NAME)
		db:RegisterDefaults(addon.tSettings)

		addon._DB = {
			profile = db.profile,
			global = db.global,
			char = db.char,
		}
	end

	-- db callbacks
	Core.db.RegisterCallback(addon, "OnProfileChanged", "RefreshConfig")
	Core.db.RegisterCallback(addon, "OnProfileDeleted", "RefreshConfig")
	Core.db.RegisterCallback(addon, "OnProfileReset", "RefreshConfig")
	Core.db.RegisterCallback(addon, "OnProfileCopied", "RefreshConfig")

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
			addon:ForgeAPI_LoadSettings()
			--local bSucces, sErrMsg = pcall(addon.ForgeAPI_LoadSettings, addon)
			--if not bSucces then Print(sErrMsg) end

			addon:ForgeAPI_PopulateOptions()
			--local bSucces, sErrMsg = pcall(addon.ForgeAPI_PopulateOptions, addon)
			--if not bSucces then Print(sErrMsg) end

			addon.bLoaded = true
		end)
		tAddons[tAddon._NAME].bHooked = true
	elseif bInit then
		addon:ForgeAPI_LoadSettings()
		--local bSucces, sErrMsg = pcall(addon.ForgeAPI_LoadSettings, addon)
		--if not bSucces then Print(sErrMsg) end

		addon:ForgeAPI_PopulateOptions()
		--local bSucces, sErrMsg = pcall(addon.ForgeAPI_PopulateOptions, addon)
		--if not bSucces then Print(sErrMsg) end

		addon.bLoaded = true
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

	-- new instance
	local module = M:NewModule(tModule)

	if bInit and module.tSettings then
		local db = Core.db:RegisterNamespace(module._NAME)
		db:RegisterDefaults(module.tSettings)

		module._DB = {
			profile = db.profile,
			global = db.global,
			char = db.char,
		}
	end

	-- db callbacks
	Core.db.RegisterCallback(module, "OnProfileChanged", "RefreshConfig")
	Core.db.RegisterCallback(module, "OnProfileDeleted", "RefreshConfig")
	Core.db.RegisterCallback(module, "OnProfileReset", "RefreshConfig")
	Core.db.RegisterCallback(module, "OnProfileCopied", "RefreshConfig")

	tModules[tModule._NAME] = {
        ["tModule"] = module,
        ["tParams"] = tParams or {},
    }

	if bInit and module.ForgeAPI_Init then
		module:ForgeAPI_Init()
		module.bInit = true
	end

	if module.OnDocLoaded then
		GeminiHook:PostHook(module, "OnDocLoaded", function()
			module:ForgeAPI_LoadSettings()
			--local bSucces, sErrMsg = pcall(module.ForgeAPI_LoadSettings, module)
			--if not bSucces then Print(sErrMsg) end

			module:ForgeAPI_PopulateOptions()
			--local bSucces, sErrMsg = pcall(module.ForgeAPI_PopulateOptions, module)
			--if not bSucces then Print(sErrMsg) end
		end)
		tModules[tModule._NAME].bHooked = true
	elseif bInit then
		module:ForgeAPI_LoadSettings()
		--local bSucces, sErrMsg = pcall(module.ForgeAPI_LoadSettings, module)
		--if not bSucces then Print(sErrMsg) end

		module:ForgeAPI_PopulateOptions()
		--local bSucces, sErrMsg = pcall(module.ForgeAPI_PopulateOptions, module)
		--if not bSucces then Print(sErrMsg) end
	end

	return module
end

function F:API_GetModule(strName)
    if tModules[strName] and not tModules[strName].tParams.bPrivate then
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
function F:API_GetNamespace(strName)
	return Core.db:GetNamespace(strName, true)
end

function F:API_GetProfileName() return Core.db:GetCurrentProfile() end
function F:API_GetProfiles() return Core.db:GetProfiles() end
function F:API_ChangeProfile(...) Core.db:SetProfile(...) end
function F:API_CopyProfile(...) Core.db:CopyProfile(...) end
function F:API_RemoveProfile(...) Core.db:DeleteProfile(...) end
function F:API_NewProfile(...) Core.db:SetProfile(...) end
function F:API_ResetProfile(...) Core.db:ResetProfile(...) end

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
			if v.tModule.tSettings then
				local db = Core.db:RegisterNamespace(v.tModule._NAME)
				db:RegisterDefaults(v.tModule.tSettings)

				v.tModule._DB = {
					profile = db.profile,
					global = db.global,
					char = db.char,
				}
			end

			v.tModule:ForgeAPI_Init()
			v.tModule.bInit = true

			if not v.bHooked then
				v.tModule:ForgeAPI_LoadSettings()
				--local bSucces, sErrMsg = pcall(v.tModule.ForgeAPI_LoadSettings, v.tModule)
				--if not bSucces then Print(sErrMsg) end

				v.tModule:ForgeAPI_PopulateOptions()
				--local bSucces, sErrMsg = pcall(v.tModule.ForgeAPI_PopulateOptions, v.tModule)
				--if not bSucces then Print(sErrMsg) end
			end
		end
	end

	for k, v in pairs(tAddons) do
		if not v.tAddon.ForgeAPI_Init then
			Print("ERR: " .. k .. " addon cannot be loaded!")
		else
			if v.tAddon.tSettings then
				local db = Core.db:RegisterNamespace(v.tAddon._NAME)
				db:RegisterDefaults(v.tAddon.tSettings)

				v.tAddon._DB = {
					profile = db.profile,
					global = db.global,
					char = db.char,
				}
			end

			v.tAddon:ForgeAPI_Init(v.tAddon)
			v.tAddon.bInit = true

			if not v.bHooked then
				v.tAddon:ForgeAPI_LoadSettings()
				--local bSucces, sErrMsg = pcall(v.tAddon.ForgeAPI_LoadSettings, v.tAddon)
				--if not bSucces then Print(sErrMsg) end

				v.tAddon:ForgeAPI_PopulateOptions()
				--local bSucces, sErrMsg = pcall(v.tAddon.ForgeAPI_PopulateOptions, v.tAddon)
				--if not bSucces then Print(sErrMsg) end

				v.tAddon.bLoaded = true
			end
		end
	end
end

function F:Save() RequestReloadUI() end
function F:Reset() Core.db:ResetDB() F:Save() end

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

Core = F:API_NewModule(Core, { bPrivate = true })
