-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI_ProfileQuickPick
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
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
		
	    self.wndMain:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)


		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_ProfileQuickPick Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here


-----------------------------------------------------------------------------------------------
-- ForgeUI_ProfileQuickPickForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function ForgeUI_ProfileQuickPick:OnOK()
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function ForgeUI_ProfileQuickPick:OnCancel()
	self.wndMain:Close() -- hide the window
end


-----------------------------------------------------------------------------------------------
-- ForgeUI_ProfileQuickPick Instance
-----------------------------------------------------------------------------------------------
local ForgeUI_ProfileQuickPickInst = ForgeUI_ProfileQuickPick:new()
ForgeUI_ProfileQuickPickInst:Init()
