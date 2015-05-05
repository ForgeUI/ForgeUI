require "Window"
 
local ForgeUI_ResourceBars = {} 
 
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
-- Initialization
-----------------------------------------------------------------------------------------------
function ForgeUI_ResourceBars:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- mandatory 
    self.api_version = 2
	self.version = "1.0.0"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_ResourceBars"
	self.strDisplayName = "Resource bars"
	
	self.wndContainers = {}
	
	self.tStylers = {
		["LoadStyle_ResourceBar_Warrior"] = self,
		["RefreshStyle_ResourceBar_Warrior"] = self, -- (unitPlayer, nResource, nResourceMax)
		["LoadStyle_ResourceBar_Engineer"] = self,
		["RefreshStyle_ResourceBar_Engineer"] = self, -- (unitPlayer, nResource, nResourceMax)
		["LoadStyle_ResourceBar_Esper"] = self,
		["RefreshStyle_ResourceBar_Esper"] = self, -- (unitPlayer, nResource, nResourceMax)
		["LoadStyle_ResourceBar_Medic"] = self,
		["RefreshStyle_ResourceBar_Medic"] = self, -- (unitPlayer, nResource, nResourceMax)
		["LoadStyle_ResourceBar_Stalker"] = self,
		["RefreshStyle_ResourceBar_Stalker"] = self, -- (unitPlayer, nResource, nResourceMax)
		["LoadStyle_ResourceBar_Slinger"] = self,
		["RefreshStyle_ResourceBar_Slinger"] = self, -- (unitPlayer, nResource, nResourceMax)
		["LoadStyle_Focus"] = self,
		["RefreshStyle_Focus"] = self, -- (unitPlayer, nResource, nResourceMax)
	}
	
	-- optional
	self.tSettings = {
		bSmoothBars = false,
		bPermaShow = false,
		crBorder = "FF000000",
		crBackground = "FF101010",
		crFocus = "FFFFFFFF",
		bCenterText = false,
		warrior = {
			crResource1 = "FFE53805",
			crResource2 = "FFEF0000"
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
	
	self.playerClass = nil
	self.playerMaxResource = nil

    return o
end

function ForgeUI_ResourceBars:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"ForgeUI"
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 
-----------------------------------------------------------------------------------------------
-- ForgeUI_ResourceBars OnLoad
-----------------------------------------------------------------------------------------------
function ForgeUI_ResourceBars:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("ForgeUI_ResourceBars.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

function ForgeUI_ResourceBars:ForgeAPI_AfterRegistration()
	ForgeUI.API_AddItemButton(self, "Resource bars", { strContainer = "Container" })
end

function ForgeUI_ResourceBars:ForgeAPI_AfterRestore()
	if GameLib.GetPlayerUnit() then
		self:OnCharacterCreated()
	else
		Apollo.RegisterEventHandler("CharacterCreated", 	"OnCharacterCreated", self)
	end
	
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("crBorder"), self.tSettings, "crBorder", false, "LoadStyles" )
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("crBackground"), self.tSettings, "crBackground", false, "LoadStyles" )
	
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers.Container:FindChild("bSmoothBars"), self.tSettings, "bSmoothBars")
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers.Container:FindChild("bPermaShow"), self.tSettings, "bPermaShow")
end

function ForgeUI_ResourceBars:OnCharacterCreated()
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

-----------------------------------------------------------------------------------------------
-- Engineer
-----------------------------------------------------------------------------------------------

