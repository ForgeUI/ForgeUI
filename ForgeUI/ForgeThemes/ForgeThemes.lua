local ForgeUI = Apollo.GetAddon("ForgeUI")
ForgeUI.tThemes = {}

local Theme = {}
Theme.__index = Prototype 
function Theme:new(strAddon, bCarbine)
   	local o = {}
   	setmetatable(o, Prototype)
   
	o.strAddon = strAddon
	o.bCarbine = bCarbine

   	return o
end

function Theme:Init()
end

function Theme:OnLoad()
end

function Theme:OnUnload()
end

-- ForgeUI API
function ForgeUI:API_RegisterTheme(strAddon, bCarbine)
	local tTheme = Theme:new(strAddon, bCarbine)

	if self.tSettings.tThemes[strAddon] == nil then
		self.tSettings.tThemes[strAddon] = true
	end
	
	ForgeUI.tThemes[strAddon] = tTheme

	return tTheme
end
