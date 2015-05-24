-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		movers.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI module for handling movers
-----------------------------------------------------------------------------------------------

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeUI GUI library
local ForgeUI = Apollo.GetAddon("ForgeUI")

-----------------------------------------------------------------------------------------------
-- ForgeUI Module Definition
-----------------------------------------------------------------------------------------------
local Movers = {
	_NAME = "movers",
	_API_VERSION = 3,
	
	tSettings = {
		profile = {

		},
		global = {
			nScope = 0,
		}
	}
}

-----------------------------------------------------------------------------------------------
-- Local variables
-----------------------------------------------------------------------------------------------
local bMoversActive = false
local tScopes = {
	["all"] = {},
	["general"] = {},
	["misc"] = {},
}

-----------------------------------------------------------------------------------------------
-- Local functions
-----------------------------------------------------------------------------------------------
local function RegisterMover(luaCaller, wnd, strKey, strName, strScope, tOptions)
	local nLeft, nTop, nRight, nBottom = wnd:GetAnchorOffsets()
	
	local wndMover
	local tData = {}
	
	if tScopes["all"][strKey] then
		wndMover = tScopes["all"][strKey]
	else
		wndMover = Apollo.LoadForm(ForgeUI.xmlDoc, "ForgeUI_Mover", nil, F)
		
		tScopes["all"][strKey] = wndMover
		if tScopes[strScope] then
			tScopes[strScope][strKey] = wndMover	
		end
		
		wndMover:SetAnchorPoints(wnd:GetAnchorPoints())
		wndMover:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
		
		if not Movers.tSettings.profile[luaCaller._NAME] then
			Movers.tSettings.profile[luaCaller._NAME] = {}
		end
		Movers.tSettings.profile[luaCaller._NAME][strKey] = { nLeft, nTop, nRight, nBottom }
		
		F:API_RegisterNamespaceDefaults(Movers, Movers.tSettings)
	end
	
	if not Movers._DB.profile[luaCaller._NAME] then
		Movers._DB.profile[luaCaller._NAME] = {}
	end
	
	if not Movers._DB.profile[luaCaller._NAME][strKey] then
		Movers._DB.profile[luaCaller._NAME][strKey] = {
			nLeft,
			nTop,
			nRight,
			nBottom,
		}
	else
		wndMover:SetAnchorOffsets(unpack(Movers._DB.profile[luaCaller._NAME][strKey]))
		wnd:SetAnchorOffsets(unpack(Movers._DB.profile[luaCaller._NAME][strKey]))
	end
	
	if tOptions then
		if tOptions.bNameAsTooltip then
			wndMover:SetTooltip(strName)
		end
	end
	
	if not tOptions or not tOptions.bNameAsTooltip then
		wndMover:SetText(strName)
	end
	
	tData.strParent = luaCaller._NAME
	tData.strKey = strKey
	tData.wndParent = wnd
	
	wndMover:SetData(tData)
end

local function UpdateMoverPosition(wndMover)
	local tData = wndMover:GetData()
	wndMover:SetAnchorOffsets(tData.wndParent:GetAnchorOffsets())
end

local function UpdateParentPosition(wndMover)
	local tData = wndMover:GetData()
	tData.wndParent:SetAnchorOffsets(wndMover:GetAnchorOffsets())
	
	local nLeft, nTop, nRight, nBottom = wndMover:GetAnchorOffsets()
	Movers._DB.profile[tData.strParent][tData.strKey] = {
		nLeft, nTop, nRight, nBottom,
	}
end

-----------------------------------------------------------------------------------------------
-- ForgeUI module functions
-----------------------------------------------------------------------------------------------
function Movers:ForgeAPI_Init()
	self.wndMoversForm = Apollo.LoadForm(ForgeUI.xmlDoc, "ForgeUI_MoversForm", nil, self)
	self.wndMoversForm:FindChild("SaveButton"):AddEventHandler("ButtonSignal", "LockMovers", self)
	self.wndMoversForm:FindChild("CancelButton"):AddEventHandler("ButtonSignal", "CancelChanges", self)

	local wndScope = G:API_AddComboBox(self, self.wndMoversForm:FindChild("Scope"), "Scope", nil, nil, {
		tOffsets = { 0, 0, 200, 25 },
		fnCallback = Movers.OnScopeSet,
	})
	G:API_AddOptionToComboBox(self, wndScope, "All", "all", { bDefault = true })
	G:API_AddOptionToComboBox(self, wndScope, "General", "general")
	G:API_AddOptionToComboBox(self, wndScope, "Misc", "misc")
	
	for k, v in pairs(tScopes["all"]) do
		UpdateParentPosition(v)
		
		v:Show(false)
	end
end

function Movers:ForgeAPI_LoadSettings()
	for _, v in pairs(tScopes["all"]) do
		local tData = v:GetData()
		
		v:SetAnchorOffsets(unpack(Movers._DB.profile[tData.strParent][tData.strKey]))
		tData.wndParent:SetAnchorOffsets(unpack(Movers._DB.profile[tData.strParent][tData.strKey]))
	end
end

function Movers:UnlockMovers()
	bMoversActive = true
	F:API_ShowMainWindow(false)
	self.wndMoversForm:Show(true)
	
	for k, v in pairs(tScopes["all"]) do
		UpdateMoverPosition(v)
	
		v:Show(true)
	end
end

function Movers:LockMovers()
	bMoversActive = false
	F:API_ShowMainWindow(true)
	self.wndMoversForm:Show(false)
	
	for k, v in pairs(tScopes["all"]) do
		UpdateParentPosition(v)
		
		v:Show(false)
	end
end

function Movers:CancelChanges()
	bMoversActive = false
	F:API_ShowMainWindow(true)
	self.wndMoversForm:Show(false)
	
	for k, v in pairs(tScopes["all"]) do
		v:Show(false)
	end
end

function Movers:OnScopeSet(strScope)
	if not tScopes[strScope] then return end

	for k, v in pairs(tScopes["all"]) do
		v:Show(false)
	end
	
	for k, v in pairs(tScopes[strScope]) do
		v:Show(true)
	end
end

function F:OnMoverMove(wndHandler, wndControl)
	local tData = wndControl:GetData()
	
	tData.wndParent:SetAnchorOffsets(wndControl:GetAnchorOffsets())
	tData.wndParent:SetAnchorPoints(wndControl:GetAnchorPoints())
end

function F:UnlockMovers() Movers:UnlockMovers() end
-----------------------------------------------------------------------------------------------
-- ForgeUI public API
-----------------------------------------------------------------------------------------------
function F:API_RegisterMover(...) return RegisterMover(...) end
function F:API_MoversActive() return bMoversActive end

Movers = F:API_NewModule(Movers)
