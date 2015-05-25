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
	DISPLAY_NAME = "UnitFrames",
	VERSION = "2.0",
	
	tSettings = {
		profile = {
			bHealthClassMob = false,
			tFrames = {
				Player = {
					bUseGradient = false,
					crBorder = "FF000000",
					crBackground = "FF101010",
					crHpBar = "FF272727",
					bHealthClassColor = false,
					crHpBarGradient = "FFFF0000",
					crHpValue = "FF75CC26",
					crName = "FF75CC26",
					bNameClassColor = true,
					crShieldBar = "FF0699F3",
					crShieldValue = "FFFFFFFF",
					crAbsorbBar = "FFFFC600",
					crAbsorbValue = "FFFFFFFF",
					strFullSprite = "ForgeUI_Smooth",
				},
				Target = {
					bUseGradient = false,
					crBorder = "FF000000",
					crBackground = "FF101010",
					crHpBar = "FF272727",
					bHealthClassColor = false,
					crHpBarGradient = "FFFF0000",
					crHpValue = "FF75CC26",
					crName = "FF75CC26",
					bNameClassColor = true,
					crShieldBar = "FF0699F3",
					crShieldValue = "FFFFFFFF",
					crAbsorbBar = "FFFFC600",
					crAbsorbValue = "FFFFFFFF",
					strFullSprite = "ForgeUI_Smooth",
				},
				ToT = {
					bUseGradient = false,
					bShowBuffs = false,
					bShowDebuffs = false,
					crBorder = "FF000000",
					crBackground = "FF101010",
					crHpBar = "FF272727",
					bHealthClassColor = false,
					crHpBarGradient = "FFFF0000",
					crHpValue = "FF75CC26",
					crName = "FF75CC26",
					bNameClassColor = true,
					crShieldBar = "FF0699F3",
					crShieldValue = "FFFFFFFF",
					crAbsorbBar = "FFFFC600",
					crAbsorbValue = "FFFFFFFF",
					strFullSprite = "ForgeUI_Smooth",
				},
				Focus = {
					bUseGradient = false,
					bShowShieldBar = true,
					bShowAbsorbBar = true,
					bShowBuffs = false,
					bShowDebuffs = false,
					crBorder = "FF000000",
					crBackground = "FF101010",
					crHpBar = "FF272727",
					bHealthClassColor = false,
					crHpBarGradient = "FFFF0000",
					crHpValue = "FF75CC26",
					crName = "FF75CC26",
					bNameClassColor = true,
					crShieldBar = "FF0699F3",
					crShieldValue = "FFFFFFFF",
					crAbsorbBar = "FFFFC600",
					crAbsorbValue = "FFFFFFFF",
					strFullSprite = "ForgeUI_Smooth",
				}
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
function ForgeUI_UnitFrames:ForgeAPI_PreInit()
	
end

function ForgeUI_UnitFrames:ForgeAPI_Init()
	self.xmlDoc = XmlDoc.CreateFromFile("..//ForgeUI_UnitFrames//ForgeUI_UnitFrames.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	
	local wndParent = F:API_AddMenuItem(self, self.DISPLAY_NAME)
	F:API_AddMenuToMenuItem(self, wndParent, "Player frame", "Player")
	F:API_AddMenuToMenuItem(self, wndParent, "Target frame", "Target")
	F:API_AddMenuToMenuItem(self, wndParent, "Focus frame", "Focus")
	F:API_AddMenuToMenuItem(self, wndParent, "ToT frame", "ToT")
	F:API_AddMenuToMenuItem(self, wndParent, "Other", "Other")
end

function ForgeUI_UnitFrames:OnDocLoaded()
	self.wndPlayerFrame = Apollo.LoadForm(self.xmlDoc, "ForgeUI_PlayerFrame", "FixedHudStratumLow", self)
	F:API_RegisterMover(self, self.wndPlayerFrame, "UnitFrames_PlayerFrame", "Player frame", "general")
	F:API_RegisterMover(self, self.wndPlayerFrame:FindChild("ShieldBar"), "UnitFrames_PlayerShieldBar", "Shield", "general", { strParent = "UnitFrames_PlayerFrame" })
	F:API_RegisterMover(self, self.wndPlayerFrame:FindChild("AbsorbBar"), "UnitFrames_PlayerAbsorbBar", "Absorb", "general", { strParent = "UnitFrames_PlayerFrame" })
	
	self.wndTargetFrame = Apollo.LoadForm(self.xmlDoc, "ForgeUI_TargetFrame", "FixedHudStratumLow", self)
	F:API_RegisterMover(self, self.wndTargetFrame, "UnitFrames_TargetFrame", "Target frame", "general", {})
	F:API_RegisterMover(self, self.wndTargetFrame:FindChild("ShieldBar"), "UnitFrames_TargetShieldBar", "Shield", "general", { strParent = "UnitFrames_TargetFrame" })
	F:API_RegisterMover(self, self.wndTargetFrame:FindChild("AbsorbBar"), "UnitFrames_TargetAbsorbBar", "Absorb", "general", { strParent = "UnitFrames_TargetFrame" })
	
	self.wndToTFrame = Apollo.LoadForm(self.xmlDoc, "ForgeUI_ToTFrame", "FixedHudStratumLow", self)
	F:API_RegisterMover(self, self.wndToTFrame, "UnitFrames_ToTFrame", "ToT frame", "general", {})

	self.wndFocusFrame = Apollo.LoadForm(self.xmlDoc, "ForgeUI_FocusFrame", "FixedHudStratumLow", self)
	F:API_RegisterMover(self, self.wndFocusFrame, "UnitFrames_FocusFrame", "Focus frame", "general", {})
	F:API_RegisterMover(self, self.wndFocusFrame:FindChild("ShieldBar"), "UnitFrames_FocusShieldBar", "Shield", "general", { strParent = "UnitFrames_FocusFrame" })
	F:API_RegisterMover(self, self.wndFocusFrame:FindChild("AbsorbBar"), "UnitFrames_FocusAbsorbBar", "Absorb", "general", { strParent = "UnitFrames_FocusFrame" })
	
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
		
	self:UpdateHPBar(unit, self.wndPlayerFrame, "Player")
	self:UpdateShieldBar(unit, self.wndPlayerFrame)
	self:UpdateAbsorbBar(unit, self.wndPlayerFrame)
	self:UpdateInterruptArmor(unit, self.wndPlayerFrame)
	
	self.wndPlayerFrame:SetData(unit)
	
	local name = self.wndPlayerFrame:FindChild("Name")
	local hpBar = self.wndPlayerFrame:FindChild("HP_ProgressBar")
	
	self:RefreshStyle(unit, name, hpBar, "Player")
	
	self:UpdateTargetFrame(unit)
	self:UpdateFocusFrame(unit)
end

-- Target Frame
function ForgeUI_UnitFrames:UpdateTargetFrame(unitSource)
	local bShow = false
	local unit = unitSource:GetTarget()
	
	if unit and not F:API_MoversActive() then
		bShow = true
	end
	
	if bShow then
		self:UpdateHPBar(unit, self.wndTargetFrame, "Target")
		self:UpdateShieldBar(unit, self.wndTargetFrame)
		self:UpdateAbsorbBar(unit, self.wndTargetFrame)
		self:UpdateInterruptArmor(unit, self.wndTargetFrame)
		
		self.wndTargetFrame:SetData(unit)
		
		local name = self.wndTargetFrame:FindChild("Name")
		local hpBar = self.wndTargetFrame:FindChild("HP_ProgressBar")
		
		self:RefreshStyle(unit, name, hpBar, "Target")
	end
	
	if bShow ~= self.wndTargetFrame:IsShown() then
		self.wndTargetFrame:Show(bShow, true)
	end
	
	self:UpdateToTFrame(unit)
end

-- ToT Frame
function ForgeUI_UnitFrames:UpdateToTFrame(unitSource)
	local bShow = false
	local unit = unitSource and unitSource:GetTarget()
	
	if unit and not F:API_MoversActive() then
		bShow = true
	end
	
	if bShow then
		self:UpdateHPBar(unit, self.wndToTFrame)
		
		self.wndToTFrame:SetData(unit)
		
		local name = self.wndToTFrame:FindChild("Name")
		local hpBar = self.wndToTFrame:FindChild("HP_ProgressBar")
		
		self:RefreshStyle(unit, name, hpBar, "ToT")
	end
	
	if bShow ~= self.wndToTFrame:IsShown() then
		self.wndToTFrame:Show(bShow, true)
	end
end

-- Focus Frame
function ForgeUI_UnitFrames:UpdateFocusFrame(unitSource)
	local bShow = false
	local unit = unitSource and unitSource:GetAlternateTarget()
	
	if unit and not F:API_MoversActive() then
		bShow = true
	end
	
	if bShow then
		self:UpdateHPBar(unit, self.wndFocusFrame)
		self:UpdateInterruptArmor(unit, self.wndFocusFrame)
		if self._DB.profile.tFrames.Focus.bShowShieldBar then
			self:UpdateShieldBar(unit, self.wndFocusFrame)
		end
		if self._DB.profile.tFrames.Focus.bShowAbsorbBar then
			self:UpdateAbsorbBar(unit, self.wndFocusFrame)
		end
		
		self.wndFocusFrame:SetData(unit)
		
		local name = self.wndFocusFrame:FindChild("Name")
		local hpBar = self.wndFocusFrame:FindChild("HP_ProgressBar")
		
		self:RefreshStyle(unit, name, hpBar, "Focus")
	end
	
	if bShow ~= self.wndFocusFrame:IsShown() then
		self.wndFocusFrame:Show(bShow, true)
	end
end

-- hp bar
function ForgeUI_UnitFrames:UpdateHPBar(unit, wnd, strSettings)
	if unit:GetHealth() ~= nil then
		wnd:FindChild("Background"):Show(true)
		wnd:FindChild("HP_ProgressBar"):SetMax(unit:GetMaxHealth())
		wnd:FindChild("HP_ProgressBar"):SetProgress(unit:GetHealth())
		
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
	self:UpdateStyle_PlayerFrame()
	self:UpdateStyle_TargetFrame()
	self:UpdateStyle_TotFrame()
	self:UpdateStyle_FocusFrame()
end

function ForgeUI_UnitFrames:RefreshStyle(unit, name, hpBar, strType)
	local crHpBar = "FFFFFFFF"
	
	name:SetText(unit:GetName())
	if self._DB.profile.tFrames[strType].bNameClassColor then
		name:SetTextColor(F:API_GetClassColor(unit))
	else
		name:SetTextColor(self._DB.profile.tFrames[strType].crName)
	end
	
	if self._DB.profile.tFrames[strType].bHealthClassColor then
		if unit:GetClassId() == 23 and self._DB.profile.bHealthClassMob then
			crHpBar = F:API_GetClassColor(unit)
		elseif unit:GetClassId() ~= 23 then
			crHpBar = F:API_GetClassColor(unit)
		else
			crHpBar = self._DB.profile.tFrames[strType].crHpBar
		end
	else
		crHpBar = self._DB.profile.tFrames[strType].crHpBar
	end

	if self._DB.profile.tFrames[strType].bUseGradient then
		local nPercent = Util:Round((unit:GetHealth() / unit:GetMaxHealth()) * 100, 0)
		crHpBar = Util:GenerateGradient(self._DB.profile.tFrames[strType].crHpBarGradient, crHpBar, 100, nPercent, true)
	end

	hpBar:SetBarColor(crHpBar)
end

function ForgeUI_UnitFrames:UpdateStyle_PlayerFrame()
	unit = GameLib.GetPlayerUnit()
	if not unit or not self.wndPlayerFrame then return end

	self.wndPlayerFrame:FindChild("Name"):SetText(unit:GetName())
	if self._DB.profile.tFrames.Player.bNameClassColor then
		self.wndPlayerFrame:FindChild("Name"):SetTextColor(F:API_GetClassColor(tClassEnums[unit:GetClassId()]))
	else
		self.wndPlayerFrame:FindChild("Name"):SetTextColor(self._DB.profile.tFrames.Player.crName)
	end
	
	if self._DB.profile.tFrames.Player.bHealthClassColor then
		self.wndPlayerFrame:FindChild("HP_ProgressBar"):SetBarColor(F:API_GetClassColor(unit))
	else
		self.wndPlayerFrame:FindChild("HP_ProgressBar"):SetBarColor(self._DB.profile.tFrames.Player.crHpBar)
	end

	self.wndPlayerFrame:FindChild("HPBar"):SetBGColor(self._DB.profile.tFrames.Player.crBorder)
	self.wndPlayerFrame:FindChild("Background"):SetBGColor(self._DB.profile.tFrames.Player.crBackground)
	self.wndPlayerFrame:FindChild("HP_ProgressBar"):SetFullSprite(self._DB.profile.tFrames.Player.strFullSprite)
	self.wndPlayerFrame:FindChild("HP_TextValue"):SetTextColor(self._DB.profile.tFrames.Player.crHpValue)
	self.wndPlayerFrame:FindChild("HP_TextPercent"):SetTextColor(self._DB.profile.tFrames.Player.crHpValue)
	self.wndPlayerFrame:FindChild("Shield_ProgressBar"):SetBarColor(self._DB.profile.tFrames.Player.crShieldBar)
	self.wndPlayerFrame:FindChild("Shield_ProgressBar"):SetFullSprite(self._DB.profile.tFrames.Player.strFullSprite)
	self.wndPlayerFrame:FindChild("Shield_TextValue"):SetTextColor(self._DB.profile.tFrames.Player.crShieldValue)
	self.wndPlayerFrame:FindChild("Absorb_ProgressBar"):SetBarColor(self._DB.profile.tFrames.Player.crAbsorbBar)
	self.wndPlayerFrame:FindChild("Absorb_ProgressBar"):SetFullSprite(self._DB.profile.tFrames.Player.strFullSprite)
	self.wndPlayerFrame:FindChild("Absorb_TextValue"):SetTextColor(self._DB.profile.tFrames.Player.crAbsorbValue)
end

function ForgeUI_UnitFrames:UpdateStyle_TargetFrame()
	self.wndTargetFrame:FindChild("HPBar"):SetBGColor(self._DB.profile.tFrames.Target.crBorder)
	self.wndTargetFrame:FindChild("Background"):SetBGColor(self._DB.profile.tFrames.Target.crBackground)
	self.wndTargetFrame:FindChild("HP_ProgressBar"):SetBarColor(self._DB.profile.tFrames.Target.crHpBar)
	self.wndTargetFrame:FindChild("HP_TextValue"):SetTextColor(self._DB.profile.tFrames.Target.crHpValue)
	self.wndTargetFrame:FindChild("HP_TextPercent"):SetTextColor(self._DB.profile.tFrames.Target.crHpValue)
	self.wndTargetFrame:FindChild("Shield_ProgressBar"):SetBarColor(self._DB.profile.tFrames.Target.crShieldBar)
	self.wndTargetFrame:FindChild("Shield_TextValue"):SetTextColor(self._DB.profile.tFrames.Target.crShieldValue)
	self.wndTargetFrame:FindChild("Absorb_ProgressBar"):SetBarColor(self._DB.profile.tFrames.Target.crAbsorbBar)
	self.wndTargetFrame:FindChild("Absorb_TextValue"):SetTextColor(self._DB.profile.tFrames.Target.crAbsorbValue)
end

function ForgeUI_UnitFrames:UpdateStyle_FocusFrame()
	self.wndFocusFrame:FindChild("HPBar"):SetBGColor(self._DB.profile.tFrames.Focus.crBorder)
	self.wndFocusFrame:FindChild("Background"):SetBGColor(self._DB.profile.tFrames.Focus.crBackground)
	self.wndFocusFrame:FindChild("HP_ProgressBar"):SetBarColor(self._DB.profile.tFrames.Focus.crHpBar)
	self.wndFocusFrame:FindChild("HP_TextValue"):SetTextColor(self._DB.profile.tFrames.Focus.crHpValue)
	self.wndFocusFrame:FindChild("HP_TextPercent"):SetTextColor(self._DB.profile.tFrames.Focus.crHpValue)
	self.wndFocusFrame:FindChild("Shield_ProgressBar"):SetBarColor(self._DB.profile.tFrames.Focus.crShieldBar)
	self.wndFocusFrame:FindChild("Shield_TextValue"):SetTextColor(self._DB.profile.tFrames.Focus.crShieldValue)
	self.wndFocusFrame:FindChild("Absorb_ProgressBar"):SetBarColor(self._DB.profile.tFrames.Focus.crAbsorbBar)
	self.wndFocusFrame:FindChild("Absorb_TextValue"):SetTextColor(self._DB.profile.tFrames.Focus.crAbsorbValue)
	
	self.wndFocusFrame:FindChild("ShieldBar"):Show(self._DB.profile.tFrames.Focus.bShowShieldBar, true)
	self.wndFocusFrame:FindChild("AbsorbBar"):Show(self._DB.profile.tFrames.Focus.bShowAbsorbBar, true)
end

function ForgeUI_UnitFrames:UpdateStyle_TotFrame()
	self.wndToTFrame:FindChild("HPBar"):SetBGColor(self._DB.profile.tFrames.ToT.crBorder)
	self.wndToTFrame:FindChild("Background"):SetBGColor(self._DB.profile.tFrames.ToT.crBackground)
	self.wndToTFrame:FindChild("HP_ProgressBar"):SetBarColor(self._DB.profile.tFrames.ToT.crHpBar)
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

function ForgeUI_UnitFrames:ForgeAPI_PopulateOptions()
	local wnd = self.tOptionHolders["Other"]
	
	G:API_AddCheckBox(self, wnd, "Use class colors for mobs", self._DB.profile, "bHealthClassMob")

	for k, v in pairs(self._DB.profile.tFrames) do
		wnd = self.tOptionHolders[k]
		
		if v.crBorder then
			G:API_AddColorBox(self, wnd, "Border color", v, "crBorder", { tMove = {0, 0}, fnCallback = self["UpdateStyle_" .. k .. "Frame"] })
		end
		
		if v.crBackground then
			G:API_AddColorBox(self, wnd, "Background color", v, "crBackground", { tMove = {0, 30}, fnCallback = self["UpdateStyle_" .. k .. "Frame"] })
		end
		
		if v.crHpBar then
			G:API_AddColorBox(self, wnd, "Health bar color", v, "crHpBar", { tMove = {0, 60}, fnCallback = self["UpdateStyle_" .. k .. "Frame"] })
		end
		
		if v.crHpValue then
			G:API_AddColorBox(self, wnd, "Health value color", v, "crHpValue", { tMove = {0, 90}, fnCallback = self["UpdateStyle_" .. k .. "Frame"] })
		end
		
		if v.crShieldBar then
			G:API_AddColorBox(self, wnd, "Shield bar color", v, "crShieldBar", { tMove = {200, 0}, fnCallback = self["UpdateStyle_" .. k .. "Frame"] })
		end
		
		if v.crShieldValue then
			G:API_AddColorBox(self, wnd, "Shield value color", v, "crShieldValue", { tMove = {400, 0}, fnCallback = self["UpdateStyle_" .. k .. "Frame"] })
		end
		
		if v.crAbsorbBar then
			G:API_AddColorBox(self, wnd, "Absorb bar color", v, "crAbsorbBar", { tMove = {200, 30}, fnCallback = self["UpdateStyle_" .. k .. "Frame"] })
		end
		
		if v.crAbsorbValue then
			G:API_AddColorBox(self, wnd, "Absorb value color", v, "crAbsorbValue", { tMove = {400, 30}, fnCallback = self["UpdateStyle_" .. k .. "Frame"] })
		end
		
		if v.crName then
			G:API_AddColorBox(self, wnd, "Name color", v, "crName", { tMove = {0, 120}, fnCallback = self["UpdateStyle_" .. k .. "Frame"] })
		end
		
		if v.bNameClassColor ~= nil then
			G:API_AddCheckBox(self, wnd, "Class color for name", v, "bNameClassColor", { tMove = {200, 120}, fnCallback = self["UpdateStyle_" .. k .. "Frame"] })
		end
		
		if v.bHealthClassColor ~= nil then
			G:API_AddCheckBox(self, wnd, "Class color for health bar", v, "bHealthClassColor", { tMove = {200, 60}, fnCallback = self["UpdateStyle_" .. k .. "Frame"] })
		end
		
		if v.bUseGradient ~= nil then
			G:API_AddCheckBox(self, wnd, "Gradient health bar", v, "bUseGradient", { tMove = {0, 180} })
		end
		
		if v.crHpBarGradient then
			G:API_AddColorBox(self, wnd, "HP bar gradient", v, "crHpBarGradient", { tMove = {200, 180}, fnCallback = self["UpdateStyle_" .. k .. "Frame"] })
		end
	end
end

F:API_NewAddon(ForgeUI_UnitFrames)

