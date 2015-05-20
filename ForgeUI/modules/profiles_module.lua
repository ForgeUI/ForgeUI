-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		profiles_module.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI profiles module for loading options into the main ForgeUI window
-----------------------------------------------------------------------------------------------

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local P = _G["ForgeLibs"]["ForgeProfiles"] -- ForgeProfiles
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI

-----------------------------------------------------------------------------------------------
-- ForgeUI Module Definition
-----------------------------------------------------------------------------------------------
local ProfilesModule = {
	NAME = "profiles_module",
	API_VERSION = 3,
}

-----------------------------------------------------------------------------------------------
-- Local variables
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- Module functions
-----------------------------------------------------------------------------------------------
function ProfilesModule:ForgeAPI_Init()
	F:API_AddMenuItem(self, "Profiles", "Profiles")
end

function ProfilesModule:ForgeAPI_PopulateOptions()
	local wndProfiles = self.tOptionHolders["Profiles"]
	
	G:API_AddText(self, wndProfiles, string.format("<T TextColor=\"%s\" Font=\"%s\">%s</T>", "FFFFFFFF", "Nameplates", "Current profile: ") .. string.format("<T TextColor=\"%s\" Font=\"%s\">%s</T>", "FFFF0000", "Nameplates", tostring(P:API_GetProfileName())))
	
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
	
	for k, v in pairs(P:API_GetProfiles()) do
		G:API_AddOptionToComboBox(self, wndCombo, k, k)
	end
	
	-- select profile
	local wndCombo = G:API_AddComboBox(tModule, wndProfiles, "Select profile", nil, nil, {
		fnCallback = self.OnSelectProfile,
		tWidths = { 200, 0 },
		tMove = { 0, 60 },
		bInnerText = true,
	})
	for k, v in pairs(P:API_GetProfiles()) do
		G:API_AddOptionToComboBox(self, wndCombo, k, k)
	end
end

function ProfilesModule:OnSelectProfile(strType, strKey, vValue)
	P:API_ChangeProfile(vValue)
end

function ProfilesModule:OnDeleteProfile(strType, strKey, vValue)
	P:API_RemoveProfile(vValue)
end

function ProfilesModule:OnNewProfile(strType, strKey, strValue)
	P:API_ChangeProfile(strValue)
end

ProfilesModule = F:API_NewModule(ProfilesModule)

