-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		skins.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI skins module
-----------------------------------------------------------------------------------------------

local F, A, M = unpack(_G["ForgeLibs"])

-----------------------------------------------------------------------------------------------
-- ForgeUI Module Definition
-----------------------------------------------------------------------------------------------
local Skins = {
	tCharSettings = {
		tLoadSkins = {}
	}
}

-----------------------------------------------------------------------------------------------
-- Local variables
-----------------------------------------------------------------------------------------------
local tSkins = {}

-----------------------------------------------------------------------------------------------
-- Module functions
-----------------------------------------------------------------------------------------------
function Skins:Init()
	for k, v in pairs(tSkins) do
		if Apollo.GetAddon(k) and self.tCharSettings.tLoadSkins[k] then
			v()
		end
	end
end

function Skins:NewCarbineSkin(strAddon, fLoadSkin)
	tSkins[strAddon] = fLoadSkin
	if self.tCharSettings.tLoadSkins[strAddon] == nil then
		self.tCharSettings.tLoadSkins[strAddon] = true
	end
end

function Skins:HandleCloseButton(wndButton, tOptions)
	wndButton:ChangeArt("ForgeUI_Button")
	wndButton:SetText("X")
	wndButton:SetFont("Nameplates")
	
	wndButton:SetStyle("AutoScaleTextOff", true)
	
	if tOptions then
	else
		wndButton:SetAnchorPoints(1, 0, 1, 0)
		wndButton:SetAnchorOffsets(-26, 5, -5, 26)
	end
end

function Skins:HandleButton(wndButton, tOptions)
	wndButton:ChangeArt("ForgeUI_Button")
	wndButton:SetDisabledTextColor("FF333333") -- TODO: Replace with variable from settings
	wndButton:SetNormalTextColor("FFFFFFFF")
	wndButton:SetPressedTextColor("FFFF0000")
	wndButton:SetPressedFlybyTextColor("FFFF0000")
	wndButton:SetFlybyTextColor("FFFFFFFF")
end

Skins = F:API_NewModule(Skins, "skins", { bGlobal = true })

