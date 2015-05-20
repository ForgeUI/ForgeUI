-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		module.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI module protype class
-----------------------------------------------------------------------------------------------

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API

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
function Prototype:new(t)
   	local t = t or {}
   	setmetatable(t, Prototype)

	t.bInit = false

   	return t
end

function Prototype:ForgeAPI_PreInit()
end

function Prototype:ForgeAPI_Init()
end

function Prototype:ForgeAPI_LoadSettings()
end

function Prototype:ForgeAPI_PopulateOptions()
end

_G["ForgeLibs"]["ForgeModule"] = new(Module)

