require "Window"
 
local ForgeUI
local ForgeUI_ToolTips = {}

local ToolTips_OnDocumentReady = nil
local ToolTips = Apollo.GetAddon("ToolTips")
 
local kItemTooltipWindowWidth = 300
local kstrTab = "    "
local kUIBody = "ff39b5d4"
local kUITeal = "ff53aa7f"
local kUIRed = "xkcdReddish" -- "ffab472f" Sat +50
local kUIGreen = "ff42da00" -- "ff55ab2f" Sat +50
local kUIYellow = kUIBody
local kUICyan = "UI_TextHoloBodyCyan"
local kUILowDurability = "yellow"
local kUIHugeFontSize = "CRB_HeaderSmall"
local knMaxLevel = 50

local karSimpleDispositionUnitTypes =
{
	["Simple"]			= true,
	["Chest"]			= true,
	["Door"]			= true,
	["Collectible"]		= true,
	["Platform"]		= true,
	["Mailbox"]			= true,
	["BindPoint"]		= true,
}

local karNPCDispositionUnitTypes =
{
	["NonPlayer"]			= true,
	["Destructible"]		= true,
	["Vehicle"]				= true,
	["Corpse"]				= true,
	["Mount"]				= true,
	["Taxi"]				= true,
	["DestructibleDoor"]	= true,
	["Turret"]				= true,
	["Pet"]					= true,
	["Esper Pet"]			= true,
	["Scanner"]				= true,
	["StructuredPlug"]		= true,
}

local ktMicrochipTypeNames =
{
	[Item.CodeEnumMicrochipType.PowerSource] 	= Apollo.GetString("CRB_Crafting_Circuit_Power_Core"),
	[Item.CodeEnumMicrochipType.Stat] 			= Apollo.GetString("CRB_Crafting_Circuit_Stat"),
	[Item.CodeEnumMicrochipType.PowerUp] 		= Apollo.GetString("CRB_Crafting_Circuit_Power_Up"),
	[Item.CodeEnumMicrochipType.Special] 		= Apollo.GetString("CRB_Crafting_Circuit_Special"),
	[Item.CodeEnumMicrochipType.Set]			= Apollo.GetString("CRB_Crafting_Circuit_Set"),
	[Item.CodeEnumMicrochipType.Omni] 			= Apollo.GetString("CRB_Crafting_Circuit_Omni"),
	[Item.CodeEnumMicrochipType.Capacitor] 		= Apollo.GetString("CRB_Crafting_Circuit_Capacitor"),
	[Item.CodeEnumMicrochipType.Resistor] 		= Apollo.GetString("CRB_Crafting_Circuit_Resistor"),
	[Item.CodeEnumMicrochipType.Inductor] 		= Apollo.GetString("CRB_Crafting_Circuit_Inductor")
}

local karClassToString =
{
	[GameLib.CodeEnumClass.Warrior]       	= Apollo.GetString("ClassWarrior"),
	[GameLib.CodeEnumClass.Engineer]      	= Apollo.GetString("ClassEngineer"),
	[GameLib.CodeEnumClass.Esper]         	= Apollo.GetString("ClassESPER"),
	[GameLib.CodeEnumClass.Medic]         	= Apollo.GetString("ClassMedic"),
	[GameLib.CodeEnumClass.Stalker]       	= Apollo.GetString("ClassStalker"),
	[GameLib.CodeEnumClass.Spellslinger]    = Apollo.GetString("ClassSpellslinger"),
}

local ktClassToIcon =
{
	[GameLib.CodeEnumClass.Medic]       	= "ForgeUI_medic",
	[GameLib.CodeEnumClass.Esper]       	= "ForgeUI_esper",
	[GameLib.CodeEnumClass.Warrior]     	= "ForgeUI_warrior",
	[GameLib.CodeEnumClass.Stalker]     	= "ForgeUI_stalker",
	[GameLib.CodeEnumClass.Engineer]    	= "ForgeUI_engineer",
	[GameLib.CodeEnumClass.Spellslinger]  	= "ForgeUI_spellslinger",
}

local ktPathToString =
{
	[PlayerPathLib.PlayerPathType_Soldier]    = Apollo.GetString("PlayerPathSoldier"),
	[PlayerPathLib.PlayerPathType_Settler]    = Apollo.GetString("PlayerPathSettler"),
	[PlayerPathLib.PlayerPathType_Scientist]  = Apollo.GetString("PlayerPathExplorer"),
	[PlayerPathLib.PlayerPathType_Explorer]   = Apollo.GetString("PlayerPathScientist"),
}

local ktPathToIcon =
{
	[PlayerPathLib.PlayerPathType_Soldier]    = "Icon_Windows_UI_CRB_Soldier",
	[PlayerPathLib.PlayerPathType_Settler]    = "Icon_Windows_UI_CRB_Colonist",
	[PlayerPathLib.PlayerPathType_Scientist]  = "Icon_Windows_UI_CRB_Scientist",
	[PlayerPathLib.PlayerPathType_Explorer]   = "Icon_Windows_UI_CRB_Explorer",
}

local karFactionToString =
{
	[Unit.CodeEnumFaction.ExilesPlayer]     = Apollo.GetString("CRB_Exile"),
	[Unit.CodeEnumFaction.DominionPlayer]   = Apollo.GetString("CRB_Dominion"),
}

local karDispositionColors =
{
	[Unit.CodeEnumDisposition.Neutral]  = "FFFFF569",
	[Unit.CodeEnumDisposition.Hostile]  = "FFE50000",
	[Unit.CodeEnumDisposition.Friendly] = "FF75CC26",
}

local karDispositionColorStrings =
{
	[Unit.CodeEnumDisposition.Neutral]  = "FFFFF569",
	[Unit.CodeEnumDisposition.Hostile]  = "FFE50000",
	[Unit.CodeEnumDisposition.Friendly] = "FF75CC26",
}

local karDispositionFrameSprites =
{
	[Unit.CodeEnumDisposition.Neutral]  = "sprTooltip_SquareFrame_UnitYellow",
	[Unit.CodeEnumDisposition.Hostile]  = "sprTooltip_SquareFrame_UnitRed",
	[Unit.CodeEnumDisposition.Friendly] = "sprTooltip_SquareFrame_UnitGreen",
}

local karRaceToString =
{
	[GameLib.CodeEnumRace.Human] 	= Apollo.GetString("RaceHuman"),
	[GameLib.CodeEnumRace.Granok] 	= Apollo.GetString("RaceGranok"),
	[GameLib.CodeEnumRace.Aurin] 	= Apollo.GetString("RaceAurin"),
	[GameLib.CodeEnumRace.Draken] 	= Apollo.GetString("RaceDraken"),
	[GameLib.CodeEnumRace.Mechari] 	= Apollo.GetString("RaceMechari"),
	[GameLib.CodeEnumRace.Chua] 	= Apollo.GetString("RaceChua"),
	[GameLib.CodeEnumRace.Mordesh] 	= Apollo.GetString("CRB_Mordesh"),
}

