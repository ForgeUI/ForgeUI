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
	_VERSION = "1.0",

	tSettings = {
		profile = {

		},
		global = {
			nScope = 1,
			nGridSize = 25,
		}
	}
}

-----------------------------------------------------------------------------------------------
-- Local variables
-----------------------------------------------------------------------------------------------
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
		if tOptions and tOptions.strParent and tScopes["all"][tOptions.strParent] then
			wndMover = Apollo.LoadForm(ForgeUI.xmlDoc, "ForgeUI_Mover", tScopes["all"][tOptions.strParent], F)
		else
			if tOptions and tOptions.strStratum then
				wndMover = Apollo.LoadForm(ForgeUI.xmlDoc, "ForgeUI_Mover", "FixedHudStratum" .. tOptions.strStratum, F)
			else
				wndMover = Apollo.LoadForm(ForgeUI.xmlDoc, "ForgeUI_Mover", "FixedHudStratum", F)
			end
		end

		if tOptions then
			if tOptions.bSizable ~= nil then
				wndMover:SetStyle("Sizable", tOptions.bSizable)
			end
		end

		tScopes["all"][strKey] = wndMover
		if tScopes[strScope] then
			tScopes[strScope][strKey] = wndMover
			tData.strScope = strScope
		end

		wndMover:SetAnchorPoints(wnd:GetAnchorPoints())
		wndMover:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
		wndMover:DestroyChildren()
		wndMover:AddEventHandler("MouseButtonDown", "OnMoverClick", F)

		local wndPos = Apollo.LoadForm(ForgeUI.xmlDoc, "ForgeUI_Positionator", wndMover, F)

		wndPos:FindChild("Move:Left"):AddEventHandler("ButtonSignal", "OnMoverPosButtonClick", F)
		wndPos:FindChild("Move:Up"):AddEventHandler("ButtonSignal", "OnMoverPosButtonClick", F)
		wndPos:FindChild("Move:Right"):AddEventHandler("ButtonSignal", "OnMoverPosButtonClick", F)
		wndPos:FindChild("Move:Down"):AddEventHandler("ButtonSignal", "OnMoverPosButtonClick", F)
		wndPos:FindChild("Size:Width:Up"):AddEventHandler("ButtonSignal", "OnMoverSizeButtonClick", F)
		wndPos:FindChild("Size:Width:Down"):AddEventHandler("ButtonSignal", "OnMoverSizeButtonClick", F)
		wndPos:FindChild("Size:Height:Up"):AddEventHandler("ButtonSignal", "OnMoverSizeButtonClick", F)
		wndPos:FindChild("Size:Height:Down"):AddEventHandler("ButtonSignal", "OnMoverSizeButtonClick", F)

		wndPos:FindChild("Size:Height:Text"):SetText("Height: " .. wndMover:GetHeight())
		wndPos:FindChild("Size:Width:Text"):SetText("Width: " .. wndMover:GetWidth())

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
	elseif Movers._DB.profile[luaCaller._NAME][strKey] then
		nLeft, nTop, nRight, nBottom = unpack(Movers._DB.profile[luaCaller._NAME][strKey])
		if nLeft and nTop and nRight and nBottom then
			wndMover:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
			wnd:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
		end
	end

	if tOptions then
		if tOptions.bNameAsTooltip then
			wndMover:SetTooltip(strName)
		end
	end

	if not tOptions or not tOptions.bNameAsTooltip then
		wndMover:SetText(strName)
	end

	tData.wndMover = wndMover
	tData.strParent = luaCaller._NAME
	tData.strKey = strKey
	tData.wndParent = wnd

	wndMover:SetData(tData)
end

local function ResetMover(luaCaller, strKey)
	if Movers._DB.profile[luaCaller._NAME] then
		Movers._DB.profile[luaCaller._NAME][strKey] = nil
	end
end

local function DestroyMover(luaCaller, strKey)
	ResetMover(luaCaller, strKey)
	if tScopes["all"][strKey] then
		tScopes["all"][strKey]:Destroy()
		for k in pairs(tScopes) do
			tScopes[k][strKey] = nil
		end
	end
end

