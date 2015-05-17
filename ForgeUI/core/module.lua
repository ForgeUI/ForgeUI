-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		module.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI module protype class
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- ForgeUI Library Definition
-----------------------------------------------------------------------------------------------
local Module = {}
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

function Module:NewModule(...) return Prototype:new(...) end

-----------------------------------------------------------------------------------------------
-- Module prototype
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
	Print("ON PROTOTYPE INIT (" .. self.strName .. ") - please overwrite this function in your module")
end

function Prototype:ForgeAPI_PopulateOptions()
end

_G["ForgeLibs"][3] = new(Module)

