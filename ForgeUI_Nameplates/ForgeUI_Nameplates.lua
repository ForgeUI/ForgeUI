require "Window"
 
local ForgeUI
local ForgeUI_Nameplates = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
tClassEnums = {
	[GameLib.CodeEnumClass.Warrior]      	= "Warrior",
	[GameLib.CodeEnumClass.Engineer]     	= "Engineer",
	[GameLib.CodeEnumClass.Esper]        	= "Esper",
	[GameLib.CodeEnumClass.Medic]        	= "Medic",
	[GameLib.CodeEnumClass.Stalker]      	= "Stalker",
	[GameLib.CodeEnumClass.Spellslinger]	= "Spellslinger"
}

local tNpcRankEnums = {
	[Unit.CodeEnumRank.Elite] 		= "elite",
	[Unit.CodeEnumRank.Superior] 	= "superior",
	[Unit.CodeEnumRank.Champion] 	= "champion",
	[Unit.CodeEnumRank.Standard] 	= "standard",
	[Unit.CodeEnumRank.Minion] 		= "minion",
	[Unit.CodeEnumRank.Fodder] 		= "fodder",
}

local tDispositionId = {
	[0] = "Hostile",
	[1] = "Neutral",
	[2] = "Friendly",
	[3] = "Unknown",
}

local _pairs		= pairs

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function ForgeUI_Nameplates:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

     -- mandatory 
	self.api_version = 2
	self.version = "0.0.1"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_Nameplates"
	self.strDisplayName = "Nameplates"
	
	self.wndContainers = {}
	
	self.tStylers = {
		["LoadStyle_Nameplate"] = self, -- (tNameplate)
		["UpdateStyle_Nameplate"] = self, -- (tNameplate)
		["RefreshStyle_Nameplate"] = self, -- (tNameplate)
	}
	
	-- optional
	self.settings_version = 2
	self.tSettings = {
		nMaxRange = 75,
		crMooBar = "FF7E00FF",
		crCastBar = "FFFEB308",
		crShieldBar = "FFFFFFFF",
		crBgBar = "FF101010",
		crAbsorbBar = "FFFFC600",
		bShowAbsorbBar = true,
		bUseOcclusion = true,
		bShowTitles = false,
		nBarWidth = 100,
		nHpBarHeight = 7,
		nShieldBarHeight = 4,
		bShowQuestIcons = true,
		bShowInfo = false,
		bClickable = true,
		tTarget = {
			bShow = true,
			bShowBars = true,
			bShowCast = true,
			bShowMarker = true,
			crMarker = "FFFFFFFF"
		},
		tPlayer = {
			bShow = false,
			bShowBars = false,
			bShowBarsInCombat = false,
			nHideBarsOver = 100,
			bUseClassColors = false,
			bShowCast = false,
			bShowGuild = false,
			crName = "FFFFFFFF",
			crBar = "FF15B01A"
		},
		tHostile = {
			bShow = true,
			bShowBars = false,
			bShowBarsInCombat = true,
			nHideBarsOver = 100,
			bShowCast = true,
			bShowGuild = false,
			crName = "FFD9544D",
			crBar = "FFE50000"
		},
		tNeutral = {
			bShow = true,
			bShowBars = false,
			bShowBarsInCombat = true,
			nHideBarsOver = 100,
			bShowCast = false,
			bShowGuild = false,
			crName = "FFFFF569",
			crBar = "FFF3D829"
		},
		tFriendly = {
			bShow = true,
			bOnlyImportantNPCs = true,
			bShowBars = false,
			bShowBarsInCombat = true,
			nHideBarsOver = 100,
			bShowCast = false,
			bShowGuild = true,
			crName = "FF76CD26",
			crBar = "FF15B01A"
		},
		tUnknown = {
			bShow = false,
			bShowBars = false,
			bShowBarsInCombat = false,
			nHideBarsOver = 100,
			bUseClassColors = false,
			bShowCast = false,
			bShowGuild = false,
			crName = "FFFFFFFF",
			crNamePvP = "FFFFFFFF",
			crBar = "FFFFFFFF"
		},
		tFriendlyPlayer = {
			bShow = true,
			bShowBars = true,
			bShowBarsInCombat = true,
			nHideBarsOver = 100,
			bUseClassColors = true,
			bShowCast = false,
			bShowGuild = false,
			bShowCleanse = false,
			crName = "FFFFFFFF",
			crBar = "FF15B01A"
		},
		tPartyPlayer = {
			bShow = true,
			bShowBars = true,
			bShowBarsInCombat = true,
			nHideBarsOver = 100,
			bUseClassColors = true,
			bShowCast = false,
			bShowGuild = false,
			bShowCleanse = false,
			crName = "FF43C8F3",
			crBar = "FF15B01A"
		},
		tHostilePlayer = {
			bShow = true,
			bShowBars = true,
			bShowBarsInCombat = true,
			nHideBarsOver = 100,
			bUseClassColors = true,
			bShowCast = true,
			bShowGuild = false,
			crName = "FFD9544D",
			crNamePvP = "FFFF0000",
			crBar = "FFE50000"
		},
		tFriendlyPet = {
			bShow = false,
			bShowBars = false,
			bShowBarsInCombat = false,
			nHideBarsOver = 100,
			bShowCast = false,
			crName = "FFFFFFFF",
			crBar = "FFFFFFFF"
		},
		tPlayerPet = {
			bShow = true,
			bShowBars = false,
			bShowBarsInCombat = false,
			nHideBarsOver = 100,
			bShowCast = false,
			crName = "FFFFFFFF",
			crBar = "FFFFFFFF"
		},
		tHostilePet = {
			bShow = false,
			bShowBars = false,
			bShowBarsInCombat = false,
			nHideBarsOver = 100,
			bShowCast = false,
			crName = "FFFFFFFF",
			crBar = "FFFFFFFF"
		},
		tCollectible = {
			bShow = false,
			crName = "FFFFFFFF",
		},
		tPinataLoot = {
			bShow = false,
			crName = "FFFFFFFF",
		},
		tMount = {
			bShow = false,
			crName = "FFFFFFFF",
		},
		tSimple = {
			bShow = false,
			crName = "FFFFFFFF",
		},
		tPickup  = { -- player's weapon for example
			bShow = true,
			crName = "FFFFFFFF",
		},
		tPickupNotPlayer  = { -- weapons for example
			bShow = false,
			crName = "FFFFFFFF",
		}
	}
	
	self.unitPlayer = nil
	self.tUnits = {}
	self.tNameplates = {}
	self.tHiddenNameplates = {}
	
	self.tUnitsInQueue = {}

    return o
