require "Window"
require "HazardsLib"
 
local ForgeUI
local ForgeUI_Hazards = {} 

function ForgeUI_Hazards:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

	self.tHazards = {}

    -- mandatory 
    self.api_version = 2
	self.version = "1.0.0"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_Hazards"
	self.strDisplayName = "Hazards"
	
	self.wndContainers = {}
	
	self.tStylers = {}
	
	-- optional
	self.settings_version = 1
    self.tSettings = {
		tHazards = {
			["Default"] = { strName = "Unknown", nMin = 0, crBar = "FFFFFFFF" },
			[HazardsLib.HazardType_Radiation] = { strName = "Radiation", nMin = 0, crBar = "FF25F400" },
			[HazardsLib.HazardType_Temperature] = { strName = "Temperature", nMin = 0, crBar = "FFF40000" },
			[HazardsLib.HazardType_Proximity] = { strName = "Proximity", nMin = 0, crBar = "FFFF9900" },
			[HazardsLib.HazardType_Timer] = { strName = "Timer", nMin = 0, crBar = "FFFF9900" },
			[HazardsLib.HazardType_Breath] = { strName = "Breath", nMin = 0, crBar = "FF1591DB" },
		}
	}

    return o
end

function ForgeUI_Hazards:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"ForgeUI"
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

function ForgeUI_Hazards:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("ForgeUI_Hazards.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

function ForgeUI_Hazards:OnDocLoaded()
	if self.xmlDoc == nil and not self.xmlDoc:IsLoaded() then return end
	
	if ForgeUI == nil then -- forgeui loaded
		ForgeUI = Apollo.GetAddon("ForgeUI")
	end
	
	ForgeUI.API_RegisterAddon(self)
end

-------------------------------------------------------------------------------
-- ForgeAPI
-------------------------------------------------------------------------------
function ForgeUI_Hazards:ForgeAPI_AfterRegistration()
	Apollo.RegisterEventHandler("BreathChanged", "OnBreathChanged", self)
	Apollo.RegisterEventHandler("HazardEnabled", "OnHazardEnable", self)
	Apollo.RegisterEventHandler("HazardRemoved", "OnHazardRemove", self)
	Apollo.RegisterEventHandler("HazardUpdated", "OnHazardsUpdated", self)
	
	self.wndHazardsHolder = Apollo.LoadForm(self.xmlDoc, "HazardsHolder", ForgeUI.HudStratum3, self)
	ForgeUI.API_RegisterWindow(self, self.wndHazardsHolder, "ForgeUI_HazardMeter", { strDisplayName = "Breath and Hazard bars" })
end

-------------------------------------------------------------------------------
-- Hazard functions
-------------------------------------------------------------------------------
function ForgeUI_Hazards:CreateHazard(nID, strName, nMin, nMax, crBar, tOptions)
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
	local wndHazard = self.tHazards[nID]
	
	if not tOptions then return end
	
	if tOptions.nValue then
		wndHazard:FindChild("ProgressBar"):SetProgress(tOptions.nValue)
		wndHazard:FindChild("Text"):SetText(wndHazard:GetData().strName .. " - " .. ForgeUI.Round((tOptions.nValue / wndHazard:GetData().nMax) * 100, 0))
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
		local tHazard = self.tSettings.tHazards[eHazardType] or self.tSettings.tHazards["default"]

		self:CreateHazard(idHazard, tHazard.strName, tHazard.nMin, nBreathMax, tHazard.crBar)
	end
	
	self:UpdateHazard(idHazard, {nValue = nBreath})
end

function ForgeUI_Hazards:OnHazardEnable(idHazard, strDisplayTxt)
	local eHazardType = nil
	local tData = nil
	
	for idx, tDat in ipairs(HazardsLib.GetHazardActiveList()) do
		if tDat.nId == idHazard then
			tData = tDat
			eHazardType = tDat.eHazardType
		end
	end
	
	local tHazard = self.tSettings.tHazards[eHazardType] or self.tSettings.tHazards["default"]

	self:CreateHazard(idHazard, tHazard.strName, tHazard.nMin, tData.fMaxValue, tHazard.crBar, { strTooltip = tData.strTooltip })
	
	self:UpdateHazard(idHazard, { nValue = tData.fMeterValue })
end

function ForgeUI_Hazards:OnHazardsUpdated()
	for idx, tData in ipairs(HazardsLib.GetHazardActiveList()) do
		if not self.tHazards[tData.nId] then
			local tHazard = self.tSettings.tHazards[tData.eHazardType] or self.tSettings.tHazards["default"]
		
			self:CreateHazard(tData.nId, tHazard.strName, tHazard.nMin, tData.fMaxValue, tHazard.crBar)
		end
		
		self:UpdateHazard(tData.nId, { nValue = tData.fMeterValue, strTooltip = tData.strTooltip })
	end
end

function ForgeUI_Hazards:OnHazardRemove(idHazard)
	self:RemoveHazard(idHazard)
end

local ForgeUI_HazardsInst = ForgeUI_Hazards:new()
ForgeUI_HazardsInst:Init()
