-----------------------------------------------------------------------------------------------
-- Client Lua Script for ItemPreview
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Window"
require "GameLib"
require "Item"

local ItemPreview = {}

local ktValidItemPreviewSlots =
{
	2,
	3,
	0,
	5,
	1,
	4,
	16
}

local knSaveVersion = nil

function ItemPreview:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function ItemPreview:Init()
    Apollo.RegisterAddon(self)
end

function ItemPreview:OnSave(eType)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Account then
		return
	end

	local locWindowLocation = self.wndMain and self.wndMain:GetLocation() or self.locSavedWindowLoc

	local tSaved =
	{
		tWindowLocation = locWindowLocation and locWindowLocation:ToTable() or nil,
		nSaveVersion = knSaveVersion
	}

	return tSaved
end

function ItemPreview:OnRestore(eType, tSavedData)
	if not tSavedData or tSavedData.nSaveVersion ~= knSaveVersion then
		return
	end

	if tSavedData.tWindowLocation then
		self.locSavedWindowLoc = WindowLocation.new(tSavedData.tWindowLocation)
	end
end

function ItemPreview:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("ItemPreview.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self)
end

function ItemPreview:OnDocumentReady()
	if self.xmlDoc == nil then
		return
	end

	Apollo.RegisterEventHandler("GenericEvent_LoadItemPreview", "OnGenericEvent_LoadItemPreview", self)
	self.bSheathed = false
end

function ItemPreview:OnGenericEvent_LoadItemPreview(item)
	if item == nil then
		return
	end

	if not self.wndMain or not self.wndMain:IsValid() then
		self.wndMain = Apollo.LoadForm(self.xmlDoc, "ItemPreviewForm", "TooltipStratum", self)
		self.wndMain:FindChild("PreviewWindow"):SetCostume(GameLib.GetPlayerUnit())
	
		local nWndLeft, nWndTop, nWndRight, nWndBottom = self.wndMain:GetRect()
		local nWndWidth = nWndRight - nWndLeft
		local nWndHeight = nWndBottom - nWndTop
		self.wndMain:SetSizingMinimum(nWndWidth - 10, nWndHeight - 10)

		if self.locSavedWindowLoc then
			self.wndMain:MoveToLocation(self.locSavedWindowLoc)
		end
	end

	self.wndMain:FindChild("PreviewWindow"):SetItem(item)

	self.wndMain:FindChild("ItemLabel"):SetText(item:GetName())

	-- set sheathed or not
	local eItemType = item:GetItemType()
	self.bSheathed = eItemType == Item.CodeEnumItemType.WeaponMHEnergy or not self:HelperCheckForWeapon(eItemType)

	self.wndMain:FindChild("PreviewWindow"):SetSheathed(self.bSheathed)
	self:HelperFormatSheathButton(self.bSheathed)
	self.wndMain:FindChild("SheathButton"):Enable(eItemType ~= Item.CodeEnumItemType.WeaponMHEnergy) -- Psyblades can't be unsheathed

	self.wndMain:Show(true)
end

function ItemPreview:HelperCheckForWeapon(eItemType)
	return eItemType >= Item.CodeEnumItemType.WeaponMHPistols and eItemType <= Item.CodeEnumItemType.WeaponMHSword
end

function ItemPreview:HelperFormatSheathButton(bSheathed)
	self.wndMain:FindChild("SheathButton"):SetText(bSheathed and Apollo.GetString("Inventory_DrawWeapons") or Apollo.GetString("Inventory_Sheathe"))
end

function ItemPreview:OnWindowClosed( wndHandler, wndControl )
	if self.wndMain ~= nil then
		self.locSavedWindowLoc = self.wndMain:GetLocation()
		self.wndMain:Destroy()
		self.wndMain = nil
	end
end

function ItemPreview:OnCloseBtn( wndHandler, wndControl, eMouseButton )
	self:OnWindowClosed()
end

function ItemPreview:OnToggleSheathButton( wndHandler, wndControl, eMouseButton )
	self.wndMain:FindChild("PreviewWindow"):SetSheathed(wndControl:IsChecked())
end

function ItemPreview:OnToggleSheathed( wndHandler, wndControl, eMouseButton )
	local bSheathed = not self.bSheathed
	self.wndMain:FindChild("PreviewWindow"):SetSheathed(bSheathed)
	self:HelperFormatSheathButton(bSheathed)

	self.bSheathed = bSheathed
end

-- Spin Code

function ItemPreview:OnRotateRight()
	self.wndMain:FindChild("PreviewWindow"):ToggleLeftSpin(true)
end

function ItemPreview:OnRotateRightCancel()
	self.wndMain:FindChild("PreviewWindow"):ToggleLeftSpin(false)
end

function ItemPreview:OnRotateLeft()
	self.wndMain:FindChild("PreviewWindow"):ToggleRightSpin(true)
end

function ItemPreview:OnRotateLeftCancel()
	self.wndMain:FindChild("PreviewWindow"):ToggleRightSpin(false)
end

local ItemPreviewInst = ItemPreview:new()
ItemPreviewInst:Init()
