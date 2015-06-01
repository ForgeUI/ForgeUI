-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		profiles_module.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI module for providing profiles UI
-----------------------------------------------------------------------------------------------

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI

-----------------------------------------------------------------------------------------------
-- ForgeUI Module Definition
-----------------------------------------------------------------------------------------------
local ProfilesModule = {
	_NAME = "profiles_module",
	_API_VERSION = 3,
	_VERSION = "1.0",
}

-----------------------------------------------------------------------------------------------
-- Local variables
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- Module functions
-----------------------------------------------------------------------------------------------
function ProfilesModule:ForgeAPI_Init()
	F:API_AddMenuItem(self, "Profiles", "Profiles", { strPriority = "low" })
end

function ProfilesModule:ForgeAPI_PopulateOptions()
	local wndProfiles = self.tOptionHolders["Profiles"]

	G:API_AddText(self, wndProfiles, string.format("<T TextColor=\"%s\" Font=\"%s\">%s</T>", "FFFFFFFF", "Nameplates", "Current profile: ") .. string.format("<T TextColor=\"%s\" Font=\"%s\">%s</T>", "FFFF0000", "Nameplates", tostring(F:API_GetProfileName())))

	-- new profile
	G:API_EditBox(self, wndProfiles, "", nil, nil, {
		strHint = "New profile (enter to confirm)",
		tWidths = { 200, 0 },
		tMove = { 0, 120 },
		fnCallbackReturn = self.OnNewProfile,
	})

	-- delete profile
	local wndCombo = G:API_AddComboBox(tModule, wndProfiles, "Delete profile", nil, nil, {
		fnCallback = self.OnDeleteProfile,
		tWidths = { 200, 0 },
		tMove = { 205, 60 },
		bInnerText = true,
	})

	for k, v in pairs(F:API_GetProfiles()) do
		G:API_AddOptionToComboBox(self, wndCombo, v, v)
	end

	-- select profile
	local wndCombo = G:API_AddComboBox(tModule, wndProfiles, "Select profile", nil, nil, {
		fnCallback = self.OnSelectProfile,
		tWidths = { 200, 0 },
		tMove = { 0, 60 },
		bInnerText = true,
	})
	for k, v in pairs(F:API_GetProfiles()) do
		G:API_AddOptionToComboBox(self, wndCombo, v, v)
	end
end

function ProfilesModule:OnSelectProfile(vValue, strKey)
	F:API_ChangeProfile(vValue)
end

function ProfilesModule:OnDeleteProfile(vValue, strKey)
	F:API_RemoveProfile(vValue)
end

function ProfilesModule:OnNewProfile(strValue, strKey)
	F:API_NewProfile(strValue)
end

ProfilesModule = F:API_NewModule(ProfilesModule)
