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
    self.api_version = 1
	self.version = "0.1.0"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_InfoBar"
	self.strDisplayName = "InfoBar"
	
	self.wndContainers = {}
	
	-- optional
	self.tSettings = {
	}

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

function ForgeUI_InfoBar:OnForgeButton( wndHandler, wndControl, eMouseButton )
	ForgeUI:OnForgeUIOn()
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_InfoBar OnDocLoaded
-----------------------------------------------------------------------------------------------
function ForgeUI_InfoBar:OnDocLoaded()
	if self.xmlDoc == nil or not self.xmlDoc:IsLoaded() then return end

	if ForgeUI == nil then -- forgeui loaded
		ForgeUI = Apollo.GetAddon("ForgeUI")
	end
	
	ForgeUI.RegisterAddon(self)
end

function ForgeUI_InfoBar:ForgeAPI_AfterRegistration()
	self.unitPlayer = GameLib.GetPlayerUnit()

	self.wndInfoBar = Apollo.LoadForm(self.xmlDoc, "ForgeUI_InfoBar", "FixedHudStratumLow", self)
	self.wndMovables = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Movables", nil, self)
	
	Apollo.RegisterEventHandler("VarChange_FrameCount", "OnNextFrame", self)
end

function ForgeUI_InfoBar:ForgeAPI_AfterRestore()
	ForgeUI.RegisterWindowPosition(self, self.wndInfoBar, "ForgeUI_InfoBar", self.wndMovables:FindChild("Movable_InfoBar"))
end

function ForgeUI_InfoBar:OnNextFrame()
	local stats = GameLib.GetPlayerUnit():GetBasicStats()
	if stats == nil then return end
	local currentXP = GetXp()
	local neededXP = GetXpToNextLevel()
	local elderXP = GetPeriodicElderPoints()
	local xpPercent = stats.nLevel == 50 and math.floor(elderXP / 10500000 * 100) or math.floor(currentXP / neededXP * 100)
	local framesPerSecond = ForgeUI.Round(GameLib.GetFrameRate(), 0)
	local latency = GameLib.GetLatency()

	self.wndInfoBar:FindChild("Level"):SetText(xpPercent .. "%")
	self.wndInfoBar:FindChild("FPS"):SetText(framesPerSecond .. "fps")
	self.wndInfoBar:FindChild("MS"):SetText(latency .. "ms")
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_Movables Functions
---------------------------------------------------------------------------------------------------

function ForgeUI_InfoBar:OnMovableMove( wndHandler, wndControl, nOldLeft, nOldTop, nOldRight, nOldBottom )
	self.wndInfoBar:SetAnchorOffsets(self.wndMovables:FindChild("Movable_InfoBar"):GetAnchorOffsets())
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_InfoBar Instance
-----------------------------------------------------------------------------------------------
local ForgeUI_InfoBarInst = ForgeUI_InfoBar:new()
ForgeUI_InfoBarInst:Init()
