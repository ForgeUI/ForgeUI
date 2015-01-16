require "Window"
 
local ForgeUI = {}
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
VERSION = "0.2.0"
AUTHOR = "WintyBadass"
API_VERSION = 1

-- errors
ERR_ADDON_REGISTERED = 0
ERR_ADDON_NOT_REGISTERED = 1
ERR_WRONG_API = 2

-----------------------------------------------------------------------------------------------
-- Variables
-----------------------------------------------------------------------------------------------
local tAddons = {} 
local bCanRegisterAddons = false
local tAddonsToRegister = {}

local wndItemList = nil
local wndActiveItem = nil
local wndItemContainer = nil
local wndItemContainer2 = nil

local tItemList_Items = {}
local tRegisteredWindows = {} -- saving windows for repositioning them later

-----------------------------------------------------------------------------------------------
-- Settings
-----------------------------------------------------------------------------------------------
local resetDefaults = false

local tSettings_addons = {}
local tSettings_windowsPositions = {}
local tSettings = {
	apiVersion = API_VERSION,
	masterColor = "xkcdFireEngineRed",
	classColors = {
		engineer = "EFAB48",
		esper = "1591DB",
		medic = "FFE757",
		spellslinger = "98C723",
		stalker = "D23EF4",
		warrior = "F54F4F"
	}
}

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function ForgeUI:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 
	
	self.wndContainers = {}	

    return o
end

local ForgeUIInst = ForgeUI:new()

