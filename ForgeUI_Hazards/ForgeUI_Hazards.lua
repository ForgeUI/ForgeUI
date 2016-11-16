----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI addon
--
-- name: 		ForgeUI_Hazards.lua
-- author:		Winty Badass@Jabbit
-- about:		Hazrds frames addon for ForgeUI
-----------------------------------------------------------------------------------------------

require "Window"
require "HazardsLib"

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI

local Util = F:API_GetModule("util")

-----------------------------------------------------------------------------------------------
-- ForgeUI Addon Definition
-----------------------------------------------------------------------------------------------
local ForgeUI_Hazards = {
	_NAME = "ForgeUI_Hazards",
	_API_VERSION = 3,
	_VERSION = "2.0",
	DISPLAY_NAME = "Hazards",

	tSettings = {
		profile = {
			tHazards = {
				["Default"] = { strName = "Unknown", nMin = 0, crBar = "FFFFFFFF" },
				[HazardsLib.HazardType_Radiation] = { strName = "Radiation", nMin = 0, crBar = "FF25F400" },
				[HazardsLib.HazardType_Temperature] = { strName = "Temperature", nMin = 0, crBar = "FFF40000" },
				[HazardsLib.HazardType_Proximity] = { strName = "Proximity", nMin = 0, crBar = "FFFF9900" },
				[HazardsLib.HazardType_Timer] = { strName = "Timer", nMin = 0, crBar = "FFFF9900" },
				[HazardsLib.HazardType_Breath] = { strName = "Breath", nMin = 0, crBar = "FF1591DB" },
			}
		}
	},

	tHazards = {},
	tQueuedHazards = {},
}

-----------------------------------------------------------------------------------------------
-- ForgeAPI
-----------------------------------------------------------------------------------------------
function ForgeUI_Hazards:ForgeAPI_PreInit()
	Apollo.RegisterEventHandler("BreathChanged", "OnBreathChanged", self)
	Apollo.RegisterEventHandler("HazardEnabled", "OnHazardEnable", self)
	Apollo.RegisterEventHandler("HazardRemoved", "OnHazardRemove", self)
	Apollo.RegisterEventHandler("HazardUpdated", "OnHazardsUpdated", self)
end

