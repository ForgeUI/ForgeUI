local ForgeUI = Apollo.GetAddon('ForgeUI')
local ForgeUI_Nameplates = Apollo.GetAddon('ForgeUI_Nameplates')

function ForgeUI_Nameplates:ForgeAPI_AfterRestore()
	ForgeUI.API_RegisterNumberBox(self, self.wndContainers["General"]:FindChild("nMaxRange"):FindChild("EditBox"), self.tSettings, "nMaxRange", { nMin = 5 })

	ForgeUI.API_RegisterCheckBox(self, self.wndContainers["General"]:FindChild("bUseOcclusion"):FindChild("CheckBox"), self.tSettings, "bUseOcclusion")
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers["General"]:FindChild("bShowTitles"):FindChild("CheckBox"), self.tSettings, "bShowTitles", "UpdateAllNameplates")
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers["General"]:FindChild("bOnlyImportantNPC"):FindChild("CheckBox"), self.tSettings, "bOnlyImportantNPC")
end