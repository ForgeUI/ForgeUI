-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		util.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI module protype class
-----------------------------------------------------------------------------------------------

local Prototype = {}

local ForgeUI = ForgeUI

-----------------------------------------------------------------------------------------------
-- Local variables
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- ForgeUI module functions
-----------------------------------------------------------------------------------------------

Prototype.__index = Prototype 
function Prototype.new(t, strName)
   	local t = t or {}
   	setmetatable(t, Prototype)
   
	t.strName = strName

	t.bInit = false

   	return t
end

function Prototype:Init()
	Print("ON PROTOTYPE INIT (" .. self.strName .. ") - please overwrite this function in your module")
end

_G["ForgeLibs"][3] = Prototype