local karConInfo =
{
	{-4, ApolloColor.new("ConTrivial"), 	Apollo.GetString("TargetFrame_Trivial"), 	Apollo.GetString("Tooltips_None"), 		"ff7d7d7d"},
	{-3, ApolloColor.new("ConInferior"), 	Apollo.GetString("TargetFrame_Inferior"), 	Apollo.GetString("Tooltips_Minimal"), 	"ff01ff07"},
	{-2, ApolloColor.new("ConMinor"), 		Apollo.GetString("TargetFrame_Minor"), 		Apollo.GetString("Tooltips_Minor"), 	"ff01fcff"},
	{-1, ApolloColor.new("ConEasy"), 		Apollo.GetString("TargetFrame_Easy"), 		Apollo.GetString("Tooltips_Low"), 		"ff597cff"},
	{ 0, ApolloColor.new("ConAverage"), 	Apollo.GetString("TargetFrame_Average"), 	Apollo.GetString("Tooltips_Normal"), 	"ffffffff"},
	{ 1, ApolloColor.new("ConModerate"), 	Apollo.GetString("TargetFrame_Moderate"), 	Apollo.GetString("Tooltips_Improved"), 	"ffffff00"},
	{ 2, ApolloColor.new("ConTough"), 		Apollo.GetString("TargetFrame_Tough"), 		Apollo.GetString("Tooltips_High"), 		"ffff8000"},
	{ 3, ApolloColor.new("ConHard"), 		Apollo.GetString("TargetFrame_Hard"), 		Apollo.GetString("Tooltips_Major"), 	"ffff0000"},
	{ 4, ApolloColor.new("ConImpossible"), 	Apollo.GetString("TargetFrame_Impossible"), Apollo.GetString("Tooltips_Superior"),	"ffff00ff"}
}

local ktRankDescriptions =
{
	[Unit.CodeEnumRank.Fodder] 		= 	Apollo.GetString("TargetFrame_Fodder"),
	[Unit.CodeEnumRank.Minion] 		= 	Apollo.GetString("TargetFrame_Minion"),
	[Unit.CodeEnumRank.Standard]	= 	Apollo.GetString("TargetFrame_Grunt"),
	[Unit.CodeEnumRank.Champion] 	=	Apollo.GetString("TargetFrame_Challenger"),
	[Unit.CodeEnumRank.Superior] 	=  	Apollo.GetString("TargetFrame_Superior"),
	[Unit.CodeEnumRank.Elite] 		= 	Apollo.GetString("TargetFrame_Prime"),
}

local ktRewardToIcon =
{
	[Unit.CodeEnumRewardInfoType.Quest] 			= "CRB_TargetFrameRewardPanelSprites:sprTargetFrame_ActiveQuest",
	[Unit.CodeEnumRewardInfoType.Challenge] 		= "CRB_TargetFrameRewardPanelSprites:sprTargetFrame_Challenge",
	[Unit.CodeEnumRewardInfoType.Explorer] 		= "CRB_TargetFrameRewardPanelSprites:sprTargetFrame_PathExp",
	[Unit.CodeEnumRewardInfoType.Scientist] 		= "CRB_TargetFrameRewardPanelSprites:sprTargetFrame_PathSci",
	[Unit.CodeEnumRewardInfoType.Soldier] 		= "CRB_TargetFrameRewardPanelSprites:sprTargetFrame_PathSol",
	[Unit.CodeEnumRewardInfoType.Settler] 		= "CRB_TargetFrameRewardPanelSprites:sprTargetFrame_PathSet",
	[Unit.CodeEnumRewardInfoType.PublicEvent] 	= "CRB_TargetFrameRewardPanelSprites:sprTargetFrame_PublicEvent",
	[Unit.CodeEnumRewardInfoType.Rival] 			= "ClientSprites:Icon_Windows_UI_CRB_Rival",
	[Unit.CodeEnumRewardInfoType.Friend] 			= "ClientSprites:Icon_Windows_UI_CRB_Friend",
	[Unit.CodeEnumRewardInfoType.ScientistSpell]	= "CRB_TargetFrameRewardPanelSprites:sprTargetFrame_PathSciSpell",
	[Unit.CodeEnumRewardInfoType.Contract]			= "CRB_TargetFrameRewardPanelSprites:sprTargetFrame_Contract"
}

local ktRewardToString =
{
	[Unit.CodeEnumRewardInfoType.Quest] 			= Apollo.GetString("Tooltips_Quest"),
	[Unit.CodeEnumRewardInfoType.Challenge] 		= Apollo.GetString("Tooltips_Challenge"),
	[Unit.CodeEnumRewardInfoType.Explorer] 		= Apollo.GetString("ZoneMap_ExplorerMission"),
	[Unit.CodeEnumRewardInfoType.Scientist] 		= Apollo.GetString("ZoneMap_ScientistMission"),
	[Unit.CodeEnumRewardInfoType.Soldier] 		= Apollo.GetString("ZoneMap_SoldierMission"),
	[Unit.CodeEnumRewardInfoType.Settler] 		= Apollo.GetString("ZoneMap_SettlerMission"),
	[Unit.CodeEnumRewardInfoType.PublicEvent] 	= Apollo.GetString("ZoneMap_PublicEvent"),
	[Unit.CodeEnumRewardInfoType.Rival] 			= Apollo.GetString("Tooltips_Rival"),
	[Unit.CodeEnumRewardInfoType.Friend] 			= Apollo.GetString("Tooltips_Friend"),
	[Unit.CodeEnumRewardInfoType.ScientistSpell]	= Apollo.GetString("PlayerPathScientist"),
	[Unit.CodeEnumRewardInfoType.Contract]			= Apollo.GetString("Tooltips_Contract")
}

local karSigilTypeToIcon =
{
	[Item.CodeEnumRuneType.Air] 	= { strEmpty = "IconSprites:Icon_Windows_UI_RuneSlot_Air_Empty",    	strUsed = "IconSprites:Icon_Windows_UI_RuneSlot_Air_Used" },
	[Item.CodeEnumRuneType.Water] 	= { strEmpty = "IconSprites:Icon_Windows_UI_RuneSlot_Water_Empty",  	strUsed = "IconSprites:Icon_Windows_UI_RuneSlot_Water_Used" },
	[Item.CodeEnumRuneType.Earth] 	= { strEmpty = "IconSprites:Icon_Windows_UI_RuneSlot_Earth_Empty",  	strUsed = "IconSprites:Icon_Windows_UI_RuneSlot_Earth_Used" },
	[Item.CodeEnumRuneType.Fire] 	= { strEmpty = "IconSprites:Icon_Windows_UI_RuneSlot_Fire_Empty",    	strUsed = "IconSprites:Icon_Windows_UI_RuneSlot_Fire_Used" },
	[Item.CodeEnumRuneType.Logic] 	= { strEmpty = "IconSprites:Icon_Windows_UI_RuneSlot_Logic_Empty",   	strUsed = "IconSprites:Icon_Windows_UI_RuneSlot_Logic_Used" },
	[Item.CodeEnumRuneType.Life] 	= { strEmpty = "IconSprites:Icon_Windows_UI_RuneSlot_Life_Empty",    	strUsed = "IconSprites:Icon_Windows_UI_RuneSlot_Life_Used" },
	[Item.CodeEnumRuneType.Omni] 	= { strEmpty = "IconSprites:Icon_Windows_UI_RuneSlot_Omni_Empty",    	strUsed = "IconSprites:Icon_Windows_UI_RuneSlot_Omni_Used" },
	[Item.CodeEnumRuneType.Fusion] = { strEmpty = "IconSprites:Icon_Windows_UI_RuneSlot_Fusion_Empty",		strUsed = "IconSprites:Icon_Windows_UI_RuneSlot_Fusion_Used" },
}

