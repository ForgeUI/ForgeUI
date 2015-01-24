require "Window"
 
local ForgeUI_SprintDash = {} 

local sprintResource = 0
local dashResource = 7

function ForgeUI_SprintDash:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- mandatory 
    self.api_version = 2
	self.version = "1.0.0"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_SprintDash"
	self.strDisplayName = "Sprint / dash meter"
	
	self.wndContainers = {}
	
	self.tStylers = {
		["LoadStyle_SprintBar"] = self,
		["RefreshStyle_SprintBar"] = self,
		["LoadStyle_DashBar"] = self,
		["RefreshStyle_DashBar"] = self,
	}
	
	-- optional
	self.settings_version = 1
    self.tSettings = {
		bShowSprint = false,
		bShowDash = false,
		crBorder = "FF000000",
		crBackground = "FFFF101010",
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
	
	ForgeUI.API_RegisterAddon(self)
	
	Apollo.RegisterEventHandler("VarChange_FrameCount", "OnNextFrame", self)
end

-------------------------------------------------------------------------------
-- ForgeAPI
-------------------------------------------------------------------------------
function ForgeUI_SprintDash:ForgeAPI_AfterRegistration()
	ForgeUI.API_AddItemButton(self, "Sprint / dash meter", { strContainer = "Container" })

	self.wndSprintMeter = Apollo.LoadForm(self.xmlDoc, "SprintMeter", ForgeUI.HudStratum0, self)
	ForgeUI.API_RegisterWindow(self, self.wndSprintMeter, "ForgeUI_SprintMeter")
	self.wndDashMeter = Apollo.LoadForm(self.xmlDoc, "DashMeter", ForgeUI.HudStratum0, self)
	ForgeUI.API_RegisterWindow(self, self.wndDashMeter, "ForgeUI_DashMeter")
end

function ForgeUI_SprintDash:ForgeAPI_AfterRestore()
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("crSprint"), self.tSettings, "crSprint", false, "LoadStyle_SprintBar" )
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("crDash"), self.tSettings, "crDash", false)
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("crDash2"), self.tSettings, "crDash2", false)
	
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers.Container:FindChild("bShowSprint"), self.tSettings, "bShowSprint")
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers.Container:FindChild("bShowDash"), self.tSettings, "bShowDash")
	
	self.tStylers["LoadStyle_SprintBar"]["LoadStyle_SprintBar"](self)
	self.tStylers["LoadStyle_DashBar"]["LoadStyle_DashBar"](self)
end

function ForgeUI_SprintDash:Test()
	Print("LOL")
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
		
		self.tStylers["RefreshStyle_SprintBar"]["RefreshStyle_SprintBar"](self)
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
			self.wndDashMeter:FindChild("Bar_A"):SetMax(nDashMax / 2)
			self.wndDashMeter:FindChild("Bar_A"):SetProgress(nDashCurr)
			
			self.wndDashMeter:FindChild("Bar_B"):SetProgress(0)
		elseif nDashCurr < nDashMax then
			self.wndDashMeter:FindChild("Bar_B"):SetMax(nDashMax / 2)
			self.wndDashMeter:FindChild("Bar_B"):SetProgress(nDashCurr - nDashMax / 2)
			
			self.wndDashMeter:FindChild("Bar_A"):SetMax(nDashMax / 2)
			self.wndDashMeter:FindChild("Bar_A"):SetProgress(nDashMax / 2)
		else
			self.wndDashMeter:FindChild("Bar_B"):SetMax(nDashMax / 2)
			self.wndDashMeter:FindChild("Bar_B"):SetProgress(nDashCurr - nDashMax / 2)
			
			self.wndDashMeter:FindChild("Bar_A"):SetMax(nDashMax / 2)
			self.wndDashMeter:FindChild("Bar_A"):SetProgress(nDashMax / 2)
		end	
		
		self.tStylers["RefreshStyle_DashBar"]["RefreshStyle_DashBar"](self, nDashCurr, nDashMax)
	end
	
	if self.wndDashMeter:IsShown() ~= bShowDash then
		self.wndDashMeter:Show(bShowDash, true)
	end
end

---------------------------------------------------------------------------------------------------
-- Styles
---------------------------------------------------------------------------------------------------

function ForgeUI_SprintDash:LoadStyle_SprintBar()
	self.wndSprintMeter:FindChild("Bar"):SetBarColor(self.tSettings.crSprint)
end

function ForgeUI_SprintDash:RefreshStyle_SprintBar()

end

function ForgeUI_SprintDash:LoadStyle_DashBar()
	
end

function ForgeUI_SprintDash:RefreshStyle_DashBar(nDashCurr, nDashMax)
	if nDashCurr < 100 then
		self.wndDashMeter:FindChild("Bar_A"):SetBarColor(self.tSettings.crDash2)
	elseif nDashCurr < nDashMax then
		self.wndDashMeter:FindChild("Bar_A"):SetBarColor(self.tSettings.crDash)
		self.wndDashMeter:FindChild("Bar_B"):SetBarColor(self.tSettings.crDash2)
	else
		self.wndDashMeter:FindChild("Bar_A"):SetBarColor(self.tSettings.crDash)
		self.wndDashMeter:FindChild("Bar_B"):SetBarColor(self.tSettings.crDash)
	end
end

---------------------------------------------------------------------------------------------------
-- Container Functions
---------------------------------------------------------------------------------------------------
local ForgeUI_SprintDashInst = ForgeUI_SprintDash:new()
ForgeUI_SprintDashInst:Init()
