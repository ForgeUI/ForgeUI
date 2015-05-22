----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI addon
--
-- name: 		ForgeUI_UnitFrames.lua
-- author:		Winty Badass@Jabbit
-- about:		Unit frames addon for ForgeUI
-----------------------------------------------------------------------------------------------

require "Window"

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI

local Util = F:API_GetModule("util")

-----------------------------------------------------------------------------------------------
-- ForgeUI Addon Definition
-----------------------------------------------------------------------------------------------
local ForgeUI_UnitFrames = {
	_NAME = "ForgeUI_UnitFrames",
    _API_VERSION = 3,
	VERSION = "2.0",
	
	tSettings = {
		profile = {
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
				crAbsorbValue = "FFFFFFFF",
				strFullSprite = "ForgeUI_Smooth",
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
				crAbsorbValue = "FFFFFFFF",
				strFullSprite = "ForgeUI_Smooth",
			},
			tTotFrame = {
				bShowBuffs = false,
				bShowDebuffs = false,
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
				crAbsorbValue = "FFFFFFFF",
				strFullSprite = "ForgeUI_Smooth",
			},
			tFocusFrame = {
				bShowShieldBar = true,
				bShowAbsorbBar = true,
				bShowBuffs = false,
				bShowDebuffs = false,
				crBorder = "FF000000",
				crBackground = "FF101010",
				crHpBar = "FF272727",
				crHpValue = "FF75CC26",
				crShieldBar = "FF0699F3",
				crShieldValue = "FFFFFFFF",
				crAbsorbBar = "FFFFC600",
				crAbsorbValue = "FFFFFFFF",
				strFullSprite = "ForgeUI_Smooth",
			}
		}
	}
} 

-----------------------------------------------------------------------------------------------
-- Local varaibles
-----------------------------------------------------------------------------------------------
local tClassEnums = {
	[GameLib.CodeEnumClass.Warrior]      	= "Warrior",
	[GameLib.CodeEnumClass.Engineer]     	= "Engineer",
	[GameLib.CodeEnumClass.Esper]        	= "Esper",
	[GameLib.CodeEnumClass.Medic]        	= "Medic",
	[GameLib.CodeEnumClass.Stalker]      	= "Stalker",
	[GameLib.CodeEnumClass.Spellslinger]	= "Spellslinger"
} 

