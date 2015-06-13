-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI_MiniMap
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Window"
require "DialogSys"
require "Quest"
require "QuestLib"
require "MailSystemLib"
require "Sound"
require "GameLib"
require "Tooltip"
require "XmlDoc"
require "PlayerPathLib"
require "Unit"
require "PublicEvent"
require "PublicEventObjective"
require "FriendshipLib"
require "CraftingLib"
require "LiveEventsLib"
require "LiveEvent"

-- TODO: Distinguish markers for different nodes from each other
local kstrMiningNodeIcon = "IconSprites:Icon_MapNode_Map_Node_Mining"
local kstrRelicNodeIcon = "IconSprites:Icon_MapNode_Map_Node_Relic"
local kstrFarmingNodeIcon = "IconSprites:Icon_MapNode_Map_Node_Plant"
local kstrSurvivalNodeIcon = "IconSprites:Icon_MapNode_Map_Node_Tree"
local kstrFishingNodeIcon = "IconSprites:Icon_MapNode_Map_Node_Fishing"

local ktConColors =
{
	[Unit.CodeEnumLevelDifferentialAttribute.Grey] 		= "ff9aaea3",
	[Unit.CodeEnumLevelDifferentialAttribute.Green] 	= "ff37ff00",
	[Unit.CodeEnumLevelDifferentialAttribute.Cyan] 		= "ff46ffff",
	[Unit.CodeEnumLevelDifferentialAttribute.Blue] 		= "ff3052fc",
	[Unit.CodeEnumLevelDifferentialAttribute.White] 	= "ffffffff",
	[Unit.CodeEnumLevelDifferentialAttribute.Yellow] 	= "ffffd400",
	[Unit.CodeEnumLevelDifferentialAttribute.Orange] 	= "ffff6a00",
	[Unit.CodeEnumLevelDifferentialAttribute.Red] 		= "ffff0000",
	[Unit.CodeEnumLevelDifferentialAttribute.Magenta] 	= "fffb00ff",
}

local ktPvPZoneTypes =
{
	[GameLib.CodeEnumZonePvpRules.None] 					= "",
	[GameLib.CodeEnumZonePvpRules.ExileStronghold]			= Apollo.GetString("MiniMap_Exile"),
	[GameLib.CodeEnumZonePvpRules.DominionStronghold] 		= Apollo.GetString("MiniMap_Dominion"),
	[GameLib.CodeEnumZonePvpRules.Sanctuary] 				= Apollo.GetString("MiniMap_Sanctuary"),
	[GameLib.CodeEnumZonePvpRules.Pvp] 						= Apollo.GetString("MiniMap_PvP"),
	[GameLib.CodeEnumZonePvpRules.ExilePVPStronghold] 		= Apollo.GetString("MiniMap_Exile"),
	[GameLib.CodeEnumZonePvpRules.DominionPVPStronghold] 	= Apollo.GetString("MiniMap_Dominion"),
}

local ktTooltipCategories =
{
	QuestNPC = 1,
	TrackedQuest = 2,
	GroupMember = 3,
	NeutralNPC = 4,
	HostileNPC = 5,
	Path = 6,
	Challenge = 7,
	PublicEvent = 8,
	Tradeskill = 9,
	Vendor = 10,
	Service = 11,
	Portal = 12,
	BindPoint = 13,
	Mining = 14,
	Relic = 15,
	Survivalist = 16,
	Farming = 17,
	Friend = 18,
	Rival = 19,
	Taxi = 20,
	CityDirection = 21,
	Other = 22,
	PvPMarker = 23,
}

local ktCategoryNames =
{
	[ktTooltipCategories.QuestNPC]		= Apollo.GetString("MiniMap_QuestNPCs"),
	[ktTooltipCategories.TrackedQuest] 	= Apollo.GetString("MiniMap_QuestObjectives"),
	[ktTooltipCategories.GroupMember]	= Apollo.GetString("MiniMap_GroupMembers"),
	[ktTooltipCategories.NeutralNPC] 	= Apollo.GetString("MiniMap_NeutralNPCs"),
	[ktTooltipCategories.HostileNPC] 	= Apollo.GetString("MiniMap_HostileNPCs"),
	[ktTooltipCategories.Path] 			= Apollo.GetString("MiniMap_PathMissions"),
	[ktTooltipCategories.Challenge] 	= Apollo.GetString("MiniMap_Challenges"),	
	[ktTooltipCategories.PublicEvent] 	= Apollo.GetString("ZoneMap_PublicEvent"),
	[ktTooltipCategories.Tradeskill] 	= Apollo.GetString("MiniMap_Tradeskills"),
	[ktTooltipCategories.Vendor] 		= Apollo.GetString("MiniMap_Vendors"),
	[ktTooltipCategories.Service] 		= Apollo.GetString("MiniMap_Services"),
	[ktTooltipCategories.Portal] 		= Apollo.GetString("MiniMap_InstancePortals"),
	[ktTooltipCategories.BindPoint] 	= Apollo.GetString("MiniMap_BindPoints"),
	[ktTooltipCategories.Mining] 		= Apollo.GetString("ZoneMap_MiningNodes"),
	[ktTooltipCategories.Relic] 		= Apollo.GetString("ZoneMap_RelicHunterNodes"),
	[ktTooltipCategories.Survivalist] 	= Apollo.GetString("ZoneMap_SurvivalistNodes"),
	[ktTooltipCategories.Farming] 		= Apollo.GetString("ZoneMap_FarmingNodes"),
	[ktTooltipCategories.Friend] 		= Apollo.GetString("MiniMap_Friends"),
	[ktTooltipCategories.Rival] 		= Apollo.GetString("MiniMap_Rivals"),
	[ktTooltipCategories.Taxi] 			= Apollo.GetString("ZoneMap_Taxis"),
	[ktTooltipCategories.CityDirection] = Apollo.GetString("ZoneMap_CityDirections"),
	[ktTooltipCategories.PvPMarker]		= Apollo.GetString("MiniMap_PvPObjective"),
}

local ktTypeToCategory = {
	[ktTooltipCategories.QuestNPC]		= "Quests",
	[ktTooltipCategories.TrackedQuest]	= "Tracked",
	[ktTooltipCategories.NeutralNPC]		= "CreaturesN",
	[ktTooltipCategories.HostileNPC]		= "CreaturesH",
	[ktTooltipCategories.GroupMember] = "GroupMember",
	[ktTooltipCategories.Path]			= "Missions",
	[ktTooltipCategories.Challenge]		= "Challenges",
	[ktTooltipCategories.PublicEvent]		= "PublicEvents",
	[ktTooltipCategories.Tradeskill]		= "Tradeskills",
	[ktTooltipCategories.Vendor]			= "Vendors",
	[ktTooltipCategories.Service]			= "Services",
	[ktTooltipCategories.Portal]			= "InstancePortals",
	[ktTooltipCategories.BindPoint]		= "BindPoints",
	[ktTooltipCategories.Mining]			= "MiningNodes",
	[ktTooltipCategories.Relic]			= "RelicNodes",
	[ktTooltipCategories.Survivalist]		= "SurvivalistNodes",
	[ktTooltipCategories.Farming]			= "FarmingNodes",
	[ktTooltipCategories.Friend]			= "Friends",
	[ktTooltipCategories.Rival]			= "Rivals",
	[ktTooltipCategories.Taxi]			= "Taxis",
	[ktTooltipCategories.CityDirection]	= "CityDirections",
}

local ktUIElementToType =
{
	["OptionsBtnQuests"] 			= ktTooltipCategories.QuestNPC,
	["OptionsBtnTracked"] 			= ktTooltipCategories.TrackedQuest,
	["OptionsBtnCreaturesN"] 		= ktTooltipCategories.NeutralNPC,
	["OptionsBtnCreaturesH"] 		= ktTooltipCategories.HostileNPC,
	["OptionsBtnGroupMember"]		= ktTooltipCategories.GroupMember,
	["OptionsBtnMissions"] 			= ktTooltipCategories.Path,
	["OptionsBtnChallenges"] 		= ktTooltipCategories.Challenge,
	["OptionsBtnPublicEvents"] 		= ktTooltipCategories.PublicEvent,
	["OptionsBtnTradeskills"] 		= ktTooltipCategories.Tradeskill,
	["OptionsBtnVendors"] 			= ktTooltipCategories.Vendor,
	["OptionsBtnServices"] 			= ktTooltipCategories.Service,
	["OptionsBtnInstancePortals"] 	= ktTooltipCategories.Portal,
	["OptionsBtnBindPoints"] 		= ktTooltipCategories.BindPoint,
	["OptionsBtnMiningNodes"] 		= ktTooltipCategories.Mining,
	["OptionsBtnRelicNodes"] 		= ktTooltipCategories.Relic,
	["OptionsBtnSurvivalistNodes"] 	= ktTooltipCategories.Survivalist,
	["OptionsBtnFarmingNodes"] 		= ktTooltipCategories.Farming,
	["OptionsBtnFriends"]			= ktTooltipCategories.Friend,
	["OptionsBtnRivals"] 			= ktTooltipCategories.Rival,
	["OptionsBtnTaxis"] 			= ktTooltipCategories.Taxi,
	["OptionsBtnCityDirections"] 	= ktTooltipCategories.CityDirection,	
}

local ktInstanceSettingTypeStrings =
{
	Veteran = Apollo.GetString("MiniMap_Veteran"),
	Rallied = Apollo.GetString("MiniMap_Rallied"),
}

local knSaveVersion = 4

local ForgeUI
local ForgeUI_MiniMap = {}

function ForgeUI_MiniMap:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	o.tQueuedUnits = {}
	
	self.api_version = 2
	self.version = "1.0.0"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_MiniMap"
	self.strDisplayName = "MiniMap"
	
	self.wndContainers = {}
	
	self.tStylers = {
		["LoadStyle_MiniMap"] = self,
	}
	
	-- optional
	self.settings_version = 1
    self.tSettings = {
		nZoomLevel = 1,
		tCategories = {
			Quests 			= true,
			Tracked 		= true,
			CreaturesN 		= true,
			CreaturesH 		= true,
			GroupMember		= true,
			Missions 		= false,
			Challenges 		= false,
			PublicEvents 	= true,
			Tradeskills 	= true,
			Vendors 		= true,
			Services 		= true,
			InstancePortals = true,
			BindPoints 		= true,
			MiningNodes 	= true,
			RelicNodes 		= true,
			SurvivalistNodes = true,
			FarmingNodes 	= true,
			Friends			= true,
			Rivals 			= true,
			Taxis			= true,
			CityDirections 	= true,
		}
	}

	return o
end

function ForgeUI_MiniMap:CreateOverlayObjectTypes()
	self.eObjectTypeInstancePortal 		= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypePublicEvent			= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypePublicEventKill		= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeChallenge			= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypePing				= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeCityDirections		= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeHazard 				= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeQuestReward 		= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeQuestReceiving 		= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeQuestNew 			= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeQuestNewSoon 		= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeQuestTarget 		= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeQuestKill	 		= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeTradeskills 		= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeVendor 				= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeAuctioneer 			= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeCommodity 			= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeBindPointActive 	= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeBindPointInactive 	= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeMiningNode 			= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeRelicHunterNode 	= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeSurvivalistNode 	= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeFarmingNode 		= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeFishingNode 		= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeVendorFlight 		= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeFlightPathNew		= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeFlightPath			= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeNeutral	 			= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeHostile	 			= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeFriend	 			= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeRival	 			= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeTrainer	 			= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeGroupMember			= self.wndMiniMap:CreateOverlayType()
	self.eObjectPvPMarkers				= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeCREDDExchange		= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeCostume				= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeBank				= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeGuildBank			= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeGuildRegistrar		= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeMail				= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeServices			= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeConvert				= self.wndMiniMap:CreateOverlayType()
