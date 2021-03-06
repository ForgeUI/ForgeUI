----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI addon
--
-- name: 		ForgeUI_Interfaces.lua
-- author:		Winty Badass@Jabbit
-- about:		Interface menu list addon for ForgeUI
-----------------------------------------------------------------------------------------------

require "Window"
require "GameLib"
require "Apollo"

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI

-----------------------------------------------------------------------------------------------
-- ForgeUI Addon Definition
-----------------------------------------------------------------------------------------------
local ForgeUI_Interfaces = {
	_NAME = "ForgeUI_Interfaces",
	_API_VERSION = 3,
	_VERSION = "2.0",
	DISPLAY_NAME = "Interfaces",

	tSettings = {
		global = {
			bShowMain = true,
			bShowStore = true,
			bShowFortunes = true,

			tPinnedAddons = {
				Apollo.GetString("InterfaceMenu_AccountInventory"),
				Apollo.GetString("CRB_Achievements"),
				Apollo.GetString("MarketplaceCredd_Title"),
				Apollo.GetString("CRB_Contracts"),
				Apollo.GetString("InterfaceMenu_GroupFinder"),
				Apollo.GetString("InterfaceMenu_Social"),
				Apollo.GetString("InterfaceMenu_Inventory"),
				Apollo.GetString("InterfaceMenu_Mail"),
			}
		}
	}
}

