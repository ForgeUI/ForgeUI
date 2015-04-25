require "Window"

local ForgeUI
local ForgeUI_Nameplates = {}

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

function ForgeUI_Nameplates:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

	self.tPreloadUnits = {}

	self.arWindowPool = {}
	self.arUnit2Nameplate = {}
	self.arWnd2Nameplate = {}

	-- mandatory 
    self.api_version = 2
	self.version = "1.0.0"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_Nameplates"
	self.strDisplayName = "Nameplates"
	
	self.wndContainers = {}
	
	self.tStylers = {
		["LoadStyle_Nameplates"] = self,
		["LoadStyle_Nameplate"] = self, -- (tNameplate)
	}
	
	-- optional
	self.settings_version = 3
    self.tSettings = {
		nMaxRange = 75,
		bUseOcclusion = true,
		bShowTitles = false,
		bOnlyImportantNPC = true,
		bShowRewards = false,
		bShowShield = true,
		bShowAbsorb = true,
		bFrequentUpdate = false,
		bShowDead = true,
		crShield = "FF0699F3",
		crAbsorb = "FFFFC600",
		crDead = "FF666666",
		crMOO = "FF7E00FF",
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
				nShowName = 0,
				nShowBars = 0,
				nShowCast = 0,
				nShowGuild = 0,
				nShowInfo = 0,
				crName = "FFFFFFFF",
				crHealth = "FF75CC26",
				bClassColors = false,
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
				crName = "FFFFFFFF",
				crHealth = "FF75CC26",
				bClassColors = true,
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
				crName = "FF43C8F3",
				crHealth = "FF75CC26",
				bClassColors = true,
			},
			HostilePlayer = {
				bEnabled = true,
				nShowName = 3,
				nShowBars = 3,
				nShowCast = 3,
				nShowGuild = 0,
				nShowInfo = 0,
				crName = "FFFF0000",
				crHealth = "FFFF0000",
				bClassColors = true,
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
				crName = "FFD9544D",
				crHealth = "FFE50000",
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
			
		},
		knNameplatePoolLimit = 500,
		knTargetRange = 16000,
	}
	
    return o
end

function ForgeUI_Nameplates:Init()
    Apollo.RegisterAddon(self, false, nil, {})
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_Nameplates OnLoad
-----------------------------------------------------------------------------------------------

function ForgeUI_Nameplates:OnLoad()
	Apollo.RegisterEventHandler("UnitCreated", 					"OnPreloadUnitCreated", self)
	
	self.xmlNameplate = XmlDoc.CreateFromFile("ForgeUI_Nameplates.xml")
	self.xmlNameplate:RegisterCallback("OptionsInit", self)
	
	self.xmlOptions = XmlDoc.CreateFromFile("ForgeUI_Options.xml")
	self.xmlOptions:RegisterCallback("OnDocLoaded", self)
end

function ForgeUI_Nameplates:ForgeAPI_AfterRegistration()
	self:NameplatesInit()

	local wndItemButton = ForgeUI.API_AddItemButton(self, "Nameplates" )
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "General", { xmlDoc = self.xmlOptions, strContainer = "Container_General", bDefault = true })
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "Target", { xmlDoc = self.xmlOptions, strContainer = "Container_Target" })
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "Player", { xmlDoc = self.xmlOptions, strContainer = "Container_Player" })
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "Friendly player", { xmlDoc = self.xmlOptions, strContainer = "Container_FriendlyPlayer" })
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "Party player", { xmlDoc = self.xmlOptions, strContainer = "Container_PartyPlayer" })
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "Hostile player", { xmlDoc = self.xmlOptions, strContainer = "Container_HostilePlayer" })
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "Friendly NPC", { xmlDoc = self.xmlOptions, strContainer = "Container_FriendlyNPC" })
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "Neutral NPC", { xmlDoc = self.xmlOptions, strContainer = "Container_NeutralNPC" })
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "Hostile NPC", { xmlDoc = self.xmlOptions, strContainer = "Container_HostileNPC" })
	
	ForgeUI.API_AddListItemToButton(self, wndItemButton, "Player's pet", { xmlDoc = self.xmlOptions, strContainer = "Container_PlayerPet" })
end

