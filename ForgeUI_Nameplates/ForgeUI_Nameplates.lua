-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		ForgeUI_Nameplates.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI Nameplates addon
-----------------------------------------------------------------------------------------------

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeUI GUI library

local Util = F:API_GetModule("util")

require "Window"

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
krtClassEnums = {
	[GameLib.CodeEnumClass.Warrior]      	= "Warrior",
	[GameLib.CodeEnumClass.Engineer]     	= "Engineer",
	[GameLib.CodeEnumClass.Esper]        	= "Esper",
	[GameLib.CodeEnumClass.Medic]        	= "Medic",
	[GameLib.CodeEnumClass.Stalker]      	= "Stalker",
	[GameLib.CodeEnumClass.Spellslinger]	= "Spellslinger"
}

krtNpcRankEnums = {
	[Unit.CodeEnumRank.Elite] 		= "elite",
	[Unit.CodeEnumRank.Superior] 	= "superior",
	[Unit.CodeEnumRank.Champion] 	= "champion",
	[Unit.CodeEnumRank.Standard] 	= "standard",
	[Unit.CodeEnumRank.Minion] 		= "minion",
	[Unit.CodeEnumRank.Fodder] 		= "fodder",
}

tNameSwaps = {
	["Briex Sper"] = "Pink Cheese",
}

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
local fnUpdateNameplate
local fnUpdateNameplateVisibility

local fnDrawName
local fnDrawGuild
local fnDrawHealth
local fnDrawIA
local fnDrawShield
local fnDrawAbsorb

local fnDrawRewards
local fnDrawCastBar
local fnDrawIndicators
local fnDrawInfo

local fnColorNameplate

local fnRepositionNameplate

local ForgeUI_Nameplates = {
	_NAME = "ForgeUI_Nameplates",
	_API_VERSION = 3,
	_VERSION = "3.0",
	DISPLAY_NAME = "Nameplates",

	tPreloadUnits = {},

	arWindowPool = {},
	arUnit2Nameplate = {},
	arWnd2Nameplate = {},

	tSettings = {
		profile = {
			nMaxRange = 75,
			bUseOcclusion = true,
			bShowTitles = false,
			bOnlyImportantNPC = true,
			bShowObjectives = true,
			bShowShield = true,
			bShowAbsorb = true,
			bFrequentUpdate = false,
			bShowDead = true,
			bClickable = true,
			bMOOBar = true,
			bMOODuration = true,
			bCombatStatePlayer = false,
			bShortNames = false,
			crShield = "FF0699F3",
			crAbsorb = "FFFFC600",
			crDead = "FF666666",
			crHealthbarMOO = "FF7E00FF",
			crCastbarNormal = "FFFEB308",
			crCastbarMOO = "FFBC00BB",
			tStyle = {
				nStyle = 0,
				nBarWidth = 120,
				nBarHeight = 20,
				nBarOffset = 80,
				nShieldHeight = 8,
				nAbsorbHeight = 8,
				nCastHeight = 7,
				nCastOffsetY = 7,
				nCastTextOffsetY = 7,
				bCastTextCenter = false,
				strFullSprite = "ForgeUI_Smooth",
				strIASprite = "ForgeUI_shield"
			},
			tUnits = {
				Target = {
					bShowMarker = true,
					crTargetMarker = "FFFFFFFF",
					nShowName = 3,
					nShowBars = 3,
					nShowCast = 3,
					nShowInfo = 0,
				},
				Player = {
					bEnabled = true,
					bHideOnHealth = false,
					bHideOnShield = false,
					nShowName = 0,
					nShowBars = 0,
					nShowCast = 0,
					nShowGuild = 0,
					nShowInfo = 0,
					nHpCutoff = 0,
					crHpCutoff = "FFCCCCCC",
					crName = "FFFFFFFF",
					crHealth = "FF75CC26",
					bClassColors = false,
					bShowHpValue = false,
					bShowShieldValue = false,
				},
				FriendlyPlayer = {
					bEnabled = true,
					bHideOnHealth = false,
					bHideOnShield = false,
					bCleanseIndicator = false,
					crCleanseIndicator = "FFA100FE",
					nShowName = 3,
					nShowBars = 3,
					nShowCast = 0,
					nShowGuild = 0,
					nShowInfo = 0,
					nHpCutoff = 0,
					crHpCutoff = "FFCCCCCC",
					crName = "FFFFFFFF",
					crHealth = "FF75CC26",
					bClassColors = true,
					bShowHpValue = false,
					bShowShieldValue = false,
				},
				PartyPlayer = {
					bEnabled = true,
					bHideOnHealth = false,
					bHideOnShield = false,
					bCleanseIndicator = false,
					crCleanseIndicator = "FFA100FE",
					nShowName = 3,
					nShowBars = 3,
					nShowCast = 0,
					nShowGuild = 0,
					nShowInfo = 0,
					nHpCutoff = 0,
					crHpCutoff = "FFCCCCCC",
					crName = "FF43C8F3",
					crHealth = "FF75CC26",
					bClassColors = true,
					bShowHpValue = false,
					bShowShieldValue = false,
				},
				HostilePlayer = {
					bEnabled = true,
					nShowName = 3,
					nShowBars = 3,
					nShowCast = 3,
					nShowGuild = 0,
					nShowInfo = 0,
					nHpCutoff = 0,
					crHpCutoff = "FFCCCCCC",
					crName = "FFFF0000",
					crNameNoPvP = "FFFF9900",
					crHealth = "FFFF0000",
					bHideBarsNoPvP = true,
					bHideCastNoPvP = true,
					bClassColors = true,
					bShowHpValue = false,
					bShowShieldValue = false,
				},
				FriendlyNPC = {
					bEnabled = true,
					nShowName = 3,
					nShowBars = 2,
					nShowCast = 2,
					nShowGuild = 3,
					nShowInfo = 0,
					crName = "FF76CD26",
					crHealth = "FF75CC26",
					bShowHpValue = false,
					bShowShieldValue = false,
				},
				NeutralNPC = {
					bEnabled = true,
					nShowName = 3,
					nShowBars = 2,
					nShowCast = 2,
					nShowGuild = 0,
					nShowInfo = 1,
					crName = "FFFFF569",
					crHealth = "FFF3D829",
					bShowHpValue = false,
					bShowShieldValue = false,
				},
				HostileNPC = {
					bEnabled = true,
					bThreatIndicator = false,
					bReposition = false,
					crThreatIndicator = "FFFF9900",
					nShowName = 3,
					nShowBars = 2,
					nShowCast = 2,
					nShowGuild = 0,
					nShowInfo = 1,
					nHpCutoff = 0,
					crHpCutoff = "FFCCCCCC",
					crName = "FFD9544D",
					crHealth = "FFE50000",
					bShowHpValue = false,
					bShowShieldValue = false,
				},
				UnknownNPC = {
					bEnabled = true,
					nShowName = 3,
					nShowBars = 3,
					crName = "FF333333",
					crHealth = "FF333333",
				},
				FriendlyPet = {
					bEnabled = false,
					nShowName = 0,
					nShowBars = 0,
				},
				PlayerPet = {
					bEnabled = true,
					nShowName = 0,
					nShowBars = 0,
					crName = "FFFFFFFF",
					crHealth = "FFFFFFFF"
				},
				HostilePet = {
					bEnabled = false,
					nShowName = 0,
					nShowBars = 0,
				},
				Simple = {
					bEnabled = false,
					nShowName = 0,
					crName = "FFFFFFFF"
				},
				Pickup = {
					bEnabled = true,
					nShowName = 3,
					crName = "FFFFFFFF"
				},
				PickupNotPlayer = {
					bEnabled = false,
					nShowName = 0,
					crName = "FFFFFFFF"
				},
				Collectible = {
					bEnabled = false,
					nShowName = 0,
					crName = "FFFFFFFF"
				},
				PinataLoot = {
					bEnabled = false,
					nShowName = 0,
					crName = "FFFFFFFF"
				},
				Mount = {
					bEnabled = false,
					nShowName = 0,
					crName = "FFFFFFFF"
				},
				Scanner = {
					bEnabled = false,
					nShowName = 0,
					nShowBars = 0,
				},

			},
			knNameplatePoolLimit = 500,
			knTargetRange = 16000,
		},
	},
}

-----------------------------------------------------------------------------------------------
-- ForgeUI_Nameplates OnLoad
-----------------------------------------------------------------------------------------------
function ForgeUI_Nameplates:ForgeAPI_PreInit()
	Apollo.RegisterEventHandler("UnitCreated", "OnPreloadUnitCreated", self)
end

function ForgeUI_Nameplates:ForgeAPI_Init()
	self.xmlNameplate = XmlDoc.CreateFromFile("..//ForgeUI_Nameplates//ForgeUI_Nameplates.xml")
	self.xmlNameplate:RegisterCallback("OptionsInit", self)

	local wndParent = F:API_AddMenuItem(self, self.DISPLAY_NAME, "General")
	F:API_AddMenuToMenuItem(self, wndParent, "Style", "Style")
	F:API_AddMenuToMenuItem(self, wndParent, "Target", "Target")
	F:API_AddMenuToMenuItem(self, wndParent, "Player", "Player")
	F:API_AddMenuToMenuItem(self, wndParent, "Party player", "PartyPlayer")
	F:API_AddMenuToMenuItem(self, wndParent, "Friendly player", "FriendlyPlayer")
	F:API_AddMenuToMenuItem(self, wndParent, "Hostile player", "HostilePlayer")
	F:API_AddMenuToMenuItem(self, wndParent, "Friendly NPC", "FriendlyNPC")
	F:API_AddMenuToMenuItem(self, wndParent, "Neutral NPC", "NeutralNPC")
	F:API_AddMenuToMenuItem(self, wndParent, "Hostile NPC", "HostileNPC")

	self:NameplatesInit()
end

