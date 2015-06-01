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
			bShowPlayer = true,
			bShowTarget = true,
			bShowFocus = true,
			tFrames = {
				Player = {
					bShowCastIcons = true,
					crBorder = "FF000000",
					crBackground = "FF101010",
					crCastBar = "FF272727",
					crDuration = "FFFFCC00",
					crText = "FFFFFFFF",
				},
				Target = {
					bShowCastIcons = true,
					crBorder = "FF000000",
					crBackground = "FF101010",
					crCastBar = "FF272727",
					crCastBarInf = "FFFF0000",
					crMooBar = "FFBC00BB",
					crText = "FFFFFFFF",
				},
				Focus = {
					bShowCastIcons = true,
					crBorder = "FF000000",
					crBackground = "FF101010",
					crCastBar = "FF272727",
					crCastBarInf = "FFFF0000",
					crMooBar = "FFBC00BB",
					crText = "FFFFFFFF",
				}
			}
		}
	}
}

-----------------------------------------------------------------------------------------------
-- Constants
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
	self.wndPlayerCastBar = Apollo.LoadForm(self.xmlDoc, "PlayerCastBar", "FixedHudStratum", self)
	self.wndTargetCastBar = Apollo.LoadForm(self.xmlDoc, "TargetCastBar", "FixedHudStratum", self)
	self.wndFocusCastBar = Apollo.LoadForm(self.xmlDoc, "FocusCastBar", "FixedHudStratum", self)

	F:API_RegisterMover(self, self.wndPlayerCastBar, "CastBars_Player", "Player's cast bar", "general")
	F:API_RegisterMover(self, self.wndTargetCastBar, "CastBars_Target", "Target's cast bar", "general")
	F:API_RegisterMover(self, self.wndFocusCastBar, "CastBars_Focus", "Focus' cast bar", "general")

	Apollo.RegisterEventHandler("StartSpellThreshold", 	"OnStartSpellThreshold", self)
	Apollo.RegisterEventHandler("ClearSpellThreshold", 	"OnClearSpellThreshold", self)
	Apollo.RegisterEventHandler("UpdateSpellThreshold", "OnUpdateSpellThreshold", self)
end

function ForgeUI_CastBars:OnNextFrame()
	local unitPlayer = GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end

	if self._DB.profile.bShowPlayer and not F:API_MoversActive() then
		self:UpdateCastBar(unitPlayer, self.wndPlayerCastBar, "Player")
	else
		if self.wndPlayerCastBar:IsShown() then
			self.wndPlayerCastBar:Show(false, true)
		end
	end

	local unitTarget = unitPlayer:GetTarget()
	if unitTarget ~= nil and unitTarget:IsValid() and self._DB.profile.bShowTarget and not F:API_MoversActive() then
		self:UpdateCastBar(unitTarget, self.wndTargetCastBar, "Target")
		self:UpdateMoOBar(unitTarget, self.wndTargetCastBar, "Target")
		self:UpdateInterruptArmor(unitTarget, self.wndTargetCastBar, "Target")
	else
		if self.wndTargetCastBar:IsShown() then
			self.wndTargetCastBar:Show(false, true)
		end
	end

	local unitFocus = unitPlayer:GetAlternateTarget()
	if unitFocus ~= nil and unitFocus:IsValid() and self._DB.profile.bShowFocus and not F:API_MoversActive() then
		self:UpdateCastBar(unitFocus, self.wndFocusCastBar, "Focus")
		self:UpdateMoOBar(unitFocus, self.wndFocusCastBar, "Focus")
		self:UpdateInterruptArmor(unitFocus, self.wndFocusCastBar, "Focus")
	else
		if self.wndFocusCastBar:IsShown() then
			self.wndFocusCastBar:Show(false, true)
		end
	end

	-- duration bar for tap skills
	if self.cast ~= nil then
		local fTimeLeft = 1-GameLib.GetSpellThresholdTimePrcntDone(self.cast.id)
		self.wndPlayerCastBar:FindChild("DurationBar"):SetProgress(fTimeLeft)
	else
		self.wndPlayerCastBar:FindChild("DurationBar"):SetProgress(0)
	end
end

function ForgeUI_CastBars:OnStartSpellThreshold(idSpell, nMaxThresholds, eCastMethod)
	if not self._DB.profile.bShowPlayer then return end

	local unitPlayer = GetPlayerUnit()
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
	if not self._DB.profile.bShowPlayer then return end

	local unitPlayer = GetPlayerUnit()
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
	local unitPlayer = GetPlayerUnit()
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
	local pl = GetPlayerUnit()

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

function ForgeUI_CastBars:UpdateInterruptArmor(unit, wnd, type)
	local bShow = false
	nValue = unit:GetInterruptArmorValue()
	nMax = unit:GetInterruptArmorMax()
	if nMax == 0 or nValue == nil or unit:IsDead() then
		wnd:FindChild("CastBar"):SetBarColor(self._DB.profile.tFrames[type].crCastBar)
	else
		bShow = true
		if nMax == -1 then
			wnd:FindChild("InterruptArmor"):SetSprite("ForgeUI_IAinf")
			wnd:FindChild("InterruptArmor_Value"):SetText("")
			wnd:FindChild("CastBar"):SetBarColor(self._DB.profile.tFrames[type].crCastBarInf)
		elseif nMax > 0 then
			wnd:FindChild("InterruptArmor"):SetSprite("ForgeUI_IA")
			wnd:FindChild("InterruptArmor_Value"):SetText(nValue)
			wnd:FindChild("CastBar"):SetBarColor(self._DB.profile.tFrames[type].crCastBar)
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
					self["wnd" .. k .. "CastBar"]:FindChild("TickBar"):SetBarColor(arg[2])
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

		if v.crDuration then
			G:API_AddColorBox(self, self.tOptionHolders[k], "Duration bar color", v, "crDuration", { tMove = {400, 30},
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
