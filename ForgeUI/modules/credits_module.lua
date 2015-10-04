-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		credits_module.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI module for displaying credit in main ForgeUI window
-----------------------------------------------------------------------------------------------

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI

-----------------------------------------------------------------------------------------------
-- ForgeUI Module Definition
-----------------------------------------------------------------------------------------------
local CreditsModule = {
	_NAME = "credits_module",
	_API_VERSION = 3,
	_VERSION = "1.0",
}

-----------------------------------------------------------------------------------------------
-- Local variables
-----------------------------------------------------------------------------------------------
local tGroups = {
	[1] = {
		sName = "Creator",
		tPpl = {
			["Winty Badass"] = "",
		},
	},
	[2] = {
		sName = "Developers",
		tPpl = {
			["Toludin"] = "",
		},
	},
	[3] = {
		sName = "Externists",
		tPpl = {
			["Vim Exe"] = "code reviews",
			["Chaarp Shooter"] = "debugging & help with code",
			["Ringo Noyamano"] = "debugging & design decisions",
			["Miss Sistray"] = "class & mob icons",
			["Akira Kurosawa"] = "design decisions",
			["Gordma Galeic"] = "design decisions",
		},
	},
	[4] = {
		sName = "Donations",
		tPpl = {
			[""] = "",
		},
	},
	[5] = {
		sName = "Pink Cheese",
		tPpl = {
			["Briex"] = "",
		},
	},
}

-----------------------------------------------------------------------------------------------
-- Module functions
-----------------------------------------------------------------------------------------------
function CreditsModule:ForgeAPI_Init()
	F:API_AddMenuItem(self, "Credits", "Credits", { strPriority = "slow" })
end

function CreditsModule:ForgeAPI_PopulateOptions()
	local wndProfiles = self.tOptionHolders["Credits"]

	local nGroups = 0
	local nPpl = 0
	
	for i = 1, #tGroups do
		local tGroup = tGroups[i]
	
		G:API_AddText(self, wndProfiles, string.format("<T TextColor=\"%s\" Font=\"%s\">%s</T>",
			"FFF50002", "Nameplates", tGroup.sName), {
			tMove = {
				0, nGroups * 25, 0, nGroups * 25,
			}
		})
		
		for sName, sNote in pairs(tGroup.tPpl) do
			G:API_AddText(self, wndProfiles, string.format("<T TextColor=\"%s\" Font=\"%s\">%s</T>",
				"FFFFFFFF", "Nameplates", sName), {
				tMove = {
					100, nGroups * 25, 0, nGroups * 25,
				}
			})
		
			if sNote then
				G:API_AddText(self, wndProfiles, string.format("<T TextColor=\"%s\" Font=\"%s\">%s</T>",
					"FFFFFFFF", "Nameplates", sNote), {
					tMove = {
						250, nGroups * 25, 0, nGroups * 25,
					}
				})
			end
			
			nGroups = nGroups + 1
		end
		
		i = i + 1
	end
	
	G:API_AddText(self, wndProfiles, "and everyone from <The Utopia> for help during early development!", {
		tMove = {
			0, 350, 0, 350,
		}
	})
	
	G:API_AddText(self, wndProfiles, "*if you can't find yourself here, send me a PM on curse.com", {
		tMove = {
			0, 400, 0, 400,
		}
	})
end

CreditsModule = F:API_NewModule(CreditsModule)
