----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI addon
--
-- name:        ForgeUI_Inventory.lua
-- author:      Winty Badass@Jabbit
-- about:       Inventory addon for ForgeUI
-----------------------------------------------------------------------------------------------

require "Apollo"
require "GameLib"
require "Item"
require "Window"
require "Money"

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI

-----------------------------------------------------------------------------------------------
-- ForgeUI Addon Definition
-----------------------------------------------------------------------------------------------
local ForgeUI_Inventory = {
	_NAME = "ForgeUI_Inventory",
	_API_VERSION = 3,
	_VERSION = "1.0",
	_DB = {},
	DISPLAY_NAME = "Inventory",

	tSettings = {
		global = {
			bShouldSortItems = false,
			nSortItemType = 2,
			nAltCurrencySelected = 1,
		}
	}
}


local knSmallIconOption = 42
local knLargeIconOption = 48
local knMaxBags = 4 -- how many bags can the player have
local knPaddingTop = 20

local karCurrency =  	-- Alt currency table; re-indexing the enums so they don't have to be in sequence code-side (and removing cash)
{						-- To add a new currency just add an entry to the table; the UI will do the rest. Idx == 1 will be the default one shown
	{eType = Money.CodeEnumCurrencyType.Renown, 					strTitle = Apollo.GetString("CRB_Renown"), 						strDescription = Apollo.GetString("CRB_Renown_Desc")},
	{eType = Money.CodeEnumCurrencyType.Triploons, 					strTitle = Apollo.GetString("CRB_Triploons"), 					strDescription = Apollo.GetString("CRB_Triploons_Desc")},
	{eType = Money.CodeEnumCurrencyType.ElderGems, 					strTitle = Apollo.GetString("CRB_Elder_Gems"), 					strDescription = Apollo.GetString("CRB_Elder_Gems_Desc")},
	{eType = Money.CodeEnumCurrencyType.Glory, 						strTitle = Apollo.GetString("CRB_Glory"), 						strDescription = Apollo.GetString("CRB_Glory_Desc")},
	{eType = Money.CodeEnumCurrencyType.Prestige, 					strTitle = Apollo.GetString("CRB_Prestige"), 					strDescription = Apollo.GetString("CRB_Prestige_Desc")},
	{eType = Money.CodeEnumCurrencyType.CraftingVouchers, 			strTitle = Apollo.GetString("CRB_Crafting_Vouchers"), 			strDescription = Apollo.GetString("CRB_Crafting_Voucher_Desc")},
  {eType = Money.CodeEnumCurrencyType.PurpleEssence,         strTitle = Apollo.GetString("Matrix_NodePurpleName"),        strDescription = AccountItemLib.GetAccountCurrency(AccountItemLib.CodeEnumAccountCurrency.PurpleEssence):GetTypeString()},
  {eType = Money.CodeEnumCurrencyType.RedEssence,         strTitle = Apollo.GetString("Matrix_NodeRedName"),        strDescription = AccountItemLib.GetAccountCurrency(AccountItemLib.CodeEnumAccountCurrency.RedEssence):GetTypeString()},
  {eType = Money.CodeEnumCurrencyType.BlueEssence,         strTitle = Apollo.GetString("Matrix_NodeBlueName"),        strDescription = AccountItemLib.GetAccountCurrency(AccountItemLib.CodeEnumAccountCurrency.BlueEssence):GetTypeString()},
  {eType = Money.CodeEnumCurrencyType.GreenEssence,         strTitle = Apollo.GetString("Matrix_NodeGreenName"),        strDescription = AccountItemLib.GetAccountCurrency(AccountItemLib.CodeEnumAccountCurrency.GreenEssence):GetTypeString()},
	{eType = AccountItemLib.CodeEnumAccountCurrency.PromissoryNote, strTitle = Apollo.GetString("CRB_Protostar_Promissory_Note"),	strDescription = Apollo.GetString("CRB_Protostar_Promissory_Note_Desc"), bAccountItem = true},
	{eType = AccountItemLib.CodeEnumAccountCurrency.Omnibits,       strTitle = Apollo.GetString("CRB_OmniBits"),              		strDescription = Apollo.GetString("CRB_OmniBits_Desc"), bAccountItem = true},
	{eType = AccountItemLib.CodeEnumAccountCurrency.ServiceToken,   strTitle = Apollo.GetString("AccountInventory_ServiceToken"),   strDescription = Apollo.GetString("AccountInventory_ServiceToken_Desc"), bAccountItem = true},
	{eType = AccountItemLib.CodeEnumAccountCurrency.MysticShiny,    strTitle = Apollo.GetString("CRB_FortuneCoin"),           		strDescription = Apollo.GetString("CRB_FortuneCoin_Desc"), bAccountItem = true},
}

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
	if itemLeft:GetName() < itemRight:GetName() then
		return -1
	end
	if itemLeft:GetName() > itemRight:GetName() then
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
	if itemLeft:GetItemCategoryName() < itemRight:GetItemCategoryName() then
		return -1
	end
	if itemLeft:GetItemCategoryName() > itemRight:GetItemCategoryName() then
		return 1
	end
	if itemLeft:GetName() < itemRight:GetName() then
		return -1
	end
	if itemLeft:GetName() > itemRight:GetName() then
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
	if itemLeft:GetItemQuality() > itemRight:GetItemQuality() then
		return -1
	end
	if itemLeft:GetItemQuality() < itemRight:GetItemQuality() then
		return 1
	end
	if itemLeft:GetName() < itemRight:GetName() then
		return -1
	end
	if itemLeft:GetName() > itemRight:GetName() then
		return 1
	end
	return 0
