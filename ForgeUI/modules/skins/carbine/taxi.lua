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
	
	Hook:PostHook(addon, "OnDocumentReady", fnUseSkin)
	
	if addon.xmlDoc and addon.xmlDoc:IsLoaded() then
		fnUseSkin(addon)
	end
end

fnUseSkin = function(luaCaller)
	if not luaCaller.wndMain then return end
	
	Skins:HandleFrame(luaCaller.wndMain)
	
	luaCaller.wndMain:FindChild("MainFrame"):SetStyle("Border", false)
	
	-- workaround for carbin's stupid name system
	luaCaller.wndMain:FindChild("Title"):SetName("TitleOuter")
	luaCaller.wndMain:FindChild("Title"):SetTextColor("FFFF0000")
	luaCaller.wndMain:FindChild("Title"):SetFont("Nameplates")
	luaCaller.wndMain:FindChild("TitleOuter"):SetName("Title")
	
	Skins:HandleTitle(luaCaller.wndMain:FindChild("Title"))
	
	Skins:HandleFooter(luaCaller.wndMain:FindChild("MetalFooter"))
	
	luaCaller.wndMain:FindChild("BGArt"):SetSprite("ForgeUI_InnerWindow")
	luaCaller.wndMain:FindChild("BGArt"):SetStyle("Picture", true)
	luaCaller.wndMain:FindChild("BGArt"):SetBGColor("FFFFFFFF")
	luaCaller.wndMain:FindChild("BGArt"):SetAnchorOffsets(5, 30, -5, -35)
	
	luaCaller.wndMain:FindChild("BG_Backer"):Show(false)
	
	luaCaller.wndMain:FindChild("MapContainer"):SetAnchorOffsets(1, 1, -1, -1)
	
	Skins:HandleButton(luaCaller.wndMain:FindChild("CancelButton"))
	luaCaller.wndMain:FindChild("CancelButton"):SetAnchorOffsets(-100, -25, 0, 0)
	
	Skins:HandleCloseButton(luaCaller.wndMain:FindChild("CloseButton"))	
end

Skins:NewCarbineSkin("TaxiMap", LoadSkin)

