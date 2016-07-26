----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI addon
--
-- name: 		ForgeUI_InfoBar.lua
-- author:		Winty Badass@Jabbit
-- about:		Info bar addon for ForgeUI
-----------------------------------------------------------------------------------------------

require "Window"

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI

local Util = F:API_GetModule("util")

-----------------------------------------------------------------------------------------------
-- ForgeUI Addon Definition
-----------------------------------------------------------------------------------------------
local ForgeUI_InfoBar = {
	_NAME = "ForgeUI_InfoBar",
	_API_VERSION = 3,
	_VERSION = "2.0",
	DISPLAY_NAME = "Info bar",

	tSettings = {
		global = {
			fUpdatePeriod = 0.5
		},
		char = {
		tInfos = {
				[1] = "XP",
				[2] = "FPS",
				[3] = "PING",
			}
		}
	}
}
-----------------------------------------------------------------------------------------------
-- Locals
-----------------------------------------------------------------------------------------------
local _UpdateTimer
local tWndInfos = {}
local tInfos = {
	["XP"] = {
		strKey = "XP",
		nWidth = 70,
		fnDraw = nil,
	},
	["FPS"] = {
		strKey = "FPS",
		nWidth = 65,
		fnDraw = nil,
	},
	["PING"] = {
		strKey = "PING",
		nWidth = 65,
		fnDraw = nil,
	},
}

-----------------------------------------------------------------------------------------------
-- ForgeAPI
-----------------------------------------------------------------------------------------------
function ForgeUI_InfoBar:ForgeAPI_Init()
	self.xmlDoc = XmlDoc.CreateFromFile("..//ForgeUI_InfoBar//ForgeUI_InfoBar.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_InfoBar OnDocLoaded
-----------------------------------------------------------------------------------------------
function ForgeUI_InfoBar:OnDocLoaded()
	self.unitPlayer = GameLib.GetPlayerUnit()

	self.wndInfoBar = Apollo.LoadForm(self.xmlDoc, "ForgeUI_InfoBar", F:API_GetStratum("Hud"), self)
	F:API_RegisterMover(self, self.wndInfoBar, "Infobar", "Info bar", "general")

	self:SetupInfos()

	_UpdateTimer = ApolloTimer.Create(self._DB.global.fUpdatePeriod, true, "OnUpdate", self)
end

function ForgeUI_InfoBar:SetupInfos()
	local wnd = self.wndInfoBar:FindChild("Background"):FindChild("List")
	wnd:DestroyChildren()
	tWndInfos = {}

	for k, v in pairs(self._DB.char.tInfos) do
		tWndInfos[v] = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Info", wnd, self)
		tWndInfos[v]:SetAnchorOffsets(0, 0, tInfos[v].nWidth, 0)
	end

	wnd:ArrangeChildrenHorz()
end

function ForgeUI_InfoBar:OnUpdate()
	for k, v in pairs(tWndInfos) do
		v:SetText(tInfos[k].fnDraw())
	end
end

-----------------------------------------------------------------------------------------------
-- Draw functions
-----------------------------------------------------------------------------------------------
local GetFrameRate = GameLib.GetFrameRate
tInfos.FPS.fnDraw = function()
	return Util:Round(GetFrameRate(), 0) .. " fps"
end

local GetPing = GameLib.GetLatency
tInfos.PING.fnDraw = function()
	return Util:Round(GetPing(), 0) .. " ms"
end

tInfos.XP.fnDraw = function()
	if not GameLib.GetPlayerUnit() then return end

	local stats = GameLib.GetPlayerUnit():GetBasicStats()
	if stats == nil then return end

	local restedXP = GetRestXp()
	local currentXP
	local neededXP
	if stats.nLevel == 50 then
		currentXP = GetPeriodicElderPoints()
		neededXP = GameLib.ElderPointsDailyMax
	else
		currentXP = GetXp() - GetXpToCurrentLevel()
		neededXP = GetXpToNextLevel()
	end

	return Util:Round(currentXP / neededXP * 100, 1) .. "% XP"
end

-----------------------------------------------------------------------------------------------
-- API
-----------------------------------------------------------------------------------------------
function ForgeUI_InfoBar:OnForgeButton() F:API_ShowMainWindow(true) end

-----------------------------------------------------------------------------------------------
-- ForgeUI addon registration
-----------------------------------------------------------------------------------------------
F:API_NewAddon(ForgeUI_InfoBar)
