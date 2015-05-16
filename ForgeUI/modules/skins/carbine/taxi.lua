-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		taxi.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI skin for Carbine's Taxi addon
-----------------------------------------------------------------------------------------------

local ForgeUI = ForgeUI
local Skins = ForgeUI:API_GetModule("skins")

local Addon

local fnOnDocumentReady
local fnOnDocumentReadyOrig

local function LoadSkin()
	Addon = Apollo.GetAddon('TaxiMap')
	
	fnOnDocumentReadyOrig = Addon.OnDocumentReady
	Addon.OnDocumentReady = fnOnDocumentReady
end

fnOnDocumentReady = function()
	fnOnDocumentReadyOrig(Addon)
	
	Addon.wndMain:SetSprite("ForgeUI_Border")
	Addon.wndMain:SetBGColor("FF000000")
	Addon.wndMain:SetStyle("Picture", true)
	Addon.wndMain:SetStyle("Border", true)
	
	Addon.wndMain:FindChild("MainFrame"):SetStyle("Border", false)
	
	-- workaround for carbin's stupid name system
	Addon.wndMain:FindChild("Title"):SetName("TitleOuter")
	Addon.wndMain:FindChild("Title"):SetTextColor("FFFFFFFF")
	Addon.wndMain:FindChild("TitleOuter"):SetName("Title")
	
	Addon.wndMain:FindChild("Title"):SetSprite("ForgeUI_InnerWindow")
	Addon.wndMain:FindChild("Title"):SetStyle("Picture", true)
	Addon.wndMain:FindChild("Title"):SetBGColor("FFFFFFFF")
	Addon.wndMain:FindChild("Title"):SetAnchorOffsets(-200, 5, 200, 40)
	
	Addon.wndMain:FindChild("MetalFooter"):SetSprite("ForgeUI_InnerWindow")
	Addon.wndMain:FindChild("MetalFooter"):SetStyle("Picture", true)
	Addon.wndMain:FindChild("MetalFooter"):SetBGColor("FFFFFFFF")
	Addon.wndMain:FindChild("MetalFooter"):SetAnchorOffsets(5, -40, -5, -5)
	
	Addon.wndMain:FindChild("BGArt"):SetSprite("ForgeUI_InnerWindow")
	Addon.wndMain:FindChild("BGArt"):SetStyle("Picture", true)
	Addon.wndMain:FindChild("BGArt"):SetBGColor("FFFFFFFF")
	Addon.wndMain:FindChild("BGArt"):SetAnchorOffsets(5, 45, -5, -45)
	
	Addon.wndMain:FindChild("BG_Backer"):Show(false)
	
	Addon.wndMain:FindChild("MapContainer"):SetAnchorOffsets(1, 1, -1, -1)
	
	Addon.wndMain:FindChild("CancelButton"):ChangeArt("ForgeUI_Button")
	Addon.wndMain:FindChild("CancelButton"):SetAnchorOffsets(-175, -30, -5, -5)
	
	Skins:HandleCloseButton(Addon.wndMain:FindChild("CloseButton"))
end

Skins:NewCarbineSkin("TaxiMap", LoadSkin)

