----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI addon
--
-- name: 		ForgeUI_SprintDash.lua
-- author:		Winty Badass@Jabbit
-- about:		Sprint/Dash meter addon for ForgeUI
-----------------------------------------------------------------------------------------------

require "Window"

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI

-----------------------------------------------------------------------------------------------
-- ForgeUI Addon Definition
-----------------------------------------------------------------------------------------------
local ForgeUI_SprintDash = {
	_NAME = "ForgeUI_SprintDash",
  _API_VERSION = 3,
	_VERSION = "2.0",
	DISPLAY_NAME = "Sprint & Dash",

	tSettings = {
		profile = {
			bShowSprint = false,
			bShowDash = false,
			crBorder = "FF000000",
			crBackground = "FF101010",
			crSprint = "FFCCCCCC",
			crDash = "FF00AAFF",
			crDash2 = "FF003388",
		}
	}
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

	F:API_AddMenuItem(self, "Sprint & dash", "General")
end

function ForgeUI_SprintDash:ForgeAPI_LoadSettings()
	self.wndSprintMeter:FindChild("Bar"):SetBarColor(self._DB.profile.crSprint)

	F:API_RegisterMover(self, self.wndSprintMeter, "SprintDash_Sprint", "Sprint", "general", { bNameAsTooltip = true})
	F:API_RegisterMover(self, self.wndDashMeter, "SprintDash_Dash", "Dash", "general", { bNameAsTooltip = true})
end

function ForgeUI_SprintDash:ForgeAPI_PopulateOptions()
	local wndGeneral = self.tOptionHolders["General"]

	-- color boxes
	G:API_AddColorBox(self, wndGeneral, "Border color", self._DB.profile, "crBorder")
	G:API_AddColorBox(self, wndGeneral, "Background color", self._DB.profile, "crBackground", { tMove = { 0, 30 }})
	G:API_AddColorBox(self, wndGeneral, "Sprint color", self._DB.profile, "crSprint", { tMove = { 0, 90 }, fnCallback = self.RefreshStyle_SprintBar })
	G:API_AddColorBox(self, wndGeneral, "Dash color", self._DB.profile, "crDash", { tMove = { 0, 150 }})
	G:API_AddColorBox(self, wndGeneral, "Dash color (not full)", self._DB.profile, "crDash2", { tMove = { 0, 180 }})

	-- check boxes
	G:API_AddCheckBox(self, wndGeneral, "Sprint meter permanently", self._DB.profile, "bShowSprint", { tMove = { 205, 0 } })
	G:API_AddCheckBox(self, wndGeneral, "Dash meter permanently", self._DB.profile, "bShowDash", { tMove = { 205, 30 } })
end

-----------------------------------------------------------------------------------------------
-- Addon functions
-----------------------------------------------------------------------------------------------
function ForgeUI_SprintDash:OnDocLoaded()
	if self.xmlDoc == nil and not self.xmlDoc:IsLoaded() then return end

	self.wndSprintMeter = Apollo.LoadForm(self.xmlDoc, "SprintMeter", F.tOverlays.HudHigh, self)
	self.wndDashMeter = Apollo.LoadForm(self.xmlDoc, "DashMeter", F.tOverlays.HudHigh, self)

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
	local bShowSprint = (not bSprintFull or self._DB.profile.bShowSprint) and not F:API_MoversActive()

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
	local bShowDash = (not bDashFull or self._DB.profile.bShowDash) and not F:API_MoversActive()

	if bShowDash then
		if nDashCurr < 100 then
			self.wndDashMeter:FindChild("Bar_A"):SetMax(nDashMax / 2)
			self.wndDashMeter:FindChild("Bar_A"):SetProgress(nDashCurr)
			self.wndDashMeter:FindChild("Bar_A"):SetBarColor(self._DB.profile.crBorder)

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
	self.wndSprintMeter:FindChild("Bar"):SetBarColor(self._DB.profile.crSprint)
end

function ForgeUI_SprintDash:LoadStyle_DashBar()

end

function ForgeUI_SprintDash:RefreshStyle_DashBar(nDashCurr, nDashMax)
	if nDashCurr < 100 then
		self.wndDashMeter:FindChild("Bar_A"):SetBarColor(self._DB.profile.crDash2)
	elseif nDashCurr < nDashMax then
		self.wndDashMeter:FindChild("Bar_A"):SetBarColor(self._DB.profile.crDash)
		self.wndDashMeter:FindChild("Bar_B"):SetBarColor(self._DB.profile.crDash2)
	else
		self.wndDashMeter:FindChild("Bar_A"):SetBarColor(self._DB.profile.crDash)
		self.wndDashMeter:FindChild("Bar_B"):SetBarColor(self._DB.profile.crDash)
	end
end

-----------------------------------------------------------------------------------------------
-- ForgeUI addon registration
-----------------------------------------------------------------------------------------------
F:API_NewAddon(ForgeUI_SprintDash)