-----------------------------------------------------------------------------------------------
-- ForgeAPI
-----------------------------------------------------------------------------------------------
function ForgeUI_UnitFrames:ForgeAPI_Init()
	self.xmlDoc = XmlDoc.CreateFromFile("..//ForgeUI_UnitFrames//ForgeUI_UnitFrames.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	
	-- buff filter hack
	local BuffFilter = Apollo.GetAddon("BuffFilter")
	if BuffFilter then
		BuffFilter.tBarProviders["ForgeUI_UnitFrames"].tTargetType.TargetOfTarget = "wndToT"
	end
end

function ForgeUI_UnitFrames:OnDocLoaded()
	self.wndPlayerFrame = Apollo.LoadForm(self.xmlDoc, "ForgeUI_PlayerFrame", "FixedHudStratumLow", self)
	self.wndPlayerBuffFrame = Apollo.LoadForm(self.xmlDoc, "PlayerBuffContainerWindow", "FixedHudStratumHigh", self)
	self.wndPlayerDebuffFrame = Apollo.LoadForm(self.xmlDoc, "PlayerDebuffContainerWindow", "FixedHudStratumHigh", self)
	
	self.wndTargetFrame = Apollo.LoadForm(self.xmlDoc, "ForgeUI_TargetFrame", "FixedHudStratumLow", self)
	self.wndTargetBuffFrame = Apollo.LoadForm(self.xmlDoc, "TargetBuffContainerWindow", "FixedHudStratumHigh", self)
	self.wndTargetDebuffFrame = Apollo.LoadForm(self.xmlDoc, "TargetDebuffContainerWindow", "FixedHudStratumHigh", self)
	
	self.wndToTFrame = Apollo.LoadForm(self.xmlDoc, "ForgeUI_ToTFrame", "FixedHudStratumLow", self)
	self.wndToTBuffFrame = self.wndToTFrame:FindChild("BuffContainerWindow")
	self.wndToTDebuffFrame = self.wndToTFrame:FindChild("DebuffContainerWindow")

	self.wndFocusFrame = Apollo.LoadForm(self.xmlDoc, "ForgeUI_FocusFrame", "FixedHudStratumLow", self)
	self.wndFocusBuffFrame = self.wndFocusFrame:FindChild("BuffContainerWindow")
	self.wndFocusDebuffFrame = self.wndFocusFrame:FindChild("DebuffContainerWindow")
	
	if GameLib.GetPlayerUnit() then
		self:OnCharacterCreated()
	else
		Apollo.RegisterEventHandler("CharacterCreated", "OnCharacterCreated", self)
	end
end

function ForgeUI_UnitFrames:ForgeAPI_LoadSettings()
	self:UpdateStyles()
end

-----------------------------------------------------------------------------------------------
-- On next frame
-----------------------------------------------------------------------------------------------
function ForgeUI_UnitFrames:OnNextFrame()
	unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer then return end
	
	self:UpdatePlayerFrame(unitPlayer)
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
	
	self:RefreshStyle_PlayerFrame(unit)
	
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
	
	self:UpdateHPBar(unit, self.wndTargetFrame, "tTargetFrame")
	self:UpdateShieldBar(unit, self.wndTargetFrame)
	self:UpdateAbsorbBar(unit, self.wndTargetFrame)
	self:UpdateInterruptArmor(unit, self.wndTargetFrame)
	
	self.wndTargetBuffFrame:SetUnit(unit)
	self.wndTargetDebuffFrame:SetUnit(unit)
	self.wndTargetFrame:SetData(unit)
	
	self:RefreshStyle_TargetFrame(unit)
	
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
		end
		return
	end
	
	self:UpdateHPBar(unit, self.wndToTFrame)
	
	self.wndToTFrame:FindChild("BuffContainerWindow"):SetUnit(unitSource)
	self.wndToTFrame:FindChild("DebuffContainerWindow"):SetUnit(unitSource)
	
	self:RefreshStyle_TotFrame(unit)
	
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
	
	self:UpdateHPBar(unit, self.wndFocusFrame)
	self:UpdateInterruptArmor(unit, self.wndFocusFrame)
	if self._DB.profile.tFocusFrame.bShowShieldBar then
		self:UpdateShieldBar(unit, self.wndFocusFrame)
	end
	if self._DB.profile.tFocusFrame.bShowAbsorbBar then
		self:UpdateAbsorbBar(unit, self.wndFocusFrame)
	end
	
	self.wndFocusFrame:FindChild("BuffContainerWindow"):SetUnit(unitSource)
	self.wndFocusFrame:FindChild("DebuffContainerWindow"):SetUnit(unitSource)
	
	self:RefreshStyle_FocusFrame(unit)
	
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
		
		if strSettings ~= nil and self._DB.profile[strSettings].bUseGradient then
			local nPercent = Util:Round((unit:GetHealth() / unit:GetMaxHealth()) * 100, 0)
			local crGradient = Util:GenerateGradient(self._DB.profile[strSettings].crHpBarGradient, self._DB.profile[strSettings].crHpBar, 100, nPercent, true)
			wnd:FindChild("HP_ProgressBar"):SetBarColor(crGradient)
		end
		
		if wnd:FindChild("HP_TextValue") ~= nil then
			wnd:FindChild("HP_TextValue"):SetText(Util:ShortNum(unit:GetHealth()))
			wnd:FindChild("HP_TextPercent"):SetText(Util:Round((unit:GetHealth() / unit:GetMaxHealth()) * 100, 1) .. "%")
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
			wnd:FindChild("Shield_TextValue"):SetText(Util:ShortNum(unit:GetShieldCapacity()))
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
			wnd:FindChild("Absorb_TextValue"):SetText(Util:ShortNum(unit:GetAbsorptionValue()))
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

-----------------------------------------------------------------------------------------------
-- On character created
-----------------------------------------------------------------------------------------------

function ForgeUI_UnitFrames:OnCharacterCreated()
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil then
		Print("ForgeUI ERROR: Wrong class")
		return
	end
	
	Apollo.RegisterEventHandler("VarChange_FrameCount", 	"OnNextFrame", self)
end

-----------------------------------------------------------------------------------------------
-- Styles
-----------------------------------------------------------------------------------------------

function ForgeUI_UnitFrames:UpdateStyles()
	self:LoadStyle_PlayerFrame()
	self:UpdateStyle_PlayerFrame()
	
	self:LoadStyle_TargetFrame()
	self:UpdateStyle_TargetFrame()
	
	self:LoadStyle_TotFrame()
	self:UpdateStyle_TotFrame()
	
	self:LoadStyle_FocusFrame()
	self:UpdateStyle_FocusFrame()
end

function ForgeUI_UnitFrames:LoadStyle_PlayerFrame()
end

function ForgeUI_UnitFrames:UpdateStyle_PlayerFrame()
	unit = GameLib.GetPlayerUnit()
	if not unit or not self.wndPlayerFrame then return end

	self.wndPlayerFrame:FindChild("Name"):SetText(unit:GetName())
	self.wndPlayerFrame:FindChild("Name"):SetTextColor(F:API_GetClassColor(tClassEnums[unit:GetClassId()]))

	self.wndPlayerFrame:FindChild("HPBar"):SetBGColor(self._DB.profile.tPlayerFrame.crBorder)
	self.wndPlayerFrame:FindChild("Background"):SetBGColor(self._DB.profile.tPlayerFrame.crBackground)
	self.wndPlayerFrame:FindChild("HP_ProgressBar"):SetBarColor(self._DB.profile.tPlayerFrame.crHpBar)
	self.wndPlayerFrame:FindChild("HP_ProgressBar"):SetFullSprite(self._DB.profile.tPlayerFrame.strFullSprite)
	self.wndPlayerFrame:FindChild("HP_TextValue"):SetTextColor(self._DB.profile.tPlayerFrame.crHpValue)
	self.wndPlayerFrame:FindChild("HP_TextPercent"):SetTextColor(self._DB.profile.tPlayerFrame.crHpValue)
	self.wndPlayerFrame:FindChild("Shield_ProgressBar"):SetBarColor(self._DB.profile.tPlayerFrame.crShieldBar)
	self.wndPlayerFrame:FindChild("Shield_ProgressBar"):SetFullSprite(self._DB.profile.tPlayerFrame.strFullSprite)
	self.wndPlayerFrame:FindChild("Shield_TextValue"):SetTextColor(self._DB.profile.tPlayerFrame.crShieldValue)
	self.wndPlayerFrame:FindChild("Absorb_ProgressBar"):SetBarColor(self._DB.profile.tPlayerFrame.crAbsorbBar)
	self.wndPlayerFrame:FindChild("Absorb_ProgressBar"):SetFullSprite(self._DB.profile.tPlayerFrame.strFullSprite)
	self.wndPlayerFrame:FindChild("Absorb_TextValue"):SetTextColor(self._DB.profile.tPlayerFrame.crAbsorbValue)
end

function ForgeUI_UnitFrames:RefreshStyle_PlayerFrame()
end

function ForgeUI_UnitFrames:LoadStyle_TargetFrame()
end

function ForgeUI_UnitFrames:UpdateStyle_TargetFrame()
	self.wndTargetFrame:FindChild("HPBar"):SetBGColor(self._DB.profile.tTargetFrame.crBorder)
	self.wndTargetFrame:FindChild("Background"):SetBGColor(self._DB.profile.tTargetFrame.crBackground)
	self.wndTargetFrame:FindChild("HP_ProgressBar"):SetBarColor(self._DB.profile.tTargetFrame.crHpBar)
	self.wndTargetFrame:FindChild("HP_TextValue"):SetTextColor(self._DB.profile.tTargetFrame.crHpValue)
	self.wndTargetFrame:FindChild("HP_TextPercent"):SetTextColor(self._DB.profile.tTargetFrame.crHpValue)
	self.wndTargetFrame:FindChild("Shield_ProgressBar"):SetBarColor(self._DB.profile.tTargetFrame.crShieldBar)
	self.wndTargetFrame:FindChild("Shield_TextValue"):SetTextColor(self._DB.profile.tTargetFrame.crShieldValue)
	self.wndTargetFrame:FindChild("Absorb_ProgressBar"):SetBarColor(self._DB.profile.tTargetFrame.crAbsorbBar)
	self.wndTargetFrame:FindChild("Absorb_TextValue"):SetTextColor(self._DB.profile.tTargetFrame.crAbsorbValue)
end

function ForgeUI_UnitFrames:RefreshStyle_TargetFrame(unit)
	local _name = self.wndTargetFrame:FindChild("Name")

	_name:SetText(unit:GetName())
	if unit:GetClassId() ~= 23 then
		_name:SetTextColor(F:API_GetClassColor(tClassEnums[unit:GetClassId()]))
	else
		_name:SetTextColor(unit:GetNameplateColor())
	end
end

function ForgeUI_UnitFrames:LoadStyle_FocusFrame()
end

function ForgeUI_UnitFrames:UpdateStyle_FocusFrame()
	self.wndFocusFrame:FindChild("HPBar"):SetBGColor(self._DB.profile.tFocusFrame.crBorder)
	self.wndFocusFrame:FindChild("Background"):SetBGColor(self._DB.profile.tFocusFrame.crBackground)
	self.wndFocusFrame:FindChild("HP_ProgressBar"):SetBarColor(self._DB.profile.tFocusFrame.crHpBar)
	self.wndFocusFrame:FindChild("HP_TextValue"):SetTextColor(self._DB.profile.tFocusFrame.crHpValue)
	self.wndFocusFrame:FindChild("HP_TextPercent"):SetTextColor(self._DB.profile.tFocusFrame.crHpValue)
	self.wndFocusFrame:FindChild("Shield_ProgressBar"):SetBarColor(self._DB.profile.tFocusFrame.crShieldBar)
	self.wndFocusFrame:FindChild("Shield_TextValue"):SetTextColor(self._DB.profile.tFocusFrame.crShieldValue)
	self.wndFocusFrame:FindChild("Absorb_ProgressBar"):SetBarColor(self._DB.profile.tFocusFrame.crAbsorbBar)
	self.wndFocusFrame:FindChild("Absorb_TextValue"):SetTextColor(self._DB.profile.tFocusFrame.crAbsorbValue)
	
	self.wndFocusFrame:FindChild("ShieldBar"):Show(self._DB.profile.tFocusFrame.bShowShieldBar, true)
	self.wndFocusFrame:FindChild("AbsorbBar"):Show(self._DB.profile.tFocusFrame.bShowAbsorbBar, true)
	
	self.wndFocusFrame:FindChild("BuffContainerWindow"):Show(self._DB.profile.tFocusFrame.bShowBuffs)
	self.wndFocusFrame:FindChild("DebuffContainerWindow"):Show(self._DB.profile.tFocusFrame.bShowDebuffs)
end

function ForgeUI_UnitFrames:RefreshStyle_FocusFrame(unit)
	local _name = self.wndFocusFrame:FindChild("Name")

	_name:SetText(unit:GetName())
	if unit:GetClassId() ~= 23 then
		_name:SetTextColor(F:API_GetClassColor(tClassEnums[unit:GetClassId()]))
	else
		_name:SetTextColor(unit:GetNameplateColor())
	end
end

function ForgeUI_UnitFrames:LoadStyle_TotFrame()
end

function ForgeUI_UnitFrames:UpdateStyle_TotFrame()
	self.wndToTFrame:FindChild("HPBar"):SetBGColor(self._DB.profile.tTotFrame.crBorder)
	self.wndToTFrame:FindChild("Background"):SetBGColor(self._DB.profile.tTotFrame.crBackground)
	self.wndToTFrame:FindChild("HP_ProgressBar"):SetBarColor(self._DB.profile.tTotFrame.crHpBar)
	
	self.wndToTFrame:FindChild("BuffContainerWindow"):Show(self._DB.profile.tTotFrame.bShowBuffs)
	self.wndToTFrame:FindChild("DebuffContainerWindow"):Show(self._DB.profile.tTotFrame.bShowDebuffs)
end

function ForgeUI_UnitFrames:RefreshStyle_TotFrame(unit)
	local _name = self.wndToTFrame:FindChild("Name")

	_name:SetText(unit:GetName())
	if unit:GetClassId() ~= 23 then
		_name:SetTextColor(F:API_GetClassColor(tClassEnums[unit:GetClassId()]))
	else
		_name:SetTextColor(unit:GetNameplateColor())
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

F:API_NewAddon(ForgeUI_UnitFrames)

