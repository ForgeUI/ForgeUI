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
	[GameLib.CodeEnumClass.Warrior]      	= "warrior",
	[GameLib.CodeEnumClass.Engineer]     	= "engineer",
	[GameLib.CodeEnumClass.Esper]        	= "esper",
	[GameLib.CodeEnumClass.Medic]        	= "medic",
	[GameLib.CodeEnumClass.Stalker]      	= "stalker",
	[GameLib.CodeEnumClass.Spellslinger]	= "spellslinger"
} 

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function ForgeUI_UnitFrames:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- mandatory 
    self.api_version = 1
	self.version = "0.1.0"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_UnitFrames"
	self.strDisplayName = "Unit frames"
	
	self.wndContainers = {}
	
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
			bShowThreat = true,
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
	local wnd = ForgeUI.AddItemButton(self, "Unit frames")
	ForgeUI.AddItemListToButton(self, wnd, {
		{ strDisplayName = "Player frame", strContainer = "Container_PlayerFrame", bDefault = true },
		{ strDisplayName = "Target frame", strContainer = "Container_TargetFrame" },
		{ strDisplayName = "ToT frame", strContainer = "Container_TotFrame" },
		{ strDisplayName = "Focus frame", strContainer = "Container_FocusFrame" }
	}) 
	
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
	
	self.wndMovables = Apollo.LoadForm(self.xmlDoc, "Movables", nil, self)
	
	if self.tSettings.tTotFrame.bShowThreat then
		Apollo.RegisterEventHandler("TargetThreatListUpdated", "OnThreatUpdated", self)
	end
end

-----------------------------------------------------------------------------------------------
-- On next frame
-----------------------------------------------------------------------------------------------

function ForgeUI_UnitFrames:OnNextFrame()
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end
	
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
	
	self.wndPlayerFrame:FindChild("Name"):SetText(unit:GetName())
	self.wndPlayerFrame:FindChild("Name"):SetTextColor("FF" .. ForgeUI.GetSettings().classColors[self.playerClass])
	
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

	self.wndTargetFrame:FindChild("Name"):SetText(unit:GetName())
	if unit:GetClassId() ~= 23 then
		self.wndTargetFrame:FindChild("Name"):SetTextColor("ff" .. ForgeUI.GetSettings().classColors[tClassEnums[unit:GetClassId()]])
	else
		self.wndTargetFrame:FindChild("Name"):SetTextColor(unit:GetNameplateColor())
	end
	
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
	
	self.wndToTFrame:FindChild("Name"):SetText(unit:GetName())
	if unit:GetClassId() ~= 23 then
		self.wndToTFrame:FindChild("Name"):SetTextColor("ff" .. ForgeUI.GetSettings().classColors[tClassEnums[unit:GetClassId()]])
	else
		self.wndToTFrame:FindChild("Name"):SetTextColor(unit:GetNameplateColor())
	end
	
	if self.tSettings.tTotFrame.bShowThreat and unitSource:GetType() == "Player"  then
		self.wndThreat:SetText("")
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
	
	self.wndFocusFrame:FindChild("Name"):SetText(unit:GetName())
	if unit:GetClassId() ~= 23 then
		self.wndFocusFrame:FindChild("Name"):SetTextColor("ff" .. ForgeUI.GetSettings().classColors[tClassEnums[unit:GetClassId()]])
	else
		self.wndFocusFrame:FindChild("Name"):SetTextColor(unit:GetNameplateColor())
	end
	
	self:UpdateHPBar(unit, self.wndFocusFrame)
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
	
	local eClassId = unitPlayer:GetClassId()
	if eClassId == GameLib.CodeEnumClass.Engineer then
		self.playerClass = "engineer"
	elseif eClassId == GameLib.CodeEnumClass.Esper then
		self.playerClass = "esper"
	elseif eClassId == GameLib.CodeEnumClass.Medic then
		self.playerClass = "medic"
	elseif eClassId == GameLib.CodeEnumClass.Spellslinger then
		self.playerClass = "spellslinger"
	elseif eClassId == GameLib.CodeEnumClass.Stalker then
		self.playerClass = "stalker"
	elseif eClassId == GameLib.CodeEnumClass.Warrior then
		self.playerClass = "warrior"
	end
	
	Apollo.RegisterEventHandler("VarChange_FrameCount", 	"OnNextFrame", self)
	Apollo.RegisterEventHandler("BreathChanged",			"OnBreathChanged", self)
end