end

function ForgeUI_Nameplates:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"ForgeUI"
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- ForgeUI_Nameplates OnLoad
-----------------------------------------------------------------------------------------------
function ForgeUI_Nameplates:OnLoad()
    self.xmlDoc = XmlDoc.CreateFromFile("ForgeUI_Nameplates.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	
	Apollo.RegisterEventHandler("UnitCreated", "OnUnitCreated", self)
	Apollo.RegisterEventHandler("UnitDestroyed", "OnUnitDestroyed", self)
	Apollo.RegisterEventHandler("TargetUnitChanged", "OnTargetUnitChanged", self)
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_Nameplates OnDocLoaded
-----------------------------------------------------------------------------------------------
function ForgeUI_Nameplates:OnDocLoaded()
	if self.xmlDoc == nil or not self.xmlDoc:IsLoaded() then return end
	
	if ForgeUI == nil then -- forgeui loaded
		ForgeUI = Apollo.GetAddon("ForgeUI")
	end
	
	ForgeUI.API_RegisterAddon(self)
end

function ForgeUI_Nameplates:ForgeAPI_AfterRegistration()
	Apollo.RegisterEventHandler("VarChange_FrameCount", "OnFrame", self)
	
	local wndItemButton = ForgeUI.API_AddItemButton(self, "Nameplates")
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "General", { strContainer = "Container_General", bDefault = true })
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "Target", { strContainer = "Container_Target" })
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "Player", { strContainer = "Container_Player" })
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "Friendly player", { strContainer = "Container_FriendlyPlayer" })
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "Party player", { strContainer = "Container_PartyPlayer" })
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "Hostile player", { strContainer = "Container_HostilePlayer" })
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "Friendly NPC", { strContainer = "Container_Friendly" })
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "Neutral NPC", { strContainer = "Container_Neutral" })
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "Hostile NPC", { strContainer = "Container_Hostile" })
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "Player pet", { strContainer = "Container_PlayerPet" })
	--ForgeUI.AddItemListToButton(self, wndItemButton, {
	--	{ strDisplayName = "General", strContainer = "Container_General", bDefault = true },
	--	{ strDisplayName = "Target", strContainer = "Container_Target" },
	--	{ strDisplayName = "Player", strContainer = "Container_Player" },
	--	{ strDisplayName = "Friendly player", strContainer = "Container_FriendlyPlayer" },
	--	{ strDisplayName = "Party player", strContainer = "Container_PartyPlayer" },
	--	{ strDisplayName = "Hostile player", strContainer = "Container_HostilePlayer" },
	--	{ strDisplayName = "Friendly NPC", strContainer = "Container_Friendly" },
	--	{ strDisplayName = "Neutral NPC", strContainer = "Container_Neutral" },
	--	{ strDisplayName = "Hostile NPC", strContainer = "Container_Hostile" },
	--	{ strDisplayName = "Player pet", strContainer = "Container_PlayerPet" }
	--})
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_Nameplates EventHandler
-----------------------------------------------------------------------------------------------
function ForgeUI_Nameplates:OnFrame()
	self.unitPlayer = GameLib.GetPlayerUnit()
	
	self:AddNewUnits()
	self:UpdateNameplates()
