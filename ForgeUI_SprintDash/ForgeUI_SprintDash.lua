require "Window"
 
local ForgeUI_SprintDash = {} 

local sprintResource = 0
local dashResource = 7

function ForgeUI_SprintDash:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- mandatory 
    self.api_version = 1
	self.version = "0.1.0"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_SprintDash"
	self.strDisplayName = "Sprint / dash meter"
	
	self.wndContainers = {}
	
	-- optional
	self.settings_version = 1
    self.tSettings = {
		bShowSprint = false,
		bShowDash = false,
		crSprint = "FFCCCCCC",
		crDash = "FF00AAFF",
		crDash2 = "FF003388"
	}

    return o
end

function ForgeUI_SprintDash:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"ForgeUI"
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

function ForgeUI_SprintDash:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("ForgeUI_SprintDash.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

function ForgeUI_SprintDash:OnDocLoaded()
	if self.xmlDoc == nil and not self.xmlDoc:IsLoaded() then return end
	
	if ForgeUI == nil then -- forgeui loaded
		ForgeUI = Apollo.GetAddon("ForgeUI")
	end
	
	ForgeUI.RegisterAddon(self)
	
	Apollo.RegisterEventHandler("VarChange_FrameCount", "OnNextFrame", self)
end

-------------------------------------------------------------------------------
-- ForgeAPI
-------------------------------------------------------------------------------
function ForgeUI_SprintDash:ForgeAPI_AfterRegistration()
	ForgeUI.AddItemButton(self, "Sprint / dash meter", "Container")

	self.wndSprintMeter = Apollo.LoadForm(self.xmlDoc, "SprintMeter", "InWorldHudStratum", self)
	self.wndDashMeter = Apollo.LoadForm(self.xmlDoc, "DashMeter", "InWorldHudStratumHigh", self)
	self.wndDashMeter:FindChild("DashMeter_B"):SetSprite("ForgeUI_Sprite:ForgeUI_Border")
	
	-- movables
	self.wndMovables = Apollo.LoadForm(self.xmlDoc, "Movables", nil, self)
end

function ForgeUI_SprintDash:ForgeAPI_AfterRestore()
	ForgeUI.RegisterWindowPosition(self, self.wndSprintMeter, "ForgeUI_SprintDash_Sprint", self.wndMovables:FindChild("Movable_SprintMeter"))
	ForgeUI.RegisterWindowPosition(self, self.wndDashMeter, "ForgeUI_SprintDash_Dash", self.wndMovables:FindChild("Movable_DashMeter"))

	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("crSprint"), self.tSettings, "crSprint", true)
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("crDash"), self.tSettings, "crDash", true)
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("crDash2"), self.tSettings, "crDash2", true)
	
	self.wndContainers.Container:FindChild("bShowSprint"):SetCheck(self.tSettings.bShowSprint)
	self.wndContainers.Container:FindChild("bShowDash"):SetCheck(self.tSettings.bShowDash)
end