function ForgeUI_UnitFrames:ForgeAPI_AfterRestore()
	ForgeUI.RegisterWindowPosition(self, self.wndPlayerFrame, "ForgeUI_UnitFrames_PlayerFrame", self.wndMovables:FindChild("Movable_PlayerFrame"))
	ForgeUI.RegisterWindowPosition(self, self.wndPlayerFrame:FindChild("ShieldBar"), "ForgeUI_UnitFrames_PlayerFrame_ShieldBar", self.wndMovables:FindChild("Movable_PlayerFrame_ShieldBar"))
	ForgeUI.RegisterWindowPosition(self, self.wndPlayerFrame:FindChild("AbsorbBar"), "ForgeUI_UnitFrames_PlayerFrame_AbsorbBar", self.wndMovables:FindChild("Movable_PlayerFrame_AbsorbBar"))
	ForgeUI.RegisterWindowPosition(self, self.wndPlayerFrame:FindChild("InterruptArmor"), "ForgeUI_UnitFrames_PlayerFrame_IA", self.wndMovables:FindChild("Movable_PlayerFrame_IA"))
	
	ForgeUI.RegisterWindowPosition(self, self.wndTargetFrame, "ForgeUI_UnitFrames_TargetFrame", self.wndMovables:FindChild("Movable_TargetFrame"))
	ForgeUI.RegisterWindowPosition(self, self.wndTargetFrame:FindChild("ShieldBar"), "ForgeUI_UnitFrames_TargetFrame_ShieldBar", self.wndMovables:FindChild("Movable_TargetFrame_ShieldBar"))
	ForgeUI.RegisterWindowPosition(self, self.wndTargetFrame:FindChild("AbsorbBar"), "ForgeUI_UnitFrames_TargetFrame_AbsorbBar", self.wndMovables:FindChild("Movable_TargetFrame_AbsorbBar"))
	ForgeUI.RegisterWindowPosition(self, self.wndTargetFrame:FindChild("InterruptArmor"), "ForgeUI_UnitFrames_TargetFrame_IA", self.wndMovables:FindChild("Movable_TargetFrame_IA"))
	
	ForgeUI.RegisterWindowPosition(self, self.wndFocusFrame, "ForgeUI_UnitFrames_FocusFrame", self.wndMovables:FindChild("Movable_FocusFrame"))
	
	ForgeUI.RegisterWindowPosition(self, self.wndToTFrame, "ForgeUI_UnitFrames_ToTFrame", self.wndMovables:FindChild("Movable_ToTFrame"))
	
	ForgeUI.RegisterWindowPosition(self, self.wndHazardBreath, "ForgeUI_UnitFrames_Hazard_Breath", self.wndMovables:FindChild("Movable_Hazard_Breath"))
	ForgeUI.RegisterWindowPosition(self, self.wndHazardHeat, "ForgeUI_UnitFrames_Hazard_Heat", self.wndMovables:FindChild("Movable_Hazard_Heat"))
	ForgeUI.RegisterWindowPosition(self, self.wndHazardToxic, "ForgeUI_UnitFrames_Hazard_Toxic", self.wndMovables:FindChild("Movable_Hazard_Toxic"))
	
	ForgeUI.RegisterWindowPosition(self, self.wndPlayerBuffFrame, "ForgeUI_UnitFrames_PlayerBuffs", self.wndMovables:FindChild("Movable_PlayerBuffs"))
	ForgeUI.RegisterWindowPosition(self, self.wndPlayerDebuffFrame, "ForgeUI_UnitFrames_PlayerDebuffs", self.wndMovables:FindChild("Movable_PlayerDebuffs"))
	ForgeUI.RegisterWindowPosition(self, self.wndTargetBuffFrame, "ForgeUI_UnitFrames_TargetBuffs", self.wndMovables:FindChild("Movable_TargetBuffs"))
	ForgeUI.RegisterWindowPosition(self, self.wndTargetDebuffFrame, "ForgeUI_UnitFrames_TargetDebuffs", self.wndMovables:FindChild("Movable_TargetDebuffs"))
	
	self:UpdateStyles()
end