local karSigilTypeToString =
{
	[Item.CodeEnumRuneType.Air] 				= Apollo.GetString("CRB_Air"),
	[Item.CodeEnumRuneType.Water] 				= Apollo.GetString("CRB_Water"),
	[Item.CodeEnumRuneType.Earth] 				= Apollo.GetString("CRB_Earth"),
	[Item.CodeEnumRuneType.Fire] 				= Apollo.GetString("CRB_Fire"),
	[Item.CodeEnumRuneType.Logic] 				= Apollo.GetString("CRB_Logic"),
	[Item.CodeEnumRuneType.Life] 				= Apollo.GetString("CRB_Life"),
	[Item.CodeEnumRuneType.Omni] 				= Apollo.GetString("CRB_Omni"),
	[Item.CodeEnumRuneType.Fusion] 				= Apollo.GetString("CRB_Fusion"),
}

local ktAttributeToText =
{
	[Unit.CodeEnumProperties.Dexterity] 					= Apollo.GetString("CRB_Finesse"),
	[Unit.CodeEnumProperties.Technology] 					= Apollo.GetString("CRB_Tech_Attribute"),
	[Unit.CodeEnumProperties.Magic] 						= Apollo.GetString("CRB_Moxie"),
	[Unit.CodeEnumProperties.Wisdom] 						= Apollo.GetString("UnitPropertyInsight"),
	[Unit.CodeEnumProperties.Stamina] 						= Apollo.GetString("CRB_Grit"),
	[Unit.CodeEnumProperties.Strength] 						= Apollo.GetString("CRB_Brutality"),

	[Unit.CodeEnumProperties.Armor] 						= Apollo.GetString("CRB_Armor") ,
	[Unit.CodeEnumProperties.ShieldCapacityMax] 			= Apollo.GetString("CBCrafting_Shields"),

	[Unit.CodeEnumProperties.AssaultPower] 					= Apollo.GetString("CRB_Assault_Power"),
	[Unit.CodeEnumProperties.SupportPower] 					= Apollo.GetString("CRB_Support_Power"),
	[Unit.CodeEnumProperties.Rating_AvoidReduce] 			= Apollo.GetString("CRB_Strikethrough_Rating"),
	[Unit.CodeEnumProperties.Rating_CritChanceIncrease] 	= Apollo.GetString("CRB_Critical_Chance"),
	[Unit.CodeEnumProperties.RatingCritSeverityIncrease] 	= Apollo.GetString("CRB_Critical_Severity"),
	[Unit.CodeEnumProperties.Rating_AvoidIncrease] 			= Apollo.GetString("CRB_Deflect_Rating"),
	[Unit.CodeEnumProperties.Rating_CritChanceDecrease] 	= Apollo.GetString("CRB_Deflect_Critical_Hit_Rating"),
	[Unit.CodeEnumProperties.ManaPerFiveSeconds] 			= Apollo.GetString("CRB_Attribute_Recovery_Rating"),
	[Unit.CodeEnumProperties.HealthRegenMultiplier] 		= Apollo.GetString("CRB_Health_Regen_Factor"),
	[Unit.CodeEnumProperties.BaseHealth] 					= Apollo.GetString("CRB_Health_Max"),

	[Unit.CodeEnumProperties.ResistTech] 					= Apollo.GetString("Tooltip_ResistTech"),
	[Unit.CodeEnumProperties.ResistMagic]					= Apollo.GetString("Tooltip_ResistMagic"),
	[Unit.CodeEnumProperties.ResistPhysical]				= Apollo.GetString("Tooltip_ResistPhysical"),

	[Unit.CodeEnumProperties.PvPOffensiveRating] 			= Apollo.GetString("Tooltip_PvPOffense"),
	[Unit.CodeEnumProperties.PvPDefensiveRating]			= Apollo.GetString("Tooltip_PvPDefense"),
}

-- TODO REFACTOR, we can combine all these item quality tables into one
local karEvalColors =
{
	[Item.CodeEnumItemQuality.Inferior] 		= "ItemQuality_Inferior",
	[Item.CodeEnumItemQuality.Average] 			= "ItemQuality_Average",
	[Item.CodeEnumItemQuality.Good] 			= "ItemQuality_Good",
	[Item.CodeEnumItemQuality.Excellent] 		= "ItemQuality_Excellent",
	[Item.CodeEnumItemQuality.Superb] 			= "ItemQuality_Superb",
	[Item.CodeEnumItemQuality.Legendary] 		= "ItemQuality_Legendary",
	[Item.CodeEnumItemQuality.Artifact]		 	= "ItemQuality_Artifact",
}

local karEvalSprites =
{
	[Item.CodeEnumItemQuality.Inferior] 		= "sprTT_HeaderDarkGrey",
	[Item.CodeEnumItemQuality.Average] 			= "sprTT_HeaderWhite",
	[Item.CodeEnumItemQuality.Good] 			= "sprTT_HeaderGreen",
	[Item.CodeEnumItemQuality.Excellent] 		= "sprTT_HeaderBlue",
	[Item.CodeEnumItemQuality.Superb] 			= "sprTT_HeaderPurple",
	[Item.CodeEnumItemQuality.Legendary] 		= "sprTT_HeaderOrange",
	[Item.CodeEnumItemQuality.Artifact]		 	= "sprTT_HeaderLightPurple",
}

local karEvalInsetSprites =
{
	[Item.CodeEnumItemQuality.Inferior] 		= "sprTT_HeaderInsetDarkGrey",
	[Item.CodeEnumItemQuality.Average] 			= "sprTT_HeaderInsetWhite",
	[Item.CodeEnumItemQuality.Good] 			= "sprTT_HeaderInsetGreen",
	[Item.CodeEnumItemQuality.Excellent] 		= "sprTT_HeaderInsetBlue",
	[Item.CodeEnumItemQuality.Superb] 			= "sprTT_HeaderInsetPurple",
	[Item.CodeEnumItemQuality.Legendary] 		= "sprTT_HeaderOrange",
	[Item.CodeEnumItemQuality.Artifact]		 	= "sprTT_HeaderInsetLightPurple"
}

local karEvalStrings =
{
	[Item.CodeEnumItemQuality.Inferior] 		= Apollo.GetString("CRB_Inferior"),
	[Item.CodeEnumItemQuality.Average] 			= Apollo.GetString("CRB_Average"),
	[Item.CodeEnumItemQuality.Good] 			= Apollo.GetString("CRB_Good"),
	[Item.CodeEnumItemQuality.Excellent] 		= Apollo.GetString("CRB_Excellent"),
	[Item.CodeEnumItemQuality.Superb] 			= Apollo.GetString("CRB_Superb"),
	[Item.CodeEnumItemQuality.Legendary] 		= Apollo.GetString("CRB_Legendary"),
	[Item.CodeEnumItemQuality.Artifact]		 	= Apollo.GetString("CRB_Artifact")
}

local karItemQualityToHeaderBG =
{
	[Item.CodeEnumItemQuality.Inferior] 		= "CRB_Tooltips:sprTooltip_Header_Silver",
	[Item.CodeEnumItemQuality.Average] 			= "CRB_Tooltips:sprTooltip_Header_White",
	[Item.CodeEnumItemQuality.Good] 			= "CRB_Tooltips:sprTooltip_Header_Green",
	[Item.CodeEnumItemQuality.Excellent] 		= "CRB_Tooltips:sprTooltip_Header_Blue",
	[Item.CodeEnumItemQuality.Superb] 			= "CRB_Tooltips:sprTooltip_Header_Purple",
	[Item.CodeEnumItemQuality.Legendary] 		= "CRB_Tooltips:sprTooltip_Header_Orange",
	[Item.CodeEnumItemQuality.Artifact]		 	= "CRB_Tooltips:sprTooltip_Header_Pink",
}

