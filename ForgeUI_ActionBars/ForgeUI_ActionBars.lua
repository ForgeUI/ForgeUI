----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI addon
--
-- name: 		ForgeUI_ActionBars.lua
-- author:		Winty Badass@Jabbit
-- about:		Action bars addon for ForgeUI
-----------------------------------------------------------------------------------------------

require "Window"
require "HousingLib"
require "AbilityBook"
require "ActionSetLib"

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI

local Util = F:API_GetModule("util")

-----------------------------------------------------------------------------------------------
-- ForgeUI Addon Definition
-----------------------------------------------------------------------------------------------
local ForgeUI_ActionBars = {
	_NAME = "ForgeUI_ActionBars",
	_API_VERSION = 3,
	_VERSION = "2.0",
	DISPLAY_NAME = "Action bars",

	tSettings = {
		char = {
			nSelectedMount = 0,
			nSelectedPotion = 0,
			nSelectedPath = 0,
			nSelectedPet = 0,
		},
		profile = {
			tFrames = {
				[1] = {
					strKey = "ForgeUI_ActionBar",
					strName = "Action bar",
					strSnapTo = "bottom",
					strContentType = "LASBar",
					nButtons = 8,
					nButtonSize = 50,
					nRows = 1,
					nColumns = 8,
					nMinId = 0,
					nButtonPaddingVer = 3,
					nButtonPaddingHor = 3,
					bDrawHotkey = true,
					bDrawShortcutBottom = false,
					bShow = true,
					bHideOOC = false,
					bShowShadow = false,
				},
				[2] = {
					strKey = "ForgeUI_UtilBarOne",
					strName = "Utility bar 1",
					strSnapTo = "bottom",
					tMove = { -296, 0 },
					tSpecialButtons = { },
					nButtonSize = 50,
					nRows = 1,
					nColumns = 3,
					nMinId = 0,
					nButtonPaddingVer = 3,
					nButtonPaddingHor = 3,
					bDrawHotkey = true,
					bDrawShortcutBottom = false,
					bShow = true,
					bHideOOC = false,
					nFlyoutRows = 10,
					nFlyoutColumns = 10,
					strFlyoutDirection = "up",
					strFlyoutGrowth = "right",
				},
				[3] = {
					strKey = "ForgeUI_UtilBarTwo",
					strName = "Utility bar 2",
					strSnapTo = "bottom",
					tMove = { 296, 0 },
					tSpecialButtons = { },
					nButtonSize = 50,
					nRows = 1,
					nColumns = 3,
					nMinId = 0,
					nButtonPaddingVer = 3,
					nButtonPaddingHor = 3,
					bDrawHotkey = true,
					bDrawShortcutBottom = false,
					bShow = true,
					bHideOOC = false,
					nFlyoutRows = 10,
					nFlyoutColumns = 10,
					strFlyoutDirection = "up",
					strFlyoutGrowth = "right",
				},
				[4] = {
					strKey = "ForgeUI_UtilBarThree",
					strName = "Utility bar 3",
					strSnapTo = "bottom",
					tMove = { -296, -55 },
					tSpecialButtons = { },
					nButtonSize = 50,
					nRows = 1,
					nColumns = 3,
					nMinId = 0,
					nButtonPaddingVer = 3,
					nButtonPaddingHor = 3,
					bDrawHotkey = true,
					bDrawShortcutBottom = false,
					bShow = true,
					bHideOOC = false,
					nFlyoutRows = 10,
					nFlyoutColumns = 10,
					strFlyoutDirection = "up",
					strFlyoutGrowth = "right",
				},
				[5] = {
					strKey = "ForgeUI_UtilBarFour",
					strName = "Utility bar 4",
					strSnapTo = "bottom",
					tMove = { 296, -55 },
					tSpecialButtons = { },
					nButtonSize = 50,
					nRows = 1,
					nColumns = 3,
					nMinId = 0,
					nButtonPaddingVer = 3,
					nButtonPaddingHor = 3,
					bDrawHotkey = true,
					bDrawShortcutBottom = false,
					bShow = true,
					bHideOOC = false,
					nFlyoutRows = 10,
					nFlyoutColumns = 10,
					strFlyoutDirection = "up",
					strFlyoutGrowth = "right",
				},
				[6] = {
					strKey = "ForgeUI_BarOne",
					strName = "Bar 1",
					strSnapTo = "right",
					strContentType = "ABar",
					tMove = { 0, 0 },
					nButtons = 12,
					nButtonSize = 40,
					nRows = 12,
					nColumns = 1,
					nMinId = 12,
					nButtonPaddingVer = 3,
					nButtonPaddingHor = 3,
					bDrawHotkey = false,
					bShow = true,
					bShowMouseover = false,
				},
				[7] = {
					strKey = "ForgeUI_BarTwo",
					strName = "Bar 2",
					strSnapTo = "right",
					strContentType = "ABar",
					tMove = { -43, 0 },
					nButtons = 12,
					nButtonSize = 40,
					nRows = 12,
					nColumns = 1,
					nMinId = 24,
					nButtonPaddingVer = 3,
					nButtonPaddingHor = 3,
					bDrawHotkey = false,
					bShow = false,
					bShowMouseover = false,
				},
				[8] = {
					strKey = "ForgeUI_BarThree",
					strName = "Bar 3",
					strSnapTo = "left",
					strContentType = "ABar",
					tMove = { 0, 0 },
					nButtons = 12,
					nButtonSize = 40,
					nRows = 12,
					nColumns = 1,
					nMinId = 36,
					nButtonPaddingVer = 3,
					nButtonPaddingHor = 3,
					bDrawHotkey = false,
					bShowMouseover = false,
					bShow = false,
				},
				[9] = {
					strKey = "ForgeUI_ShortcutBar",
					strName = "Shortcut bar",
					strSnapTo = "top",
					strContentType = "SBar",
					tMove = { 0, 50 },
					nButtons = 8,
					nButtonSize = 45,
					nRows = 1,
					nColumns = 8,
					nMinId = 84,
					nButtonPaddingVer = 3,
					nButtonPaddingHor = 3,
					bDrawHotkey = true,
					bDrawShortcutBottom = false,
				},
				[10] = {
					strKey = "ForgeUI_VehicleBar",
					strName = "Vehicle bar",
					strSnapTo = "bottom",
					strContentType = "RMSBar",
					nButtons = 8,
					nButtonSize = 50,
					nRows = 1,
					nColumns = 8,
					nMinId = 0,
					nButtonPaddingVer = 3,
					nButtonPaddingHor = 3,
					bDrawHotkey = true,
					bDrawShortcutBottom = false,
					strScope = "misc",
				},
			}
		}
	},

	tQueuedBars = {},
}

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local tSnapToPoints = {
	["bottom"] = { 0.5, 1, 0.5, 1 },
	["right"] = { 1, 0.5, 1, 0.5 },
	["top"] = { 0.5, 0, 0.5, 0 },
	["left"] = { 0, 0.5, 0, 0.5 },
}

local tSnapToOffsets = {
	["bottom"] = { 0, -5, 0, -5 },
	["right"] = { -5, 0, -5, 0 },
	["top"] = { 0, 15, 0, 15 },
	["left"] = { 5, 0, 5, 0 },
}