local function UpdateMoverPosition(wndMover)
	local tData = wndMover:GetData()
	wndMover:SetAnchorOffsets(tData.wndParent:GetAnchorOffsets())

	local nLeft, nTop, nRight, nBottom = wndMover:GetAnchorOffsets()
	Movers._DB.profile[tData.strParent][tData.strKey] = {
		nLeft, nTop, nRight, nBottom,
	}
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
	self.wndGrid = Apollo.LoadForm(ForgeUI.xmlDoc, "ForgeUI_MoversGrid", "FixedHudStratumLow", self)

	self.strScope = "general"
	local wndScope = G:API_AddComboBox(self, self.wndMoversForm:FindChild("Scope"), "Scope", nil, nil, {
		tOffsets = { 0, 0, 200, 25 },
		fnCallback = Movers.OnScopeSet,
	})
	G:API_AddOptionToComboBox(self, wndScope, "All", "all")
	G:API_AddOptionToComboBox(self, wndScope, "General", "general", { bDefault = true })
	G:API_AddOptionToComboBox(self, wndScope, "Misc", "misc")

	self.wndShowGrid = G:API_AddCheckBox(self, self.wndMoversForm:FindChild("Grid"), "Show grid", nil, nil, {
		fnCallback = (function(...)
			self.wndGrid:Show(self.wndShowGrid:IsChecked() or self.wndShowFill:IsChecked(), true)
			self:GenerateGrid()
		end),
	}):FindChild("CheckBox")

	self.wndShowFill = G:API_AddCheckBox(self, self.wndMoversForm:FindChild("Grid"), "Fill background", nil, nil, {
		tMove = { 0, 30 },
		fnCallback = (function(...)
			self.wndGrid:Show(self.wndShowGrid:IsChecked() or self.wndShowFill:IsChecked(), true)
			self:GenerateGrid()
		end),
	}):FindChild("CheckBox")

	G:API_AddNumberBox(self, self.wndMoversForm:FindChild("Grid"), "Grid size", self._DB.global, "nGridSize", {
		tMove = { 150, 0 }, fnCallback = self.GenerateGrid,
	})

	for k, v in pairs(tScopes["all"]) do
		UpdateParentPosition(v)

		v:Show(false, true)
	end

	self:GenerateGrid()
end

function Movers:ForgeAPI_LoadSettings()
	for _, v in pairs(tScopes["all"]) do
		local tData = v:GetData()

		if not Movers._DB.profile[tData.strParent] or not Movers._DB.profile[tData.strParent][tData.strKey] then
			Print(tData.strKey)
			v:Destroy()
			break
		end


		v:SetAnchorOffsets(unpack(Movers._DB.profile[tData.strParent][tData.strKey]))
		tData.wndParent:SetAnchorOffsets(unpack(Movers._DB.profile[tData.strParent][tData.strKey]))
	end
end

function Movers:UnlockMovers()
	F:API_ShowMainWindow(false, true)
	self.wndMoversForm:Show(true, true)

	for _, v in pairs(F:API_GetStrata()) do
		F:API_GetStratum(v):Show(false, true)
	end

	local strScope = self.strScope or "general"
	for k, v in pairs(tScopes[strScope]) do
		UpdateMoverPosition(v)

		v:Show(true, true)
	end
end

function Movers:LockMovers()
	F:API_ShowMainWindow(true)
	self.wndMoversForm:Show(false, true)
	self.wndGrid:Show(false, true)
	self.wndShowGrid:SetCheck(false)
	self.wndShowFill:SetCheck(false)

	for _, v in pairs(F:API_GetStrata()) do
		F:API_GetStratum(v):Show(true, true)
	end

	for k, v in pairs(tScopes["all"]) do
		UpdateParentPosition(v)

		v:Show(false, true)
	end
end

function Movers:CancelChanges()
	F:API_ShowMainWindow(true)
	self.wndMoversForm:Show(false, true)
	self.wndGrid:Show(false, true)
	self.wndShowGrid:SetCheck(false)
	self.wndShowFill:SetCheck(false)

	for _, v in pairs(F:API_GetStrata()) do
		F:API_GetStratum(v):Show(true, true)
	end

	for k, v in pairs(tScopes["all"]) do
		v:Show(false, true)
	end
end

function Movers:OnScopeSet(strScope)
	if not tScopes[strScope] then return end

	self.strScope = strScope

	for k, v in pairs(tScopes["all"]) do
		v:Show(false, true)
	end

	for k, v in pairs(tScopes[strScope]) do
		v:Show(true, true)
	end
end

