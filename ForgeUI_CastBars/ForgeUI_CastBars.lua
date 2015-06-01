----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI addon
--
-- name: 		ForgeUI_CastBars.lua
-- author:		Winty Badass@Jabbit
-- about:		Cast bars meter addon for ForgeUI
-----------------------------------------------------------------------------------------------

require "Window"

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI

local Util = F:API_GetModule("util")

-----------------------------------------------------------------------------------------------
-- ForgeUI Addon Definition
-----------------------------------------------------------------------------------------------
local ForgeUI_CastBars = {
	_NAME = "ForgeUI_CastBars",
	_API_VERSION = 3,
	_VERSION = "2.0",
	_DB = {},
	DISPLAY_NAME = "Cast bars",

	tSettings = {
		profile = {
			bSmoothBars = true,
			bShowTarget = true,
			bShowFocus = true,
			tFrames = {
				Player = {
					bShowCastIcons = true,
					crBorder = "FF000000",
					crBackground = "FF101010",
					crCastBar = "FF272727",
					crCastBarTarget = "FF272727",
					crInfArmorTarget = "FFEA0707",
					crCastBarFocus = "FF272727",
					crInfArmorFocus = "FFEA0707",
					crMooBar = "FFBC00BB",
					crDuration = "FFFFCC00",
					crText = "FFFFFFFF",
				}
			}
		}
	}
}

