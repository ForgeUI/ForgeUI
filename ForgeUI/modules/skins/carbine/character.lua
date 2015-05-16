-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		taxi.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI skin for Carbine's Character addon
-----------------------------------------------------------------------------------------------

local ForgeUI = ForgeUI
local Skins = ForgeUI:API_GetModule("skins")

local Addon

local fnUseSkin

local fnOnDocumentReady
local fnOnDocumentReadyOrig

local function LoadSkin()
	Addon = Apollo.GetAddon("Character")
	
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
	

	Skins:HandleCloseButton(addon.wndCharacter:FindChild("Close"))
end

Skins:NewCarbineSkin("Character", LoadSkin)

