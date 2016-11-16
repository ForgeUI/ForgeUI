----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI addon
--
-- name: 		ForgeUI_FloatText.lua
-- author:		Winty Badass@Jabbit
-- about:		FloatText addon for ForgeUI
-----------------------------------------------------------------------------------------------

require "Apollo"
require "GameLib"
require "CombatFloater"
require "Window"
require "Unit"

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI

local ForgeUI_FloatText = {
	_NAME = "ForgeUI_FloatText",
	_API_VERSION = 3,
	_VERSION = "2.0",
	DISPLAY_NAME = "Float Text",

	tSettings = {
		profile = {
			strFont = "Subtitle",
			strLocation = "Chest",
			strCollision = "IgnoreCollision",
			bAdjustForTallUnits = false,
			nTallUnitOffset = 100,
			bDontShowImmunity = false,
			bShowDeflect = true,
			bShowCCState = true,
			bShowCombatMomentum = true,
			bShowExperienceGained = true,
			nDamageIncomingThreshold = 0, 	--tDamageHealing.nDamageThreshold
			nHealingIncomingThreshold = 0, 	--tDamageHealing.nHealThreshold
			nDamageOutgoingThreshold = 0, 	--tPlayerDamageHealing.nDamageThreshold
			nHealingOutgoingThreshold = 0, 	--tPlayerDamageHealing.nHealThreshold
		}
	}
}

local FloatText = Apollo.GetAddon("FloatText")