end

function ForgeUI_Nameplates:OnUnitCreated(unit)
	self.tUnitsInQueue[unit:GetId()] = unit
end

function ForgeUI_Nameplates:OnUnitDestroyed(unit)
	self.tUnitsInQueue[unit:GetId()] = nil
	self.tUnits[unit:GetId()] = nil
	if self.tNameplates[unit:GetId()] ~= nil then
		self.tNameplates[unit:GetId()].wndNameplate:Destroy()
	end
	self.tNameplates[unit:GetId()] = nil
end

function ForgeUI_Nameplates:OnTargetUnitChanged(unit)
	for _, tNameplate in _pairs(self.tNameplates) do
		tNameplate.bIsTarget = false
	end
	
	if unit == nil then return end
	
	local tNameplate = self.tNameplates[unit:GetId()]
	if tNameplate == nil then return end
	
	tNameplate.bIsTarget = true
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_Nameplates Nameplate functions
-----------------------------------------------------------------------------------------------
function ForgeUI_Nameplates:UpdateNameplates()
	for idx, tNameplate in _pairs(self.tNameplates) do
		if self:UpdateNameplateVisibility(tNameplate) then
			self:UpdateNameplate(tNameplate)
			if tNameplate.bNeedUpdate then
				self.tStylers["UpdateStyle_Nameplate"]["UpdateStyle_Nameplate"](self, tNameplate)
				tNameplate.bNeedUpdate = false
			end
			self.tStylers["RefreshStyle_Nameplate"]["RefreshStyle_Nameplate"](self, tNameplate)
		end
	end
end

function ForgeUI_Nameplates:UpdateNameplate(tNameplate)
	tNameplate.unitType = self:GetUnitType(tNameplate.unitOwner)
	
	self:UpdateName(tNameplate)
	self:UpdateInfo(tNameplate)
	self:UpdateBars(tNameplate)
	self:UpdateGuild(tNameplate)
	self:UpdateCast(tNameplate)
end

-- update name
function ForgeUI_Nameplates:UpdateName(tNameplate)
	local unitOwner = tNameplate.unitOwner
	local name = tNameplate.wnd.name
	
	local newName = ""
	if self.tSettings.bShowTitles then
		newName = unitOwner:GetTitleOrName()
	else
		newName = unitOwner:GetName()
	end
	
	if newName ~= name:GetText() then
		name:SetText(newName)
		
		local nNameWidth = Apollo.GetTextWidth("Nameplates", newName .. " ")
		local nLeft, nTop, nRight, nBottom = name:GetAnchorOffsets()
		name:SetAnchorOffsets(- (nNameWidth / 2), nTop, (nNameWidth / 2), nBottom)
	end
	
	if unitOwner:IsPvpFlagged() and self.tSettings["t" .. tNameplate.unitType].crNamePvP ~= nil then
		name:SetTextColor(self.tSettings["t" .. tNameplate.unitType].crNamePvP)
	else
		name:SetTextColor(self.tSettings["t" .. tNameplate.unitType].crName)
	end
	
	local questIcon = tNameplate.wnd.quest
	local challangeIcon = tNameplate.wnd.challange
	local bShowQuest = false
	local bShowChalange = false
	if self.tSettings.bShowQuestIcons then
		local tRewardInfo = tNameplate.unitOwner:GetRewardInfo()
		if tRewardInfo == nil then return end
		
		for _, reward in _pairs(tRewardInfo) do
			if reward.strType == "Quest" or reward.strType == "PublicEvent" then
				bShowQuest = true
			end
			
			if reward.strType == "Challange" then
				bShowChalange = true
			end
		end
	end
	
	if questIcon:IsShown() ~= bShowQuest then
		questIcon:Show(bShowQuest, true)
	end
	
	if challangeIcon:IsShown() ~= bShowChalange then
		challangeIcon:Show(bShowChalange, true)
	end
end

-- update info
function ForgeUI_Nameplates:UpdateInfo(tNameplate)
	local unitOwner = tNameplate.unitOwner
	local info = tNameplate.wnd.info
	
	local bShow = self.tSettings.bShowInfo
	if bShow then
		local info_level = tNameplate.wnd.info_level
		local info_icon = tNameplate.wnd.info_icon
		
		info_level:SetText(unitOwner:GetLevel())
	end
	
	if bShow ~= info:IsShown() then
		info:Show(bShow, true)
	end
end

