-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		addon.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI addon protype class
-----------------------------------------------------------------------------------------------

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API

-----------------------------------------------------------------------------------------------
-- ForgeUI Library Definition
-----------------------------------------------------------------------------------------------
local Prototype = {}

-----------------------------------------------------------------------------------------------
-- ForgeUI Library functions
-----------------------------------------------------------------------------------------------
function F:NewAddon(...) return Prototype:new(...) end

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

function Prototype:ForgeAPI_PreInit()
end

function Prototype:ForgeAPI_Init()
end

function Prototype:ForgeAPI_LoadSettings()
end

function Prototype:ForgeAPI_PopulateOptions()
end

