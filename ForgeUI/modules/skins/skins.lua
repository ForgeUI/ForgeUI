-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		skins.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI skins module
-----------------------------------------------------------------------------------------------

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API

-----------------------------------------------------------------------------------------------
-- ForgeUI Module Definition
-----------------------------------------------------------------------------------------------
local Skins = {
	_NAME = "skins",
	_API_VERSION = 3,

	tSettings = {
		char = {
			tLoadSkins = {}
		}
	}
}

-----------------------------------------------------------------------------------------------
-- Local variables
-----------------------------------------------------------------------------------------------
local tSkins = {}

-----------------------------------------------------------------------------------------------
-- Module functions
-----------------------------------------------------------------------------------------------
function Skins:ForgeAPI_Init()
	for k, v in pairs(tSkins) do
		if Apollo.GetAddon(k) and self._DB.char.tLoadSkins[k] then
			v.fnLoadSkin()
			v.bLoaded = true
		end
	end
end

function Skins:NewCarbineSkin(strAddon, fnLoadSkin)
	tSkins[strAddon] = {
		fnLoadSkin = fnLoadSkin,
		bLoaded = false,
	}
	
	if not self._DB then
		self.tSettings.char.tLoadSkins[strAddon] = true
	else
		if self._DB.char.tLoadSkins[strAddon] == nil then
			self._DB.char.tLoadSkins[strAddon] = true
		end
	end
end

-----------------------------------------------------------------------------------------------
-- Handle functions
-----------------------------------------------------------------------------------------------
function Skins:HandleFrame(wndWindow, tOptions)
	wndWindow:SetSprite("ForgeUI_Border")
	wndWindow:SetBGColor("FF000000")
	wndWindow:SetStyle("Picture", true)
	wndWindow:SetStyle("Border", true)
end

function Skins:HandleTitle(wndWindow, tOptions)
	wndWindow:FindChild("Title"):SetSprite("ForgeUI_InnerWindow")
	wndWindow:FindChild("Title"):SetStyle("Picture", false)
	wndWindow:FindChild("Title"):SetBGColor("FFFFFFFF") -- TODO: Replace with variable from settings
	wndWindow:FindChild("Title"):SetAnchorOffsets(-200, 0, 200, 30)
end

function Skins:HandleFooter(wndWindow, tOptions)
	wndWindow:FindChild("MetalFooter"):SetStyle("Picture", false)
	wndWindow:FindChild("MetalFooter"):SetAnchorOffsets(5, -40, -5, -5)
	
	if tOptions then
		if tOptions.bBackground then
			wndWindow:FindChild("MetalFooter"):SetSprite("ForgeUI_InnerWindow")
			wndWindow:FindChild("MetalFooter"):SetBGColor("FFFFFFFF")
		end
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
	wndButton:SetFont("Nameplates")
	wndButton:SetDisabledTextColor("FF333333") -- TODO: Replace with variable from settings
	wndButton:SetNormalTextColor("FFFFFFFF")
	wndButton:SetPressedTextColor("FF888888")
	wndButton:SetPressedFlybyTextColor("FF888888")
	wndButton:SetFlybyTextColor("FFFFFFFF")
end

Skins = F:API_NewModule(Skins)