-----------------------------------------------------------------------------------------------
-- ForgeAPI
-----------------------------------------------------------------------------------------------
function ForgeUI_CastBars:ForgeAPI_Init()
	self.xmlDoc = XmlDoc.CreateFromFile("..//ForgeUI_CastBars//ForgeUI_CastBars.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)

	local wndParent = F:API_AddMenuItem(self, self.DISPLAY_NAME, "General")
	F:API_AddMenuToMenuItem(self, wndParent, "Player", "Player")
end

function ForgeUI_CastBars:ForgeAPI_LoadSettings()
end

function ForgeUI_CastBars:ForgeAPI_PopulateOptions()
	local wndPlayer = self.tOptionHolders["Player"]

	for k, v in pairs(self._DB.profile.tFrames) do
		if v.crCastBar then
			G:API_AddColorBox(self, wndPlayer, "Cast bar color", v, "crCastBar", { tMove = {0, 0},
				fnCallback = function(...) self["wnd" .. k .. "CastBar"]:FindChild("CastBar"):SetBarColor(arg[2]) end
			})
		end
	end
end

-----------------------------------------------------------------------------------------------
-- Addon functions
-----------------------------------------------------------------------------------------------
function ForgeUI_CastBars:OnDocLoaded()
	self.wndPlayerCastBar = Apollo.LoadForm(self.xmlDoc, "PlayerCastBar", "FixedHudStratum", self)
	self.wndTargetCastBar = Apollo.LoadForm(self.xmlDoc, "TargetCastBar", "FixedHudStratum", self)
	self.wndFocusCastBar = Apollo.LoadForm(self.xmlDoc, "FocusCastBar", "FixedHudStratum", self)

	if self._DB.profile.bSmoothBars == true then
		Apollo.RegisterEventHandler("NextFrame", 	"OnNextFrame", self)
	else
		Apollo.RegisterEventHandler("VarChange_FrameCount", 	"OnNextFrame", self)
	end
	Apollo.RegisterEventHandler("StartSpellThreshold", 	"OnStartSpellThreshold", self)
	Apollo.RegisterEventHandler("ClearSpellThreshold", 	"OnClearSpellThreshold", self)
	Apollo.RegisterEventHandler("UpdateSpellThreshold", "OnUpdateSpellThreshold", self)
end

function ForgeUI_CastBars:OnNextFrame()
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end

	self:UpdateCastBar(unitPlayer, self.wndPlayerCastBar)
	self:RefreshStyle_PlayerCastBar(unitPlayer, self.wndPlayerCastBar)

	local unitTarget = unitPlayer:GetTarget()
	if unitTarget ~= nil and unitTarget:IsValid() and self._DB.profile.bShowTarget then
		self:UpdateCastBar(unitTarget, self.wndTargetCastBar)
		self:UpdateMoOBar(unitTarget, self.wndTargetCastBar)
		self:UpdateInterruptArmor(unitTarget, self.wndTargetCastBar)

		self:RefreshStyle_TargetCastBar(unitTarget, self.wndTargetCastBar)
	else
		if self.wndTargetCastBar:IsShown() then
			self.wndTargetCastBar:Show(false, true)
		end
	end

	local unitFocus = unitPlayer:GetAlternateTarget()
	if unitFocus ~= nil and unitFocus:IsValid() and self._DB.profile.bShowFocus then
		self:UpdateCastBar(unitFocus, self.wndFocusCastBar)
		self:UpdateMoOBar(unitFocus, self.wndFocusCastBar)
		self:UpdateInterruptArmor(unitFocus, self.wndFocusCastBar)

		self:RefreshStyle_FocusCastBar(unitFocus, self.wndFocusCastBar)
	else
		if self.wndFocusCastBar:IsShown() then
			self.wndFocusCastBar:Show(false, true)
		end
	end

	if self.cast ~= nil then
		local fTimeLeft = 1-GameLib.GetSpellThresholdTimePrcntDone(self.cast.id)
		self.wndPlayerCastBar:FindChild("DurationBar"):SetProgress(fTimeLeft)
	else
		self.wndPlayerCastBar:FindChild("DurationBar"):SetProgress(0)
	end
end

function ForgeUI_CastBars:OnStartSpellThreshold(idSpell, nMaxThresholds, eCastMethod)
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end

	local splObject = GameLib.GetSpell(idSpell)

	if self.cast == nil then
		self.cast = {}
		self.cast.id = idSpell
		self.cast.strSpellName = splObject:GetName()
		self.cast.nThreshold = 1
		self.cast.nMaxThreshold = nMaxThresholds

		self.wndPlayerCastBar:FindChild("SpellName"):SetText(self.cast.strSpellName)
		self.wndPlayerCastBar:FindChild("TickBar"):SetMax(nMaxThresholds)
		self.wndPlayerCastBar:FindChild("TickBar"):SetProgress(self.cast.nMaxThreshold - self.cast.nThreshold)
		self.wndPlayerCastBar:FindChild("CastTime"):SetText(self.cast.nThreshold)

		self.wndPlayerCastBar:Show(true, true)
	end
end

function ForgeUI_CastBars:OnUpdateSpellThreshold(idSpell, nNewThreshold)
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() or self.cast == nil then return end

	local splObject = GameLib.GetSpell(idSpell)
	local strSpellName = splObject:GetName()

	self.cast.nThreshold = nNewThreshold

	self.wndPlayerCastBar:FindChild("SpellName"):SetText(strSpellName)
	self.wndPlayerCastBar:FindChild("TickBar"):SetProgress(self.cast.nMaxThreshold - nNewThreshold)

	self.wndPlayerCastBar:FindChild("TickBar"):SetProgress(self.cast.nMaxThreshold - nNewThreshold)

	self.wndPlayerCastBar:FindChild("CastTime"):SetText(nNewThreshold)
end

function ForgeUI_CastBars:OnClearSpellThreshold(idSpell)
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() or self.cast == nil then return end

	self.wndPlayerCastBar:Show(false, true)
	self.wndPlayerCastBar:FindChild("TickBar"):SetProgress(0)

	self.cast = nil
end

function ForgeUI_CastBars:UpdateCastBar(unit, wnd)
	if unit == nil or wnd == nil or unit:IsDead() then return end

	local fDuration
	local fElapsed
	local strSpellName
	local bShowCast = false
	local bShowTick = false

	if unit:ShouldShowCastBar() then
		bShowCast = true

		fDuration = unit:GetCastDuration()
		fElapsed = unit:GetCastElapsed()
		strSpellName = unit:GetCastName()

		wnd:FindChild("SpellName"):SetText(strSpellName)
		wnd:FindChild("CastBar"):SetMax(fDuration)
		wnd:FindChild("CastBar"):SetProgress(fElapsed)
		if wnd:FindChild("Icon") then
			local strIcon = self:GetSpellIconByName(strSpellName)
			if strIcon ~= "" and self._DB.profile.bShowCastIcons then
				wnd:FindChild("Icon"):SetSprite(self:GetSpellIconByName(strSpellName))
				wnd:FindChild("IconHolder"):Show(true, true)
			else
				wnd:FindChild("IconHolder"):Show(false, true)
			end
		end
		wnd:FindChild("CastTime"):SetText(string.format("%00.01f", (fDuration - fElapsed)/1000) .. "s")
	elseif wnd:GetName() ==  "PlayerCastBar" and self.cast ~= nil then
		wnd:FindChild("SpellName"):SetText(self.cast.strSpellName)
		wnd:FindChild("CastTime"):SetText(self.cast.nThreshold)

		local fTimeLeft = 1-GameLib.GetSpellThresholdTimePrcntDone(self.cast.id)
		self.wndPlayerCastBar:FindChild("DurationBar"):SetProgress(fTimeLeft)

		bShowTick = true
	end

	if bShowCast or bShowTick  ~= wnd:IsShown() then
		wnd:Show(bShowCast or bShowTick, true)
	end

	if bShowCast ~= wnd:FindChild("Cast"):IsShown() then
		wnd:FindChild("Cast"):Show(bShowCast, true)
	end

	if bShowTick ~= wnd:FindChild("Tick"):IsShown() then
		wnd:FindChild("Tick"):Show(bShowTick, true)
	end
end

local maxTime = 0
function ForgeUI_CastBars:UpdateMoOBar(unit, wnd)
	if unit == nil or wnd == nil or unit:IsDead() then return end

	local maxTime = unit:GetCCStateTotalTime(Unit.CodeEnumCCState.Vulnerability)
	local time = unit:GetCCStateTimeRemaining(Unit.CodeEnumCCState.Vulnerability)
	local pl = GameLib.GetPlayerUnit()

	if time > 0 then
		--maxTime = time > maxTime and time or maxTime

		wnd:FindChild("MoOBar"):SetMax(maxTime)
		wnd:FindChild("MoOBar"):SetProgress(time)

		wnd:FindChild("SpellName"):SetText("MoO")
		wnd:FindChild("CastTime"):SetText(Util:Round(time, 1))

		if not wnd:IsShown() then
			wnd:Show(true, true)
		end
	else
		wnd:FindChild("MoOBar"):SetProgress(0)
		maxTime = 0
	end
end

function ForgeUI_CastBars:UpdateInterruptArmor(unit, wnd)
	local bShow = false
	nValue = unit:GetInterruptArmorValue()
	nMax = unit:GetInterruptArmorMax()
	if nMax == 0 or nValue == nil or unit:IsDead() then
	else
		bShow = true
		if nMax == -1 then
			wnd:FindChild("InterruptArmor"):SetSprite("ForgeUI_IAinf")
			wnd:FindChild("InterruptArmor_Value"):SetText("")
		elseif nMax > 0 then
			wnd:FindChild("InterruptArmor"):SetSprite("ForgeUI_IA")
			wnd:FindChild("InterruptArmor_Value"):SetText(nValue)
		end
	end

	if bShow ~= wnd:FindChild("InterruptArmor"):IsShown() then
		wnd:FindChild("InterruptArmor"):Show(bShow, true)
	end
end

-----------------------------------------------------------------------------------------------
-- Styles
-----------------------------------------------------------------------------------------------
function ForgeUI_CastBars:UpdateStyle_PlayerCastBar()
	self.wndPlayerCastBar:FindChild("Border"):SetBGColor(self._DB.profile.crBorder)
	self.wndPlayerCastBar:FindChild("Background"):SetBGColor(self._DB.profile.crBackground)
	self.wndPlayerCastBar:FindChild("CastBar"):SetBarColor(self._DB.profile.crCastBar)
	self.wndPlayerCastBar:FindChild("TickBar"):SetBarColor(self._DB.profile.crCastBar)
	self.wndPlayerCastBar:FindChild("DurationBar"):SetBarColor(self._DB.profile.crDuration)
	self.wndPlayerCastBar:FindChild("CastTime"):SetTextColor(self._DB.profile.crText)
	self.wndPlayerCastBar:FindChild("SpellName"):SetTextColor(self._DB.profile.crText)

	if self._DB.profile.bCenterPlayerText then
		self.wndPlayerCastBar:FindChild("SpellName"):SetAnchorOffsets(10, 0, 0, 0)
		self.wndPlayerCastBar:FindChild("SpellName"):SetAnchorPoints(0, 0, 1, 1)

		self.wndPlayerCastBar:FindChild("CastTime"):SetAnchorOffsets(0, 0, -10, 0)
		self.wndPlayerCastBar:FindChild("CastTime"):SetAnchorPoints(0, 0, 1, 1)
	else
		self.wndPlayerCastBar:FindChild("SpellName"):SetAnchorOffsets(10, -10, 0, 15)
		self.wndPlayerCastBar:FindChild("SpellName"):SetAnchorPoints(0, 0, 1, 0)

		self.wndPlayerCastBar:FindChild("CastTime"):SetAnchorOffsets(0, -10, -10, 15)
		self.wndPlayerCastBar:FindChild("CastTime"):SetAnchorPoints(0, 0, 1, 0)
	end
end

function ForgeUI_CastBars:RefreshStyle_PlayerCastBar(unit, wnd)
end

function ForgeUI_CastBars:UpdateStyle_TargetCastBar()
	self.wndTargetCastBar:FindChild("Border"):SetBGColor(self._DB.profile.crBorder)
	self.wndTargetCastBar:FindChild("IconHolder"):SetBGColor(self._DB.profile.crBorder)
	self.wndTargetCastBar:FindChild("Background"):SetBGColor(self._DB.profile.crBackground)
	self.wndTargetCastBar:FindChild("CastBar"):SetBarColor(self._DB.profile.crCastBarTarget)
	self.wndTargetCastBar:FindChild("MoOBar"):SetBarColor(self._DB.profile.crMooBar)
	self.wndTargetCastBar:FindChild("CastTime"):SetTextColor(self._DB.profile.crText)
	self.wndTargetCastBar:FindChild("SpellName"):SetTextColor(self._DB.profile.crText)

	if self._DB.profile.bCenterTargetText then
		self.wndTargetCastBar:FindChild("SpellName"):SetAnchorOffsets(10, 0, 0, 0)
		self.wndTargetCastBar:FindChild("SpellName"):SetAnchorPoints(0, 0, 1, 1)

		self.wndTargetCastBar:FindChild("CastTime"):SetAnchorOffsets(0, 0, -10, 0)
		self.wndTargetCastBar:FindChild("CastTime"):SetAnchorPoints(0, 0, 1, 1)
	else
		self.wndTargetCastBar:FindChild("SpellName"):SetAnchorOffsets(10, -10, 0, 15)
		self.wndTargetCastBar:FindChild("SpellName"):SetAnchorPoints(0, 0, 1, 0)

		self.wndTargetCastBar:FindChild("CastTime"):SetAnchorOffsets(0, -10, -10, 15)
		self.wndTargetCastBar:FindChild("CastTime"):SetAnchorPoints(0, 0, 1, 0)
	end

	local nLeft, nTop, nRight, nBottom = self.wndTargetCastBar:GetAnchorOffsets()
	self.wndTargetCastBar:FindChild("IconHolder"):SetAnchorOffsets(nTop - nBottom - 5, 0, -5, 0)
end

function ForgeUI_CastBars:RefreshStyle_TargetCastBar(unit, wnd)
	local nMax = unit:GetInterruptArmorMax()
	if nMax == -1 then
		wnd:FindChild("CastBar"):SetBarColor(self._DB.profile.crInfArmorTarget)
	else
		wnd:FindChild("CastBar"):SetBarColor(self._DB.profile.crCastBarTarget)
	end
end

function ForgeUI_CastBars:UpdateStyle_FocusCastBar()
	self.wndFocusCastBar:FindChild("Border"):SetBGColor(self._DB.profile.crBorder)
	self.wndFocusCastBar:FindChild("IconHolder"):SetBGColor(self._DB.profile.crBorder)
	self.wndFocusCastBar:FindChild("Background"):SetBGColor(self._DB.profile.crBackground)
	self.wndFocusCastBar:FindChild("CastBar"):SetBarColor(self._DB.profile.crCastBarFocus)
	self.wndFocusCastBar:FindChild("MoOBar"):SetBarColor(self._DB.profile.crMooBar)
	self.wndFocusCastBar:FindChild("CastTime"):SetTextColor(self._DB.profile.crText)
	self.wndFocusCastBar:FindChild("SpellName"):SetTextColor(self._DB.profile.crText)

	if self._DB.profile.bCenterFocusText then
		self.wndFocusCastBar:FindChild("SpellName"):SetAnchorOffsets(10, 0, 0, 0)
		self.wndFocusCastBar:FindChild("SpellName"):SetAnchorPoints(0, 0, 1, 1)

		self.wndFocusCastBar:FindChild("CastTime"):SetAnchorOffsets(0, 0, -10, 0)
		self.wndFocusCastBar:FindChild("CastTime"):SetAnchorPoints(0, 0, 1, 1)
	else
		self.wndFocusCastBar:FindChild("SpellName"):SetAnchorOffsets(10, -10, 0, 15)
		self.wndFocusCastBar:FindChild("SpellName"):SetAnchorPoints(0, 0, 1, 0)

		self.wndFocusCastBar:FindChild("CastTime"):SetAnchorOffsets(0, -10, -10, 15)
		self.wndFocusCastBar:FindChild("CastTime"):SetAnchorPoints(0, 0, 1, 0)
	end

	local nLeft, nTop, nRight, nBottom = self.wndFocusCastBar:GetAnchorOffsets()
	self.wndFocusCastBar:FindChild("IconHolder"):SetAnchorOffsets(nTop - nBottom - 5, 0, -5, 0)
end

function ForgeUI_CastBars:RefreshStyle_FocusCastBar(unit, wnd)
	local nMax = unit:GetInterruptArmorMax()
	if nMax == -1 then
		wnd:FindChild("CastBar"):SetBarColor(self._DB.profile.crInfArmorFocus)
	else
		wnd:FindChild("CastBar"):SetBarColor(self._DB.profile.crCastBarFocus)
	end
end

function ForgeUI_CastBars:GetAbilitiesList()
	if self.abilityNameToIcon == nil then
		self.abilityNameToIcon = {}

		local list = AbilityBook.GetAbilitiesList()
		for _, ability in pairs(list) do
			self.abilityNameToIcon[ability.strName] = ability.tTiers[1].splObject:GetIcon()
		end
	end
	return self.abilityNameToIcon
end

function ForgeUI_CastBars:GetSpellIconByName(spellName)
	local abilities = self:GetAbilitiesList()

	if abilities[spellName] ~= nil then
		return abilities[spellName]
	end

	return ""
end

-----------------------------------------------------------------------------------------------
-- ForgeUI addon registration
-----------------------------------------------------------------------------------------------
F:API_NewAddon(ForgeUI_CastBars)
