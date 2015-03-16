-----------------------------------------------------------------------------------------------
-- Client Lua Script for InventoryBag
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Apollo"
require "GameLib"
require "Item"
require "Window"
require "Money"

local InventoryBag = {}
local knSmallIconOption = 42
local knLargeIconOption = 48
local knMaxBags = 4 -- how many bags can the player have
local knSaveVersion = 3
local knPaddingTop = 20

local karCurrency =  	-- Alt currency table; re-indexing the enums so they don't have to be in sequence code-side (and removing cash)
{						-- To add a new currency just add an entry to the table; the UI will do the rest. Idx == 1 will be the default one shown
	{eType = Money.CodeEnumCurrencyType.Renown, 			strTitle = Apollo.GetString("CRB_Renown"), 				strDescription = Apollo.GetString("CRB_Renown_Desc")},
	{eType = Money.CodeEnumCurrencyType.ElderGems, 			strTitle = Apollo.GetString("CRB_Elder_Gems"), 			strDescription = Apollo.GetString("CRB_Elder_Gems_Desc")},
	{eType = Money.CodeEnumCurrencyType.Glory, 			strTitle = Apollo.GetString("CRB_Glory"), 			strDescription = Apollo.GetString("CRB_Glory_Desc")},
	{eType = Money.CodeEnumCurrencyType.Prestige, 			strTitle = Apollo.GetString("CRB_Prestige"), 			strDescription = Apollo.GetString("CRB_Prestige_Desc")},
	{eType = Money.CodeEnumCurrencyType.CraftingVouchers, 	strTitle = Apollo.GetString("CRB_Crafting_Vouchers"), 	strDescription = Apollo.GetString("CRB_Crafting_Voucher_Desc")}
}

function InventoryBag:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	o.bShouldSortItems = false
	o.nSortItemType = 1

	return o
end

function InventoryBag:Init()
    Apollo.RegisterAddon(self)
end

function InventoryBag:OnSave(eType)
	if eType == GameLib.CodeEnumAddonSaveLevel.Character then
		return {
			nSaveVersion = knSaveVersion,
			bShouldSortItems = self.bShouldSortItems,
			nSortItemType = self.nSortItemType,
			nAltCurrencySelected = self.nAltCurrencySelected
		}
	end

	return nil
end

function InventoryBag:OnRestore(eType, tSavedData)
	if eType == GameLib.CodeEnumAddonSaveLevel.Account then
		self.tSavedData = tSavedData

		if not tSavedData or tSavedData.nSaveVersion ~= knSaveVersion then
			return
		end
	elseif eType == GameLib.CodeEnumAddonSaveLevel.Character  then
		if not tSavedData or tSavedData.nSaveVersion ~= knSaveVersion then
			return
		end

		self.bShouldSortItems = tSavedData.bShouldSortItems or false
		self.nSortItemType = tSavedData.nSortItemType or 1
		self.nAltCurrencySelected = tSavedData.nAltCurrencySelected or 1

		if self.wndMain then
			self:UpdateAltCashDisplay()
			self.wndMainBagWindow:SetSort(self.bShouldSortItems)
			self.wndMainBagWindow:SetItemSortComparer(ktSortFunctions[self.nSortItemType])
			self.wndMain:FindChild("OptionsContainer:OptionsContainerFrame:OptionsConfigureSort:ItemSortPrompt:IconBtnSortOff"):SetCheck(not self.bShouldSortItems)
			self.wndMain:FindChild("OptionsContainer:OptionsContainerFrame:OptionsConfigureSort:ItemSortPrompt:IconBtnSortAlpha"):SetCheck(self.bShouldSortItems and self.nSortItemType == 1)
			self.wndMain:FindChild("OptionsContainer:OptionsContainerFrame:OptionsConfigureSort:ItemSortPrompt:IconBtnSortCategory"):SetCheck(self.bShouldSortItems and self.nSortItemType == 2)
			self.wndMain:FindChild("OptionsContainer:OptionsContainerFrame:OptionsConfigureSort:ItemSortPrompt:IconBtnSortQuality"):SetCheck(self.bShouldSortItems and self.nSortItemType == 3)
		end
	end
end


