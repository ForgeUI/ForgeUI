-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		addon.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI addon protype class
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- ForgeUI Library Definition
-----------------------------------------------------------------------------------------------
local Addon = {}
local Prototype = {}

-----------------------------------------------------------------------------------------------
-- ForgeUI Library Initialization
-----------------------------------------------------------------------------------------------
local new = function(self, o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	
	return o
end

function Addon:NewAddon(...) return Prototype:new(...) end

-----------------------------------------------------------------------------------------------
-- Addon prototype
-----------------------------------------------------------------------------------------------
Prototype.__index = Prototype 
function Prototype:new(t, strName)
   	local t = t or {}
   	setmetatable(t, Prototype)
   
	t.strName = strName

	t.bInit = false

   	return t
end

function Prototype:ForgeAPI_Init()
	Print("ON PROTOTYPE INIT (" .. self.strName .. ") - please overwrite this function in your addon")
end

function Prototype:ForgeAPI_PopulateOptions()
end

_G["ForgeLibs"][2] = new(Addon)