function ForgeUI_ResourceBars:OnEngineerCreated(unitPlayer)
	self.playerMaxResource = unitPlayer:GetMaxResource(1)

	self.wndResource = Apollo.LoadForm(self.xmlDoc, "ResourceBar_Engineer", "FixedHudStratumHigh", self)
	
	self.wndContainers.Container:FindChild("EngineerContainer"):Show(true, true)
	
	-- register options
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("Engineer_Color1_EditBox"), self.tSettings.engineer, "crResource1", false, "LoadStyle_ResourceBar_Engineer" )
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("Engineer_Color2_EditBox"), self.tSettings.engineer, "crResource2", false, "LoadStyle_ResourceBar_Engineer" )
	
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers.Container:FindChild("EngineerContainer"):FindChild("bCenterText"), self.tSettings, "bCenterText", "LoadStyles")
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers.Container:FindChild("EngineerContainer"):FindChild("bShowBars"), self.tSettings.engineer, "bShowBars", "LoadStyles")
	
	ForgeUI.API_RegisterWindow(self, self.wndResource, "ForgeUI_ResourceBar", { nLevel = 3, strDisplayName = "Resource bar" })
	
	self.tStylers["LoadStyle_ResourceBar_Engineer"]["LoadStyle_ResourceBar_Engineer"](self)
	
	if self.tSettings.bSmoothBars then
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
	if unitPlayer:IsInCombat() or nResource > 0 or self.tSettings.bPermaShow  then
		self.tStylers["RefreshStyle_ResourceBar_Engineer"]["RefreshStyle_ResourceBar_Engineer"](self, unitPlayer, nResource)
		
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
	
	self.wndContainers.Container:FindChild("EsperContainer"):Show(true, true)
	
	-- register options
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("Esper_Color1_EditBox"), self.tSettings.esper, "crResource1", false, "LoadStyle_ResourceBar_Esper" )
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("Esper_crFocus"), self.tSettings, "crFocus", false, "LoadStyle_Focus" )
	
	ForgeUI.API_RegisterWindow(self, self.wndResource, "ForgeUI_ResourceBar", { nLevel = 3, strDisplayName = "Resource bar" })
	ForgeUI.API_RegisterWindow(self, self.wndFocus, "ForgeUI_FocusBar", { nLevel = 3, strDisplayName = "Focus bar", crBorder = "FFFFFFFF" })
	
	self.tStylers["LoadStyle_ResourceBar_Esper"]["LoadStyle_ResourceBar_Esper"](self)
	self.tStylers["LoadStyle_Focus"]["LoadStyle_Focus"](self)
	
	if self.tSettings.bSmoothBars then
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
	if unitPlayer:IsInCombat() or nResource > 0 or self.tSettings.bPermaShow  then
		self.tStylers["RefreshStyle_ResourceBar_Esper"]["RefreshStyle_ResourceBar_Esper"](self, unitPlayer, nResource)
		
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
	
	self.wndContainers.Container:FindChild("MedicContainer"):Show(true, true)
	
	-- register options
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("Medic_Color1_EditBox"), self.tSettings.medic, "crResource1", false, "LoadStyle_ResourceBar_Medic" )
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("Medic_Color2_EditBox"), self.tSettings.medic, "crResource2", false, "LoadStyle_ResourceBar_Medic" )
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("Medic_crFocus"), self.tSettings, "crFocus", false, "LoadStyle_Focus" )
	
	ForgeUI.API_RegisterWindow(self, self.wndResource, "ForgeUI_ResourceBar", { nLevel = 3, strDisplayName = "Resource bar" })
	ForgeUI.API_RegisterWindow(self, self.wndFocus, "ForgeUI_FocusBar", { nLevel = 3, strDisplayName = "Focus bar", crBorder = "FFFFFFFF" })
	
	self.tStylers["LoadStyle_ResourceBar_Medic"]["LoadStyle_ResourceBar_Medic"](self)
	self.tStylers["LoadStyle_Focus"]["LoadStyle_Focus"](self)
	
	if self.tSettings.bSmoothBars then
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
	if unitPlayer:IsInCombat() or nResource < self.playerMaxResource or self.tSettings.bPermaShow  then
		self.tStylers["RefreshStyle_ResourceBar_Medic"]["RefreshStyle_ResourceBar_Medic"](self, unitPlayer, nResource)
		
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
	
	self.wndContainers.Container:FindChild("SlingerContainer"):Show(true, true)
	
	-- register options
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("Slinger_Color1_EditBox"), self.tSettings.slinger, "crResource1", false, "LoadStyle_ResourceBar_Slinger" )
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("Slinger_Color2_EditBox"), self.tSettings.slinger, "crResource2", false, "LoadStyle_ResourceBar_Slinger" )
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("Slinger_Color3_EditBox"), self.tSettings.slinger, "crResource3", false, "LoadStyle_ResourceBar_Slinger" )
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("Slinger_Color4_EditBox"), self.tSettings.slinger, "crResource4", false, "LoadStyle_ResourceBar_Slinger" )
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("Slinger_crFocus"), self.tSettings, "crFocus", false, "LoadStyle_Focus" )
	
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers.Container:FindChild("Slinger_bSurgeShadow"), self.tSettings.slinger, "bSurgeShadow")
	
	ForgeUI.API_RegisterWindow(self, self.wndResource, "ForgeUI_ResourceBar", { nLevel = 3, strDisplayName = "Resource bar" })
	ForgeUI.API_RegisterWindow(self, self.wndFocus, "ForgeUI_FocusBar", { nLevel = 3, strDisplayName = "Focus bar", crBorder = "FFFFFFFF" })
	
	self.tStylers["LoadStyle_ResourceBar_Slinger"]["LoadStyle_ResourceBar_Slinger"](self)
	self.tStylers["LoadStyle_Focus"]["LoadStyle_Focus"](self)
	
	if self.tSettings.bSmoothBars then
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
	if unitPlayer:IsInCombat() or GameLib.IsSpellSurgeActive() or nResource < self.playerMaxResource or self.tSettings.bPermaShow  then
		self.tStylers["RefreshStyle_ResourceBar_Slinger"]["RefreshStyle_ResourceBar_Slinger"](self, unitPlayer, nResource)
		
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
	
	self.wndContainers.Container:FindChild("StalkerContainer"):Show(true, true)
	
	-- register options
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("Stalker_Color1_EditBox"), self.tSettings.stalker, "crResource1", false, "LoadStyle_ResourceBar_Stalker" )
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("Stalker_Color2_EditBox"), self.tSettings.stalker, "crResource2", false, "LoadStyle_ResourceBar_Stalker" )
	
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers.Container:FindChild("StalkerContainer"):FindChild("bCenterText"), self.tSettings, "bCenterText", "LoadStyles")
	
	ForgeUI.API_RegisterNumberBox(self, self.wndContainers.Container:FindChild("Stalker_ResourceBreakpoint"), self.tSettings.stalker, "nBreakpoint", { nMin = 0 })
	
	ForgeUI.API_RegisterWindow(self, self.wndResource, "ForgeUI_ResourceBar", { nLevel = 3, strDisplayName = "Resource bar" })
	
	self.tStylers["LoadStyle_ResourceBar_Stalker"]["LoadStyle_ResourceBar_Stalker"](self)
	
	if self.tSettings.bSmoothBars then
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
	if unitPlayer:IsInCombat() or nResource < self.playerMaxResource or self.tSettings.bPermaShow  then
		self.tStylers["RefreshStyle_ResourceBar_Stalker"]["RefreshStyle_ResourceBar_Stalker"](self, unitPlayer, nResource)
		
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
	
	self.wndContainers.Container:FindChild("WarriorContainer"):Show(true, true)
	
	self.nAugBladeRemaining = 0
	
	-- register options
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("Warrior_Color1_EditBox"), self.tSettings.warrior, "crResource1", false, "LoadStyle_ResourceBar_Warrior" )
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("Warrior_Color2_EditBox"), self.tSettings.warrior, "crResource2", false, "LoadStyle_ResourceBar_Warrior" )
	
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers.Container:FindChild("WarriorContainer"):FindChild("bCenterText"), self.tSettings, "bCenterText", "LoadStyles")
	
	ForgeUI.API_RegisterWindow(self, self.wndResource, "ForgeUI_ResourceBar", { nLevel = 3, strDisplayName = "Resource bar" })
	
	self.tStylers["LoadStyle_ResourceBar_Warrior"]["LoadStyle_ResourceBar_Warrior"](self)
	
	Apollo.RegisterEventHandler("BuffAdded", "OnWarriorBuffAdded", self)
	Apollo.RegisterEventHandler("BuffUpdated", "OnWarriorBuffUpdated", self)
	Apollo.RegisterEventHandler("BuffRemoved", "OnWarriorBuffRemoved", self)
	
	if self.tSettings.bSmoothBars then
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
	if unitPlayer:IsInCombat() or nResource > 0 or self.tSettings.bPermaShow then
		self.tStylers["RefreshStyle_ResourceBar_Warrior"]["RefreshStyle_ResourceBar_Warrior"](self, unitPlayer, nResource, nResourceMax)
		
		bShow = true
	end
	
	if not self.bAugBlade and self.wndResource:FindChild("AG_Stacks"):IsShown() then
		for k, v in pairs(GameLib.GetPlayerUnit():GetBuffs().arBeneficial) do
			if tAugBladeDrainId[v.splEffect:GetId()] then
				self.wndResource:FindChild("AG_Stacks"):SetText(ForgeUI.Round(v.fTimeRemaining, 1) .. " - " .. v.nCount)	
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
	elseif tPowerLinkId[tBuff.splEffect:GetId()] then
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
	elseif tPowerLinkId[tBuff.splEffect:GetId()] then
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
		self.tStylers["RefreshStyle_Focus"]["RefreshStyle_Focus"](self, unitPlayer, nMana, nMaxMana)
		
		bShow = true
	end
	
	if bShow ~= self.wndFocus:IsShown() then
		self.wndFocus:Show(bShow, true)
	end