function ForgeUI_UnitFrames:ForgeAPI_LoadOptions()
	for _, wndContainer in pairs(self.wndContainers) do
		if wndContainer:GetName() ~= "Container_General" then
			local wnd
			local sType = "t" .. string.sub(wndContainer:GetName(), 11, string.len(wndContainer:GetName()))
			
			wnd = wndContainer:FindChild("crBorder")
			if wnd ~= nil then
				ForgeUI.ColorBoxChange(self, wnd, self.tSettings[sType], "crBorder", true)
			end
			
			wnd = wndContainer:FindChild("crBackground")
			if wnd ~= nil then
				ForgeUI.ColorBoxChange(self, wnd, self.tSettings[sType], "crBackground", true)
			end
			
			wnd = wndContainer:FindChild("crHpBar")
			if wnd ~= nil then
				ForgeUI.ColorBoxChange(self, wnd, self.tSettings[sType], "crHpBar", true)
			end
			
			wnd = wndContainer:FindChild("crHpBarGradient")
			if wnd ~= nil then
				ForgeUI.ColorBoxChange(self, wnd, self.tSettings[sType], "crHpBarGradient", true)
			end
			
			wnd = wndContainer:FindChild("crHpValue")
			if wnd ~= nil then
				ForgeUI.ColorBoxChange(self, wnd, self.tSettings[sType], "crHpValue", true)
			end
			
			wnd = wndContainer:FindChild("crShieldBar")
			if wnd ~= nil then
				ForgeUI.ColorBoxChange(self, wnd, self.tSettings[sType], "crShieldBar", true)
			end
			
			wnd = wndContainer:FindChild("crShieldValue")
			if wnd ~= nil then
				ForgeUI.ColorBoxChange(self, wnd, self.tSettings[sType], "crShieldValue", true)
			end
			
			wnd = wndContainer:FindChild("crAbsorbBar")
			if wnd ~= nil then
				ForgeUI.ColorBoxChange(self, wnd, self.tSettings[sType], "crAbsorbBar", true)
			end
			
			wnd = wndContainer:FindChild("crAbsorbValue")
			if wnd ~= nil then
				ForgeUI.ColorBoxChange(self, wnd, self.tSettings[sType], "crAbsorbValue", true)
			end

			-- checkboxes
			
			wnd = wndContainer:FindChild("bUseGradient")
			if wnd ~= nil then
				wnd:SetCheck(self.tSettings[sType].bUseGradient)
			end
			
			wnd = wndContainer:FindChild("bShowThreat")
			if wnd ~= nil then
				wnd:SetCheck(self.tSettings[sType].bShowThreat)
			end
		end
	end
end

function ForgeUI_UnitFrames:OnOptionsChanged( wndHandler, wndControl )
	local strType = wndControl:GetParent():GetName()
	local strControlType = "t" .. string.sub(wndControl:GetParent():GetParent():GetName(), 11, string.len(wndControl:GetParent():GetParent():GetName()))
	
	if strType == "ColorBox" then
		ForgeUI.ColorBoxChange(self, wndControl, self.tSettings[strControlType], wndControl:GetName())
	end
	
	if strType == "CheckBox" then
		self.tSettings[strControlType][wndControl:GetName()] = wndControl:IsChecked()
	end
	
	self:UpdateStyles()
end

function ForgeUI_UnitFrames:UpdateStyles()
	self.wndPlayerFrame:FindChild("HPBar"):SetBGColor(self.tSettings.tPlayerFrame.crBorder)
	self.wndPlayerFrame:FindChild("Background"):SetBGColor(self.tSettings.tPlayerFrame.crBackground)
	self.wndPlayerFrame:FindChild("HP_ProgressBar"):SetBarColor(self.tSettings.tPlayerFrame.crHpBar)
	self.wndPlayerFrame:FindChild("HP_TextValue"):SetTextColor(self.tSettings.tPlayerFrame.crHpValue)
	self.wndPlayerFrame:FindChild("HP_TextPercent"):SetTextColor(self.tSettings.tPlayerFrame.crHpValue)
	self.wndPlayerFrame:FindChild("Shield_ProgressBar"):SetBarColor(self.tSettings.tPlayerFrame.crShieldBar)
	self.wndPlayerFrame:FindChild("Shield_TextValue"):SetTextColor(self.tSettings.tPlayerFrame.crShieldValue)
	self.wndPlayerFrame:FindChild("Absorb_ProgressBar"):SetBarColor(self.tSettings.tPlayerFrame.crAbsorbBar)
	self.wndPlayerFrame:FindChild("Absorb_TextValue"):SetTextColor(self.tSettings.tPlayerFrame.crAbsorbValue)
	
	self.wndTargetFrame:FindChild("HPBar"):SetBGColor(self.tSettings.tTargetFrame.crBorder)
	self.wndTargetFrame:FindChild("Background"):SetBGColor(self.tSettings.tTargetFrame.crBackground)
	self.wndTargetFrame:FindChild("HP_ProgressBar"):SetBarColor(self.tSettings.tTargetFrame.crHpBar)
	self.wndTargetFrame:FindChild("HP_TextValue"):SetTextColor(self.tSettings.tTargetFrame.crHpValue)
	self.wndTargetFrame:FindChild("HP_TextPercent"):SetTextColor(self.tSettings.tTargetFrame.crHpValue)
	self.wndTargetFrame:FindChild("Shield_ProgressBar"):SetBarColor(self.tSettings.tTargetFrame.crShieldBar)
	self.wndTargetFrame:FindChild("Shield_TextValue"):SetTextColor(self.tSettings.tTargetFrame.crShieldValue)
	self.wndTargetFrame:FindChild("Absorb_ProgressBar"):SetBarColor(self.tSettings.tTargetFrame.crAbsorbBar)
	self.wndTargetFrame:FindChild("Absorb_TextValue"):SetTextColor(self.tSettings.tTargetFrame.crAbsorbValue)
	
	self.wndToTFrame:FindChild("HPBar"):SetBGColor(self.tSettings.tTotFrame.crBorder)
	self.wndToTFrame:FindChild("Background"):SetBGColor(self.tSettings.tTotFrame.crBackground)
	self.wndToTFrame:FindChild("HP_ProgressBar"):SetBarColor(self.tSettings.tTotFrame.crHpBar)
	
	self.wndFocusFrame:FindChild("HPBar"):SetBGColor(self.tSettings.tFocusFrame.crBorder)
	self.wndFocusFrame:FindChild("Background"):SetBGColor(self.tSettings.tFocusFrame.crBackground)
	self.wndFocusFrame:FindChild("HP_ProgressBar"):SetBarColor(self.tSettings.tFocusFrame.crHpBar)
	self.wndFocusFrame:FindChild("HP_TextValue"):SetTextColor(self.tSettings.tFocusFrame.crHpValue)
	self.wndFocusFrame:FindChild("HP_TextPercent"):SetTextColor(self.tSettings.tFocusFrame.crHpValue)
