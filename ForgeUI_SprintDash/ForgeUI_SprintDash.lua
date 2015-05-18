----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI addon
--
-- name: 		ForgeUI_SprintDash.lua
-- author:		Winty Badass@Jabbit
-- about:		Sprint/Dash meter addon for ForgeUI
-----------------------------------------------------------------------------------------------

require "Window"

local F, A, M, G = unpack(_G["ForgeLibs"]) -- imports ForgeUI, Addon, Module, GUI

-----------------------------------------------------------------------------------------------
-- ForgeUI Addon Definition
-----------------------------------------------------------------------------------------------
local ForgeUI_SprintDash = {
    api_version = 3,
	author = "WintyBadass",
	strDisplayName = "Sprint / dash meter",
	
	settings_version = 1,
    tCharSettings = {
		bShowSprint = false,
		bShowDash = false,
		crBorder = "FF000000",
		crBackground = "FF101010",
		crSprint = "FFCCCCCC",
		crDash = "FF00AAFF",
		crDash2 = "FF003388",
	},
} 

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local sprintResource = 0
local dashResource = 7

-----------------------------------------------------------------------------------------------
-- ForgeAPI
-----------------------------------------------------------------------------------------------
function ForgeUI_SprintDash:ForgeAPI_Init()
	self.xmlDoc = XmlDoc.CreateFromFile("..//ForgeUI_SprintDash//ForgeUI_SprintDash.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	
	F:API_AddMenuItem(self, self.strDisplayName, "General")
end

function ForgeUI_SprintDash:ForgeAPI_PopulateOptions()
	local wndGeneral = self.tOptionHolders["General"]
	
	-- color boxes
	G:AddColorBox(self, wndGeneral, "Border color", self.tCharSettings, "crBorder")
	G:AddColorBox(self, wndGeneral, "Background color", self.tCharSettings, "crBackground", { tMove = { 0, 30 }})
	G:AddColorBox(self, wndGeneral, "Sprint color", self.tCharSettings, "crSprint", { tMove = { 0, 90 }, fnCallback = self.RefreshStyle_SprintBar })
	G:AddColorBox(self, wndGeneral, "Dash color", self.tCharSettings, "crDash", { tMove = { 0, 150 }})
	G:AddColorBox(self, wndGeneral, "Dash color (not full)", self.tCharSettings, "crDash2", { tMove = { 0, 180 }})
	
	-- check boxes
	G:AddCheckBox(self, wndGeneral, "Sprint meter permanently", self.tCharSettings, "bShowSprint", { tMove = { 205, 0 } })
	G:AddCheckBox(self, wndGeneral, "Dash meter permanently", self.tCharSettings, "bShowDash", { tMove = { 205, 30 } })
end

-----------------------------------------------------------------------------------------------
-- Addon functions
-----------------------------------------------------------------------------------------------
function ForgeUI_SprintDash:OnDocLoaded()
	if self.xmlDoc == nil and not self.xmlDoc:IsLoaded() then return end
	
	self.wndSprintMeter = Apollo.LoadForm(self.xmlDoc, "SprintMeter", nil, self)
	self.wndDashMeter = Apollo.LoadForm(self.xmlDoc, "DashMeter", nil, self)
	
	Apollo.RegisterEventHandler("VarChange_FrameCount", "OnNextFrame", self)
	
	self:RefreshStyle_SprintBar()
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
	local bShowSprint = not bSprintFull or self.tCharSettings.bShowSprint

	if bShowSprint then
		self.wndSprintMeter:FindChild("Bar"):SetMax(unitPlayer:GetMaxResource(sprintResource))
		self.wndSprintMeter:FindChild("Bar"):SetProgress(unitPlayer:GetResource(sprintResource))
	end
	
	if self.wndSprintMeter:IsShown() ~= bShowSprint then
		self.wndSprintMeter:Show(bShowSprint, true)
	end
	
	-- dash meter
	local nDashCurr = unitPlayer:GetResource(dashResource)
	local nDashMax = unitPlayer:GetMaxResource(dashResource)
	local bDashFull = nDashCurr == nDashMax or unitPlayer:IsDead()
	local bShowDash = not bDashFull or self.tCharSettings.bShowDash
	
	if bShowDash then
		if nDashCurr < 100 then
			self.wndDashMeter:FindChild("Bar_A"):SetMax(nDashMax / 2)
			self.wndDashMeter:FindChild("Bar_A"):SetProgress(nDashCurr)
			self.wndDashMeter:FindChild("Bar_A"):SetBarColor(self.tCharSettings.crBorder)
			
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
		
		self:RefreshStyle_DashBar(nDashCurr, nDashMax)
	end
	
	if self.wndDashMeter:IsShown() ~= bShowDash then
		self.wndDashMeter:Show(bShowDash, true)
	end
end

---------------------------------------------------------------------------------------------------
-- Styles
---------------------------------------------------------------------------------------------------
function ForgeUI_SprintDash:LoadStyle_SprintBar()
	
end

function ForgeUI_SprintDash:RefreshStyle_SprintBar()
	self.wndSprintMeter:FindChild("Bar"):SetBarColor(self.tCharSettings.crSprint)
end

function ForgeUI_SprintDash:LoadStyle_DashBar()
	
end

function ForgeUI_SprintDash:RefreshStyle_DashBar(nDashCurr, nDashMax)
	if nDashCurr < 100 then
		self.wndDashMeter:FindChild("Bar_A"):SetBarColor(self.tCharSettings.crDash2)
	elseif nDashCurr < nDashMax then
		self.wndDashMeter:FindChild("Bar_A"):SetBarColor(self.tCharSettings.crDash)
		self.wndDashMeter:FindChild("Bar_B"):SetBarColor(self.tCharSettings.crDash2)
	else
		self.wndDashMeter:FindChild("Bar_A"):SetBarColor(self.tCharSettings.crDash)
		self.wndDashMeter:FindChild("Bar_B"):SetBarColor(self.tCharSettings.crDash)
	end
end

-----------------------------------------------------------------------------------------------
-- ForgeUI addon registration
-----------------------------------------------------------------------------------------------
F:API_NewAddon(ForgeUI_SprintDash, "forgeui_sprintdash")