end

-----------------------------------------------------------------------------------------------
-- Styles
-----------------------------------------------------------------------------------------------

function ForgeUI_ResourceBars:LoadStyles()
	self.tStylers["LoadStyle_ResourceBar_" .. self.playerClass]["LoadStyle_ResourceBar_" .. self.playerClass](self)
end

-- engineer
function ForgeUI_ResourceBars:LoadStyle_ResourceBar_Engineer()
	self.wndResource:FindChild("Border"):SetBGColor(self.tSettings.crBorder)
	self.wndResource:FindChild("Background"):SetBGColor(self.tSettings.crBackground)
	self.wndResource:FindChild("ProgressBar"):SetMax(self.playerMaxResource)
	
	if self.tSettings.bCenterText then
		self.wndResource:FindChild("Value"):SetAnchorOffsets(0, 0, 0, 0)
	else
		self.wndResource:FindChild("Value"):SetAnchorOffsets(0, -5, 0, 0)
	end
	self.wndResource:FindChild("Value"):SetTextFlags("DT_VCENTER", self.tSettings.bCenterText)
	
	self.wndResource:FindChild("Bars"):Show(self.tSettings.engineer.bShowBars, true)
end

function ForgeUI_ResourceBars:RefreshStyle_ResourceBar_Engineer(unitPlayer, nResource)
	self.wndResource:FindChild("ProgressBar"):SetProgress(nResource)
	self.wndResource:FindChild("Value"):SetText(nResource)
	
	if nResource < 30 or nResource > 70 then
		self.wndResource:FindChild("ProgressBar"):SetBarColor(self.tSettings.engineer.crResource1)
	else
		self.wndResource:FindChild("ProgressBar"):SetBarColor(self.tSettings.engineer.crResource2)
	end
