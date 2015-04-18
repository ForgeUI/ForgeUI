require "Apollo"
require "GameLib"
require "CombatFloater"
require "Window"
require "Unit"

local ForgeUI
local ForgeUI_FloatText = {} 

local FloatTextBase_OnDocumentReady = nil
local floatTextAddon = Apollo.GetAddon("FloatText")

function ForgeUI_FloatText:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

	-- mandatory 
    self.api_version = 2
	self.version = "0.1.0"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_FloatText"
	self.strDisplayName = "Float text"
	
	self.wndContainers = {}
	
	self.tStylers = {}
	
	-- optional
	self.settings_version = 1
    self.tSettings = {
		crCriticalHit = "FFFFEA00"
	}


    return o
end

function ForgeUI_FloatText:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {"ForgeUI", "FloatText"}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 
function ForgeUI_FloatText:OnLoad()
	if ForgeUI == nil then -- forgeui loaded
		ForgeUI = Apollo.GetAddon("ForgeUI")
	end
	
	ForgeUI.API_RegisterAddon(self)
end

function ForgeUI_FloatText:ForgeAPI_AfterRegistration()
	FloatTextBase_OnDocumentReady = floatTextAddon.OnDocumentReady
	floatTextAddon.OnDocumentReady = ForgeUI_FloatText.FloatTextHook_OnDocumentReady
	
	floatTextAddon.GetDefaultTextOption = self.GetDefaultTextOption
	floatTextAddon.OnGenericFloater = self.OnGenericFloater
	floatTextAddon.OnUnitEvaded = self.OnUnitEvaded
	floatTextAddon.onAlertTitle = self.onAlertTitle
	floatTextAddon.OnCombatMomentum = self.OnCombatMomentum
	floatTextAddon.OnExperienceGained = self.OnExperienceGained
	floatTextAddon.OnElderPointsGained = self.OnElderPointsGained
	floatTextAddon.OnPathExperienceGained = self.OnPathExperienceGained
	floatTextAddon.OnFactionFloater = self.OnFactionFloater;
	floatTextAddon.OnLootedMoney = self.OnLootedMoney
	floatTextAddon.OnTradeSkillFloater = self.OnTradeSkillFloater
	floatTextAddon.OnMiss = self.OnMiss
	floatTextAddon.OnDamageOrHealing = self.OnDamageOrHealing
	floatTextAddon.OnPlayerDamageOrHealing = self.OnPlayerDamageOrHealing
	floatTextAddon.OnCombatLogCCState = self.OnCombatLogCCState
	floatTextAddon.OnCombatLogCCStatePlayer = self.OnCombatLogCCStatePlayer
end

function ForgeUI_FloatText.FloatTextHook_OnDocumentReady(floatTextSelf)
	FloatTextBase_OnDocumentReady(floatTextSelf)  -- this will create the FloatText
	local floatText = floatTextSelf		
end

function ForgeUI_FloatText:GetDefaultTextOption()
	local tTextOption =
	{
		strFontFace 				= "Subtitle",
		fDuration 					= 2,
		fScale 						= 0.7,
		fExpand 					= 0,
		fVibrate 					= 0,
		fSpinAroundRadius 			= 0,
		fFadeInDuration 			= 0,
		fFadeOutDuration 			= 0,
		fVelocityDirection 			= 0,
		fVelocityMagnitude 			= 0,
		fAccelDirection 			= 0,
		fAccelMagnitude 			= 0,
		fEndHoldDuration 			= 0,
		eLocation 					= CombatFloater.CodeEnumFloaterLocation.Top,
		fOffsetDirection 			= 0,
		fOffset 					= -0.4,
		eCollisionMode 				= CombatFloater.CodeEnumFloaterCollisionMode.Horizontal,
		fExpandCollisionBoxWidth 	= 1,
		fExpandCollisionBoxHeight 	= 1,
		nColor 						= 0xFFFFFF,
		iUseDigitSpriteSet 			= nil,
		bUseScreenPos 				= false,
		bShowOnTop 					= false,
		fRotation 					= 0,
		fDelay 						= 0,
		nDigitSpriteSpacing 		= 0,
	}
	return tTextOption
end

function ForgeUI_FloatText:OnGenericFloater(unitTarget, strMessage)
	-- modify the text to be shown
	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fDuration = 1
	tTextOption.bUseScreenPos = true
	tTextOption.fOffset = 0
	tTextOption.nColor = 0x00FFFF
	tTextOption.strFontFace = "Subtitle"
	tTextOption.bShowOnTop = true

	CombatFloater.ShowTextFloater( unitTarget, strMessage, tTextOption )
end

function ForgeUI_FloatText:OnUnitEvaded(unitSource, unitTarget, eReason, strMessage)
	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fScale = 0.7
	tTextOption.fDuration = 1
	tTextOption.nColor = 0xbaeffb
	tTextOption.strFontFace = "Subtitle"
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Bottom
	tTextOption.fOffset = -0.8
	tTextOption.fOffsetDirection = 0

	tTextOption.arFrames =
	{
		[1] = {fTime = 0,		fScale = 0.9,	fAlpha = 1.0,	nColor = 0xBAEFFB,},
		[2] = {fTime = 0.15,	fScale = 0.9,	fAlpha = 1.0,},
		[3] = {fTime = 1.1,		fScale = 0.9,	fAlpha = 1.0,	fVelocityDirection = 0,	fVelocityMagnitude = 5,},
		[4] = {fTime = 1.3,						fAlpha = 0.0,	fVelocityDirection = 0,},
	}

	CombatFloater.ShowTextFloater( unitSource, strMessage, tTextOption )
end


