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
		  nAltCurrency = 7,
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
local karCurrency =  	
{
	{eType = Money.CodeEnumCurrencyType.Renown, 					strTitle = Apollo.GetString("CRB_Renown"), 						strDescription = Apollo.GetString("CRB_Renown_Desc")},
	{eType = Money.CodeEnumCurrencyType.ElderGems, 					strTitle = Apollo.GetString("CRB_Elder_Gems"), 					strDescription = Apollo.GetString("CRB_Elder_Gems_Desc")},
	{eType = Money.CodeEnumCurrencyType.Glory, 						strTitle = Apollo.GetString("CRB_Glory"), 						strDescription = Apollo.GetString("CRB_Glory_Desc")},
	{eType = Money.CodeEnumCurrencyType.Prestige, 					strTitle = Apollo.GetString("CRB_Prestige"), 					strDescription = Apollo.GetString("CRB_Prestige_Desc")},
	{eType = Money.CodeEnumCurrencyType.CraftingVouchers, 			strTitle = Apollo.GetString("CRB_Crafting_Vouchers"), 			strDescription = Apollo.GetString("CRB_Crafting_Voucher_Desc")},
	{eType = Money.CodeEnumCurrencyType.ShadeSilver,				strTitle = Apollo.GetString("CRB_ShadeSilver"),					strDescription = Apollo.GetString("CRB_ShadeSilver_Desc")},
	{eType = AccountItemLib.CodeEnumAccountCurrency.Omnibits, 		strTitle = Apollo.GetString("CRB_OmniBits"), 					strDescription = Apollo.GetString("CRB_OmniBits_Desc"), bAccountItem = true},
	{eType = AccountItemLib.CodeEnumAccountCurrency.ServiceToken, 	strTitle = Apollo.GetString("AccountInventory_ServiceToken"), 	strDescription = Apollo.GetString("AccountInventory_ServiceToken_Desc"), bAccountItem = true},
	{eType = AccountItemLib.CodeEnumAccountCurrency.MysticShiny, 	strTitle = Apollo.GetString("CRB_FortuneCoin"), 				strDescription = Apollo.GetString("CRB_FortuneCoin_Desc"), bAccountItem = true},
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

	self.nAltCurrencySelected = self._DB.char.nAltCurrency

	self.wndInfoBar = Apollo.LoadForm(self.xmlDoc, "ForgeUI_InfoBar", "FixedHudStratumLow", self)
	self.wndCurrencyDisplay = Apollo.LoadForm(self.xmlDoc, "ForgeUI_ConfigureCurrency", nil, self)
	self.wndCurrencyDisplayList = self.wndCurrencyDisplay:FindChild("ForgeUI_ConfigureCurrencyList")
	self.wndInfoBar:FindChild("ForgeUI_CurrencyButton"):AttachWindow(self.wndCurrencyDisplay)

	self:SetupInfos()

	_UpdateTimer = ApolloTimer.Create(self._DB.global.fUpdatePeriod, true, "OnUpdate", self)

	Apollo.RegisterEventHandler("AccountCurrencyChanged", "OnPlayerCurrencyChanged", self)
	Apollo.RegisterEventHandler("PlayerCurrencyChanged", "OnPlayerCurrencyChanged", self)
	Apollo.RegisterEventHandler("CharacterCreated",  "OnCharacterCreated", self)

	--Alt Curency Display
	for idx = 1, #karCurrency do
		local tData = karCurrency[idx]
		local wnd
		wnd = Apollo.LoadForm(self.xmlDoc, "ForgeUI_PickerEntry", self.wndCurrencyDisplayList, self)
		
		if tData.bAccountItem then
			wnd:FindChild("ForgeUI_EntryCash"):SetMoneySystem(Money.CodeEnumCurrencyType.GroupCurrency, 0, 0, tData.eType)
		else
			wnd:FindChild("ForgeUI_EntryCash"):SetMoneySystem(tData.eType)
		end
		wnd:FindChild("ForgeUI_PickerEntryBtn"):SetData(idx)
		wnd:FindChild("ForgeUI_PickerEntryBtn"):SetCheck(idx == self.nAltCurrencySelected)
		wnd:FindChild("ForgeUI_PickerEntryBtn"):SetText(tData.strTitle)
		
		local strDescription = tData.strDescription
		if tData.eType == AccountItemLib.CodeEnumAccountCurrency.Omnibits then
			local tOmniBitInfo = GameLib.GetOmnibitsBonusInfo()
			local nTotalWeeklyOmniBitBonus = tOmniBitInfo.nWeeklyBonusMax - tOmniBitInfo.nWeeklyBonusEarned;
			if nTotalWeeklyOmniBitBonus < 0 then
				nTotalWeeklyOmniBitBonus = 0
			end
		strDescription = strDescription.."\n"..String_GetWeaselString(Apollo.GetString("CRB_OmniBits_EarningsWeekly"), nTotalWeeklyOmniBitBonus)
		end
		wnd:FindChild("ForgeUI_PickerEntryBtn"):SetTooltip(strDescription)
		tData.wnd = wnd
	end
	self.wndCurrencyDisplayList:ArrangeChildrenVert(Window.CodeEnumArrangeOrigin.LeftOrTop)
	self:UpdateAltCashDisplay()
	self.xmlDoc = nil
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

function ForgeUI_InfoBar:OnCurrencyPanelToggle() -- OptionsBtn
	for key, wndCurr in pairs(self.wndCurrencyDisplayList:GetChildren()) do
		self:UpdateAltCash(wndCurr)
	end
end

function ForgeUI_InfoBar:OnCharacterCreated()
	self:UpdateAltCashDisplay()
end

function ForgeUI_InfoBar:OnPlayerCurrencyChanged()
	self:UpdateAltCashDisplay()
end

function ForgeUI_InfoBar:UpdateAltCashDisplay()
	local tData = karCurrency[self.nAltCurrencySelected]
	self.wndInvokeForm:FindChild("AltCash"):SetAmount(self:HelperGetCurrencyAmmount(tData), true)
	self.wndInfoBar:FindChild("Background"):FindChild("Cash"):SetAmount(GameLib.GetPlayerCurrency(), true)
end

-----------------------------------------------------------------------------------------------
-- Alt Currency Window Functions
-----------------------------------------------------------------------------------------------
function ForgeUI_InfoBar:UpdateAltCash(wndHandler, wndControl) -- Also from PickerEntryBtn
	local nSelected = wndHandler:FindChild("ForgeUI_PickerEntryBtn"):GetData()
	local tData = karCurrency[nSelected]

	if wndHandler:FindChild("ForgeUI_PickerEntryBtn"):IsChecked() then
		self.nAltCurrencySelected = nSelected
		self._DB.char.nAltCurrency = nSelected
	end
	
	self:UpdateAltCashDisplay()

	tData.wnd:FindChild("ForgeUI_EntryCash"):SetAmount(self:HelperGetCurrencyAmmount(tData), true)
	if self.wndCurrencyDisplay:IsShown() then
		self.wndCurrencyDisplay:Show(false)
	end
end

function ForgeUI_InfoBar:UpdateAltCashDisplay()
	local tData = karCurrency[self.nAltCurrencySelected]
	self.wndInfoBar:FindChild("Background"):FindChild("AltCash"):SetAmount(self:HelperGetCurrencyAmmount(tData), true)
	self.wndInfoBar:FindChild("Background"):FindChild("Cash"):SetAmount(GameLib.GetPlayerCurrency(), true)

	local strDescription = tData.strDescription
	if tData.eType == AccountItemLib.CodeEnumAccountCurrency.Omnibits then
		local tOmniBitInfo = GameLib.GetOmnibitsBonusInfo()
		local nTotalWeeklyOmniBitBonus = tOmniBitInfo.nWeeklyBonusMax - tOmniBitInfo.nWeeklyBonusEarned;
		if nTotalWeeklyOmniBitBonus < 0 then
			nTotalWeeklyOmniBitBonus = 0
		end
		strDescription = strDescription.."\n"..String_GetWeaselString(Apollo.GetString("CRB_OmniBits_EarningsWeekly"), nTotalWeeklyOmniBitBonus)
	end
end

function ForgeUI_InfoBar:HelperGetCurrencyAmmount(tData)
	local monAmount = 0
	if tData.bAccountItem then
		monAmount = AccountItemLib.GetAccountCurrency(tData.eType)
	else
		monAmount = GameLib.GetPlayerCurrency(tData.eType)
	end
	return monAmount
end

-----------------------------------------------------------------------------------------------
-- ForgeUI addon registration
-----------------------------------------------------------------------------------------------
F:API_NewAddon(ForgeUI_InfoBar)
