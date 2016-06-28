----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI addon
--
-- name: 		ForgeUI_NeedGreed.lua
-- author:		Winty Badass@Jabbit
-- about:		NeedGreed addon for ForgeUI
-----------------------------------------------------------------------------------------------

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI

-----------------------------------------------------------------------------------------------
-- ForgeUI Addon Definition
-----------------------------------------------------------------------------------------------
local ForgeUI_NeedGreed = {
	_NAME = "ForgeUI_NeedGreed",
	_API_VERSION = 3,
	_VERSION = "2.0",
	DISPLAY_NAME = "NeedGreed",

	tSettings = {
	}
}

-----------------------------------------------------------------------------------------------
-- Local variables
-----------------------------------------------------------------------------------------------
local ktEvalColors = {
	[Item.CodeEnumItemQuality.Inferior] 		= ApolloColor.new("ItemQuality_Inferior"),
	[Item.CodeEnumItemQuality.Average] 			= ApolloColor.new("ItemQuality_Average"),
	[Item.CodeEnumItemQuality.Good] 			= ApolloColor.new("ItemQuality_Good"),
	[Item.CodeEnumItemQuality.Excellent] 		= ApolloColor.new("ItemQuality_Excellent"),
	[Item.CodeEnumItemQuality.Superb] 			= ApolloColor.new("ItemQuality_Superb"),
	[Item.CodeEnumItemQuality.Legendary] 		= ApolloColor.new("ItemQuality_Legendary"),
	[Item.CodeEnumItemQuality.Artifact]		 	= ApolloColor.new("ItemQuality_Artifact"),
}

