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
function Prototype:new(o)
   	local o = o or {}
   	setmetatable(o, Prototype)
	
	o.bInit = false
	
   	return o
end

function Prototype:RefreshConfig()
	local db = F:API_GetNamespace(self._NAME)
	if db then
		self._DB = {
			profile = db.profile,
			global = db.global,
			char = db.char,
		}
	end
	
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

_G["ForgeLibs"]["ForgeModule"] = new(Module)