local karItemQualityToHeaderBar =
{
	[Item.CodeEnumItemQuality.Inferior] 		= "CRB_Tooltips:sprTooltip_RarityBar_Silver",
	[Item.CodeEnumItemQuality.Average] 			= "CRB_Tooltips:sprTooltip_RarityBar_White",
	[Item.CodeEnumItemQuality.Good] 			= "CRB_Tooltips:sprTooltip_RarityBar_Green",
	[Item.CodeEnumItemQuality.Excellent] 		= "CRB_Tooltips:sprTooltip_RarityBar_Blue",
	[Item.CodeEnumItemQuality.Superb] 			= "CRB_Tooltips:sprTooltip_RarityBar_Purple",
	[Item.CodeEnumItemQuality.Legendary] 		= "CRB_Tooltips:sprTooltip_RarityBar_Orange",
	[Item.CodeEnumItemQuality.Artifact]		 	= "CRB_Tooltips:sprTooltip_RarityBar_Pink",
}

local karItemQualityToBorderFrameBG =
{
	[Item.CodeEnumItemQuality.Inferior] 		= "CRB_Tooltips:sprTooltip_SquareFrame_Silver",
	[Item.CodeEnumItemQuality.Average] 			= "CRB_Tooltips:sprTooltip_SquareFrame_White",
	[Item.CodeEnumItemQuality.Good] 			= "CRB_Tooltips:sprTooltip_SquareFrame_Green",
	[Item.CodeEnumItemQuality.Excellent] 		= "CRB_Tooltips:sprTooltip_SquareFrame_Blue",
	[Item.CodeEnumItemQuality.Superb] 			= "CRB_Tooltips:sprTooltip_SquareFrame_Purple",
	[Item.CodeEnumItemQuality.Legendary] 		= "CRB_Tooltips:sprTooltip_SquareFrame_Orange",
	[Item.CodeEnumItemQuality.Artifact]		 	= "CRB_Tooltips:sprTooltip_SquareFrame_Pink",
}

local kcrGroupTextColor					= ApolloColor.new("crayBlizzardBlue")
local kcrFlaggedFriendlyTextColor 		= karDispositionColors[Unit.CodeEnumDisposition.Friendly]
local kcrDefaultUnflaggedAllyTextColor 	= karDispositionColors[Unit.CodeEnumDisposition.Friendly]
local kcrAggressiveEnemyTextColor 		= karDispositionColors[Unit.CodeEnumDisposition.Neutral]
local kcrNeutralEnemyTextColor 			= ApolloColor.new("crayDenim")

function ForgeUI_ToolTips:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- mandatory 
    self.api_version = 2
	self.version = "1.0.0"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_ToolTips"
	self.strDisplayName = "ToolTips"
	
	self.wndContainers = {}
	
	self.tStylers = {}
	
	-- optional
	self.settings_version = 1
    self.tSettings = {}


    return o
end

local ForgeUI_ToolTipsInst

function ForgeUI_ToolTips:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"ForgeUI"
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)

	if ForgeUI == nil then -- forgeui loaded
		ForgeUI = Apollo.GetAddon("ForgeUI", "Tooltips")
	end
	
	ForgeUI.API_RegisterAddon(self)
end

