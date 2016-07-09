-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		ForgeUI.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI addon interface
-----------------------------------------------------------------------------------------------

require "Window"
require "ApolloTimer"

-----------------------------------------------------------------------------------------------
-- ForgeUI Module Definition
-----------------------------------------------------------------------------------------------
local ForgeUI = {}
local Addon = {}

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local AUTHOR = "Winty Badass@Jabbit"
local API_VERSION = 3

-- version
local MAJOR_VERSION = 0
local MINOR_VERSION = 5
local PATCH_VERSION = 0
local PATCH_SUFFIX = 1
local PATCH_SUFFIXES = {
	[-2] = "alpha", [-1] = "beta", [0] = "",
	[1] = "a", [2] = "b", [3] = "c",
	[4] = "d", [5] = "e", [6] = "f",
}

local VERSION = MAJOR_VERSION .. "." .. MINOR_VERSION

if PATCH_VERSION ~= 0 then
	VERSION = VERSION .. "." .. PATCH_VERSION
end

if PATCH_SUFFIX ~= 0 then
	VERSION = VERSION .. "-" .. PATCH_SUFFIXES[PATCH_SUFFIX]
end
-----------------------------------------------------------------------------------------------
-- Locals
-----------------------------------------------------------------------------------------------
local tStrata = {}
local TimerButtonDelay

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
local Addon = {}
Addon.__index = Addon

function Addon:new(o)
  o = o or {}
  setmetatable(o, Addon)

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

	TimerButtonDelay = ApolloTimer.Create(0.03, true, "OnTimerButtonDelay", self)
	TimerButtonDelay:Stop()
	
	-- create overlays
	tStrata = {
		World = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Overlay", "InWorldHudStratum", self),

		HudLow = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Overlay", "FixedHudStratumLow", self),
		Hud = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Overlay", "FixedHudStratum", self),
		HudHigh = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Overlay", "DefaultStratum", self),
		HudHighest = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Overlay", nil, self),
	}

	-- ForgeUI window initialization
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Form", nil, self)
	self.wndMenuHolder = self.wndMain:FindChild("ItemList")
	self.wndOptionsHolder = self.wndMain:FindChild("ItemContainer")

	self.wndMain:FindChild("AuthorText"):SetText(AUTHOR)
	self.wndMain:FindChild("VersionText"):SetText(VERSION)
	
	self.wndResetButton = self.wndMain:FindChild("DefaultsButton")
	--self.wndResetButton:Enable(false)
	self.wndResetButton:SetData({ nVal = 0 })
	self.wndResetButton:FindChild("ProgressBar"):SetMax(100)

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
function Addon:OnUnlockButtonPressed() ForgeUI:UnlockMovers() end

function Addon:OnDefaultsMouseEnter( wndHandler, wndControl, x, y )
	TimerButtonDelay:Start()
end

function Addon:OnDefaultsExit( wnd )
	if wnd:GetName() ~= "ProgressBar" then return end
	self.wndResetButton:SetData({ nVal = 0 })
	TimerButtonDelay:Stop()
	wnd:SetProgress(0)
end

function Addon:OnDefaultsSignal( wndHandler )
	if wndHandler:GetName() ~= "ProgressBar" then return end
	if self.wndResetButton:GetData().nVal > 100 then ForgeUI:Reset() end
end

function Addon:OnTimerButtonDelay()
	local tmp = self.wndResetButton:GetData().nVal
	self.wndResetButton:SetData({ nVal = tmp + 1 })
	self.wndResetButton:FindChild("ProgressBar"):SetProgress(tmp)
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_Item Functions
---------------------------------------------------------------------------------------------------
function Addon:ItemListPressed(wndHandler, wndControl, eMouseButton)
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
		tData.wndOptions:Show(true, true)
	else
		if not wndControl:GetParent():FindChild("Holder"):IsShown() then
			self:ItemListSignPressed(wndHandler, wndControl:FindChild("Sign"), eMouseButton)
		end
		self:ItemListPressed(wndHandler, wndControl:GetParent():FindChild("Holder"):GetChildren()[1]:FindChild("Button"), eMouseButton)
	end
end

