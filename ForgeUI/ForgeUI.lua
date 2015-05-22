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
local API_VERSION = 3
 
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

function Addon:OnLoad()
    self.xmlDoc = XmlDoc.CreateFromFile("ForgeUI.xml")
	self.xmlOptions = XmlDoc.CreateFromFile("ForgeUI_Options.xml")
	self.xmlTextures = XmlDoc.CreateFromFile("\\media\\textures\\ForgeUI_Textures.xml")
	self.xmlIcons = XmlDoc.CreateFromFile("\\media\\icons\\ForgeUI_Icons.xml")
	
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	
	-- init ForgeLibs
	for _, v in pairs(_G["ForgeLibs"]) do
		if v.ForgeAPI_Init then
			v:ForgeAPI_Init()
		end
	end
end

function Addon:OnDocLoaded()
	if self.xmlDoc == nil or not self.xmlDoc:IsLoaded() then return end
	
	Apollo.LoadSprites(self.xmlTextures)
	Apollo.LoadSprites(self.xmlIcons)
	
	Apollo.RegisterSlashCommand("forgeui", "OnForgeUIOn", self)
	
	-- ForgeUI window initialization
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Form", nil, self)
	self.wndMenuHolder = self.wndMain:FindChild("ItemList")
	self.wndOptionsHolder = self.wndMain:FindChild("ItemContainer")
	
	self.wndMain:FindChild("AuthorText"):SetText(AUTHOR)
	self.wndMain:FindChild("VersionText"):SetText(VERSION)
	
	-- init Modules
	if GameLib.GetPlayerUnit() then
		self:OnCharacterCreated()
	else
		Apollo.RegisterEventHandler("CharacterCreated", "OnCharacterCreated", self)
	end
end

function Addon:OnCharacterCreated() ForgeUI:Init() end
function Addon:OnConfigure() self:OnForgeUIOn() end
function Addon:OnForgeUIOn() self.wndMain:Invoke() end
function Addon:OnForgeUIOff() self.wndMain:Close() end

---------------------------------------------------------------------------------------------------
-- ForgeUI_Form Functions
---------------------------------------------------------------------------------------------------
function Addon:OnSaveButtonPressed() ForgeUI:Save() end
function Addon:OnUnlockButtonPressed() end
function Addon:OnDefaultsButtonPressed() ForgeUI:Reset() end

---------------------------------------------------------------------------------------------------
-- ForgeUI_Item Functions
---------------------------------------------------------------------------------------------------
function Addon:ItemListPressed( wndHandler, wndControl, eMouseButton )
	wndControl:SetCheck(true)
	
	-- menu item selection
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
	
	-- options window
	for k, v in pairs(self.wndOptionsHolder:GetChildren()) do
		v:Show(false, true)
	end
	
	local tData = wndControl:GetParent():GetData()
	
	if tData.wndOptions then
		tData.wndOptions:Show(true, false)
	end
end

function Addon:ItemListSignPressed( wndHandler, wndControl, eMouseButton )
	if wndControl:GetParent():FindChild("Holder"):IsShown() then
		wndControl:SetText("+")
		wndControl:GetParent():FindChild("Holder"):Show(false)
		
		local wndHolder = wndControl:GetParent():GetParent()
		local nLeft, nTop, nRight, nBottom = wndHolder:GetAnchorOffsets()
		wndHolder:SetAnchorOffsets(nLeft, nTop, nRight, nTop + 20)
	else
		wndControl:SetText("-")
		wndControl:GetParent():FindChild("Holder"):Show(true)
		
		local wndHolder = wndControl:GetParent():GetParent()
		local nLeft, nTop, nRight, nBottom = wndHolder:GetAnchorOffsets()
		wndHolder:SetAnchorOffsets(nLeft, nTop, nRight, nBottom + 20 * #wndControl:GetParent():FindChild("Holder"):GetChildren())
	end
	
	Inst.wndMenuHolder:ArrangeChildrenVert()
end

-----------------------------------------------------------------------------------------------
-- OnSave/OnRestore
-----------------------------------------------------------------------------------------------
--function Addon:OnSave(...) return ForgeUI:OnSave(...) end
--function Addon:OnRestore(...) ForgeUI:OnRestore(...) end

-----------------------------------------------------------------------------------------------
-- ForgeUI public api
-----------------------------------------------------------------------------------------------
function ForgeUI:API_AddMenuItem(tModule, strText, strWindow)
	local wndItem = Apollo.LoadForm(Inst.xmlDoc, "ForgeUI_Item", Inst.wndMenuHolder, Inst)
	wndItem:FindChild("Button"):SetText(strText)
	
	wndItem:AddEventHandler("ButtonCheck", "ItemListPressed", Inst)
	wndItem:AddEventHandler("ButtonUncheck", "ItemListPressed", Inst)
	wndItem:FindChild("Sign"):AddEventHandler("ButtonCheck", "ItemListSignPressed", Inst)
	wndItem:FindChild("Sign"):AddEventHandler("ButtonUncheck", "ItemListSignPressed", Inst)
	
	local tData = {}
	if strWindow then
		local wnd = Apollo.LoadForm(Inst.xmlOptions, "ForgeUI_Container", Inst.wndOptionsHolder, Inst)
		wnd:SetName(strWindow)
		
		if not tModule.tOptionHolders then tModule.tOptionHolders = {} end
		tModule.tOptionHolders[strWindow] = wnd
		
		tData.wndOptions = wnd
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
		local wnd = Apollo.LoadForm(Inst.xmlOptions, "ForgeUI_Container", Inst.wndOptionsHolder, Inst)
		wnd:SetName(strWindow)
		
		if not tModule.tOptionHolders then tModule.tOptionHolders = {} end
		tModule.tOptionHolders[strWindow] = wnd
		
		tData.wndOptions = wnd
	end
	
	wndItem:SetData(tData)

	wndParent:FindChild("Holder"):ArrangeChildrenVert()
	wndParent:FindChild("Holder"):SetAnchorOffsets(10, 0, 0, #wndParent:FindChild("Holder"):GetChildren() * 20)
	
	return wndItem
end

function ForgeUI:API_GetApiVersion() return API_VERSION end
function ForgeUI:API_GetVersion() return VERSION end

-- ForgeDB initialization
_G["ForgeDB"] = {}
_G["ForgeDB"]["profile"] = {}
_G["ForgeDB"]["global"] = {}
_G["ForgeDB"]["char"] = {}

-- ForgeLibs initialization
_G["ForgeLibs"] = {}
_G["ForgeLibs"]["ForgeUI"] = ForgeUI

Apollo.RegisterAddon(Inst, true, "ForgeUI", {})


