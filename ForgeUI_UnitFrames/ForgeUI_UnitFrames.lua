require "Window"
 
-----------------------------------------------------------------------------------------------
-- ForgeUI_UnitFrames Module Definition
-----------------------------------------------------------------------------------------------
local ForgeUI = nil
local ForgeUI_UnitFrames = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------

tClassEnums = {
	[GameLib.CodeEnumClass.Warrior]      	= "Warrior",
	[GameLib.CodeEnumClass.Engineer]     	= "Engineer",
	[GameLib.CodeEnumClass.Esper]        	= "Esper",
	[GameLib.CodeEnumClass.Medic]        	= "Medic",
	[GameLib.CodeEnumClass.Stalker]      	= "Stalker",
	[GameLib.CodeEnumClass.Spellslinger]	= "Spellslinger"
} 

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function ForgeUI_UnitFrames:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- mandatory 
    self.api_version = 2
	self.version = "0.1.0"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_UnitFrames"
	self.strDisplayName = "Unit frames"
	
	self.wndContainers = {}
	
	self.tStylers = {
		["UpdateStyle_PlayerFrame"] = self,
		["UpdateStyle_TargetFrame"] = self,
		["RefreshStyle_TargetFrame"] = self, -- (unit)
		["UpdateStyle_FocusFrame"] = self,
		["RefreshStyle_FocusFrame"] = self, -- (unit)
		["UpdateStyle_TotFrame"] = self,
		["RefreshStyle_TotFrame"] = self, -- (unit)
	}
	
	-- optional
	self.settings_version = 1
	self.tSettings = {
		tPlayerFrame = {
			bUseGradient = false,
			crBorder = "FF000000",
			crBackground = "FF101010",
			crHpBar = "FF272727",
			crHpBarGradient = "FFFF0000",
			crHpValue = "FF75CC26",
			crShieldBar = "FF0699F3",
			crShieldValue = "FFFFFFFF",
			crAbsorbBar = "FFFFC600",
			crAbsorbValue = "FFFFFFFF"
		},
		tTargetFrame = {
			bUseGradient = false,
			crBorder = "FF000000",
			crBackground = "FF101010",
			crHpBar = "FF272727",
			crHpBarGradient = "FFFF0000",
			crHpValue = "FF75CC26",
			crShieldBar = "FF0699F3",
			crShieldValue = "FFFFFFFF",
			crAbsorbBar = "FFFFC600",
			crAbsorbValue = "FFFFFFFF"
		},
		tTotFrame = {
			bShowThreat = false,
			crThreatLow = "FF33CC33",
			crThreatMedium = "FFFFFF00",
			crThreatHigh = "FFFF0000",
			crThreatTank = "FFFFFFFF",
			crBorder = "FF000000",
			crBackground = "FF101010",
			crHpBar = "FF272727",
			crHpValue = "FF75CC26",
			crShieldBar = "FF0699F3",
			crShieldValue = "FFFFFFFF",
			crAbsorbBar = "FFFFC600",
			crAbsorbValue = "FFFFFFFF"
		},
		tFocusFrame = {
			bShowShieldBar = true,
			bShowAbsorbBar = true,
			crBorder = "FF000000",
			crBackground = "FF101010",
			crHpBar = "FF272727",
			crHpValue = "FF75CC26",
			crShieldBar = "FF0699F3",
			crShieldValue = "FFFFFFFF",
			crAbsorbBar = "FFFFC600",
			crAbsorbValue = "FFFFFFFF"
		}
	}
	
	self.playerClass = nil

    return o
end