function ForgeUI_Nameplates:NameplatesInit()
	Apollo.RegisterEventHandler("VarChange_FrameCount", 		"OnFrame", self)

	Apollo.RegisterEventHandler("TargetUnitChanged", 			"OnTargetUnitChanged", self)
	Apollo.RegisterEventHandler("UnitEnteredCombat", 			"OnEnteredCombat", self)
	Apollo.RegisterEventHandler("UnitNameChanged", 				"OnUnitNameChanged", self)
	Apollo.RegisterEventHandler("UnitTitleChanged", 			"OnUnitTitleChanged", self)
	Apollo.RegisterEventHandler("PlayerTitleChange", 			"OnPlayerTitleChanged", self)
	Apollo.RegisterEventHandler("UnitGuildNameplateChanged", 	"OnUnitGuildNameplateChanged",self)
	Apollo.RegisterEventHandler("UnitMemberOfGuildChange", 		"OnUnitMemberOfGuildChange", self)
	Apollo.RegisterEventHandler("GuildChange", 					"OnGuildChange", self)
	Apollo.RegisterEventHandler("UnitGibbed",					"OnUnitGibbed", self)

	Apollo.RegisterEventHandler("StartSpellThreshold", 	"OnStartSpellThreshold", self)
	Apollo.RegisterEventHandler("ClearSpellThreshold", 	"OnClearSpellThreshold", self)
	Apollo.RegisterEventHandler("UpdateSpellThreshold", "OnUpdateSpellThreshold", self)

	self.bRedrawRewardIcons = true
	local tRewardUpdateEvents = {
		"QuestObjectiveUpdated", "QuestStateChanged", "ChallengeAbandon", "ChallengeLeftArea",
		"ChallengeFailTime", "ChallengeFailArea", "ChallengeActivate", "ChallengeCompleted",
		"ChallengeFailGeneric", "PublicEventObjectiveUpdate", "PublicEventUnitUpdate",
		"PlayerPathMissionUpdate", "FriendshipAdd", "FriendshipPostRemove", "FriendshipUpdate",
		"PlayerPathRefresh", "ContractObjectiveUpdated", "ContractStateChanged", "ChallengeUpdated"
	}

	for i, str in pairs(tRewardUpdateEvents) do
		Apollo.RegisterEventHandler(str, "RequestUpdateAllNameplateRewards", self)
	end

	Apollo.RegisterTimerHandler("HalfSecTimer", "OnHalfSecTimer", self)
	Apollo.CreateTimer("HalfSecTimer", 0.5, true)

	self.arUnit2Nameplate = {}
	self.arWnd2Nameplate = {}

	self:CreateUnitsFromPreload()
end

function ForgeUI_Nameplates:ForgeAPI_LoadSettings()
	for idx, tNameplate in pairs(self.arUnit2Nameplate) do
		tNameplate.tSettings = self._DB.profile.tUnits[tNameplate.strUnitType]
	end

	self:UpdateAllNameplates()
	self:LoadStyle_Nameplates()

	Apollo.SetConsoleVariable("ui.occludeNameplatePositions", self._DB.profile.bUseOcclusion)
end

function ForgeUI_Nameplates:UpdateAllNameplates()
	self:UpdateAllNameplateVisibility()
	self:RequestUpdateAllNameplateRewards()

	for idx, tNameplate in pairs(self.arUnit2Nameplate) do
		fnUpdateNameplate(self, tNameplate)
	end
end

function ForgeUI_Nameplates:UpdateNameplate(tNameplate)
	fnDrawIndicators(self, tNameplate)
	fnDrawName(self, tNameplate)
	fnDrawGuild(self, tNameplate)
	fnDrawInfo(self, tNameplate)
	fnDrawHealth(self, tNameplate)
	fnDrawCastBar(self, tNameplate)
	fnDrawRewards(self, tNameplate)

	fnColorNameplate(self, tNameplate)
end

function ForgeUI_Nameplates:OnHalfSecTimer()
	self:UpdateAllNameplateVisibility()
end

function ForgeUI_Nameplates:RequestUpdateAllNameplateRewards()
	self.bRedrawRewardIcons = true
end

function ForgeUI_Nameplates:UpdateNameplateRewardInfo(tNameplate)
	local tFlags =
	{
		bVert = false,
		bHideQuests = not self._DB.profile.bShowObjectives,
		bHideChallenges = not self._DB.profile.bShowObjectives,
		bHideMissions = not self._DB.profile.bShowObjectives,
		bHidePublicEvents = not self._DB.profile.bShowObjectives,
		bHideRivals = true,
		bHideFriends = true
	}

	if RewardIcons ~= nil and RewardIcons.GetUnitRewardIconsForm ~= nil then
		RewardIcons.GetUnitRewardIconsForm(tNameplate.wnd.questRewards, tNameplate.unitOwner, tFlags)
	end
end

function ForgeUI_Nameplates:UpdateAllNameplateVisibility()
	for idx, tNameplate in pairs(self.arUnit2Nameplate) do
		fnUpdateNameplateVisibility(self, tNameplate)
		if self.bRedrawRewardIcons then
			self:UpdateNameplateRewardInfo(tNameplate)
		end
	end
	self.bRedrawRewardIcons = false
end

function ForgeUI_Nameplates:UpdateNameplateVisibility(tNameplate)
	local unitOwner = tNameplate.unitOwner
	local wndNameplate = tNameplate.wndNameplate
	local bIsMounted = unitOwner:IsMounted()
	local unitWindow = wndNameplate:GetUnit()

	if bIsMounted and unitWindow == unitOwner then
		if not tNameplate.bMounted then
			wndNameplate:SetUnit(unitOwner:GetUnitMount(), 1)
			tNameplate.bMounted = true
		end
	elseif not bIsMounted and unitWindow ~= unitOwner then
		if tNameplate.bMounted then
			wndNameplate:SetUnit(unitOwner, 1)
			tNameplate.bMounted = false
		end
	end

	local eDisposition = unitOwner:GetDispositionTo(self.unitPlayer)
	if eDisposition ~= tNameplate.eDisposition then
		tNameplate.strUnitType 		= self:GetUnitType(unitOwner)
		tNameplate.eDisposition 	= eDisposition
		tNameplate.bIsImportant		= self:IsImportantNPC(unitOwner)
		tNameplate.tSettings 		= self._DB.profile.tUnits[tNameplate.strUnitType]

		self:UpdateNameplate(tNameplate)
	end

	tNameplate.bOnScreen = wndNameplate:IsOnScreen()
	tNameplate.bOccluded = wndNameplate:IsOccluded()

	local bNewShow = self:HelperVerifyVisibilityOptions(tNameplate) and self:CheckDrawDistance(tNameplate)

	tNameplate.eDisposition = eDisposition

	if bNewShow and not self._DB.profile.bFrequentUpdate then
		fnDrawNameplate(self, tNameplate)
	end

	if bNewShow ~= tNameplate.bShow then
		tNameplate.bShow = bNewShow
		wndNameplate:Show(bNewShow, not bNewShow) -- removes weird glitching when occluding nameplates
	end
end

function ForgeUI_Nameplates:OnUnitCreated(unitNew) -- build main options here
	local strNewUnitType = self:GetUnitType(unitNew)

	if not self._DB.profile.tUnits[strNewUnitType].bEnabled then return end

	local idUnit = unitNew:GetId()
	if self.arUnit2Nameplate[idUnit] ~= nil and self.arUnit2Nameplate[idUnit].wndNameplate:IsValid() then
		return
	end

	local wnd = nil
	local wndReferences = nil
	if next(self.arWindowPool) ~= nil then
		local poolEntry = table.remove(self.arWindowPool)
		wnd = poolEntry[1]
		wndReferences = poolEntry[2]
	end

	if wnd == nil or not wnd:IsValid() then
		wnd = Apollo.LoadForm(self.xmlNameplate, "Nameplate", "InWorldHudStratum", self)
		wndReferences = nil
	end

	wnd:SetUnit(unitNew, 1)

	local tNameplate =
	{
		unitOwner 		= unitNew,
		idUnit 			= idUnit,
		wndNameplate	= wnd,
		strUnitType		= strNewUnitType,
		unitClassID 	= unitNew:IsACharacter() and unitNew:GetClassId() or unitNew:GetRank(),
		tSettings 		= self._DB.profile.tUnits[strNewUnitType],

		bOnScreen 		= wnd:IsOnScreen(),
		bOccluded 		= wnd:IsOccluded(),
		bIsImportant	= self:IsImportantNPC(unitNew),

		bIsTarget 		= GameLib.GetTargetUnit() == unitNew,
		bIsCasting 		= false,
		bIsMounted		= false,

		nVulnerableTime = 0,
		eDisposition	= unitNew:GetDispositionTo(self.unitPlayer),
		tActivation		= unitNew:GetActivationState(),

		bShow			= false,
		wnd				= wndReferences,
	}

	if wndReferences == nil then
		tNameplate.wnd = {
			health = wnd:FindChild("Container:Health"),
			castBar = wnd:FindChild("Container:CastBar"),
			level = wnd:FindChild("Level"),
			wndGuild = wnd:FindChild("Guild"),
			wndName = wnd:FindChild("NameRewardContainer:Name"),

			nameRewardContainer = wnd:FindChild("NameRewardContainer:Name:RewardContainer"),
			healthMaxShield = wnd:FindChild("Container:Health:HealthBars:MaxShield"),
			healthShieldFill = wnd:FindChild("Container:Health:HealthBars:MaxShield:ShieldFill"),
			healthMaxAbsorb = wnd:FindChild("Container:Health:HealthBars:MaxAbsorb"),
			healthAbsorbFill = wnd:FindChild("Container:Health:HealthBars:MaxAbsorb:AbsorbFill"),
			healthMaxHealth = wnd:FindChild("Container:Health:HealthBars:MaxHealth"),
			healthHealthFill = wnd:FindChild("Container:Health:HealthBars:MaxHealth:HealthFill"),
			healthHealthLabel = wnd:FindChild("Container:Health:HealthLabel"),
			ia = wnd:FindChild("Container:Health:IA"),
			hpText = wnd:FindChild("HpValue"),
			shieldText = wnd:FindChild("ShieldValue"),

			castBarLabel = wnd:FindChild("Container:CastBar:Label"),
			castBarCastFill = wnd:FindChild("Container:CastBar:CastFill"),
			questRewards = wnd:FindChild("NameRewardContainer:Name:RewardContainer:QuestRewards"),
			targetMarker = wnd:FindChild("Container:Health:TargetMarker"),
			indicator = wnd:FindChild("Container:Health:Indicator"),
			info = wnd:FindChild("NameRewardContainer:Name:Info"),
			info_level = wnd:FindChild("NameRewardContainer:Name:Info:Level"),
			info_class = wnd:FindChild("NameRewardContainer:Name:Info:Class"),
		}
	end

	self.arUnit2Nameplate[idUnit] = tNameplate
	self.arWnd2Nameplate[wnd:GetId()] = tNameplate

	self:UpdateNameplateRewardInfo(tNameplate)

	self:DrawName(tNameplate)
	self:DrawGuild(tNameplate)
	self:DrawHealth(tNameplate)
	self:DrawIndicators(tNameplate)
	self:DrawRewards(tNameplate)
	self:DrawInfo(tNameplate)

	self:UpdateInfo(tNameplate)
	self:UpdateNameplateRewardInfo(tNameplate)

	self:LoadStyle_Nameplate(tNameplate)