function Movers:GenerateGrid()
	self.wndGrid:DestroyAllPixies()

	local nHeight = self.wndGrid:GetHeight()
	local nWidth = self.wndGrid:GetWidth()
	local nStep = self._DB.global.nGridSize

	if self.wndShowFill:IsChecked() then
		self.wndGrid:AddPixie({
			bLine = false,
			strSprite = "WhiteFill",
			cr = "FFFFFFFF",
			loc = {
				fPoints = {0, 0, 1, 1},
				nOffsets = {0, 0, 0, 0},
			},
		})
	end

	if self.wndShowGrid:IsChecked() then
		local tPixie = {}
		for i = 0, nWidth / 2, nStep do
			tPixie = {
				bLine = false,
				strSprite = "WhiteFill",
				cr = "FF00FF00",
				loc = {
					fPoints = {0, 0, 0, 1},
					nOffsets = {nWidth / 2 + i, 0, nWidth / 2 + i + 1, 0},
				},
			}

			if i == 0 then
				tPixie.cr = "FFFF0000"
			end

			self.wndGrid:AddPixie(tPixie)
			tPixie.loc.nOffsets = {nWidth / 2 - (i + 1), 0, nWidth / 2 - i, 0}
			self.wndGrid:AddPixie(tPixie)
		end

		for i = 0, nHeight / 2, nStep do
			tPixie = {
				bLine = false,
				strSprite = "WhiteFill",
				cr = "FF00FF00",
				loc = {
					fPoints = {0, 0, 1, 0},
					nOffsets = {0, nHeight / 2 + i, 0, nHeight / 2 + i + 1},
				},
			}

			if i == 0 then
				tPixie.cr = "FFFF0000"
			end

			self.wndGrid:AddPixie(tPixie)
			tPixie.loc.nOffsets = {0, nHeight / 2 - (i + 1), 0, nHeight / 2 - i}
			self.wndGrid:AddPixie(tPixie)
		end
	end
end

function F:OnMoverMove(wndHandler, wndControl)
	local tData = wndControl:GetData()

	tData.wndParent:SetAnchorOffsets(wndControl:GetAnchorOffsets())
	tData.wndParent:SetAnchorPoints(wndControl:GetAnchorPoints())
end

function F:OnMoverClick(wndHandler, wndControl, eMouseButton)
	local wndPos = wndControl:FindChild("ForgeUI_Positionator")
	if not wndPos then return end
	if eMouseButton ~= GameLib.CodeEnumInputMouse.Right then return end

	wndPos:Show(true, true)
end

function F:OnMoverPosButtonClick(wndHandler, wndControl)
	local wndMover = wndControl:GetParent():GetParent():GetParent()
	local strName = wndControl:GetName()

	local nLeft, nTop, nRight, nBottom = wndMover:GetAnchorOffsets()

	if strName == "Left" then
		wndMover:SetAnchorOffsets(nLeft - 1, nTop, nRight - 1, nBottom)
	elseif strName == "Up" then
		wndMover:SetAnchorOffsets(nLeft, nTop - 1, nRight, nBottom - 1)
	elseif strName == "Right" then
		wndMover:SetAnchorOffsets(nLeft + 1, nTop, nRight + 1, nBottom)
	elseif strName == "Down" then
		wndMover:SetAnchorOffsets(nLeft, nTop + 1, nRight, nBottom + 1)
	end
end

function F:OnMoverSizeButtonClick(wndHandler, wndControl)
	local wndMover = wndControl:GetParent():GetParent():GetParent():GetParent()
	local strName = wndControl:GetName()
	local strParentName = wndControl:GetParent():GetName()

	local nLeft, nTop, nRight, nBottom = wndMover:GetAnchorOffsets()

	if strParentName == "Height" then
		if strName == "Up" then
			wndMover:SetAnchorOffsets(nLeft, nTop, nRight, nBottom + 1)
		elseif strName == "Down" then
			wndMover:SetAnchorOffsets(nLeft, nTop, nRight, nBottom - 1)
		end
		wndControl:GetParent():FindChild("Text"):SetText("Height: " .. wndMover:GetHeight())
	elseif strParentName == "Width" then
		if strName == "Up" then
			wndMover:SetAnchorOffsets(nLeft, nTop, nRight + 1, nBottom)
		elseif strName == "Down" then
			wndMover:SetAnchorOffsets(nLeft, nTop, nRight - 1, nBottom)
		end
		wndControl:GetParent():FindChild("Text"):SetText("Width: " .. wndMover:GetWidth())
	end
end

function F:UnlockMovers() Movers:UnlockMovers() end
-----------------------------------------------------------------------------------------------
-- ForgeUI public API
-----------------------------------------------------------------------------------------------
function F:API_RegisterMover(...) return RegisterMover(...) end
function F:API_ResetMover(...) return ResetMover(...) end
function F:API_DestroyMover(...) return DestroyMover(...) end
function F:API_UpdateMover(strKey) UpdateMoverPosition(tScopes["all"][strKey]) end

Movers = F:API_NewModule(Movers)