-----------------------------------------------------------------------------------------------
-- ForgeAPI
-----------------------------------------------------------------------------------------------
function ForgeUI_NeedGreed:ForgeAPI_Init()
	self.xmlDoc = XmlDoc.CreateFromFile("..//ForgeUI_NeedGreed//ForgeUI_NeedGreed.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)

	Apollo.RegisterEventHandler("LootRollUpdate",		"OnGroupLoot", self)
    Apollo.RegisterTimerHandler("WinnerCheckTimer", 	"OnOneSecTimer", self)
    Apollo.RegisterEventHandler("LootRollWon", 			"OnLootRollWonEvent", self)
    Apollo.RegisterEventHandler("LootRollAllPassed", 	"OnLootRollAllPassedEvent", self)
	Apollo.RegisterTimerHandler("PlayerNameCheckTimer",	"OnNameCheckTimer", self)

	Apollo.RegisterEventHandler("LootRollSelected", 	"OnLootRollSelectedEvent", self)
	Apollo.RegisterEventHandler("LootRollPassed", 		"OnLootRollPassedEvent", self)
	Apollo.RegisterEventHandler("LootRoll", 			"OnLootRollEvent", self)

	--Apollo.RegisterEventHandler("GroupBagItemAdded", 	"OnGroupBagItemAdded", self) -- Appears deprecated

	Apollo.CreateTimer("WinnerCheckTimer", 1.0, false)
	Apollo.StopTimer("WinnerCheckTimer")
	Apollo.CreateTimer("PlayerNameCheckTimer", 2.0, false)

	self.bTimerRunning = false
	self.tKnownLoot = {}
	self.tLootRolls = {}
	self.tBlacklist = {}
	self.tPlayerWhoRolled = {}

	self.strMyPlayerName = nil

	if GameLib.GetLootRolls() then
		self:OnGroupLoot()
	end
end

function ForgeUI_NeedGreed:OnDocLoaded()
	self.wndContainer = Apollo.LoadForm(self.xmlDoc, "Container", nil, self)
	F:API_RegisterMover(self, self.wndContainer, "NeedGreed", "NeedGreed container", "general", {})
end

-----------------------------------------------------------------------------------------------
-- Main Draw Method
-----------------------------------------------------------------------------------------------
function ForgeUI_NeedGreed:OnGroupLoot()
	if not self.bTimerRunning then
		Apollo.StartTimer("WinnerCheckTimer")
		self.bTimerRunning = true
	end
end

function ForgeUI_NeedGreed:UpdateKnownLoot()
	self.tLootRolls = GameLib.GetLootRolls()
	if not self.tLootRolls or #self.tLootRolls <= 0 then
		self.tKnownLoot = {}
		self.tLootRolls = {}
		self.tBlacklist = {}
		self.tPlayerWhoRolled = {}
		return
	end

	self.tKnownLoot = {}
	for idx, tCurrentElement in ipairs(self.tLootRolls) do
		self.tKnownLoot[tCurrentElement.nLootId] = tCurrentElement
	end
end

function ForgeUI_NeedGreed:OnOneSecTimer()
	self:UpdateKnownLoot()

	if self.tLootRolls then
		--self:DrawAllLoot(self.tLootRolls, #self.tLootRolls)
		self:DrawAllLoot(self.tKnownLoot, #self.tLootRolls)
	else
		self.wndContainer:DestroyChildren()
	end

	if self.tLootRolls and #self.tLootRolls > 0 then
		Apollo.StartTimer("WinnerCheckTimer")
	else
		self.bTimerRunning = false
	end
end

function ForgeUI_NeedGreed:OnNameCheckTimer()
	if GameLib.GetPlayerUnit() then
		self.strMyPlayerName = GameLib.GetPlayerUnit():GetName()
	else
		Apollo.StartTimer("PlayerNameCheckTimer")
	end
end

function ForgeUI_NeedGreed:DrawAllLoot(tLoot, nLoot)
	if nLoot == 0 then
		self.wndContainer:DestroyChildren()
		return
	end

	for _, wnd in pairs(self.wndContainer:GetChildren()) do
		local bShouldBeDestroyed = true
		for _, loot in pairs(tLoot) do
			if wnd:GetData().nLootId == loot.nLootId then
				bShouldBeDestroyed = false
			end
		end

		if bShouldBeDestroyed then
			wnd:Destroy()
		end
	end

	--self.wndContainer:DestroyChildren()
	for k, tCurrentElement in pairs(tLoot) do
		local bShouldBeAdded = true
		local bBlacklistApplies = false

		local wndLoot

		for _, wnd in pairs(self.wndContainer:GetChildren()) do
			if wnd:GetData().nLootId == tCurrentElement.nLootId then
				bShouldBeAdded = false
				wndLoot = wnd
			end
		end

		if bShouldBeAdded then
			for idx, tBlacklistElement in ipairs(self.tBlacklist) do
				if self.tBlacklist[idx].itemDrop == tCurrentElement.itemDrop and self.tBlacklist[idx].nLootId == tCurrentElement.nLootId then
					bBlacklistApplies = true
				end
			end
		end

		if bShouldBeAdded and not bBlacklistApplies then
			wndLoot = Apollo.LoadForm(self.xmlDoc, "ForgeUI_NeedGreedForm", self.wndContainer, self)
			wndLoot:SetData(tCurrentElement)

			local itemCurrent = tCurrentElement.itemDrop
			local itemModData = tCurrentElement.tModData
			local tGlyphData = tCurrentElement.tSigilData
			wndLoot:FindChild("LootTitle"):SetText(itemCurrent:GetName())
			wndLoot:FindChild("LootTitle"):SetTextColor(ktEvalColors[itemCurrent:GetItemQuality()])
			wndLoot:FindChild("GiantItemIcon"):SetData(itemCurrent)
			wndLoot:FindChild("GiantItemIcon"):SetSprite(itemCurrent:GetIcon())
			self:HelperBuildItemTooltip(wndLoot:FindChild("GiantItemIcon"), itemCurrent, itemModData, tGlyphData)

			if GameLib.IsNeedRollAllowed(tCurrentElement.nLootId) == true then
				wndLoot:FindChild("NeedBtn"):Show(true)
				wndLoot:FindChild("NeedNotOption"):Show(false)
				wndLoot:FindChild("NeedRolls"):Show(true)
				wndLoot:FindChild("NeedRolls"):ToFront()
			else
				wndLoot:FindChild("NeedNotOption"):Show(true)
				wndLoot:FindChild("NeedBtn"):Show(false)
				wndLoot:FindChild("NeedRolls"):Show(true)
				wndLoot:FindChild("NeedRolls"):ToFront()
			end

			table.insert(self.tBlacklist, 1, tCurrentElement)
			self.tBlacklist[1].tPlayerRolls = {}
		end

		if not bBlacklistApplies then
			local nTimeLeft = math.floor(tCurrentElement.nTimeLeft / 1000)
			wndLoot:FindChild("TimeLeftText"):Show(true)

			local nTimeLeftSecs = nTimeLeft % 60
			local nTimeLeftMins = math.floor(nTimeLeft / 60)

			local strTimeLeft = tostring(nTimeLeftMins)
			if nTimeLeft < 0 then
				strTimeLeft = "0:00"
			elseif nTimeLeftSecs < 10 then
				strTimeLeft = strTimeLeft .. ":0" .. tostring(nTimeLeftSecs)
			else
				strTimeLeft = strTimeLeft .. ":" .. tostring(nTimeLeftSecs)
			end
			wndLoot:FindChild("TimeLeftText"):SetText(strTimeLeft)
		end
	end

	self:ArrangeLoot()
end

function ForgeUI_NeedGreed:ArrangeLoot()
	local i = 1

	for k, v in pairs(self.wndContainer:GetChildren()) do
		v:SetAnchorOffsets(0, -45 * i, 0, -45 * (i - 1))
		i = i + 1
	end
end

-- With a given item and roller from the Roll event, find that item's window such that the roller hasn't yet been recorded, and then update the roll counter
function ForgeUI_NeedGreed:UpdateLootRollCounters(tCurrentElement, strPlayerRoller, strRollType)
	local bFoundRightItem = false
	for _, wnd in pairs(self.wndContainer:GetChildren()) do
		if wnd:GetData().itemDrop == tCurrentElement.itemDrop and wnd:GetData().nLootId == tCurrentElement.nLootId then
			for idx, tBlacklistElement in ipairs(self.tBlacklist) do
				if tBlacklistElement.nLootId == tCurrentElement.nLootId then
					for _, tPlayerAlreadyRolled in ipairs(tBlacklistElement.tPlayerRolls) do
						if tPlayerAlreadyRolled[1] == strPlayerRoller then -- If we find the roller already in the tPlayerRolls table, don't increment the counter
							return false
						end
					end
					table.insert(tBlacklistElement.tPlayerRolls, {strPlayerRoller, strRollType}) -- Otherwise, insert them
					bFoundRightItem = true
					break
				end
			end
			local strRollString = strRollType .. "Rolls"
			local strCurrentRolls = wnd:FindChild(strRollString):GetText()
			local nNewRolls = tonumber(strCurrentRolls) + 1
			local wndRollCounter = wnd:FindChild(strRollString)
			wndRollCounter:SetText(tostring(nNewRolls))
			self:OnMouseEnterRollCounter(wndRollCounter, wndRollCounter, 0, 0) -- Generate a new tooltip, in case the player is mousing over that roll right now
		end
	end
	return bFoundRightItem
end

-----------------------------------------------------------------------------------------------
-- Chat Message Events and Roll Counters
-----------------------------------------------------------------------------------------------
function ForgeUI_NeedGreed:OnLootRollAllPassedEvent(lootInfo)
	self:OnLootRollAllPassed(lootInfo.itemLoot)
end

function ForgeUI_NeedGreed:OnLootRollAllPassed(itemLooted)
	local strResult = String_GetWeaselString(Apollo.GetString("NeedVsGreed_EveryonePassed"), itemLooted:GetChatLinkString())
	Event_FireGenericEvent("GenericEvent_LootChannelMessage", strResult)
end

function ForgeUI_NeedGreed:OnLootRollWonEvent(lootInfo)
	self:OnLootRollWon(lootInfo.itemLoot, lootInfo.strPlayer, lootInfo.bNeed)
end

function ForgeUI_NeedGreed:OnLootRollWon(itemLoot, strWinner, bNeed)
	local strNeedOrGreed = nil
	if bNeed then
		strNeedOrGreed = Apollo.GetString("NeedVsGreed_NeedRoll")
	else
		strNeedOrGreed = Apollo.GetString("NeedVsGreed_GreedRoll")
	end

	local strResult = String_GetWeaselString(Apollo.GetString("NeedVsGreed_ItemWon"), strWinner, itemLoot:GetChatLinkString(), strNeedOrGreed)
	Event_FireGenericEvent("GenericEvent_LootChannelMessage", strResult)

	for idx, tBlacklistElement in ipairs(self.tBlacklist) do
		if tBlacklistElement.itemDrop == itemLoot then
			table.remove(self.tBlacklist, idx)
			break
		end
	end
end

function ForgeUI_NeedGreed:OnLootRollSelectedEvent(lootInfo)
	self:OnLootRollSelected(lootInfo.itemLoot, lootInfo.strPlayer, lootInfo.bNeed)
end

function ForgeUI_NeedGreed:OnLootRollSelected(itemLoot, strPlayer, bNeed)
	local strNeedOrGreed = nil
	local bPlayerIsRoller = false

	if strPlayer == self.strMyPlayerName then
		bPlayerIsRoller = true
	end

	if bNeed then
		strNeedOrGreed = Apollo.GetString("NeedVsGreed_NeedRoll")
		if not bPlayerIsRoller then
			for idx, tCurrentElement in pairs(self.tKnownLoot) do
				if tCurrentElement.itemDrop == itemLoot then
					bIncrementedCounter = self:UpdateLootRollCounters(tCurrentElement, strPlayer, "Need")
					if bIncrementedCounter then break end
				end
			end
		end
	else
		strNeedOrGreed = Apollo.GetString("NeedVsGreed_GreedRoll")
		if not bPlayerIsRoller then
			for idx, tCurrentElement in pairs(self.tKnownLoot) do
				if tCurrentElement.itemDrop == itemLoot then
					bIncrementedCounter = self:UpdateLootRollCounters(tCurrentElement, strPlayer, "Greed")
					if bIncrementedCounter then break end
				end
			end
		end
	end

	local strResult = String_GetWeaselString(Apollo.GetString("NeedVsGreed_LootRollSelected"), strPlayer, strNeedOrGreed, itemLoot:GetChatLinkString())
	Event_FireGenericEvent("GenericEvent_LootChannelMessage", strResult)
end

function ForgeUI_NeedGreed:OnLootRollPassedEvent(lootInfo)
	self:OnLootRollPassed(lootInfo.itemLoot, lootInfo.strPlayer)
end

function ForgeUI_NeedGreed:OnLootRollPassed(itemLoot, strPlayer)
	local strResult = String_GetWeaselString(Apollo.GetString("NeedVsGreed_PlayerPassed"), strPlayer, itemLoot:GetChatLinkString())
	Event_FireGenericEvent("GenericEvent_LootChannelMessage", strResult)

	if strPlayer == self.strMyPlayerName then return end

	for idx, tCurrentElement in pairs(self.tKnownLoot) do
		if tCurrentElement.itemDrop == itemLoot then
			bIncrementedCounter = self:UpdateLootRollCounters(tCurrentElement, strPlayer, "Pass")
			if bIncrementedCounter then break end
		end
	end
end

function ForgeUI_NeedGreed:OnLootRollEvent(lootInfo)
	self:OnLootRoll(lootInfo.itemLoot, lootInfo.strPlayer, lootInfo.nRoll, lootInfo.bNeed)
end

function ForgeUI_NeedGreed:OnLootRoll(itemLoot, strPlayer, nRoll, bNeed)
	local strNeedOrGreed = nil
	if bNeed then
		strNeedOrGreed = Apollo.GetString("NeedVsGreed_NeedRoll")
	else
		strNeedOrGreed = Apollo.GetString("NeedVsGreed_GreedRoll")
	end

	local strResult = String_GetWeaselString(Apollo.GetString("NeedVsGreed_OnLootRoll"), strPlayer, nRoll, itemLoot:GetChatLinkString(), strNeedOrGreed)
	Event_FireGenericEvent("GenericEvent_LootChannelMessage", strResult)
end

-----------------------------------------------------------------------------------------------
-- Buttons
-----------------------------------------------------------------------------------------------

function ForgeUI_NeedGreed:OnGiantItemIconMouseUp(wndHandler, wndControl, eMouseButton)
	if eMouseButton == GameLib.CodeEnumInputMouse.Right and wndHandler:GetData() then
		Event_FireGenericEvent("GenericEvent_ContextMenuItem", wndHandler:GetData())
	end
end

function ForgeUI_NeedGreed:OnNeedBtn(wndHandler, wndControl)
	local wndLoot = wndControl:GetParent():GetParent()

	GameLib.RollOnLoot(wndLoot:GetData().nLootId, true)
	self:UpdateKnownLoot()
	wndLoot:Destroy()

	self:ArrangeLoot()
end

function ForgeUI_NeedGreed:OnGreedBtn(wndHandler, wndControl)
	local wndLoot = wndControl:GetParent():GetParent()

	GameLib.RollOnLoot(wndLoot:GetData().nLootId, false)
	self:UpdateKnownLoot()
	wndLoot:Destroy()

	self:ArrangeLoot()
end

function ForgeUI_NeedGreed:OnPassBtn(wndHandler, wndControl)
	local wndLoot = wndControl:GetParent():GetParent()

	GameLib.PassOnLoot(wndLoot:GetData().nLootId, true)
	self:UpdateKnownLoot()
	wndLoot:Destroy()

	self:ArrangeLoot()
end

function ForgeUI_NeedGreed:HelperBuildItemTooltip(wndArg, itemCurr, itemModData, tGlyphData)
	wndArg:SetTooltipDoc(nil)
	wndArg:SetTooltipDocSecondary(nil)
	local itemEquipped = itemCurr:GetEquippedItemForItemType()
	Tooltip.GetItemTooltipForm(self, wndArg, itemCurr, {bPrimary = true, bSelling = false, itemCompare = itemEquipped, itemModData = itemModData, tGlyphData = tGlyphData})
end

function ForgeUI_NeedGreed:OnMouseEnterRollCounter(wndHandler, wndControl, x, y)
	local xml = XmlDoc.new()
	xml:StartTooltip(1000)

	if wndControl:GetText() == "0" then
		xml:AddLine("None")
		wndControl:SetTooltipDoc(xml)
		return
	end

	wndMain = wndHandler:GetParent():GetParent()

	if wndControl:GetName() == "NeedRolls" then
		self:WhoRolledHelper(xml, wndMain, "Need")
	elseif wndControl:GetName() == "GreedRolls" then
		self:WhoRolledHelper(xml, wndMain:GetParent(), "Greed")
	elseif wndControl:GetName() == "PassRolls" then
		self:WhoRolledHelper(xml, wndMain:GetParent(), "Pass")
	end
	wndControl:SetTooltipDoc(xml)
end

function ForgeUI_NeedGreed:WhoRolledHelper(xml, wndMain, strRollType)
	for idx, tBlacklistElement in ipairs(self.tBlacklist) do
		if wndMain:GetData().nLootId == tBlacklistElement.nLootId then
			for idy, tPlayerAlreadyRolled in ipairs(tBlacklistElement.tPlayerRolls) do
				if tPlayerAlreadyRolled[2] == strRollType then
					xml:AddLine(tPlayerAlreadyRolled[1])
				end
			end
			break
		end
	end
end

F:API_NewAddon(ForgeUI_NeedGreed)