function ForgeUI_FloatText:OnAlertTitle(strMessage)
	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fDuration = 1
	tTextOption.fFadeInDuration = 0.2
	tTextOption.fFadeOutDuration = 0.5
	tTextOption.fVelocityMagnitude = 0.2
	tTextOption.fOffset = 0.2
	tTextOption.nColor = 0x7eff8f
	tTextOption.strFontFace = "Subtitle"
	tTextOption.bShowOnTop = true
	tTextOption.fScale = 0.7
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Top

	CombatFloater.ShowTextFloater( GameLib.GetControlledUnit(), strMessage, tTextOption )
end

----

function ForgeUI_FloatText:OnCombatMomentum( eMomentumType, nCount, strText )
	-- Passes: type enum, player's total count for that bonus type, string combines these things (ie. "3 Evade")
	local arMomentumStrings =
	{
		[CombatFloater.CodeEnumCombatMomentum.Impulse] 				= "FloatText_Impulse",
		[CombatFloater.CodeEnumCombatMomentum.KillingPerformance] 	= "FloatText_KillPerformance",
		[CombatFloater.CodeEnumCombatMomentum.KillChain] 			= "FloatText_KillChain",
		[CombatFloater.CodeEnumCombatMomentum.Evade] 				= "FloatText_Evade",
		[CombatFloater.CodeEnumCombatMomentum.Interrupt] 			= "FloatText_Interrupt",
		[CombatFloater.CodeEnumCombatMomentum.CCBreak] 				= "FloatText_StateBreak",
	}

	if not Apollo.GetConsoleVariable("ui.showCombatFloater") or arMomentumStrings[eMomentumType] == nil  then
		return
	end

	local nBaseColor = 0x7eff8f
	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fScale = 0.7
	tTextOption.fDuration = 1
	tTextOption.nColor = 0x00B4CC
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Back
	tTextOption.fOffset = 2.0
	tTextOption.fOffsetDirection = 90
	tTextOption.strFontFace = "Subtitle"
	tTextOption.arFrames =
	{
		[1] = {fTime = 0,		nColor = 0x00B4CC,		fAlpha = 0,		fVelocityDirection = 90,	fVelocityMagnitude = 5,		fScale = 0.7},
		[2] = {fTime = 0.15,							fAlpha = 1.0,	fVelocityDirection = 90,	fVelocityMagnitude = .2,},
		[3] = {fTime = 0.5,		nColor = nBaseColor,},
		[4] = {fTime = 1.0,		nColor = nBaseColor,},
		[5] = {fTime = 1.1,		nColor = 0x00B4CC,		fAlpha = 1.0,	fVelocityDirection 	= 90,	fVelocityMagnitude 	= 5,},
		[6] = {fTime = 1.3,		nColor 	= nBaseColor,	fAlpha 	= 0.0,},
	}

	local unitToAttachTo = GameLib.GetControlledUnit()
	local strMessage = String_GetWeaselString(Apollo.GetString(arMomentumStrings[eMomentumType]), nCount)
	if eMomentumType == CombatFloater.CodeEnumCombatMomentum.KillChain and nCount == 2 then
		strMessage = Apollo.GetString("FloatText_DoubleKill")
		tTextOption.strFontFace = "Subtitle"
	elseif eMomentumType == CombatFloater.CodeEnumCombatMomentum.KillChain and nCount == 3 then
		strMessage = Apollo.GetString("FloatText_TripleKill")
		tTextOption.strFontFace = "Subtitle"
	elseif eMomentumType == CombatFloater.CodeEnumCombatMomentum.KillChain and nCount == 5 then
		strMessage = Apollo.GetString("FloatText_PentaKill")
		tTextOption.strFontFace = "Subtitle"
	elseif eMomentumType == CombatFloater.CodeEnumCombatMomentum.KillChain and nCount > 5 then
		tTextOption.strFontFace = "Subtitle"
	end

	CombatFloater.ShowTextFloater(unitToAttachTo, strMessage, tTextOption)
end

function ForgeUI_FloatText:OnExperienceGained(eReason, unitTarget, strText, fDelay, nAmount)
	if not Apollo.GetConsoleVariable("ui.showCombatFloater") or nAmount < 0 then
		return
	end

	local strFormatted = ""
	local eMessageType = LuaEnumMessageType.XPAwarded
	local unitToAttachTo = GameLib.GetControlledUnit() -- unitTarget potentially nil

	local tContent = {}
	tContent.eType = LuaEnumMessageType.XPAwarded
	tContent.nNormal = 0
	tContent.nRested = 0

	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fScale = 0.7
	tTextOption.fDuration = 1
	tTextOption.nColor = 0xFFBF00
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Back
	tTextOption.fOffset = 4.0 -- GOTCHA: Different
	tTextOption.fOffsetDirection = 90
	tTextOption.strFontFace = "Subtitle"
	tTextOption.arFrames =
	{
		[1] = {fTime = 0,			fAlpha = 0,		fVelocityDirection = 90,	fVelocityMagnitude = 5,		fScale = 0.7,  nColor = 0xFFBF00},
		[2] = {fTime = 0.15,		fAlpha = 1.0,	fVelocityDirection = 90,	fVelocityMagnitude = .2,},
		[3] = {fTime = 0.5,	},
		[4] = {fTime = 1.0,	},
		[5] = {fTime = 1.1,			fAlpha = 1.0,	fVelocityDirection 	= 90,	fVelocityMagnitude 	= 5,},
		[6] = {fTime = 1.3,			fAlpha 	= 0.0,},
	}

	-- GOTCHA: UpdateOrAddXpFloater will stomp on these text formats anyways (TODO REFACTOR)
	if eReason == CombatFloater.CodeEnumExpReason.KillPerformance or eReason == CombatFloater.CodeEnumExpReason.MultiKill or eReason == CombatFloater.CodeEnumExpReason.KillingSpree then
		return -- should not be delivered via the XP event
	elseif eReason == CombatFloater.CodeEnumExpReason.Rested then
		tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
		strFormatted = String_GetWeaselString(Apollo.GetString("FloatText_RestXPGained"), nAmount)
		tContent.nRested = nAmount
	else
		tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
		strFormatted = String_GetWeaselString(Apollo.GetString("FloatText_XPGained"), nAmount)
		tContent.nNormal = nAmount
	end

	self:RequestShowTextFloater(eMessageType, unitToAttachTo, strFormatted, tTextOption, fDelay, tContent)
