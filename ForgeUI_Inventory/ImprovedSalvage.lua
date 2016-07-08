require "Window"
require "Apollo"
require "ApolloCursor"
require "GameLib"
require "Item"

local ImprovedSalvage = {}

local kidBackpack = 0

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

function ImprovedSalvage:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.bSortByQuality = true
	o.nStartIndex = 1
	o.bFirst = true

	return o
end

function ImprovedSalvage:OnSave(eType)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return
	end

	local tSavedData =
	{
		bSortByQuality = self.bSortByQuality
	}

	return tSavedData
end

function ImprovedSalvage:OnRestore(eType, tSavedData)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return
	end

	if tSavedData.bSortByQuality ~= nil then
		self.bSortByQuality = tSavedData.bSortByQuality
	end
end

function ImprovedSalvage:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("ImprovedSalvage.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self) 
end

function ImprovedSalvage:OnDocumentReady()
	if self.xmlDoc == nil then
		return
	end
	
	Apollo.RegisterEventHandler("RequestSalvageAll", "OnSalvageAll", self) -- using this for bag changes
	Apollo.RegisterSlashCommand("salvageall", "OnSalvageAll", self)

	self.wndMain = Apollo.LoadForm(self.xmlDoc, "ImprovedSalvageForm", nil, self)
	
	if self.locSavedWindowLoc then
		self.wndMain:MoveToLocation(self.locSavedWindowLoc)
	end
	
	self.tContents = self.wndMain:FindChild("HiddenBagWindow")
	self.arItemList = nil
	self.tSelection = { nIndex = nil, nBagPos = nil}

	self.wndMain:Show(false, true)

	Apollo.RegisterEventHandler("WindowManagementReady", "OnWindowManagementReady", self)
	self:OnWindowManagementReady()
end

function ImprovedSalvage:OnWindowManagementReady()
	Event_FireGenericEvent("WindowManagementRegister", {strName = Apollo.GetString("CRB_Salvage")})
	Event_FireGenericEvent("WindowManagementAdd", {wnd = self.wndMain, strName = Apollo.GetString("CRB_Salvage")})
end

--------------------//-----------------------------
function ImprovedSalvage:OnSalvageAll()
	self.arItemList = {}
	self.tSelection = { nIndex = self.nStartIndex, nBagPos = self.nStartIndex}
	
	local tInvItems = GameLib.GetPlayerUnit():GetInventoryItems()
	for idx, tItem in ipairs(tInvItems) do
		if tItem and tItem.itemInBag and tItem.itemInBag:CanSalvage() and not tItem.itemInBag:CanAutoSalvage() then
			table.insert(self.arItemList, tItem.itemInBag)
		end
	end

	self.wndMain:FindChild("SortQualityBtn"):SetCheck(self.bSortByQuality)
	self:RedrawAll()
end

function ImprovedSalvage:OnSalvageListItemCheck(wndHandler, wndControl)
	if not wndHandler or not wndHandler:GetData() then
		return
	end
	local tData = wndHandler:GetData()
	local itemCurr = self.arItemList[tData.nBagPos]
	self.tSelection = { nIndex = tData.nIdx, nBagPos = tData.nBagPos}
	self.wndMain:SetData(itemCurr)
	self.wndMain:FindChild("SalvageBtn"):SetActionData(GameLib.CodeEnumConfirmButtonType.SalvageItem, itemCurr:GetInventoryId())
end

function ImprovedSalvage:OnSortQualityCheck()
	self.bSortByQuality = self.wndMain:FindChild("SortQualityBtn"):IsChecked()
	self:SortItems()
end

function ImprovedSalvage:OnSalvageListItemGenerateTooltip(wndControl, wndHandler) -- wndHandler is VendorListItemIcon
	if wndHandler ~= wndControl then
		return
	end

	wndControl:SetTooltipDoc(nil)

	local tListItem = wndHandler:GetData().tItem
	local tPrimaryTooltipOpts = {}

	tPrimaryTooltipOpts.bPrimary = true
	tPrimaryTooltipOpts.itemModData = tListItem.itemModData
	tPrimaryTooltipOpts.strMaker = tListItem.strMaker
	tPrimaryTooltipOpts.arGlyphIds = tListItem.arGlyphIds
	tPrimaryTooltipOpts.tGlyphData = tListItem.itemGlyphData
	tPrimaryTooltipOpts.itemCompare = tListItem:GetEquippedItemForItemType()

	if Tooltip ~= nil and Tooltip.GetSpellTooltipForm ~= nil then
		Tooltip.GetItemTooltipForm(self, wndControl, tListItem, tPrimaryTooltipOpts, tListItem.nStackSize)
	end
end

function ImprovedSalvage:RedrawAll()
	if #self.arItemList > 0 then
		local wndParent = self.wndMain:FindChild("MainScroll")
		local nScrollPos = wndParent:GetVScrollPos()
		wndParent:DestroyChildren()
		
		for idx, tItem in ipairs(self.arItemList) do
			local wndCurr = Apollo.LoadForm(self.xmlDoc, "SalvageListItem", wndParent, self)
			wndCurr:FindChild("SalvageListItemBtn"):SetData({nIdx = nil, tItem = tItem, nBagPos = idx})
			
			wndCurr:FindChild("SalvageListItemTitle"):SetTextColor(karEvalColors[tItem:GetItemQuality()])
			wndCurr:FindChild("SalvageListItemTitle"):SetText(tItem:GetName())
			
			local bTextColorRed = self:HelperPrereqFailed(tItem)
			wndCurr:FindChild("SalvageListItemType"):SetTextColor(bTextColorRed and "Reddish" or "UI_TextHoloBodyCyan")
			wndCurr:FindChild("SalvageListItemType"):SetText(tItem:GetItemTypeName())
			
			wndCurr:FindChild("SalvageListItemCantUse"):Show(bTextColorRed)
			wndCurr:FindChild("SalvageListItemIcon"):GetWindowSubclass():SetItem(tItem)
		end
		
		self:SortItems()
		wndParent:SetVScrollPos(nScrollPos)
	
		self.wndMain:Show(true)
		self.wndMain:ToFront()
	else
		self.wndMain:Show(false)
	end
	
end

function ImprovedSalvage:SortItems()
	local wndParent = self.wndMain:FindChild("MainScroll")
	local fnSort = nil
	
	if self.bSortByQuality then
		fnSort = function(wndCon1, wndCon2)
			local wndItem1 = wndCon1:FindChild("SalvageListItemBtn")
			local wndItem2 = wndCon2:FindChild("SalvageListItemBtn")
			if wndItem1:GetData().tItem:GetItemQuality() == wndItem2:GetData().tItem:GetItemQuality() then
				return wndCon1:FindChild("SalvageListItemTitle"):GetText() < wndCon2:FindChild("SalvageListItemTitle"):GetText()
			else
				return wndItem1:GetData().tItem:GetItemQuality() < wndItem2:GetData().tItem:GetItemQuality()
			end
		end
	else
		fnSort = function(wndCon1, wndCon2)
			return wndCon1:FindChild("SalvageListItemBtn"):GetData().nBagPos < wndCon2:FindChild("SalvageListItemBtn"):GetData().nBagPos
		end
	end
	
	wndParent:ArrangeChildrenVert(Window.CodeEnumArrangeOrigin.LeftOrTop, fnSort)
	
	local bNotFound = true
	for idx, wndCurr in ipairs(wndParent:GetChildren()) do
		local wndCurrBtn = wndCurr:FindChild("SalvageListItemBtn")
		local tBtnData = wndCurrBtn:GetData()
		wndCurrBtn:SetData({nIdx = idx, tItem = tBtnData.tItem, nBagPos = tBtnData.nBagPos})
		local bSelected = self.bFirst
		if self.bSalvaged and idx ~= self.tSelection.nIndex then
			bSelected = false
		else
			bSelected = bSelected or (self.bSalvaged and idx == self.tSelection.nIndex)
			bSelected = bSelected or (not self.bSortByQuality and idx == self.tSelection.nBagPos) or (self.bSortByQuality and tBtnData.nBagPos == self.tSelection.nIndex)
		end
		wndCurrBtn:SetCheck(bSelected and bNotFound)
		if bSelected and bNotFound then
			self.tSelection.nBagPos = tBtnData.nBagPos
			self.tSelection.nIndex = idx
			bNotFound = false
			self.bFirst = false
			self.bSalvaged = false
		end
	end
	
	local itemCurr = self.arItemList[self.tSelection.nBagPos]
	if itemCurr then
		self.wndMain:SetData(itemCurr)
		self.wndMain:FindChild("SalvageBtn"):SetActionData(GameLib.CodeEnumConfirmButtonType.SalvageItem, itemCurr:GetInventoryId())
	end
end

function ImprovedSalvage:HelperPrereqFailed(tCurrItem)
	return tCurrItem and tCurrItem:IsEquippable() and not tCurrItem:CanEquip()
end

function ImprovedSalvage:OnSalvageCurr()
	Event_ShowTutorial(GameLib.CodeEnumTutorial.CharacterWindow)
	if self.tSelection.nIndex == #self.arItemList then 
		table.remove(self.arItemList, self.tSelection.nBagPos )
		self.tSelection.nIndex = self.tSelection.nIndex - 1
	else
		table.remove(self.arItemList, self.tSelection.nBagPos )
	end
	self.bSalvaged = true
	self:RedrawAll()
end

function ImprovedSalvage:OnCloseBtn()
	self.arItemList = {}
	self.wndMain:SetData(nil)
	self.wndMain:Show(false)
	self.nStartIndex = self.bSortByQuality and self.tSelection.nBagPos or self.tSelection.nIndex
end

----------------globals----------------------------

local ImprovedSalvage_Singleton = ImprovedSalvage:new()
Apollo.RegisterAddon(ImprovedSalvage_Singleton)
