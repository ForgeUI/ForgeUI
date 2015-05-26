----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI addon
--
-- name: 		ForgeUI_ResourceBars.lua
-- author:		Winty Badass@Jabbit
-- about:		Resource bars addon for ForgeUI
-----------------------------------------------------------------------------------------------

require "Window"

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI

local Util = F:API_GetModule("util")

-----------------------------------------------------------------------------------------------
-- ForgeUI Addon Definition
-----------------------------------------------------------------------------------------------
local ForgeUI_ResourceBars = {
	_NAME = "ForgeUI_ResourceBars",
    _API_VERSION = 3,
	_VERSION = "2.0",
	_DB = {},
	DISPLAY_NAME = "Resource bars",
	
	tSettings = {
		profile = {
			bSmoothBars = false,
			bPermaShow = false,
			crBorder = "FF000000",
			crBackground = "FF101010",
			crFocus = "FFFFFFFF",
			bCenterText = false,
			warrior = {
				crResource1 = "FFE53805",
				crResource2 = "FFEF0000",
				bPlaySoundAbEnd = false,
			},
			stalker = {
				crResource1 = "FFD23EF4",
				crResource2 = "FF620077",
				nBreakpoint = 35
			},
			engineer = {
				crResource1 = "FF00AEFF",
				crResource2 = "FFFFB000",
				bShowBars = false
			},
			esper = {
				crResource1 = "FF1591DB"
			},
			medic = {
				crResource1 = "FF98C723",
				crResource2 = "FFFFE757"
			},
			slinger = {
				bSurgeShadow = true,
				crResource1 = "FFFFE757",
				crResource2 = "FFE53805",
				crResource3 = "FF99FF33",
				crResource4 = "FF009900"
			}
		}
	}
}

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

tPowerLinkId = {
	[79798] = true,
	[79797] = true,
	[79796] = true,
	[79795] = true,
	[79794] = true,
	[79793] = true,
	[79792] = true,
	[79791] = true,
	[79787] = true,
}

tAugBladeBuffId = {
	[49311] = true,
	[49310] = true,
	[49309] = true,
	[49308] = true,
	[49307] = true,
	[49302] = true,
	[49301] = true,
	[49300] = true,
	[46935] = true,
}

tAugBladeDrainId = {
	[79757] = true,
}

