-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		ForgeUI.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI addon interface
-----------------------------------------------------------------------------------------------
 
require "Window"

-----------------------------------------------------------------------------------------------
-- ForgeUI Module Definition
-----------------------------------------------------------------------------------------------
ForgeUI = {}

local Addon = {}
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local AUTHOR = "Adam Jedlicka"
local AUTHOR_LONG = "Winty Badass@Jabbit"
local API_VERSION = 2
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Addon:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    

    return o
end

local Inst = Addon:new()

function Addon:Init() Apollo.RegisterAddon(self, true, "ForgeUI", {}) end
 
function Addon:OnLoad()
    self.xmlDoc = XmlDoc.CreateFromFile("ForgeUI.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	
	self.xmlTextures = XmlDoc.CreateFromFile("ForgeUI_Textures.xml")
end

function Addon:OnDocLoaded()
	if self.xmlDoc == nil or not self.xmlDoc:IsLoaded() then return end

	Apollo.LoadSprites(self.xmlTextures)
	
	ForgeUI:Init()
end

function Addon:OnSave(...) return ForgeUI:OnSave(...) end
function Addon:OnRestore(...) ForgeUI:OnRestore(...) end

Inst:Init()
ForgeUI["addon"] = Inst
