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
	DISPLAY_NAME = "Cast bars",

	tSettings = {
		profile = {
			bSmoothBars = true,
			bShowPlayer = true,
			bShowTarget = true,
			bShowFocus = true,
			tFrames = {
				Player = {
					bShowCastIcons = true,
					bCenterText = false,
					crBorder = "FF000000",
					crBackground = "FF101010",
					crCastBar = "FF272727",
					crCastBarEx = "FF1591DB",
					crDuration = "FFFFCC00",
					crText = "FFFFFFFF",
					strFullSprite = "ForgeUI_Smooth",
				},
				Target = {
					bShowCastIcons = true,
					bCenterText = false,
					crBorder = "FF000000",
					crBackground = "FF101010",
					crCastBar = "FF272727",
					crCastBarInf = "FFFF0000",
					crMooBar = "FFBC00BB",
					crText = "FFFFFFFF",
					strFullSprite = "ForgeUI_Smooth",
				},
				Focus = {
					bShowCastIcons = true,
					bCenterText = false,
					crBorder = "FF000000",
					crBackground = "FF101010",
					crCastBar = "FF272727",
					crCastBarInf = "FFFF0000",
					crMooBar = "FFBC00BB",
					crText = "FFFFFFFF",
					strFullSprite = "ForgeUI_Smooth",
				}
			}
		}
	}
}

-----------------------------------------------------------------------------------------------
-- Local variables
-----------------------------------------------------------------------------------------------
local GetPlayerUnit = GameLib.GetPlayerUnit