-- update guild
function ForgeUI_Nameplates:UpdateGuild(tNameplate)
	local unitOwner = tNameplate.unitOwner
	local guild = tNameplate.wnd.guild
	local bShow = false

	local strGuildName = unitOwner:GetAffiliationName()
	
	if strGuildName ~= nil and strGuildName ~= "" then
		if self.tSettings["t" .. tNameplate.unitType].bShowGuild == true then
			strGuildName = String_GetWeaselString(Apollo.GetString("Nameplates_GuildDisplay"), strGuildName)
		
			local nNameWidth = Apollo.GetTextWidth("Nameplates", strGuildName .. " ")
			local nLeft, nTop, nRight, nBottom = guild:GetAnchorOffsets()
			guild:SetAnchorOffsets(- (nNameWidth / 2), nTop, (nNameWidth / 2), nBottom)			
			
			guild:SetTextRaw(strGuildName)
			guild:SetTextColor(self.tSettings["t" .. tNameplate.unitType].crName)
			
			bShow = true
		end
	else
		guild:SetText("")
		bShow = false
	end
	
	if bShow ~= guild:IsShown() then
		guild:Show(bShow, true)
		tNameplate.bNeedUpdate = true
	end
end

-- update bars
function ForgeUI_Nameplates:UpdateBars(tNameplate)
	local bar = tNameplate.wnd.bar
	local unitOwner = tNameplate.unitOwner
	
	local bShow = false

	if self.tSettings["t" ..tNameplate.unitType].bShowBars ~= nil then
		bShow = self.tSettings["t" ..tNameplate.unitType].bShowBars
	
		if unitOwner:IsInCombat() then
			bShow = self.tSettings["t" ..tNameplate.unitType].bShowBarsInCombat
		end
		
		local hpMax = unitOwner:GetMaxHealth()
		if hpMax ~= nil then	
		
			local hp = unitOwner:GetHealth()
		
			if ((hp / hpMax) * 100) > self.tSettings["t" .. tNameplate.unitType].nHideBarsOver then
				bShow = false
			end
		end
		
		if tNameplate.bIsTarget then
			bShow = self.tSettings.tTarget.bShowBars
		end
	end
	
	if self:UpdateCleanse(tNameplate) then
		bShow = true
	end
	
	if bShow ~= bar:IsShown() then
		bar:Show(bShow, true)
	end
	
	if bShow then
		self:UpdateHealth(tNameplate)
		self:UpdateArmor(tNameplate)
		self:UpdateAbsorb(tNameplate)
		self:UpdateShield(tNameplate)
		self:UpdateMarker(tNameplate)
	end
end

-- update healthbar
function ForgeUI_Nameplates:UpdateHealth(tNameplate)
	local unitOwner = tNameplate.unitOwner
	local hp = tNameplate.wnd.hp
	local progressBar = tNameplate.wnd.hpBar
	
	local bShow = false
	
	local maxHp = unitOwner:GetMaxHealth()
	
	if maxHp ~= nil and maxHp > 0 then
		progressBar:SetMax(maxHp)
		progressBar:SetProgress(unitOwner:GetHealth())
		
		local nTime = unitOwner:GetCCStateTimeRemaining(Unit.CodeEnumCCState.Vulnerability)
		if nTime > 0 then
			progressBar:SetBarColor(self.tSettings.crMooBar)
		else
			if unitOwner:GetType() == "Player" and self.tSettings["t" .. tNameplate.unitType].bUseClassColors then
				progressBar:SetBarColor(ForgeUI.tSettings.tClassColors["cr" .. tClassEnums[unitOwner:GetClassId()]])
			else
				progressBar:SetBarColor(self.tSettings["t" .. tNameplate.unitType].crBar)
			end
		end
		
		bShow = true
	end
	
	if bShow ~= hp:IsShown() then
		hp:Show(bShow, true)
	end
end

-- update shieldbar
function ForgeUI_Nameplates:UpdateShield(tNameplate)
	local unitOwner = tNameplate.unitOwner
	local bar = tNameplate.wnd.shield
	local progressBar = tNameplate.wnd.shieldBar
	
	local bShow = false
	
	if self.tSettings.nShieldBarHeight > 0 then
		local nMax = unitOwner:GetShieldCapacityMax()
		local nValue = unitOwner:GetShieldCapacity()
		
		if nValue ~= 0 then
			progressBar:SetMax(nMax)
			progressBar:SetProgress(nValue)
			
			bShow = true
		end
	end
		
	if bar:IsShown() ~= bShow then
		bar:Show(bShow, true)
		tNameplate.bNeedUpdate = true
	end
end