function Addon:ItemListSignPressed(wndHandler, wndControl, eMouseButton)
	local wndHolder = wndControl:GetParent():GetParent()
	local wndContainer = wndControl:GetParent():GetParent():FindChild("Holder")

	if wndContainer:IsShown() then
		wndControl:SetText("+")
		wndContainer:Show(false, true)

		local nLeft, nTop, nRight, nBottom = wndHolder:GetAnchorOffsets()
		wndHolder:SetAnchorOffsets(nLeft, nTop, nRight, nTop + 20)
	else
		wndControl:SetText("-")
		wndContainer:Show(true, true)

		local nLeft, nTop, nRight, nBottom = wndHolder:GetAnchorOffsets()
		wndHolder:SetAnchorOffsets(nLeft, nTop, nRight, nBottom + 20 * #wndContainer:GetChildren())
	end

	Inst:SortItemsByPriority()
end

function Addon:SortItemsByPriority()
	local wndHolder = self.wndMenuHolder
	wndHolder:ArrangeChildrenVert() -- hack to allow scrolling

	local tAll = {
		high = {},
		normal = {},
		low = {},
		slow = {},
	}

	for k, v in pairs(wndHolder:GetChildren()) do
		local tData = v:GetData()

		if not tData.strPriotiy then tData.strPriotiy = "normal" end
		table.insert(tAll[tData.strPriotiy], v)
	end

	local nPos = 0
	for k, v in pairs(tAll.high) do
		local nLeft, nTop, nRight, nBottom = v:GetAnchorOffsets()
		nTop = nPos
		nPos = nPos + v:GetHeight()
		nBottom = nPos
		v:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
	end

	for k, v in pairs(tAll.normal) do
		local nLeft, nTop, nRight, nBottom = v:GetAnchorOffsets()
		nTop = nPos
		nPos = nPos + v:GetHeight()
		nBottom = nPos
		v:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
	end

	for k, v in pairs(tAll.low) do
		local nLeft, nTop, nRight, nBottom = v:GetAnchorOffsets()
		nTop = nPos
		nPos = nPos + v:GetHeight()
		nBottom = nPos
		v:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
	end

	for k, v in pairs(tAll.slow) do
		local nLeft, nTop, nRight, nBottom = v:GetAnchorOffsets()
		nTop = nPos
		nPos = nPos + v:GetHeight()
		nBottom = nPos
		v:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
	end
end

-----------------------------------------------------------------------------------------------
-- ForgeUI public api
-----------------------------------------------------------------------------------------------
function ForgeUI:API_AddMenuItem(tModule, strText, strWindow, tOptions)
	local wndItem = Apollo.LoadForm(Inst.xmlDoc, "ForgeUI_Item", Inst.wndMenuHolder, Inst)
	wndItem:FindChild("Button"):SetText(strText)

	wndItem:AddEventHandler("ButtonCheck", "ItemListPressed", Inst)
	wndItem:AddEventHandler("ButtonUncheck", "ItemListPressed", Inst)
	wndItem:FindChild("Sign"):AddEventHandler("ButtonCheck", "ItemListSignPressed", Inst)
	wndItem:FindChild("Sign"):AddEventHandler("ButtonUncheck", "ItemListSignPressed", Inst)

	local tData = {
		strPriority = "normal"
	}

	if strWindow then
		local wnd = Apollo.LoadForm(Inst.xmlOptions, "ForgeUI_Container", Inst.wndOptionsHolder, Inst)
		wnd:SetName(strWindow)

		if not tModule.tOptionHolders then tModule.tOptionHolders = {} end
		tModule.tOptionHolders[strWindow] = wnd

		tData.wndOptions = wnd
	end

	if tOptions then
		tData.strPriotiy = tOptions.strPriority or "normal"
	end

	wndItem:SetData(tData)

	Inst:SortItemsByPriority()

	if tOptions and tOptions.bDefault then
		Inst:ItemListPressed(wndItem, wndItem:FindChild("Button"))
	end

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

	return wndItem
end

function ForgeUI:API_ShowMainWindow(bShow) Inst.wndMain:Show(bShow, true) end
function ForgeUI:API_GetApiVersion() return API_VERSION end
function ForgeUI:API_GetVersion() return VERSION end
function ForgeUI:API_GetVersions()
	return {
		major = MAJOR_VERSION,
		minor = MINOR_VERSION,
		patch = PATCH_VERSION,
		suffix = PATCH_SUFFIX,
	}
end
function ForgeUI:API_GetStratum(strName) return tStrata[strName] or tStrata["HudLow"] end
function ForgeUI:API_GetStrata()
	local t = {}
	for k, _ in pairs(tStrata) do table.insert(t, k) end
	return t
end

-- ForgeDB initialization
_G["ForgeDB"] = {}
_G["ForgeDB"]["profile"] = {}
_G["ForgeDB"]["global"] = {}
_G["ForgeDB"]["char"] = {}

-- ForgeLibs initialization
_G["ForgeLibs"] = {}
_G["ForgeLibs"]["Forge"] = Addon
_G["ForgeLibs"]["ForgeUI"] = ForgeUI

_G["F"] = ForgeUI

Apollo.RegisterAddon(Inst, true, "ForgeUI", {})
