-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		chatlog.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI skin for Carbine's TaxiMapdon
-----------------------------------------------------------------------------------------------

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local Skins = F:API_GetModule("skins")

local fnUseSkin

local function LoadSkin()
	local addon = Apollo.GetAddon("ChatLog")
	
	F:PostHook(addon, "OnDocumentReady", fnUseSkin)
	
	fnUseSkin(addon)
end

fnUseSkin = function(luaCaller)
	--if not luaCaller.wndMain and not bRun then return end
	
	
	
	for k, v in pairs(luaCaller.tChatWindows) do
		--v:SetStyle("Border", false)
	end
end

Skins:NewCarbineSkin("ChatLog", LoadSkin)