end

-- esper
function ForgeUI_ResourceBars:LoadStyle_ResourceBar_Esper()
	for i = 1, self.playerMaxResource do
		self.wndResource:FindChild("PSI" .. i):SetBGColor(self.tSettings.crBorder)
		self.wndResource:FindChild("PSI" .. i):FindChild("Background"):SetBGColor(self.tSettings.crBackground)
		self.wndResource:FindChild("PSI" .. i):FindChild("ProgressBar"):SetBarColor(self.tSettings.esper.crResource1)
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
		self.wndResource:FindChild("ACU" .. i):SetBGColor(self.tSettings.crBorder)
		self.wndResource:FindChild("ACU" .. i):FindChild("Background"):SetBGColor(self.tSettings.crBackground)
		self.wndResource:FindChild("ACU" .. i):FindChild("ProgressBar"):SetMax(3)
	end
end

function ForgeUI_ResourceBars:RefreshStyle_ResourceBar_Medic(unitPlayer, nResource)
	for i = 1, self.playerMaxResource do
		if nResource >= i then
			self.wndResource:FindChild("ACU" .. i):FindChild("ProgressBar"):SetBarColor(self.tSettings.medic.crResource1)
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
				
				self.wndResource:FindChild("ACU" .. i):FindChild("ProgressBar"):SetBarColor(self.tSettings.medic.crResource2)
				self.wndResource:FindChild("ACU" .. i):FindChild("ProgressBar"):SetProgress(nAcu)
			end
		end
	end
end

-- slinger
function ForgeUI_ResourceBars:LoadStyle_ResourceBar_Slinger()
	for i = 1, 4 do
		self.wndResource:FindChild("RUNE" .. i):SetBGColor(self.tSettings.crBorder)
		self.wndResource:FindChild("RUNE" .. i):FindChild("Background"):SetBGColor(self.tSettings.crBackground)
		self.wndResource:FindChild("RUNE" .. i):FindChild("ProgressBar"):SetMax(25)
	end
end

function ForgeUI_ResourceBars:RefreshStyle_ResourceBar_Slinger(unitPlayer, nResource)
	for i = 1, 4 do
		if nResource >= (i * 25) then
			if GameLib.IsSpellSurgeActive() then
				self.wndResource:FindChild("RUNE" .. i):FindChild("ProgressBar"):SetBarColor(self.tSettings.slinger.crResource3)
			else
				self.wndResource:FindChild("RUNE" .. i):FindChild("ProgressBar"):SetBarColor(self.tSettings.slinger.crResource1)
			end
			self.wndResource:FindChild("RUNE" .. i):FindChild("ProgressBar"):SetProgress(25)
		else
			if GameLib.IsSpellSurgeActive() then
				self.wndResource:FindChild("RUNE" .. i):FindChild("ProgressBar"):SetBarColor(self.tSettings.slinger.crResource4)
			else
				self.wndResource:FindChild("RUNE" .. i):FindChild("ProgressBar"):SetBarColor(self.tSettings.slinger.crResource2)
			end
			self.wndResource:FindChild("RUNE" .. i):FindChild("ProgressBar"):SetProgress(25 - ((i * 25) - nResource))
		end
	end
	
	if self.tSettings.slinger.bSurgeShadow and GameLib.IsSpellSurgeActive() then
		self.wndResource:FindChild("SpellSurge"):Show(true, true)
	else
		self.wndResource:FindChild("SpellSurge"):Show(false, true)
	end