-- update absorbbar
function ForgeUI_Nameplates:UpdateAbsorb(tNameplate)
	local unitOwner = tNameplate.unitOwner
	local absorbBar = tNameplate.wnd.absorbBar
	
	local bShow = false
	
	if self.tSettings.bShowAbsorbBar then
		local nValue = unitOwner:GetAbsorptionValue()
		
		if nValue ~= nil and nValue > 0 and not unitOwner:IsDead() then
			local nMax = unitOwner:GetAbsorptionMax()
		
			absorbBar:SetMax(nMax)
			absorbBar:SetProgress(nValue)
			
			bShow = true
		end           
	end
	
	if bShow ~= absorbBar:IsShown() then
		absorbBar:Show(bShow, true)
	end
end

-- update cleanse
function ForgeUI_Nameplates:UpdateCleanse(tNameplate)
	local unitOwner = tNameplate.unitOwner
	local cleanse = tNameplate.wnd.cleanse
	
	local bShow = false
	
	if self.tSettings["t" .. tNameplate.unitType].bShowCleanse then
		local debuffs = unitOwner:GetBuffs().arHarmful
		
		for _, debuff in pairs(debuffs) do
			if debuff["splEffect"]:GetClass() == Spell.CodeEnumSpellClass.DebuffDispellable then
				bShow = true
			end
		end
	end
	
	if cleanse:IsShown() ~= bShow then
		cleanse:Show(bShow, true)
	end
	
	return bShow
end

-- update castbar
function ForgeUI_Nameplates:UpdateCast(tNameplate)
	local unitOwner = tNameplate.unitOwner
	local cast = tNameplate.wnd.cast
	local progressBar = tNameplate.wnd.castBar
	
	local bShow = false
	
	if self.tSettings["t" ..tNameplate.unitType].bShowCast or self.tSettings.tTarget.bShowCast and tNameplate.bIsTarget then
		if unitOwner:ShouldShowCastBar() then
			local fDuration = unitOwner:GetCastDuration()
			local fElapsed = unitOwner:GetCastElapsed()	
			local strSpellName = unitOwner:GetCastName()
		
			tNameplate.wnd.castText:SetText(strSpellName)
			progressBar:SetMax(fDuration)
			progressBar:SetProgress(fDuration - fElapsed)
			
			bShow = true
		end
	end
	
	if bShow ~= cast:IsShown() then
		cast:Show(bShow, true)
	end
end

-- update marker
function ForgeUI_Nameplates:UpdateMarker(tNameplate)
	local wnd = tNameplate.wnd

	local bShow = tNameplate.bIsTarget and self.tSettings.tTarget.bShowMarker
	
	if wnd.marker:IsShown() ~= bShow
		then wnd.marker:Show(bShow, true)
	end
end

-- update armor
function ForgeUI_Nameplates:UpdateArmor(tNameplate)
	local unitOwner = tNameplate.unitOwner
	local ia = tNameplate.wnd.ia
	local iaText = tNameplate.wnd.iaText
	
	local bShow = false
	
	nValue = unitOwner:GetInterruptArmorValue()
	nMax = unitOwner:GetInterruptArmorMax()
	if nMax == 0 or nValue == nil or unitOwner:IsDead() then
		
	else
		bShow = true
		if nMax == -1 then
			ia:SetSprite("ForgeUI_IAinf")
			iaText:SetText("")
		elseif nMax > 0 then
			ia:SetSprite("ForgeUI_IA")
			iaText:SetText(nValue)
		end
	end
	
	if bShow ~= ia:IsShown() then
		ia:Show(bShow, true)
	end
end


-- visibility check
function ForgeUI_Nameplates:UpdateNameplateVisibility(tNameplate)
	local unitOwner = tNameplate.unitOwner
	local wndNameplate = tNameplate.wndNameplate
	
	tNameplate.bOnScreen = wndNameplate:IsOnScreen()
	tNameplate.bOccluded = wndNameplate:IsOccluded()
	
	local bVisible = tNameplate.bOnScreen
	if bVisible then bVisible = self.tSettings["t" .. tNameplate.unitType].bShow end
	if bVisible then bVisible = self:IsNameplateInRange(tNameplate) end
	if bVisible and self.tSettings.tFriendly.bOnlyImportantNPCs and tNameplate.unitType == "Friendly" then bVisible = tNameplate.bIsImportant end
	if bVisible and self.tSettings.bUseOcclusion then bVisible = not tNameplate.bOccluded end
	if bVisible then bVisible = not unitOwner:IsDead() end
	
	if not bVisible then bVisible = self.tSettings.tTarget.bShow and tNameplate.bIsTarget end
	
	if bVisible ~= tNameplate.bShow then
		wndNameplate:Show(bVisible, true)
		tNameplate.bShow = bVisible
	end
	
	return bVisible
end

-- update style
function ForgeUI_Nameplates:UpdateStyles()
	for _, tNameplate in pairs(self.tNameplates) do
		self.tStylers["LoadStyle_Nameplate"]["LoadStyle_Nameplate"](self, tNameplate)
		self.tStylers["UpdateStyle_Nameplate"]["UpdateStyle_Nameplate"](self, tNameplate)
	end