end

local ktSortFunctions = {fnSortItemsByName, fnSortItemsByCategory, fnSortItemsByQuality}

function ForgeUI_Inventory:ForgeAPI_Init()
	self.xmlDoc = XmlDoc.CreateFromFile("..//ForgeUI_Inventory//ForgeUI_InventoryBag.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self)

	Apollo.RegisterEventHandler("UpdateInventory", 							"OnUpdateInventory", self)
	Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", 				"OnInterfaceMenuListHasLoaded", self)

	Apollo.RegisterEventHandler("InterfaceMenu_ToggleInventory", 			"OnToggleVisibility", self) -- TODO: The datachron attachment needs to be brought over
	Apollo.RegisterEventHandler("GuildBank_ShowPersonalInventory", 			"OnToggleVisibilityAlways", self)

	Apollo.RegisterEventHandler("PlayerEquippedItemChanged", 				"UpdateBagSlotItems", self) -- using this for bag changes
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
	self.wndMain 			= Apollo.LoadForm(self.xmlDoc, "InventoryBag", F:API_GetStratum("HudHighest"), self)
	self.wndSplit 			= Apollo.LoadForm(self.xmlDoc, "SplitStackContainer", nil, self)
	self.wndMain:FindChild("VirtualInvToggleBtn"):AttachWindow(self.wndMain:FindChild("VirtualInvContainer"))
	self.wndMain:Show(false, true)
	self.wndSalvageConfirm:Show(false, true)
	self.wndDeleteConfirm:Show(false, true)
	self.wndNewSatchelItemRunner = self.wndMain:FindChild("BottomContainer:SatchelBtn")
	self.wndSalvageAllBtn = self.wndMain:FindChild("SalvageAllBtn")

	F:API_RegisterMover(self, self.wndMain, "ForgeUI_Inventory", "Inventory", "misc")

	-- Variables
	self.nBoxSize = knLargeIconOption
	self.bFirstLoad = true
	self.nLastBagMaxSize = 0
	self.nLastWndMainWidth = self.wndMain:GetWidth()
	self.bSupplySatchelOpen = false

	local nLeft, _, nRight, _ = self.wndMain:GetAnchorOffsets()
	self.nFirstEverWidth = nRight - nLeft
	self.wndMain:SetSizingMinimum(245, 285)
	--self.wndMain:SetSizingMaximum(1200, 700)

	local _, nTop, _, nBottom = self.wndMain:FindChild("MainGridContainer"):GetAnchorOffsets()
	self.nFirstEverMainGridHeight = nBottom - nTop

	self.tBagSlots = {}
	self.tBagCounts = {}
	for idx = 1, knMaxBags do
		self.tBagSlots[idx] = self.wndMain:FindChild("BagBtn" .. idx)
		self.tBagCounts[idx] = self.wndMain:FindChild("BagCount" .. idx)
	end

	self.nEquippedBagCount = 0 -- used to identify bag updates

	self:UpdateSquareSize()

	if GameLib.GetPlayerUnit() then
		self:OnCharacterCreated()
	end

	self.wndMainBagWindow = self.wndMain:FindChild("MainBagWindow")

	self.wndMainBagWindow:SetNewItemOverlaySprite("Anim_Inventory_New:sprInventory_NewItem")
	self.wndMainBagWindow:SetCannotUseSprite("ClientSprites:LootCloseBox_Holo")
	--self.wndMainBagWindow:SetOpacity(0.05)

	self.wndMainBagWindow:SetItemSortComparer(ktSortFunctions[self._DB.global.nSortItemType])
	self.wndMainBagWindow:SetSort(self._DB.global.bShouldSortItems)
	self.wndMain:FindChild("OptionsContainer:OptionsContainerFrame:OptionsConfigureSort:IconBtnSortDropDown:ItemSortPrompt:IconBtnSortOff"):SetCheck(not self._DB.global.bShouldSortItems)
	self.wndMain:FindChild("OptionsContainer:OptionsContainerFrame:OptionsConfigureSort:IconBtnSortDropDown:ItemSortPrompt:IconBtnSortAlpha"):SetCheck(self._DB.global.bShouldSortItems and self._DB.global.nSortItemType == 1)
	self.wndMain:FindChild("OptionsContainer:OptionsContainerFrame:OptionsConfigureSort:IconBtnSortDropDown:ItemSortPrompt:IconBtnSortCategory"):SetCheck(self._DB.global.bShouldSortItems and self._DB.global.nSortItemType == 2)
	self.wndMain:FindChild("OptionsContainer:OptionsContainerFrame:OptionsConfigureSort:IconBtnSortDropDown:ItemSortPrompt:IconBtnSortQuality"):SetCheck(self._DB.global.bShouldSortItems and self._DB.global.nSortItemType == 3)

	self.wndIconBtnSortDropDown = self.wndMain:FindChild("OptionsContainer:OptionsContainerFrame:OptionsConfigureSort:IconBtnSortDropDown")
	self.wndIconBtnSortDropDown:AttachWindow(self.wndIconBtnSortDropDown:FindChild("ItemSortPrompt"))

		--Alt Curency Display
	local wndOptionsContainer = self.wndMain:FindChild("OptionsContainer")
	local nLeft, nTop, nRight, nBottom = wndOptionsContainer:GetAnchorOffsets()
	wndOptionsContainer:SetAnchorOffsets(nLeft, nTop, nRight, nBottom + (#karCurrency * 30) + 5)


	for idx = 1, #karCurrency do
		local tData = karCurrency[idx]
		local wnd = Apollo.LoadForm(self.xmlDoc, "PickerEntry", self.wndMain:FindChild("OptionsConfigureCurrencyList"), self)

		if tData.bAccountItem then
			wnd:FindChild("EntryCash"):SetMoneySystem(Money.CodeEnumCurrencyType.GroupCurrency, 0, 0, tData.eType)
		else
			wnd:FindChild("EntryCash"):SetMoneySystem(tData.eType)
		end
		wnd:FindChild("PickerEntryBtn"):SetData(idx)
		wnd:FindChild("PickerEntryBtn"):SetCheck(idx == self._DB.global.nAltCurrencySelected)
		wnd:FindChild("PickerEntryBtnText"):SetText(tData.strTitle)

		local strDescription = tData.strDescription
		if tData.eType == AccountItemLib.CodeEnumAccountCurrency.Omnibits then
			local tOmniBitInfo = GameLib.GetOmnibitsBonusInfo()
			local nTotalWeeklyOmniBitBonus = tOmniBitInfo.nWeeklyBonusMax - tOmniBitInfo.nWeeklyBonusEarned;
			if nTotalWeeklyOmniBitBonus < 0 then
				nTotalWeeklyOmniBitBonus = 0
			end
			strDescription = strDescription.."\n"..String_GetWeaselString(Apollo.GetString("CRB_OmniBits_EarningsWeekly"), nTotalWeeklyOmniBitBonus)
		end
		wnd:FindChild("PickerEntryBtn"):SetTooltip(strDescription)
		tData.wnd = wnd
	end
	self.wndMain:FindChild("OptionsConfigureCurrencyList"):ArrangeChildrenVert(0)

	self:UpdateAltCashDisplay()
	self.wndMainBagWindow:SetSort(self._DB.global.bShouldSortItems)
	self.wndMainBagWindow:SetItemSortComparer(ktSortFunctions[self._DB.global.nSortItemType])
	self.wndMain:FindChild("OptionsContainer:OptionsContainerFrame:OptionsConfigureSort:IconBtnSortDropDown:ItemSortPrompt:IconBtnSortOff"):SetCheck(not self._DB.global.bShouldSortItems)
	self.wndMain:FindChild("OptionsContainer:OptionsContainerFrame:OptionsConfigureSort:IconBtnSortDropDown:ItemSortPrompt:IconBtnSortAlpha"):SetCheck(self._DB.global.bShouldSortItems and self._DB.global.nSortItemType == 1)
	self.wndMain:FindChild("OptionsContainer:OptionsContainerFrame:OptionsConfigureSort:IconBtnSortDropDown:ItemSortPrompt:IconBtnSortCategory"):SetCheck(self._DB.global.bShouldSortItems and self._DB.global.nSortItemType == 2)
	self.wndMain:FindChild("OptionsContainer:OptionsContainerFrame:OptionsConfigureSort:IconBtnSortDropDown:ItemSortPrompt:IconBtnSortQuality"):SetCheck(self._DB.global.bShouldSortItems and self._DB.global.nSortItemType == 3)

	Event_FireGenericEvent("AddonFullyLoaded", {addon = self, strName = self._NAME})
end

function ForgeUI_Inventory:OnSupplySatchelOpen()
	self.bSupplySatchelOpen = true
end

function ForgeUI_Inventory:OnSupplySatchelClosed()
	self.bSupplySatchelOpen = false
end

function ForgeUI_Inventory:OnLootstackItemSentToTradeskillBag(item)
	--self.wndNewSatchelItemRunner:Show(not self.bSupplySatchelOpen)
end

function ForgeUI_Inventory:OnInterfaceMenuListHasLoaded()
	Event_FireGenericEvent("InterfaceMenuList_NewAddOn", Apollo.GetString("InterfaceMenu_Inventory"), {"InterfaceMenu_ToggleInventory", "Inventory", "Icon_Windows32_UI_CRB_InterfaceMenu_Inventory"})

	if self.wndMainBagWindow then
		local tParams = {false, nil, self.wndMainBagWindow:GetTotalEmptyBagSlots()}
		Event_FireGenericEvent("InterfaceMenuList_AlertAddOn", Apollo.GetString("InterfaceMenu_Inventory"), tParams)
	end
end

function ForgeUI_Inventory:OnCharacterCreated()
	self:OnPlayerCurrencyChanged()
end

function ForgeUI_Inventory:OnToggleVisibility()
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

function ForgeUI_Inventory:OnToggleVisibilityAlways()
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

function ForgeUI_Inventory:OnLevelUpUnlock_Inventory_Salvage()
	self:OnToggleVisibilityAlways()
end

function ForgeUI_Inventory:OnLevelUpUnlock_Path_Item(itemFromPath)
	self:OnToggleVisibilityAlways()
end

-----------------------------------------------------------------------------------------------
-- Main Update Timer
-----------------------------------------------------------------------------------------------
function ForgeUI_Inventory:OnInventoryClosed( wndHandler, wndControl )
	self.wndMain:FindChild("MainBagWindow"):MarkAllItemsAsSeen()
end

function ForgeUI_Inventory:OnPlayerCurrencyChanged()
	self.wndMain:FindChild("MainCashWindow"):SetAmount(GameLib.GetPlayerCurrency(), true)
		--Alt Currency stuff
	for key, wndCurr in pairs(self.wndMain:FindChild("OptionsConfigureCurrencyList"):GetChildren()) do
		self:UpdateAltCash(wndCurr)
	end
end

function ForgeUI_Inventory:UpdateBagSlotItems() -- update our bag display
	-- local nOldBagCount = self.nEquippedBagCount -- record the old count // unused
	self.nEquippedBagCount = 0	-- reset

	for idx = 1, knMaxBags do
		local itemBag = self.wndMainBagWindow:GetBagItem(idx)
		local wndCtrl = self.wndMain:FindChild("BagBtn"..idx)

		if itemBag ~= wndCtrl:GetData() then
			wndCtrl:SetData(itemBag)
			if itemBag then
				self.tBagCounts[idx]:SetText("+" .. itemBag:GetBagSlots())
				local wndRemoveBagIcon = wndCtrl:FindChild("RemoveBagIcon")
				wndRemoveBagIcon:Show(true)
				wndRemoveBagIcon:SetData(itemBag)
				self.nEquippedBagCount = self.nEquippedBagCount + 1
				Tooltip.GetItemTooltipForm(self, wndCtrl, itemBag, {bPrimary = true, bSelling = false})
			else
				self.tBagCounts[idx]:SetText("")
				wndCtrl:SetTooltip(string.format("<T Font=\"CRB_InterfaceSmall\" TextColor=\"white\">%s</T>", Apollo.GetString("Inventory_EmptySlot")))
				wndCtrl:FindChild("RemoveBagIcon"):Show(false)
			end
		end
	end
end
function ForgeUI_Inventory:OnBagBtnMouseEnter(wndHandler, wndControl)
end

function ForgeUI_Inventory:OnBagBtnMouseExit(wndHandler, wndControl)
end

-----------------------------------------------------------------------------------------------
-- Drawing Bag Slots
-----------------------------------------------------------------------------------------------

function ForgeUI_Inventory:OnMainWindowMouseResized()
	F:API_UpdateMover("ForgeUI_Inventory")

	self:UpdateSquareSize()
	self.wndMain:FindChild("VirtualInvItems"):ArrangeChildrenHorz(1)
end

function ForgeUI_Inventory:UpdateSquareSize()
	if not self.wndMain then
		return
	end

	local wndBag = self.wndMain:FindChild("MainBagWindow")
	wndBag:SetSquareSize(self.nBoxSize, self.nBoxSize)

end

-----------------------------------------------------------------------------------------------
-- Options
-----------------------------------------------------------------------------------------------

function ForgeUI_Inventory:OnBGBottomCashBtnToggle(wndHandler, wndControl)
	self.wndMain:FindChild("OptionsBtn"):SetCheck(wndHandler:IsChecked())
	self:OnOptionsMenuToggle()
end

function ForgeUI_Inventory:OnOptionsMenuToggle(wndHandler, wndControl) -- OptionsBtn
	self.wndMain:FindChild("BGBottomCashBtn"):SetCheck(self.wndMain:FindChild("OptionsBtn"):IsChecked())
	self.wndMain:FindChild("OptionsContainer"):Show(self.wndMain:FindChild("OptionsBtn"):IsChecked())

	for idx = 1,4 do
		self.wndMain:FindChild("BagBtn" .. idx):FindChild("RemoveBagIcon"):Show(false)
	end

	self.wndMain:FindChild("IconBtnLarge"):SetCheck(self.nBoxSize == kLargeIconOption) -- kLargeIconOption undefined!
	self.wndMain:FindChild("IconBtnSmall"):SetCheck(self.nBoxSize == kSmallIconOption) -- kSmallIconOption undefined!

	for key, wndCurr in pairs(self.wndMain:FindChild("OptionsConfigureCurrencyList"):GetChildren()) do
		self:UpdateAltCash(wndCurr)
	end
end

function ForgeUI_Inventory:OnOptionsCloseClick()
	self.wndMain:FindChild("BGBottomCashBtn"):SetCheck(false)
	self.wndMain:FindChild("OptionsBtn"):SetCheck(false)
	self:OnOptionsMenuToggle()
end

function ForgeUI_Inventory:OnOptionsAddSizeRows()
	if self.nBoxSize == knSmallIconOption then
		self.nBoxSize = knLargeIconOption
		self:OnMainWindowMouseResized()
		self:UpdateSquareSize()
	end
end

function ForgeUI_Inventory:OnOptionsRemoveSizeRows()
	if self.nBoxSize == knLargeIconOption then
		self.nBoxSize = knSmallIconOption
		self:OnMainWindowMouseResized()
		self:UpdateSquareSize()
	end
end

-----------------------------------------------------------------------------------------------
-- Alt Currency Window Functions
-----------------------------------------------------------------------------------------------

function ForgeUI_Inventory:UpdateAltCash(wndHandler, wndControl) -- Also from PickerEntryBtn
	local nSelected = wndHandler:FindChild("PickerEntryBtn"):GetData()
	local tData = karCurrency[nSelected]

	if tData.eType == AccountItemLib.CodeEnumAccountCurrency.Omnibits then
		local strDescription = tData.strDescription
		local tOmniBitInfo = GameLib.GetOmnibitsBonusInfo()
		local nTotalWeeklyOmniBitBonus = tOmniBitInfo.nWeeklyBonusMax - tOmniBitInfo.nWeeklyBonusEarned;
		if nTotalWeeklyOmniBitBonus < 0 then
			nTotalWeeklyOmniBitBonus = 0
		end
		strDescription = strDescription.."\n"..String_GetWeaselString(Apollo.GetString("CRB_OmniBits_EarningsWeekly"), nTotalWeeklyOmniBitBonus)
		wndHandler:FindChild("PickerEntryBtn"):SetTooltip(strDescription)
	end

	if wndHandler:FindChild("PickerEntryBtn"):IsChecked() then
		self._DB.global.nAltCurrencySelected = nSelected
		self:UpdateAltCashDisplay()
	end

	if self.wndMain:FindChild("OptionsBtn"):IsChecked() then
		tData.wnd:FindChild("EntryCash"):SetAmount(ForgeUI_Inventory:HelperGetCurrencyAmmount(tData), true)
	end
end

function ForgeUI_Inventory:UpdateAltCashDisplay()
	if #karCurrency == 0 then return end

	local tData = karCurrency[self._DB.global.nAltCurrencySelected]

	if tData == nil then return end

	self.wndMain:FindChild("AltCashWindow"):SetAmount(self:HelperGetCurrencyAmmount(tData), true)
	local strDescription = tData.strDescription
	if tData.eType == AccountItemLib.CodeEnumAccountCurrency.Omnibits then
		local tOmniBitInfo = GameLib.GetOmnibitsBonusInfo()
		local nTotalWeeklyOmniBitBonus = tOmniBitInfo.nWeeklyBonusMax - tOmniBitInfo.nWeeklyBonusEarned;
		if nTotalWeeklyOmniBitBonus < 0 then
			nTotalWeeklyOmniBitBonus = 0
		end
		strDescription = strDescription.."\n"..String_GetWeaselString(Apollo.GetString("CRB_OmniBits_EarningsWeekly"), nTotalWeeklyOmniBitBonus)
	end
	self.wndMain:FindChild("AltCashWindow"):SetTooltip(String_GetWeaselString(Apollo.GetString("Inventory_MoneyTooltip"), strDescription))
	self.wndMain:FindChild("MainCashWindow"):SetTooltip(String_GetWeaselString(Apollo.GetString("Inventory_MoneyTooltip"), strDescription))
end


function ForgeUI_Inventory:HelperGetCurrencyAmmount(tData)
	local monAmount
	if tData.bAccountItem then
		monAmount = AccountItemLib.GetAccountCurrency(tData.eType)
	else
		monAmount = GameLib.GetPlayerCurrency(tData.eType)
	end
	return monAmount
end

-----------------------------------------------------------------------------------------------
-- Supply Satchel
-----------------------------------------------------------------------------------------------

function ForgeUI_Inventory:OnToggleSupplySatchel(wndHandler, wndControl)
	--ToggleTradeSkillsInventory()
	local tAnchors = {}
	tAnchors.nLeft, tAnchors.nTop, tAnchors.nRight, tAnchors.nBottom = self.wndMain:GetAnchorOffsets()
	Event_FireGenericEvent("ToggleTradeskillInventoryFromBag", tAnchors)
	--self.wndNewSatchelItemRunner:Show(false)
end

-----------------------------------------------------------------------------------------------
-- Salvage All
-----------------------------------------------------------------------------------------------

function ForgeUI_Inventory:OnSalvageAllBtn(wndHandler, wndControl)
	Event_FireGenericEvent("RequestSalvageAll", tAnchors) -- tAnchors Undefined
end

function ForgeUI_Inventory:OnDragDropSalvage(wndHandler, wndControl, nX, nY, wndSource, strType, iData)
	if strType == "DDBagItem" and self.wndMain:FindChild("SalvageAllBtn"):GetData() then
		self:InvokeSalvageConfirmWindow(iData)
	end
	return false
end

function ForgeUI_Inventory:OnQueryDragDropSalvage(wndHandler, wndControl, nX, nY, wndSource, strType, iData)
	if strType == "DDBagItem" and self.wndMain:FindChild("SalvageAllBtn"):GetData() then
		return Apollo.DragDropQueryResult.Accept
	end
	return Apollo.DragDropQueryResult.Ignore
end

function ForgeUI_Inventory:OnDragDropNotifySalvage(wndHandler, wndControl, bMe) -- TODO: We can probably replace this with a button mouse over state
	-- if bMe and self.wndMain:FindChild("SalvageIcon"):GetData() then
		--self.wndMain:FindChild("SalvageIcon"):SetSprite("CRB_Inventory:InvBtn_SalvageToggleFlyby")
		--self.wndMain:FindChild("TextActionPrompt_Salvage"):Show(true)
	-- elseif self.wndMain:FindChild("SalvageIcon"):GetData() then
		--self.wndMain:FindChild("SalvageIcon"):SetSprite("CRB_Inventory:InvBtn_SalvageTogglePressed")
		--self.wndMain:FindChild("TextActionPrompt_Salvage"):Show(false)
	-- end
end

-----------------------------------------------------------------------------------------------
-- Virtual ForgeUI_Inventory
-----------------------------------------------------------------------------------------------

function ForgeUI_Inventory:OnQuestObjectiveUpdated()
	self:UpdateVirtualItemInventory()
end

function ForgeUI_Inventory:OnChallengeUpdated()
	self:UpdateVirtualItemInventory()
end

function ForgeUI_Inventory:UpdateVirtualItemInventory()
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
		local _, nTop, _, nBottom = self.wndMain:FindChild("VirtualInvToggleBtn"):GetAnchorOffsets()
		self.nVirtualButtonHeight = nBottom - nTop
	end
	if not self.nQuestItemContainerHeight then
		local _, nTop, _, nBottom = self.wndMain:FindChild("VirtualInvContainer"):GetAnchorOffsets()
		self.nQuestItemContainerHeight = nBottom - nTop
	end

	local nLeft, _, nRight, nBottom = self.wndMain:FindChild("BGVirtual"):GetAnchorOffsets()
	local nTop = nBottom
	if bThereAreItems then
		nTop = nBottom - self.nVirtualButtonHeight
		if bShowQuestItems then
			nTop = nTop - self.nQuestItemContainerHeight
		end
	end
	self.wndMain:FindChild("BGVirtual"):SetAnchorOffsets(nLeft, nTop, nRight, nBottom)

	local nBagLeft, nBagTop, nBagRight, _ = self.wndMain:FindChild("GridContainer"):GetAnchorOffsets()
	self.wndMain:FindChild("GridContainer"):SetAnchorOffsets(nBagLeft, nBagTop, nBagRight, nTop)
end

-----------------------------------------------------------------------------------------------
-- Drag and Drop
-----------------------------------------------------------------------------------------------

function ForgeUI_Inventory:OnBagDragDropCancel(wndHandler, wndControl, strType, iData, eReason)
	if strType ~= "DDBagItem" or eReason == Apollo.DragDropCancelReason.EscapeKey or eReason == Apollo.DragDropCancelReason.ClickedOnNothing then
		return false
	end

	if eReason == Apollo.DragDropCancelReason.ClickedOnWorld or eReason == Apollo.DragDropCancelReason.DroppedOnNothing then
		self:InvokeDeleteConfirmWindow(iData)
	end
	return false
end

-- Trash Icon
function ForgeUI_Inventory:OnDragDropTrash(wndHandler, wndControl, nX, nY, wndSource, strType, iData)
	if strType == "DDBagItem" then
		self:InvokeDeleteConfirmWindow(iData)
	end
	return false
end

function ForgeUI_Inventory:OnQueryDragDropTrash(wndHandler, wndControl, nX, nY, wndSource, strType, iData)
	if strType == "DDBagItem" then
		return Apollo.DragDropQueryResult.Accept
	end
	return Apollo.DragDropQueryResult.Ignore
end

function ForgeUI_Inventory:OnDragDropNotifyTrash(wndHandler, wndControl, bMe) -- TODO: We can probably replace this with a button mouse over state
	if bMe then
		--self.wndMain:FindChild("TrashIcon"):SetSprite("CRB_Inventory:InvBtn_TrashToggleFlyby")
		self.wndMain:FindChild("TrashIcon"):SetTextColor("FFFFFFFF")
		self.wndMain:FindChild("TextActionPrompt_Trash"):Show(true)
	else
		--self.wndMain:FindChild("TrashIcon"):SetSprite("CRB_Inventory:InvBtn_TrashTogglePressed")
		self.wndMain:FindChild("TrashIcon"):SetTextColor("FFFF0000")
		self.wndMain:FindChild("TextActionPrompt_Trash"):Show(false)
	end
end
-- End Trash Icon

-- Salvage Icon
function ForgeUI_Inventory:OnDragDropSalvage(wndHandler, wndControl, nX, nY, wndSource, strType, iData)
	if strType == "DDBagItem" and self.wndMain:FindChild("SalvageIcon"):GetData() then
		self:InvokeSalvageConfirmWindow(iData)
	end
	return false
end

function ForgeUI_Inventory:OnQueryDragDropSalvage(wndHandler, wndControl, nX, nY, wndSource, strType, iData)
	if strType == "DDBagItem" and self.wndMain:FindChild("SalvageIcon"):GetData() then
		return Apollo.DragDropQueryResult.Accept
	end
	return Apollo.DragDropQueryResult.Ignore
end

function ForgeUI_Inventory:OnDragDropNotifySalvage(wndHandler, wndControl, bMe) -- TODO: We can probably replace this with a button mouse over state
	if bMe and self.wndMain:FindChild("SalvageIcon"):GetData() then
		self.wndMain:FindChild("TextActionPrompt_Salvage"):Show(true)
	elseif self.wndMain:FindChild("SalvageIcon"):GetData() then
		self.wndMain:FindChild("TextActionPrompt_Salvage"):Show(false)
	end
end
-- End Salvage Icon

function ForgeUI_Inventory:HelperSetSalvageEnable()
	local tInvItems = GameLib.GetPlayerUnit():GetInventoryItems()
	for idx, tItem in ipairs(tInvItems) do
		if tItem and tItem.itemInBag and tItem.itemInBag:CanSalvage() and not tItem.itemInBag:CanAutoSalvage() then
			self.wndSalvageAllBtn:Enable(true)
			return
		end
	end
	self.wndSalvageAllBtn:Enable(false)
end


function ForgeUI_Inventory:OnUpdateInventory()
	if not self.wndMain or not self.wndMain:IsValid() or not self.wndMain:IsShown() then
		return
	end

	local tParams = {false, nil, self.wndMainBagWindow:GetTotalEmptyBagSlots()}
	Event_FireGenericEvent("InterfaceMenuList_AlertAddOn", Apollo.GetString("InterfaceMenu_Inventory"), tParams)

	self:HelperSetSalvageEnable()
end

function ForgeUI_Inventory:OnSystemBeginDragDrop(wndSource, strType, iData)
	if strType ~= "DDBagItem" then return end
	self.wndMain:FindChild("TextActionPrompt_Trash"):Show(false)
	self.wndMain:FindChild("TextActionPrompt_Salvage"):Show(false)

	--self.wndMain:FindChild("TrashIcon"):SetSprite("CRB_Inventory:InvBtn_TrashTogglePressed")

	local item = self.wndMain:FindChild("MainBagWindow"):GetItem(iData)
	if item and item:CanSalvage() then
		self.wndMain:FindChild("SalvageIcon"):SetData(true)
		self.wndSalvageAllBtn:Enable(true)
	else
		self.wndSalvageAllBtn:Enable(false)
	end

	Sound.Play(Sound.PlayUI45LiftVirtual)
end

function ForgeUI_Inventory:OnSystemEndDragDrop(strType, iData)
	if not self.wndMain or not self.wndMain:IsValid() or not self.wndMain:FindChild("TrashIcon") or strType == "DDGuildBankItem" or strType == "DDWarPartyBankItem" or strType == "DDGuildBankItemSplitStack" then
		return -- TODO Investigate if there are other types
	end

	--self.wndMain:FindChild("TrashIcon"):SetSprite("CRB_Inventory:InvBtn_TrashToggleNormal")
	self.wndMain:FindChild("SalvageIcon"):SetData(false)
	self.wndMain:FindChild("TextActionPrompt_Trash"):Show(false)
	self.wndMain:FindChild("TextActionPrompt_Salvage"):Show(false)
	self:HelperSetSalvageEnable()
	self:UpdateSquareSize()
	Sound.Play(Sound.PlayUI46PlaceVirtual)
end

function ForgeUI_Inventory:OnEquippedItem(eSlot, itemNew, itemOld)
	if itemNew then
		itemNew:PlayEquipSound()
	else
		itemOld:PlayEquipSound()
	end
end

-----------------------------------------------------------------------------------------------
-- Item Sorting
-----------------------------------------------------------------------------------------------

function ForgeUI_Inventory:OnOptionsSortItemsOff(wndHandler, wndControl)
	self._DB.global.bShouldSortItems = false
	self.wndMainBagWindow:SetSort(self._DB.global.bShouldSortItems)
	self.wndIconBtnSortDropDown:SetCheck(false)
end

function ForgeUI_Inventory:OnOptionsSortItemsName(wndHandler, wndControl)
	self._DB.global.bShouldSortItems = true
	self._DB.global.nSortItemType = 1
	self.wndMainBagWindow:SetSort(self._DB.global.bShouldSortItems)
	self.wndMainBagWindow:SetItemSortComparer(ktSortFunctions[self._DB.global.nSortItemType])
	self.wndIconBtnSortDropDown:SetCheck(false)
end

function ForgeUI_Inventory:OnOptionsSortItemsByCategory(wndHandler, wndControl)
	self._DB.global.bShouldSortItems = true
	self._DB.global.nSortItemType = 2
	self.wndMainBagWindow:SetSort(self._DB.global.bShouldSortItems)
	self.wndMainBagWindow:SetItemSortComparer(ktSortFunctions[self._DB.global.nSortItemType])
	self.wndIconBtnSortDropDown:SetCheck(false)
end

function ForgeUI_Inventory:OnOptionsSortItemsByQuality(wndHandler, wndControl)
	self._DB.global.bShouldSortItems = true
	self._DB.global.nSortItemType = 3
	self.wndMainBagWindow:SetSort(self._DB.global.bShouldSortItems)
	self.wndMainBagWindow:SetItemSortComparer(ktSortFunctions[self._DB.global.nSortItemType])
	self.wndIconBtnSortDropDown:SetCheck(false)
end

-----------------------------------------------------------------------------------------------
-- Delete/Salvage Screen
-----------------------------------------------------------------------------------------------

function ForgeUI_Inventory:InvokeDeleteConfirmWindow(iData)
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

function ForgeUI_Inventory:InvokeSalvageConfirmWindow(iData)
	self.wndSalvageConfirm:SetData(iData)
	self.wndSalvageConfirm:Show(true)
	self.wndSalvageConfirm:ToFront()
	self.wndSalvageConfirm:FindChild("SalvageBtn"):SetActionData(GameLib.CodeEnumConfirmButtonType.SalvageItem, iData)
	self.wndMain:FindChild("DragDropMouseBlocker"):Show(true)
	Sound.Play(Sound.PlayUI55ErrorVirtual)
end

-- TODO SECURITY: These confirmations are entirely a UI concept. Code should have a allow/disallow.
function ForgeUI_Inventory:OnDeleteCancel()
	self.wndDeleteConfirm:SetData(nil)
	self.wndDeleteConfirm:Close()
	self.wndMain:FindChild("DragDropMouseBlocker"):Show(false)
end

function ForgeUI_Inventory:OnSalvageCancel()
	self.wndSalvageConfirm:SetData(nil)
	self.wndSalvageConfirm:Close()
	self.wndMain:FindChild("DragDropMouseBlocker"):Show(false)
end

function ForgeUI_Inventory:OnDeleteConfirm()
	self:OnDeleteCancel()
end

function ForgeUI_Inventory:OnSalvageConfirm()
	self:OnSalvageCancel()
end

-----------------------------------------------------------------------------------------------
-- Stack Splitting
-----------------------------------------------------------------------------------------------

function ForgeUI_Inventory:OnGenericEvent_SplitItemStack(item)
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

function ForgeUI_Inventory:OnSplitStackCloseClick()
	self.wndSplit:Show(false)
end

function ForgeUI_Inventory:OnSpinnerChanged()
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

function ForgeUI_Inventory:OnSplitStackConfirm(wndHandler, wndCtrl)
	self.wndSplit:Close()
	self.wndMain:FindChild("MainBagWindow"):StartSplitStack(self.wndSplit:GetData(), self.wndSplit:FindChild("SplitValue"):GetValue())
end

function ForgeUI_Inventory:OnGenerateTooltip(wndControl, wndHandler, tType, item)
	if wndControl ~= wndHandler then return end
	wndControl:SetTooltipDoc(nil)
	if item ~= nil then
		local itemEquipped = item:GetEquippedItemForItemType()
		Tooltip.GetItemTooltipForm(self, wndControl, item, {bPrimary = true, bSelling = false, itemCompare = itemEquipped})
		-- Tooltip.GetItemTooltipForm(self, wndControl, itemEquipped, {bPrimary = false, bSelling = false, itemCompare = item})
	end
end

F:API_NewAddon(ForgeUI_Inventory)