end

-- stalker
function ForgeUI_ResourceBars:LoadStyle_ResourceBar_Stalker()
	self.wndResource:FindChild("Border"):SetBGColor(self.tSettings.crBorder)
	self.wndResource:FindChild("Background"):SetBGColor(self.tSettings.crBackground)
	self.wndResource:FindChild("ProgressBar"):SetBarColor(self.tSettings.stalker.crResource1)
	
	if self.tSettings.bCenterText then
		self.wndResource:FindChild("Value"):SetAnchorOffsets(0, 0, 0, 0)
	else
		self.wndResource:FindChild("Value"):SetAnchorOffsets(0, -5, 0, 0)
	end
	self.wndResource:FindChild("Value"):SetTextFlags("DT_VCENTER", self.tSettings.bCenterText)
end

function ForgeUI_ResourceBars:RefreshStyle_ResourceBar_Stalker(unitPlayer, nResource)
	self.wndResource:FindChild("ProgressBar"):SetProgress(nResource)
	self.wndResource:FindChild("Value"):SetText(nResource)
	
	if nResource < self.tSettings.stalker.nBreakpoint then
		self.wndResource:FindChild("ProgressBar"):SetBarColor(self.tSettings.stalker.crResource2)
	else
		self.wndResource:FindChild("ProgressBar"):SetBarColor(self.tSettings.stalker.crResource1)
	end
end

-- warrior
function ForgeUI_ResourceBars:LoadStyle_ResourceBar_Warrior()
	self.wndResource:FindChild("Border"):SetBGColor(self.tSettings.crBorder)
	self.wndResource:FindChild("Background"):SetBGColor(self.tSettings.crBackground)
	self.wndResource:FindChild("ProgressBar"):SetMax(self.playerMaxResource)
	
	
	if self.tSettings.bCenterText then
		self.wndResource:FindChild("Value"):SetAnchorOffsets(0, 0, 0, 0)
	else
		self.wndResource:FindChild("Value"):SetAnchorOffsets(0, -5, 0, 0)
	end
	self.wndResource:FindChild("Value"):SetTextFlags("DT_VCENTER", self.tSettings.bCenterText)
	self.wndResource:FindChild("AG_Stacks"):SetTextFlags("DT_VCENTER", self.tSettings.bCenterText)
end

function ForgeUI_ResourceBars:RefreshStyle_ResourceBar_Warrior(unitPlayer, nResource)
	self.wndResource:FindChild("Value"):SetText(nResource)
	self.wndResource:FindChild("ProgressBar"):SetProgress(nResource)
		
	if nResource < 750 then
		self.wndResource:FindChild("ProgressBar"):SetBarColor(self.tSettings.warrior.crResource1)
	else
		self.wndResource:FindChild("ProgressBar"):SetBarColor(self.tSettings.warrior.crResource2)
	end
end

-- focus
function ForgeUI_ResourceBars:LoadStyle_Focus()
end

function ForgeUI_ResourceBars:RefreshStyle_Focus(unitPlayer, nMana, nMaxMana)
	self.wndFocus:FindChild("ProgressBar"):SetMax(nMaxMana)
	self.wndFocus:FindChild("ProgressBar"):SetProgress(nMana)
	self.wndFocus:FindChild("ProgressBar"):SetBarColor(self.tSettings.crFocus)
	self.wndFocus:FindChild("Value"):SetText(ForgeUI.Round(nMana, 0) .. " ( " .. ForgeUI.Round((nMana / nMaxMana) * 100, 1) .. "% )")
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_ResourceBars OnDocLoaded
-----------------------------------------------------------------------------------------------
function ForgeUI_ResourceBars:OnDocLoaded()
	if self.xmlDoc == nil and not self.xmlDoc:IsLoaded() then return end
	
	if ForgeUI == nil then -- forgeui loaded
		ForgeUI = Apollo.GetAddon("ForgeUI")
	end
	
	ForgeUI.API_RegisterAddon(self)
end


-----------------------------------------------------------------------------------------------
-- ForgeUI_ResourceBars Instance
-----------------------------------------------------------------------------------------------
local ForgeUI_ResourceBarsInst = ForgeUI_ResourceBars:new()
ForgeUI_ResourceBarsInst:Init()
