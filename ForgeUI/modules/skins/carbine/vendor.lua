-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		taxi.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI skin for Carbine's Vendor addon
-----------------------------------------------------------------------------------------------

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI
local Skins = F:API_GetModule("skins")

local Addon

local fnUseSkin

local fnOnDocumentReady
local fnOnDocumentReadyOrig

local fnOnGuildChange
local fnOnGuildChangeOrig

local fnDrawHeaderAndItems
local fnDrawHeaderAndItemsOrig

local fnDrawListItem
local fnDrawListItemOrig

local function LoadSkin()
	Addon = Apollo.GetAddon("Vendor")
	
	if Addon.xmlDoc and Addon.xmlDoc:IsLoaded() then
		fnUseSkin(Addon)
	end
	
	fnOnDocumentReadyOrig = Addon.OnDocumentReady
	Addon.OnDocumentReady = fnOnDocumentReady
	
	fnOnGuildChangeOrig = Addon.OnGuildChange
	Addon.OnGuildChange = fnOnGuildChange
	
	fnDrawHeaderAndItemsOrig = Addon.DrawHeaderAndItems
	Addon.DrawHeaderAndItems = fnDrawHeaderAndItems
	
	fnDrawListItemOrig = Addon.DrawListItem
	Addon.DrawListItem = fnDrawListItem
end

fnOnDocumentReady = function(self, ...)
	fnOnDocumentReadyOrig(self, ...)
	
	fnUseSkin(self, ...)
end

fnUseSkin = function(self, ...)
	if not self.wndVendor then return end

	local wndVendor = self.wndVendor
	
	wndVendor:SetSprite("ForgeUI_Border")
	wndVendor:SetBGColor("FF000000")
	wndVendor:SetStyle("Picture", true)
	wndVendor:SetStyle("Border", true)
	
	wndVendor:FindChild("BGFrame"):Show(false)
	
	wndVendor:FindChild("VendorName"):SetSprite("ForgeUI_InnerWindow")
	wndVendor:FindChild("VendorName"):SetStyle("Picture", true)
	wndVendor:FindChild("VendorName"):SetBGColor("FFFFFFFF")
	wndVendor:FindChild("VendorName"):SetTextColor("FFFF0000") -- TODO: Replace with variable from settings
	wndVendor:FindChild("VendorName"):SetAnchorPoints(0.5, 0, 0.5, 0)
	wndVendor:FindChild("VendorName"):SetAnchorOffsets(-200, 5, 200, 40)
	
	wndVendor:FindChild("VendorTabContainer"):SetSprite("ForgeUI_InnerWindow")
	wndVendor:FindChild("VendorTabContainer"):SetAnchorOffsets(5, 45, -5, 80)
	wndVendor:FindChild("VendorTabContainer"):SetStyle("Picture", true)
	for k, v in pairs(wndVendor:FindChild("VendorTabContainer"):GetChildren()) do
		Skins:HandleButton(v)
	end
	
	wndVendor:FindChild("VendorPortrait"):Show(false)
	
	wndVendor:FindChild("LeftSideContainer"):SetAnchorOffsets(5, 85, -5, -60)
	wndVendor:FindChild("LeftSideContainer"):SetStyle("Border", false)
	wndVendor:FindChild("LeftSideContainer"):SetSprite("ForgeUI_InnerWindow")
	
	wndVendor:FindChild("ItemsList"):SetStyle("Border", false)
	
	wndVendor:FindChild("BottomContainer"):SetAnchorOffsets(5, -55, -5, -5)
	wndVendor:FindChild("BottomContainer"):SetSprite("ForgeUI_InnerWindow")
	
	wndVendor:FindChild("BottomInfoInnerBG"):SetAnchorOffsets(5, -45, 435, -5)
	
	wndVendor:FindChild("CashBagFrame"):SetSprite("ForgeUI_InnerWindow")
	
	wndVendor:FindChild("Buy"):SetAnchorOffsets(-175, -45, -5, -5)
	Skins:HandleButton(wndVendor:FindChild("Buy"))
	
	wndVendor:FindChild("AmountValue"):SetAnchorOffsets(350, -40, 428, -8)
	
	wndVendor:FindChild("AmountBlocker"):SetAnchorOffsets(355, -45, 430, -5)
	
	wndVendor:FindChild("AmountFrame"):SetSprite("ForgeUI_InnerWindow")
	
	Skins:HandleCloseButton(wndVendor:FindChild("CloseBtn"))
	
	Skins:CoverVScrollWindow(self.wndVendor:FindChild("LeftSideContainer"), self.wndVendor:FindChild("ItemsList"))
	self.OnVScrollMouseWheel = G.OnVScrollMouseWheel
end

fnOnGuildChange = function(self, ...)
	fnOnGuildChangeOrig(self, ...)
	
	if not self.wndVendor then return end

	local wndVendor = self.wndVendor
	
	wndVendor:FindChild("LeftSideContainer"):SetAnchorOffsets(5, 85, -5, -60)
	wndVendor:FindChild("BottomContainer"):SetAnchorOffsets(5, -55, -5, -5)
	
	wndVendor:FindChild("AmountBlocker"):Show(false)
end

fnDrawHeaderAndItems = function(self, tVendorList, bChanged)
	fnDrawHeaderAndItemsOrig(self, tVendorList, bChanged)
	
	for idHeader, tHeaderValue in pairs(tVendorList) do
		local wndCurr = self:FactoryCacheProduce(self.wndItemContainer, "VendorHeaderItem", "H"..idHeader)
		
		wndCurr:FindChild("CatFraming"):SetSprite("ForgeUI_InnerWindow")
		--Skins:HandleButton(wndCurr:FindChild("VendorHeaderBtn"))
		wndCurr:FindChild("VendorHeaderName"):SetTextColor("FFFFFFFF")
	end
end

fnDrawListItem = function(self, wndCurr, tCurrItem)
	fnDrawListItemOrig(self, wndCurr, tCurrItem)

	wndCurr:FindChild("VendorListItemBtn"):SetAnchorOffsets(0, 2, -2, 0)
	Skins:HandleButton(wndCurr:FindChild("VendorListItemBtn"))
	
	wndCurr:FindChild("VendorListItemIconBG"):SetSprite("ForgeUI_InnerWindow")
end

Skins:NewCarbineSkin("Vendor", LoadSkin)