-----------------------------------------------------------------------------------------------
-- ForgeAPI
-----------------------------------------------------------------------------------------------
function ForgeUI_CastBars:ForgeAPI_Init()
	self.xmlDoc = XmlDoc.CreateFromFile("..//ForgeUI_CastBars//ForgeUI_CastBars.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)

	local wndParent = F:API_AddMenuItem(self, self.DISPLAY_NAME, "General")
	F:API_AddMenuToMenuItem(self, wndParent, "Player", "Player")
	F:API_AddMenuToMenuItem(self, wndParent, "Target", "Target")
	F:API_AddMenuToMenuItem(self, wndParent, "Focus", "Focus")
end

-----------------------------------------------------------------------------------------------
-- Addon functions
-----------------------------------------------------------------------------------------------
function ForgeUI_CastBars:OnDocLoaded()
	self.wndPlayerCastBar = Apollo.LoadForm(self.xmlDoc, "PlayerCastBar", F:API_GetStratum("Hud"), self)
	self.wndTargetCastBar = Apollo.LoadForm(self.xmlDoc, "TargetCastBar", F:API_GetStratum("Hud"), self)
	self.wndFocusCastBar = Apollo.LoadForm(self.xmlDoc, "FocusCastBar", F:API_GetStratum("Hud"), self)

	F:API_RegisterMover(self, self.wndPlayerCastBar, "CastBars_Player", "Player's cast bar", "general")
	F:API_RegisterMover(self, self.wndTargetCastBar, "CastBars_Target", "Target's cast bar", "general")
	F:API_RegisterMover(self, self.wndFocusCastBar, "CastBars_Focus", "Focus' cast bar", "general")

	F:API_RegisterMover(self, self.wndTargetCastBar:FindChild("InterruptArmor"), "CastBars_Target_IA", "IA", "general", {
		strParent = "CastBars_Target"
	})
	F:API_RegisterMover(self, self.wndFocusCastBar:FindChild("InterruptArmor"), "CastBars_Focus_IA", "IA", "general", {
		strParent = "CastBars_Focus"
	})

	Apollo.RegisterEventHandler("StartSpellThreshold", 	"OnStartSpellThreshold", self)
	Apollo.RegisterEventHandler("ClearSpellThreshold", 	"OnClearSpellThreshold", self)
	Apollo.RegisterEventHandler("UpdateSpellThreshold", "OnUpdateSpellThreshold", self)
end

function ForgeUI_CastBars:OnNextFrame()
	local unitPlayer = GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end

	if self._DB.profile.bShowPlayer then
		self:UpdateCastBar(unitPlayer, self.wndPlayerCastBar, "Player")
	else
		if self.wndPlayerCastBar:IsShown() then
			self.wndPlayerCastBar:Show(false, true)
		end
	end

	local unitTarget = unitPlayer:GetTarget()
	if unitTarget ~= nil and unitTarget:IsValid() and self._DB.profile.bShowTarget then
		self:UpdateCastBar(unitTarget, self.wndTargetCastBar, "Target")
		self:UpdateMoOBar(unitTarget, self.wndTargetCastBar, "Target")
		self:UpdateInterruptArmor(unitTarget, self.wndTargetCastBar, "Target")
	else
		if self.wndTargetCastBar:IsShown() then
			self.wndTargetCastBar:Show(false, true)
		end
	end

	local unitFocus = unitPlayer:GetAlternateTarget()
	if unitFocus ~= nil and unitFocus:IsValid() and self._DB.profile.bShowFocus then
		self:UpdateCastBar(unitFocus, self.wndFocusCastBar, "Focus")
		self:UpdateMoOBar(unitFocus, self.wndFocusCastBar, "Focus")
		self:UpdateInterruptArmor(unitFocus, self.wndFocusCastBar, "Focus")
	else
		if self.wndFocusCastBar:IsShown() then
			self.wndFocusCastBar:Show(false, true)
		end
	end
end

function ForgeUI_CastBars:OnStartSpellThreshold(idSpell, nMaxThresholds, eCastMethod) -- Event
	if not self._DB.profile.bShowPlayer then return end

	local unitPlayer = GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end

	self.tTapCast = self.tTapCast or {}

	local _strSpellName = GameLib.GetSpell(idSpell):GetName()

	for k, v in pairs(self.tTapCast) do
		if k ~= _strSpellName and v.bActive then
			v.bActive = false
		end
	end

	if eCastMethod == Spell.CodeEnumCastMethod.ChargeRelease then
		if self.tTapCast[_strSpellName] then return end
	end

	self.tTapCast[_strSpellName] = {
		nIdSpell = idSpell,
		nCastMethod = eCastMethod,
		strSpellName = _strSpellName,
		nThreshold = 1,
		nMaxThreshold = nMaxThresholds,
		bActive = true,
	}
end

function ForgeUI_CastBars:OnUpdateSpellThreshold(idSpell, nNewThreshold) -- Event
	if not self._DB.profile.bShowPlayer then return end

	local unitPlayer = GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end

	self.tTapCast = self.tTapCast or {}

	local _strSpellName = GameLib.GetSpell(idSpell):GetName()

	for k, v in pairs(self.tTapCast) do
		if k ~= _strSpellName and v.bActive then
			v.bActive = false
		end
	end

	if self.tTapCast[_strSpellName] then
		self.tTapCast[_strSpellName].nThreshold = nNewThreshold
		self.tTapCast[_strSpellName].bActive = true
	end
end

function ForgeUI_CastBars:OnClearSpellThreshold(idSpell) -- Event
	if not self._DB.profile.bShowPlayer then return end

	local unitPlayer = GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end

	self.tTapCast = self.tTapCast or {}

	local _strSpellName = GameLib.GetSpell(idSpell):GetName()

	self.tTapCast[_strSpellName] = nil

	-- when tapCast ends we look for any other tapCast with lowest time remaining
	local tDummyCast = { strSpellName = "", nThresholdTimePrcntDone = 0 }
	for k, v in pairs(self.tTapCast) do
		local n = GameLib.GetSpellThresholdTimePrcntDone(v.nIdSpell)
		if tDummyCast.nThresholdTimePrcntDone == 0 or tDummyCast.nThresholdTimePrcntDone > n then
			tDummyCast.strSpellName = k
			tDummyCast.nThresholdTimePrcntDone = n
		end
	end

	-- if found, make that tapCast active
	if self.tTapCast[tDummyCast.strSpellName] then
		self.tTapCast[tDummyCast.strSpellName].bActive = true
	end
end

function ForgeUI_CastBars:IsTapCasting()
	if self.tTapCast == nil then return false end

	for k, v in pairs(self.tTapCast) do
		if v.bActive then return true end
	end

	return false
end

function ForgeUI_CastBars:GetTapCastByName(strCastName)
	if self.tTapCast == nil then return nil end

	for k, v in pairs(self.tTapCast) do
		if v.strSpellName == strCastName then return v end
	end

	return nil
end

function ForgeUI_CastBars:GetActiveTapCast()
	if self.tTapCast == nil then return nil end

	for k, v in pairs(self.tTapCast) do
		if v.bActive then return v end
	end

	return nil
end

function ForgeUI_CastBars:UpdateCastBar(unit, wnd, strType)
	if unit == nil or wnd == nil or unit:IsDead() then return end

	local fDuration
	local fElapsed
	local strSpellName
	local bShowCast = false
	local bShowCastEx = false
	local bShowDuration = false

	if strType == "Player" then
		local bIsCasting = unit:IsCasting() and unit:ShouldShowCastBar()
		local bIsTapCasting = self:IsTapCasting()

		fDuration = unit:GetCastDuration()
		fElapsed = unit:GetCastElapsed()
		strSpellName = unit:GetCastName()

		local tTapCastByName = self:GetTapCastByName(strSpellName)
		local tTapCastActive = self:GetActiveTapCast()

		bShowCast = bIsCasting or bIsTapCasting
		bShowCastEx = tTapCastByName and bIsCasting
		bShowDuration = (tTapCastByName and bIsCasting) or (tTapCastActive and not bIsCasting)

		if bShowDuration then
			local tTapCast = tTapCastByName or tTapCastActive
			wnd:FindChild("SpellName"):SetText(tTapCast.strSpellName)
			wnd:FindChild("CastTime"):SetText(tTapCast.nThreshold)
			wnd:FindChild("CastBar"):SetMax(tTapCast.nMaxThreshold)
			wnd:FindChild("CastBar"):SetProgress(tTapCast.nThreshold)
			wnd:FindChild("DurationBar"):SetProgress(1-GameLib.GetSpellThresholdTimePrcntDone(tTapCast.nIdSpell))
		else
			wnd:FindChild("SpellName"):SetText(strSpellName)
			wnd:FindChild("CastTime"):SetText(string.format("%00.01f", (fDuration - fElapsed)/1000) .. "s")
			wnd:FindChild("CastBar"):SetMax(fDuration)
			wnd:FindChild("CastBar"):SetProgress(fElapsed)
		end

		if bShowCastEx then
			wnd:FindChild("CastBarEx"):SetMax(fDuration)
			wnd:FindChild("CastBarEx"):SetProgress(fElapsed)
		end

	elseif unit:ShouldShowCastBar() then
		bShowCast = true

		fDuration = unit:GetCastDuration()
		fElapsed = unit:GetCastElapsed()
		strSpellName = unit:GetCastName()

		wnd:FindChild("SpellName"):SetText(strSpellName)
		wnd:FindChild("CastBar"):SetMax(fDuration)
		wnd:FindChild("CastBar"):SetProgress(fElapsed)

		-- if wnd:FindChild("Icon") then -- TODO: make it work
		-- 	local strIcon = self:GetSpellIconByName(strSpellName)
		-- 	if strIcon ~= "" and self._DB.profile.bShowCastIcons then
		-- 		wnd:FindChild("Icon"):SetSprite(self:GetSpellIconByName(strSpellName))
		-- 		wnd:FindChild("IconHolder"):Show(true, true)
		-- 	else
		-- 		wnd:FindChild("IconHolder"):Show(false, true)
		-- 	end
		-- end

		wnd:FindChild("CastTime"):SetText(string.format("%00.01f", (fDuration - fElapsed)/1000) .. "s")
	end

	if bShowCast ~= wnd:IsShown() then
		wnd:Show(bShowCast, true)
	end

	local wndCastBar = wnd:FindChild("Cast")
	local wndCastBarEx = wnd:FindChild("CastBarEx")
	local wndDuration = wnd:FindChild("DurationBar")

	if bShowCast ~= wndCastBar:IsShown() then
		wndCastBar:Show(bShowCast, true)
	end

	if wndCastBarEx and bShowCastEx ~= wndCastBarEx:IsShown() then
		wndCastBarEx:Show(bShowCastEx, true)
	end

	if wndDuration and bShowDuration ~= wndDuration:IsShown() then
		wndDuration:Show(bShowDuration, true)
	end

end

function ForgeUI_CastBars:UpdateMoOBar(unit, wnd, strType)
	if unit == nil or wnd == nil or unit:IsDead() then return end

	if unit:IsInCCState(Unit.CodeEnumCCState.Vulnerability) then

		local maxTime = unit:GetCCStateTotalTime(Unit.CodeEnumCCState.Vulnerability)
		local time = unit:GetCCStateTimeRemaining(Unit.CodeEnumCCState.Vulnerability)

		if time > 0 then

			wnd:FindChild("MoOBar"):SetMax(maxTime)
			wnd:FindChild("MoOBar"):SetProgress(time)

			wnd:FindChild("SpellName"):SetText("MoO")
			wnd:FindChild("CastTime"):SetText(Util:Round(time, 1))

			if not wnd:IsShown() then
				wnd:Show(true, true)
			end
		end
	else
		wnd:FindChild("MoOBar"):SetProgress(0)
	end
end

function ForgeUI_CastBars:UpdateInterruptArmor(unit, wnd, strType)
	local bShow = false
	nValue = unit:GetInterruptArmorValue()
	nMax = unit:GetInterruptArmorMax()
	if nMax == 0 or nValue == nil or unit:IsDead() then
		wnd:FindChild("CastBar"):SetBarColor(self._DB.profile.tFrames[strType].crCastBar)
	else
		bShow = true
		if nMax == -1 then
			wnd:FindChild("InterruptArmor"):SetSprite("HUD_TargetFrame:spr_TargetFrame_InterruptArmor_Infinite")
			wnd:FindChild("InterruptArmor_Value"):SetText("")
			wnd:FindChild("CastBar"):SetBarColor(self._DB.profile.tFrames[strType].crCastBarInf)
		elseif nMax > 0 then
			wnd:FindChild("InterruptArmor"):SetSprite("HUD_TargetFrame:spr_TargetFrame_InterruptArmor_Value")
			wnd:FindChild("InterruptArmor_Value"):SetText(nValue)
			wnd:FindChild("CastBar"):SetBarColor(self._DB.profile.tFrames[strType].crCastBar)
		end
	end

	if bShow ~= wnd:FindChild("InterruptArmor"):IsShown() then
		wnd:FindChild("InterruptArmor"):Show(bShow, true)
	end
end

-----------------------------------------------------------------------------------------------
-- ForgeAPI
-----------------------------------------------------------------------------------------------
function ForgeUI_CastBars:ForgeAPI_LoadSettings()
	if self._DB.profile.bSmoothBars then
		Apollo.RegisterEventHandler("NextFrame", 	"OnNextFrame", self)
		Apollo.RemoveEventHandler("VarChange_FrameCount", self)
	else
		Apollo.RegisterEventHandler("VarChange_FrameCount", "OnNextFrame", self)
		Apollo.RemoveEventHandler("NextFrame", self)
	end

	for k, v in pairs(self._DB.profile.tFrames) do
		if v.bCenterText then
			self["wnd" .. k .. "CastBar"]:FindChild("SpellName"):SetAnchorOffsets(10, 0, 0, 0)
			self["wnd" .. k .. "CastBar"]:FindChild("SpellName"):SetAnchorPoints(0, 0, 1, 1)

			self["wnd" .. k .. "CastBar"]:FindChild("CastTime"):SetAnchorOffsets(0, 0, -10, 0)
			self["wnd" .. k .. "CastBar"]:FindChild("CastTime"):SetAnchorPoints(0, 0, 1, 1)
		else
			self["wnd" .. k .. "CastBar"]:FindChild("SpellName"):SetAnchorOffsets(10, -10, 0, 15)
			self["wnd" .. k .. "CastBar"]:FindChild("SpellName"):SetAnchorPoints(0, 0, 1, 0)

			self["wnd" .. k .. "CastBar"]:FindChild("CastTime"):SetAnchorOffsets(0, -10, -10, 15)
			self["wnd" .. k .. "CastBar"]:FindChild("CastTime"):SetAnchorPoints(0, 0, 1, 0)
		end

		if v.strFullSprite ~= nil then
			self["wnd" .. k .. "CastBar"]:FindChild("CastBar"):SetFullSprite(v.strFullSprite)
		end
	end
end

function ForgeUI_CastBars:ForgeAPI_PopulateOptions()
	local wndGeneral = self.tOptionHolders["General"]
	G:API_AddCheckBox(self, wndGeneral, "Smooth bars", self._DB.profile, "bSmoothBars", { tMove = {0, 0},
		fnCallback = self.ForgeAPI_LoadSettings
	})

	G:API_AddCheckBox(self, wndGeneral, "Enable player's cast bar", self._DB.profile, "bShowPlayer", { tMove = {0, 30} })
	G:API_AddCheckBox(self, wndGeneral, "Enable target's cast bar", self._DB.profile, "bShowTarget", { tMove = {200, 30} })
	G:API_AddCheckBox(self, wndGeneral, "Enable focus' cast bar", self._DB.profile, "bShowFocus", { tMove = {400, 30} })

	for k, v in pairs(self._DB.profile.tFrames) do
		if v.crBorder then
			G:API_AddColorBox(self, self.tOptionHolders[k], "Border color", v, "crBorder", { tMove = {0, 0},
				fnCallback = function(...) self["wnd" .. k .. "CastBar"]:FindChild("Border"):SetBGColor(arg[2]) end
			})
		end

		if v.crBackground then
			G:API_AddColorBox(self, self.tOptionHolders[k], "Background color", v, "crBackground", { tMove = {200, 0},
				fnCallback = function(...) self["wnd" .. k .. "CastBar"]:FindChild("Background"):SetBGColor(arg[2]) end
			})
		end

		if v.crCastBar then
			G:API_AddColorBox(self, self.tOptionHolders[k], "Cast bar color", v, "crCastBar", { tMove = {0, 30},
				fnCallback = function(...)
					self["wnd" .. k .. "CastBar"]:FindChild("CastBar"):SetBarColor(arg[2])
				end
			})
		end


		if v.crCastBarInf then
			G:API_AddColorBox(self, self.tOptionHolders[k], "Cast bar color - infinite IA", v, "crCastBarInf", { tMove = {200, 30},
				fnCallback = function(...)
					self["wnd" .. k .. "CastBar"]:FindChild("CastBar"):SetBarColor(arg[2])
				end
			})
		end

		if v.crMooBar then
			G:API_AddColorBox(self, self.tOptionHolders[k], "MoO bar color", v, "crMooBar", { tMove = {200, 60},
				fnCallback = function(...) self["wnd" .. k .. "CastBar"]:FindChild("MoOBar"):SetBarColor(arg[2]) end
			})
		end

		if v.crCastBarEx then
			G:API_AddColorBox(self, self.tOptionHolders[k], "Extra cast bar color ", v, "crCastBarEx", { tMove = {400, 30},
				fnCallback = function(...)
					self["wnd" .. k .. "CastBar"]:FindChild("CastBarEx"):SetBarColor(arg[2])
				end
			})
		end

		if v.crDuration then
			G:API_AddColorBox(self, self.tOptionHolders[k], "Duration bar color", v, "crDuration", { tMove = {400, 60},
				fnCallback = function(...) self["wnd" .. k .. "CastBar"]:FindChild("DurationBar"):SetBarColor(arg[2]) end
			})
		end

		if v.crText then
			G:API_AddColorBox(self, self.tOptionHolders[k], "Text color", v, "crText", { tMove = {0, 60},
				fnCallback = function(...)
					self["wnd" .. k .. "CastBar"]:FindChild("CastTime"):SetTextColor(arg[2])
					self["wnd" .. k .. "CastBar"]:FindChild("SpellName"):SetTextColor(arg[2])
				end
			})
		end

		if v.bCenterText ~= nil then
			G:API_AddCheckBox(self, self.tOptionHolders[k], "Center text", v, "bCenterText", { tMove = {200, 120},
				fnCallback = self.ForgeAPI_LoadSettings
			})
		end

		if v.strFullSprite ~= nil then
			local wndCombo = G:API_AddComboBox(self, self.tOptionHolders[k], "Texture", v, "strFullSprite", { tMove = {0, 120}, tWidths = { 150, 50 },
				fnCallback = self.ForgeAPI_LoadSettings
			})
			G:API_AddOptionToComboBox(self, wndCombo, "ForgeUI_Smooth","ForgeUI_Smooth", {})
			G:API_AddOptionToComboBox(self, wndCombo, "ForgeUI_Flat", "ForgeUI_Flat", {})
			G:API_AddOptionToComboBox(self, wndCombo, "ForgeUI_Minimalist", "ForgeUI_Minimalist", {})
			G:API_AddOptionToComboBox(self, wndCombo, "ForgeUI_Edge", "ForgeUI_Edge", {})
		end
	end
end

-----------------------------------------------------------------------------------------------
-- Ability icons
-----------------------------------------------------------------------------------------------
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