function InventoryBag:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("ForgeUI_InventoryBag.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self)

	self.nAltCurrencySelected = 1
end

local fnSortItemsByName = function(itemLeft, itemRight)
	if itemLeft == itemRight then
		return 0
	end
	if itemLeft and itemRight == nil then
		return -1
	end
	if itemLeft == nil and itemRight then
		return 1
	end

	local strLeftName = itemLeft:GetName()
	local strRightName = itemRight:GetName()
	if strLeftName < strRightName then
		return -1
	end
	if strLeftName > strRightName then
		return 1
	end

	return 0
end

local fnSortItemsByCategory = function(itemLeft, itemRight)
	if itemLeft == itemRight then
		return 0
	end
	if itemLeft and itemRight == nil then
		return -1
	end
	if itemLeft == nil and itemRight then
		return 1
	end

	local strLeftName = itemLeft:GetItemCategoryName()
	local strRightName = itemRight:GetItemCategoryName()
	if strLeftName < strRightName then
		return -1
	end
	if strLeftName > strRightName then
		return 1
	end

	local strLeftName = itemLeft:GetName()
	local strRightName = itemRight:GetName()
	if strLeftName < strRightName then
		return -1
	end
	if strLeftName > strRightName then
		return 1
	end

	return 0
end

local fnSortItemsByQuality = function(itemLeft, itemRight)
	if itemLeft == itemRight then
		return 0
	end
	if itemLeft and itemRight == nil then
		return -1
	end
	if itemLeft == nil and itemRight then
		return 1
	end

	local eLeftQuality = itemLeft:GetItemQuality()
	local eRightQuality = itemRight:GetItemQuality()
	if eLeftQuality > eRightQuality then
		return -1
	end
	if eLeftQuality < eRightQuality then
		return 1
	end

	local strLeftName = itemLeft:GetName()
	local strRightName = itemRight:GetName()
	if strLeftName < strRightName then
		return -1
	end
	if strLeftName > strRightName then
		return 1
	end

	return 0
end

local ktSortFunctions = {fnSortItemsByName, fnSortItemsByCategory, fnSortItemsByQuality}

-- TODO: Mark items as viewed
function InventoryBag:OnDocumentReady()
	if  self.xmlDoc == nil then
		return
	end
	Apollo.RegisterEventHandler("UpdateInventory", 							"OnUpdateInventory", self)
	Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", 				"OnInterfaceMenuListHasLoaded", self)
	Apollo.RegisterEventHandler("WindowManagementReady", 					"OnWindowManagementReady", self)

	Apollo.RegisterEventHandler("InterfaceMenu_ToggleInventory", 			"OnToggleVisibility", self) -- TODO: The datachron attachment needs to be brought over
	Apollo.RegisterEventHandler("GuildBank_ShowPersonalInventory", 			"OnToggleVisibilityAlways", self)

	Apollo.RegisterEventHandler("PersonaUpdateCharacterStats", 				"UpdateBagSlotItems", self) -- using this for bag changes
	Apollo.RegisterEventHandler("PlayerPathMissionUpdate", 					"OnQuestObjectiveUpdated", self) -- route to same event
	Apollo.RegisterEventHandler("QuestObjectiveUpdated", 					"OnQuestObjectiveUpdated", self)
	Apollo.RegisterEventHandler("PlayerPathRefresh", 						"OnQuestObjectiveUpdated", self) -- route to same event
	Apollo.RegisterEventHandler("QuestStateChanged", 						"OnQuestObjectiveUpdated", self)
	Apollo.RegisterEventHandler("ToggleInventory", 							"OnToggleVisibility", self) -- todo: figure out if show inventory is needed
	Apollo.RegisterEventHandler("ShowInventory", 							"OnToggleVisibility", self)
	Apollo.RegisterEventHandler("ChallengeUpdated", 						"OnChallengeUpdated", self)
	Apollo.RegisterEventHandler("CharacterCreated", 						"OnCharacterCreated", self)
	Apollo.RegisterEventHandler("PlayerEquippedItemChanged",				"OnEquippedItem", self)

	Apollo.RegisterEventHandler("GenericEvent_SplitItemStack", 				"OnGenericEvent_SplitItemStack", self)

	Apollo.RegisterEventHandler("PlayerCurrencyChanged",					"OnPlayerCurrencyChanged", self)

	Apollo.RegisterEventHandler("LevelUpUnlock_Inventory_Salvage", "OnLevelUpUnlock_Inventory_Salvage", self)
	Apollo.RegisterEventHandler("LevelUpUnlock_Path_Item", "OnLevelUpUnlock_Path_Item", self)
	Apollo.RegisterEventHandler("LootStackItemSentToTradeskillBag", "OnLootstackItemSentToTradeskillBag", self)
	Apollo.RegisterEventHandler("SupplySatchelOpen", "OnSupplySatchelOpen", self)
	Apollo.RegisterEventHandler("SupplySatchelClosed", "OnSupplySatchelClosed", self)



	--Apollo.RegisterTimerHandler("InventoryUpdateTimer", 					"OnUpdateTimer", self)
	--Apollo.CreateTimer("InventoryUpdateTimer", 1.0, true)
	--Apollo.StopTimer("InventoryUpdateTimer")

	-- TODO Refactor: Investigate these two, we may not need them if we can detect the origin window of a drag
	Apollo.RegisterEventHandler("DragDropSysBegin", "OnSystemBeginDragDrop", self)
	Apollo.RegisterEventHandler("DragDropSysEnd", 	"OnSystemEndDragDrop", self)

	self.wndDeleteConfirm 	= Apollo.LoadForm(self.xmlDoc, "InventoryDeleteNotice", nil, self)
	self.wndSalvageConfirm 	= Apollo.LoadForm(self.xmlDoc, "InventorySalvageNotice", nil, self)
	self.wndMain 			= Apollo.LoadForm(self.xmlDoc, "InventoryBag", nil, self)
	self.wndSplit 			= Apollo.LoadForm(self.xmlDoc, "SplitStackContainer", nil, self)
	self.wndMain:FindChild("VirtualInvToggleBtn"):AttachWindow(self.wndMain:FindChild("VirtualInvContainer"))
	self.wndMain:Show(false, true)
	self.wndSalvageConfirm:Show(false, true)
	self.wndDeleteConfirm:Show(false, true)
	self.wndNewSatchelItemRunner = self.wndMain:FindChild("BottomContainer:SatchelBtn")
	self.wndSalvageAllBtn = self.wndMain:FindChild("SalvageAllBtn")

	-- Variables
	self.nBoxSize = knLargeIconOption
	self.bFirstLoad = true
	self.nLastBagMaxSize = 0
	self.nLastWndMainWidth = self.wndMain:GetWidth()
	self.bSupplySatchelOpen = false

	local nLeft, nTop, nRight, nBottom = self.wndMain:GetAnchorOffsets()
	self.nFirstEverWidth = nRight - nLeft
	self.wndMain:SetSizingMinimum(238, 270)
	self.wndMain:SetSizingMaximum(1200, 700)

	nLeft, nTop, nRight, nBottom = self.wndMain:FindChild("MainGridContainer"):GetAnchorOffsets()
	self.nFirstEverMainGridHeight = nBottom - nTop

	self.tBagSlots = {}
	self.tBagCounts = {}
	for idx = 1, knMaxBags do
		self.tBagSlots[idx] = self.wndMain:FindChild("BagBtn" .. idx)
		self.tBagCounts[idx] = self.wndMain:FindChild("BagCount" .. idx)
	end

	self.nEquippedBagCount = 0 -- used to identify bag updates

	self:UpdateSquareSize()

	--Alt Curency Display
	for idx = 1, #karCurrency do
		local tData = karCurrency[idx]
		local wnd = Apollo.LoadForm(self.xmlDoc, "PickerEntry", self.wndMain:FindChild("OptionsConfigureCurrencyList"), self)
		wnd:FindChild("EntryCash"):SetMoneySystem(tData.eType) -- We'll fill in the amount during the timer
		wnd:FindChild("PickerEntryBtn"):SetData(idx)
		wnd:FindChild("PickerEntryBtn"):SetCheck(idx == self.nAltCurrencySelected)
		wnd:FindChild("PickerEntryBtnText"):SetText(tData.strTitle)
		wnd:FindChild("PickerEntryBtn"):SetTooltip(tData.strDescription)
		tData.wnd = wnd
	end
	self.wndMain:FindChild("OptionsConfigureCurrencyList"):ArrangeChildrenVert(0)

	if GameLib.GetPlayerUnit() then
		self:OnCharacterCreated()
	end

	if self.locSavedWindowLoc then
		self.wndMain:MoveToLocation(self.locSavedWindowLoc)
	end

	self.wndMainBagWindow = self.wndMain:FindChild("MainBagWindow")
	
	self.wndMainBagWindow:SetNewItemOverlaySprite("ForgeUI_Border")
	
	self.wndMainBagWindow:SetItemSortComparer(ktSortFunctions[self.nSortItemType])
	self.wndMainBagWindow:SetSort(self.bShouldSortItems)
	self.wndMain:FindChild("OptionsContainer:OptionsContainerFrame:OptionsConfigureSort:IconBtnSortDropDown:ItemSortPrompt:IconBtnSortOff"):SetCheck(not self.bShouldSortItems)
	self.wndMain:FindChild("OptionsContainer:OptionsContainerFrame:OptionsConfigureSort:IconBtnSortDropDown:ItemSortPrompt:IconBtnSortAlpha"):SetCheck(self.bShouldSortItems and self.nSortItemType == 1)
	self.wndMain:FindChild("OptionsContainer:OptionsContainerFrame:OptionsConfigureSort:IconBtnSortDropDown:ItemSortPrompt:IconBtnSortCategory"):SetCheck(self.bShouldSortItems and self.nSortItemType == 2)
	self.wndMain:FindChild("OptionsContainer:OptionsContainerFrame:OptionsConfigureSort:IconBtnSortDropDown:ItemSortPrompt:IconBtnSortQuality"):SetCheck(self.bShouldSortItems and self.nSortItemType == 3)

	self.wndIconBtnSortDropDown = self.wndMain:FindChild("OptionsContainer:OptionsContainerFrame:OptionsConfigureSort:IconBtnSortDropDown")
	self.wndIconBtnSortDropDown:AttachWindow(self.wndIconBtnSortDropDown:FindChild("ItemSortPrompt"))
end

function InventoryBag:OnSupplySatchelOpen()
	self.bSupplySatchelOpen = true
end

function InventoryBag:OnSupplySatchelClosed()
	self.bSupplySatchelOpen = false
end

function InventoryBag:OnLootstackItemSentToTradeskillBag(item)
	--self.wndNewSatchelItemRunner:Show(not self.bSupplySatchelOpen)
end

function InventoryBag:OnInterfaceMenuListHasLoaded()
	Event_FireGenericEvent("InterfaceMenuList_NewAddOn", Apollo.GetString("InterfaceMenu_Inventory"), {"InterfaceMenu_ToggleInventory", "ForgeUI_Inventory", "Icon_Windows32_UI_CRB_InterfaceMenu_Inventory"})
end

function InventoryBag:OnWindowManagementReady()
	Event_FireGenericEvent("WindowManagementAdd", {wnd = self.wndMain, strName = Apollo.GetString("InterfaceMenu_Inventory"), nSaveVersion=2})
end

function InventoryBag:OnCharacterCreated()
	self:OnPlayerCurrencyChanged()
end

function InventoryBag:OnToggleVisibility()
	if self.wndMain:IsShown() then
		self.wndMain:Close()
		Sound.Play(Sound.PlayUIBagClose)
		Apollo.StopTimer("InventoryUpdateTimer")
	else
		self.wndMain:Invoke()
		Sound.Play(Sound.PlayUIBagOpen)
		Apollo.StartTimer("InventoryUpdateTimer")
	end
	if self.bFirstLoad then
		self.bFirstLoad = false
	end

	if self.wndMain:IsShown() then
		self:UpdateSquareSize()
		self:UpdateBagSlotItems()
		self:OnQuestObjectiveUpdated() -- Populate Virtual ForgeUI_Inventory Btn from reloadui/load
		self:HelperSetSalvageEnable()
	end
end

function InventoryBag:OnToggleVisibilityAlways()
	self.wndMain:Invoke()
	Apollo.StartTimer("InventoryUpdateTimer")

	if self.bFirstLoad then
		self.bFirstLoad = false
	end

	if self.wndMain:IsShown() then
		self:UpdateSquareSize()
		self:UpdateBagSlotItems()
		self:OnQuestObjectiveUpdated() -- Populate Virtual ForgeUI_Inventory Btn from reloadui/load
		self:HelperSetSalvageEnable()
	end
end

function InventoryBag:OnLevelUpUnlock_Inventory_Salvage()
	self:OnToggleVisibilityAlways()
end

function InventoryBag:OnLevelUpUnlock_Path_Item(itemFromPath)
	self:OnToggleVisibilityAlways()
end

-----------------------------------------------------------------------------------------------
-- Main Update Timer
-----------------------------------------------------------------------------------------------
function InventoryBag:OnInventoryClosed( wndHandler, wndControl )
	self.wndMain:FindChild("MainBagWindow"):MarkAllItemsAsSeen()
end

function InventoryBag:OnPlayerCurrencyChanged()
	self.wndMain:FindChild("MainCashWindow"):SetAmount(GameLib.GetPlayerCurrency(), true)
		--Alt Currency stuff
	for key, wndCurr in pairs(self.wndMain:FindChild("OptionsConfigureCurrencyList"):GetChildren()) do
		self:UpdateAltCash(wndCurr)
	end
end

function InventoryBag:UpdateBagSlotItems() -- update our bag display
	local strEmptyBag = Apollo.GetString("Inventory_EmptySlot")
	local nOldBagCount = self.nEquippedBagCount -- record the old count

	self.nEquippedBagCount = 0	-- reset

	for idx = 1, knMaxBags do
		local itemBag = self.wndMain:FindChild("MainBagWindow"):GetBagItem(idx)
		local wndCtrl = self.wndMain:FindChild("BagBtn"..idx)
		if itemBag then
			self.tBagCounts[idx]:SetText("+" .. itemBag:GetBagSlots())
			wndCtrl:FindChild("RemoveBagIcon"):Show(true)
			wndCtrl:FindChild("RemoveBagIcon"):SetData(itemBag)
			self.nEquippedBagCount = self.nEquippedBagCount + 1
			Tooltip.GetItemTooltipForm(self, self.wndMain:FindChild("BagBtn"..idx), itemBag, {bPrimary = true, bSelling = false, itemCompare = itemEquipped})
		else
			self.tBagCounts[idx]:SetText("")
			wndCtrl:SetTooltip(string.format("<T Font=\"CRB_InterfaceSmall\" TextColor=\"white\">%s</T>", strEmptyBag))
			wndCtrl:FindChild("RemoveBagIcon"):Show(false)
		end
	end
end

function InventoryBag:OnBagBtnMouseEnter(wndHandler, wndControl)
end

function InventoryBag:OnBagBtnMouseExit(wndHandler, wndControl)
end

-----------------------------------------------------------------------------------------------
-- Drawing Bag Slots
-----------------------------------------------------------------------------------------------

function InventoryBag:OnMainWindowMouseResized()
	self:UpdateSquareSize()
	self.wndMain:FindChild("VirtualInvItems"):ArrangeChildrenHorz(1)
end

function InventoryBag:UpdateSquareSize()
	if not self.wndMain then
		return
	end

	local wndBag = self.wndMain:FindChild("MainBagWindow")
	wndBag:SetSquareSize(self.nBoxSize, self.nBoxSize)

end

-----------------------------------------------------------------------------------------------
-- Options
-----------------------------------------------------------------------------------------------

function InventoryBag:OnBGBottomCashBtnToggle(wndHandler, wndControl)
	self.wndMain:FindChild("OptionsBtn"):SetCheck(wndHandler:IsChecked())
	self:OnOptionsMenuToggle()
end

function InventoryBag:OnOptionsMenuToggle(wndHandler, wndControl) -- OptionsBtn
	self.wndMain:FindChild("BGBottomCashBtn"):SetCheck(self.wndMain:FindChild("OptionsBtn"):IsChecked())
	self.wndMain:FindChild("OptionsContainer"):Show(self.wndMain:FindChild("OptionsBtn"):IsChecked())

	for idx = 1,4 do
		self.wndMain:FindChild("BagBtn" .. idx):FindChild("RemoveBagIcon"):Show(false)
	end

	self.wndMain:FindChild("IconBtnLarge"):SetCheck(self.nBoxSize == kLargeIconOption)
	self.wndMain:FindChild("IconBtnSmall"):SetCheck(self.nBoxSize == kSmallIconOption)

	for key, wndCurr in pairs(self.wndMain:FindChild("OptionsConfigureCurrencyList"):GetChildren()) do
		self:UpdateAltCash(wndCurr)
	end
end

function InventoryBag:OnOptionsCloseClick()
	self.wndMain:FindChild("BGBottomCashBtn"):SetCheck(false)
	self.wndMain:FindChild("OptionsBtn"):SetCheck(false)
	self:OnOptionsMenuToggle()
end

function InventoryBag:OnOptionsAddSizeRows()
	if self.nBoxSize == knSmallIconOption then
		self.nBoxSize = knLargeIconOption
		self:OnMainWindowMouseResized()
		self:UpdateSquareSize()
	end
end

function InventoryBag:OnOptionsRemoveSizeRows()
	if self.nBoxSize == knLargeIconOption then
		self.nBoxSize = knSmallIconOption
		self:OnMainWindowMouseResized()
		self:UpdateSquareSize()
	end
end

-----------------------------------------------------------------------------------------------
-- Alt Currency Window Functions
-----------------------------------------------------------------------------------------------

function InventoryBag:UpdateAltCash(wndHandler, wndControl) -- Also from PickerEntryBtn
	local nSelected = wndHandler:FindChild("PickerEntryBtn"):GetData()
	local tData = karCurrency[nSelected]

	if wndHandler:FindChild("PickerEntryBtn"):IsChecked() then
		self.nAltCurrencySelected = nSelected
		self:UpdateAltCashDisplay()
	end

	if self.wndMain:FindChild("OptionsBtn"):IsChecked() then
		tData.wnd:FindChild("EntryCash"):SetAmount(GameLib.GetPlayerCurrency(tData.eType):GetAmount(), true)
	end
end

function InventoryBag:UpdateAltCashDisplay()
	local tData = karCurrency[self.nAltCurrencySelected]

	self.wndMain:FindChild("AltCashWindow"):SetMoneySystem(tData.eType)
	self.wndMain:FindChild("AltCashWindow"):SetAmount(GameLib.GetPlayerCurrency(tData.eType):GetAmount(), true)
	self.wndMain:FindChild("AltCashWindow"):SetTooltip(String_GetWeaselString(Apollo.GetString("Inventory_MoneyTooltip"), tData.strDescription))
	self.wndMain:FindChild("MainCashWindow"):SetTooltip(String_GetWeaselString(Apollo.GetString("Inventory_MoneyTooltip"), tData.strDescription))
end

-----------------------------------------------------------------------------------------------
-- Supply Satchel
-----------------------------------------------------------------------------------------------

function InventoryBag:OnToggleSupplySatchel(wndHandler, wndControl)
	--ToggleTradeSkillsInventory()
	local tAnchors = {}
	tAnchors.nLeft, tAnchors.nTop, tAnchors.nRight, tAnchors.nBottom = self.wndMain:GetAnchorOffsets()
	Event_FireGenericEvent("ToggleTradeskillInventoryFromBag", tAnchors)
	--self.wndNewSatchelItemRunner:Show(false)
end

-----------------------------------------------------------------------------------------------
-- Salvage All
-----------------------------------------------------------------------------------------------

function InventoryBag:OnSalvageAllBtn(wndHandler, wndControl)
	Event_FireGenericEvent("RequestSalvageAll", tAnchors)
end

function InventoryBag:OnDragDropSalvage(wndHandler, wndControl, nX, nY, wndSource, strType, iData)
	if strType == "DDBagItem" and self.wndMain:FindChild("SalvageAllBtn"):GetData() then
		self:InvokeSalvageConfirmWindow(iData)
	end
	return false
end

function InventoryBag:OnQueryDragDropSalvage(wndHandler, wndControl, nX, nY, wndSource, strType, iData)
	if strType == "DDBagItem" and self.wndMain:FindChild("SalvageAllBtn"):GetData() then
		return Apollo.DragDropQueryResult.Accept
	end
	return Apollo.DragDropQueryResult.Ignore
end

function InventoryBag:OnDragDropNotifySalvage(wndHandler, wndControl, bMe) -- TODO: We can probably replace this with a button mouse over state
	if bMe and self.wndMain:FindChild("SalvageIcon"):GetData() then
		--self.wndMain:FindChild("SalvageIcon"):SetSprite("CRB_Inventory:InvBtn_SalvageToggleFlyby")
		--self.wndMain:FindChild("TextActionPrompt_Salvage"):Show(true)
	elseif self.wndMain:FindChild("SalvageIcon"):GetData() then
		--self.wndMain:FindChild("SalvageIcon"):SetSprite("CRB_Inventory:InvBtn_SalvageTogglePressed")
		--self.wndMain:FindChild("TextActionPrompt_Salvage"):Show(false)
	end
end

-----------------------------------------------------------------------------------------------
-- Virtual ForgeUI_Inventory
-----------------------------------------------------------------------------------------------

function InventoryBag:OnQuestObjectiveUpdated()
	self:UpdateVirtualItemInventory()
end

function InventoryBag:OnChallengeUpdated()
	self:UpdateVirtualItemInventory()
end

function InventoryBag:UpdateVirtualItemInventory()
	local tVirtualItems = Item.GetVirtualItems()
	local bThereAreItems = #tVirtualItems > 0

	self.wndMain:FindChild("VirtualInvToggleBtn"):Show(bThereAreItems)
	self.wndMain:FindChild("VirtualInvContainer"):SetData(#tVirtualItems)
	self.wndMain:FindChild("VirtualInvContainer"):Show(self.wndMain:FindChild("VirtualInvToggleBtn"):IsChecked())

	if not bThereAreItems then
		self.wndMain:FindChild("VirtualInvToggleBtn"):SetCheck(false)
		self.wndMain:FindChild("VirtualInvContainer"):Show(false)
	elseif self.wndMain:FindChild("VirtualInvContainer"):GetData() == 0 then
		self.wndMain:FindChild("VirtualInvToggleBtn"):SetCheck(true)
		self.wndMain:FindChild("VirtualInvContainer"):Show(true)
	end

	-- Draw items
	self.wndMain:FindChild("VirtualInvItems"):DestroyChildren()
	local nOnGoingCount = 0
	for key, tCurrItem in pairs(tVirtualItems) do
		local wndCurr = Apollo.LoadForm(self.xmlDoc, "VirtualItem", self.wndMain:FindChild("VirtualInvItems"), self)
		if tCurrItem.nCount > 1 then
			wndCurr:FindChild("VirtualItemCount"):SetText(tCurrItem.nCount)
		end
		nOnGoingCount = nOnGoingCount + tCurrItem.nCount
		wndCurr:FindChild("VirtualItemDisplay"):SetSprite(tCurrItem.strIcon)
		wndCurr:SetTooltip(string.format("<P Font=\"CRB_InterfaceSmall\">%s</P><P Font=\"CRB_InterfaceSmall\" TextColor=\"aaaaaaaa\">%s</P>", tCurrItem.strName, tCurrItem.strFlavor))
	end
	self.wndMain:FindChild("VirtualInvToggleBtn"):SetText(String_GetWeaselString(Apollo.GetString("Inventory_VirtualInvBtn"), nOnGoingCount))
	self.wndMain:FindChild("VirtualInvItems"):ArrangeChildrenHorz(1)

	-- Adjust heights
	local bShowQuestItems = self.wndMain:FindChild("VirtualInvToggleBtn"):IsChecked()
	if not self.nVirtualButtonHeight then
		local nLeft, nTop, nRight, nBottom = self.wndMain:FindChild("VirtualInvToggleBtn"):GetAnchorOffsets()
		self.nVirtualButtonHeight = nBottom - nTop
	end
	if not self.nQuestItemContainerHeight then
		local nLeft, nTop, nRight, nBottom = self.wndMain:FindChild("VirtualInvContainer"):GetAnchorOffsets()
		self.nQuestItemContainerHeight = nBottom - nTop
	end

	local nLeft, nTop, nRight, nBottom = self.wndMain:FindChild("BGVirtual"):GetAnchorOffsets()
	nTop = nBottom
	if bThereAreItems then
		nTop = nBottom - self.nVirtualButtonHeight
		if bShowQuestItems then
			nTop = nTop - self.nQuestItemContainerHeight
		end
	end
	self.wndMain:FindChild("BGVirtual"):SetAnchorOffsets(nLeft, nTop, nRight, nBottom)

	local nBagLeft, nBagTop, nBagRight, nBagBottom = self.wndMain:FindChild("GridContainer"):GetAnchorOffsets()
	self.wndMain:FindChild("GridContainer"):SetAnchorOffsets(nBagLeft, nBagTop, nBagRight, nTop)
end

-----------------------------------------------------------------------------------------------
-- Drag and Drop
-----------------------------------------------------------------------------------------------

function InventoryBag:OnBagDragDropCancel(wndHandler, wndControl, strType, iData, eReason)
	if strType ~= "DDBagItem" or eReason == Apollo.DragDropCancelReason.EscapeKey or eReason == Apollo.DragDropCancelReason.ClickedOnNothing then
		return false
	end

	if eReason == Apollo.DragDropCancelReason.ClickedOnWorld or eReason == Apollo.DragDropCancelReason.DroppedOnNothing then
		self:InvokeDeleteConfirmWindow(iData)
	end
	return false
end

-- Trash Icon
function InventoryBag:OnDragDropTrash(wndHandler, wndControl, nX, nY, wndSource, strType, iData)
	if strType == "DDBagItem" then
		self:InvokeDeleteConfirmWindow(iData)
	end
	return false
end

function InventoryBag:OnQueryDragDropTrash(wndHandler, wndControl, nX, nY, wndSource, strType, iData)
	if strType == "DDBagItem" then
		return Apollo.DragDropQueryResult.Accept
	end
	return Apollo.DragDropQueryResult.Ignore
end

function InventoryBag:OnDragDropNotifyTrash(wndHandler, wndControl, bMe) -- TODO: We can probably replace this with a button mouse over state
	if bMe then
		self.wndMain:FindChild("TrashIcon"):SetSprite("CRB_Inventory:InvBtn_TrashToggleFlyby")
		self.wndMain:FindChild("TextActionPrompt_Trash"):Show(true)
	else
		self.wndMain:FindChild("TrashIcon"):SetSprite("CRB_Inventory:InvBtn_TrashTogglePressed")
		self.wndMain:FindChild("TextActionPrompt_Trash"):Show(false)
	end
end
-- End Trash Icon

-- Salvage Icon
function InventoryBag:OnDragDropSalvage(wndHandler, wndControl, nX, nY, wndSource, strType, iData)
	if strType == "DDBagItem" and self.wndMain:FindChild("SalvageIcon"):GetData() then
		self:InvokeSalvageConfirmWindow(iData)
	end
	return false
end

function InventoryBag:OnQueryDragDropSalvage(wndHandler, wndControl, nX, nY, wndSource, strType, iData)
	if strType == "DDBagItem" and self.wndMain:FindChild("SalvageIcon"):GetData() then
		return Apollo.DragDropQueryResult.Accept
	end
	return Apollo.DragDropQueryResult.Ignore
end

function InventoryBag:OnDragDropNotifySalvage(wndHandler, wndControl, bMe) -- TODO: We can probably replace this with a button mouse over state
	if bMe and self.wndMain:FindChild("SalvageIcon"):GetData() then
		self.wndMain:FindChild("TextActionPrompt_Salvage"):Show(true)
	elseif self.wndMain:FindChild("SalvageIcon"):GetData() then
		self.wndMain:FindChild("TextActionPrompt_Salvage"):Show(false)
	end
end
-- End Salvage Icon

function InventoryBag:HelperSetSalvageEnable()
	local tInvItems = GameLib.GetPlayerUnit():GetInventoryItems()
	for idx, tItem in ipairs(tInvItems) do
		if tItem and tItem.itemInBag and tItem.itemInBag:CanSalvage() and not tItem.itemInBag:CanAutoSalvage() then
			self.wndSalvageAllBtn:Enable(true)
			return
		end
	end
	self.wndSalvageAllBtn:Enable(false)
end


function InventoryBag:OnUpdateInventory()
	if not self.wndMain or not self.wndMain:IsValid() or not self.wndMain:IsShown() then
		return
	end

	self:HelperSetSalvageEnable()
end

function InventoryBag:OnSystemBeginDragDrop(wndSource, strType, iData)
	if strType ~= "DDBagItem" then return end
	self.wndMain:FindChild("TextActionPrompt_Trash"):Show(false)
	self.wndMain:FindChild("TextActionPrompt_Salvage"):Show(false)

	self.wndMain:FindChild("TrashIcon"):SetSprite("CRB_Inventory:InvBtn_TrashTogglePressed")

	local item = self.wndMain:FindChild("MainBagWindow"):GetItem(iData)
	if item and item:CanSalvage() then
		self.wndMain:FindChild("SalvageIcon"):SetData(true)
		self.wndSalvageAllBtn:Enable(true)
	else
		self.wndSalvageAllBtn:Enable(false)
	end

	Sound.Play(Sound.PlayUI45LiftVirtual)
end

function InventoryBag:OnSystemEndDragDrop(strType, iData)
	if not self.wndMain or not self.wndMain:IsValid() or not self.wndMain:FindChild("TrashIcon") or strType == "DDGuildBankItem" or strType == "DDWarPartyBankItem" or strType == "DDGuildBankItemSplitStack" then
		return -- TODO Investigate if there are other types
	end

	self.wndMain:FindChild("TrashIcon"):SetSprite("CRB_Inventory:InvBtn_TrashToggleNormal")
	self.wndMain:FindChild("SalvageIcon"):SetData(false)
	self.wndMain:FindChild("TextActionPrompt_Trash"):Show(false)
	self.wndMain:FindChild("TextActionPrompt_Salvage"):Show(false)
	self:HelperSetSalvageEnable()
	self:UpdateSquareSize()
	Sound.Play(Sound.PlayUI46PlaceVirtual)
end

function InventoryBag:OnEquippedItem(eSlot, itemNew, itemOld)
	if itemNew then
		itemNew:PlayEquipSound()
	else
		itemOld:PlayEquipSound()
	end
end

-----------------------------------------------------------------------------------------------
-- Item Sorting
-----------------------------------------------------------------------------------------------

function InventoryBag:OnOptionsSortItemsOff(wndHandler, wndControl)
	self.bShouldSortItems = false
	self.wndMainBagWindow:SetSort(self.bShouldSortItems)
	self.wndIconBtnSortDropDown:SetCheck(false)
end

function InventoryBag:OnOptionsSortItemsName(wndHandler, wndControl)
	self.bShouldSortItems = true
	self.nSortItemType = 1
	self.wndMainBagWindow:SetSort(self.bShouldSortItems)
	self.wndMainBagWindow:SetItemSortComparer(ktSortFunctions[self.nSortItemType])
	self.wndIconBtnSortDropDown:SetCheck(false)
end

function InventoryBag:OnOptionsSortItemsByCategory(wndHandler, wndControl)
	self.bShouldSortItems = true
	self.nSortItemType = 2
	self.wndMainBagWindow:SetSort(self.bShouldSortItems)
	self.wndMainBagWindow:SetItemSortComparer(ktSortFunctions[self.nSortItemType])
	self.wndIconBtnSortDropDown:SetCheck(false)
end

function InventoryBag:OnOptionsSortItemsByQuality(wndHandler, wndControl)
	self.bShouldSortItems = true
	self.nSortItemType = 3
	self.wndMainBagWindow:SetSort(self.bShouldSortItems)
	self.wndMainBagWindow:SetItemSortComparer(ktSortFunctions[self.nSortItemType])
	self.wndIconBtnSortDropDown:SetCheck(false)
end

-----------------------------------------------------------------------------------------------
-- Delete/Salvage Screen
-----------------------------------------------------------------------------------------------

function InventoryBag:InvokeDeleteConfirmWindow(iData)
	local itemData = Item.GetItemFromInventoryLoc(iData)
	if itemData and not itemData:CanDelete() then
		return
	end
	self.wndDeleteConfirm:SetData(iData)
	self.wndDeleteConfirm:Show(true)
	self.wndDeleteConfirm:ToFront()
	self.wndDeleteConfirm:FindChild("DeleteBtn"):SetActionData(GameLib.CodeEnumConfirmButtonType.DeleteItem, iData)
	self.wndMain:FindChild("DragDropMouseBlocker"):Show(true)
	Sound.Play(Sound.PlayUI55ErrorVirtual)
end

function InventoryBag:InvokeSalvageConfirmWindow(iData)
	self.wndSalvageConfirm:SetData(iData)
	self.wndSalvageConfirm:Show(true)
	self.wndSalvageConfirm:ToFront()
	self.wndSalvageConfirm:FindChild("SalvageBtn"):SetActionData(GameLib.CodeEnumConfirmButtonType.SalvageItem, iData)
	self.wndMain:FindChild("DragDropMouseBlocker"):Show(true)
	Sound.Play(Sound.PlayUI55ErrorVirtual)
end

-- TODO SECURITY: These confirmations are entirely a UI concept. Code should have a allow/disallow.
function InventoryBag:OnDeleteCancel()
	self.wndDeleteConfirm:SetData(nil)
	self.wndDeleteConfirm:Close()
	self.wndMain:FindChild("DragDropMouseBlocker"):Show(false)
end

function InventoryBag:OnSalvageCancel()
	self.wndSalvageConfirm:SetData(nil)
	self.wndSalvageConfirm:Close()
	self.wndMain:FindChild("DragDropMouseBlocker"):Show(false)
end

function InventoryBag:OnDeleteConfirm()
	self:OnDeleteCancel()
end

function InventoryBag:OnSalvageConfirm()
	self:OnSalvageCancel()
end

-----------------------------------------------------------------------------------------------
-- Stack Splitting
-----------------------------------------------------------------------------------------------

function InventoryBag:OnGenericEvent_SplitItemStack(item)
	if not item then 
		return 
	end
	
	local nStackCount = item:GetStackCount()
	if nStackCount < 2 then
		self.wndSplit:Show(false)
		return
	end
	self.wndSplit:Invoke()
	local tMouse = Apollo.GetMouse()
	self.wndSplit:Move(tMouse.x - math.floor(self.wndSplit:GetWidth() / 2) , tMouse.y - knPaddingTop - self.wndSplit:GetHeight(), self.wndSplit:GetWidth(), self.wndSplit:GetHeight())


	self.wndSplit:SetData(item)
	self.wndSplit:FindChild("SplitValue"):SetValue(1)
	self.wndSplit:FindChild("SplitValue"):SetMinMax(1, nStackCount - 1)
	self.wndSplit:Show(true)
end

function InventoryBag:OnSplitStackCloseClick()
	self.wndSplit:Show(false)
end

function InventoryBag:OnSpinnerChanged()
	local wndValue = self.wndSplit:FindChild("SplitValue")
	local nValue = wndValue:GetValue()
	local itemStack = self.wndSplit:GetData()
	local nMaxStackSplit = itemStack:GetStackCount() - 1

	if nValue < 1 then
		wndValue:SetValue(1)
	elseif nValue > nMaxStackSplit then
		wndValue:SetValue(nMaxStackSplit)
	end
end

function InventoryBag:OnSplitStackConfirm(wndHandler, wndCtrl)
	self.wndSplit:Close()
	self.wndMain:FindChild("MainBagWindow"):StartSplitStack(self.wndSplit:GetData(), self.wndSplit:FindChild("SplitValue"):GetValue())
end

function InventoryBag:OnGenerateTooltip(wndControl, wndHandler, tType, item)
	if wndControl ~= wndHandler then return end
	wndControl:SetTooltipDoc(nil)
	if item ~= nil then
		local itemEquipped = item:GetEquippedItemForItemType()
		Tooltip.GetItemTooltipForm(self, wndControl, item, {bPrimary = true, bSelling = false, itemCompare = itemEquipped})
		-- Tooltip.GetItemTooltipForm(self, wndControl, itemEquipped, {bPrimary = false, bSelling = false, itemCompare = item})
	end
end

local InventoryBagInst = InventoryBag:new()
InventoryBagInst:Init()