end

function ForgeUI_Nameplates:IsNameplateInRange(tNameplate)
	local unitPlayer = self.unitPlayer
	local unitOwner = tNameplate.unitOwner

	if not unitOwner or not unitPlayer then
	    return false
	end

	local tPosTarget = unitOwner:GetPosition()
	local tPosPlayer = unitPlayer:GetPosition()

	if tPosTarget == nil or tPosPlayer == nil then
		return
	end

	local nDeltaX = tPosTarget.x - tPosPlayer.x
	local nDeltaY = tPosTarget.y - tPosPlayer.y
	local nDeltaZ = tPosTarget.z - tPosPlayer.z

	local nDistance = (nDeltaX * nDeltaX) + (nDeltaY * nDeltaY) + (nDeltaZ * nDeltaZ)

	bInRange = nDistance < (self.tSettings.nMaxRange * self.tSettings.nMaxRange) -- squaring for quick maths
	return bInRange
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_Nameplates Nameplate update functions
-----------------------------------------------------------------------------------------------
function ForgeUI_Nameplates:GetUnitType(unit)
	if unit == nil or not unit:IsValid() then return end

	local eDisposition = unit:GetDispositionTo(self.unitPlayer)
	
	if unit:IsThePlayer() then
		return "Player"
	elseif unit:GetType() == "Player" then
		if eDisposition == 0 then
			return "HostilePlayer"
		else
			if unit:IsInYourGroup() then
				return "PartyPlayer"
			else
				return "FriendlyPlayer"
			end
		end
	elseif unit:GetType() == "Collectible" then
		return "Collectible"
	elseif unit:GetType() == "PinataLoot" then
		return "PinataLoot"
	elseif unit:GetType() == "Pet" then
		local petOwner = unit:GetUnitOwner()
	
		if eDisposition == 0 then
			return "HostilePet"
		elseif petOwner ~= nil and petOwner:IsThePlayer() then
			return "PlayerPet"
		else
			return "FriendlyPet"
		end
	elseif unit:GetType() == "Mount" then
		return "Mount"
	elseif unit:GetType() == "Pickup" then
		if string.match(unit:GetName(), self.unitPlayer:GetName()) then
			return "Pickup"
		end
		return "PickupNotPlayer"
	elseif unit:GetHealth() == nil and not unit:IsDead() then
		return "Simple"
	else
		return tDispositionId[eDisposition]
	end
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_Nameplates Unit functions
-----------------------------------------------------------------------------------------------
function ForgeUI_Nameplates:AddNewUnits()
	for idx, unit in _pairs(self.tUnitsInQueue) do
		if unit == nil 
			or not unit:IsValid() 
			or self.tUnits[idx] ~= nil
		then
			self.tUnitsInQueue[idx] = nil
			return
		end
		
		self.tUnitsInQueue[idx] = nil
		
		self.tUnits[idx] = unit
		self:GenerateNewNameplate(unit)
	end
end

function ForgeUI_Nameplates:GenerateNewNameplate(unitNew)
	local wnd = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Nameplate", "InWorldHudStratum", self)
	
	wnd:SetUnit(unitNew, 1)
	
	local tNameplate = {
		unitOwner 		= unitNew,
		idUnit 			= idUnit,
		unitClassID 	= unitNew:IsACharacter() and unitNew:GetClassId() or unitNew:GetRank(),
		unitType 		= self:GetUnitType(unitNew),
		bIsPlayer		= unitNew:IsACharacter(),
		eDisposition	= unitNew:GetDispositionTo(self.unitPlayer),
		bIsImportant	= self:IsImportantNPC(unitNew),
		
		wndNameplate	= tmpWnd,
		wndMeasure		= nil,
		bOnScreen 		= wnd:IsOnScreen(),
		bOccluded 		= wnd:IsOccluded(),
		bIsTarget 		= false,
		bGibbed			= false,
		nVulnerableTime = 0,
		
		bShow			= false,
		bNeedUpdate		= false,
		
		wndNameplate 	= wnd,
		wnd = {
			name = wnd:FindChild("Name"),
			guild = wnd:FindChild("Guild"),
			bar = wnd:FindChild("Bar"),
			hp = wnd:FindChild("HPBar"),
			hpBar = wnd:FindChild("HPBar"):FindChild("ProgressBar"),
			absorbBar = wnd:FindChild("AbsorbBar"),
			shield = wnd:FindChild("ShieldBar"),
			shieldBar = wnd:FindChild("ShieldBar"):FindChild("ProgressBar"),
			cast = wnd:FindChild("CastBar"),
			castBar = wnd:FindChild("CastBar"):FindChild("ProgressBar"),
			castText = wnd:FindChild("CastBar"):FindChild("Text"),
			marker = wnd:FindChild("Marker"),
			ia = wnd:FindChild("IA"),
			iaText = wnd:FindChild("IAText"),
			quest = wnd:FindChild("QuestIndicator"),
			challange = wnd:FindChild("ChallangeIndicator"),
			info = wnd:FindChild("Info"),
			info_icon = wnd:FindChild("Info"):FindChild("Icon"),
			info_level = wnd:FindChild("Info"):FindChild("Level"),
			cleanse = wnd:FindChild("Cleanse")
		}
	}
	
	if self.tSettings["t" .. tNameplate.unitType] == nil then
		tNameplate.unitType = "Unknown"
		Print("Please report this text to any ForgeUI page: Unknow unitType - " .. unitNew:GetName())
	end

	self.tStylers["LoadStyle_Nameplate"]["LoadStyle_Nameplate"](self, tNameplate)
	self.tStylers["UpdateStyle_Nameplate"]["UpdateStyle_Nameplate"](self, tNameplate)
	
	self:UpdateNameplate(tNameplate)
	
	self.tNameplates[unitNew:GetId()] = tNameplate
	
	return tNameplate
