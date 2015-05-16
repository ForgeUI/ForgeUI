-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		taxi.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI skin for Carbine's Taxi addon
-----------------------------------------------------------------------------------------------

local F, A, M, G = unpack(_G["ForgeLibs"]) -- imports ForgeUI, Addon, Module, GUI
local Skins = F:API_GetModule("skins")

local Addon

local fnUseSkin

local fnOnDocumentReady
local fnOnDocumentReadyOrig

local function LoadSkin()
	Addon = Apollo.GetAddon("TaxiMap")
	
	if Addon.xmlDoc:IsLoaded() then
		fnUseSkin(Addon)
	end
	
	fnOnDocumentReadyOrig = Addon.OnDocumentReady
	Addon.OnDocumentReady = fnOnDocumentReady
end

fnOnDocumentReady = function()
	fnOnDocumentReadyOrig(Addon)
	
	fnUseSkin(Addon)
end

fnUseSkin = function(addon)
	if not addon.wndMain then return end

	addon.wndMain:SetSprite("ForgeUI_Border")
	addon.wndMain:SetBGColor("FF000000")
	addon.wndMain:SetStyle("Picture", true)
	addon.wndMain:SetStyle("Border", true)
	
	addon.wndMain:FindChild("MainFrame"):SetStyle("Border", false)
	
	-- workaround for carbin's stupid name system
	addon.wndMain:FindChild("Title"):SetName("TitleOuter")
	addon.wndMain:FindChild("Title"):SetTextColor("FFFFFFFF")
	addon.wndMain:FindChild("TitleOuter"):SetName("Title")
	
	addon.wndMain:FindChild("Title"):SetSprite("ForgeUI_InnerWindow")
	addon.wndMain:FindChild("Title"):SetStyle("Picture", true)
	addon.wndMain:FindChild("Title"):SetBGColor("FFFF0000") -- TODO: Replace with variable from settings
	addon.wndMain:FindChild("Title"):SetAnchorOffsets(-200, 5, 200, 40)
	
	addon.wndMain:FindChild("MetalFooter"):SetSprite("ForgeUI_InnerWindow")
	addon.wndMain:FindChild("MetalFooter"):SetStyle("Picture", true)
	addon.wndMain:FindChild("MetalFooter"):SetBGColor("FFFFFFFF")
	addon.wndMain:FindChild("MetalFooter"):SetAnchorOffsets(5, -40, -5, -5)
	
	addon.wndMain:FindChild("BGArt"):SetSprite("ForgeUI_InnerWindow")
	addon.wndMain:FindChild("BGArt"):SetStyle("Picture", true)
	addon.wndMain:FindChild("BGArt"):SetBGColor("FFFFFFFF")
	addon.wndMain:FindChild("BGArt"):SetAnchorOffsets(5, 45, -5, -45)
	
	addon.wndMain:FindChild("BG_Backer"):Show(false)
	
	addon.wndMain:FindChild("MapContainer"):SetAnchorOffsets(1, 1, -1, -1)
	
	addon.wndMain:FindChild("CancelButton"):ChangeArt("ForgeUI_Button")
	addon.wndMain:FindChild("CancelButton"):SetAnchorOffsets(-175, -30, -5, -5)
	
	Skins:HandleCloseButton(addon.wndMain:FindChild("CloseButton"))
end

Skins:NewCarbineSkin("TaxiMap", LoadSkin)