end

function ForgeUI_FloatText:OnElderPointsGained(nAmount)
	if not Apollo.GetConsoleVariable("ui.showCombatFloater") or nAmount < 0 then
		return
	end

	local tContent = {}
	tContent.eType = LuaEnumMessageType.XPAwarded
	tContent.nNormal = nAmount
	tContent.nRested = 0

	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fScale = 0.7
	tTextOption.fDuration = 1
	tTextOption.nColor = 0xFFBF00
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Back
	tTextOption.fOffset = 4.0 -- GOTCHA: Different
	tTextOption.fOffsetDirection = 90
	tTextOption.strFontFace = "Subtitle"
	tTextOption.arFrames =
	{
		[1] = {fTime = 0,			fAlpha = 0,		fVelocityDirection = 90,	fVelocityMagnitude = 5,		fScale = 0.7,   nColor = 0xFFBF00},
		[2] = {fTime = 0.15,		fAlpha = 1.0,	fVelocityDirection = 90,	fVelocityMagnitude = .2,},
		[3] = {fTime = 0.5,	},
		[4] = {fTime = 1.0,	},
		[5] = {fTime = 1.1,			fAlpha = 1.0,	fVelocityDirection 	= 90,	fVelocityMagnitude 	= 5,},
		[6] = {fTime = 1.3,			fAlpha 	= 0.0,},
	}

	local eMessageType = LuaEnumMessageType.XPAwarded
	local unitToAttachTo = GameLib.GetControlledUnit()
	local strFormatted = String_GetWeaselString(Apollo.GetString("FloatText_EPGained"), nAmount)

	self:RequestShowTextFloater(eMessageType, unitToAttachTo, strFormatted, tTextOption, 0, tContent)
end

function ForgeUI_FloatText:OnPathExperienceGained( nAmount, strText )
	if not Apollo.GetConsoleVariable("ui.showCombatFloater") then
		return
	end

	local eMessageType = LuaEnumMessageType.PathXp
	local unitToAttachTo = GameLib.GetControlledUnit()
	local strFormatted = String_GetWeaselString(Apollo.GetString("FloatText_PathXP"), nAmount)

	local tContent =
	{
		eType = LuaEnumMessageType.PathXp,
		nAmount = nAmount,
	}

	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fScale = 0.7
	tTextOption.fDuration = 1
	tTextOption.nColor = 0xFFBF00
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Back
	tTextOption.fOffset = 4.0 -- GOTCHA: Different
	tTextOption.fOffsetDirection = 90
	tTextOption.strFontFace = "Subtitle"
	tTextOption.arFrames =
	{
		[1] = {fTime = 0,			fAlpha = 0,		fVelocityDirection = 90,	fVelocityMagnitude = 5,		fScale = 0.7,  nColor = 0xFFBF00},
		[2] = {fTime = 0.15,		fAlpha = 1.0,	fVelocityDirection = 90,	fVelocityMagnitude = .2,},
		[3] = {fTime = 0.5,	},
		[4] = {fTime = 1.0,	},
		[5] = {fTime = 1.1,			fAlpha = 1.0,	fVelocityDirection 	= 90,	fVelocityMagnitude 	= 5,},
		[6] = {fTime = 1.3,			fAlpha 	= 0.0,},
	}

	local unitToAttachTo = GameLib.GetControlledUnit() -- make unitToAttachTo to controlled unit because with the message system,
	self:RequestShowTextFloater( eMessageType, unitToAttachTo, strFormatted, tTextOption, 0, tContent )
end

-------------------

function ForgeUI_FloatText:OnFactionFloater(unitTarget, strMessage, nAmount, strFactionName, idFaction) -- Reputation Floater
	if not Apollo.GetConsoleVariable("ui.showCombatFloater") or strFactionName == nil or nAmount < 1 then
		return
	end

	local eMessageType = LuaEnumMessageType.ReputationIncrease
	local unitToAttachTo = unitTarget or GameLib.GetControlledUnit()
	local strFormatted = String_GetWeaselString(Apollo.GetString("FloatText_Rep"), nAmount, strFactionName)

	local tContent = {}
	tContent.eType = LuaEnumMessageType.ReputationIncrease
	tContent.nAmount = nAmount
	tContent.idFaction = idFaction
	tContent.strName = strFactionName

	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fScale = 0.7
	tTextOption.fDuration = 1
	tTextOption.nColor = 0xFFBF00
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Back
	tTextOption.fOffset = 5.0 -- GOTCHA: Extra Different
	tTextOption.fOffsetDirection = 90
	tTextOption.strFontFace = "Subtitle"
	tTextOption.arFrames =
	{
		[1] = {fTime = 0,			fAlpha = 0,		fVelocityDirection = 90,	fVelocityMagnitude = 5,		fScale = 0.7,  nColor = 0xFFBF00},
		[2] = {fTime = 0.15,		fAlpha = 1.0,	fVelocityDirection = 90,	fVelocityMagnitude = .2,},
		[3] = {fTime = 0.5,	},
		[4] = {fTime = 1.0,	},
		[5] = {fTime = 1.1,			fAlpha = 1.0,	fVelocityDirection 	= 90,	fVelocityMagnitude 	= 5,},
		[6] = {fTime = 1.3,			fAlpha 	= 0.0,},
	}

	self:RequestShowTextFloater(eMessageType, GameLib.GetControlledUnit(), strFormatted, tTextOption, 0, tContent)