-----------------------------------------------------------------------------------------------
-- ForgeAPI
-----------------------------------------------------------------------------------------------
function ForgeUI_ResourceBars:ForgeAPI_Init()
	self.xmlDoc = XmlDoc.CreateFromFile("..//ForgeUI_ResourceBars//ForgeUI_ResourceBars.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil then
		Print("ForgeUI ERROR: Wrong class")
		return
	end
	
	local eClassId = unitPlayer:GetClassId()
	if eClassId == GameLib.CodeEnumClass.Engineer then
		self.playerClass = "Engineer"
		self:OnEngineerCreated(unitPlayer)
	elseif eClassId == GameLib.CodeEnumClass.Esper then
		self.playerClass = "Esper"
		self:OnEsperCreated(unitPlayer)
	elseif eClassId == GameLib.CodeEnumClass.Medic then
		self.playerClass = "Medic"
		self:OnMedicCreated(unitPlayer)
	elseif eClassId == GameLib.CodeEnumClass.Spellslinger then
		self.playerClass = "Spellslinger"
		self:OnSlingerCreated(unitPlayer)
	elseif eClassId == GameLib.CodeEnumClass.Stalker then
		self.playerClass = "Stalker"
		self:OnStalkerCreated(unitPlayer)
	elseif eClassId == GameLib.CodeEnumClass.Warrior then
		self.playerClass = "Warrior"
		self:OnWarriorCreated(unitPlayer)	
	end
end

function ForgeUI_ResourceBars:ForgeAPI_LoadSettings()
	self["LoadStyle_ResourceBar_" .. self.playerClass](self)
end

-----------------------------------------------------------------------------------------------
-- Engineer
-----------------------------------------------------------------------------------------------

function ForgeUI_ResourceBars:OnEngineerCreated(unitPlayer)
	self.playerMaxResource = unitPlayer:GetMaxResource(1)

	self.wndResource = Apollo.LoadForm(self.xmlDoc, "ResourceBar_Engineer", "FixedHudStratumHigh", self)
	
	if self._DB.profile.bSmoothBars then
		Apollo.RegisterEventHandler("NextFrame", "OnEngineerUpdate", self)
	else
		Apollo.RegisterEventHandler("VarChange_FrameCount", "OnEngineerUpdate", self)
	end
end

function ForgeUI_ResourceBars:OnEngineerUpdate()
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end
	
	local bShow = false
	
	local nResource = unitPlayer:GetResource(1)
	if unitPlayer:IsInCombat() or nResource > 0 or self._DB.profile.bPermaShow  then
		bShow = true
	end
	
	if bShow ~= self.wndResource:IsShown() then
		self.wndResource:Show(bShow, true)
	end
end

-----------------------------------------------------------------------------------------------
-- Esper
-----------------------------------------------------------------------------------------------

function ForgeUI_ResourceBars:OnEsperCreated(unitPlayer)
	self.playerMaxResource = unitPlayer:GetMaxResource(1)

	self.wndResource = Apollo.LoadForm(self.xmlDoc, "ResourceBar_Esper", "FixedHudStratumHigh", self)
	self.wndFocus = Apollo.LoadForm(self.xmlDoc, "ResourceBar_Focus", "FixedHudStratumHigh", self)
	
	if self._DB.profile.bSmoothBars then
		Apollo.RegisterEventHandler("NextFrame", "OnEsperUpdate", self)
	else
		Apollo.RegisterEventHandler("VarChange_FrameCount", "OnEsperUpdate", self)
	end
end

function ForgeUI_ResourceBars:OnEsperUpdate()
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end
	
	local bShow = false
	
	local nResource = unitPlayer:GetResource(1)
	if unitPlayer:IsInCombat() or nResource > 0 or self._DB.profile.bPermaShow  then
		bShow = true
	end
	
	if bShow ~= self.wndResource:IsShown() then
		self.wndResource:Show(bShow, true)
	end
	
	self:UpdateFocus(unitPlayer)
end

-----------------------------------------------------------------------------------------------
-- Medic
-----------------------------------------------------------------------------------------------

function ForgeUI_ResourceBars:OnMedicCreated(unitPlayer)
	self.playerMaxResource = unitPlayer:GetMaxResource(1)

	self.wndResource = Apollo.LoadForm(self.xmlDoc, "ResourceBar_Medic", "FixedHudStratumHigh", self)
	self.wndFocus = Apollo.LoadForm(self.xmlDoc, "ResourceBar_Focus", "FixedHudStratumHigh", self)
	
	if self._DB.profile.bSmoothBars then
		Apollo.RegisterEventHandler("NextFrame", "OnMedicUpdate", self)
	else
		Apollo.RegisterEventHandler("VarChange_FrameCount", "OnMedicUpdate", self)
	end
end

function ForgeUI_ResourceBars:OnMedicUpdate()
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end
	
	local bShow = false
	
	local nResource = unitPlayer:GetResource(1)
	if unitPlayer:IsInCombat() or nResource < self.playerMaxResource or self._DB.profile.bPermaShow  then
		bShow = true
	end
	
	if bShow ~= self.wndResource:IsShown() then
		self.wndResource:Show(bShow, true)
	end
	
	self:UpdateFocus(unitPlayer)
end

-----------------------------------------------------------------------------------------------
-- Slinger
-----------------------------------------------------------------------------------------------

function ForgeUI_ResourceBars:OnSlingerCreated(unitPlayer)
	self.playerMaxResource = unitPlayer:GetMaxResource(4)

	self.wndResource = Apollo.LoadForm(self.xmlDoc, "ResourceBar_Slinger", "FixedHudStratumHigh", self)
	self.wndFocus = Apollo.LoadForm(self.xmlDoc, "ResourceBar_Focus", "FixedHudStratumHigh", self)
	
	if self._DB.profile.bSmoothBars then
		Apollo.RegisterEventHandler("NextFrame", "OnSlingerUpdate", self)
	else
		Apollo.RegisterEventHandler("VarChange_FrameCount", "OnSlingerUpdate", self)
	end
end

function ForgeUI_ResourceBars:OnSlingerUpdate()
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end
	
	local bShow = false
	
	local nResource = unitPlayer:GetResource(4)
	if unitPlayer:IsInCombat() or GameLib.IsSpellSurgeActive() or nResource < self.playerMaxResource or self._DB.profile.bPermaShow  then
		bShow = true
	end

	if bShow ~= self.wndResource:IsShown() then
		self.wndResource:Show(bShow, true)
	end
	
	self:UpdateFocus(unitPlayer)
end

-----------------------------------------------------------------------------------------------
-- Stalker
-----------------------------------------------------------------------------------------------

function ForgeUI_ResourceBars:OnStalkerCreated(unitPlayer)
	self.playerMaxResource = unitPlayer:GetMaxResource(3)

	self.wndResource = Apollo.LoadForm(self.xmlDoc, "ResourceBar_Stalker", "FixedHudStratumHigh", self)
	self.wndResource:FindChild("ProgressBar"):SetMax(self.playerMaxResource)
	
	if self._DB.profile.bSmoothBars then
		Apollo.RegisterEventHandler("NextFrame", "OnStalkerUpdate", self)
	else
		Apollo.RegisterEventHandler("VarChange_FrameCount", "OnStalkerUpdate", self)
	end
end

function ForgeUI_ResourceBars:OnStalkerUpdate()
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end
	
	local bShow = false
	
	local nResource = unitPlayer:GetResource(3)
	if unitPlayer:IsInCombat() or nResource < self.playerMaxResource or self._DB.profile.bPermaShow  then
		bShow = true
	end
	
	if bShow ~= self.wndResource:IsShown() then
		self.wndResource:Show(bShow, true)
	end
end

-----------------------------------------------------------------------------------------------
-- Warrior
-----------------------------------------------------------------------------------------------

function ForgeUI_ResourceBars:OnWarriorCreated(unitPlayer)
	self.playerMaxResource = unitPlayer:GetMaxResource(1)

	self.wndResource = Apollo.LoadForm(self.xmlDoc, "ResourceBar_Warrior", "FixedHudStratumHigh", self)
	self.wndResource:FindChild("ProgressBar"):SetMax(self.playerMaxResource)
	
	self.nAugBladeRemaining = 0
	
	Apollo.RegisterEventHandler("BuffAdded", "OnWarriorBuffAdded", self)
	Apollo.RegisterEventHandler("BuffUpdated", "OnWarriorBuffUpdated", self)
	Apollo.RegisterEventHandler("BuffRemoved", "OnWarriorBuffRemoved", self)
	
	if self._DB.profile.bSmoothBars then
		Apollo.RegisterEventHandler("NextFrame", "OnWarriorUpdate", self)
	else
		Apollo.RegisterEventHandler("VarChange_FrameCount", "OnWarriorUpdate", self)
	end
end

function ForgeUI_ResourceBars:OnWarriorUpdate()
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end
	
	local bShow = false
	
	local nResource = unitPlayer:GetResource(1)
	if unitPlayer:IsInCombat() or nResource > 0 or self._DB.profile.bPermaShow then
		self:RefreshStyle_ResourceBar_Warrior(unitPlayer, nResource)
	
		bShow = true
	end
	
	if not self.bAugBlade and self.wndResource:FindChild("AG_Stacks"):IsShown() then
		for k, v in pairs(GameLib.GetPlayerUnit():GetBuffs().arBeneficial) do
			if tAugBladeDrainId[v.splEffect:GetId()] then
				self.wndResource:FindChild("AG_Stacks"):SetText(Util:Round(v.fTimeRemaining, 1) .. " - " .. v.nCount)	
			end	
		end
	end
	
	if bShow ~= self.wndResource:IsShown() then
		self.wndResource:Show(bShow, true)
	end
end

function ForgeUI_ResourceBars:OnWarriorBuffAdded(unit, tBuff, nCout)
	if not unit or not unit:IsThePlayer() then return end
	
	if tAugBladeDrainId[tBuff.splEffect:GetId()] and tBuff.nCount > 0 then
		self.wndResource:FindChild("AG_Stacks"):SetText(tBuff.nCount)
		self.wndResource:FindChild("AG_Stacks"):Show(true, true)
	elseif tAugBladeBuffId[tBuff.splEffect:GetId()] then -- aug blade turned off
		self.wndResource:FindChild("KE_Drain"):Show(true, true)
		
		self.bAugBlade = true
	elseif self.bHasPowerlink and tPowerLinkId[tBuff.splEffect:GetId()] then
		self.wndResource:FindChild("KE_Drain"):Show(true, true)
		
		self.bPowerLink = true
	end
end

function ForgeUI_ResourceBars:OnWarriorBuffUpdated(unit, tBuff, nCout)
	if not unit or not unit:IsThePlayer() then return end

	if tAugBladeDrainId[tBuff.splEffect:GetId()] and tBuff.nCount > 0 then
		self.wndResource:FindChild("AG_Stacks"):SetText(tBuff.nCount)
	end
end

function ForgeUI_ResourceBars:OnWarriorBuffRemoved(unit, tBuff, nCout)
	if not unit or not unit:IsThePlayer() then return end

	if tAugBladeDrainId[tBuff.splEffect:GetId()] then
		self.wndResource:FindChild("AG_Stacks"):Show(false, true)
		
		if self._DB.profile.warrior.bPlaySoundAbEnd then
			Sound.Play(220)
		end
	elseif self.bHasPowerlink and tPowerLinkId[tBuff.splEffect:GetId()] then
		self.bPowerLink = false
	elseif tAugBladeBuffId[tBuff.splEffect:GetId()] then -- aug blade turned off
		self.bAugBlade = false
	end
	
	if not self.bAugBlade and not self.bPowerLink then
		self.wndResource:FindChild("KE_Drain"):Show(false, true)
	end
end

-----------------------------------------------------------------------------------------------
-- Focus
-----------------------------------------------------------------------------------------------

function ForgeUI_ResourceBars:UpdateFocus(unitPlayer)
	if unitPlayer == nil or not unitPlayer:IsValid() then return end
	if self.wndFocus == nil then return end
	
	local bShow = false
	
	local nMana = unitPlayer:GetMana()
	local nMaxMana = unitPlayer:GetMaxMana()
	
	if nMana < nMaxMana then
		bShow = true
	end
	
	if bShow ~= self.wndFocus:IsShown() then
		self.wndFocus:Show(bShow, true)
	end
end

-----------------------------------------------------------------------------------------------
-- Styles
-----------------------------------------------------------------------------------------------

-- engineer
function ForgeUI_ResourceBars:LoadStyle_ResourceBar_Engineer()
	self.wndResource:FindChild("Border"):SetBGColor(self._DB.profile.crBorder)
	self.wndResource:FindChild("Background"):SetBGColor(self._DB.profile.crBackground)
	self.wndResource:FindChild("ProgressBar"):SetMax(self.playerMaxResource)
	
	if self._DB.profile.bCenterText then
		self.wndResource:FindChild("Value"):SetAnchorOffsets(0, 0, 0, 0)
	else
		self.wndResource:FindChild("Value"):SetAnchorOffsets(0, -5, 0, 0)
	end
	self.wndResource:FindChild("Value"):SetTextFlags("DT_VCENTER", self._DB.profile.bCenterText)
	
	self.wndResource:FindChild("Bars"):Show(self._DB.profile.engineer.bShowBars, true)
end

function ForgeUI_ResourceBars:RefreshStyle_ResourceBar_Engineer(unitPlayer, nResource)
	self.wndResource:FindChild("ProgressBar"):SetProgress(nResource)
	self.wndResource:FindChild("Value"):SetText(nResource)
	
	if nResource < 30 or nResource > 70 then
		self.wndResource:FindChild("ProgressBar"):SetBarColor(self._DB.profile.engineer.crResource1)
	else
		self.wndResource:FindChild("ProgressBar"):SetBarColor(self._DB.profile.engineer.crResource2)
	end
end

-- esper
function ForgeUI_ResourceBars:LoadStyle_ResourceBar_Esper()
	for i = 1, self.playerMaxResource do
		self.wndResource:FindChild("PSI" .. i):SetBGColor(self._DB.profile.crBorder)
		self.wndResource:FindChild("PSI" .. i):FindChild("Background"):SetBGColor(self._DB.profile.crBackground)
		self.wndResource:FindChild("PSI" .. i):FindChild("ProgressBar"):SetBarColor(self._DB.profile.esper.crResource1)
		self.wndResource:FindChild("PSI" .. i):FindChild("ProgressBar"):SetMax(1)
	end
end

function ForgeUI_ResourceBars:RefreshStyle_ResourceBar_Esper(unitPlayer, nResource)
	for i = 1, self.playerMaxResource do
		if nResource >= i then
			self.wndResource:FindChild("PSI" .. i):FindChild("ProgressBar"):SetProgress(1)
		else
			self.wndResource:FindChild("PSI" .. i):FindChild("ProgressBar"):SetProgress(0)
		end
	end
end

-- medic
function ForgeUI_ResourceBars:LoadStyle_ResourceBar_Medic()
	for i = 1, self.playerMaxResource do
		self.wndResource:FindChild("ACU" .. i):SetBGColor(self._DB.profile.crBorder)
		self.wndResource:FindChild("ACU" .. i):FindChild("Background"):SetBGColor(self._DB.profile.crBackground)
		self.wndResource:FindChild("ACU" .. i):FindChild("ProgressBar"):SetMax(3)
	end
end

function ForgeUI_ResourceBars:RefreshStyle_ResourceBar_Medic(unitPlayer, nResource)
	for i = 1, self.playerMaxResource do
		if nResource >= i then
			self.wndResource:FindChild("ACU" .. i):FindChild("ProgressBar"):SetBarColor(self._DB.profile.medic.crResource1)
			self.wndResource:FindChild("ACU" .. i):FindChild("ProgressBar"):SetProgress(3)
		else
			self.wndResource:FindChild("ACU" .. i):FindChild("ProgressBar"):SetProgress(0)
			if (nResource + 1) == i then
				local nAcu = 0
			
				for key, buff in pairs(unitPlayer:GetBuffs().arBeneficial) do
					if buff.splEffect:GetId() == 42569 then 
						nAcu = buff.nCount
					end
				end
				
				self.wndResource:FindChild("ACU" .. i):FindChild("ProgressBar"):SetBarColor(self._DB.profile.medic.crResource2)
				self.wndResource:FindChild("ACU" .. i):FindChild("ProgressBar"):SetProgress(nAcu)
			end
		end
	end
end

-- slinger
function ForgeUI_ResourceBars:LoadStyle_ResourceBar_Slinger()
	for i = 1, 4 do
		self.wndResource:FindChild("RUNE" .. i):SetBGColor(self._DB.profile.crBorder)
		self.wndResource:FindChild("RUNE" .. i):FindChild("Background"):SetBGColor(self._DB.profile.crBackground)
		self.wndResource:FindChild("RUNE" .. i):FindChild("ProgressBar"):SetMax(25)
	end
end

function ForgeUI_ResourceBars:RefreshStyle_ResourceBar_Slinger(unitPlayer, nResource)
	for i = 1, 4 do
		if nResource >= (i * 25) then
			if GameLib.IsSpellSurgeActive() then
				self.wndResource:FindChild("RUNE" .. i):FindChild("ProgressBar"):SetBarColor(self._DB.profile.slinger.crResource3)
			else
				self.wndResource:FindChild("RUNE" .. i):FindChild("ProgressBar"):SetBarColor(self._DB.profile.slinger.crResource1)
			end
			self.wndResource:FindChild("RUNE" .. i):FindChild("ProgressBar"):SetProgress(25)
		else
			if GameLib.IsSpellSurgeActive() then
				self.wndResource:FindChild("RUNE" .. i):FindChild("ProgressBar"):SetBarColor(self._DB.profile.slinger.crResource4)
			else
				self.wndResource:FindChild("RUNE" .. i):FindChild("ProgressBar"):SetBarColor(self._DB.profile.slinger.crResource2)
			end
			self.wndResource:FindChild("RUNE" .. i):FindChild("ProgressBar"):SetProgress(25 - ((i * 25) - nResource))
		end
	end
	
	if self._DB.profile.slinger.bSurgeShadow and GameLib.IsSpellSurgeActive() then
		self.wndResource:FindChild("SpellSurge"):Show(true, true)
	else
		self.wndResource:FindChild("SpellSurge"):Show(false, true)
	end
end

-- stalker
function ForgeUI_ResourceBars:LoadStyle_ResourceBar_Stalker()
	self.wndResource:FindChild("Border"):SetBGColor(self._DB.profile.crBorder)
	self.wndResource:FindChild("Background"):SetBGColor(self._DB.profile.crBackground)
	self.wndResource:FindChild("ProgressBar"):SetBarColor(self._DB.profile.stalker.crResource1)
	
	if self._DB.profile.bCenterText then
		self.wndResource:FindChild("Value"):SetAnchorOffsets(0, 0, 0, 0)
	else
		self.wndResource:FindChild("Value"):SetAnchorOffsets(0, -5, 0, 0)
	end
	self.wndResource:FindChild("Value"):SetTextFlags("DT_VCENTER", self._DB.profile.bCenterText)
end

function ForgeUI_ResourceBars:RefreshStyle_ResourceBar_Stalker(unitPlayer, nResource)
	self.wndResource:FindChild("ProgressBar"):SetProgress(nResource)
	self.wndResource:FindChild("Value"):SetText(nResource)
	
	if nResource < self._DB.profile.stalker.nBreakpoint then
		self.wndResource:FindChild("ProgressBar"):SetBarColor(self._DB.profile.stalker.crResource2)
	else
		self.wndResource:FindChild("ProgressBar"):SetBarColor(self._DB.profile.stalker.crResource1)
	end
end

-- warrior
function ForgeUI_ResourceBars:LoadStyle_ResourceBar_Warrior()
	self.wndResource:FindChild("Border"):SetBGColor(self._DB.profile.crBorder)
	self.wndResource:FindChild("Background"):SetBGColor(self._DB.profile.crBackground)
	self.wndResource:FindChild("ProgressBar"):SetMax(self.playerMaxResource)
	
	Print("WOT")
	
	if self._DB.profile.bCenterText then
		self.wndResource:FindChild("Value"):SetAnchorOffsets(0, 0, 0, 0)
	else
		self.wndResource:FindChild("Value"):SetAnchorOffsets(0, -5, 0, 0)
	end
	self.wndResource:FindChild("Value"):SetTextFlags("DT_VCENTER", self._DB.profile.bCenterText)
	self.wndResource:FindChild("AG_Stacks"):SetTextFlags("DT_VCENTER", self._DB.profile.bCenterText)
end

function ForgeUI_ResourceBars:RefreshStyle_ResourceBar_Warrior(unitPlayer, nResource)
	self.wndResource:FindChild("Value"):SetText(nResource)
	self.wndResource:FindChild("ProgressBar"):SetProgress(nResource)
		
	if nResource < 750 then
		self.wndResource:FindChild("ProgressBar"):SetBarColor(self._DB.profile.warrior.crResource1)
	else
		self.wndResource:FindChild("ProgressBar"):SetBarColor(self._DB.profile.warrior.crResource2)
	end
end

-- focus
function ForgeUI_ResourceBars:LoadStyle_Focus()
end

function ForgeUI_ResourceBars:RefreshStyle_Focus(unitPlayer, nMana, nMaxMana)
	self.wndFocus:FindChild("ProgressBar"):SetMax(nMaxMana)
	self.wndFocus:FindChild("ProgressBar"):SetProgress(nMana)
	self.wndFocus:FindChild("ProgressBar"):SetBarColor(self._DB.profile.crFocus)
	self.wndFocus:FindChild("Value"):SetText(Util:Round(nMana, 0) .. " ( " .. Util:Round((nMana / nMaxMana) * 100, 1) .. "% )")
end

-----------------------------------------------------------------------------------------------
-- ForgeUI addon registration
-----------------------------------------------------------------------------------------------
F:API_NewAddon(ForgeUI_ResourceBars)