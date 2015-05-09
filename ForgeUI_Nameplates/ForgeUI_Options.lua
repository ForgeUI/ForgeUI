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
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers["Container_General"]:FindChild("bShowDead"):FindChild("CheckBox"), self.tSettings, "bShowDead")
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers["Container_General"]:FindChild("bShowObjectives"):FindChild("CheckBox"), self.tSettings, "bShowObjectives")
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers["Container_General"]:FindChild("bClickable"):FindChild("CheckBox"), self.tSettings, "bClickable", "LoadStyle_Nameplates" )
	
	ForgeUI.API_RegisterColorBox(self, self.wndContainers["Container_General"]:FindChild("crShield"):FindChild("EditBox"), self.tSettings, "crShield", false, "LoadStyle_Nameplates" )
	ForgeUI.API_RegisterColorBox(self, self.wndContainers["Container_General"]:FindChild("crAbsorb"):FindChild("EditBox"), self.tSettings, "crAbsorb", false, "LoadStyle_Nameplates" )
	ForgeUI.API_RegisterColorBox(self, self.wndContainers["Container_General"]:FindChild("crDead"):FindChild("EditBox"), self.tSettings, "crDead", false )
	
	-- external
	
	ForgeUI.API_RegisterColorBox(self, self.wndContainers["Container_Target"]:FindChild("crTargetMarkerEXT"):FindChild("EditBox"), self.tSettings.tUnits["Target"], "crTargetMarker", false, "LoadStyle_Nameplates" )
	ForgeUI.API_RegisterColorBox(self, self.wndContainers["Container_HostileNPC"]:FindChild("crThreatIndicatorEXT"):FindChild("EditBox"), self.tSettings.tUnits["HostileNPC"], "crThreatIndicator", false, "LoadStyle_Nameplates" )
	ForgeUI.API_RegisterColorBox(self, self.wndContainers["Container_FriendlyPlayer"]:FindChild("crCleanseIndicatorEXT"):FindChild("EditBox"), self.tSettings.tUnits["FriendlyPlayer"], "crCleanseIndicator", false, "LoadStyle_Nameplates" )
	ForgeUI.API_RegisterColorBox(self, self.wndContainers["Container_PartyPlayer"]:FindChild("crCleanseIndicatorEXT"):FindChild("EditBox"), self.tSettings.tUnits["PartyPlayer"], "crCleanseIndicator", false, "LoadStyle_Nameplates" )
	
	for type, keyValue in pairs(self.tSettings.tUnits) do
		for option, optionValue in pairs(keyValue) do
			if self.wndContainers["Container_" .. type] ~= nil then
				if string.sub(option, 1, 1) == "n" then
					if self.wndContainers["Container_" .. type]:FindChild(tostring(option)) ~= nil and self.wndContainers["Container_" .. type]:FindChild(tostring(option)):FindChild("Dropdown") ~= nil then
						if tostring(option) == "nShowInfo" then
							ForgeUI.API_RegisterDropdown(self, self.wndContainers["Container_" .. type]:FindChild(tostring(option)):FindChild("Dropdown"), self.tSettings.tUnits[type], option, {
								[0] = "Nothing",
								[1] = "Level",
								[2] = "Class",
								[3] = "Both",
							}, "UpdateAllNameplates")
						else
							ForgeUI.API_RegisterDropdown(self, self.wndContainers["Container_" .. type]:FindChild(tostring(option)):FindChild("Dropdown"), self.tSettings.tUnits[type], option, {
								[0] = "Never",
								[1] = "Out of combat",
								[2] = "In combat",
								[3] = "Always",
							})
						end
					elseif self.wndContainers["Container_" .. type]:FindChild(tostring(option)) ~= nil and self.wndContainers["Container_" .. type]:FindChild(tostring(option)):FindChild("EditBox") ~= nil then
						ForgeUI.API_RegisterNumberBox(self, self.wndContainers["Container_" .. type]:FindChild(tostring(option)):FindChild("EditBox"), self.tSettings.tUnits[type], option, { nMin = 0 })
					end
				end
				
				if string.sub(option, 1, 1) == "b" then
					if self.wndContainers["Container_" .. type]:FindChild(tostring(option)) ~= nil and self.wndContainers["Container_" .. type]:FindChild(tostring(option)):FindChild("CheckBox") ~= nil then
						ForgeUI.API_RegisterCheckBox(self, self.wndContainers["Container_" .. type]:FindChild(option):FindChild("CheckBox"), self.tSettings.tUnits[type], option )
					end
				end
				
				if string.sub(option, 1, 2) == "cr" then
					if self.wndContainers["Container_" .. type]:FindChild(tostring(option)) ~= nil and self.wndContainers["Container_" .. type]:FindChild(tostring(option)):FindChild("EditBox") ~= nil then
						ForgeUI.API_RegisterColorBox(self, self.wndContainers["Container_" .. type]:FindChild(option):FindChild("EditBox"), self.tSettings.tUnits[type], option, false )
					end
				end
			end
		end
	end
	
	-- style
	
	ForgeUI.API_RegisterNumberBox(self, self.wndContainers["Container_Style"]:FindChild("nBarHeight"):FindChild("EditBox"), self.tSettings.tStyle, "nBarHeight", { nMin = 0 }, "LoadStyle_Nameplates")
	ForgeUI.API_RegisterNumberBox(self, self.wndContainers["Container_Style"]:FindChild("nBarWidth"):FindChild("EditBox"), self.tSettings.tStyle, "nBarWidth", { nMin = 0 }, "LoadStyle_Nameplates")
	ForgeUI.API_RegisterNumberBox(self, self.wndContainers["Container_Style"]:FindChild("nShieldHeight"):FindChild("EditBox"), self.tSettings.tStyle, "nShieldHeight", { nMin = 0 }, "LoadStyle_Nameplates")
	ForgeUI.API_RegisterNumberBox(self, self.wndContainers["Container_Style"]:FindChild("nAbsorbHeight"):FindChild("EditBox"), self.tSettings.tStyle, "nAbsorbHeight", { nMin = 0 }, "LoadStyle_Nameplates")
	ForgeUI.API_RegisterNumberBox(self, self.wndContainers["Container_Style"]:FindChild("nCastHeight"):FindChild("EditBox"), self.tSettings.tStyle, "nCastHeight", { nMin = 0 }, "LoadStyle_Nameplates")
	
	ForgeUI.API_RegisterDropdown(self, self.wndContainers["Container_Style"]:FindChild("nStyle"):FindChild("Dropdown"), self.tSettings.tStyle, "nStyle", {
		[0] = "Modern",
		[1] = "Classic",
	}, "OnStyleChanged")
	
	self.tStylers["LoadStyle_Nameplates"]["LoadStyle_Nameplates"](self)
	self:UpdateAllNameplates()
end