end

---------------------------------------------------------------------------------------------------
function ForgeUI_FloatText:OnLootedMoney(monLooted) -- karCurrencyTypeToString filters to most alternate currencies but Money. Money displays in LootNotificationWindow.
	if not monLooted then
		return
	end
	
	local arCurrencyTypeToString =
	{
		[Money.CodeEnumCurrencyType.Renown] 			= "CRB_Renown",
		[Money.CodeEnumCurrencyType.ElderGems] 			= "CRB_Elder_Gems",
		[Money.CodeEnumCurrencyType.Prestige] 			= "CRB_Prestige",
		[Money.CodeEnumCurrencyType.CraftingVouchers]	= "CRB_Crafting_Vouchers",
	}

	local strCurrencyType = arCurrencyTypeToString[monLooted:GetMoneyType()] or ""
	if strCurrencyType == "" then
		return
	else
		strCurrencyType = Apollo.GetString(strCurrencyType)
	end

	-- TODO
	local eMessageType = LuaEnumMessageType.AlternateCurrency
	local strFormatted = String_GetWeaselString(Apollo.GetString("FloatText_AlternateMoney"), monLooted:GetAmount(), strCurrencyType)

	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fScale = 0.7
	tTextOption.fDuration = 1
	tTextOption.nColor = 0xD9D64E
	tTextOption.strFontFace = "Subtitle"
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Bottom
	tTextOption.fOffset = -1
	tTextOption.fOffsetDirection = 0
	tTextOption.arFrames =
	{
		[1] = {fScale = 0.7,	fTime = 0,		fAlpha = 0.0,	fVelocityDirection = 0,		fVelocityMagnitude = 0,	 nColor = 0xD9D64E},
		[2] = {fScale = 0.7,	fTime = 0.1,	fAlpha = 1.0,	fVelocityDirection = 0,		fVelocityMagnitude = 0,	},
		[3] = {fScale = 0.7,	fTime = 0.5,	fAlpha = 1.0,														},
		[4] = {					fTime = 1,		fAlpha = 1.0,	fVelocityDirection = 180,	fVelocityMagnitude = 3,	},
		[5] = {					fTime = 1.5,	fAlpha = 0.0,	fVelocityDirection = 180,							},
	}

	local tContent =
	{
		eType = LuaEnumMessageType.AlternateCurrency,
		nAmount = monLooted:GetAmount(),
	}

	self:RequestShowTextFloater(eMessageType, GameLib.GetControlledUnit(), strFormatted, tTextOption, 0, tContent)
end

---------------------------------------------------------------------------------------------------
function ForgeUI_FloatText:OnTradeSkillFloater(unitTarget, strMessage)
	if not Apollo.GetConsoleVariable("ui.showCombatFloater") then
		return
	end

	local eMessageType = LuaEnumMessageType.TradeskillXp
	local tTextOption = self:GetDefaultTextOption()
	local unitToAttachTo = GameLib.GetControlledUnit()

	-- XP Defaults
	tTextOption.fScale = 0.7
	tTextOption.fDuration = 1
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Top
	tTextOption.fOffset = -0.3
	tTextOption.fOffsetDirection = 0
	tTextOption.strFontFace = "Subtitle"
	tTextOption.nColor = 0x79C6C7
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical --Horizontal  --IgnoreCollision
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Top
	tTextOption.fOffset = -0.3
	tTextOption.fOffsetDirection = 0

	-- scale and movement
	tTextOption.arFrames =
	{
		[1] = {fTime = 0,	fScale = 0.7,	fAlpha = 0.0,   nColor = 0x79C6C7},
		[2] = {fTime = 0.1,	fScale = 0.7,	fAlpha = 0.8,},
		[3] = {fTime = 0.9,	fScale = 0.7,	fAlpha = 0.8,	fVelocityDirection = 0,},
		[4] = {fTime = 1.0,	fScale = 0.7,	fAlpha = 0.0,	fVelocityDirection = 0,},
	}


	local unitToAttachTo = GameLib.GetControlledUnit()
	self:RequestShowTextFloater( eMessageType, unitToAttachTo, strMessage, tTextOption, 0 )
end

---------------------------------------------------------------------------------------------------
function ForgeUI_FloatText:OnMiss( unitCaster, unitTarget, eMissType )
	if unitTarget == nil or not Apollo.GetConsoleVariable("ui.showCombatFloater") then
		return
	end

	-- modify the text to be shown
	local tTextOption = self:GetDefaultTextOption()
	if GameLib.IsControlledUnit( unitTarget ) or unitTarget:GetType() == "Mount" then -- if the target unit is player's char
		tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal --Vertical--Horizontal  --IgnoreCollision
		tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Bottom
		tTextOption.nColor = 0xA9CEDE
		tTextOption.fScale = 0.7
		tTextOption.strFontFace = "Subtitle"
		tTextOption.fOffset = -0.6
		tTextOption.fOffsetDirection = 0
		tTextOption.arFrames =
		{
			[1] = {fScale = 0.9,	fTime = 0,						fVelocityDirection = 0,		fVelocityMagnitude = 0,   nColor = 0xA9CEDE},
			[2] = {fScale = 0.7,	fTime = 0.05,	fAlpha = 1.0,},
			[3] = {fScale = 0.7,	fTime = .2,		fAlpha = 1.0,	fVelocityDirection = 180,	fVelocityMagnitude = 3,},
			[4] = {fScale = 0.7,	fTime = .45,	fAlpha = 0.2,	fVelocityDirection = 180,},
		}
	else

		tTextOption.fScale = 0.7
		tTextOption.fDuration = 1
		tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal --Horizontal
		tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Bottom
		tTextOption.fOffset = -0.8
		tTextOption.fOffsetDirection = 0
		tTextOption.arFrames =
		{
			[1] = {fScale = 0.9,	fTime = 0,		fAlpha = 1.0,	nColor = 0xA6A6A6,},
			[2] = {fScale = 0.7,	fTime = 0.1,	fAlpha = 1.0,},
			[3] = {					fTime = 0.3,	},
			[4] = {fScale = 0.7,	fTime = 0.8,	fAlpha = 1.0,},
			[5] = {					fTime = 0.9,	fAlpha = 0.0,},
		}
	end

	-- display the text
	local strText = (eMissType == GameLib.CodeEnumMissType.Dodge) and Apollo.GetString("CRB_Dodged") or Apollo.GetString("CRB_Blocked")
	CombatFloater.ShowTextFloater( unitTarget, strText, tTextOption )
