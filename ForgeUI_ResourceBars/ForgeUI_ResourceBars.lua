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
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function ForgeUI_ResourceBars:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- mandatory 
    self.api_version = 1
	self.version = "0.1.0"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_ResourceBars"
	self.strDisplayName = "Resource bars"
	
	self.wndContainers = {}
	
	-- optional
	self.tSettings = {
		bSmoothBars = false,
		bPermaShow = false,
		crBorder = "FF000000",
		crBackground = "FF101010",
		crFocus = "FFFFFFFF",
		warrior = {
			crResource1 = "FFE53805",
			crResource2 = "FFEF0000"
		},
		stalker = {
			crResource1 = "FFD23EF4",
			crResource2 = "FF620077"
		},
		engineer = {
			crResource1 = "FF00AEFF",
			crResource2 = "FFFFB000"
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
	self.wndMovables = Apollo.LoadForm(self.xmlDoc, "Movables", nil, self)
	
	ForgeUI.AddItemButton(self, "Resource bars", "Container")
end

function ForgeUI_ResourceBars:ForgeAPI_AfterRestore()
	self:LoadOptions()

	if GameLib.GetPlayerUnit() then
		self:OnCharacterCreated()
	else
		Apollo.RegisterEventHandler("CharacterCreated", 	"OnCharacterCreated", self)
	end
	
end

function ForgeUI_ResourceBars:OnCharacterCreated()
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil then
		Print("ForgeUI ERROR: Wrong class")
		return
	end
	
	local eClassId = unitPlayer:GetClassId()
	if eClassId == GameLib.CodeEnumClass.Engineer then
		self.playerClass = "engineer"
		self:OnEngineerCreated(unitPlayer)
	elseif eClassId == GameLib.CodeEnumClass.Esper then
		self.playerClass = "esper"
		self:OnEsperCreated(unitPlayer)
	elseif eClassId == GameLib.CodeEnumClass.Medic then
		self.playerClass = "medic"
		self:OnMedicCreated(unitPlayer)
	elseif eClassId == GameLib.CodeEnumClass.Spellslinger then
		self.playerClass = "spellslinger"
		self:OnSlingerCreated(unitPlayer)
	elseif eClassId == GameLib.CodeEnumClass.Stalker then
		self.playerClass = "stalker"
		self:OnStalkerCreated(unitPlayer)
	elseif eClassId == GameLib.CodeEnumClass.Warrior then
		self.playerClass = "warrior"
		self:OnWarriorCreated(unitPlayer)	
	end
end

-----------------------------------------------------------------------------------------------
-- Engineer
-----------------------------------------------------------------------------------------------

function ForgeUI_ResourceBars:OnEngineerCreated(unitPlayer)
	self.playerMaxResource = unitPlayer:GetMaxResource(1)

	self.wndResource = Apollo.LoadForm(self.xmlDoc, "ResourceBar_Engineer", "FixedHudStratumHigh", self)
	self.wndResource:FindChild("Border"):SetBGColor(self.tSettings.crBorder)
	self.wndResource:FindChild("Background"):SetBGColor(self.tSettings.crBackground)
	self.wndResource:FindChild("ProgressBar"):SetMax(self.playerMaxResource)
	
	self.wndContainers.Container:FindChild("EngineerContainer"):Show(true, true)
	
	if self.tSettings.bSmoothBars then
		Apollo.RegisterEventHandler("NextFrame", "OnEngineerUpdate", self)
	else
		Apollo.RegisterEventHandler("VarChange_FrameCount", "OnEngineerUpdate", self)
	end
	
	ForgeUI.RegisterWindowPosition(self, self.wndResource, "ForgeUI_ResourceBars_Resource", self.wndMovables:FindChild("Movable_Resource"))
end

function ForgeUI_ResourceBars:OnEngineerUpdate()
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end
	
	local nResource = unitPlayer:GetResource(1)
	if unitPlayer:IsInCombat() or nResource > 0 or self.tSettings.bPermaShow  then
		self.wndResource:FindChild("ProgressBar"):SetProgress(nResource)
		self.wndResource:FindChild("Value"):SetText(nResource)
		
		if nResource < 30 or nResource > 70 then
			self.wndResource:FindChild("ProgressBar"):SetBarColor(self.tSettings.engineer.crResource1)
		else
			self.wndResource:FindChild("ProgressBar"):SetBarColor(self.tSettings.engineer.crResource2)
		end
		
		self.wndResource:Show(true, true)
	else
		self.wndResource:Show(false, true)
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
	
	for i = 1, self.playerMaxResource do
		self.wndResource:FindChild("PSI" .. i):SetBGColor(self.tSettings.crBorder)
		self.wndResource:FindChild("PSI" .. i):FindChild("Background"):SetBGColor(self.tSettings.crBackground)
		self.wndResource:FindChild("PSI" .. i):FindChild("ProgressBar"):SetBarColor(self.tSettings.esper.crResource1)
		self.wndResource:FindChild("PSI" .. i):FindChild("ProgressBar"):SetMax(1)
	end
	
	if self.tSettings.bSmoothBars then
		Apollo.RegisterEventHandler("NextFrame", "OnEsperUpdate", self)
	else
		Apollo.RegisterEventHandler("VarChange_FrameCount", "OnEsperUpdate", self)
	end
	
	ForgeUI.RegisterWindowPosition(self, self.wndResource, "ForgeUI_ResourceBars_Resource", self.wndMovables:FindChild("Movable_Resource"))
	ForgeUI.RegisterWindowPosition(self, self.wndFocus, "ForgeUI_ResourceBars_Focus", self.wndMovables:FindChild("Movable_Focus"))
end

function ForgeUI_ResourceBars:OnEsperUpdate()
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end
	
	local nResource = unitPlayer:GetResource(1)
	
	if unitPlayer:IsInCombat() or nResource > 0 or self.tSettings.bPermaShow  then
		for i = 1, self.playerMaxResource do
			if nResource >= i then
				self.wndResource:FindChild("PSI" .. i):FindChild("ProgressBar"):SetProgress(1)
			else
				self.wndResource:FindChild("PSI" .. i):FindChild("ProgressBar"):SetProgress(0)
			end
		end
		
		self.wndResource:Show(true, true)
	else
		self.wndResource:Show(false, true)
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
	
	for i = 1, self.playerMaxResource do
		self.wndResource:FindChild("ACU" .. i):SetBGColor(self.tSettings.crBorder)
		self.wndResource:FindChild("ACU" .. i):FindChild("Background"):SetBGColor(self.tSettings.crBackground)
		self.wndResource:FindChild("ACU" .. i):FindChild("ProgressBar"):SetMax(3)
	end
	
	if self.tSettings.bSmoothBars then
		Apollo.RegisterEventHandler("NextFrame", "OnMedicUpdate", self)
	else
		Apollo.RegisterEventHandler("VarChange_FrameCount", "OnMedicUpdate", self)
	end
	
	ForgeUI.RegisterWindowPosition(self, self.wndResource, "ForgeUI_ResourceBars_Resource", self.wndMovables:FindChild("Movable_Resource"))
	ForgeUI.RegisterWindowPosition(self, self.wndFocus, "ForgeUI_ResourceBars_Focus", self.wndMovables:FindChild("Movable_Focus"))
end

function ForgeUI_ResourceBars:OnMedicUpdate()
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end
	
	local nResource = unitPlayer:GetResource(1)
	
	if unitPlayer:IsInCombat() or nResource < self.playerMaxResource or self.tSettings.bPermaShow  then
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
		
		self.wndResource:Show(true, true)
	else
		self.wndResource:Show(false, true)
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
	
	for i = 1, 4 do
		self.wndResource:FindChild("RUNE" .. i):SetBGColor(self.tSettings.crBorder)
		self.wndResource:FindChild("RUNE" .. i):FindChild("Background"):SetBGColor(self.tSettings.crBackground)
		self.wndResource:FindChild("RUNE" .. i):FindChild("ProgressBar"):SetMax(25)
	end
	
	if self.tSettings.bSmoothBars then
		Apollo.RegisterEventHandler("NextFrame", "OnSlingerUpdate", self)
	else
		Apollo.RegisterEventHandler("VarChange_FrameCount", "OnSlingerUpdate", self)
	end
	
	ForgeUI.RegisterWindowPosition(self, self.wndResource, "ForgeUI_ResourceBars_Resource", self.wndMovables:FindChild("Movable_Resource"))
	ForgeUI.RegisterWindowPosition(self, self.wndFocus, "ForgeUI_ResourceBars_Focus", self.wndMovables:FindChild("Movable_Focus"))
end

function ForgeUI_ResourceBars:OnSlingerUpdate()
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end
	
	local nResource = unitPlayer:GetResource(4)
	
	if unitPlayer:IsInCombat() or GameLib.IsSpellSurgeActive() or nResource < self.playerMaxResource or self.tSettings.bPermaShow  then
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
		
		self.wndResource:Show(true, true)
	else
		self.wndResource:Show(false, true)
	end
	
	if self.tSettings.slinger.bSurgeShadow and GameLib.IsSpellSurgeActive() then
		self.wndResource:FindChild("SpellSurge"):Show(true, true)
	else
		self.wndResource:FindChild("SpellSurge"):Show(false, true)
	end

	self:UpdateFocus(unitPlayer)
end

-----------------------------------------------------------------------------------------------
-- Stalker
-----------------------------------------------------------------------------------------------

function ForgeUI_ResourceBars:OnStalkerCreated(unitPlayer)
	self.playerMaxResource = unitPlayer:GetMaxResource(1)

	self.wndResource = Apollo.LoadForm(self.xmlDoc, "ResourceBar_Stalker", "FixedHudStratumHigh", self)
	self.wndResource:FindChild("Border"):SetBGColor(self.tSettings.crBorder)
	self.wndResource:FindChild("Background"):SetBGColor(self.tSettings.crBackground)
	self.wndResource:FindChild("ProgressBar"):SetBarColor(self.tSettings.stalker.crResource1)
	self.wndResource:FindChild("ProgressBar"):SetMax(100)
	
	self.wndContainers.Container:FindChild("StalkerContainer"):Show(true, true)
	
	if self.tSettings.bSmoothBars then
		Apollo.RegisterEventHandler("NextFrame", "OnStalkerUpdate", self)
	else
		Apollo.RegisterEventHandler("VarChange_FrameCount", "OnStalkerUpdate", self)
	end
	
	ForgeUI.RegisterWindowPosition(self, self.wndResource, "ForgeUI_ResourceBars_Resource", self.wndMovables:FindChild("Movable_Resource"))
end

function ForgeUI_ResourceBars:OnStalkerUpdate()
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end
	
	local nResource = unitPlayer:GetResource(3)
	if unitPlayer:IsInCombat() or nResource < self.playerMaxResource or self.tSettings.bPermaShow  then
		self.wndResource:FindChild("ProgressBar"):SetProgress(nResource)
		self.wndResource:FindChild("Value"):SetText(nResource)
		
		if nResource < 35 then
			self.wndResource:FindChild("ProgressBar"):SetBarColor(self.tSettings.stalker.crResource2)
		else
			self.wndResource:FindChild("ProgressBar"):SetBarColor(self.tSettings.stalker.crResource1)
		end
		
		self.wndResource:Show(true, true)
	else
		self.wndResource:Show(false, true)
	end
end

-----------------------------------------------------------------------------------------------
-- Warrior
-----------------------------------------------------------------------------------------------

function ForgeUI_ResourceBars:OnWarriorCreated(unitPlayer)
	self.playerMaxResource = unitPlayer:GetMaxResource(1)

	self.wndResource = Apollo.LoadForm(self.xmlDoc, "ResourceBar_Warrior", "FixedHudStratumHigh", self)
	self.wndResource:FindChild("Border"):SetBGColor(self.tSettings.crBorder)
	self.wndResource:FindChild("Background"):SetBGColor(self.tSettings.crBackground)
	self.wndResource:FindChild("ProgressBar"):SetMax(self.playerMaxResource)
	
	self.wndContainers.Container:FindChild("WarriorContainer"):Show(true, true)
	
	if self.tSettings.bSmoothBars then
		Apollo.RegisterEventHandler("NextFrame", "OnWarriorUpdate", self)
	else
		Apollo.RegisterEventHandler("VarChange_FrameCount", "OnWarriorUpdate", self)
	end
	
	ForgeUI.RegisterWindowPosition(self, self.wndResource, "ForgeUI_ResourceBars_Resource", self.wndMovables:FindChild("Movable_Resource"))
end

function ForgeUI_ResourceBars:OnWarriorUpdate()
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end
	
	local nResource = unitPlayer:GetResource(1)
	if unitPlayer:IsInCombat() or nResource > 0 or self.tSettings.bPermaShow then
		self.wndResource:FindChild("ProgressBar"):SetProgress(nResource)
		self.wndResource:FindChild("Value"):SetText(nResource)
		
		if nResource < 750 then
			self.wndResource:FindChild("ProgressBar"):SetBarColor(self.tSettings.warrior.crResource1)
		else
			self.wndResource:FindChild("ProgressBar"):SetBarColor(self.tSettings.warrior.crResource2)
		end
		
		self.wndResource:Show(true, true)
	else
		self.wndResource:Show(false, true)
	end
end

-----------------------------------------------------------------------------------------------
-- focus
-----------------------------------------------------------------------------------------------

function ForgeUI_ResourceBars:UpdateFocus(unitPlayer)
	if unitPlayer == nil or not unitPlayer:IsValid() then return end
	if self.wndFocus == nil then return end
	
	local nMana = unitPlayer:GetMana()
	local nMaxMana = unitPlayer:GetMaxMana()
	
	if nMana < nMaxMana then
		local focusBar = self.wndFocus:FindChild("ProgressBar")
	
		focusBar:SetMax(nMaxMana)
		focusBar:SetProgress(nMana)
		focusBar:SetBarColor(self.tSettings.crFocus)
		self.wndFocus:FindChild("Value"):SetText(ForgeUI.Round(nMana, 0) .. " ( " .. ForgeUI.Round((nMana / nMaxMana) * 100, 1) .. "% )")
		
		self.wndFocus:Show(true, true)
	else
		self.wndFocus:Show(false, true)
	end
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_ResourceBars OnDocLoaded
-----------------------------------------------------------------------------------------------
function ForgeUI_ResourceBars:OnDocLoaded()
	if self.xmlDoc == nil and not self.xmlDoc:IsLoaded() then return end
	
	if ForgeUI == nil then -- forgeui loaded
		ForgeUI = Apollo.GetAddon("ForgeUI")
	end
	
	ForgeUI.RegisterAddon(self)
end

---------------------------------------------------------------------------------------------------
-- Movables Functions
---------------------------------------------------------------------------------------------------

function ForgeUI_ResourceBars:OnMovableMove( wndHandler, wndControl, nOldLeft, nOldTop, nOldRight, nOldBottom )
	if wndControl:GetName() == "Movable_Resource" then
		self.wndResource:SetAnchorOffsets(wndControl:GetAnchorOffsets())
	elseif wndControl:GetName() == "Movable_Focus" then
		self.wndFocus:SetAnchorOffsets(wndControl:GetAnchorOffsets())
	end
end

---------------------------------------------------------------------------------------------------
-- Options
---------------------------------------------------------------------------------------------------

function ForgeUI_ResourceBars:OnOptionsChanged( wndHandler, wndControl )
	if wndControl:GetName() == "SmoothBars_CheckBox" then
		self.tSettings.bSmoothBars = wndControl:IsChecked()
	elseif wndControl:GetName() == "PermaShow_CheckBox" then
		self.tSettings.bPermaShow = wndControl:IsChecked()
	elseif wndControl:GetName() == "BorderColor_EditBox" then
		ForgeUI.ColorBoxChange(self, wndControl, self.tSettings, "crBorder")
	elseif wndControl:GetName() == "BackgroundColor_EditBox" then
		ForgeUI.ColorBoxChange(self, wndControl, self.tSettings, "crBackground")
	end
	
	-- warrior
	if wndControl:GetName() == "Warrior_Color1_EditBox" then
		ForgeUI.ColorBoxChange(self, wndControl, self.tSettings.warrior, "crResource1")
	elseif wndControl:GetName() == "Warrior_Color2_EditBox" then
		ForgeUI.ColorBoxChange(self, wndControl, self.tSettings.warrior, "crResource2")
	end
	
	-- stalker
	if wndControl:GetName() == "Stalker_Color1_EditBox" then
		ForgeUI.ColorBoxChange(self, wndControl, self.tSettings.stalker, "crResource1")
	elseif wndControl:GetName() == "Stalker_Color2_EditBox" then
		ForgeUI.ColorBoxChange(self, wndControl, self.tSettings.stalker, "crResource2")
	end
	
	-- medic
	if wndControl:GetName() == "Medic_Color1_EditBox" then
		ForgeUI.ColorBoxChange(self, wndControl, self.tSettings.medic, "crResource1")
	elseif wndControl:GetName() == "Medic_Color2_EditBox" then
		ForgeUI.ColorBoxChange(self, wndControl, self.tSettings.medic, "crResource2")
	end
	
	-- esper
	if wndControl:GetName() == "Esper_Color1_EditBox" then
		ForgeUI.ColorBoxChange(self, wndControl, self.tSettings.esper, "crResource1")
	end
	
	-- engineer
	if wndControl:GetName() == "Engineer_Color1_EditBox" then
		ForgeUI.ColorBoxChange(self, wndControl, self.tSettings.engineer, "crResource1")
	elseif wndControl:GetName() == "Engineer_Color2_EditBox" then
		ForgeUI.ColorBoxChange(self, wndControl, self.tSettings.engineer, "crResource2")
	end
	
	-- slinger
	if wndControl:GetName() == "Slinger_Color1_EditBox" then
		ForgeUI.ColorBoxChange(self, wndControl, self.tSettings.slinger, "crResource1")
	elseif wndControl:GetName() == "Slinger_Color2_EditBox" then
		ForgeUI.ColorBoxChange(self, wndControl, self.tSettings.slinger, "crResource2")
	elseif wndControl:GetName() == "Slinger_Color3_EditBox" then
		ForgeUI.ColorBoxChange(self, wndControl, self.tSettings.slinger, "crResource3")
	elseif wndControl:GetName() == "Slinger_Color4_EditBox" then
		ForgeUI.ColorBoxChange(self, wndControl, self.tSettings.slinger, "crResource4")
	elseif wndControl:GetName() == "bSurgeShadow" then
		self.tSettings.slinger.bSurgeShadow = wndControl:IsChecked()
	end
	
	if wndControl:GetName() == "crFocus" then
		ForgeUI.ColorBoxChange(self, wndControl, self.tSettings, "crFocus")
	end
end

function ForgeUI_ResourceBars:LoadOptions()
	self.wndContainers.Container:FindChild("SmoothBars_CheckBox"):SetCheck(self.tSettings.bSmoothBars)
	self.wndContainers.Container:FindChild("PermaShow_CheckBox"):SetCheck(self.tSettings.bPermaShow)
	
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("BorderColor_EditBox"), self.tSettings, "crBorder", true)
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("BackgroundColor_EditBox"), self.tSettings, "crBackground", true)
	
	-- warrior
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("Warrior_Color1_EditBox"), self.tSettings.warrior, "crResource1", true)
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("Warrior_Color2_EditBox"), self.tSettings.warrior, "crResource2", true)
	
	-- stalker
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("Stalker_Color1_EditBox"), self.tSettings.stalker, "crResource1", true)
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("Stalker_Color2_EditBox"), self.tSettings.stalker, "crResource2", true)
	
	-- medic
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("Medic_Color1_EditBox"), self.tSettings.medic, "crResource1", true)
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("Medic_Color2_EditBox"), self.tSettings.medic, "crResource2", true)
	
	-- esper
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("Esper_Color1_EditBox"), self.tSettings.esper, "crResource1", true)
	
	-- engineer
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("Engineer_Color1_EditBox"), self.tSettings.engineer, "crResource1", true)
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("Engineer_Color2_EditBox"), self.tSettings.engineer, "crResource2", true)
	
	-- slinger
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("Slinger_Color1_EditBox"), self.tSettings.slinger, "crResource1", true)
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("Slinger_Color2_EditBox"), self.tSettings.slinger, "crResource2", true)
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("Slinger_Color3_EditBox"), self.tSettings.slinger, "crResource3", true)
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("Slinger_Color4_EditBox"), self.tSettings.slinger, "crResource4", true)
	self.wndContainers.Container:FindChild("bSurgeShadow"):SetCheck(self.tSettings.slinger.bSurgeShadow)
	
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("EsperContainer"):FindChild("crFocus"), self.tSettings, "crFocus", true)
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("MedicContainer"):FindChild("crFocus"), self.tSettings, "crFocus", true)
	ForgeUI.ColorBoxChange(self, self.wndContainers.Container:FindChild("SlingerContainer"):FindChild("crFocus"), self.tSettings, "crFocus", true)
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_ResourceBars Instance
-----------------------------------------------------------------------------------------------
local ForgeUI_ResourceBarsInst = ForgeUI_ResourceBars:new()
ForgeUI_ResourceBarsInst:Init()