end

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
	
	ForgeUI.RegisterAddon(self)
	
	if GameLib.GetPlayerUnit() then
		self:OnCharacterCreated()
	else
		Apollo.RegisterEventHandler("CharacterCreated", 	"OnCharacterCreated", self)
	end 
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

function ForgeUI_UnitFrames:OnMovableMove( wndHandler, wndControl, nOldLeft, nOldTop, nOldRight, nOldBottom )
	self.wndPlayerFrame:SetAnchorOffsets(self.wndMovables:FindChild("Movable_PlayerFrame"):GetAnchorOffsets())
	self.wndPlayerFrame:FindChild("ShieldBar"):SetAnchorOffsets(self.wndMovables:FindChild("Movable_PlayerFrame_ShieldBar"):GetAnchorOffsets())
	self.wndPlayerFrame:FindChild("AbsorbBar"):SetAnchorOffsets(self.wndMovables:FindChild("Movable_PlayerFrame_AbsorbBar"):GetAnchorOffsets())
	self.wndPlayerFrame:FindChild("InterruptArmor"):SetAnchorOffsets(self.wndMovables:FindChild("Movable_PlayerFrame_IA"):GetAnchorOffsets())
	
	self.wndTargetFrame:SetAnchorOffsets(self.wndMovables:FindChild("Movable_TargetFrame"):GetAnchorOffsets())
	self.wndTargetFrame:FindChild("ShieldBar"):SetAnchorOffsets(self.wndMovables:FindChild("Movable_TargetFrame_ShieldBar"):GetAnchorOffsets())
	self.wndTargetFrame:FindChild("AbsorbBar"):SetAnchorOffsets(self.wndMovables:FindChild("Movable_TargetFrame_AbsorbBar"):GetAnchorOffsets())
	self.wndTargetFrame:FindChild("InterruptArmor"):SetAnchorOffsets(self.wndMovables:FindChild("Movable_TargetFrame_IA"):GetAnchorOffsets())
	
	self.wndFocusFrame:SetAnchorOffsets(self.wndMovables:FindChild("Movable_FocusFrame"):GetAnchorOffsets())
	
	self.wndToTFrame:SetAnchorOffsets(self.wndMovables:FindChild("Movable_ToTFrame"):GetAnchorOffsets())
	
	self.wndPlayerBuffFrame:SetAnchorOffsets(self.wndMovables:FindChild("Movable_PlayerBuffs"):GetAnchorOffsets())
	self.wndPlayerDebuffFrame:SetAnchorOffsets(self.wndMovables:FindChild("Movable_PlayerDebuffs"):GetAnchorOffsets())
	self.wndTargetBuffFrame:SetAnchorOffsets(self.wndMovables:FindChild("Movable_TargetBuffs"):GetAnchorOffsets())
	self.wndTargetDebuffFrame:SetAnchorOffsets(self.wndMovables:FindChild("Movable_TargetDebuffs"):GetAnchorOffsets())
	
	self.wndHazardBreath:SetAnchorOffsets(self.wndMovables:FindChild("Movable_Hazard_Breath"):GetAnchorOffsets())
	self.wndHazardToxic:SetAnchorOffsets(self.wndMovables:FindChild("Movable_Hazard_Toxic"):GetAnchorOffsets())
	self.wndHazardHeat:SetAnchorOffsets(self.wndMovables:FindChild("Movable_Hazard_Heat"):GetAnchorOffsets())
end

local ForgeUI_UnitFramesInst = ForgeUI_UnitFrames:new()
ForgeUI_UnitFramesInst:Init()