function ForgeUI_Nameplates:OnDocLoaded()
	if ForgeUI == nil then -- forgeui loaded
		ForgeUI = Apollo.GetAddon("ForgeUI")
	end
	
	ForgeUI.API_RegisterAddon(self)
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

function ForgeUI_Nameplates:UpdateAllNameplates()
	self:UpdateAllNameplateVisibility()
	self:RequestUpdateAllNameplateRewards()
	
	for idx, tNameplate in pairs(self.arUnit2Nameplate) do
		fnUpdateNameplate(self, tNameplate)
	end
end

function ForgeUI_Nameplates:UpdateNameplate(tNameplate)
	fnDrawName(self, tNameplate)
	fnDrawGuild(self, tNameplate)
	fnDrawInfo(self, tNameplate)
	fnDrawHealth(self, tNameplate)
	fnDrawCastBar(self, tNameplate)
	fnDrawIndicators(self, tNameplate)
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
		bHideQuests = not self.tSettings.bShowRewards,
		bHideChallenges = not self.tSettings.bShowRewards,
		bHideMissions = not self.tSettings.bShowRewards,
		bHidePublicEvents = not self.tSettings.bShowRewards,
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
		tNameplate.tSettings 		= self.tSettings.tUnits[tNameplate.strUnitType]
		
		self:UpdateNameplate(tNameplate)
	end
	
	tNameplate.bOnScreen = wndNameplate:IsOnScreen()
	tNameplate.bOccluded = wndNameplate:IsOccluded()
	
	local bNewShow = self:HelperVerifyVisibilityOptions(tNameplate) and self:CheckDrawDistance(tNameplate)
	
	tNameplate.eDisposition = eDisposition
	
	if bNewShow and not self.tSettings.bFrequentUpdate then
		fnDrawNameplate(self, tNameplate)
	end

	if bNewShow ~= tNameplate.bShow then
		tNameplate.bShow = bNewShow
		wndNameplate:Show(bNewShow, not bNewShow) -- removes weird glitching when occluding nameplates
	end
end

