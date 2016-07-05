-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		taxi.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI skin for Carbine's TaxiMapdon
-----------------------------------------------------------------------------------------------

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local Skins = F:API_GetModule("skins")

local function fnUseSkin(luaCaller)
	if not luaCaller.tWndRefs.wndMain then return end

	Skins:HandleFrame(luaCaller.tWndRefs.wndMain)
	
	luaCaller.tWndRefs.wndMain:FindChild("MainFrame"):SetStyle("Border", false)
	
	luaCaller.tWndRefs.wndMain:FindChild("TitleText"):SetTextColor("FFFF0000")
	luaCaller.tWndRefs.wndMain:FindChild("TitleText"):SetFont("Nameplates")
	luaCaller.tWndRefs.wndMain:FindChild("Title"):SetName("Title")
	
	Skins:HandleTitle(luaCaller.tWndRefs.wndMain:FindChild("Title"))
	
	Skins:HandleFooter(luaCaller.tWndRefs.wndMain:FindChild("MetalFooter"))
	
	luaCaller.tWndRefs.wndMain:FindChild("BGArt"):SetSprite("ForgeUI_InnerWindow")
	luaCaller.tWndRefs.wndMain:FindChild("BGArt"):SetStyle("Picture", true)
	luaCaller.tWndRefs.wndMain:FindChild("BGArt"):SetBGColor("FFFFFFFF")
	luaCaller.tWndRefs.wndMain:FindChild("BGArt"):SetAnchorOffsets(5, 30, -5, -35)
	
	luaCaller.tWndRefs.wndMain:FindChild("BG_Backer"):Show(false)
	
	luaCaller.tWndRefs.wndMain:FindChild("MapContainer"):SetAnchorOffsets(1, 1, -1, -1)

	luaCaller.tWndRefs.wndMain:FindChild("ZoneToggle"):SetAnchorOffsets(14, -41, 159, -4)
	luaCaller.tWndRefs.wndMain:FindChild("SubzoneToggle"):SetAnchorOffsets(166, -41, 311, -4)
	
	Skins:HandleButton(luaCaller.tWndRefs.wndMain:FindChild("CancelButton"))
	luaCaller.tWndRefs.wndMain:FindChild("CancelButton"):SetAnchorOffsets(-100, -25, 0, 0)
	
	Skins:HandleCloseButton(luaCaller.tWndRefs.wndMain:FindChild("CloseButton"))
end

local function LoadSkin()
	local addon = Apollo.GetAddon("TaxiMap")
	
	F:PostHook(addon, "OnInvokeTaxiWindow", fnUseSkin)
	
	fnUseSkin(addon)
end

Skins:NewCarbineSkin("TaxiMap", LoadSkin)