function ForgeUI:Init()
	local bHasConfigureFunction = true
	local strConfigureButtonText = "ForgeUI"
	local tDependencies = {

	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end

-----------------------------------------------------------------------------------------------
-- ForgeUI OnLoad
-----------------------------------------------------------------------------------------------
function ForgeUI:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("ForgeUI.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- ForgeUI OnDocLoaded
-----------------------------------------------------------------------------------------------
function ForgeUI:OnDocLoaded()
	if self.xmlDoc == nil or not self.xmlDoc:IsLoaded() then return end
	Apollo.LoadSprites("ForgeUI_Sprite.xml", "Forge")
	
    self.wndMain = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Form", nil, self)
	self.wndMain:FindChild("Version"):FindChild("Text"):SetText(VERSION)
	self.wndMain:FindChild("Author"):FindChild("Text"):SetText(AUTHOR)
	self.wndMain:Show(false, true)
	
	wndItemList = Apollo.LoadForm(self.xmlDoc, "ForgeUI_ListHolder", self.wndMain:FindChild("ForgeUI_Form_ItemList"), self)
	wndItemContainer = self.wndMain:FindChild("ForgeUI_ContainerHolder")
	wndItemContainer2 = self.wndMain:FindChild("ForgeUI_ContainerHolder2")

	Apollo.RegisterSlashCommand("forgeui", "OnForgeUIcmd", self)
	
	local tmpWnd = ForgeUI.AddItemButton(self, "Home", "ForgeUI_Home")
	wndActiveItem = tmpWnd
	self:SetActiveItem(tmpWnd)
	
	ForgeUI.AddItemButton(self, "General settings", "ForgeUI_General")
	
	ForgeUI.RegisterWindowPosition(self, self.wndMain, "ForgeUI_Core")
	
	self.wndMovables = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Movables", nil, self)
	
	bCanRegisterAddons = true
	
	for _, tAddon in pairs(tAddonsToRegister) do -- loading not registered addons
		ForgeUI.RegisterAddon(tAddon)
	end
	
	self:Initialize()
end

function ForgeUI:Initialize()
	ForgeUI.ColorBoxChanged(self.wndContainers.ForgeUI_General:FindChild("ClassColor_Engineer"):FindChild("EditBox"), tSettings.classColors.engineer, "engineer")
	ForgeUI.ColorBoxChanged(self.wndContainers.ForgeUI_General:FindChild("ClassColor_Esper"):FindChild("EditBox"), tSettings.classColors.esper, "esper")
	ForgeUI.ColorBoxChanged(self.wndContainers.ForgeUI_General:FindChild("ClassColor_Spellslinger"):FindChild("EditBox"), tSettings.classColors.spellslinger, "spellslinger")
	ForgeUI.ColorBoxChanged(self.wndContainers.ForgeUI_General:FindChild("ClassColor_Stalker"):FindChild("EditBox"), tSettings.classColors.stalker, "stalker")
	ForgeUI.ColorBoxChanged(self.wndContainers.ForgeUI_General:FindChild("ClassColor_Medic"):FindChild("EditBox"), tSettings.classColors.medic, "medic")
	ForgeUI.ColorBoxChanged(self.wndContainers.ForgeUI_General:FindChild("ClassColor_Warrior"):FindChild("EditBox"), tSettings.classColors.warrior, "warrior")
end

-----------------------------------------------------------------------------------------------
-- ForgeUI API
-----------------------------------------------------------------------------------------------
function ForgeUI.RegisterAddon(tAddon)
	if tAddons[tAddon.strAddonName] ~= nil then return ERR_ADDON_REGISTERED end
	if tAddon.api_version ~= API_VERSION then return ERR_WRONG_API end
	
	if bCanRegisterAddons then
		tAddons[tAddon.strAddonName] = tAddon
		
		if tAddon.ForgeAPI_AfterRegistration ~= nil then
			tAddon:ForgeAPI_AfterRegistration() -- Forge API AfterRegistration
		end
		
		if tSettings_addons[tAddon.strAddonName] ~= nil then
			if tAddon.settings_version ~= nil then
				if tAddon.settings_version == tSettings_addons[tAddon.strAddonName].settings_version then
					tAddon.tSettings = ForgeUI.CopyTable(tAddon.tSettings, tSettings_addons[tAddon.strAddonName])
				end
				tAddon.tSettings.settings_version = nil
			else
				if tSettings_addons[tAddon.strAddonName].settings_version == nil then
					tAddon.tSettings = ForgeUI.CopyTable(tAddon.tSettings, tSettings_addons[tAddon.strAddonName])
				end
			end
		end
		
		if tAddon.ForgeAPI_AfterRestore ~= nil then
			tAddon:ForgeAPI_AfterRestore() -- Forge API AfterRestore
		end
        
        if tAddon.ForgeAPI_LoadOptions ~= nil then
			tAddon:ForgeAPI_LoadOptions() -- Forge API LoadOptions
		end
	else
		tAddonsToRegister[tAddon.strAddonName] = tAddon
	end
end

function ForgeUI.AddItemButton(tAddon, strDisplayName, strWndContainer, tOptions)
	local wndButton = Apollo.LoadForm(ForgeUIInst.xmlDoc, "ForgeUI_Item", wndItemList, ForgeUIInst):FindChild("ForgeUI_Item_Button")
	wndButton:GetParent():FindChild("ForgeUI_Item_Text"):SetText(strDisplayName)
	
	local tData = {}
	if strWndContainer ~= nil then
		tAddon.wndContainers[strWndContainer] = Apollo.LoadForm(tAddon.xmlDoc, strWndContainer, wndItemContainer, tAddon)
		tAddon.wndContainers[strWndContainer]:Show(false)
		tData.itemContainer = tAddon.wndContainers[strWndContainer]
	end
	
	tData.itemList = wndItemList
	
	wndButton:SetData(tData)
	
	return wndButton
end

function ForgeUI.AddItemListToButton(tAddon, wndButton, tItems)
	local wndList = Apollo.LoadForm(ForgeUIInst.xmlDoc, "ForgeUI_ListHolder", ForgeUIInst.wndMain:FindChild("ForgeUI_Form_ItemList"), ForgeUIInst)
	wndList:Show(false)
	local wndBackButton = Apollo.LoadForm(ForgeUIInst.xmlDoc, "ForgeUI_Item", wndList, ForgeUIInst):FindChild("ForgeUI_Item_Button")
	wndBackButton:GetParent():FindChild("ForgeUI_Item_Text"):SetText("--- BACK ---")
	wndBackButton:GetParent():FindChild("ForgeUI_Item_Text"):SetTextFlags("DT_CENTER", true)
	
	for i, tItem in pairs(tItems) do
		local wndBtn = Apollo.LoadForm(ForgeUIInst.xmlDoc, "ForgeUI_Item", wndList, ForgeUIInst):FindChild("ForgeUI_Item_Button")
		wndBtn:GetParent():FindChild("ForgeUI_Item_Text"):SetText(tItem.strDisplayName)
		tAddon.wndContainers[tItem.strContainer] = Apollo.LoadForm(tAddon.xmlDoc, tItem.strContainer, wndItemContainer, tAddon)
		tAddon.wndContainers[tItem.strContainer]:Show(false)
		wndBtn:SetData({
			itemContainer = tAddon.wndContainers[tItem.strContainer],
			itemList = nil
		}) 
	end
	
	wndBackButton:SetData({
		itemList = wndButton:GetData().itemList
	})
	
	wndButton:SetData({
		itemContainer = wndButton:GetData().itemContainer,
		itemList = wndList
	})
	
	wndList:ArrangeChildrenVert()
end

function ForgeUI.RegisterWindowPosition(tAddon, wnd, strName, wndMovable)
	tRegisteredWindows[strName] = wnd

	if tSettings_windowsPositions[strName] ~= nil then
		wnd:SetAnchorOffsets(
			tSettings_windowsPositions[strName].left,
			tSettings_windowsPositions[strName].top,
			tSettings_windowsPositions[strName].right,
			tSettings_windowsPositions[strName].bottom
		)
	else
		local nLeft, nTop, nRight, nBottom = wnd:GetAnchorOffsets()
		tSettings_windowsPositions[strName] = {
			left = nLeft,
			top = nTop,
			right = nRight,
			bottom = nBottom
		}
	end
	if wndMovable ~= nil then
		wndMovable:SetAnchorOffsets(wnd:GetAnchorOffsets())
		wndMovable:SetAnchorPoints(wnd:GetAnchorPoints())
		wndMovable:SetSprite("CRB_ActionBarIconSprites:sprActionBar_OrangeBorder")
		wndMovable:SetBGColor("FFFF0000")
	end
end

function ForgeUI.GetSettings(arg)
	if arg ~= nil then
		return tSettings[arg]
	else
		return tSettings
	end
end

function ForgeUI.ColorBoxChanged(wndControl, settings, data) -- deprecated
	if settings ~= nil then
		wndControl:SetText(settings)
		wndControl:SetTextColor("ff" .. settings)
	end
	
	if data ~= nil then
		wndControl:SetData(data)
	end
	
	local colorString = wndControl:GetText()
		
	if string.len(colorString) > 6 then
		wndControl:SetText(string.sub(colorString, 0, 6))
	elseif string.len(colorString) == 6 then
		wndControl:SetTextColor("FF" .. colorString)
		settings = "FF" .. colorString
	end
	
	return wndControl
end

function ForgeUI.ColorBoxChange(tAddon, wndControl, tSettings, sValue, bOverwrite, bAlpha)
	local sColor = "FFFFFFFF"
	if bOverwrite then
		if bAlpha then
			sColor = sValue
		else
			sColor = string.sub(sValue, 3, 8)
		end
	end

	sColor = wndControl:GetText()
	
	if tSettings ~= nil and bOverwrite then
		if bAlpha then
			sColor = string.sub(tSettings[sValue], 0, 8)
		else
			sColor = string.sub(tSettings[sValue], 3, 8)
		end
	end
		
	if bAlpha then
		if string.len(sColor) > 8 then
			wndControl:SetText(string.sub(sColor, 0, 8))
		elseif string.len(sColor) == 8 then
			wndControl:SetText(sColor)
			wndControl:SetTextColor(sColor)
			tSettings[sValue] = sColor
		end
	else
		if string.len(sColor) > 6 then
			wndControl:SetText(string.sub(sColor, 0, 6))
		elseif string.len(sColor) == 6 then
			wndControl:SetText(sColor)
			wndControl:SetTextColor("FF" .. sColor)
			tSettings[sValue] = "FF" .. sColor
		end
	end
end

-----------------------------------------------------------------------------------------------
-- OnSave / OnRestore
-----------------------------------------------------------------------------------------------
function ForgeUI:OnSave(eType)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
        return nil
    end

	if resetDefaults == true then
		return {}
	end
	
	local tSett = {}
	local tAdd = tSettings_addons

	tSett = ForgeUI.CopyTable(tSett, tSettings)
	
	for addonName, addon in pairs(tAddons) do -- addon settings
		if addon.bReset ~= true then
			if addon.ForgeAPI_BeforeSave ~= nil then
				addon:ForgeAPI_BeforeSave() -- Forge API BeforeSave
			end
			tAdd[addonName] = {}
			
			if addon.settings_version ~= nil then
				tAdd[addonName].settings_version = addon.settings_version
			end
			
			tAdd[addonName] = ForgeUI.CopyTable(tAdd[addonName], addon.tSettings)
		end
	end
	
	for id, wnd in pairs(tSettings_windowsPositions) do -- registered windows
		local nLeft, nTop, nRight, nBottom = tRegisteredWindows[id]:GetAnchorOffsets()
		tSettings_windowsPositions[id] = {
			left = nLeft,
			top = nTop,
			right = nRight,
			bottom = nBottom
		}
	end

	return {
		windowsPositions = tSettings_windowsPositions,
		addons = tAdd,
		settings = tSett
	}
end

function ForgeUI:OnRestore(eType, tData)
	if tData.settings == nil then return end
	tSettings = ForgeUI.CopyTable(tSettings, tData.settings)
	tSettings_windowsPositions = ForgeUI.CopyTable(tSettings_windowsPositions, tData.windowsPositions)
	
	if tData.addons == nil then return end
	for name, data in pairs(tData.addons) do
		tSettings_addons[name] = data
	end
end

-----------------------------------------------------------------------------------------------
-- ForgeUI Functions
-----------------------------------------------------------------------------------------------
function ForgeUI:OnForgeUIcmd(cmd, arg)
	if cmd ~= "forgeui" then return end
	
	if arg == "" then
		self:OnForgeUIOn()
	elseif arg == "reset" then
		self:ResetDefaults()
	else
		tArgs = {}
		for sArg in arg:gmatch("%w+") do table.insert(tArgs, sArg) end
		
		if tArgs[1] == "reset" then
			if tAddons["ForgeUI_" .. tArgs[2]] ~= nil then
				tAddons["ForgeUI_" .. tArgs[2]].bReset = true
			end
			RequestReloadUI()
		end
	end
end

function ForgeUI:OnConfigure()
	self:OnForgeUIOn()
end

function ForgeUI:OnForgeUIOn()
	wndItemList:ArrangeChildrenVert()
	self.wndMain:Invoke()
end

function ForgeUI:OnFOrgeUIOff( wndHandler, wndControl, eMouseButton )
	self.wndMain:Close()
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_Movables Functions
---------------------------------------------------------------------------------------------------
function ForgeUI:OnUnlockElements()
	self.wndMain:Show(false, true)
	self.wndMain:FindChild("ForgeUI_General_UnlockButton"):SetText("Lock elements")

	self.wndMovables:Show(true, true)
	self:FillGrid(self.wndMovables:FindChild("Grid"))

	for name, addon in pairs(tAddons) do
		if addon.wndMovables ~= nil then
			addon.wndMovables:Show(true, true)
		end
	
		if addon.ForgeAPI_OnUnlockElements ~= nil then
			addon:ForgeAPI_OnUnlockElements() -- Forge API OnUnlockElements
		end
	end
end

function ForgeUI:OnLockElements()
	self.wndMain:Show(true, true)
	self.wndMain:FindChild("ForgeUI_General_UnlockButton"):SetText("Unlock elements")

	self.wndMovables:Show(false, true)
	self.wndMovables:FindChild("Grid"):DestroyAllPixies()

	for _, addon in pairs(tAddons) do
		if addon.wndMovables ~= nil then
			addon.wndMovables:Show(false, true)
		end
	
		if addon.ForgeAPI_OnLockElements ~= nil then
			addon:ForgeAPI_OnLockElements() -- Forge API OnLockElements
		end
	end
end

function ForgeUI:ForgeUI_Movables_GridCheckbox( wndHandler, wndControl, eMouseButton )
	self.wndMovables:FindChild("Grid"):Show(wndControl:IsChecked(), true)
end

function ForgeUI:FillGrid(wnd)
	local nDiameter = 5

	local nHeight = wnd:GetHeight()
	local nWidth = wnd:GetWidth()
	
	for i = 0, nHeight, nDiameter do
		wnd:AddPixie({
			strSprite = "BlackFill",
			loc = {
		    	fPoints = {0,0,1,0},
	    		nOffsets = {0,i,0,i + 1}
			 }
		})
	end
	
	for i = 0, nWidth, nDiameter do
		wnd:AddPixie({
			strSprite = "BlackFill",
			loc = {
		    	fPoints = {0,0,0,1},
	    		nOffsets = {i,0,i + 1,0}
			 }
		})
	end
end

function ForgeUI:OnMovablesClose( wndHandler, wndControl, eMouseButton )
	self:OnLockElements()
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_Form Functions
---------------------------------------------------------------------------------------------------
function ForgeUI:SetActiveItem(wndControl)
	wndItemContainer2:Show(false)
	wndActiveItem:GetParent():FindChild("ForgeUI_Item_Text"):SetTextColor("white")
	wndActiveItem = wndControl
	wndControl:GetParent():FindChild("ForgeUI_Item_Text"):SetTextColor("xkcdFireEngineRed")
	if wndControl:GetData().itemContainer ~= nil then
		wndItemContainer2 = wndControl:GetData().itemContainer
		wndItemContainer2:Show(true)
	else
		wndItemList:Show(false)
		wndItemList = wndControl:GetData().itemList
		wndItemList:Show(true)	
	end
end

function ForgeUI:TestFunction( wndHandler, wndControl, eMouseButton )
	ForgeUI.GenerateGradient("FFFFFF", "000000", 10, false)
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_General Functions
---------------------------------------------------------------------------------------------------
function ForgeUI:OnUnlockButtonPressed( wndHandler, wndControl, eMouseButton )
	if wndControl:GetText() == "Unlock elements" then
		self:OnUnlockElements()
	else
		self:OnLockElements()
	end	
end

function ForgeUI:OnSaveButtonPressed( wndHandler, wndControl, eMouseButton )
	RequestReloadUI()
end

function ForgeUI:ResetDefaults()
	resetDefaults = true
	RequestReloadUI()
end

function ForgeUI:OnDefaultsButtonPressed( wndHandler, wndControl, eMouseButton )
	ForgeUI.CreateConfirmWindow(self, self.ResetDefaults)
end

function ForgeUI:EditBoxChanged( wndHandler, wndControl, strText )
	local tmpWnd = ForgeUI.ColorBoxChanged(wndControl)
	tSettings.classColors[tmpWnd:GetData()] = tmpWnd:GetText()
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_Item Functions
---------------------------------------------------------------------------------------------------
function ForgeUI:ItemListPressed( wndHandler, wndControl, eMouseButton )
	self:SetActiveItem(wndControl)
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_ConfirmWindow Functions
---------------------------------------------------------------------------------------------------
function ForgeUI:ForgeUI_ConfirmWindow( wndHandler, wndControl, eMouseButton )
	if(wndControl:GetName() == "YesButton") then
		wndControl:GetData()()
		
	elseif(wndControl:GetName() == "NoButton") then
	
	end
	wndControl:GetParent():Destroy()
end

function ForgeUI.CreateConfirmWindow(self, fCallback)
	local wndConfirmWindow = Apollo.LoadForm(ForgeUIInst.xmlDoc, "ForgeUI_ConfirmWindow", nil, ForgeUIInst)
	wndConfirmWindow:FindChild("YesButton"):SetData(fCallback)
end

---------------------------------------------------------------------------------------------------
-- Libraries
---------------------------------------------------------------------------------------------------
function ForgeUI.ReturnTestStr()
	return "ForgeUI"
end

function ForgeUI.CopyTable(tNew, tOld)
	if tOld == nil then return end
	if tNew == nil then
		tNew = {}
	end
	
	for k, v in pairs(tOld) do
		if type(v) == "table" then
			tNew[k] = ForgeUI.CopyTable(tNew[k], v)
		else
			tNew[k] = v
		end
	end
	return tNew
end

function ForgeUI.ShortNum(num)
	local tmp = tostring(num)
    if not num then
        return 0
    elseif num >= 1000000 then
        ret = string.sub(tmp, 1, string.len(tmp) - 6) .. "." .. string.sub(tmp, string.len(tmp) - 5, string.len(tmp) - 5) .. "M"
    elseif num >= 1000 then
        ret = string.sub(tmp, 1, string.len(tmp) - 3) .. "." .. string.sub(tmp, string.len(tmp) - 2, string.len(tmp) - 2) .. "k"    else
        ret = num -- hundreds
    end
    return ret
end

function ForgeUI.FormatDuration(tim)
	if tim == nil then return end 
	if (tim>86400) then
		return ("%.0fd"):format(tim/86400)
	elseif (tim>3600) then
		return ("%.0fh"):format(tim/3600)
	elseif (tim>60) then
		return ("%.0fm"):format(tim/60)
	elseif (tim>5) then
		return ("%.0fs"):format(tim)
	elseif (tim>0) then
		return ("%.1fs"):format(tim)
	elseif (tim==0) then
		return ""
	end
end

function ForgeUI.Round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function ForgeUI.InTable(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return key end
    end
    return false
end

function ForgeUI.ConvertAlpha(value)	
	return string.format("%02X", math.floor(value * 255 + 0.5))
end

function ForgeUI.GenerateGradient(strColorStart, strColorEnd, nSteps, nStep, bAlpha)
	local colorBegin
	local colorEnd

	if bAlpha then
		colorBegin = string.sub(strColorStart, 3, 8)
		colorEnd = string.sub(strColorEnd, 3, 8)
	else
		colorBegin = strColorStart
		colorEnd = strColorEnd
	end
	
	local colorR0 = tonumber(string.sub(colorBegin, 1, 2), 16)
	local colorG0 = tonumber(string.sub(colorBegin, 3, 4), 16)
	local colorB0 = tonumber(string.sub(colorBegin, 5, 6), 16)
  	
	local colorR1 = tonumber(string.sub(colorEnd, 1, 2), 16)
	local colorG1 = tonumber(string.sub(colorEnd, 3, 4), 16)
	local colorB1 = tonumber(string.sub(colorEnd, 5, 6), 16)

	local colorR = ((colorR1 - colorR0) / nSteps * nStep) + colorR0
	local colorG = ((colorG1 - colorG0) / nSteps * nStep) + colorG0
	local colorB = ((colorB1 - colorB0) / nSteps * nStep) + colorB0
	
    if bAlpha then
        return string.format("FF%02x%02x%02x", colorR, colorG, colorB)
    else
	   return string.format("%02x%02x%02x", colorR, colorG, colorB)
    end
end

ForgeUIInst:Init() 
