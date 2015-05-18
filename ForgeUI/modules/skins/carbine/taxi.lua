-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		taxi.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI skin for Carbine's Taxi addon
-----------------------------------------------------------------------------------------------

local F, A, M, G, P = unpack(_G["ForgeLibs"]) -- imports ForgeUI, Addon, Module, GUI, Profiles
local Hook = Apollo.GetPackage("Gemini:Hook-1.0").tPackage
local Skins = F:API_GetModule("skins")

local fnUseSkin

local function LoadSkin()
	local addon = Apollo.GetAddon("TaxiMap")
	
	Hook:PostHook(addon, "OnDocumentReady", function()
		fnUseSkin(addon)
	end)
	
	if addon.xmlDoc and addon.xmlDoc:IsLoaded() then
		fnUseSkin(addon)
	end
end

fnUseSkin = function(addon)
	if not addon.wndMain then return end
	
	Skins:HandleFrame(addon.wndMain)
	
	addon.wndMain:FindChild("MainFrame"):SetStyle("Border", false)
	
	-- workaround for carbin's stupid name system
	addon.wndMain:FindChild("Title"):SetName("TitleOuter")
	addon.wndMain:FindChild("Title"):SetTextColor("FFFF0000")
	addon.wndMain:FindChild("TitleOuter"):SetName("Title")
	
	Skins:HandleTitle(addon.wndMain:FindChild("Title"))
	
	Skins:HandleFooter(addon.wndMain:FindChild("MetalFooter"))
	
	addon.wndMain:FindChild("BGArt"):SetSprite("ForgeUI_InnerWindow")
	addon.wndMain:FindChild("BGArt"):SetStyle("Picture", true)
	addon.wndMain:FindChild("BGArt"):SetBGColor("FFFFFFFF")
	addon.wndMain:FindChild("BGArt"):SetAnchorOffsets(5, 45, -5, -45)
	
	addon.wndMain:FindChild("BG_Backer"):Show(false)
	
	addon.wndMain:FindChild("MapContainer"):SetAnchorOffsets(1, 1, -1, -1)
	
	Skins:HandleButton(addon.wndMain:FindChild("CancelButton"))
	addon.wndMain:FindChild("CancelButton"):SetAnchorOffsets(-175, -30, -5, -5)
	
	Skins:HandleCloseButton(addon.wndMain:FindChild("CloseButton"))	
end

Skins:NewCarbineSkin("TaxiMap", LoadSkin)