function ForgeUI_Interfaces:ForgeAPI_Init()
	self.xmlDoc = XmlDoc.CreateFromFile("..//ForgeUI_Interfaces//ForgeUI_Interfaces.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self)

	local wndParent = F:API_AddMenuItem(self, self.DISPLAY_NAME, "General")
end

function ForgeUI_Interfaces:OnDocumentReady()
	if self.xmlDoc == nil then
		return
	end

	Apollo.RegisterEventHandler("InterfaceMenuList_NewAddOn",       "OnNewAddonListed", self)
	Apollo.RegisterEventHandler("InterfaceMenuList_AlertAddOn",     "OnDrawAlert", self)
	Apollo.RegisterEventHandler("CharacterCreated",                 "OnCharacterCreated", self)
	Apollo.RegisterEventHandler("Tutorial_RequestUIAnchor",         "OnTutorial_RequestUIAnchor", self)
	Apollo.RegisterTimerHandler("TimeUpdateTimer",                  "OnUpdateTimer", self)
	Apollo.RegisterTimerHandler("QueueRedrawTimer",                 "OnQueuedRedraw", self)
	Apollo.RegisterEventHandler("ApplicationWindowSizeChanged",     "ButtonListRedraw", self)
	Apollo.RegisterEventHandler("OptionsUpdated_HUDPreferences",    "OnUpdateTimer", self)

	Apollo.RegisterEventHandler("InterfaceMenu_ToggleShop",         "OnToggleShop", self)
	Apollo.RegisterEventHandler("InterfaceMenu_ToggleFortunes",     "OnToggleFortunes", self)

	Apollo.RegisterEventHandler("InterfaceMenu_ToggleShop",         "OnToggleShop", self)
	Apollo.RegisterEventHandler("InterfaceMenu_ToggleFortunes",     "OnToggleFortunes", self)

	self.wndMain = Apollo.LoadForm(self.xmlDoc , "ForgeUI_InterfacesForm", F:API_GetStratum("HudHigh"), self)
	F:API_RegisterMover(self, self.wndMain, "MenuList", "MenuList", "misc", {})
	self.wndList = Apollo.LoadForm(self.xmlDoc , "FullListFrame", nil, self)

	self.wndMain:FindChild("OpenFullListBtn"):AttachWindow(self.wndList)
	self.wndMain:FindChild("OpenFullListBtn"):Enable(false)

	self:ForgeAPI_LoadSettings()

	Apollo.CreateTimer("QueueRedrawTimer", 0.3, false)

	self.tMenuData = {
		[Apollo.GetString("InterfaceMenu_SystemMenu")] = { "", "Escape", "Icon_Windows32_UI_CRB_InterfaceMenu_EscMenu" },
	}

	self.tMenuTooltips = {}
	self.tMenuAlerts = {}

	self:ButtonListRedraw()

	if GameLib.GetPlayerUnit() then
		self:OnCharacterCreated()
	end
end

function ForgeUI_Interfaces:OnListShow()
	self.wndList:ToFront()
end

function ForgeUI_Interfaces:OnCharacterCreated()
	Apollo.CreateTimer("TimeUpdateTimer", 1.0, true)
end

function ForgeUI_Interfaces:OnUpdateTimer()
	if not self.bHasLoaded then
		Event_FireGenericEvent("InterfaceMenuListHasLoaded")
		self.wndMain:FindChild("OpenFullListBtn"):Enable(true)

		Event_FireGenericEvent("InterfaceMenuList_NewAddOn", Apollo.GetString("InterfaceMenu_Store"), {"InterfaceMenu_ToggleShop", "Store", ""})
		Event_FireGenericEvent("InterfaceMenuList_NewAddOn", Apollo.GetString("InterfaceMenuList_Fortunes"), {"InterfaceMenu_ToggleFortunes", "", ""})

		-- This is workaround for Carbine's bug that was introduced in 1.5.1 Game Update - 04 May 2016. Can be removed if they fix this one day.
		-- https://forums.wildstar-online.com/forums/index.php?/topic/151344-151-game-update-notes-04-may-2016/

		-- LAS button
		Event_FireGenericEvent("InterfaceMenuList_NewAddOn", Apollo.GetString("InterfaceMenu_AbilityBuilder"), {"ToggleAbilitiesWindow", "LimitedActionSetBuilder", "Icon_Windows32_UI_CRB_InterfaceMenu_Abilities"})
		-- Lore button
		Event_FireGenericEvent("InterfaceMenuList_NewAddOn", Apollo.GetString("InterfaceMenu_Lore"), {"InterfaceMenu_ToggleLoreWindow", "Lore", "Icon_Windows32_UI_CRB_InterfaceMenu_Lore"})

		self.bHasLoaded = true
	end
end

function ForgeUI_Interfaces:OnNewAddonListed(strKey, tParams)
	strKey = string.gsub(strKey, ":", "|") -- ":'s don't work for window names, sorry!"

	self.tMenuData[strKey] = tParams

	self:FullListRedraw()
	self:ButtonListRedraw()
end

function ForgeUI_Interfaces:IsPinned(strText)
	for idx, strWindowText in pairs(self._DB.global.tPinnedAddons) do
		if (strText == strWindowText) then
			return true
		end
	end

	return false
end

function ForgeUI_Interfaces:FullListRedraw()
	local strUnbound = Apollo.GetString("Keybinding_Unbound")
	local wndParent = self.wndList:FindChild("FullListScroll")

	local strQuery = Apollo.StringToLower(tostring(self.wndList:FindChild("SearchEditBox"):GetText()) or "")
	if strQuery == nil or strQuery == "" or not strQuery:match("[%w%s]+") then
		strQuery = ""
	end

	for strWindowText, tData in pairs(self.tMenuData) do
		local bSearchResultMatch = string.find(Apollo.StringToLower(strWindowText), strQuery) ~= nil

		if strQuery == "" or bSearchResultMatch then
			local wndMenuItem = self:LoadByName("MenuListItem", wndParent, strWindowText)
			local wndMenuButton = self:LoadByName("InterfaceMenuButton", wndMenuItem:FindChild("Icon"), strWindowText)
			local strTooltip = strWindowText

			if string.len(tData[2]) > 0 then
				local strKeyBindLetter = GameLib.GetKeyBinding(tData[2])
				strKeyBindLetter = strKeyBindLetter == strUnbound and "" or string.format(" (%s)", strKeyBindLetter)  -- LOCALIZE

				strTooltip = strKeyBindLetter ~= "" and strTooltip .. strKeyBindLetter or strTooltip
			end

			if tData[3] ~= "" then
				wndMenuButton:FindChild("Icon"):SetSprite(tData[3])
			else
				wndMenuButton:FindChild("Icon"):SetText(string.sub(strTooltip, 1, 1))
			end

			wndMenuButton:FindChild("ShortcutBtn"):SetData(strWindowText)
			wndMenuButton:FindChild("Icon"):SetTooltip(strTooltip)
			self.tMenuTooltips[strWindowText] = strTooltip

			wndMenuItem:FindChild("MenuListItemBtn"):SetText(strWindowText)
			wndMenuItem:FindChild("MenuListItemBtn"):SetData(tData[1])

			wndMenuItem:FindChild("PinBtn"):SetCheck(self:IsPinned(strWindowText))
			wndMenuItem:FindChild("PinBtn"):SetData(strWindowText)

			if string.len(tData[2]) > 0 then
				local strKeyBindLetter = GameLib.GetKeyBinding(tData[2])
				wndMenuItem:FindChild("MenuListItemBtn"):FindChild("MenuListItemKeybind"):SetText(strKeyBindLetter == strUnbound and "" or string.format("(%s)", strKeyBindLetter))  -- LOCALIZE
			end
		elseif not bSearchResultMatch and wndParent:FindChild(strWindowText) then
			wndParent:FindChild(strWindowText):Destroy()
		end
	end

	wndParent:ArrangeChildrenVert(0, function (a,b) return a:GetName() < b:GetName() end)
end

function ForgeUI_Interfaces:ButtonListRedraw()
	Apollo.StopTimer("QueueRedrawTimer")
	Apollo.StartTimer("QueueRedrawTimer")
end

function ForgeUI_Interfaces:OnQueuedRedraw()
	local strUnbound = Apollo.GetString("Keybinding_Unbound")
	local wndParent = self.wndMain:FindChild("ButtonList")
	wndParent:DestroyChildren()
	local nParentWidth = wndParent:GetWidth()

	local nLastButtonWidth = 0
	local nTotalWidth = 0

	for idx, strWindowText in pairs(self._DB.global.tPinnedAddons) do
		local tData = self.tMenuData[strWindowText]

		--Magic number below is allowing the 1 pixel gutter on the right
		if tData and nTotalWidth + nLastButtonWidth <= nParentWidth + 1 then
			local wndMenuItem = self:LoadByName("InterfaceMenuButton", wndParent, strWindowText)
			local strTooltip = strWindowText
			nLastButtonWidth = wndMenuItem:GetWidth()
			nTotalWidth = nTotalWidth + nLastButtonWidth

			if string.len(tData[2]) > 0 then
				local strKeyBindLetter = GameLib.GetKeyBinding(tData[2])
				strKeyBindLetter = strKeyBindLetter == strUnbound and "" or string.format(" (%s)", strKeyBindLetter)  -- LOCALIZE
				strTooltip = strKeyBindLetter ~= "" and strTooltip .. strKeyBindLetter or strTooltip
			end

			if tData[3] ~= "" then
				wndMenuItem:FindChild("Icon"):SetSprite(tData[3])
			else
				wndMenuItem:FindChild("Icon"):SetText(string.sub(strTooltip, 1, 1))
			end

			wndMenuItem:FindChild("ShortcutBtn"):SetData(strWindowText)
			wndMenuItem:FindChild("Icon"):SetTooltip(strTooltip)
		end

		if self.tMenuAlerts[strWindowText] then
			self:OnDrawAlert(strWindowText, self.tMenuAlerts[strWindowText])
		end
	end

	wndParent:ArrangeChildrenHorz(0)
end

-----------------------------------------------------------------------------------------------
-- Search
-----------------------------------------------------------------------------------------------

function ForgeUI_Interfaces:OnSearchEditBoxChanged(wndHandler, wndControl)
	self.wndList:FindChild("SearchClearBtn"):Show(string.len(wndHandler:GetText() or "") > 0)
	self:FullListRedraw()
end

function ForgeUI_Interfaces:OnSearchClearBtn(wndHandler, wndControl)
	self.wndList:FindChild("SearchFlash"):SetSprite("CRB_WindowAnimationSprites:sprWinAnim_BirthSmallTemp")
	self.wndList:FindChild("SearchFlash"):SetFocus()
	self.wndList:FindChild("SearchClearBtn"):Show(false)
	self.wndList:FindChild("SearchEditBox"):SetText("")
	self:FullListRedraw()
end

function ForgeUI_Interfaces:OnSearchCommitBtn(wndHandler, wndControl)
	self.wndList:FindChild("SearchFlash"):SetSprite("CRB_WindowAnimationSprites:sprWinAnim_BirthSmallTemp")
	self.wndList:FindChild("SearchFlash"):SetFocus()
	self:FullListRedraw()
end

-----------------------------------------------------------------------------------------------
-- Alerts
-----------------------------------------------------------------------------------------------

function ForgeUI_Interfaces:OnDrawAlert(strWindowName, tParams)
	self.tMenuAlerts[strWindowName] = tParams
	for idx, wndTarget in pairs(self.wndMain:FindChild("ButtonList"):GetChildren()) do
		if wndTarget and tParams then
			local wndButton = wndTarget:FindChild("ShortcutBtn")
			if wndButton then
				local wndIcon = wndButton:FindChild("Icon")

				if wndButton:GetData() == strWindowName then
					if tParams[1] then
						local wndIndicator = self:LoadByName("AlertIndicator", wndButton:FindChild("Alert"), "AlertIndicator")

					elseif wndButton:FindChild("AlertIndicator") ~= nil then
						wndButton:FindChild("AlertIndicator"):Destroy()
					end

					if tParams[2] then
						wndIcon:SetTooltip(string.format("%s\n\n%s", self.tMenuTooltips[strWindowName], tParams[2]))
					end

					if tParams[3] and tParams[3] > 0 then
						local strColor = tParams[1] and "UI_WindowTextOrange" or "UI_TextHoloTitle"

						wndButton:FindChild("Number"):Show(true)
						wndButton:FindChild("Number"):SetText(tParams[3])
						wndButton:FindChild("Number"):SetTextColor(ApolloColor.new(strColor))
					else
						wndButton:FindChild("Number"):Show(false)
						wndButton:FindChild("Number"):SetText("")
						wndButton:FindChild("Number"):SetTextColor(ApolloColor.new("UI_TextHoloTitle"))
					end
				end
			end
		end
	end

	local wndParent = self.wndList:FindChild("FullListScroll")
	for idx, wndTarget in pairs(wndParent:GetChildren()) do
		local wndButton = wndTarget:FindChild("ShortcutBtn")
		local wndIcon = wndButton:FindChild("Icon")

		if wndButton:GetData() == strWindowName then
			if tParams[1] then
				local wndIndicator = self:LoadByName("AlertIndicator", wndButton:FindChild("Alert"), "AlertIndicator")
			elseif wndButton:FindChild("AlertIndicator") ~= nil then
				wndButton:FindChild("AlertIndicator"):Destroy()
			end

			if tParams[2] then
				wndIcon:SetTooltip(string.format("%s\n\n%s", self.tMenuTooltips[strWindowName], tParams[2]))
			end

			if tParams[3] and tParams[3] > 0 then
				local strColor = tParams[1] and "UI_WindowTextOrange" or "UI_TextHoloTitle"

				wndButton:FindChild("Number"):Show(true)
				wndButton:FindChild("Number"):SetText(tParams[3])
				wndButton:FindChild("Number"):SetTextColor(ApolloColor.new(strColor))
			else
				wndButton:FindChild("Number"):Show(false)
			end
		end
	end
end

-----------------------------------------------------------------------------------------------
-- Helpers and Errata
-----------------------------------------------------------------------------------------------

function ForgeUI_Interfaces:OnMenuListItemClick(wndHandler, wndControl)
	if wndHandler ~= wndControl then return end

	if string.len(wndControl:GetData()) > 0 then
		Event_FireGenericEvent(wndControl:GetData())
	else
		InvokeOptionsScreen()
	end
	self.wndList:Show(false)
end

function ForgeUI_Interfaces:OnPinBtnChecked(wndHandler, wndControl)
	if wndHandler ~= wndControl then return end

	local wndParent = wndControl:GetParent():GetParent()

	self._DB.global.tPinnedAddons = {}

	for idx, wndMenuItem in pairs(wndParent:GetChildren()) do
		if wndMenuItem:FindChild("PinBtn"):IsChecked() then

			table.insert(self._DB.global.tPinnedAddons, wndMenuItem:FindChild("PinBtn"):GetData())
		end
	end

	self:ButtonListRedraw()
end

function ForgeUI_Interfaces:OnListBtnClick(wndHandler, wndControl) -- These are the five always on icons on the top
	if wndHandler ~= wndControl then return end
	local strMappingResult = wndHandler:GetData() and self.tMenuData[wndHandler:GetData()][1] or ""

	if string.len(strMappingResult) > 0 then
		Event_FireGenericEvent(strMappingResult)
	else
		InvokeOptionsScreen()
	end
end

function ForgeUI_Interfaces:OnOpenFullListCheck(wndHandler, wndControl)
	self.wndList:FindChild("SearchEditBox"):SetFocus()
	self:FullListRedraw()
end

function ForgeUI_Interfaces:LoadByName(strForm, wndParent, strCustomName)
	local wndNew = wndParent:FindChild(strCustomName)
	if not wndNew then
		wndNew = Apollo.LoadForm(self.xmlDoc , strForm, wndParent, self)
		wndNew:SetName(strCustomName)
	end
	return wndNew
end

function ForgeUI_Interfaces:OnTutorial_RequestUIAnchor(eAnchor, idTutorial, strPopupText)
	local arTutorialAnchorMapping =
	{
		--[GameLib.CodeEnumTutorialAnchor.Abilities] 			= "LASBtn",
		--[GameLib.CodeEnumTutorialAnchor.Character] 		= "CharacterBtn",
		--[GameLib.CodeEnumTutorialAnchor.Mail] 				= "MailBtn",
		--[GameLib.CodeEnumTutorialAnchor.GalacticArchive] = "LoreBtn",
		--[GameLib.CodeEnumTutorialAnchor.Social] 			= "SocialBtn",
		--[GameLib.CodeEnumTutorialAnchor.GroupFinder] 		= "GroupFinderBtn",
	}

	local strWindowName = "ButtonList" or false
	if not strWindowName then
		return
	end

	local tRect = {}
	tRect.l, tRect.t, tRect.r, tRect.b = self.wndMain:FindChild(strWindowName):GetRect()
	tRect.r = tRect.r - 26

	if arTutorialAnchorMapping[eAnchor] then
		Event_FireGenericEvent("Tutorial_RequestUIAnchorResponse", eAnchor, idTutorial, strPopupText, tRect)
	end
end

function ForgeUI_Interfaces:OnToggleShop()
	GameLib.OpenStore()
end

function ForgeUI_Interfaces:OnToggleFortunes()
	GameLib.OpenFortunes()
end

function ForgeUI_Interfaces:OnMouseButtonDown( wndHandler, wndControl, eMouseButton )
	if wndControl:GetName() == "StoreBtn" then
		GameLib.OpenStore()
	elseif wndControl:GetName() == "FortunesBtn" then
		GameLib.OpenFortunes()
	end
end

-----------------------------------------------------------------------------------------------
-- Loading setting
-----------------------------------------------------------------------------------------------
function ForgeUI_Interfaces:ForgeAPI_LoadSettings()
	if not self.wndMain then return end

	local wndStore = self.wndMain:FindChild("StoreContainer")
	local wndFortunes = self.wndMain:FindChild("FortunesContainer")
	local wndButtonList = self.wndMain:FindChild("ButtonList")
	local tOpenFullListBtnOffsets = { self.wndMain:FindChild("OpenFullListBtn"):GetOriginalLocation():GetOffsets() }
	local tStoreBtnOffsets = { wndStore:GetOriginalLocation():GetOffsets() }

	self.wndMain:Show(self._DB.global.bShowMain) -- show bar

	if not self._DB.global.bShowStore and not self._DB.global.bShowFortunes then -- no Store and Fortunes
		wndStore:Show(false)
		wndFortunes:Show(false)
		wndButtonList:SetAnchorPoints(0, 0, 1, 1)
		wndButtonList:SetAnchorOffsets(tOpenFullListBtnOffsets[3], 0, 0, 0)
	elseif self._DB.global.bShowStore and not self._DB.global.bShowFortunes then -- Store only
		wndStore:Show(true)
		wndFortunes:Show(false)
		wndButtonList:SetAnchorPoints(0, 0, 1, 1)
		wndButtonList:SetAnchorOffsets(tStoreBtnOffsets[3], 0, 0, 0)
	elseif not self._DB.global.bShowStore and self._DB.global.bShowFortunes then -- Fortunes only
		wndStore:Show(false)
		wndFortunes:Show(true)
		wndFortunes:SetAnchorPoints(0, 1, 0, 1)
		wndFortunes:SetAnchorOffsets(tOpenFullListBtnOffsets[3], -25, tOpenFullListBtnOffsets[3] + 25, 0)
		wndButtonList:SetAnchorPoints(0, 0, 1, 1)
		wndButtonList:SetAnchorOffsets(tOpenFullListBtnOffsets[3] + 25, 0, 0, 0)
	elseif self._DB.global.bShowStore and self._DB.global.bShowFortunes then -- Store and Fortunes
		wndStore:Show(true)
		wndFortunes:Show(true)
		wndStore:SetAnchorPoints(wndStore:GetOriginalLocation():GetPoints())
		wndStore:SetAnchorOffsets(wndStore:GetOriginalLocation():GetOffsets())
		wndFortunes:SetAnchorPoints(wndFortunes:GetOriginalLocation():GetPoints())
		wndFortunes:SetAnchorOffsets(wndFortunes:GetOriginalLocation():GetOffsets())
		wndButtonList:SetAnchorPoints(wndButtonList:GetOriginalLocation():GetPoints())
		wndButtonList:SetAnchorOffsets(wndButtonList:GetOriginalLocation():GetOffsets())
	end
end

-----------------------------------------------------------------------------------------------
-- Populating opions
-----------------------------------------------------------------------------------------------
function ForgeUI_Interfaces:ForgeAPI_PopulateOptions()
	-- general settings
	local wndGeneral = self.tOptionHolders["General"]

	G:API_AddCheckBox(self, wndGeneral, "Show interface menu bar", self._DB.global, "bShowMain", { tMove = {0, 0}, fnCallback = self.ForgeAPI_LoadSettings })
	G:API_AddCheckBox(self, wndGeneral, "Show store", self._DB.global, "bShowStore", { tMove = {0, 30}, fnCallback = self.ForgeAPI_LoadSettings })
	G:API_AddCheckBox(self, wndGeneral, "Show fortunes", self._DB.global, "bShowFortunes", { tMove = {0, 60}, fnCallback = self.ForgeAPI_LoadSettings })
end

-----------------------------------------------------------------------------------------------
-- ForgeUI addon registration
-----------------------------------------------------------------------------------------------
F:API_NewAddon(ForgeUI_Interfaces)