local tPathTypeData = {
	[PlayerPathLib.PlayerPathType_Explorer] = { strText = "Explorer", strSprite = "BK3:UI_Icon_CharacterCreate_Path_Explorer" },
	[PlayerPathLib.PlayerPathType_Scientist] = { strText = "Scientist", strSprite = "BK3:UI_Icon_CharacterCreate_Path_Scientist" },
	[PlayerPathLib.PlayerPathType_Settler] = { strText = "Settler", strSprite = "BK3:UI_Icon_CharacterCreate_Path_Settler" },
	[PlayerPathLib.PlayerPathType_Soldier] = { strText = "Soldier", strSprite = "BK3:UI_Icon_CharacterCreate_Path_Soldier" },
}

local tSpecialButtons

-----------------------------------------------------------------------------------------------
-- Local
-----------------------------------------------------------------------------------------------
local tBars = {}
local wndMenuItem = nil

local bShortcutShown = false
local bVehicleShown = false

-----------------------------------------------------------------------------------------------
-- ForgeAPI
-----------------------------------------------------------------------------------------------
function ForgeUI_ActionBars:ForgeAPI_PreInit()
	Apollo.RegisterEventHandler("ShowActionBarShortcut", "ShowShortcutBar", self)
end

function ForgeUI_ActionBars:ForgeAPI_Init()
	self.xmlDoc = XmlDoc.CreateFromFile("..//ForgeUI_ActionBars//ForgeUI_ActionBars.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)

	-- Pre-hook into ActionSetLib.RequestActionSetChanges, to validate & eventually fix broken path skill
	local fnRequestActionSetChanges = ActionSetLib.RequestActionSetChanges
	ActionSetLib.RequestActionSetChanges = (function(tAbilities)
		local tPathAbilities = AbilityBook.GetAbilitiesList(Spell.CodeEnumSpellTag.Path)
		local bFound = false;

		for _, pathAbility in ipairs(tPathAbilities) do
			if pathAbility.nId == tAbilities[10] then
				bFound = true
				break
			end
		end

		if bFound == false then
			tAbilities[10] = 0
		end

		return fnRequestActionSetChanges(tAbilities)
	end)

	F:API_RegisterEvent(self, "PlayerEnteredCombat", "OnPlayerEnteredCombat")
	Apollo.RegisterEventHandler("PathChangeResult", "OnPathChangeResult", self)

	wndMenuItem = F:API_AddMenuItem(self, self.DISPLAY_NAME, "General")
end

function ForgeUI_ActionBars:ForgeAPI_LoadSettings()
	-- TODO: This is one fucking ugly hack
	-- If GeminiDB gets { 3, 2, 1 } as default, and then user removes some value from this table
	-- GeminiDB still uses this table as base and than pastes updated table on top of it.
	-- So If i remove 2 from default and reload table new table is { 3, 1, 1 } instead of { 3, 1 }
	-- FIX IT !!!
	if #self._DB.profile.tFrames[2].tSpecialButtons == 0 then
		self._DB.profile.tFrames[2].tSpecialButtons = { 3, 2, 1 }
	end
	if #self._DB.profile.tFrames[3].tSpecialButtons == 0 then
		self._DB.profile.tFrames[3].tSpecialButtons = { 4, 5, 6 }
	end

	for _, tBar in pairs(self._DB.profile.tFrames) do
		self:SetupBar(tBar, false, true)
		self:SetupButtons(tBar)
		self:EditButtons(tBar)
		self:PositionButtons(tBar)
	end
end

function ForgeUI_ActionBars:OnDocLoaded()
	if self.xmlDoc == nil and not self.xmlDoc:IsLoaded() then return end

	for k, v in pairs(self._DB.profile.tFrames) do
		self:GenerateBar(v)
	end

	self.bLoaded = true

	for k, v in pairs(self.tQueuedBars) do
		self:ShowShortcutBar(k, v.bIsVisible, v.nShortcuts)
	end
	self.tQueuedBars = {}

	self.wndShadow = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Shadow", "InWorldHudStratum", self)
	self.wndShadow:SetOpacity(0.5)
	self.wndShadow:Show(self._DB.profile.tFrames[1].bShowShadow,true)
end

function ForgeUI_ActionBars:OnPlayerEnteredCombat(_, bInCombat)
	for _, v in pairs(self._DB.profile.tFrames) do
		if v.bHideOOC then
			tBars[v.strKey]:SetOpacity(bInCombat and 1 or 0)
		end
	end
end

-----------------------------------------------------------------------------------------------
-- Addon functions
-----------------------------------------------------------------------------------------------
function ForgeUI_ActionBars:GenerateBar(tBar)
	local wndNewBar = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Bar", F:API_GetStratum("HudHigh"), self)
	wndNewBar:SetData(tBar)

	wndNewBar:AddEventHandler("MouseEnter", "OnMouseEnter", self)
	wndNewBar:AddEventHandler("MouseExit", "OnMouseExit", self)

	tBars[tBar.strKey] = wndNewBar

	F:API_AddMenuToMenuItem(self, wndMenuItem, tBar.strName, tBar.strKey)

	return wndNewBar
end

function ForgeUI_ActionBars:OnMouseEnter( wndHandler, wndControl )
	local tBar = wndControl:GetData()
	if not tBar or type(tBar) ~= "table" then return end

	if tBar.bShowMouseover then
		wndControl:SetOpacity(1)
	end

	if tBar.bHideOOC then
		wndControl:SetOpacity(1)
	end
end

function ForgeUI_ActionBars:OnMouseExit( wndHandler, wndControl )
	local tBar = wndControl:GetData()
	if not tBar or type(tBar) ~= "table" then return end

	if tBar.bShowMouseover then
		wndControl:SetOpacity(0)
	end

	if tBar.bHideOOC and not GameLib.GetPlayerUnit():IsInCombat() then
		wndControl:SetOpacity(0)
	end
end

function ForgeUI_ActionBars:SetupBar(tBar, bResetMover, bResetAnchors)
	local wndBar = tBars[tBar.strKey]
	wndBar:SetData(tBar)

	wndBar:SetAnchorPoints(unpack(tSnapToPoints[tBar.strSnapTo]))
	wndBar:SetAnchorOffsets(self:Helper_BarOffsets(tBar, bResetAnchors))
	wndBar:SetOpacity(1)

	if tBar.strKey == "ForgeUI_ShortcutBar" then
		wndBar:Show(bShortcutShown)
	elseif tBar.strKey == "ForgeUI_VehicleBar" then
		wndBar:Show(bVehicleShown)
	elseif tBar.strKey == "ForgeUI_ActionBar" then
		wndBar:Show(not bVehicleShown and tBar.bShow)
	elseif tBar.bShow ~= nil then
		wndBar:Show(tBar.bShow)
	end

	if tBar.bShowMouseover then
		wndBar:SetOpacity(0)
	end

	if tBar.bHideOOC and not GameLib.GetPlayerUnit():IsInCombat() then
		wndBar:SetOpacity(0)
	end

	if bResetMover then
		F:API_ResetMover(self, tBar.strKey)
	end

	F:API_RegisterMover(self, wndBar, tBar.strKey, tBar.strName, tBar.strScope or "general", { strStratum = "high", bSizable = false })
end

function ForgeUI_ActionBars:SetupButtons(tBar)
	local wndBar = tBars[tBar.strKey]

	local nTotalButtons = tBar.nButtons or #tBar.tSpecialButtons

	wndBar:DestroyChildren()
	for i = 1, nTotalButtons do
		local wndBarButton = Apollo.LoadForm(self.xmlDoc, "ForgeUI_BarButton", wndBar, self)
	end
end

function ForgeUI_ActionBars:PositionButtons(tBar, bPositionBar)
	local wndBar = tBars[tBar.strKey]
	local tButtons = {}

	for k, v in pairs(wndBar:GetChildren()) do
		tButtons[k - 1] = v
	end

	local nButton = 0
	for i = 0, tBar.nRows - 1 do
		for j = 0, tBar.nColumns - 1 do

			if tBar.strSnapTo == "bottom" or tBar.strSnapTo == "top" then
				if tButtons[nButton] then
					tButtons[nButton]:SetAnchorOffsets(
						j * tBar.nButtonSize - j + j * tBar.nButtonPaddingHor,
						i * tBar.nButtonSize - i + i * tBar.nButtonPaddingVer,
						(j + 1) * tBar.nButtonSize - j + j * tBar.nButtonPaddingHor,
						(i + 1) * tBar.nButtonSize - i + i * tBar.nButtonPaddingVer
					)
				end
			elseif tBar.strSnapTo == "right" or tBar.strSnapTo == "left" then
				if tButtons[nButton] then
					tButtons[nButton]:SetAnchorOffsets(
						j * tBar.nButtonSize - j + j * tBar.nButtonPaddingHor,
						i * tBar.nButtonSize - i + i * tBar.nButtonPaddingVer,
						(j + 1) * tBar.nButtonSize - j + j * tBar.nButtonPaddingHor,
						(i + 1) * tBar.nButtonSize - i + i * tBar.nButtonPaddingVer
					)
				end
			end

			nButton = nButton + 1
		end
	end

	if bPositionBar then
		self:SetupBar(tBar, true, false)
	end
end

function ForgeUI_ActionBars:EditButtons(tBar)
	local wndBar = tBars[tBar.strKey]

	for k, v in pairs(wndBar:GetChildren()) do
		local i = k - 1
		local wndBarButton = v

		local tXml = self.xmlDoc:ToTable()
		local tActionButton
		for k, v in pairs(tXml) do
			if v.Name == "ForgeUI_ActionButton" then
				tActionButton = v
			end
		end

		if tBar.tSpecialButtons then
			tActionButton.ContentId = tSpecialButtons[tBar.tSpecialButtons[k]].nContentId
			tActionButton.ContentType = tSpecialButtons[tBar.tSpecialButtons[k]].strContent
		elseif tBar.tButtons and tBar.tButtons[k] then
			tActionButton.ContentId = tBar.tButtons[k][1]
			tActionButton.ContentType = tBar.tButtons[k][2]
		else
			-- TODO : Come with better idea
			-- Vehicle bar dismound button workaround
			if tBar.strKey == "ForgeUI_VehicleBar" and i == 7 then
				tActionButton.ContentId = 8
				tActionButton.ContentType = "GCBar"
			else
				tActionButton.ContentId = tBar.nMinId + i
				tActionButton.ContentType = tBar.strContentType
			end
		end

		tActionButton.DrawHotkey = tBar.bDrawHotkey
		tActionButton.DrawShortcutBottom = false

		wndBarButton:FindChild("Holder"):DestroyChildren()
		wndBarButton:FindChild("Holder"):SetAnchorOffsets(1, 1, -1, -1)
		wndBarButton:FindChild("Hotkey"):Show(false)

		if tBar.strSnapTo == "bottom" or tBar.strSnapTo == "top" then
			tActionButton.DrawShortcutBottom = tBar.bDrawHotkey and tBar.bDrawShortcutBottom

			wndBarButton:FindChild("Holder"):SetAnchorOffsets(1, 1, -1, tActionButton.DrawShortcutBottom and 12 or -1)
			wndBarButton:FindChild("Hotkey"):Show(tBar.bDrawShortcutBottom)
		end

		Apollo.LoadForm(XmlDoc.CreateFromTable(tXml), "ForgeUI_ActionButton", wndBarButton:FindChild("Holder"), self)

		if tBar.tSpecialButtons and tSpecialButtons[tBar.tSpecialButtons[k]].fnFill then
			tSpecialButtons[tBar.tSpecialButtons[k]].fnFill(self, wndBarButton, tBar)
			wndBarButton:AddEventHandler("MouseButtonDown", "BarButton_OnMouseDown", self)
			wndBarButton:SetData({fnFill = tSpecialButtons[tBar.tSpecialButtons[k]].fnFill, tConfig = tBar})

			if tSpecialButtons[tBar.tSpecialButtons[k]].strName == "Pet" then
				wndBarButton:FindChild("Holder"):DestroyChildren()
				wndBarButton:SetName("ForgeUI_PetButton")
				self:LoadPet(wndBarButton:FindChild("Holder"))
			end
		end
	end
end

-- filling methods
-- stances
function ForgeUI_ActionBars:FillStances(wnd, tConfig)
	local wndList = wnd:FindChild("List")
	wndList:DestroyChildren()

	local nCount = 0
	for idx, spellObject in pairs(GameLib.GetClassInnateAbilitySpells().tSpells) do
		if idx % 2 == 1 then
			nCount = nCount + 1
			local wndCurr = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellBtn", wndList, self)
			wndCurr:SetData({sType = "stance"})
			wndCurr:FindChild("Icon"):SetSprite(spellObject:GetIcon())
			wndCurr:FindChild("Button"):SetData(nCount)
			wndCurr:SetAnchorOffsets(0, 0, tConfig.nButtonSize, tConfig.nButtonSize)

			if Tooltip and Tooltip.GetSpellTooltipForm then
				wndCurr:SetTooltipDoc(nil)
				Tooltip.GetSpellTooltipForm(self, wndCurr, spellObject)
			end
		end
	end

	self:ResizeFlyout(wnd,tConfig,nCount)
end

-- mounts
function ForgeUI_ActionBars:FillMounts(wnd, tConfig)
	local wndList = wnd:FindChild("List")
	wndList:DestroyChildren()

	local tMountList = CollectiblesLib.GetMountList()
	local tSelectedSpellObj = nil

	local nCount = 0
	for _, tMount in pairs(tMountList) do
		if tMount.bIsKnown then
			nCount = nCount + 1

			local tSpellObject = tMount.splObject

			if tSpellObject:GetId() == self._DB.char.nSelectedMount then
				tSelectedSpellObj = tSpellObject
			end

			local wndCurr = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellBtn", wndList, self)
			wndCurr:SetData({sType = "mount"})
			wndCurr:FindChild("Icon"):SetSprite(tSpellObject:GetIcon())
			wndCurr:FindChild("Button"):SetData(tSpellObject)

			wndCurr:SetAnchorOffsets(0, 0, tConfig.nButtonSize, tConfig.nButtonSize)

			if Tooltip and Tooltip.GetSpellTooltipForm then
				wndCurr:SetTooltipDoc(nil)
				Tooltip.GetSpellTooltipForm(self, wndCurr, tSpellObject, {})
			end
		end
	end

	if tSelectedSpellObj == nil and #tMountList > 0 then
		tSelectedSpellObj = tMountList[1].splObject
	end

	if tSelectedSpellObj ~= nil then
		GameLib.SetShortcutMount(tSelectedSpellObj:GetId())
	end

	self:ResizeFlyout(wnd,tConfig,nCount)
end

-- pets
function ForgeUI_ActionBars:FillPets(wnd, tConfig)
	local wndList = wnd:FindChild("List")
	wndList:DestroyChildren()

	local tPetList = CollectiblesLib.GetVanityPetList()
	local tSelectedSpellObj = nil

	local nCount = 0
	for _, tPet in pairs(tPetList) do
		if tPet.bIsKnown then
			nCount = nCount + 1

			local tSpellObject = tPet.splObject

			if tSpellObject:GetId() == self._DB.char.nSelectedPet then
				tSelectedSpellObj = tSpellObject
			end

			local wndCurr = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellBtn", wndList, self)
			wndCurr:SetData({sType = "pet"})
			wndCurr:FindChild("Icon"):SetSprite(tSpellObject:GetIcon())
			wndCurr:FindChild("Button"):SetData(tPet)

			wndCurr:SetAnchorOffsets(0, 0, tConfig.nButtonSize, tConfig.nButtonSize)

			if Tooltip and Tooltip.GetSpellTooltipForm then
				wndCurr:SetTooltipDoc(nil)
				Tooltip.GetSpellTooltipForm(self, wndCurr, tSpellObject, {})
			end
		end
	end

	self:ResizeFlyout(wnd,tConfig,nCount)
end

-- load pet
function ForgeUI_ActionBars:LoadPet(wnd)
	if not self._DB.char.nSelectedPet then return end
	local tPetList = CollectiblesLib.GetVanityPetList()

	for idx, tPet in pairs(tPetList) do
		local tSpellObject = tPet.splObject

		if tPet.nId == self._DB.char.nSelectedPet then
			wnd:SetSprite(tPet.splObject:GetIcon())

			if Tooltip and Tooltip.GetSpellTooltipForm then
				wnd:SetTooltipDoc(nil)
				Tooltip.GetSpellTooltipForm(self, wnd, tSpellObject, {})
			end

			return
		end
	end
end

-- recalls
function ForgeUI_ActionBars:FillRecalls(wnd, tConfig)
	local wndList = wnd:FindChild("List")
	wndList:DestroyChildren()

	if wnd:FindChild("ForgeUI_ActionButton") then
		wnd:FindChild("ForgeUI_ActionButton"):SetContentId(GameLib.GetDefaultRecallCommand())
	end

	local nCount = 0
	local bHasBinds = false
	local bHasWarplot = false
	local guildCurr = nil

	-- todo: condense this
	if GameLib.HasBindPoint() == true then
		--load recall
		local wndBind = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellBtn", wndList, self)
		wndBind:SetAnchorPoints(0,0,0,0)
		wndBind:SetAnchorOffsets(0,0,tConfig.nButtonSize,tConfig.nButtonSize)
		wndBind:FindChild("Border"):DestroyChildren()

		local wndBindBtn = Apollo.LoadForm(self.xmlDoc, "ForgeUI_ActionButton", wndBind:FindChild("Border"), self)
		wndBindBtn:SetContentId(GameLib.CodeEnumRecallCommand.BindPoint)
		wndBindBtn:SetData(GameLib.CodeEnumRecallCommand.BindPoint)
		wndBindBtn:SetStyle("noclip", true)

		wndBindBtn:AddEventHandler("MouseButtonDown", "RecallBtn_OnButtonDown", self)

		wndBindBtn:SetAnchorPoints(0,0,1,1)
		wndBindBtn:SetAnchorOffsets(1,1,-1,-1)

		bHasBinds = true
		nCount = nCount + 1
	end

	if HousingLib.IsResidenceOwner() == true then
		-- load house
		local wndHouse = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellBtn", wndList, self)
		wndHouse:SetAnchorPoints(0,0,0,0)
		wndHouse:SetAnchorOffsets(0,0,tConfig.nButtonSize,tConfig.nButtonSize)
		wndHouse:FindChild("Border"):DestroyChildren()

		local wndHouseBtn = Apollo.LoadForm(self.xmlDoc, "ForgeUI_ActionButton", wndHouse:FindChild("Border"), self)
		wndHouseBtn:SetContentId(GameLib.CodeEnumRecallCommand.House)
		wndHouseBtn:SetData(GameLib.CodeEnumRecallCommand.House)
		wndHouseBtn:SetStyle("noclip", true)

		wndHouseBtn:AddEventHandler("MouseButtonDown", "RecallBtn_OnButtonDown", self)

		wndHouseBtn:SetAnchorPoints(0,0,1,1)
		wndHouseBtn:SetAnchorOffsets(1,1,-1,-1)

		bHasBinds = true
		nCount = nCount + 1
	end

	-- Determine if this player is in a WarParty
	for key, guildCurr in pairs(GuildLib.GetGuilds()) do
		if guildCurr:GetType() == GuildLib.GuildType_WarParty then
			bHasWarplot = true
			break
		end
	end

	if bHasWarplot == true then
		-- load warplot
		local wndWarplot = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellBtn", wndList, self)
		wndWarplot:SetAnchorPoints(0,0,0,0)
		wndWarplot:SetAnchorOffsets(0,0,tConfig.nButtonSize,tConfig.nButtonSize)
		wndWarplot:FindChild("Border"):DestroyChildren()

		local wndWarplotBtn = Apollo.LoadForm(self.xmlDoc, "ForgeUI_ActionButton", wndWarplot:FindChild("Border"), self)
		wndWarplotBtn:SetContentId(GameLib.CodeEnumRecallCommand.Warplot)
		wndWarplotBtn:SetData(GameLib.CodeEnumRecallCommand.Warplot)
		wndWarplotBtn:SetStyle("noclip", true)

		wndWarplotBtn:AddEventHandler("MouseButtonDown", "RecallBtn_OnButtonDown", self)

		wndWarplotBtn:SetAnchorPoints(0,0,1,1)
		wndWarplotBtn:SetAnchorOffsets(1,1,-1,-1)

		bHasBinds = true
		nCount = nCount + 1
	end

	local bIllium = false
	local bThayd = false

	for idx, tSpell in pairs(AbilityBook.GetAbilitiesList(Spell.CodeEnumSpellTag.Misc) or {}) do
		if tSpell.bIsActive and tSpell.nId == GameLib.GetTeleportIlliumSpell():GetBaseSpellId() then
			bIllium = true
		end
		if tSpell.bIsActive and tSpell.nId == GameLib.GetTeleportThaydSpell():GetBaseSpellId() then
			bThayd = true
		end
	end

	if bIllium then
		-- load capital
		local wndIllium = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellBtn", wndList, self)
		wndIllium:SetAnchorPoints(0,0,0,0)
		wndIllium:SetAnchorOffsets(0,0,tConfig.nButtonSize,tConfig.nButtonSize)
		wndIllium:FindChild("Border"):DestroyChildren()

		local wndIlliumBtn = Apollo.LoadForm(self.xmlDoc, "ForgeUI_ActionButton", wndIllium:FindChild("Border"), self)
		wndIlliumBtn:SetContentId(GameLib.CodeEnumRecallCommand.Illium)
		wndIlliumBtn:SetData(GameLib.CodeEnumRecallCommand.Illium)
		wndIlliumBtn:SetStyle("noclip", true)

		wndIlliumBtn:AddEventHandler("MouseButtonDown", "RecallBtn_OnButtonDown", self)

		wndIlliumBtn:SetAnchorPoints(0,0,1,1)
		wndIlliumBtn:SetAnchorOffsets(1,1,-1,-1)

		bHasBinds = true
		nCount = nCount + 1
	end

	if bThayd then
		-- load capital
		local wndThayd = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellBtn", wndList, self)
		wndThayd:SetAnchorPoints(0,0,0,0)
		wndThayd:SetAnchorOffsets(0,0,tConfig.nButtonSize,tConfig.nButtonSize)
		wndThayd:FindChild("Border"):DestroyChildren()

		local wndThaydBtn = Apollo.LoadForm(self.xmlDoc, "ForgeUI_ActionButton", wndThayd:FindChild("Border"), self)
		wndThaydBtn:SetContentId(GameLib.CodeEnumRecallCommand.Thayd)
		wndThaydBtn:SetData(GameLib.CodeEnumRecallCommand.Thayd)
		wndThaydBtn:SetStyle("noclip", true)

		wndThaydBtn:AddEventHandler("MouseButtonDown", "RecallBtn_OnButtonDown", self)

		wndThaydBtn:SetAnchorPoints(0,0,1,1)
		wndThaydBtn:SetAnchorOffsets(1,1,-1,-1)

		bHasBinds = true
		nCount = nCount + 1
	end

	self:ResizeFlyout(wnd,tConfig,nCount)
end

-- potions
function ForgeUI_ActionBars:FillPotions(wnd, tConfig)
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end

	local wndList = wnd:FindChild("List")
	wndList:DestroyChildren()

	local tItemList = unitPlayer:GetInventoryItems()
	local tPotions = {}

	for idx, tItemData in pairs(tItemList) do
		if tItemData and tItemData.itemInBag and tItemData.itemInBag:GetItemCategory() == 48 then--and tItemData.itemInBag:GetConsumable() == "Consumable" then
			local itemPotion = tItemData.itemInBag
			tPotions[itemPotion:GetItemId()] = {
				itemObject = itemPotion,
				nCount = itemPotion:GetStackCount()
			}
		end
	end

	local nCount = 0
	for idx, tData  in pairs(tPotions) do
		nCount = nCount + 1

		local wndCurr = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellBtn", wndList, self)
		wndCurr:SetData({sType = "potion"})
		wndCurr:FindChild("Icon"):SetSprite(tData.itemObject:GetIcon())
		wndCurr:FindChild("Button"):SetData(tData.itemObject)

		wndCurr:SetAnchorOffsets(0,0,tConfig.nButtonSize,tConfig.nButtonSize)

		wndCurr:SetTooltipDoc(nil)
		Tooltip.GetItemTooltipForm(self, wndCurr, tData.itemObject, {})
	end

	GameLib.SetShortcutPotion(self._DB.char.nSelectedPotion)
	self:ResizeFlyout(wnd,tConfig,nCount)
end

-- path
function ForgeUI_ActionBars:FillPath(wnd, tConfig)
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end

	local tAbilities = AbilityBook.GetAbilitiesList(Spell.CodeEnumSpellTag.Path)
	if not tAbilities then
		return
	end

	local wndList = wnd:FindChild("List")
	wndList:DestroyChildren()

	self:ValidateSelectedPath()

	local nCount = 0

	for ePathType, tPathInfo in pairs(PlayerPathLib:GetPathStatuses().tPaths) do
		if tPathInfo and (tPathInfo.bUnlocked and not tPathInfo.bActive) then
			nCount = nCount + 1
			local wndCurr = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellBtn", wndList, self)
			local wndIcon = wndCurr:FindChild("Icon")
			wndCurr:SetData({sType = "path_switch"})
			wndCurr:SetTooltip(tPathTypeData[ePathType].strText)
			wndIcon:SetSprite(tPathTypeData[ePathType].strSprite)
			local nCooldown = PlayerPathLib:GetPathChangeCooldown() or 0
			if nCooldown > 0 then
				wndIcon:SetBGColor("UI_BtnTextGrayDisabled")
				wndIcon:SetTextFlags("DT_CENTER", true)
				wndIcon:SetTextFlags("DT_VCENTER", true)
				wndIcon:SetText(Util:FormatDuration(nCooldown))
				wndIcon:SetFont("CRB_Header14")
			end
			wndCurr:FindChild("Button"):SetData(ePathType)
			wndCurr:SetAnchorOffsets(0,0,tConfig.nButtonSize,tConfig.nButtonSize)
		end
	end

	for _, tAbility in pairs(tAbilities) do
		local splObject = self:GetPathSkillForDisplay(tAbility);
		if splObject then
			nCount = nCount + 1
			local wndCurr = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellBtn", wndList, self)
			wndCurr:SetData({sType = "path"})
			wndCurr:FindChild("Icon"):SetSprite(splObject:GetIcon())
			wndCurr:FindChild("Button"):SetData(tAbility.nId)
			wndCurr:SetAnchorOffsets(0,0,tConfig.nButtonSize,tConfig.nButtonSize)

			if Tooltip and Tooltip.GetSpellTooltipForm then
				wndCurr:SetTooltipDoc(nil)
				Tooltip.GetSpellTooltipForm(self, wndCurr, spellObject)
			end
		end
	end

	local tActionSet = ActionSetLib.GetCurrentActionSet()

	--if self._DB.char.nSelectedPath > 0 and ActionSetLib.IsSpellCompatibleWithActionSet(self._DB.char.nSelectedPath) ~= 3 then
	Event_FireGenericEvent("PathAbilityUpdated", self._DB.char.nSelectedPath) -- TODO: Make it work
	tActionSet[10] = self._DB.char.nSelectedPath
	--else
	--	tActionSet[10] = tActionSet[10]
	--	self._DB.char.nSelectedPath = tActionSet[10]
	--end
	ActionSetLib.RequestActionSetChanges(tActionSet)
	self:ResizeFlyout(wnd,tConfig,nCount)
end

-- Returns spellObject from tAbility only if said path ability is availible to the player
function ForgeUI_ActionBars:GetPathSkillForDisplay(tAbility)
	local pathLevel = PlayerPathLib.GetPathLevel()
	local splObject = nil

	for _, tier in ipairs(tAbility.tTiers) do
		if tier.nLevelReq <= pathLevel then
			splObject = tier.splObject
		end
	end

	return splObject
end

-- Validates if selected path skill is valid and usable by the player
-- Prevents locking of LAS
function ForgeUI_ActionBars:ValidateSelectedPath()
	if self._DB.char.nSelectedPath then
		local tAbilities = AbilityBook.GetAbilitiesList(Spell.CodeEnumSpellTag.Path)
		local bIsValidPathId = false

		for idx, tAbility in pairs(tAbilities) do
			if tAbility.bIsActive then
				bIsValidPathId = bIsValidPathId or tAbility.nId == self._DB.char.nSelectedPath
			end
		end

		self._DB.char.nSelectedPath = bIsValidPathId and self._DB.char.nSelectedPath or nil
	end
end

function ForgeUI_ActionBars:OnPathChangeResult(nResult)
	if nResult == GameLib.CodeEnumGenericError.Ok then
		local tPathAbilitiy = AbilityBook.GetAbilitiesList(Spell.CodeEnumSpellTag.Path)[1]
		if tPathAbilitiy ~= nil then
			local tActionSet = ActionSetLib.GetCurrentActionSet()

			self._DB.char.nSelectedPath = tPathAbilitiy.nId

			Event_FireGenericEvent("PathAbilityUpdated", self._DB.char.nSelectedPath)
			tActionSet[10] = self._DB.char.nSelectedPath
			ActionSetLib.RequestActionSetChanges(tActionSet)
		end
	end
end

---------------------------------------------------------------------------------------------------
-- LASBar Functions
---------------------------------------------------------------------------------------------------
function ForgeUI_ActionBars:OnGenerateTooltip(wndControl, wndHandler, eType, arg1, arg2)
	local xml = nil
	if eType == Tooltip.TooltipGenerateType_ItemInstance then -- Doesn't need to compare to item equipped
		Tooltip.GetItemTooltipForm(self, wndControl, arg1, {})
	elseif eType == Tooltip.TooltipGenerateType_ItemData then -- Doesn't need to compare to item equipped
		Tooltip.GetItemTooltipForm(self, wndControl, arg1, {})
	elseif eType == Tooltip.TooltipGenerateType_GameCommand then
		xml = XmlDoc.new()
		xml:AddLine(arg2)
		wndControl:SetTooltipDoc(xml)
	elseif eType == Tooltip.TooltipGenerateType_Macro then
		xml = XmlDoc.new()
		xml:AddLine(arg1)
		wndControl:SetTooltipDoc(xml)
	elseif eType == Tooltip.TooltipGenerateType_Spell then
		if Tooltip ~= nil and Tooltip.GetSpellTooltipForm ~= nil then
			Tooltip.GetSpellTooltipForm(self, wndControl, arg1)
		end
	elseif eType == Tooltip.TooltipGenerateType_PetCommand then
		xml = XmlDoc.new()
		xml:AddLine(arg2)
		wndControl:SetTooltipDoc(xml)
	end
end

function ForgeUI_ActionBars:OnSpellBtn( wndHandler, wndControl, eMouseButton )
	local sType = wndControl:GetParent():GetParent():GetData().sType
	if sType == "stance" then
		wndControl:GetParent():GetParent():GetParent():GetParent():GetParent():FindChild("Popup"):Show(false, true)
		GameLib.SetCurrentClassInnateAbilityIndex(wndHandler:GetData())
	elseif sType == "mount" then
		wndControl:GetParent():GetParent():GetParent():GetParent():GetParent():FindChild("Popup"):Show(false, true)
		self._DB.char.nSelectedMount = wndControl:GetData():GetId()
		GameLib.SetShortcutMount(self._DB.char.nSelectedMount)
	elseif sType == "pet" then
		wndControl:GetParent():GetParent():GetParent():GetParent():GetParent():FindChild("Popup"):Show(false, true)
		self._DB.char.nSelectedPet = wndControl:GetData().nId
		self:LoadPet(wndControl:GetParent():GetParent():GetParent():GetParent():GetParent():FindChild("Holder"))
	elseif sType == "potion" then
		wndControl:GetParent():GetParent():GetParent():GetParent():GetParent():FindChild("Popup"):Show(false, true)
		self._DB.char.nSelectedPotion = wndControl:GetData():GetItemId()
		GameLib.SetShortcutPotion(wndControl:GetData():GetItemId())
	elseif sType == "path" then
		local tActionSet = ActionSetLib.GetCurrentActionSet()

		self._DB.char.nSelectedPath = wndControl:GetData()

		Event_FireGenericEvent("PathAbilityUpdated", self._DB.char.nSelectedPath)
		tActionSet[10] = self._DB.char.nSelectedPath
		ActionSetLib.RequestActionSetChanges(tActionSet)

		wndControl:GetParent():GetParent():GetParent():GetParent():GetParent():FindChild("Popup"):Show(false, true)
	elseif sType == "path_switch" then
		local crb_pathlog = Apollo.GetAddon("PlayerPath")

		if crb_pathlog then
			if crb_pathlog.PathLogTypeSelectionChanged == nil or crb_pathlog.OnSelectPath == nil then
				return
			end
			Event_FireGenericEvent("PlayerPathShow_NoHide")
			if not crb_pathlog.wndMissionLog then
				crb_pathlog:Initialize()
			end
			local wndBtn = crb_pathlog.tPathTypeBtns[wndControl:GetData()]
			for _, wndPathTypeBtn in pairs(crb_pathlog.tPathTypeBtns) do
				wndPathTypeBtn:SetCheck(wndPathTypeBtn == wndBtn)
			end
			crb_pathlog:PathLogTypeSelectionChanged(wndBtn, wndBtn, 0)
			crb_pathlog:OnSelectPath(wndBtn, wndBtn, 0)
		end

		crb_pathlog = nil

		wndControl:GetParent():GetParent():GetParent():GetParent():GetParent():FindChild("Popup"):Show(false, true)
	end
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_BarButton Functions
---------------------------------------------------------------------------------------------------
function ForgeUI_ActionBars:BarButton_OnMouseDown( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if (wndControl:GetName() == "ForgeUI_BarButton" or wndControl:GetName() == "ForgeUI_PetButton") and eMouseButton == 1 then
		local tData = wndControl:GetData()
		if tData.fnFill ~= nil and type(tData.fnFill) == 'function' then
			tData.fnFill(self, wndControl, tData.tConfig)
		end

		wndControl:FindChild("Popup"):Show(true, true)
	elseif wndControl:GetName() == "ForgeUI_PetButton" and eMouseButton == 0 then
		if self._DB.char.nSelectedPet then
			GameLib.SummonVanityPet(self._DB.char.nSelectedPet)
		end
	end
end

function ForgeUI_ActionBars:RecallBtn_OnButtonDown( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	local wnd = wndControl:GetParent():GetParent():GetParent():GetParent():GetParent()
	if wndControl:GetName() == "ForgeUI_ActionButton" and eMouseButton == 1 then
		GameLib.SetDefaultRecallCommand(wndControl:GetData())
		wnd:FindChild("Holder"):FindChild("ForgeUI_ActionButton"):SetContentId(wndControl:GetData())
	end
end

function ForgeUI_ActionBars:ShowShortcutBar(nBar, bIsVisible, nShortcuts)
	if not self:IsLoaded() then
		self.tQueuedBars[nBar] = {
			bIsVisible = bIsVisible,
			nShortcuts = nShortcuts,
		}

		return
	end

	if nBar == ActionSetLib.CodeEnumShortcutSet.VehicleBar then -- vehiclebar
		bVehicleShown = bIsVisible

		if tBars["ForgeUI_ActionBar"] then
			tBars["ForgeUI_ActionBar"]:Show(not bVehicleShown)
			tBars["ForgeUI_VehicleBar"]:Show(bVehicleShown)
		end
	end

	if nBar == ActionSetLib.CodeEnumShortcutSet.FloatingSpellBar then -- shortcutbar
		bShortcutShown = bIsVisible

		if bIsVisible and tBars["ForgeUI_ShortcutBar"] then
			tBars["ForgeUI_ShortcutBar"]:Show(true)
		elseif tBars["ForgeUI_ShortcutBar"] then
			tBars["ForgeUI_ShortcutBar"]:Show(false)
		end
	end
end

function ForgeUI_ActionBars:ToggleShadow(tBar)
	self.wndShadow:Show(tBar.bShowShadow,true)
end

-----------------------------------------------------------------------------------------------
-- Helpers
-----------------------------------------------------------------------------------------------
function ForgeUI_ActionBars:Helper_BarOffsets(tBar, bReset)
	local nLeft, nTop, nRight, nBottom
	local nCenterVert, nCenterHor

	local nWidth = tBar.nColumns * tBar.nButtonSize - tBar.nColumns + tBar.nColumns * tBar.nButtonPaddingHor - tBar.nButtonPaddingHor / 2
	local nHeight = tBar.nRows * tBar.nButtonSize - tBar.nRows + tBar.nRows * tBar.nButtonPaddingVer - tBar.nButtonPaddingVer / 2

	if bReset then
		nLeft, nTop, nRight, nBottom = unpack(tSnapToOffsets[tBar.strSnapTo])

		if tBar.tMove then
			nLeft = nLeft + tBar.tMove[1]
			nTop = nTop + tBar.tMove[2]
			nRight = nRight + tBar.tMove[1]
			nBottom = nBottom + tBar.tMove[2]
		end
	else
		nLeft, nTop, nRight, nBottom = tBars[tBar.strKey]:GetAnchorOffsets()
	end

	nCenterHor = (nLeft / 2) + (nRight / 2)
	nCenterVert = (nTop / 2) + (nBottom / 2)

	if tBar.strSnapTo == "bottom" then
		nLeft = nCenterHor + nWidth / -2
		nRight = nCenterHor + nWidth / 2

		nTop = nBottom - nHeight
	elseif tBar.strSnapTo == "top" then
		nLeft = nCenterHor + nWidth / -2
		nRight = nCenterHor + nWidth / 2

		nBottom = nTop + nHeight
	elseif tBar.strSnapTo == "right" then
		nTop = nCenterVert + nHeight / -2
		nBottom = nCenterVert + nHeight / 2

		nLeft = nRight - nWidth
	elseif tBar.strSnapTo == "left" then
		nTop = nCenterVert + nHeight / -2
		nBottom = nCenterVert + nHeight / 2

		nRight = nLeft + nWidth
	end

	return nLeft, nTop, nRight, nBottom
end

function ForgeUI_ActionBars:ResizeFlyout(wnd,tConfig,nCount)
	if not wnd or not tConfig or not nCount then
		return
	end

	local wndList = wnd:FindChild("List")
	local wndPopup = wnd:FindChild("Popup")
	local direction = tConfig.strFlyoutDirection or "up"
	local growth = tConfig.strFlyoutGrowth or "right"
	local cols = tConfig.nFlyoutColumns or 8
	local rows = tConfig.nFlyoutRows or 8

	if nCount <= cols then
		cols = nCount
		rows = 1
	else
		if (math.ceil(nCount/cols)) < rows then
			rows = math.ceil(nCount/cols)
		end
	end

	local width = (tConfig.nButtonSize * cols) + 3
	local height = (tConfig.nButtonSize * rows) + 3

	if direction == "left" then
		wndPopup:SetAnchorPoints(0,0,0,0)

		if growth == "up" then
			wndPopup:SetAnchorOffsets((width * -1),((height - tConfig.nButtonSize) * -1),-1,tConfig.nButtonSize)
			wndList:ArrangeChildrenTiles(Window.CodeEnumArrangeOrigin.RightOrBottom)
		else
			wndPopup:SetAnchorOffsets((width * -1),0,-1,height)
			wndList:ArrangeChildrenTiles()
		end
	elseif direction == "right" then
		wndPopup:SetAnchorPoints(1,0,1,0)

		if growth == "up" then
			wndPopup:SetAnchorOffsets(1,((height - tConfig.nButtonSize) * -1),width,tConfig.nButtonSize)
			wndList:ArrangeChildrenTiles(Window.CodeEnumArrangeOrigin.RightOrBottom)
		else
			wndPopup:SetAnchorOffsets(1,0,width,height)
			wndList:ArrangeChildrenTiles()
		end
	elseif direction == "up" then
		wndPopup:SetAnchorPoints(1,0,1,0)

		if growth == "left" then
			wndPopup:SetAnchorOffsets((width * -1),(height * -1),0,-1)
			wndList:ArrangeChildrenTiles(Window.CodeEnumArrangeOrigin.RightOrBottom)
		else
			wndPopup:SetAnchorOffsets((tConfig.nButtonSize * -1),(height * -1),(width - tConfig.nButtonSize),-1)
			wndList:ArrangeChildrenTiles()
		end
	elseif direction == "down" then
		wndPopup:SetAnchorPoints(0,1,0,1)

		if growth == "left" then
			wndPopup:SetAnchorOffsets(((width - tConfig.nButtonSize) * -1),1,tConfig.nButtonSize,height)
			wndList:ArrangeChildrenTiles(Window.CodeEnumArrangeOrigin.RightOrBottom)
		else
			wndPopup:SetAnchorOffsets(0,1,width,height)
			wndList:ArrangeChildrenTiles()
		end
	end
end

function ForgeUI_ActionBars:ForgeAPI_PopulateOptions()
	for k, v in pairs(self._DB.profile.tFrames) do
		local wnd = self.tOptionHolders[v.strKey]

		if v.bShow ~= nil then
			G:API_AddCheckBox(self, wnd, "Show", v, "bShow", { tMove = {0, 0},
				fnCallback = function(...) self:SetupBar(v) end })
		end

		if v.bShowMouseover ~= nil then
			G:API_AddCheckBox(self, wnd, "Show on mouseover", v, "bShowMouseover", { tMove = {200, 0},
				fnCallback = function(...) self:SetupBar(v) end })
		end

		if v.bHideOOC ~= nil then
			G:API_AddCheckBox(self, wnd, "Hide out of combat", v, "bHideOOC", { tMove = {400, 0},
				fnCallback = function(...) self:SetupBar(v) end })
		end

		if v.bDrawHotkey ~= nil then
			G:API_AddCheckBox(self, wnd, "Show hotkey", v, "bDrawHotkey", { tMove = {0, 30},
				fnCallback = function(...) self:EditButtons(v) end })
		end

		if v.bDrawShortcutBottom ~= nil then
			G:API_AddCheckBox(self, wnd, "Use bottom-styled hotkey", v, "bDrawShortcutBottom", { tMove = {10, 60},
				fnCallback = function(...) self:EditButtons(v) end })
		end

		if v.strName == "Action bar" then
			G:API_AddCheckBox(self, wnd, "Show bottom shadow", v, "bShowShadow", { tMove = {0, 90},
				fnCallback = function(...) self:ToggleShadow(v) end })
		end

		if v.nButtons ~= nil then
			G:API_AddNumberBox(self, wnd, "Number of buttons ", v, "nButtons", {
  				tMove = {200, 30},
				fnCallback = function(...) self:SetupButtons(v); self:EditButtons(v); self:PositionButtons(v, true) end
			})
		end

		if v.nButtonSize ~= nil then
			G:API_AddNumberBox(self, wnd, "Button size ", v, "nButtonSize", { tMove = {400, 30},
				fnCallback = function(...) self:PositionButtons(v, true) end })
		end

		if v.nRows ~= nil then
			G:API_AddNumberBox(self, wnd, "Rows ", v, "nRows", { tMove = {200, 90},
				fnCallback = function(...) self:PositionButtons(v, true) end })
		end

		if v.nColumns ~= nil then
			G:API_AddNumberBox(self, wnd, "Columns ", v, "nColumns", { tMove = {200, 120},
				fnCallback = function(...) self:PositionButtons(v, true) end })
		end

		if v.nButtonPaddingHor ~= nil then
			G:API_AddNumberBox(self, wnd, "Horizontal padding ", v, "nButtonPaddingHor", { tMove = {400, 90},
				fnCallback = function(...) self:PositionButtons(v, true) end })
		end

		if v.nButtonPaddingVer ~= nil then
			G:API_AddNumberBox(self, wnd, "Vertical padding ", v, "nButtonPaddingVer", { tMove = {400, 120},
				fnCallback = function(...) self:PositionButtons(v, true) end })
		end

		if v.nFlyoutRows ~= nil then
			G:API_AddNumberBox(self, wnd, "Flyout Rows ", v, "nFlyoutRows", { tMove = {200, 160} })
		end

		if v.nFlyoutColumns ~= nil then
			G:API_AddNumberBox(self, wnd, "Flyout Columns ", v, "nFlyoutColumns", { tMove = {200, 190} })
		end

		if v.strFlyoutGrowth ~= nil then
			local wndFlyoutDirectionBox = G:API_AddComboBox(self, wnd, "Flyout growth", v, "strFlyoutGrowth", { tMove = {400, 190}, tWidths = {100, 150} })
			G:API_AddOptionToComboBox(self, wndFlyoutDirectionBox , "Up", "up", {})
			G:API_AddOptionToComboBox(self, wndFlyoutDirectionBox , "Down", "down", {})
			G:API_AddOptionToComboBox(self, wndFlyoutDirectionBox , "Left", "left", {})
			G:API_AddOptionToComboBox(self, wndFlyoutDirectionBox , "Right", "right", {})
		end

		if v.strFlyoutDirection ~= nil then
			local wndFlyoutGrowthBox = G:API_AddComboBox(self, wnd, "Flyout direction", v, "strFlyoutDirection", { tMove = {400, 160}, tWidths = {100, 150} })
			G:API_AddOptionToComboBox(self, wndFlyoutGrowthBox , "Up", "up", {})
			G:API_AddOptionToComboBox(self, wndFlyoutGrowthBox , "Down", "down", {})
			G:API_AddOptionToComboBox(self, wndFlyoutGrowthBox , "Left", "left", {})
			G:API_AddOptionToComboBox(self, wndFlyoutGrowthBox , "Right", "right", {})
		end

		if v.tSpecialButtons ~= nil then
			local wndAddCombo = G:API_AddComboBox(self, wnd, "Add button", nil, nil, { tMove = {0, 250},
				fnCallback = (function(module, value, key)
					table.insert(v.tSpecialButtons, value)
					self:ForgeAPI_LoadSettings()
					self:RefreshConfig()
				end)
			})
			for i = 1, #tSpecialButtons do
				G:API_AddOptionToComboBox(self, wndAddCombo, tSpecialButtons[i].strName, i)
			end

			local wndRemoveCombo = G:API_AddComboBox(self, wnd, "Remove button", nil, nil, { tMove = {200, 250},
				fnCallback = (function(module, value, key)
					for i = 0, #v.tSpecialButtons do
						if v.tSpecialButtons[i] == value then
							table.remove(v.tSpecialButtons, i)
						end
					end
					self:ForgeAPI_LoadSettings()
					self:RefreshConfig()
				end)
			})
			for _, val in pairs(v.tSpecialButtons) do
				G:API_AddOptionToComboBox(self, wndRemoveCombo, tSpecialButtons[val].strName, val)
			end
		end
	end
end

tSpecialButtons = {
	[1] = {
		strKey = "ForgeUI_StanceButton",
		strName = "Stance",
		strContent = "GCBar",
		nContentId = 2,
		fnFill = ForgeUI_ActionBars.FillStances,
	},
	[2] = {
		strKey = "ForgeUI_MountButton",
		strName = "Mount",
		strContent = "GCBar",
		nContentId = 26,
		fnFill = ForgeUI_ActionBars.FillMounts,
	},
	[3] = {
		strKey = "ForgeUI_RecallButton",
		strName = "Recall",
		strContent = "GCBar",
		nContentId = 18,
		fnFill = ForgeUI_ActionBars.FillRecalls,
	},
	[4] = {
		strKey = "ForgeUI_GadgetButton",
		strName = "Gadget",
		strContent = "GCBar",
		nContentId = 0,
	},
	[5] = {
		strKey = "ForgeUI_PotionButton",
		strName = "Potion",
		strContent = "GCBar",
		nContentId = 27,
		fnFill = ForgeUI_ActionBars.FillPotions,
	},
	[6] = {
		strKey = "ForgeUI_PathButton",
		strName = "Path",
		strContent = "LASBar",
		nContentId = 9,
		fnFill = ForgeUI_ActionBars.FillPath,
	},
	[7] = {
		strKey = "ForgeUI_PetButton",
		strName = "Pet",
		strContent = "GCBar",
		nContentId = nil,
		fnFill = ForgeUI_ActionBars.FillPets,
	},
}

-----------------------------------------------------------------------------------------------
-- ForgeUI addon public API
-----------------------------------------------------------------------------------------------
function ForgeUI_ActionBars:API_GetTBars()
	return tBars
end

function ForgeUI_ActionBars:API_GetTBar(strKey)
	return tBars[strKey]
end

-----------------------------------------------------------------------------------------------
-- ForgeUI addon registration
-----------------------------------------------------------------------------------------------
F:API_NewAddon(ForgeUI_ActionBars)
