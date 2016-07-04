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

    G:API_AddColorBox(self, wnd, "Engineer", F:API_GetCoreDB().tClassColors, GameLib.CodeEnumClass.Engineer, { tMove = { 0, 90 } })
    G:API_AddColorBox(self, wnd, "Esper", F:API_GetCoreDB().tClassColors, GameLib.CodeEnumClass.Esper, { tMove = { 150, 90 } })
    G:API_AddColorBox(self, wnd, "Medic", F:API_GetCoreDB().tClassColors, GameLib.CodeEnumClass.Medic, { tMove = { 300, 90 } })
    G:API_AddColorBox(self, wnd, "Spellslinger", F:API_GetCoreDB().tClassColors, GameLib.CodeEnumClass.Spellslinger, { tMove = { 0, 120 } })
    G:API_AddColorBox(self, wnd, "Stalker", F:API_GetCoreDB().tClassColors, GameLib.CodeEnumClass.Stalker, { tMove = { 150, 120 } })
    G:API_AddColorBox(self, wnd, "Warrior", F:API_GetCoreDB().tClassColors, GameLib.CodeEnumClass.Warrior, { tMove = { 300, 120 } })

    --G:API_AddColorBox(self, wnd, "Friendly", F:API_GetCoreDB().tDispositionColors, Unit.CodeEnumDisposition.Friendly, { tMove = { 450, 60 } })
    --G:API_AddColorBox(self, wnd, "Neutral", F:API_GetCoreDB().tDispositionColors, Unit.CodeEnumDisposition.Neutral, { tMove = { 450, 90 } })
    --G:API_AddColorBox(self, wnd, "Hostile", F:API_GetCoreDB().tDispositionColors, Unit.CodeEnumDisposition.Hostile, { tMove = { 450, 120 } })

    G:API_AddText(self, wnd, "Press 'Save changes' button after changing class colors", { tMove = { 0, 150 } })

    if F:API_GetCoreDB()["nColorPreset"] == nil then
        F:API_GetCoreDB()["nColorPreset"] = 0
    end
    local wndCombo = G:API_AddComboBox(self, wnd, "Color preset", F:API_GetCoreDB(), "nColorPreset", { tMove = {0, 60}, tWidths = { 150, 100 },
        fnCallback = (function()
            local nColorPreset = F:API_GetCoreDB()["nColorPreset"]
            if nColorPreset == 0 then
                F:API_GetCoreDB().tClassColors[GameLib.CodeEnumClass.Engineer] = "FFEFAB48"
                F:API_GetCoreDB().tClassColors[GameLib.CodeEnumClass.Esper] = "FF1591DB"
                F:API_GetCoreDB().tClassColors[GameLib.CodeEnumClass.Medic] = "FFFFE757"
                F:API_GetCoreDB().tClassColors[GameLib.CodeEnumClass.Spellslinger] = "FF98C723"
                F:API_GetCoreDB().tClassColors[GameLib.CodeEnumClass.Stalker] = "FFD23EF4"
                F:API_GetCoreDB().tClassColors[GameLib.CodeEnumClass.Warrior] = "FFF54F4F"
            elseif nColorPreset == 1 then
                F:API_GetCoreDB().tClassColors[GameLib.CodeEnumClass.Engineer] = "FFD3BF12"
                F:API_GetCoreDB().tClassColors[GameLib.CodeEnumClass.Esper] = "FF1BB0D1"
                F:API_GetCoreDB().tClassColors[GameLib.CodeEnumClass.Medic] = "FF32EB14"
                F:API_GetCoreDB().tClassColors[GameLib.CodeEnumClass.Spellslinger] = "FFFF8C00"
                F:API_GetCoreDB().tClassColors[GameLib.CodeEnumClass.Stalker] = "FF8A2BE2"
                F:API_GetCoreDB().tClassColors[GameLib.CodeEnumClass.Warrior] = "FFB22222"
            end

            --F:API_GetCoreDB().tDispositionColors[Unit.CodeEnumDisposition.Friendly] = "FF75CC26"
            --F:API_GetCoreDB().tDispositionColors[Unit.CodeEnumDisposition.Neutral] = "FFF3D829"
            --F:API_GetCoreDB().tDispositionColors[Unit.CodeEnumDisposition.Hostile] = "FFE50000"

            self:RefreshConfig()

            -- TODO : Create callback listener for global settings
            local nameplates = Apollo.GetAddon("ForgeUI_Nameplates")
            if nameplates ~= nil then
                nameplates:LoadStyle_Nameplates()
            end
        end)
    })
	G:API_AddOptionToComboBox(self, wndCombo, "ForgeUI", 0, {})
    G:API_AddOptionToComboBox(self, wndCombo, "Carbine", 1, {})
end

-----------------------------------------------------------------------------------------------
-- ForgeUI addon registration
-----------------------------------------------------------------------------------------------
F:API_NewModule(Settings)