function ForgeUI_ToolTips:OnLoad()
    self.xmlDoc = XmlDoc.CreateFromFile("ForgeUI_ToolTips.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

function ForgeUI_ToolTips:OnDocLoaded()
	if self.xmlDoc ~= nil or not self.xmlDoc:IsLoaded() then return end
end

local GenerateBuffTooltipForm
local GenerateSpellTooltipForm
local GenerateItemTooltipForm

function ForgeUI_ToolTips:ForgeAPI_AfterRegistration()
	ToolTips_OnDocumentReady = ToolTips.OnDocumentReady
	ToolTips.OnDocumentReady = ForgeUI_ToolTips.TooltipsHook_OnDocumentReady
	
	-- hooks
	ToolTips.UnitTooltipGen = self.UnitTooltipGen
end

local origGenerateBuffTooltipForm
local origGenerateSpellTooltipForm
local origGenerateItemTooltipForm

function ForgeUI_ToolTips.TooltipsHook_OnDocumentReady(tooltips)
	ToolTips_OnDocumentReady(tooltips)
	local ToolTipsInst = tooltips
	
	origGenerateBuffTooltipForm = Tooltip.GetBuffTooltipForm
	Tooltip.GetBuffTooltipForm = GenerateBuffTooltipForm
	
	origGenerateSpellTooltipForm = Tooltip.GetSpellTooltipForm 
	Tooltip.GetSpellTooltipForm  = GenerateSpellTooltipForm
	
	origGenerateItemTooltipForm = Tooltip.GetItemTooltipForm
	Tooltip.GetItemTooltipForm = GenerateItemTooltipForm
end

-----------------------------------------------------------------------------------------------
-- Hooks
-----------------------------------------------------------------------------------------------
GenerateBuffTooltipForm = function(luaCaller, wndParent, splSource, tFlags)
	local wndToolTip = origGenerateBuffTooltipForm(luaCaller, wndParent, splSource, tFlags)
	
	wndToolTip:SetStyle("Picture", true)
	wndToolTip:SetStyle("Border", false)
	wndToolTip:SetSprite("ForgeUI_Border")
	wndToolTip:SetBGColor("FF000000")
	
	wndToolTip:FindChild("NameString"):SetStyle("Picture", true)
	wndToolTip:FindChild("NameString"):SetSprite("ForgeUI_Border")
	wndToolTip:FindChild("NameString"):SetBGColor("FF000000")
	
	wndToolTip:FindChild("GeneralDescriptionString"):SetStyle("Picture", true)
	wndToolTip:FindChild("GeneralDescriptionString"):SetSprite("ForgeUI_Border")
	wndToolTip:FindChild("GeneralDescriptionString"):SetBGColor("FF000000")
	
	local nLeft, nTop, nRight, nBottom = wndToolTip:GetAnchorOffsets()
	wndToolTip:SetAnchorOffsets(nLeft, nTop, nRight, nBottom - 45)
end

GenerateSpellTooltipForm = function(luaCaller, wndParent, splSource, tFlags)
	local wndToolTip = origGenerateSpellTooltipForm(luaCaller, wndParent, splSource, tFlags)
	
	wndToolTip:SetSprite("ForgeUI_Border")
	wndToolTip:SetBGColor("FF000000")
	
	wndToolTip:FindChild("BGArt2"):SetSprite("ForgeUI_Border")
	wndToolTip:FindChild("BGArt2"):SetBGColor("FF000000")
	wndToolTip:FindChild("BGArt2"):SetAnchorOffsets(3, 3, -3, -3)
end

GenerateItemTooltipForm = function(luaCaller, wndParent, itemSource, tFlags, nCount)
	local wndToolTip, wndTooltipComp = origGenerateItemTooltipForm(luaCaller, wndParent, itemSource, tFlags, nCount)
	
	wndToolTip:FindChild("ItemTooltipBG"):SetSprite("ForgeUI_Border")
	wndToolTip:FindChild("ItemTooltipBG"):SetBGColor("FF000000")
	
	wndToolTip:FindChild("CurrentHeader"):SetSprite("ForgeUI_Border")
	wndToolTip:FindChild("CurrentHeader"):SetBGColor("FF000000")
	
	wndToolTip:FindChild("ItemTooltip_BaseRarityFrame"):SetSprite("ForgeUI_Border")
	wndToolTip:FindChild("ItemTooltip_BaseRarityFrame"):SetBGColor("FF000000")
	
	if wndTooltipComp then
		wndTooltipComp:FindChild("ItemTooltipBG"):SetSprite("ForgeUI_Border")
		wndTooltipComp:FindChild("ItemTooltipBG"):SetBGColor("FF000000")
		
		wndTooltipComp:FindChild("CurrentHeader"):SetSprite("ForgeUI_Border")
		wndTooltipComp:FindChild("CurrentHeader"):SetBGColor("FF000000")
		
		wndTooltipComp:FindChild("ItemTooltip_BaseRarityFrame"):SetSprite("ForgeUI_Border")
		wndTooltipComp:FindChild("ItemTooltip_BaseRarityFrame"):SetBGColor("FF000000")
	end
end

function ForgeUI_ToolTips:UnitTooltipGen(wndContainer, unitSource, strProp)
	local wndTooltipForm = nil
	local bSkipFormatting = false -- used to identify when we switch to item tooltips (aka pinata loot)
	local bNoDisposition = false -- used to replace dispostion assets when they're not needed
	local bHideFormSecondary = true

	if not unitSource and strProp == "" then
		wndContainer:SetTooltipForm(nil)
		wndContainer:SetTooltipFormSecondary(nil)
		return
	elseif strProp ~= "" then
		if not self.wndPropTooltip or not self.wndPropTooltip:IsValid() then
			--self.wndPropTooltip = wndContainer:LoadTooltipForm("ui\\Tooltips\\TooltipsForms.xml", "PropTooltip_Base", self) -- ForgeUI
			self.wndPropTooltip = Apollo.LoadForm(ForgeUI_ToolTipsInst.xmlDoc, "PropTooltip_Base", nil, self)
		end
		self.wndPropTooltip:FindChild("NameString"):SetText(strProp)

		local tMouse = Apollo.GetMouse()
		Apollo.SetNavTextAnchor(tMouse.x + 10, true, tMouse.y + 10, false)
		
		wndContainer:SetTooltipForm(self.wndPropTooltip)
		wndContainer:SetTooltipFormSecondary(nil)
		return
	end
	
	local nScreenWidth, nScreenHeight = Apollo.GetScreenSize()
	Apollo.SetNavTextAnchor(10, true, nScreenHeight - 332, false)

	if not self.wndUnitTooltip or not self.wndUnitTooltip:IsValid() then
		--self.wndUnitTooltip = wndContainer:LoadTooltipForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Base", self) -- ForgeUI
		self.wndUnitTooltip = Apollo.LoadForm(ForgeUI_ToolTipsInst.xmlDoc, "UnitTooltip_Base", nil, self)
	end

	local wndTopDataBlock 			= self.wndUnitTooltip:FindChild("TopDataBlock")
	local wndMiddleDataBlock 		= self.wndUnitTooltip:FindChild("MiddleDataBlock") -- THIS GETS USED FOR A LOT!!
	local wndBottomDataBlock 		= self.wndUnitTooltip:FindChild("BottomDataBlock")
	local wndTopRight				= wndTopDataBlock:FindChild("RightSide")
	local wndMiddleDataBlockContent = wndMiddleDataBlock:FindChild("MiddleDataBlockContent")
	local wndPathIcon 				= wndTopRight:FindChild("PathIcon")
	local wndClassIcon 				= wndTopRight:FindChild("ClassIcon")
	local wndClassBack 				= wndTopRight:FindChild("ClassBack")
	local wndPathBack 				= wndTopRight:FindChild("PathBack")
	local wndLevelBack 				= wndTopRight:FindChild("LevelBack")
	local wndXpAwardString 			= wndBottomDataBlock:FindChild("XpAwardString")
	local wndBreakdownString 		= wndBottomDataBlock:FindChild("BreakdownString")
	local wndDispositionFrame 		= self.wndUnitTooltip:FindChild("DispositionArtFrame")
	local wndNameString 			= wndTopDataBlock:FindChild("NameString")
	local wndLevelString 			= self.wndUnitTooltip:FindChild("LevelString")
	local wndAffiliationString 		= self.wndUnitTooltip:FindChild("AffiliationString")

	local unitPlayer = GameLib.GetPlayerUnit()
	local eDisposition = unitSource:GetDispositionTo(unitPlayer)

	local fullWndLeft, fullWndTop, fullWndRight, fullWndBottom = self.wndUnitTooltip:GetAnchorOffsets()
	local topBlockLeft, topBlockTop, topBlockRight, topBlockBottom = self.wndUnitTooltip:FindChild("TopDataBlock"):GetAnchorOffsets()

	-- Basics
	wndLevelString:SetText(unitSource:GetLevel())
	wndNameString:SetText(string.format("<P Font=\"CRB_HeaderSmall_O\" TextColor=\"%s\">%s</P>", karDispositionColorStrings[eDisposition], unitSource:GetName()))
	
	-- Unit to player affiliation
	local strAffiliationName = unitSource:GetAffiliationName() or ""
	wndAffiliationString:SetTextRaw(strAffiliationName)
	wndAffiliationString:Show(strAffiliationName ~= "")
	wndAffiliationString:SetTextColor(karDispositionColors[eDisposition])

	-- Reward info
	wndMiddleDataBlockContent:DestroyChildren()
	for idx, tRewardInfo in pairs(unitSource:GetRewardInfo() or {}) do
		local eRewardType = tRewardInfo.eType
		local bCanAddReward = true

		-- Only show active challenge rewards
		if eRewardType == Unit.CodeEnumRewardInfoType.Challenge then
			bCanAddReward = false
			for index, clgCurr in pairs(ChallengesLib.GetActiveChallengeList()) do
				if tRewardInfo.idChallenge == clgCurr:GetId() and clgCurr:IsActivated() and not clgCurr:IsInCooldown() and not clgCurr:ShouldCollectReward() then
					bCanAddReward = true
					break
				end
			end
		end

		if bCanAddReward and ktRewardToIcon[eRewardType] and ktRewardToString[eRewardType] then
			if eRewardType == Unit.CodeEnumRewardInfoType.PublicEvent then
				tRewardInfo.strTitle = tRewardInfo.peoObjective:GetEvent():GetName() or ""
			elseif eRewardType == Unit.CodeEnumRewardInfoType.Soldier or eRewardType == Unit.CodeEnumRewardInfoType.Explorer or eRewardType == Unit.CodeEnumRewardInfoType.Settler then
				tRewardInfo.strTitle = tRewardInfo.pmMission and tRewardInfo.pmMission:GetName() or ""
			elseif eRewardType == Unit.CodeEnumRewardInfoType.Scientist then
				if tRewardInfo.pmMission then
					if tRewardInfo.pmMission:GetMissionState() >= PathMission.PathMissionState_Unlocked then
						tRewardInfo.strTitle = tRewardInfo.pmMission:GetName()
					else
						tRewardInfo.strTitle = Apollo.GetString("TargetFrame_UnknownReward")
					end
				end
			end

			if tRewardInfo.strTitle and tRewardInfo.strTitle ~= "" then
				local wndReward = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Reward", wndMiddleDataBlockContent, self)
				wndReward:FindChild("Icon"):SetSprite(ktRewardToIcon[eRewardType])
				wndReward:FindChild("Label"):SetText(String_GetWeaselString(Apollo.GetString("Tooltip_TitleReward"), tRewardInfo.strTitle, ktRewardToString[eRewardType]))

				-- Adjust height to fit text
				wndReward:FindChild("Label"):SetHeightToContentHeight()
				if wndReward:FindChild("Label"):GetHeight() > wndReward:GetHeight() then
					local rewardWndLeft, rewardWndTop, rewardWndRight, rewardWndBottom = wndReward:GetAnchorOffsets()
					wndReward:SetAnchorOffsets(rewardWndLeft, rewardWndTop, rewardWndRight, wndReward:FindChild("Label"):GetHeight() + 3) -- +3 for decenders
				end
			end
		end
	end

	local strUnitType = unitSource:GetType()
	if strUnitType == "Player" then

		-- Player
		local tSourceStats = unitSource:GetBasicStats()
		local ePathType = unitSource:GetPlayerPathType()
		local eClassType = unitSource:GetClassId()
		local bIsPvpFlagged = unitSource:IsPvpFlagged()

		wndPathIcon:SetSprite(ktPathToIcon[ePathType])
		wndClassIcon:SetSprite(ktClassToIcon[eClassType])

		-- Player specific affiliation override
		local strPlayerAffiliationName = unitSource:GetGuildName()
		if strPlayerAffiliationName then
			wndAffiliationString:SetTextRaw(String_GetWeaselString(Apollo.GetString("Nameplates_GuildDisplay"), strPlayerAffiliationName))
			wndAffiliationString:Show(true)
		end

		-- Player specific disposition color override
		local crColorToUse = karDispositionColors[eDisposition]
		if eDisposition == Unit.CodeEnumDisposition.Friendly then
			if unitSource:IsPvpFlagged() then
				crColorToUse = kcrFlaggedFriendlyTextColor
			elseif unitSource:IsInYourGroup() then
				crColorToUse = kcrGroupTextColor
			else
				crColorToUse = kcrDefaultUnflaggedAllyTextColor
			end
		else
			local bIsUnitFlagged = unitSource:IsPvpFlagged()
			local bAmIFlagged = GameLib.IsPvpFlagged()
			if not bAmIFlagged and not bIsUnitFlagged then
				crColorToUse = kcrNeutralEnemyTextColor
			elseif bAmIFlagged ~= bIsUnitFlagged then
				crColorToUse = kcrAggressiveEnemyTextColor
			end
		end
		wndNameString:SetTextColor(crColorToUse)
		wndAffiliationString:SetTextColor(crColorToUse)

		-- Determine if Exile Human or Cassian
		local strRaceString = ""
		local nRaceID = unitSource:GetRaceId()
		local nFactionID = unitSource:GetFaction()
		if nRaceID == GameLib.CodeEnumRace.Human then
			if nFactionID == Unit.CodeEnumFaction.ExilesPlayer then
				strRaceString = Apollo.GetString("CRB_ExileHuman")
			elseif nFactionID == Unit.CodeEnumFaction.DominionPlayer then
				strRaceString = Apollo.GetString("CRB_Cassian")
			end
		else
			strRaceString = karRaceToString[nRaceID]
		end

		local strBreakdown = String_GetWeaselString(Apollo.GetString("Tooltip_CharacterDescription"), tSourceStats.nLevel, strRaceString)
		if tSourceStats.nEffectiveLevel ~= 0 and unitSource:IsMentoring() then -- GOTCHA: Intentionally we don't care about IsRallied()
			strBreakdown = String_GetWeaselString(Apollo.GetString("Tooltips_MentoringAppend"), strBreakdown, tSourceStats.nEffectiveLevel)
		end
		if bIsPvpFlagged then
			strBreakdown = String_GetWeaselString(Apollo.GetString("Tooltips_PvpFlagged"), strBreakdown)
		end
		wndBreakdownString:SetText(strBreakdown)

		-- Friend or Rival
		if unitSource:IsFriend() then
			local wndReward = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Reward", wndMiddleDataBlockContent, self)
			wndReward:FindChild("Icon"):SetSprite(ktRewardToIcon[Unit.CodeEnumRewardInfoType.Friend])
			wndReward:FindChild("Label"):SetText(ktRewardToString[Unit.CodeEnumRewardInfoType.Friend])
			wndMiddleDataBlockContent:Show(true)
		end

		if unitSource:IsRival() then
			local wndReward = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Reward", wndMiddleDataBlockContent, self)
			wndReward:FindChild("Icon"):SetSprite(ktRewardToIcon[Unit.CodeEnumRewardInfoType.Rival])
			wndReward:FindChild("Label"):SetText(ktRewardToString[Unit.CodeEnumRewardInfoType.Rival])
			wndMiddleDataBlockContent:Show(true)
		end
		
		local wndInfo = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
		wndInfo:FindChild("Label"):SetText(Apollo.GetString("Tooltips_RealmUnknown"))
		self.tRealmNamePendingCallbacks[unitSource:GetId()] = function(strRealmName)
			if wndInfo:IsValid() then
				wndInfo:FindChild("Label"):SetText(String_GetWeaselString(Apollo.GetString("Tooltips_RealmFrom"), strRealmName))
			end
		end
		unitSource:RequestRealmName()
		
		wndMiddleDataBlockContent:Show(true)

		wndBottomDataBlock:Show(true)
		wndPathIcon:Show(true)
		wndClassIcon:Show(true)
		wndLevelString:Show(true)
		wndXpAwardString:Show(false)
		wndBreakdownString:Show(true)

	elseif karNPCDispositionUnitTypes[strUnitType] then
		-- NPC
		local nCon = self:HelperCalculateConValue(unitSource)
		if nCon == 1 or not unitSource:CanGrantXp() then
			wndXpAwardString:SetAML("")
		else
			if unitPlayer:GetLevel() == knMaxLevel and nCon >= 5 then -- 5 = same level as target
				strXPFinal = String_GetWeaselString(Apollo.GetString("Tooltips_XPAwardValue"), Apollo.GetString("Tooltips_XpAward"), Apollo.GetString("CRB_Elder_Gems"))
			else
				strXPFinal = String_GetWeaselString(Apollo.GetString("Tooltips_XPAwardValue"), Apollo.GetString("Tooltips_XpAward"), karConInfo[nCon][4])
			end
			wndXpAwardString:SetAML(string.format("<P Font=\"CRB_InterfaceSmall\" TextColor=\"UI_TextHoloBody\" Align=\"Right\">%s</P>", strXPFinal))
		end
		wndBreakdownString:SetText(ktRankDescriptions[unitSource:GetRank()] or "")

		-- Settler improvement
		if unitSource:IsSettlerImprovement() then
			if unitSource:IsSettlerReward() then
				local strSettlerRewardName = String_GetWeaselString(Apollo.GetString("Tooltips_SettlerReward"), unitSource:GetSettlerRewardName(), Apollo.GetString("CRB_Settler_Reward"))
				local wndInfo = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
				wndInfo:FindChild("Label"):SetText(strSettlerRewardName)
			else
				local tSettlerImprovementInfo = unitSource:GetSettlerImprovementInfo()

				for idx, strOwnerName in pairs(tSettlerImprovementInfo.arOwnerNames) do
					local wndInfo = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
					wndInfo:FindChild("Label"):SetText(Apollo.GetString("Tooltips_GetSettlerDepot")..strOwnerName)
				end

				if not tSettlerImprovementInfo.bIsInfiniteDuration then
					local strSettlerTimeRemaining = string.format(Apollo.GetString("CRB_Remaining_Time_Format"), tSettlerImprovementInfo.nRemainingTime)
					local wndInfo = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
					wndInfo:FindChild("Label"):SetText(strSettlerTimeRemaining)
					self:AddTimedWindow(tSettlerImprovementInfo.nRemainingTime, 1, 0, Apollo.GetString("CRB_Remaining_Time_Format"), wndInfo:FindChild("Label"))
				end

				for idx, tTier in pairs(tSettlerImprovementInfo.arTiers) do
					local wndInfo = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
					wndInfo:FindChild("Label"):SetText(String_GetWeaselString(Apollo.GetString("Tooltips_SettlerTier"), tTier.nTier, tTier.strName))
				end
			end
		end

		-- Friendly Warplot structure
		if unitSource:IsFriendlyWarplotStructure() then
			local strCurrentTier = String_GetWeaselString(Apollo.GetString("CRB_WarplotPlugTier"), unitSource:GetCurrentWarplotTier())
			local wndCurrentTier = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
			wndCurrentTier:FindChild("Label"):SetText(strCurrentTier)
			if unitSource:CanUpgradeWarplotStructure() then
				local strCurrentCost = String_GetWeaselString(Apollo.GetString("CRB_WarplotPlugUpgradeCost"), unitSource:GetCurrentWarplotUpgradeCost())
				local wndCurrentCost = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
				wndCurrentCost:FindChild("Label"):SetText(strCurrentCost)
			end
		end

		wndBottomDataBlock:Show(true)
		wndPathIcon:Show(false)
		wndClassIcon:Show(false)
		wndLevelString:Show(true)
		wndXpAwardString:Show(eDisposition == Unit.CodeEnumDisposition.Hostile or eDisposition == Unit.CodeEnumDisposition.Neutral)
		wndBreakdownString:Show(unitSource:ShouldShowNamePlate())

	elseif karSimpleDispositionUnitTypes[strUnitType] then

		-- Simple
		bNoDisposition = true

		wndBottomDataBlock:Show(false)
		wndPathIcon:Show(false)
		wndClassIcon:Show(false)
		wndLevelString:Show(true)
		wndXpAwardString:Show(false)
		wndBreakdownString:Show(false)

	elseif strUnitType == "InstancePortal" then
		-- Instance Portal
		bNoDisposition = true

		local tLevelRange = unitSource:GetInstancePortalLevelRange()
		if tLevelRange and tLevelRange.nMinLevel and tLevelRange.nMaxLevel then
			local strInstancePortalLevelRange = ""
			if tLevelRange.nMinLevel == tLevelRange.nMaxLevel then
				strInstancePortalLevelRange = string.format(Apollo.GetString("InstancePortal_RequiredLevel"), tLevelRange.nMaxLevel)
			else
				strInstancePortalLevelRange = string.format(Apollo.GetString("InstancePortal_LevelRange"), tLevelRange.nMinLevel, tLevelRange.nMaxLevel)
			end
			local wndInfo = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
			wndInfo:FindChild("Label"):SetText(strInstancePortalLevelRange)
		end

		local nPortalCompletionTime = unitSource:GetInstancePortalCompletionTime()
		if nPortalCompletionTime then
			local strInstanceCompletionTime = string.format(Apollo.GetString("InstancePortal_ExpectedCompletionTime"), nPortalCompletionTime)
			local wndInfo = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
			wndInfo:FindChild("Label"):SetText(strInstanceCompletionTime)
		end

		local nPortalRemainingTime = unitSource:GetInstancePortalRemainingTime()
		if nPortalRemainingTime and nPortalRemainingTime > 0 then
			local strInstancePortalRemainingTime = string.format(Apollo.GetString("CRB_Remaining_Time_Format"), nPortalRemainingTime)
			local wndInfo = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
			wndInfo:FindChild("Label"):SetText(strInstancePortalRemainingTime)

			self:AddTimedWindow(nPortalRemainingTime, 1, 0, Apollo.GetString("CRB_Remaining_Time_Format"), wndInfo:FindChild("Label"))
		end

		wndBottomDataBlock:Show(false)
		wndPathIcon:Show(false)
		wndClassIcon:Show(false)
		wndLevelString:Show(false)
		wndXpAwardString:Show(false)
		wndBreakdownString:Show(false)

	elseif strUnitType == "Harvest" then
		-- Harvestable
		bNoDisposition = true

		local strHarvestRequiredTradeskillName = unitSource:GetHarvestRequiredTradeskillName()

		if strHarvestRequiredTradeskillName and strHarvestRequiredTradeskillName ~= "" then
			wndBreakdownString:SetText(string.format(Apollo.GetString("CRB_Requires_Tradeskill_Tier"), strHarvestRequiredTradeskillName, unitSource:GetHarvestRequiredTradeskillTier() or ""))

			wndBottomDataBlock:Show(true)
			wndLevelString:Show(false)
			wndBreakdownString:Show(true)
		else
			wndBottomDataBlock:Show(false)
			wndLevelString:Show(true)
			wndBreakdownString:Show(false)
		end

		wndPathIcon:Show(false)
		wndClassIcon:Show(false)
		wndXpAwardString:Show(false)

	elseif strUnitType == "PinataLoot" then
		local tLoot = unitSource:GetLoot()
		if tLoot then
			bNoDisposition = true

			if tLoot.eLootItemType == Unit.CodeEnumLootItemType.StaticItem then
				bHideFormSecondary = false
				local itemEquipped = tLoot.itemLoot:GetEquippedItemForItemType()
				local tTooltipData = {bPrimary = true, itemCompare = itemEquipped, itemModData = tLoot.itemModData, tGlyphData = tLoot.itemSigilData}

				-- Overwrite everything and show itemLoot tooltip instead
				wndTooltipForm = Tooltip.GetItemTooltipForm(self, wndContainer, tLoot.itemLoot, tTooltipData)
				bSkipFormatting = true
			elseif tLoot.eLootItemType == Unit.CodeEnumLootItemType.Cash then
				local wndCash = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Cash", wndMiddleDataBlockContent, self)
				wndCash:FindChild("CashWindow"):SetAmount(tLoot.monCurrency, true)

			elseif tLoot.eLootItemType == Unit.CodeEnumLootItemType.VirtualItem then
				local wndLoot = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_PinataLoot", wndMiddleDataBlockContent, self)
				local wndLootLeft, wndLootTop, wndLootRight, wndLootBottom = wndLoot:GetAnchorOffsets()

				wndLoot:FindChild("TextWindow"):SetText(tLoot.tVirtualItem.strFlavor)
				wndLoot:FindChild("TextWindow"):SetHeightToContentHeight()
				wndLoot:SetAnchorOffsets( wndLootLeft, wndLootTop, wndLootRight, math.max(wndLootBottom, wndLoot:FindChild("TextWindow"):GetHeight()))

			elseif tLoot.eLootItemType == Unit.CodeEnumLootItemType.AdventureSpell then
				local wndLoot = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_PinataLoot", wndMiddleDataBlockContent, self)
				local wndLootLeft, wndLootTop, wndLootRight, wndLootBottom = wndLoot:GetAnchorOffsets()

				wndLoot:FindChild("TextWindow"):SetText(tLoot.tAbility.strDescription)
				wndLoot:FindChild("TextWindow"):SetHeightToContentHeight()
				wndLoot:SetAnchorOffsets( wndLootLeft, wndLootTop, wndLootRight, math.max(wndLootBottom, wndLoot:FindChild("TextWindow"):GetHeight()))
			end
		end

		wndBottomDataBlock:Show(false)
		wndPathIcon:Show(false)
		wndClassIcon:Show(false)
		wndLevelString:Show(false)
		wndXpAwardString:Show(false)
		wndBreakdownString:Show(false)

	else -- error state, do name only
		bNoDisposition = true

		wndBottomDataBlock:Show(false)
		wndPathIcon:Show(false)
		wndClassIcon:Show(false)
		wndLevelString:Show(true)
		wndXpAwardString:Show(false)
		wndBreakdownString:Show(false)
	end

	-- formatting and resizing --
	if not bSkipFormatting then
		if bNoDisposition then
			wndNameString:SetTextColor(ApolloColor.new("UI_TextHoloBodyHighlight"))
			--wndDispositionFrame:SetSprite("sprTooltip_SquareFrame_UnitTeal") -- ForgeUI
		end

		wndClassBack:Show(wndClassIcon:IsShown())
		wndPathBack:Show(wndPathIcon:IsShown())
		wndLevelBack:Show(wndLevelString:GetText() ~= "")

		-- Right anchor of name
		local lsLeft, lsTop, lsRight, lsBottom = wndNameString:GetAnchorOffsets()
		if wndPathIcon:IsShown() then
			local pathLeft, pathTop, pathRight, pathBottom = wndPathBack:GetAnchorOffsets()
			wndNameString:SetAnchorOffsets(lsLeft, lsTop, pathLeft - 20, lsBottom)
		elseif wndClassIcon:IsShown() then
			local classLeft, classTop, classRight, classBottom = wndClassBack:GetAnchorOffsets()
			wndNameString:SetAnchorOffsets(lsLeft, lsTop, classLeft - 20, lsBottom)
		elseif wndLevelString:IsShown() then
			local levelLeft, levelTop, levelRight, levelBottom = wndLevelBack:GetAnchorOffsets()
			wndNameString:SetAnchorOffsets(lsLeft, lsTop, levelLeft - 20, lsBottom)
		else
			local levelLeft, levelTop, levelRight, levelBottom = wndLevelBack:GetAnchorOffsets()
			wndNameString:SetAnchorOffsets(lsLeft, lsTop, levelRight, lsBottom)
		end

		-- Vertical Height
		local nHeight = 16 -- Space between the bottom of BottomDataBlock and the bottom of the entire window

		local nNameWidth, nNameHeight = wndNameString:SetHeightToContentHeight()
		nNameHeight = math.max(nNameHeight, 32) -- 32 is starting height from XML
		local nTopDataBlockLeft, nTopDataBlockTop, nTopDataBlockRight, nTopDataBlockBottom = wndTopDataBlock:GetAnchorOffsets()
		wndTopDataBlock:SetAnchorOffsets(nTopDataBlockLeft, nTopDataBlockTop, nTopDataBlockRight, nTopDataBlockTop + math.max(32, lsTop + nNameHeight))

		local nTopDataBlockHeight = wndTopDataBlock:GetHeight()
		nHeight = nHeight + nTopDataBlockHeight

		if wndAffiliationString:IsShown() then
			local nLeft, nTop, nRight, nBottom = wndAffiliationString:GetAnchorOffsets()
			local nAffiliationBottom = nTopDataBlockHeight + wndAffiliationString:GetHeight()
			wndAffiliationString:SetAnchorOffsets(nLeft, nTopDataBlockHeight, nRight, nAffiliationBottom)

			local nLeft, nTop, nRight, nBottom = wndMiddleDataBlock:GetAnchorOffsets()
			wndMiddleDataBlock:SetAnchorOffsets(nLeft, nAffiliationBottom, nRight, nAffiliationBottom + wndMiddleDataBlock:GetHeight())

			nHeight = nHeight + wndAffiliationString:GetHeight()
		else
			local nLeft, nTop, nRight, nBottom = wndMiddleDataBlock:GetAnchorOffsets()
			wndMiddleDataBlock:SetAnchorOffsets(nLeft, nTopDataBlockHeight, nRight, nBottom)
		end

		-- Size middle block
		local bShowMiddleBlock = #wndMiddleDataBlockContent:GetChildren() > 0
		wndMiddleDataBlock:Show(bShowMiddleBlock)
		if bShowMiddleBlock then
			local nInnerHeight = wndMiddleDataBlockContent:ArrangeChildrenVert(0)
			local nOuterHeight = nInnerHeight + 8
			nHeight = nHeight + nOuterHeight + 8

			local nLeft, nTop, nRight, nBottom = wndMiddleDataBlockContent:GetAnchorOffsets()
			wndMiddleDataBlockContent:SetAnchorOffsets(nLeft, nTop, nRight, nTop + nInnerHeight)

			local nLeft, nTop, nRight, nBottom = wndMiddleDataBlock:GetAnchorOffsets()
			wndMiddleDataBlock:SetAnchorOffsets(nLeft, nTop, nRight, nTop + nOuterHeight)
		end

		-- Size Tooltip
		if wndXpAwardString:IsShown() or wndBreakdownString:IsShown() then
			nHeight = nHeight + wndBottomDataBlock:GetHeight()
		end

		self.wndUnitTooltip:SetAnchorOffsets(fullWndLeft, fullWndTop, fullWndRight, fullWndTop + nHeight)
	end
	
	if not wndTooltipForm then
		wndTooltipForm = self.wndUnitTooltip
	end

	self.unitTooltip = unitSource

	wndContainer:SetTooltipForm(wndTooltipForm)
	if bHideFormSecondary then
		wndContainer:SetTooltipFormSecondary(nil)
	end
end

function ForgeUI_ToolTips:HookItemToolTips()
	local aTooltips = Apollo.GetAddon("ToolTips")
	if aTooltips == nil then return end
	
	local origCreateCallNames = aTooltips.CreateCallNames
	aTooltips.CreateCallNames = function(luaCaller)
		origCreateCallNames(luaCaller)
		local origItemTooltip = Tooltip.GetItemTooltipForm
		Tooltip.GetItemTooltipForm = function(luaCaller, wndControl, item, bStuff, nCount)
		
			if item ~= nil then
				
				wndControl:SetTooltipDoc(nil)
										
				local wndTooltip, wndTooltipComp = origItemTooltip(luaCaller, wndControl, item, bStuff, nCount)
				local wndGearTooltips = Apollo.LoadForm(self.xmlDoc, "Gear_Tooltips_wnd", wndTooltip, self)
			
				wndTooltip:FindChild("ItemTooltipBG"):SetSprite("ForgeUI_Border")
				wndTooltip:FindChild("ItemTooltipBG"):SetBGColor("FF000000")
												
				return wndTooltip, wndTooltipComp
			else
				return origItemTooltip(luaCaller, wndControl, item, bStuff, nCount)
			end
		end
	end
end 

-----------------------------------------------------------------------------------------------
-- Event handlers
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-- ForgeUI_ToolTips Instance
-----------------------------------------------------------------------------------------------
ForgeUI_ToolTipsInst = ForgeUI_ToolTips:new()
ForgeUI_ToolTipsInst:Init()