function ForgeUI_Nameplates:OnUnitCreated(unitNew) -- build main options here
	local strNewUnitType = self:GetUnitType(unitNew)
	
	if not self.tSettings.tUnits[strNewUnitType].bEnabled then return end

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
		tSettings 		= self.tSettings.tUnits[strNewUnitType],
		
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
			level = wnd:FindChild("NameRewardContainer:Level"),
			wndGuild = wnd:FindChild("Guild"),
			wndName = wnd:FindChild("NameRewardContainer:Name"),
			
			nameRewardContainer = wnd:FindChild("NameRewardContainer:RewardContainer"),
			healthMaxShield = wnd:FindChild("Container:Health:HealthBars:MaxShield"),
			healthShieldFill = wnd:FindChild("Container:Health:HealthBars:MaxShield:ShieldFill"),
			healthMaxAbsorb = wnd:FindChild("Container:Health:HealthBars:MaxAbsorb"),
			healthAbsorbFill = wnd:FindChild("Container:Health:HealthBars:MaxAbsorb:AbsorbFill"),
			healthMaxHealth = wnd:FindChild("Container:Health:HealthBars:MaxHealth"),
			healthHealthFill = wnd:FindChild("Container:Health:HealthBars:MaxHealth:HealthFill"),
			healthHealthLabel = wnd:FindChild("Container:Health:HealthLabel"),
			ia = wnd:FindChild("Container:Health:IA"),
			
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
	
	if tNameplate.wndReposition == nil then
		tNameplate.wndReposition = Apollo.LoadForm(self.xmlNameplate, "Reposition", "InWorldHudStratum", self)
		tNameplate.wndReposition:SetUnit(unitNew, 0)
	else
		tNameplate.wndReposition:SetUnit(unitNew, 0)
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
	
	self.tStylers["LoadStyle_Nameplate"]["LoadStyle_Nameplate"](tNameplate)
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
		
		self.timerPreloadUnitCreateDelay:Stop()
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
	if #self.arWindowPool < self.tSettings.knNameplatePoolLimit then
		wndNameplate:Show(false, true)
		wndNameplate:SetUnit(nil)
		table.insert(self.arWindowPool, {wndNameplate, tNameplate.wnd})
	else
		wndNameplate:Destroy()
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
			
			if self.tSettings.bFrequentUpdate then
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
	
	if unitOwner:IsDead() then
		crNameColors = self.tSettings.crDead
	end
	
	if tSettings.bClassColors then
		crBarColor = ForgeUI.tSettings.tClassColors["cr" .. krtClassEnums[unitOwner:GetClassId()]]
	end
	
	if unitOwner:IsInCCState(Unit.CodeEnumCCState.Vulnerability) then
		crBarColor = self.tSettings.crMOO
	end

	tNameplate.wnd.wndName:SetTextColor(crNameColors)
	tNameplate.wnd.wndGuild:SetTextColor(crNameColors)
	tNameplate.wnd.healthHealthFill:SetBarColor(crBarColor)
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
		local strNewName
		if self.tSettings.bShowTitles then
			strNewName = unitOwner:GetTitleOrName()
		else
			strNewName = unitOwner:GetName()
		end

		if tNameplate.strName ~= strNewName then
			wndName:SetText(strNewName)
			tNameplate.strName = strNewName

			local nNameWidth = Apollo.GetTextWidth("Nameplates", strNewName .. " ")
			local nLeft, nTop, nRight, nBottom = wndName:GetAnchorOffsets()
			wndName:SetAnchorOffsets(- (nNameWidth / 2), nTop, (nNameWidth / 2), nBottom)
			
			-- Need to consider guild as well for the resize code
			local strNewGuild = unitOwner:GetAffiliationName()
			if unitOwner:GetType() == "Player" and strNewGuild ~= nil and strNewGuild ~= "" then
				strNewGuild = String_GetWeaselString(Apollo.GetString("Nameplates_GuildDisplay"), strNewGuild)
			end
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
	
	if tNameplate.tSettings.bHideOnHealth or tNameplate.tSettings.bHideOnShield then
		local bHealth = nHealth ~= nMaxHealth and tNameplate.tSettings.bHideOnHealth
		
		local nShield = unitOwner:GetShieldCapacity()
		local nShieldMax = unitOwner:GetShieldCapacityMax()	
		
		local bShield = nShield ~= nShieldMax and tNameplate.tSettings.bHideOnShield
	
		bShow = bHealth or bShield
	end
	
	if bShow then
		self:SetBarValue(tNameplate.wnd.healthHealthFill, 0, nHealth, nMaxHealth)
		
		fnDrawIndicators(self, tNameplate)
		
		fnDrawIA(self, tNameplate)
		fnDrawShield(self, tNameplate)
		fnDrawAbsorb(self, tNameplate)
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
			ia:SetSprite("ForgeUI_IAinf")
			ia:SetText("")
		elseif nMax > 0 then
			ia:SetSprite("ForgeUI_IA")
			ia:SetText(nValue)
		end
	end
	
	if bShow ~= ia:IsShown() then
		ia:Show(bShow, true)
	end
end

function ForgeUI_Nameplates:DrawShield(tNameplate)
	local bShow = false
	
	if self.tSettings.bShowShield then
		local unitOwner = tNameplate.unitOwner
		
		local nShield = unitOwner:GetShieldCapacity()
		local nShieldMax = unitOwner:GetShieldCapacityMax()
		
		bShow = nShield ~= nil and not unitOwner:IsDead() and nShield > 0
		
		if bShow then
			self:SetBarValue(tNameplate.wnd.healthShieldFill, 0, nShield, nShieldMax)
		end
	end
	
	if bShow ~= tNameplate.wnd.healthMaxShield:IsShown() then
		tNameplate.wnd.healthMaxShield:Show(bShow, true)
		tNameplate.bShowShield = bShow
	end
end

function ForgeUI_Nameplates:DrawAbsorb(tNameplate)
	local bShow = false
	
	if self.tSettings.bShowAbsorb then
		local unitOwner = tNameplate.unitOwner
		
		local nAbsorb = unitOwner:GetAbsorptionValue()
		local nAbsorbMax = unitOwner:GetAbsorptionMax()
		
		local bShow = nAbsorb ~= nil and not unitOwner:IsDead() and nAbsorb > 0
		
		if bShow then
			self:SetBarValue(tNameplate.wnd.healthAbsorbFill, 0, nAbsorb, nAbsorbMax)
		end
	end
		
	if bShow ~= tNameplate.wnd.healthMaxAbsorb:IsShown() then
		tNameplate.wnd.healthMaxAbsorb:Show(bShow, true)
		tNameplate.bShowAbsorb = bShow
	end