function ForgeUI_UnitFrames:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"ForgeUI"
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- ForgeUI_UnitFrames OnLoad
-----------------------------------------------------------------------------------------------
function ForgeUI_UnitFrames:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("ForgeUI_UnitFrames.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

function ForgeUI_UnitFrames:ForgeAPI_AfterRegistration()
	local wnd = ForgeUI.API_AddItemButton(self, "Unit frames")
	ForgeUI.API_AddListItemToButton(self, wnd, "Player frame", { strContainer = "Container_PlayerFrame", bDefault = true })
	ForgeUI.API_AddListItemToButton(self, wnd, "Target frame", { strContainer = "Container_TargetFrame" })
	ForgeUI.API_AddListItemToButton(self, wnd, "ToT frame", { strContainer = "Container_TotFrame" })
	ForgeUI.API_AddListItemToButton(self, wnd, "Focus frame", { strContainer = "Container_FocusFrame" })
	
	self.wndPlayerFrame = Apollo.LoadForm(self.xmlDoc, "ForgeUI_PlayerFrame", "FixedHudStratumLow", self)
	self.wndPlayerBuffFrame = Apollo.LoadForm(self.xmlDoc, "PlayerBuffContainerWindow", "FixedHudStratumHigh", self)
	self.wndPlayerDebuffFrame = Apollo.LoadForm(self.xmlDoc, "PlayerDebuffContainerWindow", "FixedHudStratumHigh", self)
	
	self.wndTargetFrame = Apollo.LoadForm(self.xmlDoc, "ForgeUI_TargetFrame", "FixedHudStratumLow", self)
	self.wndTargetBuffFrame = Apollo.LoadForm(self.xmlDoc, "TargetBuffContainerWindow", "FixedHudStratumHigh", self)
	self.wndTargetDebuffFrame = Apollo.LoadForm(self.xmlDoc, "TargetDebuffContainerWindow", "FixedHudStratumHigh", self)
	
	self.wndToTFrame = Apollo.LoadForm(self.xmlDoc, "ForgeUI_ToTFrame", "FixedHudStratumLow", self)
	self.wndThreat = self.wndToTFrame:FindChild("Threat")
	self.wndFocusFrame = Apollo.LoadForm(self.xmlDoc, "ForgeUI_FocusFrame", "FixedHudStratumLow", self)
	
	self.wndHazardBreath = Apollo.LoadForm(self.xmlDoc, "ForgeUI_HazardBreath", "FixedHudStratumLow", self)
	self.wndHazardHeat = Apollo.LoadForm(self.xmlDoc, "ForgeUI_HazardHeat", "FixedHudStratumLow", self)
	self.wndHazardToxic = Apollo.LoadForm(self.xmlDoc, "ForgeUI_HazardToxic", "FixedHudStratumLow", self)
	
	-- register windows
	
	ForgeUI.API_RegisterWindow(self, self.wndPlayerFrame, "ForgeUI_PlayerFrame", { strDisplayName = "Player frame" })
	ForgeUI.API_RegisterWindow(self, self.wndPlayerFrame:FindChild("ShieldBar"), "ForgeUI_PlayerFrame_Shield", { strParent = "ForgeUI_PlayerFrame", strDisplayName = "Shield", crBorder = "FF0699F3" })
	ForgeUI.API_RegisterWindow(self, self.wndPlayerFrame:FindChild("AbsorbBar"), "ForgeUI_PlayerFrame_Absorb", { strParent = "ForgeUI_PlayerFrame", strDisplayName = "Absorb", crBorder = "FFFFC600" })
	ForgeUI.API_RegisterWindow(self, self.wndPlayerFrame:FindChild("InterruptArmor"), "ForgeUI_PlayerFrame_IA", { strParent = "ForgeUI_PlayerFrame", strDisplayName = "IA", crBorder = "FFFFFFFF", bMaintainRatio = true })
	ForgeUI.API_RegisterWindow(self, self.wndPlayerBuffFrame, "ForgeUI_PlayerFrame_Buffs", { strDisplayName = "Player buffs" })
	ForgeUI.API_RegisterWindow(self, self.wndPlayerDebuffFrame, "ForgeUI_PlayerFrame_Debuffs", { strDisplayName = "Player debuffs" })
	
	ForgeUI.API_RegisterWindow(self, self.wndTargetFrame, "ForgeUI_TargetFrame", { strDisplayName = "Target frame" })
	ForgeUI.API_RegisterWindow(self, self.wndTargetFrame:FindChild("ShieldBar"), "ForgeUI_TargetFrame_Shield", { strParent = "ForgeUI_TargetFrame", strDisplayName = "Shield", crBorder = "FF0699F3" })
	ForgeUI.API_RegisterWindow(self, self.wndTargetFrame:FindChild("AbsorbBar"), "ForgeUI_TargetFrame_Absorb", { strParent = "ForgeUI_TargetFrame", strDisplayName = "Absorb", crBorder = "FFFFC600" })
	ForgeUI.API_RegisterWindow(self, self.wndTargetFrame:FindChild("InterruptArmor"), "ForgeUI_TargetFrame_IA", { strParent = "ForgeUI_TargetFrame", strDisplayName = "IA", crBorder = "FFFFFFFF", bMaintainRatio = true })
	ForgeUI.API_RegisterWindow(self, self.wndTargetBuffFrame, "ForgeUI_TargetFrame_Buffs", { strDisplayName = "Target buffs" })
	ForgeUI.API_RegisterWindow(self, self.wndTargetDebuffFrame, "ForgeUI_TargetFrame_Debuffs", { strDisplayName = "Target debuffs" })
	
	ForgeUI.API_RegisterWindow(self, self.wndToTFrame, "ForgeUI_ToTFrame", { strDisplayName = "ToT frame" })
	
	ForgeUI.API_RegisterWindow(self, self.wndFocusFrame, "ForgeUI_FocusFrame", { strDisplayName = "Focus frame" })
	ForgeUI.API_RegisterWindow(self, self.wndFocusFrame:FindChild("ShieldBar"), "ForgeUI_FocusFrame_Shield", { strParent = "ForgeUI_FocusFrame", strDisplayName = "Shield", crBorder = "FF0699F3" })
	ForgeUI.API_RegisterWindow(self, self.wndFocusFrame:FindChild("AbsorbBar"), "ForgeUI_FocusFrame_Absorb", { strParent = "ForgeUI_FocusFrame", strDisplayName = "Absorb", crBorder = "FFFFC600" })
	ForgeUI.API_RegisterWindow(self, self.wndFocusFrame:FindChild("InterruptArmor"), "ForgeUI_FocusFrame_IA", { strParent = "ForgeUI_FocusFrame", strDisplayName = "IA", crBorder = "FFFFFFFF", bMaintainRatio = true })
	
	ForgeUI.API_RegisterWindow(self, self.wndHazardBreath, "ForgeUI_wndHazardBreath", { strDisplayName = "Breath" })
	ForgeUI.API_RegisterWindow(self, self.wndHazardHeat, "ForgeUI_wndHazardHeat", { strDisplayName = "Heat" })
	ForgeUI.API_RegisterWindow(self, self.wndHazardToxic, "ForgeUI_wndHazardToxic", { strDisplayName = "Toxic" })
	
	if self.tSettings.tTotFrame.bShowThreat then
		Apollo.RegisterEventHandler("TargetThreatListUpdated", "OnThreatUpdated", self)
	end
end

function ForgeUI_UnitFrames:ForgeAPI_Initialization()
	if GameLib.GetPlayerUnit() then
		self:OnCharacterCreated()
	else
		Apollo.RegisterEventHandler("CharacterCreated", 	"OnCharacterCreated", self)
	end
end

-----------------------------------------------------------------------------------------------
-- On next frame
-----------------------------------------------------------------------------------------------

function ForgeUI_UnitFrames:OnNextFrame()
	unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer then return end
	
	self:UpdatePlayerFrame(unitPlayer)
	self:UpdateHazards(unitPlayer)
end

-- Player Frame
function ForgeUI_UnitFrames:UpdatePlayerFrame(unit)
	if unit:IsInCombat() then
		self.wndPlayerFrame:FindChild("Indicator"):Show(true)
	else
		self.wndPlayerFrame:FindChild("Indicator"):Show(false)
	end
		
	self:UpdateHPBar(unit, self.wndPlayerFrame, "tPlayerFrame")
	self:UpdateShieldBar(unit, self.wndPlayerFrame)
	self:UpdateAbsorbBar(unit, self.wndPlayerFrame)
	self:UpdateInterruptArmor(unit, self.wndPlayerFrame)
	
	self.wndPlayerFrame:SetData(unit)
	
	self.wndPlayerBuffFrame:SetUnit(unit)
	self.wndPlayerDebuffFrame:SetUnit(unit)
		
	self:UpdateTargetFrame(unit)
	self:UpdateFocusFrame(unit)
end

-- Target Frame
function ForgeUI_UnitFrames:UpdateTargetFrame(unitSource)
	local unit = unitSource:GetTarget()
	if unit == nil then 
		if self.wndTargetFrame:IsShown() then
			self.wndTargetFrame:Show(false, true)
			self.wndToTFrame:Show(false, true)
			self.wndTargetBuffFrame:SetUnit(nil)
			self.wndTargetDebuffFrame:SetUnit(nil)
		end
		return
	end

	self.tStylers["RefreshStyle_TargetFrame"]["RefreshStyle_TargetFrame"](self, unit)
	
	self:UpdateHPBar(unit, self.wndTargetFrame, "tTargetFrame")
	self:UpdateShieldBar(unit, self.wndTargetFrame)
	self:UpdateAbsorbBar(unit, self.wndTargetFrame)
	self:UpdateInterruptArmor(unit, self.wndTargetFrame)
	
	self.wndTargetBuffFrame:SetUnit(unit)
	self.wndTargetDebuffFrame:SetUnit(unit)
	self.wndTargetFrame:SetData(unit)
	
	if not self.wndTargetFrame:IsShown() then
		self.wndTargetBuffFrame:Show(true, true)
		self.wndTargetDebuffFrame:Show(true, true)
		self.wndTargetFrame:Show(true, true)
	end
	
	self:UpdateToTFrame(unit)
end

-- ToT Frame
function ForgeUI_UnitFrames:UpdateToTFrame(unitSource)
	local unit = unitSource:GetTarget()
	
	if unit == nil then 
		if self.wndToTFrame:IsShown() then
			self.wndToTFrame:Show(false)
			self.wndThreat:SetText("")
		end
		return
	end
	
	self.tStylers["RefreshStyle_TotFrame"]["RefreshStyle_TotFrame"](self, unit)
	if self.tSettings.tTotFrame.bShowThreat and unitSource:GetType() == "Player"  then
		self.wndThreat:SetText("")
	elseif self.tSettings.tTotFrame.bShowThreat and unit:IsACharacter() then
		self.wndThreat:Show(true, true)
	else
		self.wndThreat:Show(false, true)
	end
	
	self:UpdateHPBar(unit, self.wndToTFrame)
	
	self.wndToTFrame:SetData(unit)
	if not self.wndToTFrame:IsShown() then
		self.wndToTFrame:Show(true)
	end
end

-- Focus Frame
function ForgeUI_UnitFrames:UpdateFocusFrame(unitSource)
	local unit = unitSource:GetAlternateTarget()
	
	if unit == nil then 
		if self.wndFocusFrame:IsShown() then
			self.wndFocusFrame:Show(false)
		end
		return
	end
	
	self.tStylers["RefreshStyle_FocusFrame"]["RefreshStyle_FocusFrame"](self, unit)
	
	self:UpdateHPBar(unit, self.wndFocusFrame)
	self:UpdateInterruptArmor(unit, self.wndFocusFrame)
	if self.tSettings.tFocusFrame.bShowShieldBar then
		self:UpdateShieldBar(unit, self.wndFocusFrame)
	end
	if self.tSettings.tFocusFrame.bShowAbsorbBar then
		self:UpdateAbsorbBar(unit, self.wndFocusFrame)
	end
	
	self.wndFocusFrame:SetData(unit)
	if not self.wndFocusFrame:IsShown() then
		self.wndFocusFrame:Show(true)
	end
end

-- hp bar
function ForgeUI_UnitFrames:UpdateHPBar(unit, wnd, strSettings)
	if unit:GetHealth() ~= nil then
		wnd:FindChild("Background"):Show(true)
		wnd:FindChild("HP_ProgressBar"):SetMax(unit:GetMaxHealth())
		wnd:FindChild("HP_ProgressBar"):SetProgress(unit:GetHealth())
		
		if strSettings ~= nil and self.tSettings[strSettings].bUseGradient then
			local nPercent = ForgeUI.Round((unit:GetHealth() / unit:GetMaxHealth()) * 100, 0)
			local crGradient = ForgeUI.GenerateGradient(self.tSettings[strSettings].crHpBarGradient, self.tSettings[strSettings].crHpBar, 100, nPercent, true)
			wnd:FindChild("HP_ProgressBar"):SetBarColor(crGradient)
		end
		
		if wnd:FindChild("HP_TextValue") ~= nil then
			wnd:FindChild("HP_TextValue"):SetText(ForgeUI.ShortNum(unit:GetHealth()))
			wnd:FindChild("HP_TextPercent"):SetText(ForgeUI.Round((unit:GetHealth() / unit:GetMaxHealth()) * 100, 1) .. "%")
		end
	else
		wnd:FindChild("Background"):Show(false)
		wnd:FindChild("HP_ProgressBar"):SetProgress(0)
		if wnd:FindChild("HP_TextValue") ~= nil then
			wnd:FindChild("HP_TextValue"):SetText("")
			wnd:FindChild("HP_TextPercent"):SetText("")
		end
	end
end

-- shield bar
function ForgeUI_UnitFrames:UpdateShieldBar(unit, wnd)
	if unit:GetHealth() ~= nil then
		if unit:GetShieldCapacity() == 0 or unit:IsDead() then
			wnd:FindChild("ShieldBar"):Show(false)
		else
			wnd:FindChild("ShieldBar"):Show(true)
			wnd:FindChild("Shield_ProgressBar"):SetMax(unit:GetShieldCapacityMax())
			wnd:FindChild("Shield_ProgressBar"):SetProgress(unit:GetShieldCapacity())
			wnd:FindChild("Shield_TextValue"):SetText(ForgeUI.ShortNum(unit:GetShieldCapacity()))
		end
	else
		wnd:FindChild("ShieldBar"):Show(false)
	end
end

-- absorb bar
function ForgeUI_UnitFrames:UpdateAbsorbBar(unit, wnd)
	if unit:GetHealth() ~= nil then
		if unit:GetAbsorptionValue() == 0 or unit:IsDead() then
			wnd:FindChild("AbsorbBar"):Show(false)
		else
			wnd:FindChild("AbsorbBar"):Show(true)
			wnd:FindChild("Absorb_ProgressBar"):SetMax(unit:GetAbsorptionMax())
			wnd:FindChild("Absorb_ProgressBar"):SetProgress(unit:GetAbsorptionValue())
			wnd:FindChild("Absorb_TextValue"):SetText(ForgeUI.ShortNum(unit:GetAbsorptionValue()))
		end
	else
		wnd:FindChild("AbsorbBar"):Show(false)
	end
end

-- interrupt armor
function ForgeUI_UnitFrames:UpdateInterruptArmor(unit, wnd)
	nValue = unit:GetInterruptArmorValue()
	nMax = unit:GetInterruptArmorMax()
	if nMax == 0 or nValue == nil or unit:IsDead() then
		wnd:FindChild("InterruptArmor"):Show(false, true)
	else
		wnd:FindChild("InterruptArmor"):Show(true, true)
		if nMax == -1 then
			wnd:FindChild("InterruptArmor"):SetSprite("ForgeUI_IAinf")
			wnd:FindChild("InterruptArmor_Value"):SetText("")
		elseif nMax > 0 then
			wnd:FindChild("InterruptArmor"):SetSprite("ForgeUI_IA")
			wnd:FindChild("InterruptArmor_Value"):SetText(nValue)
		end
	end
end

-- uodate hazard bars
function ForgeUI_UnitFrames:UpdateHazards(unit)
	self.wndHazardHeat:Show(false)
	self.wndHazardToxic:Show(false)

	for idx, tActiveHazard in ipairs(HazardsLib.GetHazardActiveList()) do
		if tActiveHazard.eHazardType == HazardsLib.HazardType_Radiation then
			self.wndHazardToxic:Show(true)
			self.wndHazardToxic:FindChild("ProgressBar"):SetMax(tActiveHazard.fMaxValue)
			self.wndHazardToxic:FindChild("ProgressBar"):SetProgress(tActiveHazard.fMeterValue)
			self.wndHazardHeat:FindChild("Text"):SetText("Radiation - " .. ForgeUI.Round((tActiveHazard.fMeterValue / tActiveHazard.fMaxValue * 100), 0))
		end
		if tActiveHazard.eHazardType == HazardsLib.HazardType_Temperature then
			self.wndHazardHeat:Show(true)
			self.wndHazardHeat:FindChild("ProgressBar"):SetMax(tActiveHazard.fMaxValue)
			self.wndHazardHeat:FindChild("ProgressBar"):SetProgress(tActiveHazard.fMeterValue)
			self.wndHazardHeat:FindChild("Text"):SetText("Heat - " .. ForgeUI.Round((tActiveHazard.fMeterValue / tActiveHazard.fMaxValue * 100), 0))
		end
	end
end

function ForgeUI_UnitFrames:OnBreathChanged(nBreath)
	if nBreath == 100 then
		self.wndHazardBreath:Show(false)
	else
		self.wndHazardBreath:Show(true)
		self.wndHazardBreath:FindChild("ProgressBar"):SetMax(100)
		self.wndHazardBreath:FindChild("ProgressBar"):SetProgress(nBreath)
	end
end

-----------------------------------------------------------------------------------------------
-- On character created
-----------------------------------------------------------------------------------------------

function ForgeUI_UnitFrames:OnCharacterCreated()
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil then
		Print("ForgeUI ERROR: Wrong class")
		return
	end
	
	self:UpdateStyles()
	
	Apollo.RegisterEventHandler("VarChange_FrameCount", 	"OnNextFrame", self)
	Apollo.RegisterEventHandler("BreathChanged",			"OnBreathChanged", self)
end

function ForgeUI_UnitFrames:ForgeAPI_AfterRestore()
	for key, keyValue in pairs(self.tSettings) do
		local type  = string.sub(key, 2, string.len(key))
		for option, optionValue in pairs(keyValue) do
			if string.sub(option, 1, 2) == "cr" then
				if self.wndContainers["Container_" .. type]:FindChild(tostring(option)) ~= nil then
					ForgeUI.API_RegisterColorBox(self, self.wndContainers["Container_" .. type]:FindChild(tostring(option)), self.tSettings[key], tostring(option), false, "UpdateStyle_" .. type)
				end
			end
			if string.sub(option, 1, 1) == "b" then
				if self.wndContainers["Container_" .. type]:FindChild(tostring(option)) ~= nil then
					ForgeUI.API_RegisterCheckBox(self, self.wndContainers["Container_" .. type]:FindChild(tostring(option)), self.tSettings[key], tostring(option), "UpdateStyle_" .. type)
				end
			end
		end
	end
end

-----------------------------------------------------------------------------------------------
-- Styles
-----------------------------------------------------------------------------------------------

function ForgeUI_UnitFrames:UpdateStyles()
	self.tStylers["UpdateStyle_PlayerFrame"]["UpdateStyle_PlayerFrame"](self)
	self.tStylers["UpdateStyle_TargetFrame"]["UpdateStyle_TargetFrame"](self)
	self.tStylers["UpdateStyle_FocusFrame"]["UpdateStyle_FocusFrame"](self)
	self.tStylers["UpdateStyle_TotFrame"]["UpdateStyle_TotFrame"](self)
end

function ForgeUI_UnitFrames:UpdateStyle_PlayerFrame()
	unit = GameLib.GetPlayerUnit()
	if not unit or not self.wndPlayerFrame then return end

	self.wndPlayerFrame:FindChild("Name"):SetText(unit:GetName())
	self.wndPlayerFrame:FindChild("Name"):SetTextColor(ForgeUI.tSettings.tClassColors["cr" .. tClassEnums[unit:GetClassId()]])

	self.wndPlayerFrame:FindChild("HPBar"):SetBGColor(self.tSettings.tPlayerFrame.crBorder)
	self.wndPlayerFrame:FindChild("Background"):SetBGColor(self.tSettings.tPlayerFrame.crBackground)
	self.wndPlayerFrame:FindChild("HP_ProgressBar"):SetBarColor(self.tSettings.tPlayerFrame.crHpBar)
	self.wndPlayerFrame:FindChild("HP_TextValue"):SetTextColor(self.tSettings.tPlayerFrame.crHpValue)
	self.wndPlayerFrame:FindChild("HP_TextPercent"):SetTextColor(self.tSettings.tPlayerFrame.crHpValue)
	self.wndPlayerFrame:FindChild("Shield_ProgressBar"):SetBarColor(self.tSettings.tPlayerFrame.crShieldBar)
	self.wndPlayerFrame:FindChild("Shield_TextValue"):SetTextColor(self.tSettings.tPlayerFrame.crShieldValue)
	self.wndPlayerFrame:FindChild("Absorb_ProgressBar"):SetBarColor(self.tSettings.tPlayerFrame.crAbsorbBar)
	self.wndPlayerFrame:FindChild("Absorb_TextValue"):SetTextColor(self.tSettings.tPlayerFrame.crAbsorbValue)
end

function ForgeUI_UnitFrames:UpdateStyle_TargetFrame()
	self.wndTargetFrame:FindChild("HPBar"):SetBGColor(self.tSettings.tTargetFrame.crBorder)
	self.wndTargetFrame:FindChild("Background"):SetBGColor(self.tSettings.tTargetFrame.crBackground)
	self.wndTargetFrame:FindChild("HP_ProgressBar"):SetBarColor(self.tSettings.tTargetFrame.crHpBar)
	self.wndTargetFrame:FindChild("HP_TextValue"):SetTextColor(self.tSettings.tTargetFrame.crHpValue)
	self.wndTargetFrame:FindChild("HP_TextPercent"):SetTextColor(self.tSettings.tTargetFrame.crHpValue)
	self.wndTargetFrame:FindChild("Shield_ProgressBar"):SetBarColor(self.tSettings.tTargetFrame.crShieldBar)
	self.wndTargetFrame:FindChild("Shield_TextValue"):SetTextColor(self.tSettings.tTargetFrame.crShieldValue)
	self.wndTargetFrame:FindChild("Absorb_ProgressBar"):SetBarColor(self.tSettings.tTargetFrame.crAbsorbBar)
	self.wndTargetFrame:FindChild("Absorb_TextValue"):SetTextColor(self.tSettings.tTargetFrame.crAbsorbValue)
end

function ForgeUI_UnitFrames:RefreshStyle_TargetFrame(unit)
	local _name = self.wndTargetFrame:FindChild("Name")

	_name:SetText(unit:GetName())
	if unit:GetClassId() ~= 23 then
		_name:SetTextColor(ForgeUI.tSettings.tClassColors["cr" .. tClassEnums[unit:GetClassId()]])
	else
		_name:SetTextColor(unit:GetNameplateColor())
	end
end

function ForgeUI_UnitFrames:UpdateStyle_FocusFrame()
	self.wndFocusFrame:FindChild("HPBar"):SetBGColor(self.tSettings.tFocusFrame.crBorder)
	self.wndFocusFrame:FindChild("Background"):SetBGColor(self.tSettings.tFocusFrame.crBackground)
	self.wndFocusFrame:FindChild("HP_ProgressBar"):SetBarColor(self.tSettings.tFocusFrame.crHpBar)
	self.wndFocusFrame:FindChild("HP_TextValue"):SetTextColor(self.tSettings.tFocusFrame.crHpValue)
	self.wndFocusFrame:FindChild("HP_TextPercent"):SetTextColor(self.tSettings.tFocusFrame.crHpValue)
	self.wndFocusFrame:FindChild("Shield_ProgressBar"):SetBarColor(self.tSettings.tFocusFrame.crShieldBar)
	self.wndFocusFrame:FindChild("Shield_TextValue"):SetTextColor(self.tSettings.tFocusFrame.crShieldValue)
	self.wndFocusFrame:FindChild("Absorb_ProgressBar"):SetBarColor(self.tSettings.tFocusFrame.crAbsorbBar)
	self.wndFocusFrame:FindChild("Absorb_TextValue"):SetTextColor(self.tSettings.tFocusFrame.crAbsorbValue)
	
	self.wndFocusFrame:FindChild("ShieldBar"):Show(self.tSettings.tFocusFrame.bShowShieldBar, true)
	self.wndFocusFrame:FindChild("AbsorbBar"):Show(self.tSettings.tFocusFrame.bShowAbsorbBar, true)
end

function ForgeUI_UnitFrames:RefreshStyle_FocusFrame(unit)
	local _name = self.wndFocusFrame:FindChild("Name")

	_name:SetText(unit:GetName())
	if unit:GetClassId() ~= 23 then
		_name:SetTextColor(ForgeUI.tSettings.tClassColors["cr" .. tClassEnums[unit:GetClassId()]])
	else
		_name:SetTextColor(unit:GetNameplateColor())
	end
end

function ForgeUI_UnitFrames:UpdateStyle_TotFrame()
	self.wndToTFrame:FindChild("HPBar"):SetBGColor(self.tSettings.tTotFrame.crBorder)
	self.wndToTFrame:FindChild("Background"):SetBGColor(self.tSettings.tTotFrame.crBackground)
	self.wndToTFrame:FindChild("HP_ProgressBar"):SetBarColor(self.tSettings.tTotFrame.crHpBar)
end

function ForgeUI_UnitFrames:RefreshStyle_TotFrame(unit)
	local _name = self.wndToTFrame:FindChild("Name")

	_name:SetText(unit:GetName())
	if unit:GetClassId() ~= 23 then
		_name:SetTextColor(ForgeUI.tSettings.tClassColors["cr" .. tClassEnums[unit:GetClassId()]])
	else
		_name:SetTextColor(unit:GetNameplateColor())
	end
end

-----------------------------------------------------------------------------------------------
-- Threat
-----------------------------------------------------------------------------------------------

function ForgeUI_UnitFrames:OnThreatUpdated(...)
	if self.tSettings.tTotFrame.bShowThreat ~= true then return end

	if select(1, ...) ~= nil then
		local topThreatUnit = select(1, ...)
		local topThreatValue = select(2, ...)
		if topThreatUnit:IsThePlayer() then
			if select(3, ...) == nil then
				self.wndThreat:SetText("")
			else
				self.wndThreat:SetText(ForgeUI.Round((select(4, ...) / topThreatValue) * 100, 1) .. "%")
				self.wndThreat:SetTextColor(self.tSettings.tTotFrame.crThreatTank)
			end
		else
			for i=3, select('#', ...), 2 do
				local cUnit = select(i, ...)
				local cThreat = select(i+1, ...)
				
				if cUnit ~= nil and cUnit:IsThePlayer() then
					local nThreatPercentage = ForgeUI.Round((cThreat / topThreatValue) * 100, 1)
				
					self.wndThreat:SetText(nThreatPercentage .. "%")
					if nThreatPercentage <= 75 then
						self.wndThreat:SetTextColor(self.tSettings.tTotFrame.crThreatLow)
					elseif nThreatPercentage <= 90 then
						self.wndThreat:SetTextColor(self.tSettings.tTotFrame.crThreatMedium)
					else
						self.wndThreat:SetTextColor(self.tSettings.tTotFrame.crThreatHigh)
					end
				end
			end
		end
	end
end
-----------------------------------------------------------------------------------------------
-- ForgeUI_UnitFrames OnDocLoaded
-----------------------------------------------------------------------------------------------
function ForgeUI_UnitFrames:OnDocLoaded()
	if self.xmlDoc == nil or not self.xmlDoc:IsLoaded() then return false end
	 
	if ForgeUI == nil then -- forgeui loaded
		ForgeUI = Apollo.GetAddon("ForgeUI")
	end
	
	ForgeUI.API_RegisterAddon(self)
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_PlayerFrame Functions
---------------------------------------------------------------------------------------------------

function ForgeUI_UnitFrames:OnMouseButtonDown( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	local unit = wndHandler:GetData()
	
	if eMouseButton == GameLib.CodeEnumInputMouse.Left and unit ~= nil then
		GameLib.SetTargetUnit(unit)
		return false
	end
	
	if eMouseButton == GameLib.CodeEnumInputMouse.Right and unit ~= nil then
		Event_FireGenericEvent("GenericEvent_NewContextMenuPlayerDetailed", nil, unit:GetName(), unit)
		return true
	end
	
	return false
end

function ForgeUI_UnitFrames:OnGenerateBuffTooltip(wndHandler, wndControl, tType, splBuff)
	if wndHandler == wndControl or Tooltip == nil then
		return
	end
	Tooltip.GetBuffTooltipForm(self, wndControl, splBuff, {bFutureSpell = false})
end

---------------------------------------------------------------------------------------------------
-- Movables Functions
---------------------------------------------------------------------------------------------------

local ForgeUI_UnitFramesInst = ForgeUI_UnitFrames:new()
ForgeUI_UnitFramesInst:Init()