function ForgeUI_FloatText:ForgeAPI_Init()
	self.xmlDoc = XmlDoc.CreateFromFile("..//ForgeUI_FloatText//ForgeUI_FloatText.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)

	F:API_AddMenuItem(self, "Float Text", "General")

	FloatText.OnDamageOrHealing = self.OnDamageOrHealing
	FloatText.OnPlayerDamageOrHealing = self.OnPlayerDamageOrHealing
	FloatText.OnMiss = self.OnMiss
	FloatText.OnCombatLogCCState = self.OnCombatLogCCState
	FloatText.OnCombatLogImmunity = self.OnCombatLogImmunity
end

function ForgeUI_FloatText:OnDocLoaded()
	if self.xmlDoc == nil and not self.xmlDoc:IsLoaded() then return end
end


function ForgeUI_FloatText:GetDefaultTextOption()
	local tTextOption = {
		strFontFace 				= self._DB.profile.strFont,
		fDuration 					= 2,
		fScale 						= 0.9,
		fExpand 					= 1,
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
		fOffset 					= -0.5,
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
		nTotalDamage = nTotalDamage + nShieldDamaged
	end

	if type(nAbsorptionAmount) == "number" and nAbsorptionAmount > 0 then
		nTotalDamage = nTotalDamage + nAbsorptionAmount
	end

	local bHeal = eDamageType == GameLib.CodeEnumDamageType.Heal or eDamageType == GameLib.CodeEnumDamageType.HealShields
	if bHeal and nTotalDamage <= ForgeUI_FloatText._DB.profile.nHealingOutgoingThreshold then return end
	if not bHeal and nTotalDamage <= ForgeUI_FloatText._DB.profile.nDamageOutgoingThreshold then return end

	local tTextOption = ForgeUI_FloatText:GetDefaultTextOption()
	local tTextOptionAbsorb = ForgeUI_FloatText:GetDefaultTextOption()

	if type(nAbsorptionAmount) == "number" and nAbsorptionAmount > 0 then --absorption is its own separate type
		tTextOptionAbsorb.fScale = 1.0
		tTextOptionAbsorb.fDuration = 2
		tTextOptionAbsorb.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.IgnoreCollision --Horizontal
		tTextOptionAbsorb.eLocation = CombatFloater.CodeEnumFloaterLocation[ForgeUI_FloatText._DB.profile.strLocation]
		tTextOptionAbsorb.fOffset = -0.8
		tTextOptionAbsorb.fOffsetDirection = 0
		tTextOptionAbsorb.arFrames={}

		tTextOptionAbsorb.arFrames = {
			[1] = {fScale = 1.1,	fTime = 0,		fAlpha = 1.0,	nColor = 0xb0b0b0,},
			[2] = {fScale = 0.7,	fTime = 0.1,	fAlpha = 1.0,},
			[3] = {					fTime = 0.3,	},
			[4] = {fScale = 0.7,	fTime = 0.8,	fAlpha = 1.0,},
			[5] = {					fTime = 0.9,	fAlpha = 0.0,},
		}
	end

	--local nBaseColor = 0x00ffff
	local fMaxSize = 0.8
	--local nOffsetDirection = 95
	local fMaxDuration = 0.7
	local nBaseColor

	tTextOption.strFontFace = ForgeUI_FloatText._DB.profile.strFont
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.IgnoreCollision
	tTextOption.eLocation = ForgeUI_FloatText:GetFloatTextLocation(bHeal, unitTarget)

	if not bHeal and bCritical == true then -- Crit not vuln
		nBaseColor = 0xffea00
		fMaxSize = 1.0
	elseif not bHeal and (unitTarget:IsInCCState( Unit.CodeEnumCCState.Vulnerability ) or eDamageType == knTestingVulnerable ) then -- vuln not crit -- knTestingVulnerable undefined!
		nBaseColor = 0xf5a2ff
	else -- normal damage
		if eDamageType == GameLib.CodeEnumDamageType.Heal then -- healing params
			nBaseColor = bCritical and 0xcdffa0 or 0xb0ff6a
			fMaxSize = bCritical and 0.9 or 0.7

		elseif eDamageType == GameLib.CodeEnumDamageType.HealShields then -- healing shields params
			nBaseColor = bCritical and 0xc9fffb or 0x6afff3
			fMaxSize = bCritical and 0.9 or 0.7

		else -- regular target damage params
			nBaseColor = 0xe5feff
		end
	end

	-- determine offset direction; re-randomize if too close to the last
	local nOffset = math.random(0, 360)
	if nOffset <= (self.fLastOffset + 25) and nOffset >= (self.fLastOffset - 25) then
		nOffset = math.random(0, 360)
	end
	self.fLastOffset = nOffset

	-- set offset
	tTextOption.fOffsetDirection = nOffset
	tTextOption.fOffset = math.random(10, 80)/100

	-- scale and movement
	tTextOption.arFrames = ForgeUI_FloatText:GetOutgoingDamageAnimation(true, fMaxSize, nBaseColor, fMaxDuration)

	if not bHeal then
		self.fLastDamageTime = GameLib.GetGameTime()
	end

	if type(nAbsorptionAmount) == "number" and nAbsorptionAmount > 0 then -- secondary "if" so we don't see absorption and "0"
		CombatFloater.ShowTextFloater( unitTarget, String_GetWeaselString(Apollo.GetString("FloatText_Absorbed"), nAbsorptionAmount), 0, tTextOptionAbsorb )

		if nTotalDamage > 0 then
			tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
			if bHeal then
				CombatFloater.ShowTextFloater( unitTarget, String_GetWeaselString(Apollo.GetString("FloatText_PlusValue"), nTotalDamage), 0, tTextOption )
			else
				CombatFloater.ShowTextFloater( unitTarget, nTotalDamage, 0, tTextOption )
			end
		end
	elseif bHeal then
		CombatFloater.ShowTextFloater( unitTarget, String_GetWeaselString(Apollo.GetString("FloatText_PlusValue"), nTotalDamage), 0, tTextOption ) -- we show "0" when there's no absorption
	else
		CombatFloater.ShowTextFloater( unitTarget, nTotalDamage, 0, tTextOption )
	end
end

function ForgeUI_FloatText:OnPlayerDamageOrHealing(unitPlayer, eDamageType, nDamage, nShieldDamaged, nAbsorptionAmount, bCritical)
	if unitPlayer == nil or not Apollo.GetConsoleVariable("ui.showCombatFloater") then return end

	-- If there is no damage, don't show a floater
	if nDamage == nil then return end

	local bHeal = eDamageType == GameLib.CodeEnumDamageType.Heal or eDamageType == GameLib.CodeEnumDamageType.HealShields

	if bHeal and nDamage <= ForgeUI_FloatText._DB.profile.nHealingIncomingThreshold then return end
	if not bHeal and nDamage <= ForgeUI_FloatText._DB.profile.nDamageIncomingThreshold then return end

	local tTextOption = ForgeUI_FloatText:GetDefaultTextOption()
	local tTextOptionAbsorb = ForgeUI_FloatText:GetDefaultTextOption()

	tTextOption.strFontFace = ForgeUI_FloatText._DB.profile.strFont
	tTextOption.arFrames = {}
	tTextOptionAbsorb.arFrames = {}

	local nStallTime = .3

	if type(nAbsorptionAmount) == "number" and nAbsorptionAmount > 0 then --absorption is its own separate type
		tTextOptionAbsorb.nColor = 0xf8f3d7
		tTextOptionAbsorb.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal --Vertical--Horizontal  --IgnoreCollision
		tTextOptionAbsorb.eLocation = CombatFloater.CodeEnumFloaterLocation.Chest
		tTextOptionAbsorb.fOffset = -0.4
		tTextOptionAbsorb.fOffsetDirection = 0--125

		-- scale and movement
		tTextOptionAbsorb.arFrames = {
			[1] = {fScale = 1.1,	fTime = 0,									fVelocityDirection = 0,		fVelocityMagnitude = 0,},
			[2] = {fScale = 0.7,	fTime = 0.05,				fAlpha = 1.0,},
			[3] = {fScale = 0.7,	fTime = .2 + nStallTime,	fAlpha = 1.0,	fVelocityDirection = 180,	fVelocityMagnitude = 3,},
			[4] = {fScale = 0.7,	fTime = .45 + nStallTime,	fAlpha = 0.2,	fVelocityDirection = 180,},
		}
	end

	if type(nShieldDamaged) == "number" and nShieldDamaged > 0 then
		nDamage = nDamage + nShieldDamaged
	end

	if type(nAbsorptionAmount) == "number" and nAbsorptionAmount > 0 then
		nDamage = nDamage + nAbsorptionAmount
	end

	local nBaseColor = 0xff6d6d
	local nHighlightColor = 0xff6d6d
	local fMaxSize = 0.8
	--local nOffsetDirection = 0
	local fOffsetAmount
	--local fMaxDuration = .55
	local eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal

	if eDamageType == GameLib.CodeEnumDamageType.Heal then -- healing params
		nBaseColor = 0xb0ff6a
		nHighlightColor = 0xb0ff6a
		fOffsetAmount = -0.5

		if bCritical then
			fMaxSize = 1.2
			nBaseColor = 0xc6ff94
			nHighlightColor = 0xc6ff94
			--fMaxDuration = .75
		end
	elseif eDamageType == GameLib.CodeEnumDamageType.HealShields then -- healing shields params
		nBaseColor = 0x6afff3
		fOffsetAmount = -0.5
		nHighlightColor = 0x6afff3

		if bCritical then
			fMaxSize = 1.2
			nBaseColor = 0xa6fff8
			nHighlightColor = 0xFFFFFF
			--fMaxDuration = .75
		end
	else -- regular old damage (player)
		fOffsetAmount = -0.5

		if bCritical then
			fMaxSize = 1.2
			nBaseColor = 0xffab3d
			nHighlightColor = 0xFFFFFF
			--fMaxDuration = .75
		end
	end

	tTextOptionAbsorb.fOffset = fOffsetAmount
	tTextOption.eCollisionMode = eCollisionMode
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Chest

	-- scale and movement
	tTextOption.arFrames = {
		[1] = {fScale = fMaxSize * .75,	fTime = 0,									nColor = nHighlightColor,	fVelocityDirection = 0,		fVelocityMagnitude = 0,},
		[2] = {fScale = fMaxSize * 1.5,	fTime = 0.05,								nColor = nHighlightColor,	fVelocityDirection = 0,		fVelocityMagnitude = 0,},
		[3] = {fScale = fMaxSize,		fTime = 0.1,				fAlpha = 1.0,	nColor = nBaseColor,},
		[4] = {							fTime = 0.3 + nStallTime,	fAlpha = 1.0,								fVelocityDirection = 180,	fVelocityMagnitude = 3,},
		[5] = {							fTime = 0.65 + nStallTime,	fAlpha = 0.2,								fVelocityDirection = 180,},
	}

	if type(nAbsorptionAmount) == "number" and nAbsorptionAmount > 0 then -- secondary "if" so we don't see absorption and "0"
		CombatFloater.ShowTextFloater( unitPlayer, String_GetWeaselString(Apollo.GetString("FloatText_Absorbed"), nAbsorptionAmount), 0, tTextOptionAbsorb )
	end

	if nDamage > 0 and bHeal then
		CombatFloater.ShowTextFloater( unitPlayer, String_GetWeaselString(Apollo.GetString("FloatText_PlusValue"), nDamage), 0, tTextOption )
	elseif nDamage > 0 then
		CombatFloater.ShowTextFloater( unitPlayer, nDamage, 0, tTextOption )
	end
end

function ForgeUI_FloatText:OnCombatLogCCState(tEventArgs)
	if not ForgeUI_FloatText._DB.profile.bShowCCState then return end

	if not self:ShouldDisplayCCStateFloater( tEventArgs ) then
		return
	end

	if tEventArgs.eResult == nil then return false end -- totally invalid

	if GameLib.IsControlledUnit( tEventArgs.unitTarget ) then
		-- Route to the player function
		self:OnCombatLogCCStatePlayer(tEventArgs)
		return
	end

	local nOffsetState = tEventArgs.eState

	-- Removing an entry from this table means no floater is shown for that state.
	local arCCFormat = {
		[Unit.CodeEnumCCState.Stun] 			= 0xffe691, -- stun
		[Unit.CodeEnumCCState.Sleep] 			= 0xffe691, -- sleep
		[Unit.CodeEnumCCState.Root] 			= 0xffe691, -- root
		[Unit.CodeEnumCCState.Disarm] 			= 0xffe691, -- disarm
		[Unit.CodeEnumCCState.Silence] 			= 0xffe691, -- silence
		[Unit.CodeEnumCCState.Polymorph] 		= 0xffe691, -- polymorph
		[Unit.CodeEnumCCState.Fear] 			= 0xffe691, -- fear
		[Unit.CodeEnumCCState.Hold] 			= 0xffe691, -- hold
		[Unit.CodeEnumCCState.Knockdown] 		= 0xffe691, -- knockdown
		[Unit.CodeEnumCCState.Disorient] 		= 0xffe691,
		[Unit.CodeEnumCCState.Disable] 			= 0xffe691,
		[Unit.CodeEnumCCState.Taunt] 			= 0xffe691,
		[Unit.CodeEnumCCState.DeTaunt] 			= 0xffe691,
		[Unit.CodeEnumCCState.Blind] 			= 0xffe691,
		[Unit.CodeEnumCCState.Knockback] 		= 0xffe691,
		[Unit.CodeEnumCCState.Pushback ] 		= 0xffe691,
		[Unit.CodeEnumCCState.Pull] 			= 0xffe691,
		[Unit.CodeEnumCCState.PositionSwitch] 	= 0xffe691,
		[Unit.CodeEnumCCState.Tether] 			= 0xffe691,
		[Unit.CodeEnumCCState.Snare] 			= 0xffe691,
		[Unit.CodeEnumCCState.Interrupt] 		= 0xffe691,
		[Unit.CodeEnumCCState.Daze] 			= 0xffe691,
		[Unit.CodeEnumCCState.Subdue] 			= 0xffe691,
	}

	local tTextOption = self:GetDefaultCCStateTextOption()
	local strMessage
	local bUseCCFormat = false -- use CC formatting vs. message formatting

	if tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Ok then -- CC applied
		strMessage = tEventArgs.strState
		if arCCFormat[nOffsetState] ~= nil then -- make sure it's one we want to show
			bUseCCFormat = true
		else
			return
		end
	elseif tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Target_Immune then
		if ForgeUI_FloatText._DB.profile.bDontShowImmunity then return end
		strMessage = Apollo.GetString("FloatText_Immune")
	elseif tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Target_InfiniteInterruptArmor then
		if ForgeUI_FloatText._DB.profile.bDontShowImmunity then return end
		strMessage = Apollo.GetString("FloatText_InfInterruptArmor")
	elseif tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.Target_InterruptArmorReduced then -- use with interruptArmorHit
		strMessage = String_GetWeaselString(Apollo.GetString("FloatText_InterruptArmor"), tEventArgs.nInterruptArmorHit)
	elseif tEventArgs.eResult == CombatFloater.CodeEnumCCStateApplyRulesResult.DiminishingReturns_TriggerCap and tEventArgs.strTriggerCapCategory ~= nil then
		strMessage = Apollo.GetString("FloatText_CC_DiminishingReturns_TriggerCap").." "..tEventArgs.strTriggerCapCategory
	else -- all invalid messages
		return
	end

	if bUseCCFormat then -- CC applied
		tTextOption.arFrames = {
			[1] = {fScale = 2.0,	fTime = 0,		fAlpha = 1.0,	nColor = 0xFFFFFF,},
			[2] = {fScale = 0.7,	fTime = 0.15,	fAlpha = 1.0,},
			[3] = {					fTime = 0.5,					nColor = arCCFormat[nOffsetState],},
			[4] = {fScale = 0.7,	fTime = 1.1,	fAlpha = 1.0,										fVelocityDirection = 0,	fVelocityMagnitude = 5,},
			[5] = {					fTime = 1.3,	fAlpha = 0.0,										fVelocityDirection = 0,},
		}
	end

	CombatFloater.ShowTextFloater( tEventArgs.unitTarget, strMessage, tTextOption )
end

function ForgeUI_FloatText:OnCombatLogImmunity(tEventArgs)
	if ForgeUI_FloatText._DB.profile.bDontShowImmunity then return end
	local tTextOption = self:GetDefaultCCStateTextOption()
	local strMessage = Apollo.GetString("FloatText_Immune")
	CombatFloater.ShowTextFloater( tEventArgs.unitTarget, strMessage, tTextOption )
end


function ForgeUI_FloatText:OnCombatMomentum( eMomentumType, nCount, strText )
	if not ForgeUI_FloatText._DB.profile.bShowCombatMomentum then return end
	-- Passes: type enum, player's total count for that bonus type, string combines these things (ie. "3 Evade")
	local arMomentumStrings = {
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
	tTextOption.fScale = 0.8
	tTextOption.fDuration = 2
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Back
	tTextOption.fOffset = 2.0
	tTextOption.fOffsetDirection = 90
	tTextOption.strFontFace = self._DB.profile.strFont
	tTextOption.arFrames = {
		[1] = {fTime = 0,		nColor = 0xFFFFFF,		fAlpha = 0,		fVelocityDirection = 90,	fVelocityMagnitude = 5,		fScale = 0.8},
		[2] = {fTime = 0.15,							fAlpha = 1.0,	fVelocityDirection = 90,	fVelocityMagnitude = .2,},
		[3] = {fTime = 0.5,		nColor = nBaseColor,},
		[4] = {fTime = 1.0,		nColor = nBaseColor,},
		[5] = {fTime = 1.1,		nColor = 0xFFFFFF,		fAlpha = 1.0,	fVelocityDirection 	= 90,	fVelocityMagnitude 	= 5,},
		[6] = {fTime = 1.3,		nColor 	= nBaseColor,	fAlpha 	= 0.0,},
	}

	local unitToAttachTo = GameLib.GetControlledUnit()
	local strMessage = String_GetWeaselString(Apollo.GetString(arMomentumStrings[eMomentumType]), nCount)
	if eMomentumType == CombatFloater.CodeEnumCombatMomentum.KillChain and nCount == 2 then
		strMessage = Apollo.GetString("FloatText_DoubleKill")
		tTextOption.strFontFace = self._DB.profile.strFont
	elseif eMomentumType == CombatFloater.CodeEnumCombatMomentum.KillChain and nCount == 3 then
		strMessage = Apollo.GetString("FloatText_TripleKill")
		tTextOption.strFontFace = self._DB.profile.strFont
		tTextOption.fScale = 1.0
	elseif eMomentumType == CombatFloater.CodeEnumCombatMomentum.KillChain and nCount == 5 then
		strMessage = Apollo.GetString("FloatText_PentaKill")
		tTextOption.strFontFace = self._DB.profile.strFont
		tTextOption.fScale = 1.2
	elseif eMomentumType == CombatFloater.CodeEnumCombatMomentum.KillChain and nCount > 5 then
		tTextOption.strFontFace = self._DB.profile.strFont
		tTextOption.fScale = 1.5
	end

	CombatFloater.ShowTextFloater(unitToAttachTo, strMessage, 0, tTextOption)
end

function ForgeUI_FloatText:OnMiss( unitCaster, unitTarget, eMissType )
	if not ForgeUI_FloatText._DB.profile.bShowDeflect then return end
	if unitTarget == nil or not Apollo.GetConsoleVariable("ui.showCombatFloater") then return end

	-- modify the text to be shown
	local tTextOption = FloatText:GetDefaultTextOption()

	tTextOption.strFontFace = ForgeUI_FloatText._DB.profile.strFont

	if GameLib.IsControlledUnit( unitTarget ) or unitTarget:GetType() == "Mount" then -- if the target unit is player's char
		tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal --Vertical--Horizontal  --IgnoreCollision
		tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Chest
		tTextOption.nColor = 0xbaeffb
		tTextOption.fOffset = -0.6
		tTextOption.fOffsetDirection = 0
		tTextOption.arFrames = {
			[1] = {fScale = 1.0,	fTime = 0,						fVelocityDirection = 0,		fVelocityMagnitude = 0,},
			[2] = {fScale = 0.6,	fTime = 0.05,	fAlpha = 1.0,},
			[3] = {fScale = 0.6,	fTime = .2,		fAlpha = 1.0,	fVelocityDirection = 180,	fVelocityMagnitude = 3,},
			[4] = {fScale = 0.6,	fTime = .45,	fAlpha = 0.2,	fVelocityDirection = 180,},
		}
	else
		tTextOption.fScale = 1.0
		tTextOption.fDuration = 2
		tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.IgnoreCollision --Horizontal
		tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Chest
		tTextOption.fOffset = -0.8
		tTextOption.fOffsetDirection = 0
		tTextOption.arFrames = {
			[1] = {fScale = 1.1,	fTime = 0,		fAlpha = 1.0,	nColor = 0xb0b0b0,},
			[2] = {fScale = 0.7,	fTime = 0.1,	fAlpha = 1.0,},
			[3] = {					fTime = 0.3,	},
			[4] = {fScale = 0.7,	fTime = 0.8,	fAlpha = 1.0,},
			[5] = {					fTime = 0.9,	fAlpha = 0.0,},
		}
	end

	-- display the text
	local strText = (eMissType == GameLib.CodeEnumMissType.Dodge) and Apollo.GetString("CRB_Dodged") or Apollo.GetString("CRB_Blocked")
	CombatFloater.ShowTextFloater( unitTarget, strText, 0, tTextOption )
end

function ForgeUI_FloatText:OnExperienceGained(eReason, unitTarget, strText, fDelay, nAmount)
	if not ForgeUI_FloatText._DB.profile.bShowExperienceGained then return end
	if not Apollo.GetConsoleVariable("ui.showCombatFloater") or nAmount < 0 then return end

	local strFormatted
	local eMessageType = LuaEnumMessageType.XPAwarded
	local unitToAttachTo = GameLib.GetControlledUnit() -- unitTarget potentially nil

	local tContent = {}
	tContent.eType = LuaEnumMessageType.XPAwarded
	tContent.nNormal = 0
	tContent.nRested = 0

	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fScale = 0.8
	tTextOption.fDuration = 2
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Back
	tTextOption.fOffset = 4.0 -- GOTCHA: Different
	tTextOption.fOffsetDirection = 90
	tTextOption.strFontFace = self._DB.profile.strFont
	tTextOption.arFrames = {
		[1] = {fTime = 0,			fAlpha = 0,		fVelocityDirection = 90,	fVelocityMagnitude = 5,		fScale = 0.8},
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

function ForgeUI_FloatText:OnElderPointsGained(nAmount, nRested)
	if not Apollo.GetConsoleVariable("ui.showCombatFloater") or nAmount < 0 then return end

	local tContent = {}
	tContent.eType = LuaEnumMessageType.XPAwarded
	tContent.nNormal = nAmount
	tContent.nRested = 0

	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fScale = 0.8
	tTextOption.fDuration = 2
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Back
	tTextOption.fOffset = 4.0 -- GOTCHA: Different
	tTextOption.fOffsetDirection = 90
	tTextOption.strFontFace = self._DB.profile.strFont
	tTextOption.arFrames = {
		[1] = {fTime = 0,			fAlpha = 0,		fVelocityDirection = 90,	fVelocityMagnitude = 5,		fScale = 0.8},
		[2] = {fTime = 0.15,		fAlpha = 1.0,	fVelocityDirection = 90,	fVelocityMagnitude = .2,},
		[3] = {fTime = 0.5,	},
		[4] = {fTime = 1.0,	},
		[5] = {fTime = 1.1,			fAlpha = 1.0,	fVelocityDirection 	= 90,	fVelocityMagnitude 	= 5,},
		[6] = {fTime = 1.3,			fAlpha 	= 0.0,},
	}

	local eMessageType = LuaEnumMessageType.XPAwarded
	local unitToAttachTo = GameLib.GetControlledUnit()
	-- Base EP Floater
	local strFormatted = String_GetWeaselString(Apollo.GetString("FloatText_EPGained"), nAmount)
	self:RequestShowTextFloater(eMessageType, unitToAttachTo, strFormatted, tTextOption, 0, tContent)
	-- Rested EP Floater
	if nRested > 0 then
		strFormatted = String_GetWeaselString(Apollo.GetString("FloatText_RestEPGained"), nRested)
		self:RequestShowTextFloater(eMessageType, unitToAttachTo, strFormatted, tTextOption, 0, tContent)
	end
end

function ForgeUI_FloatText:OnPathExperienceGained( nAmount, strText )
	if not Apollo.GetConsoleVariable("ui.showCombatFloater") then return end

	local eMessageType = LuaEnumMessageType.PathXp
	local strFormatted = String_GetWeaselString(Apollo.GetString("FloatText_PathXP"), nAmount)

	local tContent = {
		eType = LuaEnumMessageType.PathXp,
		nAmount = nAmount,
	}

	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fScale = 0.8
	tTextOption.fDuration = 2
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Vertical
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Back
	tTextOption.fOffset = 4.0 -- GOTCHA: Different
	tTextOption.fOffsetDirection = 90
	tTextOption.strFontFace = self._DB.profile.strFont
	tTextOption.arFrames = {
		[1] = {fTime = 0,			fAlpha = 0,		fVelocityDirection = 90,	fVelocityMagnitude = 5,		fScale = 0.8},
		[2] = {fTime = 0.15,		fAlpha = 1.0,	fVelocityDirection = 90,	fVelocityMagnitude = .2,},
		[3] = {fTime = 0.5,	},
		[4] = {fTime = 1.0,	},
		[5] = {fTime = 1.1,			fAlpha = 1.0,	fVelocityDirection 	= 90,	fVelocityMagnitude 	= 5,},
		[6] = {fTime = 1.3,			fAlpha 	= 0.0,},
	}

	local unitToAttachTo = GameLib.GetControlledUnit() -- make unitToAttachTo to controlled unit because with the message system,
	self:RequestShowTextFloater( eMessageType, unitToAttachTo, strFormatted, tTextOption, 0, tContent )
end

function ForgeUI_FloatText:OnGenericFloater(unitTarget, strMessage)
	-- modify the text to be shown
	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fDuration = 2
	tTextOption.bUseScreenPos = true
	tTextOption.fOffset = 0
	tTextOption.nColor = 0x00FFFF
	tTextOption.strFontFace = self._DB.profile.strFont
	tTextOption.bShowOnTop = true

	CombatFloater.ShowTextFloater( unitTarget, strMessage, 0, tTextOption )
end

function ForgeUI_FloatText:OnUnitEvaded(unitSource, unitTarget, eReason, strMessage)
	local tTextOption = self:GetDefaultTextOption()
	tTextOption.fScale = 1.0
	tTextOption.fDuration = 2
	tTextOption.nColor = 0xbaeffb
	tTextOption.strFontFace = self._DB.profile.strFont
	tTextOption.eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.IgnoreCollision
	tTextOption.eLocation = CombatFloater.CodeEnumFloaterLocation.Chest
	tTextOption.fOffset = -0.8
	tTextOption.fOffsetDirection = 0

	tTextOption.arFrames = {
		[1] = {fTime = 0,		fScale = 2.0,	fAlpha = 1.0,	nColor = 0xFFFFFF,},
		[2] = {fTime = 0.15,	fScale = 0.9,	fAlpha = 1.0,},
		[3] = {fTime = 1.1,		fScale = 0.9,	fAlpha = 1.0,	fVelocityDirection = 0,	fVelocityMagnitude = 5,},
		[4] = {fTime = 1.3,						fAlpha = 0.0,	fVelocityDirection = 0,},
	}

	CombatFloater.ShowTextFloater( unitSource, strMessage, 0, tTextOption )
end

function ForgeUI_FloatText:GetOutgoingDamageAnimation(bCritical, fMaxSize, nBaseColor, fMaxDuration)
	if bCritical then
		return self:GetCriticalOutgoingDamageAnimation(fMaxSize, nBaseColor, fMaxDuration)
	end

	local frame1Direction
	local frame2Direction
	local frame3Direction

	if self.lastDirection == nil or self.lastDirection == "left" then
		self.lastDirection = "right"
		frame1Direction = 45
		frame2Direction = 45
		frame3Direction = 90
	else
		self.lastDirection = "left"
		frame1Direction = 315
		frame2Direction = 315
		frame3Direction = 275

	end

	return {
		[1] = {fScale = (fMaxSize) * 1.75,	fTime = 0,			  fVelocityDirection=frame1Direction , fVelocityMagnitude = 5.0	,					nColor = 0xffffff, },
		[2] = {fScale = fMaxSize,			fTime = .15,		  fAlpha = 1.0, 		  fVelocityDirection=frame2Direction , fVelocityMagnitude = 3.5,},
		[3] = {fScale = fMaxSize,			fTime = .3,			  fVelocityDirection=frame3Direction , fVelocityMagnitude = 2.0,					nColor = nBaseColor,},
		[4] = {fScale = fMaxSize,			fTime = .5,			  fAlpha = 1.0,},
		[5] = {								fTime = fMaxDuration, fAlpha = 0.0,},
	}

end

function ForgeUI_FloatText:GetCriticalOutgoingDamageAnimation(fMaxSize, nBaseColor, fMaxDuration)
	return {
		[1] = {fScale = (fMaxSize) * 1.75,	fTime = 0,			  				nColor = 0xffffff, },
		[2] = {fScale = fMaxSize,			fTime = .15,		  fAlpha = 1.0, 		  },
		[3] = {fScale = fMaxSize,			fTime = .3,			  				nColor = nBaseColor,},
		[4] = {fScale = fMaxSize,			fTime = .5,			  fAlpha = 1.0,},
		[5] = {								fTime = fMaxDuration, fAlpha = 0.0,},
	}

end

function ForgeUI_FloatText:GetFloatTextLocation(bHeal, targetUnit)
	if bHeal == false and self._DB.profile.bAdjustForTallUnits == true then

		local overheadAnchor = targetUnit:GetOverheadAnchor()
		if overheadAnchor ~= nil and overheadAnchor.y < self._DB.profile.nTallUnitOffset then
			return CombatFloater.CodeEnumFloaterLocation.Bottom
		end
	end

	return CombatFloater.CodeEnumFloaterLocation[self._DB.profile.strLocation]
end

function ForgeUI_FloatText:ForgeAPI_PopulateOptions()
	local wndGeneral = self.tOptionHolders["General"]

	G:API_AddNumberBox(self, wndGeneral, "Incoming damage threshold", self._DB.profile, "nDamageIncomingThreshold", {
		tOffsets = { 5, 5, 300, 30 },
		strHint = "Damage below this value will not be shown"
	})
	G:API_AddNumberBox(self, wndGeneral, "Incoming heals threshold", self._DB.profile, "nHealingIncomingThreshold", {
		tOffsets = { 5, 35, 300, 60 },
		strHint = "Heals below this value will not be shown"
	})
	G:API_AddNumberBox(self, wndGeneral, "Outgoing damage threshold", self._DB.profile, "nDamageOutgoingThreshold", {
		tOffsets ={ 275, 5, 475, 30 },
		strHint = "Damage below this value will not be shown"
	})
	G:API_AddNumberBox(self, wndGeneral, "Outgoing heals threshold", self._DB.profile, "nHealingOutgoingThreshold", {
		tOffsets = { 275, 35, 475, 60 },
		strHint = "Heals below this value will not be shown"
	})

	G:API_AddCheckBox(self,wndGeneral, "Adjust for tall units", self._DB.profile, "bAdjustForTallUnits", {
		tMove = { 0, 70 }
	})
	G:API_AddCheckBox(self,wndGeneral, "Don't show immunity/inf armor floaters", self._DB.profile, "bDontShowImmunity", {
		tMove = { 0, 100 },
	})
	G:API_AddCheckBox(self,wndGeneral, "Show Deflects", self._DB.profile, "bShowDeflect", {
		tMove = { 0, 130 },
	})
	G:API_AddCheckBox(self,wndGeneral, "Show CC's", self._DB.profile, "bShowCCState", {
		tMove = { 0, 160 },
	})
	G:API_AddCheckBox(self,wndGeneral, "Show Combat Momentum", self._DB.profile, "bShowCombatMomentum", {
		tMove = { 0, 190 },
	})
	G:API_AddCheckBox(self,wndGeneral, "Show Experience Gained", self._DB.profile, "bShowExperienceGained", {
		tMove = { 0, 220 },
	})
end

----------------------------------------------------------------------------------------------
-- ForgeUI_FloatText Instance
-----------------------------------------------------------------------------------------------
F:API_NewAddon(ForgeUI_FloatText)