end

function ForgeUI_Nameplates:DrawCastBar(tNameplate) -- Every frame
	local wndNameplate = tNameplate.wndNameplate
	local unitOwner = tNameplate.unitOwner

	-- Casting; has some onDraw parameters we need to check
	tNameplate.bIsCasting = unitOwner:ShouldShowCastBar()

	local bShow = tNameplate.bIsCasting and self:GetBooleanOption("nShowCast", tNameplate)

	local wndCastBar = tNameplate.wnd.castBar
	if bShow ~= wndCastBar:IsShown() then
		wndCastBar:Show(bShow)
	end
	
	if bShow then
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

	local bShow = self.tSettings.bShowRewards

	if bShow ~= tNameplate.wnd.questRewards:IsShown() then
		tNameplate.wnd.questRewards:Show(bShow)
	end
	
	local tRewardsData = tNameplate.wnd.questRewards:GetData()
end

function ForgeUI_Nameplates:DrawIndicators(tNameplate)
	local wnd = tNameplate.wnd
	local unitOwner = tNameplate.unitOwner

	-- target indicator
	
	local bShowTargetMarker = tNameplate.bIsTarget and self.tSettings.tUnits["Target"].bShowMarker
	if wnd.targetMarker:IsShown() ~= bShowTargetMarker then
		wnd.targetMarker:Show(bShowTargetMarker)
	end
	
	-- threat loss indicator
	
	local bShowIndicator = false
	
	if tNameplate.tSettings.bThreatIndicator then
		local unitsTarget = unitOwner:GetTarget()
		if unitsTarget and not unitsTarget:IsThePlayer() then
			bShowIndicator = true
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
	--	nShowInfo = self.tSettings.tUnits["Target"].nShowInfo
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
	
	wnd.info_level:SetText("lvl" .. tostring(unitOwner:GetLevel()))
	if unitOwner:GetType() == "Player" then
		wnd.info_class:SetSprite("ForgeUI_" .. krtClassEnums[tNameplate.unitClassID] .. "_t")
	elseif tNameplate.unitClassID ~= 6 and tNameplate.unitClassID >= 0 then
		wnd.info_class:SetSprite("ForgeUI_npc_rank_" .. krtNpcRankEnums[tNameplate.unitClassID] .. "_t")
	end 
end

function ForgeUI_Nameplates:RepositionNameplate(tNameplate)
	if tNameplate.tSettings.bReposition then
		local wndNameplate = tNameplate.wndNameplate
	
		local nX, nY = wndNameplate:GetPos()
		if nY < 0 or tNameplate.bRepositioned then
			local wndReposition = tNameplate.wndReposition
		
			local nX, nY = wndReposition:GetPos()
			if nY > 0 and tNameplate.bRepositioned then
				tNameplate.bRepositioned = false
				
				wndReposition:SetUnit(tNameplate.unitOwner, 0)
				wndNameplate:SetUnit(tNameplate.unitOwner, 1)
			elseif not tNameplate.bRepositioned then
				tNameplate.bRepositioned = true
				
				wndReposition:SetUnit(tNameplate.unitOwner, 1)
				wndNameplate:SetUnit(tNameplate.unitOwner, 0)
			end
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
		bInRange = nDistance < self.tSettings.knTargetRange
		return bInRange
	else
		bInRange = nDistance < self.tSettings.nMaxRange * self.tSettings.nMaxRange
		return bInRange
	end
end

