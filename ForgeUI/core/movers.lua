-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		movers.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI module for handling movers
-----------------------------------------------------------------------------------------------

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
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
	},
}

-----------------------------------------------------------------------------------------------
-- Local variables
-----------------------------------------------------------------------------------------------
local bMoversActive = false
local tOverlays = {
	["all"] = {},
}

-----------------------------------------------------------------------------------------------
-- Local functions
-----------------------------------------------------------------------------------------------
local function OnParentMove(wndHandler, wndControl)

end

local function RegisterMover(luaCaller, wnd, strKey, strName, strOverlay, tOptions)
	if true then return wnd end

	local nLeft, nTop, nRight, nBottom = wnd:GetAnchorOffsets()
	
	Movers.tSettings.profile[luaCaller._NAME] = {}
	Movers.tSettings.profile[luaCaller._NAME][strKey] = {
		nLeft,
		nTop,
		nRight,
		nBottom,
	}
	
	--_G["test"] = _G["test"] .. " A"
	--F:SetupDefaults(Movers)
	--_G["test"] = _G["test"] .. "C "
end

local function UpdatePosition(wndMover)
	local tData = wndMover:GetData()
	wndMover:SetAnchorOffsets(tData.wndParent:GetAnchorOffsets())
end

-----------------------------------------------------------------------------------------------
-- ForgeUI module functions
-----------------------------------------------------------------------------------------------
function Movers:ForgeAPI_Init()

end

function Movers:UnlockMovers()
	bMoversActive = true
	
	for k, v in pairs(tOverlays["all"]) do
		UpdatePosition(v)
	
		v:Show(true)
	end
end

function Movers:LockMovers()
	bMoversActive = false
	for k, v in pairs(tOverlays["all"]) do
		local tData = v:GetData()
	
		local nLeft, nTop, nRight, nBottom = v:GetAnchorOffsets()
		Movers._DB.profile[tData.strParent][tData.strKey] = {
			nLeft, nTop, nRight, nBottom,
		}
	
		v:Show(false)
	end
end

function F:OnMoverMove(wndHandler, wndControl)
	local tData = wndControl:GetData()
	
	tData.wndParent:SetAnchorOffsets(wndControl:GetAnchorOffsets())
	tData.wndParent:SetAnchorPoints(wndControl:GetAnchorPoints())
end

-----------------------------------------------------------------------------------------------
-- ForgeUI public API
-----------------------------------------------------------------------------------------------
function F:API_RegisterMover(...) return RegisterMover(...) end
function F:API_MoversActive() return bMoversActive end

Movers = F:API_NewModule(Movers)
