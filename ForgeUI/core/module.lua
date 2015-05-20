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
local Prototype = {}

-----------------------------------------------------------------------------------------------
-- ForgeUI Library Finctions
-----------------------------------------------------------------------------------------------
function F:NewModule(...) return Prototype:new(...) end

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

function Prototype:ForgeAPI_PreInit()
end

function Prototype:ForgeAPI_Init()
end

function Prototype:ForgeAPI_LoadSettings()
end

function Prototype:ForgeAPI_PopulateOptions()
end