end

function ForgeUI_Nameplates:OnPreloadUnitCreated(unitNew)
	self.tPreloadUnits[#self.tPreloadUnits + 1] = unitNew
end

function ForgeUI_Nameplates:CreateUnitsFromPreload()
	self.unitPlayer = GameLib.GetPlayerUnit()

	-- Process units created while form was loading
	self.timerPreloadUnitCreateDelay = ApolloTimer.Create(0.5, true, "OnPreloadUnitCreateTimer", self)
	self:OnPreloadUnitCreateTimer()
end

function ForgeUI_Nameplates:OnPreloadUnitCreateTimer()
	if self.unitPlayer then
		Apollo.RemoveEventHandler("UnitCreated", self)

		Apollo.RegisterEventHandler("UnitCreated",					"OnUnitCreated", self)
		Apollo.RegisterEventHandler("UnitDestroyed", 				"OnUnitDestroyed", self)

		local nCurrentTime = GameLib.GetTickCount()

		while #self.tPreloadUnits > 0 do
			local unit = table.remove(self.tPreloadUnits, #self.tPreloadUnits)
			if unit:IsValid() then
				self:OnUnitCreated(unit)
			end

			if GameLib.GetTickCount() - nCurrentTime > 250 then
				return
			end
		end

		if self.timerPreloadUnitCreateDelay then
			self.timerPreloadUnitCreateDelay:Stop()
		end
		self.arPreloadUnits = nil
		self.timerPreloadUnitCreateDelay = nil
	end
end

function ForgeUI_Nameplates:OnUnitDestroyed(unitOwner)
	local idUnit = unitOwner:GetId()
	if self.arUnit2Nameplate[idUnit] == nil then
		return
	end

	local tNameplate = self.arUnit2Nameplate[idUnit]
	local wndNameplate = tNameplate.wndNameplate

	self.arWnd2Nameplate[wndNameplate:GetId()] = nil
	if #self.arWindowPool < self._DB.profile.knNameplatePoolLimit then
		wndNameplate:Show(false, true)
		wndNameplate:SetUnit(nil)

		table.insert(self.arWindowPool, {wndNameplate, tNameplate.wnd })
	else
		wndNameplate:Destroy()
		tNameplate.wnd = nil
		tNameplate = nil
	end
	self.arUnit2Nameplate[idUnit] = nil
end

-----------------------------------------------------------------------------------------------
-- Drawing functions
-----------------------------------------------------------------------------------------------

function ForgeUI_Nameplates:OnFrame()
	self.unitPlayer = GameLib.GetPlayerUnit()

	for idx, tNameplate in pairs(self.arUnit2Nameplate) do
		if tNameplate.bShow then
			fnDrawCastBar(self, tNameplate)
			fnRepositionNameplate(self, tNameplate)

			if self._DB.profile.bFrequentUpdate then
				fnDrawNameplate(self, tNameplate)
			end
		end
	end
end

function ForgeUI_Nameplates:DrawNameplate(tNameplate)
	fnColorNameplate(self, tNameplate)

	fnDrawName(self, tNameplate)
	fnDrawGuild(self, tNameplate)
	fnDrawHealth(self, tNameplate)

	fnDrawRewards(self, tNameplate)
end

function ForgeUI_Nameplates:ColorNameplate(tNameplate) -- Every frame
	local unitOwner = tNameplate.unitOwner
	local wndNameplate = tNameplate.wndNameplate
	local tSettings = tNameplate.tSettings

	local crNameColors = tSettings.crName
	local crBarColor = tSettings.crHealth

	if tNameplate.strUnitType == "HostilePlayer" and not unitOwner:IsPvpFlagged() then
		crNameColors = tSettings.crNameNoPvP
	end

	if unitOwner:IsDead() then
		crNameColors = self._DB.profile.crDead
	end

	if tSettings.bClassColors then
		crBarColor = F:API_GetClassColor(unitOwner)
	end

	if tSettings.nHpCutoff and tNameplate.hpPercentage and tNameplate.hpPercentage < tSettings.nHpCutoff then
		crBarColor = tSettings.crHpCutoff
	end

	if self._DB.profile.bMOOBar then
		if unitOwner:IsInCCState(Unit.CodeEnumCCState.Vulnerability) then
			crBarColor = self._DB.profile.crHealthbarMOO
		end
	end

	tNameplate.wnd.wndName:SetTextColor(crNameColors)
	tNameplate.wnd.wndGuild:SetTextColor(crNameColors)
	tNameplate.wnd.healthHealthFill:SetBarColor(crBarColor)
end

function ForgeUI_Nameplates:HelperGetName(tNameplate)
	local unitOwner = tNameplate.unitOwner
	local nameIterator = unitOwner:GetName():gmatch("[^ ]+")
	local strNameFirst = nameIterator() or ""
	local strNameSecond = nameIterator() or ""

	local strNewName = ""
	if self._DB.profile.bShowTitles then
		strNewName = unitOwner:GetTitleOrName()
	else
		strNewName = unitOwner:GetName()
	end

	if tNameSwaps[unitOwner:GetName()] then
		strNewName = tNameSwaps[unitOwner:GetName()]
	elseif self._DB.profile.bShortNames then
		strNewName = strNewName:gsub(" "..strNameSecond, "")
	end

	return strNewName
end

function ForgeUI_Nameplates:DrawName(tNameplate)
	local wndNameplate = tNameplate.wndNameplate
	local unitOwner = tNameplate.unitOwner
	local wndName = tNameplate.wnd.wndName

	local bShow = self:GetBooleanOption("nShowName", tNameplate)
	if wndName:IsShown() ~= bShow then
		wndName:Show(bShow, true)
	end

	if bShow then
		local strNewName = self:HelperGetName(tNameplate)

		if tNameplate.strName ~= strNewName then
			tNameplate.strName = strNewName

			wndName:SetText(strNewName)

			local nNameWidth = Apollo.GetTextWidth("Nameplates", strNewName .. " ")
			local nLeft, nTop, nRight, nBottom = wndName:GetAnchorOffsets()
			wndName:SetAnchorOffsets(- (nNameWidth / 2), nTop, (nNameWidth / 2), nBottom)
		end
	end
end

function ForgeUI_Nameplates:DrawGuild(tNameplate)
	local wndNameplate = tNameplate.wndNameplate
	local unitOwner = tNameplate.unitOwner

	local wndGuild = tNameplate.wnd.wndGuild
	local bShow = self:GetBooleanOption("nShowGuild", tNameplate)

	if bShow then
		local strNewGuild = unitOwner:GetAffiliationName()
		if tNameplate.strAffiliationName ~= strNewGuild then
			tNameplate.strAffiliationName = strNewGuild

			if unitOwner:GetType() == "Player" and strNewGuild ~= nil and strNewGuild ~= "" then
				strNewGuild = String_GetWeaselString(Apollo.GetString("Nameplates_GuildDisplay"), strNewGuild)
			end

			wndGuild:SetTextRaw(strNewGuild)

			local nNameWidth = Apollo.GetTextWidth("Nameplates", strNewGuild .. " ")
			local nLeft, nTop, nRight, nBottom = wndGuild:GetAnchorOffsets()
			wndGuild:SetAnchorOffsets(- (nNameWidth / 2), nTop, (nNameWidth / 2), nBottom)
		end

		bShow = bShow and strNewGuild ~= nil and strNewGuild ~= ""
	end

	if bShow ~= wndGuild:IsShown() then
		wndGuild:Show(bShow, true)
		wndNameplate:ArrangeChildrenVert(2)
	end
end

function ForgeUI_Nameplates:DrawHealth(tNameplate)
	local unitOwner = tNameplate.unitOwner

	local nHealth = unitOwner:GetHealth()
	local nMaxHealth = unitOwner:GetMaxHealth()

	local bShow = nHealth ~= nil and not unitOwner:IsDead() and nMaxHealth > 0 and self:GetBooleanOption("nShowBars", tNameplate)

	if (tNameplate.tSettings.bHideOnHealth or tNameplate.tSettings.bHideOnShield) and not tNameplate.bIsTarget then
		local bHealth = nHealth ~= nMaxHealth and tNameplate.tSettings.bHideOnHealth

		local nShield = unitOwner:GetShieldCapacity()
		local nShieldMax = unitOwner:GetShieldCapacityMax()

		local bShield = nShield ~= nShieldMax and tNameplate.tSettings.bHideOnShield

		bShow = bHealth or bShield
	end

	-- hide health bar for non flagged hostile players
	if tNameplate.tSettings.bHideBarsNoPvP and tNameplate.strUnitType == "HostilePlayer" and not unitOwner:IsPvpFlagged() and not tNameplate.bIsTarget then
		bShow = false
	end

	if bShow then
		self:SetBarValue(tNameplate.wnd.healthHealthFill, 0, nHealth, nMaxHealth)

		tNameplate.hpPercentage = (nHealth / nMaxHealth) * 100

		if tNameplate.tSettings.bShowHpValue then
			tNameplate.wnd.hpText:SetText(Util:ShortNum(nHealth))
		else
			tNameplate.wnd.hpText:SetText("")
		end

		fnDrawIndicators(self, tNameplate)

		fnDrawIA(self, tNameplate)
		fnDrawShield(self, tNameplate)
		fnDrawAbsorb(self, tNameplate)

		bShow = true
	end

	if bShow ~= tNameplate.wnd.health:IsShown() then
		tNameplate.wnd.health:Show(bShow, true)
	end
end

function ForgeUI_Nameplates:DrawIA(tNameplate)
	local unitOwner = tNameplate.unitOwner

	local ia = tNameplate.wnd.ia

	local bShow = false

	nValue = unitOwner:GetInterruptArmorValue()
	nMax = unitOwner:GetInterruptArmorMax()
	if nMax == 0 or nValue == nil or unitOwner:IsDead() then

	else
		bShow = true
		if nMax == -1 then
			ia:SetBGColor("FF2D2D2D")
			ia:SetText("-")
		elseif nMax > 0 then
			ia:SetBGColor("FF795548")
			ia:SetText(nValue)
		end
	end

	if bShow ~= ia:IsShown() then
		ia:Show(bShow, true)
	end
end

function ForgeUI_Nameplates:DrawShield(tNameplate)
	local bShow = false

	if self._DB.profile.bShowShield then
		local unitOwner = tNameplate.unitOwner

		local nShield = unitOwner:GetShieldCapacity()
		local nShieldMax = unitOwner:GetShieldCapacityMax()

		bShow = nShield ~= nil and not unitOwner:IsDead() and nShield > 0

		if bShow then
			self:SetBarValue(tNameplate.wnd.healthShieldFill, 0, nShield, nShieldMax)
		end

		if bShow and tNameplate.tSettings.bShowShieldValue then
			tNameplate.wnd.shieldText:SetText(Util:ShortNum(nShield))
		else
			tNameplate.wnd.shieldText:SetText("")
		end
	end

	if bShow ~= tNameplate.wnd.healthMaxShield:IsShown() then
		tNameplate.wnd.healthMaxShield:Show(bShow, true)
		tNameplate.bShowShield = bShow

		if self._DB.profile.tStyle.nStyle == 1 then
			tNameplate.wndNameplate:FindChild("TargetMarker"):SetAnchorOffsets(-7, -7, 7, bShow and 7 + self._DB.profile.tStyle.nShieldHeight or 7)
			tNameplate.wndNameplate:FindChild("Indicator"):SetAnchorOffsets(-7, -7, 7, bShow and 7 + self._DB.profile.tStyle.nShieldHeight or 7)
		end
	end
end

function ForgeUI_Nameplates:DrawAbsorb(tNameplate)
	local bShow = false

	if self._DB.profile.bShowAbsorb then
		local unitOwner = tNameplate.unitOwner

		local nAbsorb = unitOwner:GetAbsorptionValue()
		local nAbsorbMax = unitOwner:GetAbsorptionMax()

		bShow = nAbsorb ~= nil and not unitOwner:IsDead() and nAbsorb > 0

		if bShow then
			if self._DB.profile.tStyle.nStyle == 0 then
				self:SetBarValue(tNameplate.wnd.healthAbsorbFill, 0, nAbsorb, nAbsorbMax)
			elseif self._DB.profile.tStyle.nStyle == 1 then
				local nMaxHealth = unitOwner:GetMaxHealth()

				if nMaxHealth > nAbsorbMax then
					self:SetBarValue(tNameplate.wnd.healthAbsorbFill, 0, nAbsorb, nMaxHealth)
				else
					self:SetBarValue(tNameplate.wnd.healthAbsorbFill, 0, nAbsorb, nAbsorbMax)
				end
			end
		end
	end

	if bShow ~= tNameplate.wnd.healthMaxAbsorb:IsShown() then
		tNameplate.wnd.healthMaxAbsorb:Show(bShow, true)
		tNameplate.bShowAbsorb = bShow

		if self._DB.profile.tStyle.nStyle == 1 then
			tNameplate.wndNameplate:FindChild("TargetMarker"):SetAnchorOffsets(-7, bShow and -7 - self._DB.profile.tStyle.nAbsorbHeight or -7, 7, 7)
			tNameplate.wndNameplate:FindChild("Indicator"):SetAnchorOffsets(-7, bShow and -7 - self._DB.profile.tStyle.nAbsorbHeight or -7, 7, 7)
		end
	end
end

function ForgeUI_Nameplates:OnStartSpellThreshold(idSpell, nMaxThresholds, eCastMethod) -- Event
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end

	local tNameplate = self.arUnit2Nameplate[unitPlayer:GetId()]

	local splObject = GameLib.GetSpell(idSpell)

	if tNameplate ~= nil then

		tNameplate.tTapCast = {
			idSpell = idSpell,
			strSpellName = splObject:GetName(),
			nThreshold = 1,
			nMaxThreshold = nMaxThresholds,
			bActive = true,
		}

		local bShow = self:GetBooleanOption("nShowCast", tNameplate)

		local wndCastBar = tNameplate.wnd.castBar
		if bShow ~= wndCastBar:IsShown() then
			wndCastBar:Show(bShow)
		end

		if bShow then
			tNameplate.wnd.castBarCastFill:SetBarColor(self._DB.profile.crCastbarNormal)

			local strCastName = tNameplate.tTapCast.strSpellName
			tNameplate.wnd.castBarLabel:SetText(string.format("%s (%s/%s)", strCastName, "1", nMaxThresholds))
			tNameplate.strCastName = strCastName

			local nCastDuration = nMaxThresholds
			if nCastDuration ~= tNameplate.nCastDuration then
				tNameplate.wnd.castBarCastFill:SetMax(nCastDuration)
				tNameplate.nCastDuration = nCastDuration
			end

			local nCastElapsed = tNameplate.tTapCast.nThreshold
			if nCastElapsed ~= tNameplate.nCastElapsed then
				tNameplate.wnd.castBarCastFill:SetProgress(nCastElapsed)
				tNameplate.nCastElapsed = nCastElapsed
			end

		end

	end
end

function ForgeUI_Nameplates:OnUpdateSpellThreshold(idSpell, nNewThreshold) -- Event
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end

	local tNameplate = self.arUnit2Nameplate[unitPlayer:GetId()]

	if tNameplate ~= nil then

		local bShow = self:GetBooleanOption("nShowCast", tNameplate)

		local wndCastBar = tNameplate.wnd.castBar
		if bShow ~= wndCastBar:IsShown() then
			wndCastBar:Show(bShow)
		end

		local strCastName = tNameplate.tTapCast.strSpellName
		local nMaxThresholds = tNameplate.tTapCast.nMaxThreshold
		tNameplate.wnd.castBarLabel:SetText(string.format("%s (%s/%s)", strCastName, nNewThreshold, nMaxThresholds))
		tNameplate.strCastName = strCastName

		local nCastDuration = tNameplate.tTapCast.nMaxThreshold
		if nCastDuration ~= tNameplate.nCastDuration then
			tNameplate.wnd.castBarCastFill:SetMax(nCastDuration)
			tNameplate.nCastDuration = nCastDuration
		end

		local nCastElapsed = nNewThreshold
		if nCastElapsed ~= tNameplate.nCastElapsed then
			tNameplate.wnd.castBarCastFill:SetProgress(nCastElapsed)
			tNameplate.nCastElapsed = nCastElapsed
			tNameplate.tTapCast.nThreshold = nNewThreshold
		end

	end
end

function ForgeUI_Nameplates:OnClearSpellThreshold(idSpell) -- Event
	local unitPlayer = GameLib.GetPlayerUnit()
	local tNameplate = self.arUnit2Nameplate[unitPlayer:GetId()]
	if unitPlayer == nil or not unitPlayer:IsValid() or tNameplate == nil then return end

	tNameplate.wnd.castBar:Show(false)
	tNameplate.wnd.castBarCastFill:SetProgress(0)

	tNameplate.tTapCast = nil
end

function ForgeUI_Nameplates:DrawMOOBar(tNameplate)
	local unitOwner = tNameplate.unitOwner
	if unitOwner == nil or unitOwner:IsDead() then return end

	local nCCTimeRemaining = unitOwner:GetCCStateTimeRemaining(Unit.CodeEnumCCState.Vulnerability)
	local nCCTimeMax = unitOwner:GetCCStateTotalTime(Unit.CodeEnumCCState.Vulnerability)

	if nCCTimeRemaining > 0 then

		tNameplate.wnd.castBarCastFill:SetBarColor(self._DB.profile.crCastbarMOO)

--		local strCastName = string.format("%s (%s)", "MoO", ForgeUI.Round(time, 1))
		local strCastName = ""
		if strCastName ~= tNameplate.strCastName then
			tNameplate.wnd.castBarLabel:SetText(strCastName)
			tNameplate.strCastName = strCastName
		end

		if nCCTimeMax ~= tNameplate.nCastDuration then
			tNameplate.wnd.castBarCastFill:SetMax(nCCTimeMax)
			tNameplate.nCastDuration = nCCTimeMax
		end

		if nCCTimeRemaining ~= tNameplate.nCastElapsed then
			tNameplate.wnd.castBarCastFill:SetProgress(nCCTimeRemaining)
			tNameplate.nCastElapsed = nCCTimeRemaining
		end

		if not tNameplate.wnd.castBar:IsShown() then
			tNameplate.wnd.castBar:Show(true, true)
		end
	else
		tNameplate.wnd.castBar:Show(false)
	end
end

function ForgeUI_Nameplates:DrawCastBar(tNameplate) -- Every frame
	-- TapCast check (only for unitPlayer)
	if tNameplate.tTapCast ~= nil and tNameplate.tTapCast.bActive and tNameplate.unitOwner:ShouldShowCastBar() then
		-- new cast started that interrupted TapCast
		tNameplate.tTapCast.bActive = false
	elseif tNameplate.tTapCast ~= nil and not tNameplate.tTapCast.bActive and not tNameplate.unitOwner:ShouldShowCastBar() then
		-- cast ended while inactive TapCast still running. updating castbar
		tNameplate.tTapCast.bActive = true
		return self:OnUpdateSpellThreshold(tNameplate.tTapCast.idSpell, tNameplate.tTapCast.nThreshold)
	elseif tNameplate.tTapCast ~= nil and not tNameplate.unitOwner:ShouldShowCastBar() then
		-- do not update cast bar if TapCast active (unless new cast started)
		return
	end

	local wndNameplate = tNameplate.wndNameplate
	local unitOwner = tNameplate.unitOwner

	if self._DB.profile.bMOODuration then -- MoO duration bar
		if unitOwner:IsInCCState(Unit.CodeEnumCCState.Vulnerability) then
			return self:DrawMOOBar(tNameplate)
		end
	end

	-- Casting; has some onDraw parameters we need to check
	tNameplate.bIsCasting = unitOwner:ShouldShowCastBar()

	local bShow = tNameplate.bIsCasting and self:GetBooleanOption("nShowCast", tNameplate)

	-- hide cast bar for non flagged hostile players
	if tNameplate.tSettings.bHideCastNoPvP and tNameplate.strUnitType == "HostilePlayer" and not unitOwner:IsPvpFlagged() and not tNameplate.bIsTarget then
		bShow = false
	end

	local wndCastBar = tNameplate.wnd.castBar
	if bShow ~= wndCastBar:IsShown() then
		wndCastBar:Show(bShow)
	end

	if bShow then
		tNameplate.wnd.castBarCastFill:SetBarColor(self._DB.profile.crCastbarNormal)

		local strCastName = unitOwner:GetCastName()
		if strCastName ~= tNameplate.strCastName then
			tNameplate.wnd.castBarLabel:SetText(strCastName)
			tNameplate.strCastName = strCastName
		end

		local nCastDuration = unitOwner:GetCastDuration()
		if nCastDuration ~= tNameplate.nCastDuration then
			tNameplate.wnd.castBarCastFill:SetMax(nCastDuration)
			tNameplate.nCastDuration = nCastDuration
		end

		local nCastElapsed = unitOwner:GetCastElapsed()
		if nCastElapsed ~= tNameplate.nCastElapsed then
			tNameplate.wnd.castBarCastFill:SetProgress(nCastElapsed)
			tNameplate.nCastElapsed = nCastElapsed
		end
	end
end

function ForgeUI_Nameplates:DrawRewards(tNameplate)
	local wndNameplate = tNameplate.wndNameplate
	local unitOwner = tNameplate.unitOwner

	local bShow = self._DB.profile.bShowObjectives

	if bShow ~= tNameplate.wnd.questRewards:IsShown() then
		tNameplate.wnd.questRewards:Show(bShow)
	end

	local tRewardsData = tNameplate.wnd.questRewards:GetData()
end

function ForgeUI_Nameplates:DrawIndicators(tNameplate)
	local wnd = tNameplate.wnd
	local unitOwner = tNameplate.unitOwner

	-- target indicator

	local bShowTargetMarker = tNameplate.bIsTarget and self._DB.profile.tUnits["Target"].bShowMarker
	if wnd.targetMarker:IsShown() ~= bShowTargetMarker then
		wnd.targetMarker:Show(bShowTargetMarker)
	end

	local bShowIndicator = false

	-- threat loss indicator

	if tNameplate.tSettings.bThreatIndicator then
		local unitsTarget = unitOwner:GetTarget()
		if unitsTarget and not unitsTarget:IsThePlayer() then
			bShowIndicator = true
		end
	end

	-- cleanse indicator

	if tNameplate.tSettings.bCleanseIndicator then
		local tDebuffs = unitOwner:GetBuffs().arHarmful

		for _, debuff in pairs(tDebuffs) do
			if debuff["splEffect"]:GetClass() == Spell.CodeEnumSpellClass.DebuffDispellable then
				bShowIndicator = true
				tNameplate.bIsCleansable = true
			end
		end
	end

	if bShowIndicator ~= wnd.indicator:IsShown() then
		wnd.indicator:Show(bShowIndicator, true)
	end
end

function ForgeUI_Nameplates:DrawInfo(tNameplate)
	local wnd = tNameplate.wnd

	local nShowInfo = 0
	local bShowInfo = false

	--if tNameplate.bIsTarget then
	--	nShowInfo = self._DB.profile.tUnits["Target"].nShowInfo
	--else
		nShowInfo = tNameplate.tSettings.nShowInfo
	--end


	if nShowInfo == 0 then
	elseif nShowInfo == 1 then
		wnd.info_level:SetAnchorOffsets(-60, 0, -2, 0)
		wnd.info_class:SetAnchorOffsets(0, 0, 0, 0)

		bShowInfo = true
	elseif nShowInfo == 2 then
		wnd.info_class:SetAnchorOffsets(-15, 0, 0, 0)
		wnd.info_level:SetAnchorOffsets(0, 0, 0, 0)

		bShowInfo = true
	elseif nShowInfo == 3 then
		wnd.info_class:SetAnchorOffsets(-15, 0, 0, 0)
		wnd.info_level:SetAnchorOffsets(-75, 0, -17, 0)

		bShowInfo = true
	end

	if bShowInfo ~= wnd.info:IsShown() then
		wnd.info:Show(bShowInfo, true)
	end
end

function ForgeUI_Nameplates:UpdateInfo(tNameplate)
	local unitOwner = tNameplate.unitOwner
	local wnd = tNameplate.wnd

	wnd.info_level:SetText(tostring(unitOwner:GetLevel()))
	if unitOwner:GetType() == "Player" then
		wnd.info_class:SetBGColor(F:API_GetClassColor(tNameplate.unitOwner))
		wnd.info_class:SetSprite("ForgeUI_" .. krtClassEnums[tNameplate.unitClassID] .. "_t")
	elseif tNameplate.unitClassID ~= 6 and tNameplate.unitClassID >= 0 then
		wnd.info_class:SetSprite("ForgeUI_npc_rank_" .. krtNpcRankEnums[tNameplate.unitClassID] .. "_t")
	end
end

function ForgeUI_Nameplates:RepositionNameplate(tNameplate)
    if tNameplate.tSettings.bReposition then
        local wndNameplate = tNameplate.wndNameplate

        local tOverhead = tNameplate.unitOwner:GetOverheadAnchor()
        if tOverhead == nil then return end

        if tOverhead.y < 25 and not tNameplate.bRepositioned then

            tNameplate.bRepositioned = true
            wndNameplate:SetUnit(tNameplate.unitOwner, 0)

        elseif tOverhead.y > 25 and tNameplate.bRepositioned then

            tNameplate.bRepositioned = false
            wndNameplate:SetUnit(tNameplate.unitOwner, 1)

        end
    end
end

function ForgeUI_Nameplates:SetBarValue(wndBar, fMin, fValue, fMax)
	wndBar:SetMax(fMax)
	wndBar:SetFloor(fMin)
	wndBar:SetProgress(fValue)
end

-----------------------------------------------------------------------------------------------
-- Helper functions
-----------------------------------------------------------------------------------------------

function ForgeUI_Nameplates:CheckDrawDistance(tNameplate)
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

	if tNameplate.bIsTarget then
		bInRange = nDistance < self._DB.profile.knTargetRange
		return bInRange
	else
		bInRange = nDistance < self._DB.profile.nMaxRange * self._DB.profile.nMaxRange
		return bInRange
	end
end

function ForgeUI_Nameplates:HelperVerifyVisibilityOptions(tNameplate)
	local unitPlayer = self.unitPlayer
	local unitOwner = tNameplate.unitOwner

	local bDontShowNameplate = not tNameplate.bOnScreen or tNameplate.bGibbed or not tNameplate.bIsImportant and self._DB.profile.bOnlyImportantNPC
		or (unitOwner:IsDead() and not self._DB.profile.bShowDead)

	if bDontShowNameplate and not tNameplate.bIsTarget then
		return false
	end

	local eDisposition = tNameplate.eDisposition
	local tActivation = tNameplate.tActivation

	local bShowNameplate = true
	if self._DB.profile.bUseOcclusion then
		bShowNameplate = not tNameplate.bOccluded or tNameplate.bIsTarget
	else
		bShowNameplate = true
	end

	--if self._DB.profile.bShowMainObjectiveOnly and not bShowNameplate then
	--	local tRewardInfo = unitOwner:GetRewardInfo() or {}
	--	for idx, tReward in pairs(tRewardInfo) do
	--		if tReward.eType == Unit.CodeEnumRewardInfoType.Quest or tReward.eType == Unit.CodeEnumRewardInfoType.Contract then
	--			bShowNameplate = true
	--			break
	--		end
	--	end
	--end

	return bShowNameplate
end

local strPlayerName = nil
function ForgeUI_Nameplates:GetUnitType(unit)
	if unit == nil or not unit:IsValid() then return end

	local eDisposition
	if self.unitPlayer then
		eDisposition = unit:GetDispositionTo(self.unitPlayer)
	else
		eDisposition = unit:GetDispositionTo(GameLib.GetPlayerUnit())
	end

	if not strPlayerName then
		strPlayerName = self.unitPlayer:GetName()
	end

	if unit:GetType() == "Player" and unit:GetName() == strPlayerName then -- TODO: :IsThePlayer() broken
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
	elseif unit:GetType() == "Scanner" then
		return "Scanner"
	elseif unit:GetType() == "Pickup" then
		if string.match(unit:GetName(), self.unitPlayer:GetName()) then
			return "Pickup"
		end
		return "PickupNotPlayer"
	elseif unit:GetHealth() == nil and (not unit:IsDead() or unit:GetLevel() == nil) then
		return "Simple"
	else
		if eDisposition == 0 then
			return "HostileNPC"
		elseif eDisposition == 1 then
			return "NeutralNPC"
		elseif eDisposition == 2 then
			return "FriendlyNPC"
		elseif eDisposition == 3 then
			return "UnknownNPC"
		end
	end
end

function ForgeUI_Nameplates:GetBooleanOption(strOption, tNameplate)
	local nOption = -1

	local unit = tNameplate.unitOwner
	if self._DB.profile.bCombatStatePlayer then -- track player combat state
		unit = self.unitPlayer
	end

	if tNameplate.bIsTarget then
		nOption = self._DB.profile.tUnits.Target[strOption]
		if nOption == nil then
			nOption = tNameplate.tSettings[strOption]
		end
	else
		nOption = tNameplate.tSettings[strOption]
	end

	if nOption == 0 then -- Never
		return false
	elseif nOption == 1 then -- Out of combat
		if not unit:IsInCombat() then
			return true
		else
			return false
		end
	elseif nOption == 2 then -- In combat
		-- if unit:IsInCombat() or unit:GetHealth() ~= unit:GetMaxHealth() then
		-- removed max health check: because we want to see nameplates ONLY in combat and not when unit isn't full health
		-- can be re implemented via separate option if needed
		if unit:IsInCombat() then
			return true
		else
			return false
		end
	elseif nOption == 3 then -- Always
		return true
	end
end

function ForgeUI_Nameplates:IsImportantNPC(unitOwner)
	local strUnitType = self:GetUnitType(unitOwner)
	if strUnitType == "FriendlyNPC" or strUnitType == "Simple" then
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
		if tActivation.TradeskillTrainer  then
			return true
		end

		if tActivation.InstancePortal then
			return true
		end

		return false
	else
		return true
	end

	return false
end

-----------------------------------------------------------------------------------------------
-- Stylers
-----------------------------------------------------------------------------------------------

function ForgeUI_Nameplates:LoadStyle_Nameplates()
	for idx, tNameplate in pairs(self.arUnit2Nameplate) do
		self:LoadStyle_Nameplate(tNameplate)
		self:UpdateInfo(tNameplate)
	end
end

function ForgeUI_Nameplates:LoadStyle_Nameplate(tNameplate)
	if not tNameplate then return end

	local wnd = tNameplate.wnd
	local wndNameplate = tNameplate.wndNameplate

	wnd.targetMarker:SetBGColor(self._DB.profile.tUnits["Target"].crTargetMarker)
	wnd.ia:SetSprite(self._DB.profile.tStyle.strIASprite)

	wnd.healthShieldFill:SetBarColor(self._DB.profile.crShield)
	wnd.healthAbsorbFill:SetBarColor(self._DB.profile.crAbsorb)
	wnd.healthHealthFill:SetFullSprite(self._DB.profile.tStyle.strFullSprite)
	wnd.castBarCastFill:SetFullSprite(self._DB.profile.tStyle.strFullSprite)
	wnd.healthShieldFill:SetFullSprite(self._DB.profile.tStyle.strFullSprite)
	wnd.healthAbsorbFill:SetFullSprite(self._DB.profile.tStyle.strFullSprite)

	if tNameplate.strUnitType == "HostileNPC" then
		wnd.indicator:SetBGColor(self._DB.profile.tUnits["HostileNPC"].crThreatIndicator)
	elseif tNameplate.strUnitType == "FriendlyPlayer" then
		wnd.indicator:SetBGColor(self._DB.profile.tUnits["FriendlyPlayer"].crCleanseIndicator)
	elseif tNameplate.strUnitType == "PartyPlayer" then
		wnd.indicator:SetBGColor(self._DB.profile.tUnits["PartyPlayer"].crCleanseIndicator)
	end

	--style
	local tStyle = self._DB.profile.tStyle

	-- nameplate vertical offset
	local nLeft, nTop, nRight, nBottom = wndNameplate:GetAnchorOffsets()

	nTop = -150 + tStyle.nBarOffset
	nBottom = nTop + 80

	wndNameplate:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)

	-- indicators
	if tStyle.nStyle == 0 then
		wndNameplate:FindChild("TargetMarker"):SetAnchorOffsets(-7, -7, 7, 7)
		wndNameplate:FindChild("Indicator"):SetAnchorOffsets(-7, -7, 7, 7)
	elseif self._DB.profile.tStyle.nStyle == 1 then
		wndNameplate:FindChild("TargetMarker"):SetAnchorOffsets(-7, -7, 7, 7 + tStyle.nShieldHeight)
		wndNameplate:FindChild("Indicator"):SetAnchorOffsets(-7, -7, 7, 7 + tStyle.nShieldHeight)
	end

	-- bar
	nLeft, nTop, nRight, nBottom = wndNameplate:FindChild("Container"):GetAnchorOffsets()

	nLeft = -(tStyle.nBarWidth / 2)
	nRight = (tStyle.nBarWidth / 2)

	nBottom = nTop + tStyle.nBarHeight

	wndNameplate:FindChild("Container"):SetAnchorOffsets(nLeft, nTop, nRight, nBottom)

	-- shield
	if tStyle.nStyle == 0 then
		wndNameplate:FindChild("MaxShield"):SetAnchorPoints(0.5, 1, 1, 1)
		wndNameplate:FindChild("MaxShield"):SetAnchorOffsets(10, -4, -5, 4)

		nLeft, nTop, nRight, nBottom = wndNameplate:FindChild("MaxShield"):GetAnchorOffsets()

		nTop = -(tStyle.nShieldHeight / 2)
		nBottom = (tStyle.nShieldHeight / 2)

		wndNameplate:FindChild("MaxShield"):SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
	elseif tStyle.nStyle == 1 then
		wndNameplate:FindChild("MaxShield"):SetAnchorPoints(0, 1, 1, 1)
		wndNameplate:FindChild("MaxShield"):SetAnchorOffsets(0, -1, 0, tStyle.nShieldHeight)
	end

	-- absorb
	if tStyle.nStyle == 0 then
		wndNameplate:FindChild("MaxAbsorb"):SetAnchorPoints(0, 1, 0.5, 1)
		wndNameplate:FindChild("MaxAbsorb"):SetAnchorOffsets(5, -4, -10, 4)

		nLeft, nTop, nRight, nBottom = wndNameplate:FindChild("MaxAbsorb"):GetAnchorOffsets()

		nTop = -(tStyle.nAbsorbHeight/ 2)
		nBottom = (tStyle.nAbsorbHeight/ 2)

		wndNameplate:FindChild("MaxAbsorb"):SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
	elseif tStyle.nStyle == 1 then
		wndNameplate:FindChild("MaxAbsorb"):SetAnchorPoints(0, 0, 1, 0)
		wndNameplate:FindChild("MaxAbsorb"):SetAnchorOffsets(0, - tStyle.nAbsorbHeight, 0, 1)
	end

	-- castbar
	nLeft, nTop, nRight, nBottom = wndNameplate:FindChild("CastBar"):GetAnchorOffsets()

	nTop = -4 + tStyle.nCastOffsetY
	nBottom = nTop + tStyle.nCastHeight

	wndNameplate:FindChild("CastBar"):SetAnchorOffsets(nLeft, nTop, nRight, nBottom)

	-- cast text
	nLeft, nTop, nRight, nBottom = wndNameplate:FindChild("Container:CastBar:Label"):GetAnchorOffsets()

	nTop = -16 + tStyle.nCastTextOffsetY
	nBottom = nTop + 16

	wndNameplate:FindChild("Container:CastBar:Label"):SetAnchorOffsets(nLeft, nTop, nRight, nBottom)

	wndNameplate:FindChild("Container:CastBar:Label"):SetTextFlags("dt_center", self._DB.profile.tStyle.bCastTextCenter)

	-- hp & shield values
	if tStyle.nStyle == 0 then
		wndNameplate:FindChild("ShieldValue"):SetAnchorPoints(1, 1, 1, 1)
		wndNameplate:FindChild("ShieldValue"):SetAnchorOffsets(-57, -20, -7, 15)
	elseif tStyle.nStyle == 1 then
		wndNameplate:FindChild("ShieldValue"):SetAnchorPoints(0, 0, 0, 1)
		wndNameplate:FindChild("ShieldValue"):SetAnchorOffsets(-52, -3, -2, 23)
	end
end

function ForgeUI_Nameplates:OnStyleChanged()
	if self._DB.profile.tStyle.nStyle == 0 then
		self._DB.profile.tStyle.nAbsorbHeight = 8
		self._DB.profile.tStyle.nShieldHeight = 8
		--self._DB.profile.crShield = "FF0699F3"
	elseif self._DB.profile.tStyle.nStyle == 1 then
		self._DB.profile.tStyle.nAbsorbHeight = 4
		self._DB.profile.tStyle.nShieldHeight = 4
		--self._DB.profile.crShield = "FFFFFFFF"
	end

	self:RefreshConfig()
	self:LoadStyle_Nameplates()
end

-----------------------------------------------------------------------------------------------
-- Nameplate Events
-----------------------------------------------------------------------------------------------

function ForgeUI_Nameplates:OnNameplateNameClick(wndHandler, wndCtrl, eMouseButton)
	if wndHandler ~= wndCtrl then return end -- Fixes ghost clicks

	if not self._DB.profile.bClickable then return false end
	if eMouseButton == GameLib.CodeEnumInputMouse.Right then return false end

	local tNameplate = self.arWnd2Nameplate[wndHandler:GetParent():GetId()]
	if not tNameplate then return false end

	local unitOwner = tNameplate.unitOwner
	if unitOwner:IsThePlayer() then return false end

	if GameLib.GetTargetUnit() ~= unitOwner and eMouseButton == GameLib.CodeEnumInputMouse.Left then
		GameLib.SetTargetUnit(unitOwner)
		return true
	elseif GameLib.GetTargetUnit() == unitOwner then
		return true
	end

	return false
end

function ForgeUI_Nameplates:OnWorldLocationOnScreen(wndHandler, wndControl, bOnScreen)
	local tNameplate = self.arWnd2Nameplate[wndHandler:GetId()]
	if tNameplate ~= nil then
		tNameplate.bOnScreen = bOnScreen
		fnUpdateNameplateVisibility(self, tNameplate)
	end
end

function ForgeUI_Nameplates:OnUnitOcclusionChanged(wndHandler, wndControl, bOccluded)
	local tNameplate = self.arWnd2Nameplate[wndHandler:GetId()]
	if tNameplate ~= nil then
		tNameplate.bOccluded = bOccluded
		fnUpdateNameplateVisibility(self, tNameplate)
	end
end

-----------------------------------------------------------------------------------------------
-- System Events
-----------------------------------------------------------------------------------------------

function ForgeUI_Nameplates:OnEnteredCombat(unitChecked, bInCombat)
	if unitChecked == self.unitPlayer then
		self.bPlayerInCombat = bInCombat
	end

	local tNameplate = self.arUnit2Nameplate[unitChecked:GetId()]
	if tNameplate ~= nil then
		fnDrawName(self, tNameplate)
	end
end

function ForgeUI_Nameplates:OnUnitGibbed(unitUpdated)
	local tNameplate = self.arUnit2Nameplate[unitUpdated:GetId()]
	if tNameplate ~= nil then
		tNameplate.bGibbed = true
		fnUpdateNameplateVisibility(self, tNameplate)
	end
end

function ForgeUI_Nameplates:OnUnitNameChanged(unitUpdated, strNewName)
	local tNameplate = self.arUnit2Nameplate[unitUpdated:GetId()]
	if tNameplate ~= nil then
		fnDrawName(self, tNameplate)
	end
end

function ForgeUI_Nameplates:OnUnitTitleChanged(unitUpdated)
	local tNameplate = self.arUnit2Nameplate[unitUpdated:GetId()]
	if tNameplate ~= nil then
		fnDrawName(self, tNameplate)
	end
end

function ForgeUI_Nameplates:OnPlayerTitleChanged()
	local tNameplate = self.arUnit2Nameplate[self.unitPlayer:GetId()]
	if tNameplate ~= nil then
		fnDrawName(self, tNameplate)
	end
end

function ForgeUI_Nameplates:OnGuildChange()
	self.guildDisplayed = nil
	self.guildWarParty = nil
	for key, guildCurr in pairs(GuildLib.GetGuilds()) do
		local eGuildType = guildCurr:GetType()
		if eGuildType == GuildLib.GuildType_Guild then
			self.guildDisplayed = guildCurr
		end
		if eGuildType == GuildLib.GuildType_WarParty then
			self.guildWarParty = guildCurr
		end
	end

	for key, tNameplate in pairs(self.arUnit2Nameplate) do
		local unitOwner = tNameplate.unitOwner
		tNameplate.bIsGuildMember = self.guildDisplayed and self.guildDisplayed:IsUnitMember(unitOwner) or false
		tNameplate.bIsWarPartyMember = self.guildWarParty and self.guildWarParty:IsUnitMember(unitOwner) or false
	end
end

function ForgeUI_Nameplates:OnUnitGuildNameplateChanged(unitUpdated)
	local tNameplate = self.arUnit2Nameplate[unitUpdated:GetId()]
	if tNameplate ~= nil then
		fnDrawGuild(self, tNameplate)
	end
end

function ForgeUI_Nameplates:OnUnitMemberOfGuildChange(unitOwner)
	local tNameplate = self.arUnit2Nameplate[unitOwner:GetId()]
	if tNameplate ~= nil then
		fnDrawGuild(self, tNameplate)
		tNameplate.bIsGuildMember = self.guildDisplayed and self.guildDisplayed:IsUnitMember(unitOwner) or false
		tNameplate.bIsWarPartyMember = self.guildWarParty and self.guildWarParty:IsUnitMember(unitOwner) or false
	end
end

function ForgeUI_Nameplates:OnTargetUnitChanged(unitOwner) -- build targeted options here; we get this event when a creature attacks, too
	for idx, tNameplateOther in pairs(self.arUnit2Nameplate) do
		local bIsTarget = tNameplateOther.bIsTarget

		tNameplateOther.bIsTarget = false

		if bIsTarget then
			fnDrawIndicators(self, tNameplateOther)
			fnDrawHealth(self, tNameplateOther)
			fnDrawName(self, tNameplateOther)
			fnDrawGuild(self, tNameplateOther)
			fnDrawInfo(self, tNameplateOther)

			self:UpdateNameplateRewardInfo(tNameplateOther)

			fnUpdateNameplateVisibility(self, tNameplateOther)
		end
	end

	if unitOwner == nil then
		return
	end

	local tNameplate = self.arUnit2Nameplate[unitOwner:GetId()]
	if tNameplate == nil then
		return
	end

	if GameLib.GetTargetUnit() == unitOwner then
		tNameplate.bIsTarget = true

		fnDrawHealth(self, tNameplate)
		fnDrawName(self, tNameplate)
		fnDrawGuild(self, tNameplate)
		fnDrawInfo(self, tNameplate)

		self:UpdateNameplateRewardInfo(tNameplate)

		fnUpdateNameplateVisibility(self, tNameplate)
	end
end

-----------------------------------------------------------------------------------------------
-- Populating opions
-----------------------------------------------------------------------------------------------
function ForgeUI_Nameplates:ForgeAPI_PopulateOptions()
	-- general settings
	local wndGeneral = self.tOptionHolders["General"]

	G:API_AddNumberBox(self, wndGeneral, "Draw distance", self._DB.profile, "nMaxRange", { tMove = {0, 0} })
	G:API_AddCheckBox(self, wndGeneral, "Use occlusion", self._DB.profile, "bUseOcclusion", { tMove = {0, 30},
		strTooltip = "If checked, nameplates will not be drawn behind objects.",
		fnCallback = (function(...) Apollo.SetConsoleVariable("ui.occludeNameplatePositions", arg[2]) end) })
	G:API_AddCheckBox(self, wndGeneral, "Show titles", self._DB.profile, "bShowTitles", { tMove = {200, 30} })
	G:API_AddCheckBox(self, wndGeneral, "Show only important NPC", self._DB.profile, "bOnlyImportantNPC", { tMove = {0, 60} })
	G:API_AddCheckBox(self, wndGeneral, "Track player combat state", self._DB.profile, "bCombatStatePlayer", { tMove = {200, 60},
		strTooltip = "If checked, [In combat / Out of combat] visibility settings will be based on player combat state instead of unit combat state." })
	G:API_AddCheckBox(self, wndGeneral, "Short names", self._DB.profile, "bShortNames", { tMove = {400, 60} })
	G:API_AddCheckBox(self, wndGeneral, "Show objectives", self._DB.profile, "bShowObjectives", { tMove = {200, 0} })
	G:API_AddCheckBox(self, wndGeneral, "Show shields", self._DB.profile, "bShowShield", { tMove = {0, 150} })
	G:API_AddCheckBox(self, wndGeneral, "Show absorbs", self._DB.profile, "bShowAbsorb", { tMove = {0, 180} })
	G:API_AddCheckBox(self, wndGeneral, "Frequent updates", self._DB.profile, "bFrequentUpdate", { tMove = {400, 0} })
	G:API_AddCheckBox(self, wndGeneral, "Clickable nameplates", self._DB.profile, "bClickable", { tMove = {400, 30}, fnCallback = self.LoadStyle_Nameplates })
	G:API_AddCheckBox(self, wndGeneral, "Show nameplates for dead units", self._DB.profile, "bShowDead", { tOffsets = { 5, 125, 300, 150 } })
	G:API_AddCheckBox(self, wndGeneral, "Show MOO bar", self._DB.profile, "bMOOBar", { tMove = {0, 240} })
	G:API_AddCheckBox(self, wndGeneral, "Show MOO duration bar", self._DB.profile, "bMOODuration", { tMove = {0, 270} })
	G:API_AddColorBox(self, wndGeneral, "Shield bar", self._DB.profile, "crShield", { tMove = {400, 150}, fnCallback = self.LoadStyle_Nameplates })
	G:API_AddColorBox(self, wndGeneral, "Absorb bar", self._DB.profile, "crAbsorb", { tMove = {400, 180}, fnCallback = self.LoadStyle_Nameplates })
	G:API_AddColorBox(self, wndGeneral, "MOO bar", self._DB.profile, "crHealthbarMOO", { tMove = {400, 240}, fnCallback = self.LoadStyle_Nameplates })
	G:API_AddColorBox(self, wndGeneral, "MOO duration bar", self._DB.profile, "crCastbarMOO", { tMove = {400, 270}, fnCallback = self.LoadStyle_Nameplates })
	G:API_AddColorBox(self, wndGeneral, "Dead unit name", self._DB.profile, "crDead", { tMove = {400, 120}, fnCallback = self.LoadStyle_Nameplates })

	-- style options
	local wndStyle = self.tOptionHolders["Style"]

	G:API_AddNumberBox(self, wndStyle, "Nameplate width", self._DB.profile.tStyle, "nBarWidth", { tMove = { 0, 30 }, fnCallback = self.LoadStyle_Nameplates })
	G:API_AddNumberBox(self, wndStyle, "Nameplate height", self._DB.profile.tStyle, "nBarHeight", { tMove = { 0, 60 }, fnCallback = self.LoadStyle_Nameplates })
	G:API_AddNumberBox(self, wndStyle, "Nameplate vertical offset", self._DB.profile.tStyle, "nBarOffset", { tOffsets = { 5, 95, 300, 120 }, fnCallback = self.LoadStyle_Nameplates })
	G:API_AddNumberBox(self, wndStyle, "Shield height", self._DB.profile.tStyle, "nShieldHeight", { tMove = { 300, 30 }, fnCallback = self.LoadStyle_Nameplates })
	G:API_AddNumberBox(self, wndStyle, "Absorb height", self._DB.profile.tStyle, "nAbsorbHeight", { tMove = { 300, 60 }, fnCallback = self.LoadStyle_Nameplates })
	G:API_AddNumberBox(self, wndStyle, "Castbar height", self._DB.profile.tStyle, "nCastHeight", { tMove = { 0, 180 }, fnCallback = self.LoadStyle_Nameplates })
	G:API_AddNumberBox(self, wndStyle, "Castbar vertical offset", self._DB.profile.tStyle, "nCastOffsetY", { tOffsets = { 5, 215, 300, 240 }, fnCallback = self.LoadStyle_Nameplates })
	G:API_AddNumberBox(self, wndStyle, "Cast text vertical offset", self._DB.profile.tStyle, "nCastTextOffsetY", { tOffsets = { 205, 185, 500, 210 }, fnCallback = self.LoadStyle_Nameplates })
	G:API_AddCheckBox(self, wndStyle, "Center cast text", self._DB.profile.tStyle, "bCastTextCenter", { tMove = {200, 210}, fnCallback = self.LoadStyle_Nameplates })

	local wndComboStyle = G:API_AddComboBox(self, wndStyle, "Style", self._DB.profile.tStyle, "nStyle", { fnCallback = self.OnStyleChanged })
	G:API_AddOptionToComboBox(self, wndComboStyle , "Modern", 0, {})
	G:API_AddOptionToComboBox(self, wndComboStyle , "Classic", 1, {})

	local wndCombo = G:API_AddComboBox(self, wndStyle, "Texture", self._DB.profile.tStyle, "strFullSprite", { tMove = {0, 120}, tWidths = { 150, 50 },
		fnCallback = self.LoadStyle_Nameplates
	})
	G:API_AddOptionToComboBox(self, wndCombo, "ForgeUI_Smooth","ForgeUI_Smooth", {})
	G:API_AddOptionToComboBox(self, wndCombo, "ForgeUI_Flat", "ForgeUI_Flat", {})
	G:API_AddOptionToComboBox(self, wndCombo, "ForgeUI_Minimalist", "ForgeUI_Minimalist", {})
	G:API_AddOptionToComboBox(self, wndCombo, "ForgeUI_Edge", "ForgeUI_Edge", {})

	local wndComboIA = G:API_AddComboBox(self, wndStyle, "IA icon", self._DB.profile.tStyle, "strIASprite", { tMove = {300, 120}, tWidths = { 150, 50 },
		fnCallback = self.LoadStyle_Nameplates
	})
	G:API_AddOptionToComboBox(self, wndComboIA, "Shield","ForgeUI_shield", {})
	G:API_AddOptionToComboBox(self, wndComboIA, "Square", "ForgeUI_Border", {})

	-- specific options
	for k, v in pairs(self._DB.profile.tUnits) do
		local wnd = self.tOptionHolders[k]
		if wnd then
			if v.nHpCutoff then
				G:API_AddNumberBox(self, wnd, "HP cutoff", v, "nHpCutoff", { tMove = {400, 0}, strTooltip = "Recolor nameplate when HP is below this percentage.", })
			end

			if v.crHpCutoff then
				G:API_AddColorBox(self, wnd, "HP cutoff color", v, "crHpCutoff", { tMove = {400, 30}, })
			end

			if v.crName then
				G:API_AddColorBox(self, wnd, "Name color", v, "crName", { tMove = {0, 150} })
			end

			if v.crNameNoPvP then
				G:API_AddColorBox(self, wnd, "Name color (PvP off)", v, "crNameNoPvP", { tMove = {200, 150} })
			end

			if v.bHideBarsNoPvP ~= nil then
				G:API_AddCheckBox(self, wnd, "Hide bars (PvP off)", v, "bHideBarsNoPvP", { tMove = {200, 30} })
			end

			if v.bHideCastNoPvP ~= nil then
				G:API_AddCheckBox(self, wnd, "Hide cast (PvP off)", v, "bHideCastNoPvP", { tMove = {200, 60} })
			end

			if v.crHealth then
				G:API_AddColorBox(self, wnd, "Health color", v, "crHealth", { tMove = {0, 180} })
			end

			if v.bClassColors ~= nil then
				G:API_AddCheckBox(self, wnd, "Use class color", v, "bClassColors", { tMove = {200, 180} })
			end

			if v.bCleanseIndicator ~= nil then
				G:API_AddCheckBox(self, wnd, "Show cleanse indicator", v, "bCleanseIndicator", { tMove = {400, 90} })
			end


			if v.bHideOnHealth ~= nil then
				G:API_AddCheckBox(self, wnd, "Hide on full hp", v, "bHideOnHealth", { tMove = {400, 180} } )
			end


			if v.bHideOnShield ~= nil then
				G:API_AddCheckBox(self, wnd, "Hide on full shield", v, "bHideOnShield", { tMove = { 400, 210 } } )
			end


			if v.crCleanseIndicator then
				G:API_AddColorBox(self, wnd, "Cleanse indicator", v, "crCleanseIndicator", { tMove = {400, 120}, fnCallback = self.LoadStyle_Nameplates })
			end

			if v.bThreatIndicator ~= nil then
				G:API_AddCheckBox(self, wnd, "Show threat indicator", v, "bThreatIndicator", { tMove = {400, 90} })
			end

			if v.crThreatIndicator then
				G:API_AddColorBox(self, wnd, "Threat indicator", v, "crThreatIndicator", { tMove = {400, 120}, fnCallback = self.LoadStyle_Nameplates })
			end

			if v.bReposition ~= nil then
				G:API_AddCheckBox(self, wnd, "Reposition for big units", v, "bReposition", { tMove = {200, 60} })
			end

			if v.bShowHpValue ~= nil then
				G:API_AddCheckBox(self, wnd, "Show HP text", v, "bShowHpValue", { tMove = {400, 270}, fnCallback = self.LoadStyle_Nameplates })
			end

			if v.bShowShieldValue ~= nil then
				G:API_AddCheckBox(self, wnd, "Show shield text", v, "bShowShieldValue", { tMove = {400, 300}, fnCallback = self.LoadStyle_Nameplates })
			end

			if v.nShowGuild then
				local wndCombo = G:API_AddComboBox(self, wnd, "Guild", v, "nShowGuild", { tMove = {0, 90}, tWidths = { 150, 50 } })
				G:API_AddOptionToComboBox(self, wndCombo, "Never", 0, {})
				G:API_AddOptionToComboBox(self, wndCombo, "Out of combat", 1, {})
				G:API_AddOptionToComboBox(self, wndCombo, "In combat", 2, {})
				G:API_AddOptionToComboBox(self, wndCombo, "Always", 3, {})
			end

			if v.nShowCast then
				local wndCombo = G:API_AddComboBox(self, wnd, "Cast", v, "nShowCast", { tMove = {0, 60}, tWidths = { 150, 50 } })
				G:API_AddOptionToComboBox(self, wndCombo, "Never", 0, {})
				G:API_AddOptionToComboBox(self, wndCombo, "Out of combat", 1, {})
				G:API_AddOptionToComboBox(self, wndCombo, "In combat", 2, {})
				G:API_AddOptionToComboBox(self, wndCombo, "Always", 3, {})
			end

			if v.nShowBars then
				local wndCombo = G:API_AddComboBox(self, wnd, "Bars", v, "nShowBars", { tMove = {0, 30}, tWidths = { 150, 50 } })
				G:API_AddOptionToComboBox(self, wndCombo, "Never", 0, {})
				G:API_AddOptionToComboBox(self, wndCombo, "Out of combat", 1, {})
				G:API_AddOptionToComboBox(self, wndCombo, "In combat", 2, {})
				G:API_AddOptionToComboBox(self, wndCombo, "Always", 3, {})
			end

			if v.nShowName then
				local wndCombo = G:API_AddComboBox(self, wnd, "Name", v, "nShowName", { tMove = {0, 0}, tWidths = { 150, 50 } })
				G:API_AddOptionToComboBox(self, wndCombo, "Never", 0, {})
				G:API_AddOptionToComboBox(self, wndCombo, "Out of combat", 1, {})
				G:API_AddOptionToComboBox(self, wndCombo, "In combat", 2, {})
				G:API_AddOptionToComboBox(self, wndCombo, "Always", 3, {})
			end

			if v.nShowInfo then
				local wndCombo = G:API_AddComboBox(self, wnd, "Info", v, "nShowInfo", { tMove = {200, 0}, tWidths = { 150, 50 }, fnCallback = self.UpdateAllNameplates })
				G:API_AddOptionToComboBox(self, wndCombo, "Nothing", 0, {})
				G:API_AddOptionToComboBox(self, wndCombo, "Level", 1, {})
				G:API_AddOptionToComboBox(self, wndCombo, "Class", 2, {})
				G:API_AddOptionToComboBox(self, wndCombo, "Both", 3, {})
			end
		end
	end
end

-----------------------------------------------------------------------------------------------
-- Local function reference assignments
-----------------------------------------------------------------------------------------------
fnUpdateNameplate = ForgeUI_Nameplates.UpdateNameplate
fnUpdateNameplateVisibility = ForgeUI_Nameplates.UpdateNameplateVisibility

fnDrawNameplate = ForgeUI_Nameplates.DrawNameplate

fnDrawName = ForgeUI_Nameplates.DrawName
fnDrawGuild = ForgeUI_Nameplates.DrawGuild
fnDrawHealth = ForgeUI_Nameplates.DrawHealth
fnDrawIA = ForgeUI_Nameplates.DrawIA
fnDrawShield = ForgeUI_Nameplates.DrawShield
fnDrawAbsorb = ForgeUI_Nameplates.DrawAbsorb

fnDrawRewards = ForgeUI_Nameplates.DrawRewards
fnDrawMOOBar = ForgeUI_Nameplates.DrawMOOBar
fnDrawCastBar = ForgeUI_Nameplates.DrawCastBar
fnColorNameplate = ForgeUI_Nameplates.ColorNameplate
fnDrawIndicators = ForgeUI_Nameplates.DrawIndicators
fnDrawInfo = ForgeUI_Nameplates.DrawInfo

fnRepositionNameplate = ForgeUI_Nameplates.RepositionNameplate

-----------------------------------------------------------------------------------------------
-- ForgeUI_Nameplates Instance
-----------------------------------------------------------------------------------------------
ForgeUI_Nameplates = F:API_NewAddon(ForgeUI_Nameplates)