end

---------------------------------------------------------------------------------------------------
function ForgeUI_FloatText:OnDamageOrHealing( unitCaster, unitTarget, eDamageType, nDamage, nShieldDamaged, nAbsorptionAmount, bCritical )
	if unitTarget == nil or not Apollo.GetConsoleVariable("ui.showCombatFloater") or nDamage == nil then
		return
	end

	
	if GameLib.IsControlledUnit(unitTarget) or unitTarget == GameLib.GetPlayerMountUnit() or GameLib.IsControlledUnit(unitTarget:GetUnitOwner()) then
		self:OnPlayerDamageOrHealing( unitTarget, eDamageType, nDamage, nShieldDamaged, nAbsorptionAmount, bCritical )
		return
	end

	-- NOTE: This needs to be changed if we're ever planning to display shield and normal damage in different formats.
	-- NOTE: Right now, we're just telling the player the amount of damage they did and not the specific type to keep things neat
	local nTotalDamage = nDamage
	if type(nShieldDamaged) == "number" and nShieldDamaged > 0 then
		nTotalDamage = nDamage + nShieldDamaged
	end

	local tTextOption = self:GetDefaultTextOption()
	local tTextOptionAbsorb = self:GetDefaultTextOption()

	if type(nAbsorptionAmount) == "number" and nAbsorptionAmount > 0 then --absorption is its own separate type
		tTextOptionAbsorb.fScale = 0.7
		tTextOption.strFontFace = "Subtitle"
		tTextOptionAbsorb.fDuration = 2
		tTextOptionAbsorb.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.IgnoreCollision
		tTextOptionAbsorb.eLocation = CombatFloater.CodeEnumFloaterLocation.Bottom
		tTextOptionAbsorb.fOffset = -0.8
		tTextOptionAbsorb.fOffsetDirection = 0
		tTextOptionAbsorb.arFrames={}

		tTextOptionAbsorb.arFrames =
		{
			[1] = {fScale = 0.9,	fTime = 0,		fAlpha = 1.0,	nColor = 0xB7C468,},
			[2] = {fScale = 0.7,	fTime = 0.1,	fAlpha = 1.0,},
			[3] = {					fTime = 0.3,	},
			[4] = {fScale = 0.7,	fTime = 0.8,	fAlpha = 1.0,},
			[5] = {					fTime = 0.9,	fAlpha = 0.0,},
		}
	end

	local bHeal = eDamageType == GameLib.CodeEnumDamageType.Heal or eDamageType == GameLib.CodeEnumDamageType.HealShields
	local nBaseColor = 0x00DBDB
	local fMaxSize = 0.8
	local nOffsetDirection = 95
	local fMaxDuration = 0.7

	tTextOption.strFontFace = "Subtitle"
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.IgnoreCollision
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Bottom

	if not bHeal and bCritical == true then -- Crit not vuln
		nBaseColor = 0xFFC600
		fMaxSize = 1
		fMaxDuration = 1.5
	elseif not bHeal and (unitTarget:IsInCCState( Unit.CodeEnumCCState.Vulnerability ) or eDamageType == knTestingVulnerable ) then -- vuln not crit
		nBaseColor = 0xF49CFF
	else -- normal damage
		if eDamageType == GameLib.CodeEnumDamageType.Heal then -- healing params
			nBaseColor = bCritical and 0xB5FF73 or 0x94DB56
			fMaxSize = bCritical and 0.9 or 0.7

		elseif eDamageType == GameLib.CodeEnumDamageType.HealShields then -- healing shields params
			nBaseColor = bCritical and 0x95DED8 or 0x5CCBED
			fMaxSize = bCritical and 0.9 or 0.7

		else -- regular target damage params
			nBaseColor = 0xFFFFFF
		end
	end

	-- determine offset direction; re-randomize if too close to the last
	local nOffset = math.random(0, 360)
	if nOffset <= (self.fLastOffset + 50) and nOffset >= (self.fLastOffset - 50) then
		nOffset = math.random(0, 360)
	end
	self.fLastOffset = nOffset

	-- set offset
	tTextOption.fOffsetDirection = nOffset
	tTextOption.fOffset = math.random(10, 80)/100

	-- scale and movement
	tTextOption.arFrames =
	{
		[1] = {fScale = (fMaxSize) * 1.3,	fTime = 0,									nColor = 0xffffff,	},
		[2] = {fScale = fMaxSize,			fTime = .15,			fAlpha = 1.0,},--	nColor = nBaseColor,},
		[3] = {fScale = fMaxSize,			fTime = .3,									nColor = nBaseColor,},
		[4] = {fScale = fMaxSize,			fTime = .5,				fAlpha = 1.0,},
		[5] = {								fTime = fMaxDuration,	fAlpha = 0.0,},
	}

	if not bHeal then
		self.fLastDamageTime = GameLib.GetGameTime()
	end

	if type(nAbsorptionAmount) == "number" and nAbsorptionAmount > 0 then -- secondary "if" so we don't see absorption and "0"
		CombatFloater.ShowTextFloater( unitTarget, String_GetWeaselString(Apollo.GetString("FloatText_Absorbed"), nAbsorptionAmount), tTextOptionAbsorb )

		if nTotalDamage > 0 then
			tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
			if bHeal then
				CombatFloater.ShowTextFloater( unitTarget, String_GetWeaselString(Apollo.GetString("FloatText_PlusValue"), nTotalDamage), tTextOption )
			else
				CombatFloater.ShowTextFloater( unitTarget, nTotalDamage, tTextOption )
			end
		end
	elseif bHeal then
		CombatFloater.ShowTextFloater( unitTarget, String_GetWeaselString(Apollo.GetString("FloatText_PlusValue"), nTotalDamage), tTextOption ) -- we show "0" when there's no absorption
	else
		if bCritical then
			CombatFloater.ShowTextFloater( unitTarget, nTotalDamage, tTextOption )
		else
			CombatFloater.ShowTextFloater( unitTarget, nTotalDamage, tTextOption )
		end
	end