end

function ForgeUI_Nameplates:IsImportantNPC(unitOwner)
	local tActivation = unitOwner:GetActivationState()
	
	--Units without health
	if tActivation.Bank ~= nil then
		return true
	elseif tActivation.CREDDExchange then
		return true
	end

	--Flight paths
	if tActivation.FlightPathSettler ~= nil or tActivation.FlightPath ~= nil or tActivation.FlightPathNew then
		return true
	end
	
	--Quests
	if tActivation.QuestReward ~= nil then
		return true
	elseif tActivation.QuestNew ~= nil or tActivation.QuestNewMain ~= nil then
		return true
	elseif tActivation.QuestReceiving ~= nil then
		return true
	elseif tActivation.QuestNewDaily ~= nil then
		return true
	elseif tActivation.TalkTo ~= nil then
		return true
	end
	
	--Vendors
	if tActivation.CommodityMarketplace ~= nil then
		return true
	elseif tActivation.ItemAuctionhouse then
		return true
	elseif tActivation.Vendor then
		return true
	end
	
	--Trainers
	if tActivation.TradeskillTrainer then
		return true
	end
end

function ForgeUI_Nameplates:OnNameplateClick( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if wndControl:GetName() == "Bar" or wndControl:GetName() == "Name" or wndControl:GetName() == "Guild" then
		GameLib.SetTargetUnit(wndControl:GetParent():GetUnit())
	elseif wndControl:GetName() == "HPBar" or wndControl:GetName() == "ShieldBar" then
		GameLib.SetTargetUnit(wndControl:GetParent():GetParent():GetUnit())
	end
end

-----------------------------------------------------------------------------------------------
-- Settings
-----------------------------------------------------------------------------------------------

function ForgeUI_Nameplates:ForgeAPI_AfterRestore()
	for key, keyValue in pairs(self.tSettings) do
		local type  = string.sub(key, 2, string.len(key))
		
		if string.sub(key, 1, 1) ~= "t" then
			if string.sub(key, 1, 2) == "cr" then
				if self.wndContainers["Container_General"]:FindChild(tostring(key)) ~= nil then
					ForgeUI.API_RegisterColorBox(self, self.wndContainers["Container_General"]:FindChild(tostring(key)), self.tSettings, tostring(key), false, "UpdateStyles")
				end
			end
			if string.sub(key, 1, 1) == "b" then
				if self.wndContainers["Container_General"]:FindChild(tostring(key)) ~= nil then
					ForgeUI.API_RegisterCheckBox(self, self.wndContainers["Container_General"]:FindChild(tostring(key)), self.tSettings, tostring(key), "UpdateStyles")
				end
			end
			if string.sub(key, 1, 1) == "n" then
				if self.wndContainers["Container_General"]:FindChild(tostring(key)) ~= nil then
					ForgeUI.RegisterNumberBox(self, self.wndContainers["Container_General"]:FindChild(tostring(key)), self.tSettings, tostring(key), {}, "UpdateStyles")
				end
			end
		else
			for option, optionValue in pairs(keyValue) do
				if self.wndContainers["Container_" .. type] ~= nil then
					if string.sub(option, 1, 2) == "cr" then
						if self.wndContainers["Container_" .. type]:FindChild(tostring(option)) ~= nil then
							ForgeUI.API_RegisterColorBox(self, self.wndContainers["Container_" .. type]:FindChild(tostring(option)), self.tSettings[key], tostring(option), false, "UpdateStyles")
						end
					end
					if string.sub(option, 1, 1) == "b" then
						if self.wndContainers["Container_" .. type]:FindChild(tostring(option)) ~= nil then
							ForgeUI.API_RegisterCheckBox(self, self.wndContainers["Container_" .. type]:FindChild(tostring(option)), self.tSettings[key], tostring(option), "UpdateStyles")
						end
					end
					if string.sub(option, 1, 1) == "n" then
						if self.wndContainers["Container_" .. type]:FindChild(tostring(option)) ~= nil then
							ForgeUI.RegisterNumberBox(self, self.wndContainers["Container_" .. type]:FindChild(tostring(option)), self.tSettings[key], tostring(option), {}, "UpdateStyles")
						end
					end
				end
			end
		end
	end
end

-----------------------------------------------------------------------------------------------
-- Styles
-----------------------------------------------------------------------------------------------

function ForgeUI_Nameplates:LoadStyle_Nameplate(tNameplate)
	local wnd = tNameplate.wnd

	if tNameplate.bIsPlayer then
		tNameplate.wnd.info_icon:SetSprite("ForgeUI_" .. tClassEnums[tNameplate.unitClassID] .. "_s")
	elseif tNameplate.unitClassID ~= 6 and tNameplate.unitClassID >= 4 then
		tNameplate.wnd.info_icon:SetSprite("ForgeUI_npc_rank_" .. tNpcRankEnums[tNameplate.unitClassID] .. "_s")
	else
		tNameplate.wnd.info_level:SetAnchorOffsets(0, 0, -3, 0)
	end
	
	wnd.hp:FindChild("Background"):SetBGColor(self.tSettings.crBgBar)
	wnd.shield:FindChild("Background"):SetBGColor(self.tSettings.crBgBar)
	wnd.shieldBar:SetBarColor(self.tSettings.crShieldBar)
	wnd.absorbBar:SetBarColor(self.tSettings.crAbsorbBar)
	wnd.castBar:SetBarColor(self.tSettings.crCastBar)
	wnd.cast:FindChild("Background"):SetBGColor(self.tSettings.crBgBar)
	wnd.marker:SetBGColor(self.tSettings.tTarget.crMarker) 
	
	tNameplate.wndNameplate:SetAnchorOffsets(-(self.tSettings.nBarWidth /2), -30, (self.tSettings.nBarWidth / 2), 0)
	
	if self.tSettings.bClickable then
		wnd.bar:AddEventHandler("MouseButtonDown", "OnNameplateClick", self)
		wnd.name:AddEventHandler("MouseButtonDown", "OnNameplateClick", self)
		wnd.guild:AddEventHandler("MouseButtonDown", "OnNameplateClick", self)
	else
		wnd.bar:RemoveEventHandler("MouseButtonDown", "OnNameplateClick", self)
		wnd.name:RemoveEventHandler("MouseButtonDown", "OnNameplateClick", self)
		wnd.guild:RemoveEventHandler("MouseButtonDown", "OnNameplateClick", self)
	end
	
	wnd.bar:SetStyle("IgnoreMouse", not self.tSettings.bClickable)
	wnd.name:SetStyle("IgnoreMouse", not self.tSettings.bClickable)
	wnd.guild:SetStyle("IgnoreMouse", not self.tSettings.bClickable)
end

function ForgeUI_Nameplates:UpdateStyle_Nameplate(tNameplate)
	local wnd = tNameplate.wnd

	local nLeft, nTop, nRight, nBottom = wnd.bar:GetAnchorOffsets()
	if wnd.shield:IsShown() then
		wnd.bar:SetAnchorOffsets(nLeft, nTop, nRight, nTop + self.tSettings.nHpBarHeight + self.tSettings.nShieldBarHeight - 1)
		wnd.hp:SetAnchorOffsets(0, 0, 0, self.tSettings.nHpBarHeight)
		wnd.shield:SetAnchorOffsets(0, - self.tSettings.nShieldBarHeight, 0, 0)
	else
		wnd.bar:SetAnchorOffsets(nLeft, nTop, nRight, nTop + self.tSettings.nHpBarHeight)
		wnd.hp:SetAnchorOffsets(0, 0, 0, self.tSettings.nHpBarHeight)
	end
	
	if wnd.guild:IsShown() then
		nLeft, nTop, nRight, nBottom = wnd.name:GetAnchorOffsets()
		wnd.name:SetAnchorOffsets(nLeft, -12, nRight, -30)
	else
		nLeft, nTop, nRight, nBottom = wnd.name:GetAnchorOffsets()
		wnd.name:SetAnchorOffsets(nLeft, 0, nRight, -12)
	end
end

function ForgeUI_Nameplates:RefreshStyle_Nameplate(tNameplate)
	
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_Nameplates Instance
-----------------------------------------------------------------------------------------------
local ForgeUI_NameplatesInst = ForgeUI_Nameplates:new()
ForgeUI_NameplatesInst:Init()
