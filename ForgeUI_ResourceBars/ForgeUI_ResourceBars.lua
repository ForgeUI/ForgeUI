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
	self.wndResource:FindChild("Border"):SetBGColor(self.tSettings.crBorder)
	self.wndResource:FindChild("Background"):SetBGColor(self.tSettings.crBackground)
	self.wndResource:FindChild("ProgressBar"):SetMax(self.playerMaxResource)
	
	ForgeUI.API_RegisterWindow(self, self.wndResource, "ForgeUI_ResourceBar", { nLevel = 3, strDisplayName = "Resource bar" })
	
	self.wndContainers.Container:FindChild("EngineerContainer"):Show(true, true)
	
	if self.tSettings.bSmoothBars then
		Apollo.RegisterEventHandler("NextFrame", "OnEngineerUpdate", self)
	else
		Apollo.RegisterEventHandler("VarChange_FrameCount", "OnEngineerUpdate", self)
	end
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
	
	ForgeUI.API_RegisterWindow(self, self.wndResource, "ForgeUI_ResourceBar", { nLevel = 3, strDisplayName = "Resource bar" })
	ForgeUI.API_RegisterWindow(self, self.wndFocus, "ForgeUI_FocusBar", { nLevel = 3, strDisplayName = "Focus bar", crBorder = "FFFFFFFF" })
	
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
	
	ForgeUI.API_RegisterWindow(self, self.wndResource, "ForgeUI_ResourceBar", { nLevel = 3, strDisplayName = "Resource bar" })
	ForgeUI.API_RegisterWindow(self, self.wndFocus, "ForgeUI_FocusBar", { nLevel = 3, strDisplayName = "Focus bar", crBorder = "FFFFFFFF" })
	
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
	
	-- register options
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("Warrior_Color1_EditBox"), self.tSettings.warrior, "crResource1", false, "LoadStyle_ResourceBar_Warrior" )
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.Container:FindChild("Warrior_Color2_EditBox"), self.tSettings.warrior, "crResource2", false, "LoadStyle_ResourceBar_Warrior" )
	
	ForgeUI.API_RegisterWindow(self, self.wndResource, "ForgeUI_ResourceBar", { nLevel = 3, strDisplayName = "Resource bar" })
	
	self.tStylers["LoadStyle_ResourceBar_Warrior"]["LoadStyle_ResourceBar_Warrior"](self)
	
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
		self.wndResource:FindChild("ProgressBar"):SetProgress(nResource)
		
		self.tStylers["RefreshStyle_ResourceBar_Warrior"]["RefreshStyle_ResourceBar_Warrior"](self, unitPlayer, nResource, nResourceMax)
		
		bShow = true
	end
	
	if bShow ~= self.wndResource:IsShown() then
		self.wndResource:Show(bShow, true)
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
		local focusBar = self.wndFocus:FindChild("ProgressBar")
	
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
end

function ForgeUI_ResourceBars:RefreshStyle_ResourceBar_Engineer(unitPlayer, nResource)
end

-- esper
function ForgeUI_ResourceBars:LoadStyle_ResourceBar_Esper()
end

function ForgeUI_ResourceBars:RefreshStyle_ResourceBar_Esper(unitPlayer, nResource)
end

-- medic
function ForgeUI_ResourceBars:LoadStyle_ResourceBar_Medic()
end

function ForgeUI_ResourceBars:RefreshStyle_ResourceBar_Medic(unitPlayer, nResource)
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
end

function ForgeUI_ResourceBars:RefreshStyle_ResourceBar_Stalker(unitPlayer, nResource)
	self.wndResource:FindChild("ProgressBar"):SetProgress(nResource)
	self.wndResource:FindChild("Value"):SetText(nResource)
	
	if nResource < 35 then
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
end

function ForgeUI_ResourceBars:RefreshStyle_ResourceBar_Warrior(unitPlayer, nResource)
	self.wndResource:FindChild("Value"):SetText(nResource)

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
	focusBar:SetMax(nMaxMana)
	focusBar:SetProgress(nMana)
	focusBar:SetBarColor(self.tSettings.crFocus)
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
