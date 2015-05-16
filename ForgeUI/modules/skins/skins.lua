-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		skins.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI skins module
-----------------------------------------------------------------------------------------------

local ForgeUI = ForgeUI

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

function Skins:HandleCloseButton(wndButton, tPostition)
	wndButton:ChangeArt("ForgeUI_Button")
	wndButton:SetText("X")
	wndButton:SetFont("Nameplates")
	
	wndButton:SetStyle("AutoScaleTextOff", true)
	
	if tPostition then
	else
		wndButton:SetAnchorPoints(1, 0, 1, 0)
		wndButton:SetAnchorOffsets(-26, 5, -5, 26)
	end
end

Skins = ForgeUI:API_NewModule(Skins, "skins", { bGlobal = true })