end

------------------------------------------------------------------
function ForgeUI_FloatText:OnPlayerDamageOrHealing(unitPlayer, eDamageType, nDamage, nShieldDamaged, nAbsorptionAmount, bCritical)
	if unitPlayer == nil or not Apollo.GetConsoleVariable("ui.showCombatFloater") then
		return
	end

	-- If there is no damage, don't show a floater
	if nDamage == nil then
		return
	end

	local bShowFloater = true
	local tTextOption = self:GetDefaultTextOption()
	local tTextOptionAbsorb = self:GetDefaultTextOption()

	tTextOption.arFrames = {}
	tTextOptionAbsorb.arFrames = {}

	local nStallTime = .3

	if type(nAbsorptionAmount) == "number" and nAbsorptionAmount > 0 then --absorption is its own separate type
		tTextOption.strFontFace = "Subtitle"
		tTextOptionAbsorb.nColor = 0xB7C468
		tTextOptionAbsorb.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal --Vertical--Horizontal  --IgnoreCollision
		tTextOptionAbsorb.eLocation = CombatFloater.CodeEnumFloaterLocation.Bottom
		tTextOptionAbsorb.fOffset = -0.4
		tTextOptionAbsorb.fOffsetDirection = 0--125

		-- scale and movement
		tTextOptionAbsorb.arFrames =
		{
			[1] = {fScale = 0.9,	fTime = 0,									fVelocityDirection = 0,		fVelocityMagnitude = 0,},
			[2] = {fScale = 0.7,	fTime = 0.05,				fAlpha = 1.0,},
			[3] = {fScale = 0.7,	fTime = .2 + nStallTime,	fAlpha = 1.0,	fVelocityDirection = 180,	fVelocityMagnitude = 3,},
			[4] = {fScale = 0.7,	fTime = .45 + nStallTime,	fAlpha = 0.2,	fVelocityDirection = 180,},
		}
	end

	if type(nShieldDamaged) == "number" and nShieldDamaged > 0 then
		nDamage = nDamage + nShieldDamaged
	end

	local bHeal = eDamageType == GameLib.CodeEnumDamageType.Heal or eDamageType == GameLib.CodeEnumDamageType.HealShields
	local nBaseColor = 0xFF4242
	local nHighlightColor = 0xE35656
	local fMaxSize = 0.8
	local nOffsetDirection = 0
	local fOffsetAmount = -0.6
	local fMaxDuration = .55
	local eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal

	if eDamageType == GameLib.CodeEnumDamageType.Heal then -- healing params
		nBaseColor = 0x81E02D
		nHighlightColor = 0x8AED32
		fOffsetAmount = -0.5

		if bCritical then
			fMaxSize = 0.9
			nBaseColor = 0x5CC400
			nHighlightColor = 0x69E000
			fMaxDuration = .75
		end

	elseif eDamageType == GameLib.CodeEnumDamageType.HealShields then -- healing shields params
		nBaseColor = 0x1CEDDC
		fOffsetAmount = -0.5
		nHighlightColor = 0x00E0CE

		if bCritical then
			fMaxSize = 0.9
			nBaseColor = 0x1CEBDA
			nHighlightColor = 0x2DDDE0
			fMaxDuration = .75
		end

	else -- regular old damage (player)
		fOffsetAmount = -0.5

		if bCritical then
			fMaxSize = 0.9
			nBaseColor = 0xFF00E1
			nHighlightColor = 0xC900B2
			fMaxDuration = .75
		end
	end

	tTextOptionAbsorb.fOffset = fOffsetAmount
	tTextOption.eCollisionMode = eCollisionMode
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Bottom

	-- scale and movement
	tTextOption.arFrames =
	{
		[1] = {fScale = fMaxSize * .75,	fTime = 0,									nColor = nHighlightColor,	fVelocityDirection = 0,		fVelocityMagnitude = 0,},
		[2] = {fScale = fMaxSize * 1.3,	fTime = 0.05,								nColor = nHighlightColor,	fVelocityDirection = 0,		fVelocityMagnitude = 0,},
		[3] = {fScale = fMaxSize,		fTime = 0.1,				fAlpha = 1.0,	nColor = nBaseColor,},
		[4] = {							fTime = 0.3 + nStallTime,	fAlpha = 1.0,								fVelocityDirection = 180,	fVelocityMagnitude = 3,},
		[5] = {							fTime = 0.65 + nStallTime,	fAlpha = 0.2,								fVelocityDirection = 180,},
	}

	if type(nAbsorptionAmount) == "number" and nAbsorptionAmount > 0 then -- secondary "if" so we don't see absorption and "0"
		CombatFloater.ShowTextFloater( unitPlayer, String_GetWeaselString(Apollo.GetString("FloatText_Absorbed"), nAbsorptionAmount), tTextOptionAbsorb )
	end

	if nDamage > 0 and bHeal then
		CombatFloater.ShowTextFloater( unitPlayer, String_GetWeaselString(Apollo.GetString("FloatText_PlusValue"), nDamage), tTextOption )
	elseif nDamage > 0 then
		if bCritical then
			CombatFloater.ShowTextFloater( unitPlayer, nDamage, tTextOption )
		else
			CombatFloater.ShowTextFloater( unitPlayer, nDamage, tTextOption )
		end	
	end
