-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		welcome_module.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI welcome module
-----------------------------------------------------------------------------------------------

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI

-----------------------------------------------------------------------------------------------
-- ForgeUI Module Definition
-----------------------------------------------------------------------------------------------
local CreditsModule = {
	_NAME = "welcome_module",
	_API_VERSION = 3,
	_VERSION = "1.0",
}

-----------------------------------------------------------------------------------------------
-- Local variables
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- Module functions
-----------------------------------------------------------------------------------------------
function CreditsModule:ForgeAPI_Init()
	F:API_AddMenuItem(self, "Home", "Home", { strPriority = "shigh", bDefault = true })

	self.tTmpSettings = {
		crColor = "FFFF9900"
	}
end

function CreditsModule:ForgeAPI_PopulateOptions()
	local wndHome = self.tOptionHolders["Home"]

    G:API_AddText(self, wndHome, string.format("<T TextColor=\"%s\" Font=\"%s\">%s</T>", "FFFFFFFF", "Nameplates", "Welcome to ")
        .. string.format("<T TextColor=\"%s\" Font=\"%s\">%s</T>", "FFFF0000", "Nameplates", "ForgeUI"), { tMove = { 235, 30 } })

    G:API_AddText(self, wndHome, "- To move and resize elements of ForgeUI, press 'Unlock elements'.", { tMove = { 0, 90 } })
    G:API_AddText(self, wndHome, "- To change mounts, recalls, potions, ... use right-click.", { tMove = { 0, 120 } })
    G:API_AddText(self, wndHome, "- To cycle between mounts, use scroll-wheel.", { tMove = { 0, 150 } })
    G:API_AddText(self, wndHome, "- /reloadui fixes most of the problems :)", { tMove = { 0, 180 } })

	G:API_AddText(self, wndHome, "- Click on these color-boxes to bring up color picker: ", { tMove = { 0, 210 } })
	G:API_AddColorBox(self, wndHome, "", self.tTmpSettings, "crColor", { tMove = { 310, 205 } })

    G:API_AddText(self, wndHome, "Because ForgeUI is still in beta, please report any bugs here:", { tMove = { 0, 365 } })
    self.wndEditBox = G:API_EditBox(self, wndHome, "", nil, nil, {
		tMove = { 0, 390 }, tWidths = { 300, 0 },
		fnCallback = (function()
			self.wndEditBox:SetText('https://github.com/ForgeUI/ForgeUI/issues')
		end)
	}):FindChild("EditBox")
	self.wndEditBox:SetText('https://github.com/ForgeUI/ForgeUI/issues')
end

CreditsModule = F:API_NewModule(CreditsModule)