-------------------------------------------------------------------------------
-- Event handlers
-------------------------------------------------------------------------------
function ForgeUI_SprintDash:OnNextFrame()
	local unitPlayer = GameLib.GetPlayerUnit()	
    if unitPlayer == nil then return end
	
	-- sprint meter
	local nSprintCurr = unitPlayer:GetResource(sprintResource)
	local nSprintMax = unitPlayer:GetMaxResource(sprintResource)
	local bSprintFull = nSprintCurr == nSprintMax or unitPlayer:IsDead()
	local bShowSprint = not bSprintFull or self.tSettings.bShowSprint

	if bShowSprint then
		self.wndSprintMeter:FindChild("Bar"):SetMax(unitPlayer:GetMaxResource(sprintResource))
		self.wndSprintMeter:FindChild("Bar"):SetProgress(unitPlayer:GetResource(sprintResource))
		self.wndSprintMeter:FindChild("Bar"):SetBarColor(ApolloColor.new("ff" .. self.tSettings.crSprint))
	end
	
	if self.wndSprintMeter:IsShown() ~= bShowSprint then
		self.wndSprintMeter:Show(bShowSprint, true)
	end
	
	-- dash meter
	local nDashCurr = unitPlayer:GetResource(dashResource)
	local nDashMax = unitPlayer:GetMaxResource(dashResource)
	local bDashFull = nDashCurr == nDashMax or unitPlayer:IsDead()
	local bShowDash = not bDashFull or self.tSettings.bShowDash
	
	if bShowDash then
		if nDashCurr < 100 then
			self.wndDashMeter:FindChild("Bar_A"):SetMax(unitPlayer:GetMaxResource(dashResource) / 2)
			self.wndDashMeter:FindChild("Bar_A"):SetProgress(unitPlayer:GetResource(dashResource))
			self.wndDashMeter:FindChild("Bar_A"):SetBarColor(ApolloColor.new(self.tSettings.crDash))
			
			self.wndDashMeter:FindChild("Bar_B"):SetProgress(0)
		elseif nDashCurr < nDashMax then
			self.wndDashMeter:FindChild("Bar_B"):SetMax(unitPlayer:GetMaxResource(dashResource) / 2)
			self.wndDashMeter:FindChild("Bar_B"):SetProgress(unitPlayer:GetResource(dashResource) - (unitPlayer:GetMaxResource(dashResource) / 2))
			self.wndDashMeter:FindChild("Bar_B"):SetBarColor(ApolloColor.new(self.tSettings.crDash2))
			
			self.wndDashMeter:FindChild("Bar_A"):SetMax(unitPlayer:GetMaxResource(dashResource) / 2)
			self.wndDashMeter:FindChild("Bar_A"):SetProgress(unitPlayer:GetMaxResource(dashResource) / 2)
			self.wndDashMeter:FindChild("Bar_A"):SetBarColor(ApolloColor.new(self.tSettings.crDash))
		else
			self.wndDashMeter:FindChild("Bar_B"):SetMax(unitPlayer:GetMaxResource(dashResource) / 2)
			self.wndDashMeter:FindChild("Bar_B"):SetProgress(unitPlayer:GetResource(dashResource) - (unitPlayer:GetMaxResource(dashResource) / 2))
			self.wndDashMeter:FindChild("Bar_B"):SetBarColor(ApolloColor.new(self.tSettings.crDash))
			
			self.wndDashMeter:FindChild("Bar_A"):SetMax(unitPlayer:GetMaxResource(dashResource) / 2)
			self.wndDashMeter:FindChild("Bar_A"):SetProgress(unitPlayer:GetMaxResource(dashResource) / 2)
			self.wndDashMeter:FindChild("Bar_A"):SetBarColor(ApolloColor.new(self.tSettings.crDash))
		end		
	end
	
	if self.wndDashMeter:IsShown() ~= bShowDash then
		self.wndDashMeter:Show(bShowDash, true)
	end
end

---------------------------------------------------------------------------------------------------
-- Movables Functions
---------------------------------------------------------------------------------------------------

function ForgeUI_SprintDash:OnMovableMove( wndHandler, wndControl, nOldLeft, nOldTop, nOldRight, nOldBottom )
	self.wndSprintMeter:MoveToLocation(self.wndMovables:FindChild("Movable_SprintMeter"):GetLocation())
	self.wndDashMeter:MoveToLocation(self.wndMovables:FindChild("Movable_DashMeter"):GetLocation())
end

function ForgeUI_SprintDash:OnOptionsChanged( wndHandler, wndControl )
	local strType = wndControl:GetParent():GetName()
	
	if strType == "ColorBox" then
		ForgeUI.ColorBoxChange(self, wndControl, self.tSettings, wndControl:GetName())
	end
	
	if strType == "CheckBox" then
		self.tSettings[wndControl:GetName()] = wndControl:IsChecked()
	end
end

---------------------------------------------------------------------------------------------------
-- Container Functions
---------------------------------------------------------------------------------------------------
local ForgeUI_SprintDashInst = ForgeUI_SprintDash:new()
ForgeUI_SprintDashInst:Init()
