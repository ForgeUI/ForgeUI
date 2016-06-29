-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		taxi.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI skin for Carbine's Character addon
-----------------------------------------------------------------------------------------------

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local Skins = F:API_GetModule("skins")

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

	Skins:HandleFrame(Addon.wndCharacter)
	
	addon.wndCharacter:FindChild("CharFrame_BGArt"):SetStyle("Border", false)
	addon.wndCharacter:FindChild("BGArt_OverallFrame"):SetStyle("Border", false)
	
	addon.wndCharacter:FindChild("PlayerName"):SetSprite("ForgeUI_InnerWindow")
	addon.wndCharacter:FindChild("PlayerName"):SetStyle("Picture", false)
	addon.wndCharacter:FindChild("PlayerName"):SetBGColor("FFFFFFFF")
	addon.wndCharacter:FindChild("PlayerName"):SetTextColor("FFFF0000")
	addon.wndCharacter:FindChild("PlayerName"):SetAnchorPoints(0.5, 0, 0.5, 0)
	addon.wndCharacter:FindChild("PlayerName"):SetAnchorOffsets(-200, 5, 200, 40)

	addon.wndCharacter:FindChild("PlayerNameFraming"):SetSprite("ForgeUI_InnerWindow")
	addon.wndCharacter:FindChild("PlayerNameFraming"):SetStyle("Picture", true)
	addon.wndCharacter:FindChild("PlayerNameFraming"):SetBGColor("FFFFFFFF")
	addon.wndCharacter:FindChild("PlayerNameFraming"):SetTextColor("FFFF0000")
	addon.wndCharacter:FindChild("PlayerNameFraming"):SetAnchorPoints(0.5, 0, 0.5, 0)
	addon.wndCharacter:FindChild("PlayerNameFraming"):SetAnchorOffsets(-200, 5, 200, 40)
	
	addon.wndCharacter:FindChild("HeaderNav"):SetSprite("ForgeUI_InnerWindow")
	addon.wndCharacter:FindChild("HeaderNav"):SetAnchorOffsets(5, 45, -5, 80)
	addon.wndCharacter:FindChild("HeaderNav"):SetStyle("Picture", true)
	for k, v in pairs(addon.wndCharacter:FindChild("HeaderNav"):GetChildren()) do
		Skins:HandleButton(v)
	end
		
	addon.wndCharacter:FindChild("Left"):SetStyle("Border", false)
	addon.wndCharacter:FindChild("Left"):SetSprite("ForgeUI_InnerWindow")
	
	addon.wndCharacter:FindChild("CharacterTitles"):SetStyle("Border", false)
	addon.wndCharacter:FindChild("CharacterTitles"):SetSprite("ForgeUI_InnerWindow")
	
	

	Skins:HandleCloseButton(addon.wndCharacter:FindChild("Close"))
end

Skins:NewCarbineSkin("Character", LoadSkin)