function ForgeUI_Nameplates:HelperVerifyVisibilityOptions(tNameplate)
	local unitPlayer = self.unitPlayer
	local unitOwner = tNameplate.unitOwner
	
	local bDontShowNameplate = not tNameplate.bOnScreen or tNameplate.bGibbed or not tNameplate.bIsImportant and self.tSettings.bOnlyImportantNPC
		or (unitOwner:IsDead() and not self.tSettings.bShowDead)
	
	if bDontShowNameplate and not tNameplate.bIsTarget then
		return false
	end
	
	local eDisposition = tNameplate.eDisposition
	local tActivation = tNameplate.tActivation

	local bShowNameplate = true
	if self.tSettings.bUseOcclusion then
		bShowNameplate = not tNameplate.bOccluded or tNameplate.bIsTarget
	else
		bShowNameplate = true
	end

	--if self.tSettings.bShowMainObjectiveOnly and not bShowNameplate then
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
	elseif unit:GetType() == "Pickup" then
		if string.match(unit:GetName(), self.unitPlayer:GetName()) then
			return "Pickup"
		end
		return "PickupNotPlayer"
	elseif unit:GetHealth() == nil and not unit:IsDead() then
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

	if tNameplate.bIsTarget then
		nOption = self.tSettings.tUnits.Target[strOption]
		if nOption == nil then
			nOption = tNameplate.tSettings[strOption]
		end
	else
		nOption = tNameplate.tSettings[strOption]
	end

	if nOption == 0 then
		return false
	elseif nOption == 1 then
		if not unit:IsInCombat() then
			return true
		else
			return false
		end
	elseif nOption == 2 then
		if unit:IsInCombat() or unit:GetHealth() ~= unit:GetMaxHealth() then
			return true
		else
			return false
		end
	elseif nOption == 3 then
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
		self.tStylers["LoadStyle_Nameplate"]["LoadStyle_Nameplate"](self, tNameplate)
	end
end

function ForgeUI_Nameplates:LoadStyle_Nameplate(tNameplate)
	if not tNameplate then return end
	
	local wnd = tNameplate.wnd
	
	wnd.targetMarker:SetBGColor(self.tSettings.tUnits["Target"].crTargetMarker)
	
	wnd.healthShieldFill:SetBarColor(self.tSettings.crShield)
	wnd.healthAbsorbFill:SetBarColor(self.tSettings.crAbsorb)
	
	if tNameplate.strUnitType == "HostileNPC" then
		wnd.indicator:SetBGColor(self.tSettings.tUnits["HostileNPC"].crThreatIndicator)
	elseif tNameplate.strUnitType == "FriendlyPlayer" then
		wnd.indicator:SetBGColor(self.tSettings.tUnits["FriendlyPlayer"].crCleanseIndicator)
	elseif tNameplate.strUnitType == "PartyPlayer" then
		wnd.indicator:SetBGColor(self.tSettings.tUnits["PartyPlayer"].crCleanseIndicator)
	end
end

-----------------------------------------------------------------------------------------------
-- Nameplate Events
-----------------------------------------------------------------------------------------------

function ForgeUI_Nameplates:OnNameplateNameClick(wndHandler, wndCtrl, eMouseButton)
	if true then return end

	local tNameplate = self.arWnd2Nameplate[wndHandler:GetParent():GetId()]
	if tNameplate == nil then
		return
	end

	local unitOwner = tNameplate.unitOwner
	if GameLib.GetTargetUnit() ~= unitOwner and eMouseButton == GameLib.CodeEnumInputMouse.Left then
		GameLib.SetTargetUnit(unitOwner)
	end
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
			fnDrawHealth(self, tNameplateOther)
			fnDrawName(self, tNameplateOther)
			fnDrawGuild(self, tNameplateOther)
			fnDrawIndicators(self, tNameplateOther)
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
		fnDrawIndicators(self, tNameplate)
		fnDrawInfo(self, tNameplate)
		
		self:UpdateNameplateRewardInfo(tNameplate)
		
		fnUpdateNameplateVisibility(self, tNameplate)
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
fnDrawCastBar = ForgeUI_Nameplates.DrawCastBar
fnColorNameplate = ForgeUI_Nameplates.ColorNameplate
fnDrawIndicators = ForgeUI_Nameplates.DrawIndicators
fnDrawInfo = ForgeUI_Nameplates.DrawInfo

fnRepositionNameplate = ForgeUI_Nameplates.RepositionNameplate

-----------------------------------------------------------------------------------------------
-- ForgeUI_Nameplates Instance
-----------------------------------------------------------------------------------------------
local ForgeUI_NameplatesInst = ForgeUI_Nameplates:new()
ForgeUI_NameplatesInst:Init()
