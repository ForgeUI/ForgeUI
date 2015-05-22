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
function Prototype:new(o)
   	local o = o or {}
   	setmetatable(o, Prototype)
	
	o._DB = {
		profile = F:API_GetDB(o, "profile"),
		global = F:API_GetDB(o, "global"),
		char = F:API_GetDB(o, "char"),
	}

	o.bInit = false
	
   	return o
end

function Prototype:RefreshConfig()
	self._DB = {
		profile = F:API_GetDB(self, "profile"),
		global = F:API_GetDB(self, "global"),
		char = F:API_GetDB(self, "char"),
	}
	
	if self.tOptionHolders then
		for k, v in pairs(self.tOptionHolders) do
			v:DestroyChildren()
		end
	end
	
	self:ForgeAPI_LoadSettings()
	self:ForgeAPI_PopulateOptions()
end

function Prototype:ForgeAPI_PreInit() end
function Prototype:ForgeAPI_Init() end
function Prototype:ForgeAPI_LoadSettings() end
function Prototype:ForgeAPI_PopulateOptions() end

_G["ForgeLibs"]["ForgeAddon"] = new(Addon)

