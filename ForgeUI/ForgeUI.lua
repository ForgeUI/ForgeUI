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
local ForgeUI = {}
local Addon = {}
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local AUTHOR = "Winty Badass@Jabbit"
local VERSION = "0.5-alpha"
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
	
	self.xmlTextures = XmlDoc.CreateFromFile("\\media\\textures\\ForgeUI_Textures.xml")
end

function Addon:OnDocLoaded()
	if self.xmlDoc == nil or not self.xmlDoc:IsLoaded() then return end

	Apollo.LoadSprites(self.xmlTextures)
	
	-- ForgeUI window initialization
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Form", nil, self)
	self.wndMenuHolder = self.wndMain:FindChild("ItemList")
	self.wndOptionsHolder = self.wndMain:FindChild("ItemHolder")
	
	self.wndMain:FindChild("AuthorText"):SetText(AUTHOR)
	self.wndMain:FindChild("VersionText"):SetText(VERSION)
	
	ForgeUI:Init()
end

function Addon:OnConfigure() self:OnForgeUIOn() end
function Addon:OnForgeUIOn() self.wndMain:Invoke() end

---------------------------------------------------------------------------------------------------
-- ForgeUI_Item Functions
---------------------------------------------------------------------------------------------------
function Addon:ItemListPressed( wndHandler, wndControl, eMouseButton )
	wndControl:SetCheck(true)

	for _, v in pairs(self.wndMenuHolder:GetChildren()) do
		if v:FindChild("Button") ~= wndControl then
			v:FindChild("Button"):SetCheck(false)
		end
		
		for _, w in pairs(v:FindChild("Holder"):GetChildren()) do
			if w:FindChild("Button") ~= wndControl then
				w:FindChild("Button"):SetCheck(false)
			end
		end
	end
	
	if wndControl:FindChild("Sign"):IsShown() then
		if wndControl:FindChild("Holder"):IsShown() then
			wndControl:FindChild("Sign"):SetText("+")
			wndControl:FindChild("Holder"):Show(false)
			
			local wndHolder = wndControl:GetParent()
			local nLeft, nTop, nRight, nBottom = wndHolder:GetAnchorOffsets()
			wndHolder:SetAnchorOffsets(nLeft, nTop, nRight, nTop + 20)
		else
			wndControl:FindChild("Sign"):SetText("-")
			wndControl:FindChild("Holder"):Show(true)
			
			local wndHolder = wndControl:GetParent()
			local nLeft, nTop, nRight, nBottom = wndHolder:GetAnchorOffsets()
			wndHolder:SetAnchorOffsets(nLeft, nTop, nRight, nBottom + 20 * #wndControl:FindChild("Holder"):GetChildren())
		end
		
		Inst.wndMenuHolder:ArrangeChildrenVert()
	end
end

-----------------------------------------------------------------------------------------------
-- OnSave/OnRestore
-----------------------------------------------------------------------------------------------
function Addon:OnSave(...) return ForgeUI:OnSave(...) end
function Addon:OnRestore(...) ForgeUI:OnRestore(...) end

-----------------------------------------------------------------------------------------------
-- FOrgeUI public api
-----------------------------------------------------------------------------------------------
function ForgeUI:API_AddMenuItem(tModule, strText, strWindow)
	local wndItem = Apollo.LoadForm(Inst.xmlDoc, "ForgeUI_Item", Inst.wndMenuHolder, Inst)
	wndItem:FindChild("Button"):SetText(strText)
	
	wndItem:AddEventHandler("ButtonCheck", "ItemListPressed", Inst)
	wndItem:AddEventHandler("ButtonUncheck", "ItemListPressed", Inst)
	
	local tData = {}
	
	if strWindow then
	end
	
	wndItem:SetData(tData)

	Inst.wndMenuHolder:ArrangeChildrenVert()
	
	return wndItem
end

function ForgeUI:API_AddMenuToMenuItem(tModule, wndParent, strText, strWindow)
	local wndItem = Apollo.LoadForm(Inst.xmlDoc, "ForgeUI_Item", wndParent:FindChild("Holder"), Inst)
	wndItem:FindChild("Button"):SetText(strText)
	
	wndItem:AddEventHandler("ButtonCheck", "ItemListPressed", Inst)
	wndItem:AddEventHandler("ButtonUncheck", "ItemListPressed", Inst)
	
	wndParent:FindChild("Sign"):Show(true, true)
	
	local tData = {}
	
	if strWindow then
	end
	
	wndItem:SetData(tData)

	wndParent:FindChild("Holder"):ArrangeChildrenVert()
	wndParent:FindChild("Holder"):SetAnchorOffsets(10, 0, 0, #wndParent:FindChild("Holder"):GetChildren() * 20)
	
	return wndItem
end

Inst:Init()

-- ForgeLibs initialization
_G["ForgeLibs"] = {}
_G["ForgeLibs"][1] = ForgeUI
_G["ForgeLibs"][2] = Inst