end



function ForgeUI_MiniMap:BuildCustomMarkerInfo()
	self.tMinimapMarkerInfo =
	{
		PvPBlueCarry			= { nOrder = 100,	objectType = self.eObjectPvPMarkers,			strIcon = "IconSprites:Icon_MapNode_Map_PvP_ExileCarry",	bFixedSizeMedium = true	},
		PvPRedCarry		= { nOrder = 100,	objectType = self.eObjectPvPMarkers,			strIcon = "IconSprites:Icon_MapNode_Map_PvP_DominionCarry",	bFixedSizeMedium = true	},
		PvPNeutralCarry			= { nOrder = 100,	objectType = self.eObjectPvPMarkers,			strIcon = "IconSprites:Icon_MapNode_Map_PvP_NeutralCarry",	bFixedSizeMedium = true	},
		PvPBlueCap1			= { nOrder = 100,	objectType = self.eObjectPvPMarkers,			strIcon = "IconSprites:Icon_MapNode_Map_PvP_ExileCap",		bFixedSizeMedium = true	},
		PvPRedCap1			= { nOrder = 100,	objectType = self.eObjectPvPMarkers,			strIcon = "IconSprites:Icon_MapNode_Map_PvP_DominionCap",	bFixedSizeMedium = true	},
		PvPNeutralCap1			= { nOrder = 100,	objectType = self.eObjectPvPMarkers,			strIcon = "IconSprites:Icon_MapNode_Map_PvP_NeutralCap",	bFixedSizeMedium = true	},
		PvPBlueCap2			= { nOrder = 100,	objectType = self.eObjectPvPMarkers,			strIcon = "IconSprites:Icon_MapNode_Map_PvP_ExileCap",		bFixedSizeMedium = true	},
		PvPRedCap2			= { nOrder = 100,	objectType = self.eObjectPvPMarkers,			strIcon = "IconSprites:Icon_MapNode_Map_PvP_DominionCap",	bFixedSizeMedium = true	},
		PvPNeutralCap2			= { nOrder = 100,	objectType = self.eObjectPvPMarkers,			strIcon = "IconSprites:Icon_MapNode_Map_PvP_NeutralCap",	bFixedSizeMedium = true	},
		PvPBattleAlert			= { nOrder = 100,	objectType = self.eObjectPvPMarkers,			strIcon = "IconSprites:Icon_MapNode_Map_PvP_BattleAlert",	bFixedSizeMedium = true	},
		IronNode				= { nOrder = 100, 	objectType = self.eObjectTypeMiningNode,		strIcon = kstrMiningNodeIcon,	crObject = kcrMiningNode, 	crEdge = kcrMiningNode },
		TitaniumNode			= { nOrder = 100, 	objectType = self.eObjectTypeMiningNode,		strIcon = kstrMiningNodeIcon,	crObject = kcrMiningNode, 	crEdge = kcrMiningNode },
		ZephyriteNode			= { nOrder = 100, 	objectType = self.eObjectTypeMiningNode,		strIcon = kstrMiningNodeIcon,	crObject = kcrMiningNode, 	crEdge = kcrMiningNode },
		PlatinumNode			= { nOrder = 100, 	objectType = self.eObjectTypeMiningNode,		strIcon = kstrMiningNodeIcon,	crObject = kcrMiningNode, 	crEdge = kcrMiningNode },
		HydrogemNode			= { nOrder = 100, 	objectType = self.eObjectTypeMiningNode,		strIcon = kstrMiningNodeIcon,	crObject = kcrMiningNode, 	crEdge = kcrMiningNode },
		XenociteNode			= { nOrder = 100, 	objectType = self.eObjectTypeMiningNode,		strIcon = kstrMiningNodeIcon,	crObject = kcrMiningNode, 	crEdge = kcrMiningNode },
		ShadeslateNode			= { nOrder = 100, 	objectType = self.eObjectTypeMiningNode,		strIcon = kstrMiningNodeIcon,	crObject = kcrMiningNode, 	crEdge = kcrMiningNode },
		GalactiumNode			= { nOrder = 100, 	objectType = self.eObjectTypeMiningNode,		strIcon = kstrMiningNodeIcon,	crObject = kcrMiningNode, 	crEdge = kcrMiningNode },
		NovaciteNode			= { nOrder = 100, 	objectType = self.eObjectTypeMiningNode,		strIcon = kstrMiningNodeIcon,	crObject = kcrMiningNode, 	crEdge = kcrMiningNode },
		StandardRelicNode		= { nOrder = 100, 	objectType = self.eObjectTypeRelicHunterNode,	strIcon = kstrRelicNodeIcon, 	crObject = kcrRelicNode, 	crEdge = kcrRelicNode },
		AcceleratedRelicNode	= { nOrder = 100, 	objectType = self.eObjectTypeRelicHunterNode,	strIcon = kstrRelicNodeIcon, 	crObject = kcrRelicNode, 	crEdge = kcrRelicNode },
		AdvancedRelicNode		= { nOrder = 100, 	objectType = self.eObjectTypeRelicHunterNode,	strIcon = kstrRelicNodeIcon, 	crObject = kcrRelicNode, 	crEdge = kcrRelicNode },
		DynamicRelicNode		= { nOrder = 100, 	objectType = self.eObjectTypeRelicHunterNode,	strIcon = kstrRelicNodeIcon, 	crObject = kcrRelicNode, 	crEdge = kcrRelicNode },
		KineticRelicNode		= { nOrder = 100, 	objectType = self.eObjectTypeRelicHunterNode,	strIcon = kstrRelicNodeIcon, 	crObject = kcrRelicNode, 	crEdge = kcrRelicNode },
		SpirovineNode			= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		BladeleafNode			= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		YellowbellNode			= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		PummelgranateNode		= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		SerpentlilyNode			= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		GoldleafNode			= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		HoneywheatNode			= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		CrowncornNode			= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		CoralscaleNode			= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		LogicleafNode			= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		StoutrootNode			= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		GlowmelonNode			= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		FaerybloomNode			= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode,	crEdge = kcrFarmingNode },
		WitherwoodNode			= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode,	crEdge = kcrFarmingNode },
		FlamefrondNode			= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		GrimgourdNode			= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		MourningstarNode		= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		BloodbriarNode			= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		OctopodNode				= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		HeartichokeNode			= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		SmlGrowthshroomNode		= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		MedGrowthshroomNode		= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		LrgGrowthshroomNode		= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		SmlHarvestshroomNode	= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		MedHarvestshroomNode	= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		LrgHarvestshroomNode	= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		SmlRenewshroomNode		= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		MedRenewshroomNode		= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		LrgRenewshroomNode		= { nOrder = 100, 	objectType = self.eObjectTypeFarmingNode,		strIcon = kstrFarmingNodeIcon, 	crObject = kcrFarmingNode, 	crEdge = kcrFarmingNode },
		AlgorocTreeNode			= { nOrder = 100, 	objectType = self.eObjectTypeSurvivalistNode,	strIcon = kstrSurvivalNodeIcon,	crObject = kcrSurvivalNode, crEdge = kcrSurvivalNode },
		CelestionTreeNode		= { nOrder = 100, 	objectType = self.eObjectTypeSurvivalistNode,	strIcon = kstrSurvivalNodeIcon,	crObject = kcrSurvivalNode, crEdge = kcrSurvivalNode },
		DeraduneTreeNode		= { nOrder = 100, 	objectType = self.eObjectTypeSurvivalistNode,	strIcon = kstrSurvivalNodeIcon,	crObject = kcrSurvivalNode, crEdge = kcrSurvivalNode },
		EllevarTreeNode			= { nOrder = 100, 	objectType = self.eObjectTypeSurvivalistNode,	strIcon = kstrSurvivalNodeIcon,	crObject = kcrSurvivalNode, crEdge = kcrSurvivalNode },
		GalerasTreeNode			= { nOrder = 100, 	objectType = self.eObjectTypeSurvivalistNode,	strIcon = kstrSurvivalNodeIcon,	crObject = kcrSurvivalNode, crEdge = kcrSurvivalNode },
		AuroriaTreeNode			= { nOrder = 100, 	objectType = self.eObjectTypeSurvivalistNode,	strIcon = kstrSurvivalNodeIcon,	crObject = kcrSurvivalNode, crEdge = kcrSurvivalNode },
		WhitevaleTreeNode		= { nOrder = 100, 	objectType = self.eObjectTypeSurvivalistNode,	strIcon = kstrSurvivalNodeIcon,	crObject = kcrSurvivalNode, crEdge = kcrSurvivalNode },
		DreadmoorTreeNode		= { nOrder = 100, 	objectType = self.eObjectTypeSurvivalistNode,	strIcon = kstrSurvivalNodeIcon,	crObject = kcrSurvivalNode, crEdge = kcrSurvivalNode },
		FarsideTreeNode			= { nOrder = 100, 	objectType = self.eObjectTypeSurvivalistNode,	strIcon = kstrSurvivalNodeIcon,	crObject = kcrSurvivalNode, crEdge = kcrSurvivalNode },
		CoralusTreeNode			= { nOrder = 100, 	objectType = self.eObjectTypeSurvivalistNode,	strIcon = kstrSurvivalNodeIcon,	crObject = kcrSurvivalNode, crEdge = kcrSurvivalNode },
		MurkmireTreeNode		= { nOrder = 100, 	objectType = self.eObjectTypeSurvivalistNode,	strIcon = kstrSurvivalNodeIcon,	crObject = kcrSurvivalNode, crEdge = kcrSurvivalNode },
		WilderrunTreeNode		= { nOrder = 100, 	objectType = self.eObjectTypeSurvivalistNode,	strIcon = kstrSurvivalNodeIcon,	crObject = kcrSurvivalNode, crEdge = kcrSurvivalNode },
		MalgraveTreeNode		= { nOrder = 100, 	objectType = self.eObjectTypeSurvivalistNode,	strIcon = kstrSurvivalNodeIcon,	crObject = kcrSurvivalNode, crEdge = kcrSurvivalNode },
		HalonRingTreeNode		= { nOrder = 100, 	objectType = self.eObjectTypeSurvivalistNode,	strIcon = kstrSurvivalNodeIcon,	crObject = kcrSurvivalNode, crEdge = kcrSurvivalNode },
		GrimvaultTreeNode		= { nOrder = 100, 	objectType = self.eObjectTypeSurvivalistNode,	strIcon = kstrSurvivalNodeIcon,	crObject = kcrSurvivalNode, crEdge = kcrSurvivalNode },
		SchoolOfFishNode		= { nOrder = 100, 	objectType = self.eObjectTypeFishingNode,		strIcon = kstrFishingNodeIcon,	crObject = kcrFishingNode,	crEdge = kcrFishingNode },
		Friend					= { nOrder = 2, 	objectType = self.eObjectTypeFriend, 			strIcon = "IconSprites:Icon_Windows_UI_CRB_Friend",	bNeverShowOnEdge = true, bShown, bFixedSizeMedium = true },
		Rival					= { nOrder = 3, 	objectType = self.eObjectTypeRival, 			strIcon = "IconSprites:Icon_MapNode_Map_Rival", 	bNeverShowOnEdge = true, bShown, bFixedSizeMedium = true },
		Trainer					= { nOrder = 4, 	objectType = self.eObjectTypeTrainer, 			strIcon = "IconSprites:Icon_MapNode_Map_Trainer", 	bNeverShowOnEdge = true, bFixedSizeMedium = true },
		QuestKill				= { nOrder = 5, 	objectType = self.eObjectTypeQuestKill, 		strIcon = "sprMM_TargetCreature", 	bNeverShowOnEdge = true, bFixedSizeMedium = true },
		QuestTarget				= { nOrder = 6,		objectType = self.eObjectTypeQuestTarget, 		strIcon = "sprMM_TargetObjective", 	bNeverShowOnEdge = true, bFixedSizeMedium = true },
		PublicEventKill			= { nOrder = 7,		objectType = self.eObjectTypePublicEventKill, 	strIcon = "sprMM_TargetCreature", 	bNeverShowOnEdge = true, bFixedSizeMedium = true },
		PublicEventTarget		= { nOrder = 8,		objectType = self.eObjectTypePublicEventTarget, strIcon = "sprMM_TargetObjective", 	bNeverShowOnEdge = true, bFixedSizeMedium = true },
		QuestReward				= { nOrder = 9,		objectType = self.eObjectTypeQuestReward, 		strIcon = "sprMM_QuestCompleteUntracked", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestRewardSoldier		= { nOrder = 10,	objectType = self.eObjectTypeQuestReward, 		strIcon = "IconSprites:Icon_MapNode_Map_Soldier_Accepted", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestRewardSettler		= { nOrder = 11,	objectType = self.eObjectTypeQuestReward, 		strIcon = "IconSprites:Icon_MapNode_Map_Settler_Accepted", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestRewardScientist	= { nOrder = 12,	objectType = self.eObjectTypeQuestReward, 		strIcon = "IconSprites:Icon_MapNode_Map_Scientist_Accepted", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestRewardExplorer		= { nOrder = 13,	objectType = self.eObjectTypeQuestReward, 		strIcon = "IconSprites:Icon_MapNode_Map_Explorer_Accepted", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestNew				= { nOrder = 14,	objectType = self.eObjectTypeQuestNew, 			strIcon = "IconSprites:Icon_MapNode_Map_Quest", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestNewDaily			= { nOrder = 14,	objectType = self.eObjectTypeQuestNew, 			strIcon = "IconSprites:Icon_MapNode_Map_Quest", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestNewSoldier			= { nOrder = 15,	objectType = self.eObjectTypeQuestNew, 			strIcon = "IconSprites:Icon_MapNode_Map_Soldier", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestNewSettler			= { nOrder = 16,	objectType = self.eObjectTypeQuestNew, 			strIcon = "IconSprites:Icon_MapNode_Map_Settler", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestNewScientist		= { nOrder = 17,	objectType = self.eObjectTypeQuestNew, 			strIcon = "IconSprites:Icon_MapNode_Map_Scientist", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestNewExplorer		= { nOrder = 18,	objectType = self.eObjectTypeQuestNew, 			strIcon = "IconSprites:Icon_MapNode_Map_Explorer", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestNewMain			= { nOrder = 19,	objectType = self.eObjectTypeQuestNew, 			strIcon = "IconSprites:Icon_MapNode_Map_Quest", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestNewMainSoldier		= { nOrder = 20,	objectType = self.eObjectTypeQuestNew, 			strIcon = "IconSprites:Icon_MapNode_Map_Soldier", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestNewMainSettler		= { nOrder = 21,	objectType = self.eObjectTypeQuestNew, 			strIcon = "IconSprites:Icon_MapNode_Map_Settler", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestNewMainScientist	= { nOrder = 22,	objectType = self.eObjectTypeQuestNew, 			strIcon = "IconSprites:Icon_MapNode_Map_Scientist", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestNewMainExplorer	= { nOrder = 23,	objectType = self.eObjectTypeQuestNew, 			strIcon = "IconSprites:Icon_MapNode_Map_Explorer", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestNewRepeatable		= { nOrder = 24,	objectType = self.eObjectTypeQuestNew, 			strIcon = "IconSprites:Icon_MapNode_Map_Quest", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestNewRepeatableSoldier	= { nOrder = 25,	objectType = self.eObjectTypeQuestNew, 			strIcon = "IconSprites:Icon_MapNode_Map_Soldier", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestNewRepeatableSettler	= { nOrder = 26,	objectType = self.eObjectTypeQuestNew, 			strIcon = "IconSprites:Icon_MapNode_Map_Settler", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestNewRepeatableScientist	= { nOrder = 27,objectType = self.eObjectTypeQuestNew, 			strIcon = "IconSprites:Icon_MapNode_Map_Scientist", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestNewRepeatableExplorer	= { nOrder = 28,	objectType = self.eObjectTypeQuestNew, 			strIcon = "IconSprites:Icon_MapNode_Map_Explorer", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestReceiving			= { nOrder = 29,	objectType = self.eObjectTypeQuestReceiving, 	strIcon = "sprMM_QuestCompleteOngoing", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestReceivingSoldier	= { nOrder = 30,	objectType = self.eObjectTypeQuestReceiving, 	strIcon = "IconSprites:Icon_MapNode_Map_Soldier", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestReceivingSettler	= { nOrder = 31,	objectType = self.eObjectTypeQuestReceiving, 	strIcon = "IconSprites:Icon_MapNode_Map_Settler", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestReceivingScientist	= { nOrder = 32,	objectType = self.eObjectTypeQuestReceiving, 	strIcon = "IconSprites:Icon_MapNode_Map_Scientist", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestReceivingExplorer	= { nOrder = 33,	objectType = self.eObjectTypeQuestReceiving, 	strIcon = "IconSprites:Icon_MapNode_Map_Explorer", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestNewSoon			= { nOrder = 34,	objectType = self.eObjectTypeQuestNewSoon, 		strIcon = "IconSprites:Icon_MapNode_Map_Quest_Disabled", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestNewMainSoon		= { nOrder = 35,	objectType = self.eObjectTypeQuestNewSoon, 		strIcon = "IconSprites:Icon_MapNode_Map_Quest_Disabled", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestNewTradeskill		= { nOrder = 36,	objectType = self.eObjectTypeQuestNewSoon, 		strIcon = "IconSprites:Icon_MapNode_Map_Quest_Tradeskill", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestGivingTradeskill	= { nOrder = 36,	objectType = self.eObjectTypeQuestNewSoon, 		strIcon = "IconSprites:Icon_MapNode_Map_Quest_Tradeskill", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		QuestReceivingTradeskill	= { nOrder = 36,	objectType = self.eObjectTypeQuestNewSoon, 	strIcon = "IconSprites:Icon_MapNode_Map_Quest_Tradeskill", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		ConvertItem				= { nOrder = 37,	objectType = self.eObjectTypeConvert, 			strIcon = "IconSprites:Icon_MapNode_Map_Vendor_ResourceConversion", 	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		ConvertRep				= { nOrder = 38,	objectType = self.eObjectTypeConvert, 			strIcon = "IconSprites:Icon_MapNode_Map_Vendor_Reputation", 	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		Vendor					= { nOrder = 39,	objectType = self.eObjectTypeVendor, 			strIcon = "IconSprites:Icon_MapNode_Map_Vendor", 	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		Mail					= { nOrder = 40,	objectType = self.eObjectTypeMail, 				strIcon = "IconSprites:Icon_MapNode_Map_Mailbox", 	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		CityDirections			= { nOrder = 41,	objectType = self.eObjectTypeCityDirections, 	strIcon = "IconSprites:Icon_MapNode_Map_CityDirections", 	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		Dye						= { nOrder = 42,	objectType = self.eObjectTypeCostume, 			strIcon = "IconSprites:Icon_MapNode_Map_DyeSpecialist", 	bNeverShowOnEdge = true, bFixedSizeMedium = true },
		FlightPathSettler		= { nOrder = 43,	objectType = self.eObjectTypeVendorFlight, 		strIcon = "IconSprites:Icon_MapNode_Map_Vendor_Flight", 	bNeverShowOnEdge = true, bFixedSizeMedium = true },
		FlightPath				= { nOrder = 44,	objectType = self.eObjectTypeFlightPath, 		strIcon = "IconSprites:Icon_MapNode_Map_Taxi", bNeverShowOnEdge = true, bFixedSizeMedium = true },
		FlightPathNew			= { nOrder = 45,	objectType = self.eObjectTypeFlightPathNew, 	strIcon = "IconSprites:Icon_MapNode_Map_Taxi_Undiscovered", 	bNeverShowOnEdge = true, bFixedSizeMedium = true },
		TalkTo					= { nOrder = 46,	objectType = self.eObjectTypeQuestTarget, 		strIcon = "IconSprites:Icon_MapNode_Map_Chat", 	bNeverShowOnEdge = true, bFixedSizeMedium = true },
		InstancePortal			= { nOrder = 47,	objectType = self.eObjectTypeInstancePortal, 	strIcon = "IconSprites:Icon_MapNode_Map_Portal", 	bNeverShowOnEdge = true },
		BindPoint				= { nOrder = 48,	objectType = self.eObjectTypeBindPointInactive, strIcon = "IconSprites:Icon_MapNode_Map_Gate", 	bNeverShowOnEdge = true },
		BindPointCurrent		= { nOrder = 48,	objectType = self.eObjectTypeBindPointActive, 	strIcon = "IconSprites:Icon_MapNode_Map_Gate", 	bNeverShowOnEdge = true },
		TradeskillTrainer		= { nOrder = 50,	objectType = self.eObjectTypeTradeskills, 		strIcon = "IconSprites:Icon_MapNode_Map_Tradeskill", 	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		CraftingStation			= { nOrder = 51,	objectType = self.eObjectTypeTradeskills, 		strIcon = "IconSprites:Icon_MapNode_Map_Tradeskill", 	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		CommodityMarketplace	= { nOrder = 52,	objectType = self.eObjectTypeCommodity, 		strIcon = "IconSprites:Icon_MapNode_Map_CommoditiesExchange", bNeverShowOnEdge = true, bHideIfHostile = true },
		ItemAuctionhouse		= { nOrder = 53,	objectType = self.eObjectTypeAuctioneer, 		strIcon = "IconSprites:Icon_MapNode_Map_AuctionHouse", 	bNeverShowOnEdge = true, bHideIfHostile = true },
		SettlerImprovement		= { nOrder = 54,	objectType = GameLib.CodeEnumMapOverlayType.PathObjective, strIcon = "CRB_MinimapSprites:sprMM_SmallIconSettler", bNeverShowOnEdge = true },
		CREDDExchange			= { nOrder = 55,	objectType = self.eObjectTypeCREDDExchange,		strIcon = "IconSprites:Icon_MapNode_Map_CREED",	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		Neutral					= { nOrder = 151,	objectType = self.eObjectTypeNeutral, 			strIcon = "ClientSprites:MiniMapMarkerTiny", 	bNeverShowOnEdge = true, bShown = false, crObject = ApolloColor.new("xkcdBrightYellow") },
		Hostile					= { nOrder = 150,	objectType = self.eObjectTypeHostile, 			strIcon = "ClientSprites:MiniMapMarkerTiny", 	bNeverShowOnEdge = true, bShown = false, crObject = ApolloColor.new("xkcdBrightRed") },
		GroupMember				= { nOrder = 1,		objectType = self.eObjectTypeGroupMember, 		strIcon = "IconSprites:Icon_MapNode_Map_GroupMember", bFixedSizeLarge = true, strIconEdge = "CRB_MinimapSprites:sprMM_PartyMemberArrow", crEdge = CColor.new(1, 1, 1, 1), bNeverShowOnEdge = false },
		Bank					= { nOrder = 55,	objectType = self.eObjectTypeBank, 				strIcon = "IconSprites:Icon_MapNode_Map_Bank", 	bNeverShowOnEdge = true, bFixedSizeLarge = true, bHideIfHostile = true },
		GuildBank				= { nOrder = 57,	objectType = self.eObjectTypeGuildBank, 		strIcon = "IconSprites:Icon_MapNode_Map_Bank", 	bNeverShowOnEdge = true, bFixedSizeLarge = true, crObject = ApolloColor.new("yellow"), bHideIfHostile = true },
		GuildRegistrar			= { nOrder = 56,	objectType = self.eObjectTypeGuildRegistrar, 	strIcon = "CRB_MinimapSprites:sprMM_Group", bNeverShowOnEdge = true, bFixedSizeLarge = true, crObject = ApolloColor.new("yellow"), bHideIfHostile = true },
		VendorGeneral			= { nOrder = 39,	objectType = self.eObjectTypeVendor,			strIcon = "IconSprites:Icon_MapNode_Map_Vendor",	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		VendorArmor				= { nOrder = 39,	objectType = self.eObjectTypeVendor, 			strIcon = "IconSprites:Icon_MapNode_Map_Vendor_Armor",	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		VendorConsumable		= { nOrder = 39,	objectType = self.eObjectTypeVendor, 			strIcon = "IconSprites:Icon_MapNode_Map_Vendor_Consumable",	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		VendorElderGem			= { nOrder = 39,	objectType = self.eObjectTypeVendor, 			strIcon = "IconSprites:Icon_MapNode_Map_Vendor_ElderGem",	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		VendorHousing			= { nOrder = 39,	objectType = self.eObjectTypeVendor, 			strIcon = "IconSprites:Icon_MapNode_Map_Vendor_Housing",	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		VendorMount				= { nOrder = 39,	objectType = self.eObjectTypeVendor, 			strIcon = "IconSprites:Icon_MapNode_Map_Vendor_Mount",	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		VendorRenown			= { nOrder = 39,	objectType = self.eObjectTypeVendor, 			strIcon = "IconSprites:Icon_MapNode_Map_Vendor_Renown",	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		VendorReputation		= { nOrder = 39,	objectType = self.eObjectTypeVendor, 			strIcon = "IconSprites:Icon_MapNode_Map_Vendor_Reputation",	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		VendorResourceConversion= { nOrder = 39,	objectType = self.eObjectTypeVendor, 			strIcon = "IconSprites:Icon_MapNode_Map_Vendor_ResourceConversion",	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		VendorTradeskill		= { nOrder = 39,	objectType = self.eObjectTypeVendor,			strIcon = "IconSprites:Icon_MapNode_Map_Vendor_Tradeskill",	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		VendorWeapon			= { nOrder = 39,	objectType = self.eObjectTypeVendor,			strIcon = "IconSprites:Icon_MapNode_Map_Vendor_Weapon",		bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		VendorPvPArena			= { nOrder = 39,	objectType = self.eObjectTypeVendor,			strIcon = "IconSprites:Icon_MapNode_Map_Vendor_Prestige_Arena",	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		VendorPvPBattlegrounds	= { nOrder = 39,	objectType = self.eObjectTypeVendor,			strIcon = "IconSprites:Icon_MapNode_Map_Vendor_Prestige_Battlegrounds",	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		VendorPvPWarplots		= { nOrder = 39,	objectType = self.eObjectTypeVendor,			strIcon = "IconSprites:Icon_MapNode_Map_Vendor_Prestige_Warplot",	bNeverShowOnEdge = true, bFixedSizeMedium = true, bHideIfHostile = true },
		ContractBoard			= { nOrder = 14,	objectType = self.eObjectTypeQuestNew, 			strIcon = "IconSprites:Icon_MapNode_Map_Contracts", 	bNeverShowOnEdge = true, bHideIfHostile = true },
	}
end

function ForgeUI_MiniMap:Init()
	Apollo.RegisterAddon(self)
end

function ForgeUI_MiniMap:OnLoad()
	Apollo.RegisterEventHandler("UnitCreated", 							"OnUnitCreated", self)

	self.bRotate = false
	self.tChallengeObjects 			= {}
	self.ChallengeFlashingIconId 	= nil
	self.tUnitsShown 				= {}	-- For Quests, PublicEvents, Vendors, Instance Portals, and Bind Points which all use UnitCreated/UnitDestroyed events
	self.tUnitsHidden 				= {}	-- Units that we're tracking but are out of the current subzone
	self.tObjectsShown 				= {} -- For Challenges which use their own events
	self.tObjectsShown.Challenges 	= {}
	self.tPingObjects 				= {}
	self.arResourceNodes			= {}
	self.tObjectData				= {}

	self.tGroupMembers 				= {}
	self.tGroupMemberObjects 		= {}

	self.xmlDoc = XmlDoc.CreateFromFile("ForgeUI_MiniMap.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self)
end

function ForgeUI_MiniMap:OnDocumentReady()
	if self.xmlDoc == nil and not self.xmlDoc:IsLoaded() then return end

	Apollo.LoadSprites("SquareMapTextures_NoCompass.xml")
	
	if ForgeUI == nil then -- forgeui loaded
		ForgeUI = Apollo.GetAddon("ForgeUI")
	end
	
	ForgeUI.API_RegisterAddon(self)
end

function ForgeUI_MiniMap:ForgeAPI_AfterRegistration()
	Apollo.RegisterEventHandler("CharacterCreated", 					"OnCharacterCreated", self)
	Apollo.RegisterEventHandler("OptionsUpdated_QuestTracker", 			"OnOptionsUpdated", self)
	Apollo.RegisterEventHandler("VarChange_ZoneName", 					"OnChangeZoneName", self)
	Apollo.RegisterEventHandler("SubZoneChanged", 						"OnChangeZoneName", self)

	Apollo.RegisterEventHandler("QuestObjectiveUpdated", 				"OnQuestStateChanged", self)
	Apollo.RegisterEventHandler("QuestStateChanged", 					"OnQuestStateChanged", self)
	Apollo.RegisterEventHandler("GenericEvent_QuestTrackerRenumbered", 	"OnQuestStateChanged", self)

	Apollo.RegisterEventHandler("FriendshipAdd", 						"OnFriendshipAdd", self)
	Apollo.RegisterEventHandler("FriendshipRemove", 					"OnFriendshipRemove", self)
	Apollo.RegisterEventHandler("FriendshipAccountFriendsRecieved",  	"OnFriendshipAccountFriendsRecieved", self)
	Apollo.RegisterEventHandler("FriendshipAccountFriendRemoved",   	"OnFriendshipAccountFriendRemoved", self)

	Apollo.RegisterEventHandler("ReputationChanged",   					"OnReputationChanged", self)

	Apollo.RegisterEventHandler("UnitDestroyed", 						"OnUnitDestroyed", self)
	Apollo.RegisterEventHandler("UnitActivationTypeChanged", 			"OnUnitChanged", self)
	Apollo.RegisterEventHandler("UnitMiniMapMarkerChanged", 			"OnUnitChanged", self)
	Apollo.RegisterEventHandler("ChallengeFailArea", 					"OnFailChallenge", self)
	Apollo.RegisterEventHandler("ChallengeFailTime", 					"OnFailChallenge", self)
	Apollo.RegisterEventHandler("ChallengeAbandonConfirmed", 			"OnRemoveChallengeIcon", self)
	Apollo.RegisterEventHandler("ChallengeActivate", 					"OnAddChallengeIcon", self)
	Apollo.RegisterEventHandler("ChallengeFlashStartLocation", 			"OnFlashChallengeIcon", self)
	Apollo.RegisterEventHandler("PlayerPathMissionActivate", 			"OnPlayerPathMissionActivate", self)
	Apollo.RegisterEventHandler("PlayerPathMissionUpdate", 				"OnPlayerPathMissionActivate", self)
	Apollo.RegisterEventHandler("PlayerPathMissionDeactivate", 			"OnPlayerPathMissionDeactivate", self)
	Apollo.RegisterEventHandler("PlayerPathExplorerPowerMapStarted", 	"OnPlayerPathMissionActivate", self)
	Apollo.RegisterEventHandler("PlayerPathExplorerPowerMapFailed", 	"OnPlayerPathMissionActivate", self)
	Apollo.RegisterEventHandler("PublicEventObjectiveUpdate", 			"OnPublicEventObjectiveUpdate", self)
	Apollo.RegisterEventHandler("PublicEventStart", 					"OnPublicEventStart", self)
	Apollo.RegisterEventHandler("PublicEventEnd", 						"OnPublicEventEnd", self)
	Apollo.RegisterEventHandler("PublicEventLeave",						"OnPublicEventEnd", self)
	Apollo.RegisterEventHandler("PublicEventLocationAdded", 			"OnPublicEventUpdate", self)
	Apollo.RegisterEventHandler("PublicEventLocationRemoved", 			"OnPublicEventUpdate", self)
	Apollo.RegisterEventHandler("PublicEventObjectiveLocationAdded", 	"OnPublicEventObjectiveUpdate", self)
	Apollo.RegisterEventHandler("PublicEventObjectiveLocationRemoved", 	"OnPublicEventObjectiveUpdate", self)

	Apollo.RegisterEventHandler("CityDirectionMarked",					"OnCityDirectionMarked", self)
	Apollo.RegisterEventHandler("ZoneMap_TimeOutCityDirectionEvent",	"OnZoneMap_TimeOutCityDirectionEvent", self)

	Apollo.RegisterEventHandler("MapGhostMode", 						"OnMapGhostMode", self)
	Apollo.RegisterEventHandler("ToggleGhostModeMap",					"OnToggleGhostModeMap", self) -- for key input toggle on/off
	Apollo.RegisterEventHandler("HazardShowMinimapUnit", 				"OnHazardShowMinimapUnit", self)
	Apollo.RegisterEventHandler("HazardRemoveMinimapUnit", 				"OnHazardRemoveMinimapUnit", self)
	Apollo.RegisterEventHandler("ZoneMapPing", 							"OnMapPing", self)

	Apollo.RegisterEventHandler("PlayerLevelChange",					"UpdateHarvestableNodes", self)

	Apollo.RegisterTimerHandler("ChallengeFlashIconTimer", 				"OnStopChallengeFlashIcon", self)
	
	self.timerCreateDelay = ApolloTimer.Create(1.0, true, "OnOneSecTimer", self)
	self.timerCreateDelay:Start()

	Apollo.RegisterTimerHandler("PingTimer",							"OnPingTimer", self)
	Apollo.CreateTimer("PingTimer", 1, false)
	Apollo.StopTimer("PingTimer")

	--Group Events
	Apollo.RegisterEventHandler("Group_Join", 							"OnGroupJoin", self)					-- ()
	Apollo.RegisterEventHandler("Group_Add", 							"OnGroupAdd", self)						-- ( name )
	Apollo.RegisterEventHandler("Group_Remove", 						"OnGroupRemove", self)					-- ( name, result )
	Apollo.RegisterEventHandler("Group_Left", 							"OnGroupLeft", self)					-- ( reason )
	Apollo.RegisterEventHandler("Group_UpdatePosition", 				"OnGroupUpdatePosition", self)			-- ( arMembers )

	Apollo.RegisterEventHandler("Tutorial_RequestUIAnchor", 			"OnTutorial_RequestUIAnchor", self)

	ForgeUI.API_AddItemButton(self, "MiniMap", { strContainer = "Container" })
	
	self.wndMain 			= Apollo.LoadForm(self.xmlDoc , "Minimap", "FixedHudStratum", self)
	ForgeUI.API_RegisterWindow(self, self.wndMain, "ForgeUI_MiniMap", { strDisplayName = "MiniMap" })
	
	self.wndMiniMap 		= self.wndMain:FindChild("MapContent")
	self.wndZoneName 		= self.wndMain:FindChild("MapZoneName")
	self:UpdateZoneName(GetCurrentZoneName())

	self.bLiveEventActive = false

	self:CreateOverlayObjectTypes() -- ** IMPORTANT ** This function must run before you do anything involving overlay types!
	self:BuildCustomMarkerInfo()

	self.unitPlayerDisposition = GameLib.GetPlayerUnit()
	if self.unitPlayerDisposition ~= nil then
		self:OnCharacterCreated()
	end
	
	-- The object types for each category
	self.tCategoryTypes =
	{
		[ktTooltipCategories.QuestNPC] 		= {self.eObjectTypeQuestReward, self.eObjectTypeQuestReceiving, self.eObjectTypeQuestNew, self.eObjectTypeQuestNewSoon, self.eObjectTypeQuestTarget,	self.eObjectTypeQuestKill,},
		[ktTooltipCategories.TrackedQuest] 	= {GameLib.CodeEnumMapOverlayType.QuestObjective,},
		[ktTooltipCategories.GroupMember]	= {self.eObjectTypeGroupMember,},
		[ktTooltipCategories.NeutralNPC] 	= {self.eObjectTypeNeutral,},
		[ktTooltipCategories.HostileNPC]	= {self.eObjectTypeHostile,},
		[ktTooltipCategories.Path]			= {GameLib.CodeEnumMapOverlayType.PathObjective,},
		[ktTooltipCategories.Challenge] 	= {self.eObjectTypeChallenge,},
		[ktTooltipCategories.PublicEvent] 	= {self.eObjectTypePublicEvent,},
		[ktTooltipCategories.Tradeskill] 	= {self.eObjectTypeTradeskills,},
		[ktTooltipCategories.Vendor] 		= {self.eObjectTypeVendor,},
		[ktTooltipCategories.Service] 		= {self.eObjectTypeAuctioneer, self.eObjectTypeCommodity, self.eObjectTypeBank, self.eObjectTypeGuildBank, self.eObjectTypeGuildRegistrar, self.eObjectTypeCostume, self.eObjectTypeCREDDExchange, self.eObjectTypeMail, self.eObjectTypeConvert,},
		[ktTooltipCategories.Portal] 		= {self.eObjectTypeInstancePortal,},
		[ktTooltipCategories.BindPoint] 	= {self.eObjectTypeBindPointActive, self.eObjectTypeBindPointInactive,},
		[ktTooltipCategories.Mining] 		= {self.eObjectTypeMiningNode,},
		[ktTooltipCategories.Relic] 		= {self.eObjectTypeRelicHunterNode,},
		[ktTooltipCategories.Survivalist] 	= {self.eObjectTypeSurvivalistNode,},
		[ktTooltipCategories.Farming] 		= {self.eObjectTypeFarmingNode,},
		[ktTooltipCategories.Friend] 		= {self.eObjectTypeFriend,},
		[ktTooltipCategories.Rival] 		= {self.eObjectTypeRival,},
		[ktTooltipCategories.Taxi] 			= {self.eObjectTypeFlightPath, self.eObjectTypeFlightPathNew,},
		[ktTooltipCategories.CityDirection] = {self.eObjectTypeCityDirections,},
		[ktTooltipCategories.PvPMarker]		= {self.eObjectPvPMarkers,},
	}
	
	-- Maps object types to their parent category for quick access
	self.tReverseCategoryMap = {}
	for eCategory, tObjectTypes in pairs(self.tCategoryTypes) do
		for idx, eObjectType in pairs(tObjectTypes) do
			self.tReverseCategoryMap[eObjectType] = eCategory
		end
	end

	self:ReloadPublicEvents()
	self:ReloadMissions()
	self:OnQuestStateChanged()

	if g_wndTheMiniMap == nil then
		g_wndTheMiniMap = self.wndMiniMap
	end

	self:OnOptionsUpdated()
end

function ForgeUI_MiniMap:ForgeAPI_AfterRestore()
	self.wndMiniMap:SetZoomLevel(self.tSettings.nZoomLevel)
	
	local wndOptionsWindow = self.wndContainers["Container"]
	for strCategory, bEnabled in pairs(self.tSettings.tCategories) do
		local wndOptionsBtn = wndOptionsWindow:FindChild("OptionsBtn" .. strCategory)
		
		if wndOptionsBtn then
			ForgeUI.API_RegisterCheckBox(self, wndOptionsBtn, self.tSettings.tCategories, strCategory, "OnFilterOption")
		end
	end
	
	self:RehideAllToggledIcons()
end

function ForgeUI_MiniMap:OnCharacterCreated()
	if not self.unitPlayerDisposition then
		self.unitPlayerDisposition = GameLib.GetPlayerUnit()
	end

	-- PublicEventStart will catch it if this loads too early
	for idx, peEvent in pairs(PublicEvent.GetActiveEvents() or {}) do
		if peEvent:GetEventType() == PublicEvent.PublicEventType_LiveEvent then
			self.bLiveEventActive = true
			return
		end
	end
end

function ForgeUI_MiniMap:OnOptionsUpdated()
	if g_InterfaceOptions and g_InterfaceOptions.Carbine.bQuestTrackerByDistance ~= nil then
		self.bQuestTrackerByDistance = g_InterfaceOptions.Carbine.bQuestTrackerByDistance
	else
		self.bQuestTrackerByDistance = true
	end

	self:OnQuestStateChanged()
end

function ForgeUI_MiniMap:ReloadMissions()
	--self.wndMiniMap:RemoveObjectsByType(GameLib.CodeEnumMapOverlayType.PathObjective)
	local epiCurrent = PlayerPathLib.GetCurrentEpisode()
	if epiCurrent then
		for idx, pmCurr in ipairs(epiCurrent:GetMissions()) do
			self:OnPlayerPathMissionActivate(pmCurr)
		end
	end
end

function ForgeUI_MiniMap:OnChangeZoneName(oVar, strNewZone)
	self:UpdateZoneName(strNewZone)

	-- update mission indicators
	self:ReloadMissions()

	-- update quest indicators on zone change
	self:OnQuestStateChanged()

	-- update public events
	self:ReloadPublicEvents()

	-- update all already shown units
  	if self.tUnitsShown then
		for idx, tCurr in pairs(self.tUnitsShown) do
			if tCurr.unitObject then
				self.wndMiniMap:RemoveUnit(tCurr.unitObject)
				self.tUnitsShown[tCurr.unitObject:GetId()] = nil
				self:OnUnitCreated(tCurr.unitObject)
			end
		end
	end

	-- check for any units that are now back in the subzone
  	if self.tUnitsHidden then
		for idx, tCurr in pairs(self.tUnitsHidden) do
			if tCurr.unitObject then
				self.tUnitsHidden[tCurr.unitObject:GetId()] = nil
				self:OnUnitCreated(tCurr.unitObject)
			end
		end
	end

	self:OnOneSecTimer()

end

function ForgeUI_MiniMap:UpdateZoneName(strZoneName)
	if strZoneName == nil then
		return
	end

	local tInstanceSettingsInfo = GameLib.GetInstanceSettings()

	local strDifficulty = nil
	if tInstanceSettingsInfo.eWorldDifficulty == GroupLib.Difficulty.Veteran then
		strDifficulty = ktInstanceSettingTypeStrings.Veteran
	end

	local strScaled = nil
	if tInstanceSettingsInfo.bWorldForcesLevelScaling == true then
		strScaled = ktInstanceSettingTypeStrings.Rallied
	end

	local strAdjustedZoneName = strZoneName
	if strDifficulty then
		strAdjustedZoneName = strZoneName .. " (" .. strDifficulty .. ")"
	elseif strScaled then
		strAdjustedZoneName = strZoneName .. " (" .. strScaled .. ")"
	end

	self.wndZoneName:SetText(strAdjustedZoneName)
end

---------------------------------------------------------------------------------------------------
--Options
---------------------------------------------------------------------------------------------------
function ForgeUI_MiniMap:OnMapPing(idUnit, tPos )
	for idx, tCur in pairs(self.tPingObjects) do
		if tCur.idUnit == idUnit then
			self.wndMiniMap:RemoveObject(tCur.objMapPing)
			self.tPingObjects[idx] = nil
		end
	end

	local tInfo =
	{
		strIcon = "sprMap_PlayerPulseFast",
		crObject = CColor.new(1, 1, 1, 1),
		strIconEdge = "",
		crEdge = CColor.new(1, 1, 1, 1),
		bAboveOverlay = true,
	}

	Sound.Play(Sound.PlayUIMiniMapPing)

	table.insert(self.tPingObjects, {["idUnit"] = idUnit, ["objMapPing"] = self.wndMiniMap:AddObject(self.eObjectTypePing, tPos, "", tInfo), ["nTime"] = GameLib.GetGameTime()})

	Apollo.StartTimer("PingTimer")

end

function ForgeUI_MiniMap:OnPingTimer()

	local nCurTime = GameLib.GetGameTime()
	local nNumUnits = 0
	for idx, tCur in pairs(self.tPingObjects) do
		if (tCur.nTime + 5) < nCurTime then
			self.wndMiniMap:RemoveObject(tCur.objMapPing)
			self.tPingObjects[idx] = nil
		else
			nNumUnits = nNumUnits + 1
		end
	end

	if nNumUnits == 0 then
		Apollo.StopTimer("PingTimer")
	else
		Apollo.StartTimer("PingTimer")
	end

end

function ForgeUI_MiniMap:OnMouseMove(wndHandler, wndControl, nX, nY)

end

function ForgeUI_MiniMap:OnMapClick(wndHandler, wndControl, eButton, nX, nY, bDouble)

end

function ForgeUI_MiniMap:OnMouseButtonUp(eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY)

end

---------------------------------------------------------------------------------------------------
function ForgeUI_MiniMap:OnFailChallenge(tChallengeData)
	self:OnRemoveChallengeIcon(tChallengeData:GetId())
end

function ForgeUI_MiniMap:OnRemoveChallengeIcon(chalOwner)
	if self.tChallengeObjects[chalOwner] ~= nil then
		self.wndMiniMap:RemoveObject(self.tChallengeObjects[chalOwner])
	end
	if self.tObjectsShown.Challenges ~= nil then
		for idx, tCurr in pairs(self.tObjectsShown.Challenges) do
			self.wndMiniMap:RemoveObject(idx)
		end
	end
	self.tObjectsShown.Challenges = {}
end

function ForgeUI_MiniMap:OnAddChallengeIcon(chalOwner, strDescription, tPosition)
	if self.tChallengeObjects[chalOwner:GetId()] ~= nil then
		self.wndMiniMap:RemoveObject(self.tChallengeObjects[chalOwner:GetId()])
		self.tChallengeObjects[chalOwner:GetId()] = nil

		-- make sure we turn off the flash icon just in case
		self:OnStopChallengeFlashIcon()
	end

	local tInfo =
	{
		strIcon = "MiniMapObject",
		crObject = CColor.new(1, 1, 1, 1),
		strIconEdge = "sprMM_ChallengeArrow",
		crEdge = CColor.new(1, 1, 1, 1),
		bAboveOverlay = true,
	}
	if tPosition ~= nil then
		if self.tObjectsShown.Challenges == nil then
			self.tObjectsShown.Challenges = {}
		end

		self.tChallengeObjects[chalOwner] = self.wndMiniMap:AddObject(self.eObjectTypeChallenge, tPosition, strDescription, tInfo, {}, not self.tToggledIcon[self.eObjectTypeChallenge])
		self.tObjectsShown.Challenges[self.tChallengeObjects[chalOwner]] = {tPosition = tPosition, strDescription = strDescription}
	end
end

function ForgeUI_MiniMap:OnFlashChallengeIcon(chalOwner, strDescription, fDuration, tPosition)
	if self.tChallengeObjects[chalOwner] ~= nil then
		self.wndMiniMap:RemoveObject(self.tChallengeObjects[chalOwner])
	end

	if self.tSettings.tCategories.Challenges ~= false then
		-- TODO: Need to change the icon to a flashing icon
		local tInfo =
		{
			strIcon 		= "sprMM_QuestZonePulse",
			crObject 		= CColor.new(1, 1, 1, 1),
			strIconEdge 	= "sprMM_PathArrowActive",
			crEdge 			= CColor.new(1, 1, 1, 1),
			bAboveOverlay 	= true,
		}

		self.tChallengeObjects[chalOwner] = self.wndMiniMap:AddObject(self.eObjectTypeChallenge, tPosition, strDescription, tInfo, {}, false)
		self.ChallengeFlashingIconId = chalOwner

		-- create the timer to turn off this flashing icon
		Apollo.StopTimer("ChallengeFlashIconTimer")
		Apollo.CreateTimer("ChallengeFlashIconTimer", fDuration, false)
		Apollo.StartTimer("ChallengeFlashIconTimer")
	end
end

function ForgeUI_MiniMap:OnStopChallengeFlashIcon()

	if self.ChallengeFlashingIconId and self.tChallengeObjects[self.ChallengeFlashingIconId] then
		self.wndMiniMap:RemoveObject(self.tChallengeObjects[self.ChallengeFlashingIconId])
		self.tChallengeObjects[self.ChallengeFlashingIconId] = nil
	end

	self.ChallengeFlashingIconId = nil
end

---------------------------------------------------------------------------------------------------

function ForgeUI_MiniMap:OnPlayerPathMissionActivate(pmActivated)
	if self.tSettings.tCategories == nil then
		return
	end

	self:OnPlayerPathMissionDeactivate(pmActivated)

	local tInfo =
	{
		strIcon 	= pmActivated:GetMapIcon(),
		crObject 	= CColor.new(1, 1, 1, 1),
		strIconEdge = "",
		crEdge 		= CColor.new(1, 1, 1, 1),
	}

	self.wndMiniMap:AddPathIndicator(pmActivated, tInfo, {bNeverShowOnEdge = true, bFixedSizeSmall = false}, not self.tSettings.tCategories.Missions)
end

function ForgeUI_MiniMap:OnPlayerPathMissionDeactivate(pmDeactivated)
	self.wndMiniMap:RemoveObjectsByUserData(GameLib.CodeEnumMapOverlayType.PathObjective, pmDeactivated)
end

---------------------------------------------------------------------------------------------------

function ForgeUI_MiniMap:ReloadPublicEvents()
	local tEvents = PublicEvent.GetActiveEvents()
	for idx, peCurr in ipairs(tEvents) do
		self:OnPublicEventUpdate(peCurr)
	end
end

function ForgeUI_MiniMap:OnPublicEventUpdate(peUpdated)
	self.wndMiniMap:RemoveObjectsByUserData(self.eObjectTypePublicEvent, peUpdated)
	for idx, peoCurr in ipairs(peUpdated:GetObjectives()) do
		self:OnPublicEventObjectiveEnd(peoCurr)
	end	
	
	if not peUpdated:IsActive() or self.tSettings.tCategories == nil then
		return
	end

	local tInfo =
	{
		strIcon = "sprMM_POI",
		crObject = CColor.new(1, 1, 1, 1),
		strIconEdge = "sprMM_QuestArrowActive",
		crEdge = CColor.new(1, 1, 1, 1),
	}

	for idx, tPos in ipairs(peUpdated:GetLocations()) do
		local tOptions = { bNeverShowOnEdge = peUpdated:ShouldShowOnMiniMapEdge(), bFixedSizeSmall = false }
		self.wndMiniMap:AddObject(self.eObjectTypePublicEvent, tPos, peUpdated:GetName(), tInfo, tOptions, not self.tSettings.tCategories.PublicEvents, peUpdated)
	end

	for idx, peoCurr in ipairs(peUpdated:GetObjectives()) do
		self:OnPublicEventObjectiveUpdate(peoCurr)
	end
end

function ForgeUI_MiniMap:OnPublicEventEnd(peEnding)
	self.wndMiniMap:RemoveObjectsByUserData(self.eObjectTypePublicEvent, peEnding)
	for idx, peoCurr in ipairs(peEnding:GetObjectives()) do
		self:OnPublicEventObjectiveEnd(peoCurr)
	end

	if peEnding:GetEventType() == PublicEvent.PublicEventType_LiveEvent and not peEnding:IsActive() then -- Assumes only one live event will be active at once
		self.bLiveEventActive = false
	end
end

function ForgeUI_MiniMap:OnPublicEventStart(peStarting)
	self:OnPublicEventUpdate(peStarting) -- Always do this, from previous code
	if peStarting and peStarting:GetEventType() == PublicEvent.PublicEventType_LiveEvent then
		self.bLiveEventActive = true
	end
end

function ForgeUI_MiniMap:OnPublicEventObjectiveUpdate(peoUpdated)
	self:OnPublicEventObjectiveEnd(peoUpdated)

	if peoUpdated:GetStatus() ~= PublicEventObjective.PublicEventStatus_Active then
		return
	end

	local tInfo =
	{
		strIcon 	= "sprMM_POI",
		crObject 	= CColor.new(1, 1, 1, 1),
		strIconEdge = "MiniMapObjectEdge",
		crEdge 		= CColor.new(1,1, 1, 1),
	}

	bHideOnEdge = (peoUpdated:ShouldShowOnMinimapEdge() ~= true)

	for idx, tPos in ipairs(peoUpdated:GetLocations()) do
		self.wndMiniMap:AddObject(self.eObjectTypePublicEvent, tPos, peoUpdated:GetShortDescription(), tInfo, {bNeverShowOnEdge = hideOnEdge, bFixedSizeSmall = false}, not self.tSettings.tCategories.PublicEvents, peoUpdated)
	end
end

function ForgeUI_MiniMap:OnPublicEventObjectiveEnd(peoUpdated)
	self.wndMiniMap:RemoveObjectsByUserData(self.eObjectTypePublicEvent, peoUpdated)
end

---------------------------------------------------------------------------------------------------
function ForgeUI_MiniMap:OnCityDirectionMarked(tLocInfo)
	if not self.wndMiniMap or not self.wndMiniMap:IsValid() then
		return
	end

	local tInfo =
	{
		strIconEdge = "",
		strIcon 	= "sprMM_QuestTrackedActivate",
		crObject 	= CColor.new(1, 1, 1, 1),
		crEdge 		= CColor.new(1, 1, 1, 1),
	}

	-- Only one city direction at a time, so stomp and remove and previous
	self.wndMiniMap:RemoveObjectsByUserData(self.eObjectTypeCityDirections, Apollo.GetString("ZoneMap_CityDirections"))
	self.wndMiniMap:AddObject(self.eObjectTypeCityDirections, tLocInfo.tLoc, tLocInfo.strName, tInfo, {bFixedSizeSmall = false}, false, Apollo.GetString("ZoneMap_CityDirections"))
	Apollo.StartTimer("ZoneMap_TimeOutCityDirectionMarker")
end

function ForgeUI_MiniMap:OnZoneMap_TimeOutCityDirectionEvent()
	if not self.wndMiniMap or not self.wndMiniMap:IsValid() then
		return
	end

	self.wndMiniMap:RemoveObjectsByUserData(self.eObjectTypeCityDirections, Apollo.GetString("ZoneMap_CityDirections"))
end

---------------------------------------------------------------------------------------------------
function ForgeUI_MiniMap:OnQuestStateChanged()
	self.tEpisodeList = QuestLib.GetTrackedEpisodes(self.bQuestTrackerByDistance)

	if self.wndMiniMap == nil or self.tSettings.tCategories == nil then
		return
	end

	-- Clear episode list
	self.wndMiniMap:RemoveObjectsByType(GameLib.CodeEnumMapOverlayType.QuestObjective)

	-- Iterate over all the episodes adding the active one
	local nCount = 0
	for idx, epiCurr in pairs(self.tEpisodeList) do

		-- Add entries for each quest in the episode
		for idx2, queCurr in pairs(epiCurr:GetTrackedQuests(0, self.bQuestTrackerByDistance)) do
			local eQuestState = queCurr:GetState()
			nCount = nCount + 1 -- number the quest

			if queCurr:IsActiveQuest() then
				local tInfo =
				{
					strIcon 	= "ActiveQuestIcon",
					crObject 	= CColor.new(1, 1, 1, 1),
					strIconEdge = "sprMM_QuestArrowActivate",
					crEdge 		= CColor.new(1, 1, 1, 1),
				}
				-- This is a C++ call on the MiniMapWindow class
				self.wndMiniMap:AddQuestIndicator(queCurr, tostring(nCount), tInfo, {bOnlyShowOnEdge = false, bAboveOverlay = true}, not self.tSettings.tCategories.Tracked)
			elseif not queCurr:IsActiveQuest() and self.tSettings.tCategories.Quests then
				local tInfo =
				{
					strIcon = "sprMM_QuestTracked",
					crObject = CColor.new(1, 1, 1, 1),
					strIconEdge = "sprMM_SolidPathArrow",
					crEdge = CColor.new(1, 1, 1, 1),
					strIconAbove = "IconSprites:Icon_MapNode_Map_QuestMarkerAbove",
					strIconBelow = "IconSprites:Icon_MapNode_Map_QuestMarkerBelow",
				}
				-- This is a C++ call on the MiniMapWindow class
				self.wndMiniMap:AddQuestIndicator(queCurr, tostring(nCount), tInfo, {bOnlyShowOnEdge = false, bFixedSizeMedium = false, bAboveOverlay = true}, not self.tSettings.tCategories.Tracked)
			end
		end
	end
end

---------------------------------------------------------------------------------------------------

function ForgeUI_MiniMap:OnOneSecTimer()
	if self.tQueuedUnits == nil then
		return
	end

	self.unitPlayerDisposition = GameLib.GetPlayerUnit()
	if self.unitPlayerDisposition == nil or not self.unitPlayerDisposition:IsValid() then
		return
	end

	local nCurrentTime = os.time()
	
	if ForgeUI then
		self.wndMain:FindChild("Time"):SetText(ForgeUI.GetTime(true))
	end
	
	while #self.tQueuedUnits > 0 do
		local unit = table.remove(self.tQueuedUnits, #self.tQueuedUnits)
		if unit:IsValid() then
			self:HandleUnitCreated(unit)
		end
		
		if os.time() - nCurrentTime > 0 then
			break
		end
	end
end

function ForgeUI_MiniMap:OnUnitCreated(unitNew)
	if unitNew == nil or not unitNew:IsValid() or unitNew == GameLib.GetPlayerUnit() then
		return
	end
	self.tQueuedUnits[#self.tQueuedUnits + 1] = unitNew
end

function ForgeUI_MiniMap:GetDefaultUnitInfo()
	local tInfo =
	{
		strIcon = "",
		strIconEdge = "MiniMapObjectEdge",
		crObject = CColor.new(1, 1, 1, 1),
		crEdge = CColor.new(1, 1, 1, 1),
		bAboveOverlay = false,
	}
	return tInfo
end

function ForgeUI_MiniMap:UpdateHarvestableNodes()
	for idx, unitResource in pairs(self.arResourceNodes) do
		if unitResource:CanBeHarvestedBy(GameLib.GetPlayerUnit()) then
			self:OnUnitChanged(unitResource)
			self.arResourceNodes[unitResource:GetId()] = nil
		end
	end
end

function ForgeUI_MiniMap:GetOrderedMarkerInfos(tMarkerStrings)
	local tMarkerInfos = {}

	for nMarkerIdx, strMarker in ipairs(tMarkerStrings) do
		if strMarker then
			local tMarkerOverride = self.tMinimapMarkerInfo[strMarker]
			if tMarkerOverride then
				table.insert(tMarkerInfos, tMarkerOverride)
			end
		end
	end

	table.sort(tMarkerInfos, function(x, y) return x.nOrder < y.nOrder end)
	return tMarkerInfos
end

function ForgeUI_MiniMap:HandleUnitCreated(unitNew)

	if not unitNew or not unitNew:IsValid() then
		return
	end

	if self.tUnitsHidden and self.tUnitsHidden[unitNew:GetId()] then
		self.tUnitsHidden[unitNew:GetId()] = nil
		self.wndMiniMap:RemoveUnit(unitNew)
	end

	if self.tUnitsShown and self.tUnitsShown[unitNew:GetId()] then
		self.tUnitsShown[unitNew:GetId()] = nil
		self.wndMiniMap:RemoveUnit(unitNew)
	end

	local bShowUnit = unitNew:IsVisibleOnCurrentZoneMinimap()

	if bShowUnit == false then
		self.tUnitsHidden[unitNew:GetId()] = {unitObject = unitNew} -- valid, but different subzone. Add it to the list
		return
	end

	local tMarkers = unitNew:GetMiniMapMarkers()
	if tMarkers == nil then
		return
	end
	local tMarkerInfoList = self:GetOrderedMarkerInfos(tMarkers)
	for nIdx, tMarkerInfo in ipairs(tMarkerInfoList) do
		local tInfo = self:GetDefaultUnitInfo()
		local tInteract = unitNew:GetActivationState()
		
		if tMarkerInfo.strIcon ~= nil then
			tInfo.strIcon = tMarkerInfo.strIcon
		end
		if tMarkerInfo.crObject ~= nil then
			tInfo.crObject = tMarkerInfo.crObject
		end
		if tMarkerInfo.crEdge ~= nil then
			tInfo.crEdge = tMarkerInfo.crEdge
		end
		if tMarkerInfo.strIconEdge ~= nil then
			tInfo.strIconEdge = tMarkerInfo.strIconEdge
		end

		local tMarkerOptions = { bNeverShowOnEdge = true }
		if tMarkerInfo.bNeverShowOnEdge ~= nil then
			tMarkerOptions.bNeverShowOnEdge = tMarkerInfo.bNeverShowOnEdge
		end
		if tMarkerInfo.bAboveOverlay ~= nil then
			tMarkerOptions.bAboveOverlay = tMarkerInfo.bAboveOverlay
		end
		if tMarkerInfo.bShown ~= nil then
			tMarkerOptions.bShown = tMarkerInfo.bShown
		end
		
		-- only one of these should be set
		if tMarkerInfo.bFixedSizeSmall ~= nil then
			tMarkerOptions.bFixedSizeSmall = tMarkerInfo.bFixedSizeSmall
		elseif tMarkerInfo.bFixedSizeMedium ~= nil then
			tMarkerOptions.bFixedSizeMedium = tMarkerInfo.bFixedSizeMedium
		end

		local objectType = GameLib.CodeEnumMapOverlayType.Unit
		if tMarkerInfo.objectType ~= nil then
			objectType = tMarkerInfo.objectType
		end

		local bIconState = self:GetToggledIconState(objectType)
		if not tInteract.Busy and (not tMarkerInfo.bHideIfHostile
			or (tMarkerInfo.bHideIfHostile and unitNew:GetDispositionTo(self.unitPlayerDisposition) ~= Unit.CodeEnumDisposition.Hostile)) then
			local mapIconReference = self.wndMiniMap:AddUnit(unitNew, objectType, tInfo, tMarkerOptions, bIconState ~= nil and not bIconState)
			self.tUnitsShown[unitNew:GetId()] = { tInfo = tInfo, unitObject = unitNew }
			
			if objectType == self.eObjectTypeGroupMember then
				for idxMember = 2, GroupLib.GetMemberCount() do
					local unitMember = GroupLib.GetUnitForGroupMember(idxMember)
					if unitMember == unitNew then
						if self.tGroupMembers[idxMember] ~= nil then
							if self.tGroupMembers[idxMember].mapObject ~= nil then
								self.wndMiniMap:RemoveObject(self.tGroupMembers[idxMember].mapObject)
							end
	
							self.tGroupMembers[idxMember].mapObject = mapIconReference
						end
						break
					end
				end
			end
		end
	end

end

function ForgeUI_MiniMap:OnHazardShowMinimapUnit(idHazard, unitHazard, bIsBeneficial)

	if unitHazard == nil then
		return
	end

	--local unit = GameLib.GetUnitById(unitId)
	local tInfo

	tInfo =
	{
		strIcon = "",
		strIconEdge = "",
		crObject = CColor.new(1, 1, 1, 1),
		crEdge = CColor.new(1, 1, 1, 1),
		bAboveOverlay = false,
	}


	if bIsBeneficial then
		tInfo.strIcon = "sprMM_ZoneBenefit"
	else
		tInfo.strIcon = "sprMM_ZoneHazard"
	end

	self.wndMiniMap:AddUnit(unitHazard, self.eObjectTypeHazard, tInfo, {bNeverShowOnEdge = true, bFixedSizeMedium = true}, false)
end

function ForgeUI_MiniMap:OnHazardRemoveMinimapUnit(idHazard, unitHazard)
	if unitHazard == nil then
		return
	end

	self.wndMiniMap:RemoveUnit(unitHazard)
end

function ForgeUI_MiniMap:OnUnitChanged(unitUpdated, eType)
	if unitUpdated == nil then
		return
	end

	self.wndMiniMap:RemoveUnit(unitUpdated)
	self.tUnitsShown[unitUpdated:GetId()] = nil
	self.tUnitsHidden[unitUpdated:GetId()] = nil
	self:OnUnitCreated(unitUpdated)
end

function ForgeUI_MiniMap:OnUnitDestroyed(unitDestroyed)
	self.tUnitsShown[unitDestroyed:GetId()] = nil
	self.tUnitsHidden[unitDestroyed:GetId()] = nil
	self.arResourceNodes[unitDestroyed:GetId()] = nil
	
	if unitDestroyed:IsInYourGroup() then
		for idxMember = 2, GroupLib.GetMemberCount() do
			local unitMember = GroupLib.GetUnitForGroupMember(idxMember)
			if unitMember == unitDestroyed then
				local tMember = self.tGroupMembers[idxMember]
				if tMember ~= nil then
					tMember.tWorldLoc = unitDestroyed:GetPosition()
					self:DrawGroupMember(tMember)
				end
				break
			end
		end
	end
end

-- GROUP EVENTS

function ForgeUI_MiniMap:OnGroupJoin()
	for idx = 2, GroupLib.GetMemberCount() do
		local tInfo = GroupLib.GetGroupMember(idx)
		if tInfo.bIsOnline then
			self.tGroupMembers[idx] =
			{
				nIndex = idx,
				strName = tInfo.strCharacterName,
			}

			local unitMember = GroupLib.GetUnitForGroupMember(idx)
			if unitMember ~= nil and unitMember:IsValid() then
				self:OnUnitCreated(unitMember)
			end
		end
	end
end

function ForgeUI_MiniMap:OnGroupAdd(strName)
	for idx = 2, GroupLib.GetMemberCount() do
		local tInfo = GroupLib.GetGroupMember(idx)
		if tInfo.bIsOnline and strName == tInfo.strCharacterName then
			self.tGroupMembers[idx] =
			{
				nIndex = idx,
				strName = tInfo.strCharacterName,
			}

			local unitMember = GroupLib.GetUnitForGroupMember(idx)
			if unitMember ~= nil and unitMember:IsValid() then
				self:OnUnitCreated(unitMember)
			end

			return
		end
	end
end

function ForgeUI_MiniMap:OnGroupRemove(strName, eReason)
	for idx, tMember in pairs(self.tGroupMembers) do -- remove all of the group objects
		self.wndMiniMap:RemoveObject(tMember.mapObject)
	end

	--[[
	for idx = 2, GroupLib.GetMemberCount() do
		local tInfo = GroupLib.GetGroupMember(idx)
		if tInfo.bIsOnline and strName ~= tInfo.strCharacterName then
			local unitMember = GroupLib.GetUnitForGroupMember(idx)
			if unitMember ~= nil and unitMember:IsValid() then
				self:OnUnitCreated(unitMember)
			end
		end
	end
	]]--
	
	self:OnRefreshRadar()
	self:DrawGroupMembers()
end

function ForgeUI_MiniMap:OnGroupLeft(eReason)
	for idx, tMember in pairs(self.tGroupMembers) do -- remove all of the group objects
		self.wndMiniMap:RemoveObject(tMember.mapObject)
	end

	self.tGroupMembers = {}
	self:OnRefreshRadar()
end

function ForgeUI_MiniMap:OnGroupUpdatePosition(arMembers)
	for idx, tMember in pairs(arMembers) do
		if tMember.nIndex ~= 1 then -- this is the player
			local tMemberInfo = GroupLib.GetGroupMember(tMember.nIndex)
			if self.tGroupMembers[tMember.nIndex] == nil then
				local tInfo =
				{
					nIndex = tMember.nIndex,
					tZoneMap = tMember.tZoneMap,
					idWorld = tMember.idWorld,
					tWorldLoc = tMember.tWorldLoc,
					bInCombatPvp = tMember.bInCombatPvp,
					strName = tMemberInfo.strCharacterName,
				}

				self.tGroupMembers[tMember.nIndex] = tInfo
			else
				self.tGroupMembers[tMember.nIndex].tZoneMap = tMember.tZoneMap
				self.tGroupMembers[tMember.nIndex].tWorldLoc = tMember.tWorldLoc
				self.tGroupMembers[tMember.nIndex].strName = tMemberInfo.strCharacterName
				self.tGroupMembers[tMember.nIndex].idWorld = tMember.idWorld
				self.tGroupMembers[tMember.nIndex].bInCombatPvp = tMember.bInCombatPvp
			end
		end
	end

	self:DrawGroupMembers()
end

function ForgeUI_MiniMap:DrawGroupMembers()
	for idx = 2, GroupLib.GetMemberCount() do
		local tMember = self.tGroupMembers[idx]
		local unitMember = GroupLib.GetUnitForGroupMember(idx)
		if unitMember == nil or not unitMember:IsValid() then
			self:DrawGroupMember(self.tGroupMembers[idx])
		end
	end
end

function ForgeUI_MiniMap:DrawGroupMember(tMember)
	if tMember == nil or tMember.tWorldLoc == nil then
		return
	end

	if tMember.mapObject ~= nil then
		self.wndMiniMap:RemoveObject(tMember.mapObject)
	end

	if not GroupLib.GetGroupMember(tMember.nIndex).bIsOnline then
		return
	end
	
	local tZone = GameLib.GetCurrentZoneMap()
	if tZone == nil or tMember.tZoneMap == nil or tMember.tZoneMap.id ~= tZone.id then
		return
	end
	
	local tMarkerInfo = self.tMinimapMarkerInfo.GroupMember
	local tInfo = self:GetDefaultUnitInfo()
	
	if tMarkerInfo.strIcon ~= nil then
		tInfo.strIcon = tMarkerInfo.strIcon
	end
	if tMarkerInfo.crObject ~= nil then
		tInfo.crObject = tMarkerInfo.crObject
	end
	if tMarkerInfo.crEdge ~= nil then
		tInfo.crEdge = tMarkerInfo.crEdge
	end
	if tMarkerInfo.strIconEdge ~= nil then
		tInfo.strIconEdge = tMarkerInfo.strIconEdge
	end

	local tMarkerOptions = { bNeverShowOnEdge = true }
	if tMarkerInfo.bNeverShowOnEdge ~= nil then
		tMarkerOptions.bNeverShowOnEdge = tMarkerInfo.bNeverShowOnEdge
	end
	if tMarkerInfo.bAboveOverlay ~= nil then
		tMarkerOptions.bAboveOverlay = tMarkerInfo.bAboveOverlay
	end
	if tMarkerInfo.bShown ~= nil then
		tMarkerOptions.bShown = tMarkerInfo.bShown
	end
	
	-- only one of these should be set
	if tMarkerInfo.bFixedSizeSmall ~= nil then
		tMarkerOptions.bFixedSizeSmall = tMarkerInfo.bFixedSizeSmall
	elseif tMarkerInfo.bFixedSizeMedium ~= nil then
		tMarkerOptions.bFixedSizeMedium = tMarkerInfo.bFixedSizeMedium
	end
	
	local strNameFormatted = string.format("<T Font=\"CRB_InterfaceMedium_B\" TextColor=\"ff31fcf6\">%s</T>", tMember.strName)
	strNameFormatted = String_GetWeaselString(Apollo.GetString("ZoneMap_AppendGroupMemberLabel"), strNameFormatted)
	tMember.mapObject = self.wndMiniMap:AddObject(self.eObjectTypeGroupMember, tMember.tWorldLoc, strNameFormatted, tInfo, tMarkerOptions)
end


---------------------------------------------------------------------------------------------------
function ForgeUI_MiniMap:OnGenerateTooltip(wndHandler, wndControl, eType, nX, nY)
	local strTooltip = ""
	if eType ~= Tooltip.TooltipGenerateType_Map then
		wndControl:SetTooltip("")
		return
	end

	local tMapObjects = self.wndMiniMap:GetObjectsAtPoint(nX, nY)
	if not tMapObjects or #tMapObjects == 0 then
		wndControl:SetTooltip("")
		return
	end
	
	local tDisplayStrings = {}
	
	for key, tObject in pairs(tMapObjects) do
		local strName = string.format("<T Font=\"%s\" TextColor=\"%s\">%s</T>", "CRB_InterfaceMedium", "ffffffff", tObject.strName)
		local eParentCategory = self.tReverseCategoryMap[tObject.eType]
		
		if self.tSettings.tCategories[ktTypeToCategory[eParentCategory]] then
			if tObject.eType == GameLib.CodeEnumMapOverlayType.QuestObjective then
				local strLevel = string.format("<T Font=\"%s\" TextColor=\"%s\"> (%s)</T>", "CRB_InterfaceMedium", ktConColors[tObject.userData:GetColoredDifficulty()], tObject.userData:GetConLevel())
				strName = strName .. strLevel
			end
			
			if not tDisplayStrings[eParentCategory] then				
				tDisplayStrings[eParentCategory] = {}
			end

			if not tDisplayStrings[eParentCategory][strName] then
				tDisplayStrings[eParentCategory][strName] = {}
			end
			
			if tObject.unit then
				local idUnit = tObject.unit:GetId()
				tDisplayStrings[eParentCategory][strName][idUnit] = true
			end
		end
	end
	
	local arSortedCategories = {}
	for eCategory, tStrings in pairs(tDisplayStrings) do
		table.insert(arSortedCategories, eCategory)
	end
	
	table.sort(arSortedCategories)
	
	local strFinal = ""
	local nObjectCount = 0
	
	for idx, eCategory in pairs(arSortedCategories) do
	
		local tStrings = tDisplayStrings[eCategory]
		if nObjectCount < 10 then
			strFinal = strFinal .. string.format("<P><T Font=\"%s\" TextColor=\"%s\">%s</T></P>", "CRB_InterfaceMedium", "UI_TextHoloTitle", ktCategoryNames[eCategory])
			
			for strName, tIds in pairs(tStrings) do
				local nCount = 0
				if nObjectCount < 10 then
					local strCount = ""
					for idUnit, bExists in pairs(tIds) do
						nCount = nCount + 1
					end
					
					if nCount > 1 then
						strCount = String_GetWeaselString(Apollo.GetString("Vendor_ItemCount"), nCount)
					end
					strFinal = strFinal .. "<P>-   " .. strName .. " " .. strCount .."</P>"
				end
				nObjectCount = nObjectCount + 1				
			end
		end
	end
	
	if nObjectCount > 10 then
		strOther = String_GetWeaselString(Apollo.GetString("MiniMap_OtherUnits"), GetPluralizeActor(Apollo.GetString("CRB_Unit"), nObjectCount - 10))
		strOther = string.format("<T Font=\"%s\" TextColor=\"%s\">%s</T>", "CRB_InterfaceMedium", "UI_TextHoloTitle", strOther)
		strFinal = strFinal .. "<P>" .. strOther .. "</P>"
	end
	
	if nObjectCount > 0 then
		wndControl:SetTooltip(strFinal)
	else
		wndControl:SetTooltip("")
	end	
end

function ForgeUI_MiniMap:OnFriendshipAccountFriendsRecieved(tFriendAccountList)
	for idx, tFriend in pairs(tFriendAccountList) do
		self:OnRefreshRadar(FriendshipLib.GetUnitById(tFriend.nId))
	end
end

function ForgeUI_MiniMap:OnFriendshipAdd(nFriendId)
	self:OnRefreshRadar(FriendshipLib.GetUnitById(nFriendId))
end

function ForgeUI_MiniMap:OnFriendshipRemove(nFriendId)
	self:OnRefreshRadar(FriendshipLib.GetUnitById(nFriendId))
end

function ForgeUI_MiniMap:OnFriendshipAccountFriendsRecieved(tFriendAccountList)
	self:OnRefreshRadar()
end

function ForgeUI_MiniMap:OnFriendshipAccountFriendRemoved(nId)
	self:OnRefreshRadar()
end

function ForgeUI_MiniMap:OnReputationChanged(tFaction)
	self:OnRefreshRadar()
end

function ForgeUI_MiniMap:OnRefreshRadar(newUnit)
	if newUnit ~= nil and newUnit:IsValid() then
		self:OnUnitCreated(newUnit)
	else
		for idx, tCur in pairs(self.tUnitsShown) do
			self:OnUnitCreated(tCur.unitObject)
		end

		for idx, tCur in pairs(self.tUnitsHidden) do
			self:OnUnitCreated(tCur.unitObject)
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Tutorial anchor request
---------------------------------------------------------------------------------------------------

function ForgeUI_MiniMap:OnTutorial_RequestUIAnchor(eAnchor, idTutorial, strPopupText)
	if eAnchor ~= GameLib.CodeEnumTutorialAnchor.ForgeUI_MiniMap then
		return
	end

	local tRect = {}
	tRect.l, tRect.t, tRect.r, tRect.b = self.wndMain:GetRect()

	Event_FireGenericEvent("Tutorial_RequestUIAnchorResponse", eAnchor, idTutorial, strPopupText, tRect)
end

---------------------------------------------------------------------------------------------------
-- MinimapOptions Functions
---------------------------------------------------------------------------------------------------
function ForgeUI_MiniMap:OnFilterOption(wndControl)
	for idx, eObjectType in pairs(self.tCategoryTypes[ktUIElementToType[wndControl:GetName()]]) do
		if wndControl:IsChecked() then
			self.wndMiniMap:ShowObjectsByType(eObjectType)
		else
			self.wndMiniMap:HideObjectsByType(eObjectType)
		end
	end
end

function ForgeUI_MiniMap:RehideAllToggledIcons()
	if self.wndMiniMap ~= nil and self.tToggledIcons ~= nil then
		for eData, bState in pairs(self.tSettings.tCategories) do
			if not bState then
				for idx, eObjectType in pairs(self.tCategoryTypes[ktUIElementToType["OptionsBtn" .. eData]]) do
					self.wndMiniMap:HideObjectsByType(eObjectType)
				end
			end
		end
	end
end

function ForgeUI_MiniMap:GetToggledIconState(eSearchType)
	for eCategory, tTypes in pairs(self.tCategoryTypes) do
		for idx, eObjectType in pairs(tTypes) do
			if eObjectType == eSearchType then
				return self.tSettings.tCategories[ktTypeToCategory[eCategory]]
			end
		end
	end

	return false
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_MiniMap instance
---------------------------------------------------------------------------------------------------
local ForgeUI_MiniMapInst = ForgeUI_MiniMap:new()
ForgeUI_MiniMapInst:Init()
