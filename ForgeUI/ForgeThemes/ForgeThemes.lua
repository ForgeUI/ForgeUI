local ForgeUI = Apollo.GetAddon("ForgeUI")
ForgeUI.tThemes = {}

local Theme = {}
Theme.__index = Prototype 
function Theme:new(strAddon)
   	local o = {}
   	setmetatable(o, Prototype)
   
	o.strAddon = strAddon

   	return o
end

function Theme:Init()
end

function Theme:ForgeAPI_AfterDocLoaded()
end

-- ForgeUI API
function ForgeUI:API_RegisterTheme(strAddon)
	local tTheme = Theme:new(strAddon)

	ForgeUI.tThemes[strAddon] = tTheme

	return tTheme
end
