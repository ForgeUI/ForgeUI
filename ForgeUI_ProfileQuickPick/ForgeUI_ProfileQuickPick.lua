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
local ForgeUI_ProfileQuickPick = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function ForgeUI_ProfileQuickPick:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function ForgeUI_ProfileQuickPick:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- ForgeUI_ProfileQuickPick OnLoad
-----------------------------------------------------------------------------------------------
function ForgeUI_ProfileQuickPick:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("ForgeUI_ProfileQuickPick.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_ProfileQuickPick OnDocLoaded
-----------------------------------------------------------------------------------------------
function ForgeUI_ProfileQuickPick:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "ForgeUI_ProfileQuickPickForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
		self:LoadDropdown();
		
	    self.wndMain:Show(true, true)		
		
		ChatSystemLib.PostOnChannel(2, "0.1");
	end
end

function ForgeUI_ProfileQuickPick:LoadDropdown()

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

function ForgeUI_ProfileQuickPick:OnSelectProfile(vValue, strKey)
	F:API_ChangeProfile(vValue)
end

local ForgeUI_ProfileQuickPickInst = ForgeUI_ProfileQuickPick:new()
ForgeUI_ProfileQuickPickInst:Init()