end

-----

function ForgeUI_FloatText:OnCombatLogCCState(tEventArgs)
	if not Apollo.GetConsoleVariable("ui.showCombatFloater") then
		return
	end

	-- removal of a CC state does not display floater text
	if tEventArgs.bRemoved or tEventArgs.bHideFloater then
		return
	end

	local nOffsetState = tEventArgs.eState
	if tEventArgs.eResult == nil then
		return
	end -- totally invalid

	if GameLib.IsControlledUnit( tEventArgs.unitTarget ) then
		-- Route to the player function
		self:OnCombatLogCCStatePlayer(tEventArgs)
		return
	end

	local arCCFormat =  --Removing an entry from this table means no floater is shown for that state.
	{
		[Unit.CodeEnumCCState.Stun] 			= 0xFFAE00, -- stun
		[Unit.CodeEnumCCState.Sleep] 			= 0xFFAE00, -- sleep
		[Unit.CodeEnumCCState.Root] 			= 0xFFAE00, -- root
		[Unit.CodeEnumCCState.Disarm] 			= 0xFFAE00, -- disarm
		[Unit.CodeEnumCCState.Silence] 			= 0xFFAE00, -- silence
		[Unit.CodeEnumCCState.Polymorph] 		= 0xFFAE00, -- polymorph
		[Unit.CodeEnumCCState.Fear] 			= 0xFFAE00, -- fear
		[Unit.CodeEnumCCState.Hold] 			= 0xFFAE00, -- hold
		[Unit.CodeEnumCCState.Knockdown] 		= 0xFFAE00, -- knockdown
		[Unit.CodeEnumCCState.Disorient] 		= 0xFFAE00,
		[Unit.CodeEnumCCState.Disable] 			= 0xFFAE00,
		[Unit.CodeEnumCCState.Taunt] 			= 0xFFAE00,
		[Unit.CodeEnumCCState.DeTaunt] 			= 0xFFAE00,
		[Unit.CodeEnumCCState.Blind] 			= 0xFFAE00,
		[Unit.CodeEnumCCState.Knockback] 		= 0xFFAE00,
		[Unit.CodeEnumCCState.Pushback ] 		= 0xFFAE00,
		[Unit.CodeEnumCCState.Pull] 			= 0xFFAE00,
		[Unit.CodeEnumCCState.PositionSwitch] 	= 0xFFAE00,
		[Unit.CodeEnumCCState.Tether] 			= 0xFFAE00,
		[Unit.CodeEnumCCState.Snare] 			= 0xFFAE00,
		[Unit.CodeEnumCCState.Interrupt] 		= 0xFFAE00,
		[Unit.CodeEnumCCState.Daze] 			= 0xFFAE00,
		[Unit.CodeEnumCCState.Subdue] 			= 0xFFAE00,
	}

	local tTextOption = self:GetDefaultTextOption()
	local strMessage = ""

	tTextOption.strFontFace = "Subtitle"	
	tTextOption.fScale = 0.7
	tTextOption.fDuration = 1
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.IgnoreCollision
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Bottom
	tTextOption.fOffset = -0.8
	tTextOption.fOffsetDirection = 0
	tTextOption.arFrames={}

	local bUseCCFormat = false -- use CC formatting vs. message formatting

	if tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Ok then -- CC applied
		strMessage = tEventArgs.strState
		if arCCFormat[nOffsetState] ~= nil then -- make sure it's one we want to show
			bUseCCFormat = true
		else
			return
		end
	elseif tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Target_Immune then
		strMessage = Apollo.GetString("FloatText_Immune")
	elseif tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Target_InfiniteInterruptArmor then
		strMessage = Apollo.GetString("FloatText_InfInterruptArmor")
	elseif tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Target_InterruptArmorReduced then -- use with interruptArmorHit
		strMessage = String_GetWeaselString(Apollo.GetString("FloatText_InterruptArmor"), tEventArgs.nInterruptArmorHit)
	elseif tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.DiminishingReturns_TriggerCap and tEventArgs.strTriggerCapCategory ~= nil then
		strMessage = Apollo.GetString("FloatText_CC_DiminishingReturns_TriggerCap").." "..tEventArgs.strTriggerCapCategory
	else -- all invalid messages
		return
	end

	if not bUseCCFormat then -- CC didn't take
		tTextOption.nColor = 0xC4C4C4

		tTextOption.arFrames =
		{
			[1] = {fScale = 0.9,	fTime = 0,		fAlpha = 0.0},
			[2] = {fScale = 0.7,	fTime = 0.1,	fAlpha = 0.8},
			[3] = {fScale = 0.7,	fTime = 0.9,	fAlpha = 0.8,	fVelocityDirection = 0},
			[4] = {fScale = 0.9,	fTime = 1.0,	fAlpha = 0.0,	fVelocityDirection = 0},
		}
	else -- CC applied
		tTextOption.arFrames =
		{
			[1] = {fScale = 0.9,	fTime = 0,		fAlpha = 1.0,	nColor = 0xFFFFFF,},
			[2] = {fScale = 0.7,	fTime = 0.15,	fAlpha = 1.0,},
			[3] = {					fTime = 0.5,					nColor = arCCFormat[nOffsetState],},
			[4] = {fScale = 0.7,	fTime = 1.1,	fAlpha = 1.0,										fVelocityDirection = 0,	fVelocityMagnitude = 5,},
			[5] = {					fTime = 1.3,	fAlpha = 0.0,										fVelocityDirection = 0,},
		}
	end

	CombatFloater.ShowTextFloater( tEventArgs.unitTarget, strMessage, tTextOption )
