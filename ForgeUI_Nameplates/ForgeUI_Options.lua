local ForgeUI = Apollo.GetAddon('ForgeUI')
local ForgeUI_Nameplates = Apollo.GetAddon('ForgeUI_Nameplates')

function ForgeUI_Nameplates:ForgeAPI_AfterRestore()
	Apollo.SetConsoleVariable("ui.occludeNameplatePositions", false)
	
	ForgeUI.API_RegisterNumberBox(self, self.wndContainers["Container_General"]:FindChild("nMaxRange"):FindChild("EditBox"), self.tSettings, "nMaxRange", { nMin = 0 })

	ForgeUI.API_RegisterCheckBox(self, self.wndContainers["Container_General"]:FindChild("bUseOcclusion"):FindChild("CheckBox"), self.tSettings, "bUseOcclusion")
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers["Container_General"]:FindChild("bShowTitles"):FindChild("CheckBox"), self.tSettings, "bShowTitles", "UpdateAllNameplates")
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers["Container_General"]:FindChild("bShowAbsorb"):FindChild("CheckBox"), self.tSettings, "bShowAbsorb")
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers["Container_General"]:FindChild("bShowShield"):FindChild("CheckBox"), self.tSettings, "bShowShield")
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers["Container_General"]:FindChild("bOnlyImportantNPC"):FindChild("CheckBox"), self.tSettings, "bOnlyImportantNPC")
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers["Container_General"]:FindChild("bFrequentUpdate"):FindChild("CheckBox"), self.tSettings, "bFrequentUpdate")
	
	ForgeUI.API_RegisterColorBox(self, self.wndContainers["Container_General"]:FindChild("crShield"):FindChild("EditBox"), self.tSettings, "crShield", false, "LoadStyle_Nameplates" )
	ForgeUI.API_RegisterColorBox(self, self.wndContainers["Container_General"]:FindChild("crAbsorb"):FindChild("EditBox"), self.tSettings, "crAbsorb", false, "LoadStyle_Nameplates" )
	
	ForgeUI.API_RegisterDropdown(self, self.wndContainers["Container_Player"]:FindChild("nShowName"):FindChild("Dropdown"), self.tSettings.tUnits.Player, "nShowName", {
		[0] = "Never",
		[1] = "Out of combat",
		[2] = "In combat",
		[3] = "Always",
	}, "UpdateAllNameplates")
end