function ForgeUI_Hazards:ForgeAPI_Init()
	self.xmlDoc = XmlDoc.CreateFromFile("..//ForgeUI_Hazards//ForgeUI_Hazards.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

function ForgeUI_Hazards:OnDocLoaded()
	self.wndHazardsHolder = Apollo.LoadForm(self.xmlDoc, "HazardsHolder", F:API_GetStratum("Hud"), self)
	F:API_RegisterMover(self, self.wndHazardsHolder, "Hazards", "Hazards", "misc", {})

	for k, v in pairs(self.tQueuedHazards) do
		self:CreateHazard(k, v.strName, v.nMin, v.nMax, v.crBar, v.tOptions)
	end
	self.tQueuedHazards = {}
end

-------------------------------------------------------------------------------
-- Hazard functions
-------------------------------------------------------------------------------
function ForgeUI_Hazards:CreateHazard(nID, strName, nMin, nMax, crBar, tOptions)
	if not self.wndHazardsHolder then
		self.tQueuedHazards[nID] = {
			strName = strName,
			nMin = nMin,
			nMax = nMax,
			crBar = crBar,
			tOptions = tOptions,
		}

		return
	end

	if self.tHazards[nID] ~= nil then
		self:RemoveHazard(nID)
	end

	local wndNewHazard = Apollo.LoadForm(self.xmlDoc, "Hazard", self.wndHazardsHolder, self)

	wndNewHazard:FindChild("ProgressBar"):SetFloor(nMin)
	wndNewHazard:FindChild("ProgressBar"):SetMax(nMax)
	wndNewHazard:FindChild("ProgressBar"):SetBarColor(crBar)
	wndNewHazard:FindChild("Text"):SetText(strName)

	if tOptions then
		if tOptions.strTooltip then
			wndNewHazard:SetTooltip(tOptions.strTooltip)
		end
	end

	local tData = {
		nID = nID,
		strName = strName,
		nMin = nMin,
		nMax = nMax,
		crBar = crBar,
		tOptions = tOptions
	}

	wndNewHazard:SetData(tData)

	self.tHazards[nID] = wndNewHazard

	self.wndHazardsHolder:ArrangeChildrenHorz(1)
end

function ForgeUI_Hazards:UpdateHazard(nID, tOptions)
	if not self.wndHazardsHolder then return end

	local wndHazard = self.tHazards[nID]

	if not tOptions then return end

	if tOptions.nValue then
		wndHazard:FindChild("ProgressBar"):SetProgress(tOptions.nValue)
		--wndHazard:FindChild("Text"):SetText(wndHazard:GetData().strName .. " - " .. Util.Round((tOptions.nValue / wndHazard:GetData().nMax) * 100, 0))
		wndHazard:FindChild("Text"):SetText(wndHazard:GetData().strName .. " - " .. Util:Round(tOptions.nValue, 0))
	end

	if tOptions.strTooltip then
		wndHazard:SetTooltip(tOptions.strTooltip)
	end
end

function ForgeUI_Hazards:RemoveHazard(nID)
	if self.tHazards[nID] and self.tHazards[nID].Destroy then
		self.tHazards[nID]:Destroy()
	end
	self.tHazards[nID] = nil

	self.wndHazardsHolder:ArrangeChildrenHorz(1)
end

-------------------------------------------------------------------------------
-- Event handlers
-------------------------------------------------------------------------------
function ForgeUI_Hazards:OnBreathChanged(nBreath)
	local idHazard = -1
	local eHazardType = HazardsLib.HazardType_Breath
	local nBreathMax = 100

	if nBreath == nBreathMax then
		self:RemoveHazard(idHazard)
		return
	end

	if self.tHazards[idHazard] == nil then
		local tHazard = self._DB.profile.tHazards[eHazardType] or self._DB.profile.tHazards["default"]

		self:CreateHazard(idHazard, tHazard.strName, tHazard.nMin, nBreathMax, tHazard.crBar)
	end

	self:UpdateHazard(idHazard, {nValue = nBreath})
end

function ForgeUI_Hazards:OnHazardEnable(idHazard, strDisplayTxt)
	local eHazardType = nil
	local tData = {}

	for idx, tDat in ipairs(HazardsLib.GetHazardActiveList()) do
		if tDat.nId == idHazard then
			tData = tDat
			eHazardType = tDat.eHazardType
		end
	end

	local tHazard = self._DB.profile.tHazards[eHazardType] or self._DB.profile.tHazards["default"]

	self:CreateHazard(idHazard, strDisplayTxt, tHazard.nMin, tData.fMaxValue, tHazard.crBar, { strTooltip = tData.strTooltip })

	self:UpdateHazard(idHazard, { nValue = tData.fMeterValue })
end

function ForgeUI_Hazards:OnHazardsUpdated()
	for idx, tData in ipairs(HazardsLib.GetHazardActiveList()) do
		if not self.tHazards[tData.nId] then
			local tHazard = self._DB.profile.tHazards[tData.eHazardType] or self._DB.profile.tHazards["default"]

			self:CreateHazard(tData.nId, HazardsLib.GetHazardDisplayString(tData.nId), tHazard.nMin, tData.fMaxValue, tHazard.crBar)
		end

		self:UpdateHazard(tData.nId, { nValue = tData.fMeterValue, strTooltip = tData.strTooltip })
	end
end

function ForgeUI_Hazards:OnHazardRemove(idHazard)
	self:RemoveHazard(idHazard)
end

F:API_NewAddon(ForgeUI_Hazards)
