-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI_ProfileQuickPick
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI


-----------------------------------------------------------------------------------------------
-- ForgeUI_ProfileQuickPick Module Definition
----------------------------------------------------------------------------------------------- 
local ForgeUI_ProfileQuickPick = {
	_NAME = "ForgeUI_ProfileQuickPick",
  	_API_VERSION = 3,
	_VERSION = "0.1",
	DISPLAY_NAME = "Profile quick pick",

	tSettings = {}	
	
}

function ForgeUI_ProfileQuickPick:ForgeAPI_Init()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("..//ForgeUI_ProfileQuickPick//ForgeUI_ProfileQuickPick.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

function ForgeUI_ProfileQuickPick:ForgeAPI_LoadSettings()
	--F:API_RegisterMover(self, self.wndMain, "Something here", "Profile picker", "general", { bNameAsTooltip = true})	
end

function ForgeUI_ProfileQuickPick:ForgeAPI_PopulateOptions()
end

function ForgeUI_ProfileQuickPick:OnDocLoaded()
	if self.xmlDoc == nil and not self.xmlDoc:IsLoaded() then return end

	self.wndMain = Apollo.LoadForm(self.xmlDoc, "PQPContainer", nil, self);
		
	self:LoadDropdown();
		
	self.wndMain:Show(true, true);
	
	ChatSystemLib.PostOnChannel(2, "Profilepicker loaded");
end

function ForgeUI_ProfileQuickPick:LoadDropdown()

	local wndCombo = G:API_AddComboBox(tModule, self.wndMain, "Select profile", nil, nil, {
		fnCallback = self.OnSelectProfile,
		tWidths = { 200, 0 },
tMove = { -3, -3 },
		bInnerText = true,
	})

	for k, v in pairs(F:API_GetProfiles()) do
		G:API_AddOptionToComboBox(self, wndCombo, v, v)
	end
	
	ChatSystemLib.PostOnChannel(2, "Combobox loaded");

	
end

function ForgeUI_ProfileQuickPick:OnSelectProfile(vValue, strKey)
	F:API_ChangeProfile(vValue)
end

--local ForgeUI_ProfileQuickPickInst = ForgeUI_ProfileQuickPick:new()
--ForgeUI_ProfileQuickPickInst:Init()
F:API_NewAddon(ForgeUI_ProfileQuickPick);
