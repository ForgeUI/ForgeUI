----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI addon
--
-- name:        settings.lua
-- author:      Winty Badass@Jabbit
-- about:       General settings for the ForgeUI addon
-----------------------------------------------------------------------------------------------

require "Window"

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI
local ForgeUI = Apollo.GetAddon("ForgeUI")

-- libraries
local GeminiHook = Apollo.GetPackage("Gemini:Hook-1.0").tPackage

-----------------------------------------------------------------------------------------------
-- ForgeUI Addon Definition
-----------------------------------------------------------------------------------------------
local Settings = {
    _NAME = "settings",
    _API_VERSION = 3,
    _VERSION = "1.0",
    DISPLAY_NAME = "General settings",

    tSettings = {
        profile = {
            bShowBottomPanel = true,
            nBottomPanelSize = 15,
        }
    }
}
-----------------------------------------------------------------------------------------------
-- ForgeAPI
-----------------------------------------------------------------------------------------------
function Settings:ForgeAPI_Init()
    F:API_AddMenuItem(self, self.DISPLAY_NAME, "General")

    self.wndBottomPanel = Apollo.LoadForm(ForgeUI.xmlDoc, "ForgeUI_Panel", F:API_GetStratum("HudLow"), self)
end

function Settings:ForgeAPI_LoadSettings()
    self.wndBottomPanel:Show(self._DB.profile.bShowBottomPanel)
    self.wndBottomPanel:SetAnchorOffsets(0, -self._DB.profile.nBottomPanelSize, 0, 0)
end

function Settings:ForgeAPI_PopulateOptions()
    local wnd = self.tOptionHolders["General"]

    G:API_AddCheckBox(self, wnd, "Show bottom panel", self._DB.profile, "bShowBottomPanel", { tMove = {0, 0},
        fnCallback = self.ForgeAPI_LoadSettings
    })

    G:API_AddNumberBox(self, wnd, "Bottom panel size", self._DB.profile, "nBottomPanelSize", { tMove = {150, 0},
        fnCallback = self.ForgeAPI_LoadSettings
    })
end

-----------------------------------------------------------------------------------------------
-- ForgeUI addon registration
-----------------------------------------------------------------------------------------------
F:API_NewModule(Settings)