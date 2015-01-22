require "Window"

local ForgeUI 
local ForgeUI_InfoBar = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------

 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function ForgeUI_InfoBar:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

     -- mandatory 
    self.api_version = 2
	self.version = "0.1.0"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_InfoBar"
	self.strDisplayName = "InfoBar"
	
	self.wndContainers = {}
	
	-- optional
	self.tSettings = {
	}

	self.stats = {}
	
	self.currentXP = 0
	self.neededXP = 0
	self.restedXP = 0
	self.currentPathXP = 0
	self.neededPathXP = 0
	
    return o
end

function ForgeUI_InfoBar:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"ForgeUI"
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- ForgeUI_InfoBar OnLoad
-----------------------------------------------------------------------------------------------
function ForgeUI_InfoBar:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("ForgeUI_InfoBar.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_InfoBar OnDocLoaded
-----------------------------------------------------------------------------------------------
function ForgeUI_InfoBar:OnDocLoaded()
	if self.xmlDoc == nil or not self.xmlDoc:IsLoaded() then return end

	if ForgeUI == nil then -- forgeui loaded
		ForgeUI = Apollo.GetAddon("ForgeUI")
	end
	
	ForgeUI.API_RegisterAddon(self)
end

function ForgeUI_InfoBar:ForgeAPI_AfterRegistration()
	self.unitPlayer = GameLib.GetPlayerUnit()

	self.wndInfoBar = Apollo.LoadForm(self.xmlDoc, "ForgeUI_InfoBar", "FixedHudStratumLow", self)
	ForgeUI.API_RegisterWindow(self, self.wndInfoBar, "ForgeUI_InfoBar", { strDisplayName = "Info bar", bSizable = false })
	
	Apollo.RegisterEventHandler("VarChange_FrameCount", "OnNextFrame", self)
end

function ForgeUI_InfoBar:OnNextFrame()
	self.stats = GameLib.GetPlayerUnit():GetBasicStats()
	if self.stats == nil then return end
	
	if self.stats.nLevel == 50 then
		self.currentXP = GetPeriodicElderPoints()
		self.neededXP = GameLib.ElderPointsDailyMax
	else
		self.currentXP = GetXp() - GetXpToCurrentLevel()
		self.neededXP = GetXpToNextLevel()
	end
	
	local nCurrentLevel = PlayerPathLib.GetPathLevel()
	local nNextLevel = math.min(30, nCurrentLevel + 1) -- TODO replace with variable

	local nLastLevelXP = PlayerPathLib.GetPathXPAtLevel(nCurrentLevel)
	self.currentPathXP =  PlayerPathLib.GetPathXP() - nLastLevelXP
	self.neededPathXP = PlayerPathLib.GetPathXPAtLevel(nNextLevel) - nLastLevelXP
	
	local framesPerSecond = ForgeUI.Round(GameLib.GetFrameRate(), 0)
	local latency = GameLib.GetLatency()

	self.wndInfoBar:FindChild("Level"):SetText(ForgeUI.Round(self.currentXP / self.neededXP * 100, 1) .. "% XP")
	self.wndInfoBar:FindChild("FPS"):SetText(framesPerSecond .. "fps")
	self.wndInfoBar:FindChild("MS"):SetText(latency .. "ms")
end

function ForgeUI_InfoBar:OnForgeButton( wndHandler, wndControl, eMouseButton )
	ForgeUI:OnForgeUIOn()
end

function ForgeUI_InfoBar:OnGenerateTooltip( wndHandler, wndControl, eToolTipType, x, y )
	local xml = nil

	if wndControl:GetName() == "Level" then
		xml = XmlDoc.new()
		xml:StartTooltip(1000)
		if self.stats.nLevel == 50 then
			xml:AddLine("EG: " .. math.floor(self.currentXP / 75000)) -- TODO replace with variable
		else
			xml:AddLine("XP: " .. ForgeUI.ShortNum(self.currentXP) .. "/" .. ForgeUI.ShortNum(self.neededXP) .. "         ", crWhite, "CRB_InterfaceMedium")
		end
		if self.neededPathXP ~= 0 then
			xml:AddLine("Path XP: " .. self.currentPathXP .. "/" .. self.neededPathXP .. " (" .. ForgeUI.Round(self.currentPathXP / self.neededPathXP, 1) .. "%)", crWhite, "CRB_InterfaceMedium")
		end
	end
	
	wndControl:SetTooltipDoc(xml)
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_Movables Functions
---------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- ForgeUI_InfoBar Instance
-----------------------------------------------------------------------------------------------
local ForgeUI_InfoBarInst = ForgeUI_InfoBar:new()
ForgeUI_InfoBarInst:Init()