end

------------------------------------------------------------------
function ForgeUI_FloatText:OnCombatLogCCStatePlayer(tEventArgs)
	if not Apollo.GetConsoleVariable("ui.showCombatFloater") then
		return
	end

	-- removal of a CC state does not display floater text
	if tEventArgs.bRemoved or tEventArgs.bHideFloater then
		return
	end

	local arCCFormatPlayer =
    --Removing an entry from this table means no floater is shown for that state.
	{
		[Unit.CodeEnumCCState.Stun] 			= 0xD52BFF,
		[Unit.CodeEnumCCState.Sleep] 			= 0xD52BFF,
		[Unit.CodeEnumCCState.Root] 			= 0xD52BFF,
		[Unit.CodeEnumCCState.Disarm] 			= 0xD52BFF,
		[Unit.CodeEnumCCState.Silence] 			= 0xD52BFF,
		[Unit.CodeEnumCCState.Polymorph] 		= 0xD52BFF,
		[Unit.CodeEnumCCState.Fear] 			= 0xD52BFF,
		[Unit.CodeEnumCCState.Hold] 			= 0xD52BFF,
		[Unit.CodeEnumCCState.Knockdown] 		= 0xD52BFF,
		[Unit.CodeEnumCCState.Disorient] 		= 0xD52BFF,
		[Unit.CodeEnumCCState.Disable] 			= 0xD52BFF,
		[Unit.CodeEnumCCState.Taunt] 			= 0xD52BFF,
		[Unit.CodeEnumCCState.DeTaunt] 			= 0xD52BFF,
		[Unit.CodeEnumCCState.Blind] 			= 0xD52BFF,
		[Unit.CodeEnumCCState.Knockback] 		= 0xD52BFF,
		[Unit.CodeEnumCCState.Pushback] 		= 0xD52BFF,
		[Unit.CodeEnumCCState.Pull] 			= 0xD52BFF,
		[Unit.CodeEnumCCState.PositionSwitch] 	= 0xD52BFF,
		[Unit.CodeEnumCCState.Tether] 			= 0xD52BFF,
		[Unit.CodeEnumCCState.Snare] 			= 0xD52BFF,
		[Unit.CodeEnumCCState.Interrupt] 		= 0xD52BFF,
		[Unit.CodeEnumCCState.Daze] 			= 0xD52BFF,
		[Unit.CodeEnumCCState.Subdue] 			= 0xD52BFF,
	}

	local nOffsetState = tEventArgs.eState

	local tTextOption = self:GetDefaultTextOption()
	local strMessage = ""

	tTextOption.strFontFace = "Subtitle"	
	tTextOption.fScale = 0.7
	tTextOption.fDuration = 1
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Bottom
	tTextOption.fOffset = -0.2
	tTextOption.fOffsetDirection = 0
	tTextOption.arFrames={}

	local bUseCCFormat = false -- use CC formatting vs. message formatting

	if tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Ok then -- CC applied
		strMessage = tEventArgs.strState
		if arCCFormatPlayer[nOffsetState] ~= nil then -- make sure it's one we want to show
			bUseCCFormat = true
		else
			return
		end
	elseif tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Target_Immune then
		strMessage = Apollo.GetString("FloatText_Immune")
	elseif tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Target_InfiniteInterruptArmor then
		strMessage = Apollo.GetString("FloatText_InfInterruptArmor")
	elseif tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Target_InterruptArmorReduced then -- use with interruptArmorHit
		strMessage = String_GetWeaselString(Apollo.GetString("FloatText_InterruptArmor"), tEventArgs.nInterruptArmorHit)
	else -- all invalid messages
		return
	end

	if not bUseCCFormat then -- CC didn't take
		tTextOption.nColor = 0xBABABA
		tTextOption.arFrames =
		{
			[1] = {fScale = 0.9,	fTime = 0,		fAlpha = 0.0,},
			[2] = {fScale = 0.7,	fTime = 0.1,	fAlpha = 0.8,},
			[3] = {fScale = 0.7,	fTime = 0.9,	fAlpha = 0.8,	fVelocityDirection = 180,	fVelocityMagnitude = 3,},
			[4] = {fScale = 0.7,	fTime = 1.0,	fAlpha = 0.0,	fVelocityDirection = 180,},
		}
	else -- CC applied
		tTextOption.nColor = arCCFormatPlayer[nOffsetState]
		tTextOption.arFrames =
		{
			[1] = {fScale = 0.9,	fTime = 0,		nColor = 0xBABABA,},
			[2] = {fScale = 0.7,	fTime = 0.05,	nColor = arCCFormatPlayer[nOffsetState],	fAlpha = 1.0,},
			[3]	= {					fTime = 0.35,	nColor = 0xBABABA,},
			[4] = {					fTime = 0.7,	nColor = arCCFormatPlayer[nOffsetState],},
			[5] = {					fTime = 1.05,	nColor = 0xBABABA,},
			[6] = {fScale = 0.7,	fTime = 1.4,	nColor = arCCFormatPlayer[nOffsetState],	fAlpha = 1.0,	fVelocityDirection = 180,	fVelocityMagnitude = 3,},
			[7] = {fScale = 0.7,	fTime = 1.55,												fAlpha = 0.2,	fVelocityDirection = 180,},
		}
	end

	CombatFloater.ShowTextFloater( tEventArgs.unitTarget, strMessage, tTextOption )
end


-----------------------------------------------------------------------------------------------
-- ForgeUI_FloatText Instance
-----------------------------------------------------------------------------------------------
local ForgeUI_FloatTextInst = ForgeUI_FloatText:new()
ForgeUI_FloatTextInst:Init()
