require "Window"
 
local ForgeUI = {}
local ForgeColor
local ForgeOptions
local ForgeComm

local WildShell = Apollo.GetAddon("WildShell")
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------

local AUTHOR = "Adam Jedlicka"
local AUTHOR_LONG = "Winty Badass@Jabbit"
local API_VERSION = 2

-- errors
local ERR_ADDON_REGISTERED = 0
local ERR_ADDON_NOT_REGISTERED = 1
local ERR_WRONG_API = 2

-----------------------------------------------------------------------------------------------
-- Variables
-----------------------------------------------------------------------------------------------
local tAddons = {} 
local bCanRegisterAddons = false
local tAddonsToRegister = {}

local tStylers = {}

local tRegisteredWindows = {} -- saving windows for repositioning them later

local wndAdvancedBtn

-----------------------------------------------------------------------------------------------
-- Settings
-----------------------------------------------------------------------------------------------
local bResetDefaults = false

local tSettings_addons = {}
local tSettings_windows = {}

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function ForgeUI:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 
	
	 -- mandatory 
    self.api_version = 2
	self.sVersion = "0.4.3"
	self.nVersion = 1

	self.author = "WintyBadass"
	self.strAddonName = "~ForgeUI"
	self.strDisplayName = "ForgeUI"
	
	self.wndContainers  = {}
	
	self.tStylers = {}
	
	-- optional
	self.settings_version = 1
    self.tSettings = {
		crMain = "FFFF0000",
		crTest = "FFFFFFFF",
		bNetworking = true,
		bNotifications = true,
		bAdvanced = false,
		b24HourFormat = true,
		tClassColors = {
			crEngineer = "FFEFAB48",
			crEsper = "FF1591DB",
			crMedic = "FFFFE757",
			crSpellslinger = "FF98C723",
			crStalker = "FFD23EF4",
			crWarrior = "FFF54F4F"
		},
		bDebug = false,
		bNetworkLoop = false,
	}	

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
	self.xmlMain = XmlDoc.CreateFromFile("ForgeUI.xml")
	self.xmlUI = XmlDoc.CreateFromFile("ForgeUI_UIElements.xml")
	
	self.xmlMain:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- ForgeUI OnDocLoaded
-----------------------------------------------------------------------------------------------
function ForgeUI:OnDocLoaded()
	if self.xmlMain == nil or not self.xmlMain:IsLoaded() then return end
	
	ForgeColor = Apollo.GetPackage("ForgeColor").tPackage
	ForgeOptions = Apollo.GetPackage("ForgeOptions").tPackage
	
	self:InitComm()
	
	-- sprites
	Apollo.LoadSprites("ForgeUI_Sprite.xml", "ForgeUI_Sprite")
	Apollo.LoadSprites("ForgeUI_Icons.xml", "ForgeUI_Icons")
	
	-- tratums
	self.WorldStratum0 = Apollo.LoadForm(self.xmlMain, "ForgeUI_Stratum", nil, self)
	self.WorldStratum1 = Apollo.LoadForm(self.xmlMain, "ForgeUI_Stratum", nil, self)
	
	self.HudStratum0 = Apollo.LoadForm(self.xmlMain, "ForgeUI_Stratum", nil, self)
	self.HudStratum1 = Apollo.LoadForm(self.xmlMain, "ForgeUI_Stratum", nil, self)
	self.HudStratum2 = Apollo.LoadForm(self.xmlMain, "ForgeUI_Stratum", nil, self)
	self.HudStratum3 = Apollo.LoadForm(self.xmlMain, "ForgeUI_Stratum", nil, self)
	self.HudStratum4 = Apollo.LoadForm(self.xmlMain, "ForgeUI_Stratum", nil, self)
	self.HudStratum5 = Apollo.LoadForm(self.xmlMain, "ForgeUI_Stratum", nil, self)
	
	-- main window
    self.wndMain = Apollo.LoadForm(self.xmlMain, "ForgeUI_Form", nil, self)
	self.wndMain:FindChild("Version"):FindChild("Text"):SetText(self.sVersion)
	self.wndMain:FindChild("Author"):FindChild("Text"):SetText(AUTHOR_LONG)
	
	-- addons list
	self.wndAddons = Apollo.LoadForm(self.xmlMain, "ForgeUI_AddonsForm", self.wndMain, self)
	
	-- movables
	self.wndMovables = Apollo.LoadForm(self.xmlMain, "ForgeUI_Movables", nil, self)
	
	-- item list & container
	self.wndItemList = self.wndMain:FindChild("ForgeUI_Form_ItemList")
	self.wndItemContainer = self.wndMain:FindChild("ForgeUI_Form_ItemContainer")
	
	self.wndMainItemListHolder = Apollo.LoadForm(self.xmlMain, "ForgeUI_ListHolder", self.wndItemList, self)
	self.wndMainItemListHolder:Show(true, true)

	-- load modules
	
	ForgeOptions:Init()
	
	-- slash commands
	Apollo.RegisterSlashCommand("forgeui", "OnForgeUIcmd", self)
	Apollo.RegisterSlashCommand("focus", "OnFocusCmd", self)
	
	bCanRegisterAddons = true
	
	ForgeUI.API_RegisterAddon(self)
	
	for _, tAddon in pairs(tAddonsToRegister) do -- loading not registered addons
		ForgeUI.API_RegisterAddon(tAddon)
	end
	
	local tInterface = Apollo.GetAddon("Interface")
	if tInterface == nil then
		ForgeUI.ShowWarning("Addon 'Interface' is turned off which may cause errors. Please turn it on.")
	end
	tInterface = nil
end

function ForgeUI:ForgeAPI_AfterRegistration()
	ForgeUI.API_AddItemButton(self, "Home", { bDefault = true, strContainer = "ForgeUI_Home", xmlDoc = self.xmlMain })
	ForgeUI.API_AddItemButton(self, "General", { strContainer = "ForgeUI_General", xmlDoc = self.xmlMain })
end

function ForgeUI:ForgeAPI_AfterRestore()
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.ForgeUI_General:FindChild("crEngineer"), self.tSettings.tClassColors, "crEngineer", false)
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.ForgeUI_General:FindChild("crEsper"), self.tSettings.tClassColors, "crEsper", false)
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.ForgeUI_General:FindChild("crMedic"), self.tSettings.tClassColors, "crMedic", false)
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.ForgeUI_General:FindChild("crSpellslinger"), self.tSettings.tClassColors, "crSpellslinger", false)
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.ForgeUI_General:FindChild("crStalker"), self.tSettings.tClassColors, "crStalker", false)
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.ForgeUI_General:FindChild("crWarrior"), self.tSettings.tClassColors, "crWarrior", false)
	
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.ForgeUI_Home:FindChild("TextColorBox"), self.tSettings, "crTest")
	
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers.ForgeUI_General:FindChild("b24HourFormat"):FindChild("CheckBox"), self.tSettings, "b24HourFormat")
	
	ForgeOptions:API_AddAdvancedOption(self, "General", "Allow networking", "boolean", self.tSettings, "bNetworking", nil, {})
	ForgeOptions:API_AddAdvancedOption(self, "General", "Enable notifications", "boolean", self.tSettings, "bNotifications", nil, {})
	
	ForgeOptions:API_AddAdvancedOption(self, "Debug", "Enable debugging", "boolean", self.tSettings, "bDebug", nil, {})
	if GameLib.GetPlayerUnit() and GameLib.GetPlayerUnit():GetName() == "Winty Badass" then
		ForgeOptions:API_AddAdvancedOption(self, "Debug", "Enable network loop", "boolean", self.tSettings, "bNetworkLoop", nil, {})
	end
end

-----------------------------------------------------------------------------------------------
-- ForgeUI API
-----------------------------------------------------------------------------------------------
function ForgeUI.API_RegisterAddon(tAddon)
	if tAddons[tAddon.strAddonName] ~= nil then return ERR_ADDON_REGISTERED end
	if tAddon.api_version ~= API_VERSION then return ERR_WRONG_API end
	
	if bCanRegisterAddons then
		tAddons[tAddon.strAddonName] = tAddon
		
		if tAddon.ForgeAPI_AfterRegistration ~= nil then
			tAddon:ForgeAPI_AfterRegistration() -- Forge API AfterRegistration
		end
		
		-- styler registration
		local bCanStylerBeRegistered = true
		for _, tStyler in pairs(tStylers) do
			if not tStyler.bRegistered then
				for _, strAddon in pairs(tStyler.strAddons) do
					if tAddons[strAddon] == nil then
						bCanBeRegistered = false
					end
				end
				
				if bCanStylerBeRegistered == true then
					tStyler.bRegistered = true
					
					if tStyler.tAddon.ForgeAPI_AfterStylerRegistration~= nil then
						tStyler.tAddon:ForgeAPI_AfterStylerRegistration() -- Forge API AfterStylerRegistration
					end
				end
			end
			
			bCanStylerBeRegistered = false
		end
		-- end of styler registration
		
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
		
		if tAddon.ForgeAPI_Initialization ~= nil then
			tAddon:ForgeAPI_Initialization() -- Forge API Initialization
		end
		
		local wndAddon = Apollo.LoadForm(ForgeUIInst.xmlMain, "ForgeUI_AddonForm", ForgeUIInst.wndAddons:FindChild("Container"), ForgeUIInst)
		wndAddon:FindChild("AddonName"):SetText(tAddon.strDisplayName)
		
		wndAddon:SetData(tAddon)
		
		ForgeUIInst.wndAddons:FindChild("Container"):ArrangeChildrenVert()
	else
		tAddonsToRegister[tAddon.strAddonName] = tAddon
	end
end

-- stylers
function ForgeUI.API_RegisterStyler(tAddon, strAddons)
	if tAddon.strName == nil then return end
	if tStylers[tAddon.strName] ~= nil then return end
	
	tStylers[tAddon.strName] = {
		tAddon = tAddon,
		strAddons = strAddons,
		bRegistered = false
	}
	
	local bCanBeRegistered = true
	for _, strAddon in pairs(strAddons) do
		if tAddons[strAddon] == nil then
			bCanBeRegistered = false
		end
	end
	
	if bCanBeRegistered == true and not tStylers[tAddon.strName].bRegistered then
		tStylers[tAddon.strName].bRegistered = true
		
		if tAddon.ForgeAPI_AfterStylerRegistration~= nil then
			tAddon:ForgeAPI_AfterStylerRegistration() -- Forge API AfterRegistration
		end
	end
end

function ForgeUI.API_GetAddon(strAddonName)
	if tAddons[strAddonName] ~= nil then
		return tAddons[strAddonName]
	else
		return nil
	end
end

function ForgeUI.API_ResetAddonSettings(strAddonName)
	local tAddon = tAddons[strAddonName]
	if tAddon == nil then return end
	
	tAddon.bReset = true
	RequestReloadUI()
end

-----------------------------------------------------------------------------------------------
-- ForgeUI ItemList API
-----------------------------------------------------------------------------------------------
function ForgeUI.API_AddItemButton(tAddon, strDisplayName, tOptions)
	local wndButton = Apollo.LoadForm(ForgeUIInst.xmlMain, "ForgeUI_Item", ForgeUIInst.wndMainItemListHolder, ForgeUIInst):FindChild("ForgeUI_Item_Button")
	wndButton:GetParent():FindChild("ForgeUI_Item_Text"):SetText(strDisplayName)
	
	local tData = {}
	tData.wndParentContainer = ForgeUIInst.wndMainItemListHolder
	
	if tOptions == nil then
		wndButton:SetData(tData)
		ForgeUIInst.wndMainItemListHolder:ArrangeChildrenVert()
		return wndButton
	end
	
	if tOptions.strContainer then
		if tOptions.xmlDoc then
			tAddon.wndContainers[tOptions.strContainer] = Apollo.LoadForm(tOptions.xmlDoc, tOptions.strContainer, ForgeUIInst.wndItemContainer, ForgeUIInst)
			tAddon.wndContainers[tOptions.strContainer]:Show(false, true)
			tData.itemContainer = tAddon.wndContainers[tOptions.strContainer]
		else
			tAddon.wndContainers[tOptions.strContainer] = Apollo.LoadForm(tAddon.xmlDoc, tOptions.strContainer, ForgeUIInst.wndItemContainer, ForgeUIInst)
			tAddon.wndContainers[tOptions.strContainer]:Show(false, true)
			tData.itemContainer = tAddon.wndContainers[tOptions.strContainer]
		end
	end
	
	if tOptions.bDefault then
		tData.bDefault = tOptions.bDefault
	end
	
	wndButton:SetData(tData)
	
	if tOptions.bShow ~= nil then
		wndButton:GetParent():Show(tOptions.bShow, true)
	end
	
	ForgeUIInst.wndMainItemListHolder:ArrangeChildrenVert()
	
	if tOptions.bDefault then
		ForgeUIInst:SetActiveItem(wndButton)
	end
	
	return wndButton
end

function ForgeUI.API_ToggleItemButton(wndButton, bShow)
	wndButton:GetParent():Show(bShow, true)
	
	wndButton:GetData().wndParentContainer:ArrangeChildrenVert()
end

function ForgeUI.API_AddListItemToButton(tAddon, wndBtn, strDisplayName, tOptions)
	local tData = wndBtn:GetData()
	local tNewData = {}
	
	local wndList
	if tData.itemList == nil then
		wndList = Apollo.LoadForm(ForgeUIInst.xmlMain, "ForgeUI_ListHolder", ForgeUIInst.wndItemList, ForgeUI)
		
		local wndHomeButton = Apollo.LoadForm(ForgeUIInst.xmlMain, "ForgeUI_Item", wndList, ForgeUIInst):FindChild("ForgeUI_Item_Button")
		wndHomeButton:GetParent():FindChild("ForgeUI_Item_Text"):SetText("Home")
		
		local tHomeData = {}
		tHomeData.wndParentContainer = wndList
		tHomeData.itemList = ForgeUIInst.wndMainItemListHolder
		
		wndHomeButton:SetData(tHomeData)
				
		tData.itemList = wndList
	else
		wndList = tData.itemList
	end
	
	local wndButton = Apollo.LoadForm(ForgeUIInst.xmlMain, "ForgeUI_Item", wndList, ForgeUIInst):FindChild("ForgeUI_Item_Button")
	wndButton:GetParent():FindChild("ForgeUI_Item_Text"):SetText(strDisplayName)
	
	tNewData.wndParentContainer = wndList
	
	if tOptions == nil then
		wndButton:SetData(tNewData)
		wndList:ArrangeChildrenVert()
		return wndButton
	end
	
	if tOptions.strContainer ~= nil then
		if tOptions.xmlDoc ~= nil then
			tAddon.wndContainers[tOptions.strContainer] = Apollo.LoadForm(tOptions.xmlDoc, tOptions.strContainer, ForgeUIInst.wndItemContainer, ForgeUIInst)
			tAddon.wndContainers[tOptions.strContainer]:Show(false, true)
			tNewData.itemContainer = tAddon.wndContainers[tOptions.strContainer]
		else
			tAddon.wndContainers[tOptions.strContainer] = Apollo.LoadForm(tAddon.xmlDoc, tOptions.strContainer, ForgeUIInst.wndItemContainer, ForgeUIInst)
			tAddon.wndContainers[tOptions.strContainer]:Show(false, true)
			tNewData.itemContainer = tAddon.wndContainers[tOptions.strContainer]
		end
	end
	
	if tOptions.bDefault ~= nil then
		tNewData.bDefault = tOptions.bDefault
	end
	
	wndButton:SetData(tNewData)
	wndList:ArrangeChildrenVert()
	return wndButton
end

function ForgeUI:SetActiveItem(wndControl)
	local data = wndControl:GetData()
	
	for _, wndButton in pairs(data.wndParentContainer:GetChildren()) do
		wndButton:FindChild("ForgeUI_Item_Text"):SetTextColor("FFFFFFFF")
		if wndButton:FindChild("ForgeUI_Item_Button"):GetData().itemContainer ~= nil then
			wndButton:FindChild("ForgeUI_Item_Button"):GetData().itemContainer:Show(false, true)
		end
	end
	
	if data.itemList ~= nil then
		for _, wndList in pairs(self.wndItemList:GetChildren()) do
			wndList:Show(false, true)
		end
		data.itemList:Show(true, false)
		for _, wndButton in pairs(data.itemList:GetChildren()) do
			if wndButton:FindChild("ForgeUI_Item_Button"):GetData().bDefault == true then
				self:SetActiveItem(wndButton:FindChild("ForgeUI_Item_Button"))
			end
		end
	else
		wndControl:GetParent():FindChild("ForgeUI_Item_Text"):SetTextColor(self.tSettings.crMain)
		if data.itemContainer ~= nil then
			data.itemContainer:Show(true, true)
		end
	end
end

function ForgeUI:ItemListPressed( wndHandler, wndControl, eMouseButton )
	self:SetActiveItem(wndControl)
end

-----------------------------------------------------------------------------------------------
-- ForgeUI Movables API
-----------------------------------------------------------------------------------------------
local _tRegisteredWindows = {}
function ForgeUI.API_RegisterWindow(tAddon, wnd, strName, tSettings)
	if _tRegisteredWindows[tAddon.strAddonName] == nil then
		_tRegisteredWindows[tAddon.strAddonName] = {}
	end
	
	if tSettings_windows[tAddon.strAddonName] ~= nil and tSettings_windows[tAddon.strAddonName][strName] ~= nil then
		wnd:SetAnchorOffsets(
			tSettings_windows[tAddon.strAddonName][strName].left,
			tSettings_windows[tAddon.strAddonName][strName].top,
			tSettings_windows[tAddon.strAddonName][strName].right,
			tSettings_windows[tAddon.strAddonName][strName].bottom
		)
	end
	
	_tRegisteredWindows[tAddon.strAddonName][strName] = {}
	_tRegisteredWindows[tAddon.strAddonName][strName].wnd = wnd
	
	if tSettings ~= nil and tSettings.bNoMovable == true then return end
	
	local wndMovable
	if tSettings ~= nil then
		if tSettings.strParent ~= nil then
			wndMovable = Apollo.LoadForm(ForgeUIInst.xmlMain, "ForgeUI_Movable", _tRegisteredWindows[tAddon.strAddonName][tSettings.strParent].movable, ForgeUIInst)
			_tRegisteredWindows[tAddon.strAddonName][strName].strParent = tSettings.strParent
		elseif tSettings.nLevel ~= nil then
			if tSettings.nLevel > 0 and tSettings.nLevel < 5 then
				wndMovable = Apollo.LoadForm(ForgeUIInst.xmlMain, "ForgeUI_Movable", ForgeUIInst.wndMovables:FindChild("Movables" .. tSettings.nLevel), ForgeUIInst)
			else
				wndMovable = Apollo.LoadForm(ForgeUIInst.xmlMain, "ForgeUI_Movable", ForgeUIInst.wndMovables:FindChild("Movables"), ForgeUIInst)
			end
		end
	end
	if wndMovable == nil then
		wndMovable = Apollo.LoadForm(ForgeUIInst.xmlMain, "ForgeUI_Movable", ForgeUIInst.wndMovables:FindChild("Movables"), ForgeUIInst)
	end
	wndMovable:SetAnchorOffsets(wnd:GetAnchorOffsets())
	wndMovable:SetAnchorPoints(wnd:GetAnchorPoints())
	
	if tSettings ~= nil then
		if tSettings.strDisplayName ~= nil then
			wndMovable:FindChild("Text"):SetText(tSettings.strDisplayName)
		end
		
		if tSettings.bSizable ~= nil then
			wndMovable:SetStyle("Sizable", tSettings.bSizable)
		end
		
		if tSettings.bMaintainRatio ~= nil then
			wndMovable:SetStyle("MaintainAspectRatio", tSettings.bMaintainRatio)
		end
		
		if tSettings.crBorder ~= nil then
			wndMovable:SetBGColor(tSettings.crBorder)
		end
		
		if tSettings.bInvisible then
			wndMovable:SetStyle("IgnoreMouse", true)
			wndMovable:SetStyle("Moveable", false)
			wndMovable:SetStyle("Picture", false)
			wndMovable:FindChild("Background"):SetStyle("Picture", false)
			wndMovable:SetName("ForgeUI_Movable_Invisible")
		end
	end
	
	wndMovable:AddEventHandler("WindowMove", "OnMovableMove", ForgeUIInst)
	
	_tRegisteredWindows[tAddon.strAddonName][strName].movable = wndMovable
end

function ForgeUI.API_UnRegisterWindow(tAddon, strName)
	for strAddonName, tAddon in pairs(_tRegisteredWindows) do
		for name, tMovable in pairs(tAddon) do
			if name == strName then
				tMovable.movable:DestroyChildren()
				tMovable.movable:Destroy()
				_tRegisteredWindows[strAddonName][name] = nil
			end
			
			if tMovable.strParent == strName then
				tMovable.movable:DestroyChildren()
				tMovable.movable:Destroy()
				tAddon[name] = nil
			end
		end
	end
end

function ForgeUI:OnMovableMove()
	for strAddonName, tWindows in pairs(_tRegisteredWindows) do
		for strWindowName, tWindow in pairs(tWindows) do
			tWindow.wnd:SetAnchorOffsets(tWindow.movable:GetAnchorOffsets())
		end
	end
end

local _tMovablesSavedPositions = {}
function ForgeUI:OnUnlockElements()
	self.wndMain:Show(false, true)
	self.wndMain:FindChild("ForgeUI_General_UnlockButton"):SetText("Lock elements")

	self.wndMovables:Show(true, true)
	self:FillGrid(self.wndMovables:FindChild("Grid"))

	for _, tAddon in pairs(_tRegisteredWindows) do
		for _, tMovable in pairs(tAddon) do
			tMovable.movable:Show(true, true)
			tMovable.wnd_shown = tMovable.wnd:IsShown()
			tMovable.wnd:Show(false, true)
		end
	end
end

function ForgeUI:OnLockElements()
	self.wndMain:Show(true, true)
	self.wndMain:FindChild("ForgeUI_General_UnlockButton"):SetText("Unlock elements")

	self.wndMovables:Show(false, true)
	self.wndMovables:FindChild("Grid"):DestroyAllPixies()

	for _, tAddon in pairs(tAddons) do
		if tAddon.ForgeAPI_AfterMovableMove ~= nil then
			tAddon:ForgeAPI_AfterMovableMove() -- Forge API AfterMovableMove
		end
	end

	for _, tWindow in pairs(_tRegisteredWindows) do
		for _, tMovable in pairs(tWindow) do
			tMovable.movable:Show(false, true)
			tMovable.wnd:Show(tMovable.wnd_shown, true)
		end
	end
end

function ForgeUI:OnMovableClick( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if wndControl:GetName() == "ForgeUI_Movable" and eMouseButton == 1 then
		local wndPrecisionWindow = wndControl:FindChild("PrecisionWindow")
		wndPrecisionWindow:Show(not  wndPrecisionWindow:IsShown())
		wndPrecisionWindow:FindChild("Name"):SetText(wndControl:FindChild("Text"):GetText())
		wndPrecisionWindow:FindChild("Size_X"):SetText(wndControl:GetWidth())
		wndPrecisionWindow:FindChild("Size_Y"):SetText(wndControl:GetHeight())
		
		local nLeft, nTop, nRight, nBottom = wndControl:GetAnchorOffsets()
		wndPrecisionWindow:FindChild("Pos_X"):SetText(nLeft)
		wndPrecisionWindow:FindChild("Pos_Y"):SetText(nTop)
	end
end

function ForgeUI:OnMovableSizeButtonClick( wndHandler, wndControl, eMouseButton )
	if wndControl:GetName() == "Plus" then
		local nNew = wndControl:GetParent():GetText() + 1
		wndControl:GetParent():SetText(nNew)
	elseif wndControl:GetName() == "Minus" then
		local nNew = wndControl:GetParent():GetText() - 1
		if wndControl:GetParent():GetParent():GetName() == "Size" and nNew < 1 then return end
		wndControl:GetParent():SetText(nNew)
	end
	
	local wnd = wndControl:GetParent():GetParent():GetParent():GetParent()
	
	self:ResizeMovable(wnd, wnd:FindChild("Size_X"):GetText(), wnd:FindChild("Size_Y"):GetText(), wnd:FindChild("Pos_X"):GetText(), wnd:FindChild("Pos_Y"):GetText())
	self:OnMovableMove()
end

function ForgeUI:ResizeMovable(wndMovable, nNewWidth, nNewHeight, nNewPosX, nNewPosY)
	local nDeltaWidth = nNewWidth - wndMovable:GetWidth()
	local nDeltaHeight = nNewHeight - wndMovable:GetHeight()
	
	local nLeft, nTop, nRight, nBottom = wndMovable:GetAnchorOffsets()
	nRight = nRight + nNewPosX - nLeft
	nBottom = nBottom + nNewPosY - nTop
	nLeft = nNewPosX
	nTop = nNewPosY
	wndMovable:SetAnchorOffsets(nLeft, nTop, nRight + nDeltaWidth, nBottom + nDeltaHeight) 
end

function ForgeUI:ForgeUI_Movables_GridCheckbox( wndHandler, wndControl, eMouseButton )
	self.wndMovables:FindChild("Grid"):Show(wndControl:IsChecked(), true)
end

function ForgeUI:FillGrid(wnd)
	self.wndMovables:FindChild("Grid"):DestroyAllPixies()

	local nDiameterX = self.wndMovables:FindChild("GridSize_X"):GetText()
	local nDiameterY = self.wndMovables:FindChild("GridSize_Y"):GetText()

	local nHeight = wnd:GetHeight()
	local nWidth = wnd:GetWidth()
	
	for i = 0, nHeight / 2 , nDiameterY do
		local j = nHeight / 2 + i
		local k = nHeight / 2 - i
	
		if i == 0 then
			wnd:AddPixie({
				strSprite = "WhiteFill",
				loc = {
			    	fPoints = {0,0,1,0},
		    		nOffsets = {0,j,0,j + 1}
				 },
				cr = "FFFF0000"
			})
		else
			wnd:AddPixie({
				strSprite = "WhiteFill",
				loc = {
			    	fPoints = {0,0,1,0},
		    		nOffsets = {0,j,0,j + 1}
				 },
				cr = "FF000000"
			})

			wnd:AddPixie({
				strSprite = "WhiteFill",
				loc = {
			    	fPoints = {0,0,1,0},
		    		nOffsets = {0,k,0,k + 1}
				 },
				cr = "FF000000"
			})
		end
	end
	
	for i = 0, nWidth / 2 , nDiameterX do
		local j = nWidth / 2 + i
		local k = nWidth / 2 - i
	
		if i == 0 then
			wnd:AddPixie({
				strSprite = "WhiteFill",
				loc = {
			    	fPoints = {0,0,0,1},
		    		nOffsets = {j,0,j + 1,0}
				 },
				cr = "FFFF0000"
			})
		else
			wnd:AddPixie({
				strSprite = "WhiteFill",
				loc = {
			    	fPoints = {0,0,0,1},
		    		nOffsets = {j,0,j + 1,0}
				 },
				cr = "FF000000"
			})

			wnd:AddPixie({
				strSprite = "WhiteFill",
				loc = {
			    	fPoints = {0,0,0,1},
		    		nOffsets = {k,0,k + 1,0}
				 },
				cr = "FF000000"
			})
		end
	end
end

function ForgeUI:OnGridSizeButtonClick( wndHandler, wndControl, eMouseButton )
	if wndControl:GetName() == "Plus" then
		local nNew = wndControl:GetParent():GetText() + 1
		wndControl:GetParent():SetText(nNew)
	elseif wndControl:GetName() == "Minus" then
		local nNew = wndControl:GetParent():GetText() - 1
		if nNew < 0 then return end
		wndControl:GetParent():SetText(nNew)
	end
	self:FillGrid(self.wndMovables:FindChild("Grid"))
end

function ForgeUI:OnMovablesClose( wndHandler, wndControl, eMouseButton )
	self:OnLockElements()
end

-----------------------------------------------------------------------------------------------
-- ForgeUI Window elements api
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- Color box
-----------------------------------------------------------------------------------------------

function ForgeUI.API_RegisterColorBox(tAddon, wndControl, tSettings, sValue, bAlpha, strCallback)
	local tData = {
		tAddon = tAddon,
		tSettings = tSettings,
		sValue = sValue,
		bAlpha = bAlpha,
		strCallback = strCallback
	}
	
	wndControl:SetData(tData)
	wndControl:AddEventHandler("EditBoxChanged", 	"OnColorBoxChanged", ForgeUIInst)
	wndControl:AddEventHandler("MouseButtonDown", 	"OnColorBoxDown", ForgeUIInst)
	
	ForgeUI.API_ColorBoxChange(tAddon, wndControl, tSettings, sValue, true, bAlpha)
end

function ForgeUI:OnColorBoxChanged( wndHandler, wndControl, strText )
	local tData = wndControl:GetData()
	if tData == nil then return end
	
	local color = ForgeUI.API_ColorBoxChange(tData.tAddon, wndControl, tData.tSettings, tData.sValue, false, tData.bAlpha)
	
	if tData.strCallback ~= nil and color ~= nil then
		if tData.tAddon.tStylers[tData.strCallback] ~= nil then
			tData.tAddon.tStylers[tData.strCallback][tData.strCallback](tData.tAddon)
		else
			tData.tAddon[tData.strCallback](tData.tAddon)
		end
	end
end

function ForgeUI:OnColorBoxDown( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if eMouseButton ~= 1 then return end
	
	ForgeColor:Show(self, "FF" .. wndControl:GetText(), { wndControl = wndControl })
end

function ForgeUI.API_ColorBoxChange(tAddon, wndControl, tSettings, sValue, bOverwrite, bAlpha)
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
			return sColor
		end
	else
		if string.len(sColor) > 6 then
			wndControl:SetText(string.sub(sColor, 0, 6))
		elseif string.len(sColor) == 6 then
			wndControl:SetText(sColor)
			wndControl:SetTextColor("FF" .. sColor)
			tSettings[sValue] = "FF" .. sColor
			return "FF" .. sColor
		end
	end
end

-----------------------------------------------------------------------------------------------
-- Check box
-----------------------------------------------------------------------------------------------

function ForgeUI.API_RegisterCheckBox(tAddon, wndControl, tSettings, strValue, strCallback)
	local tData = {
		tAddon = tAddon,
		tSettings = tSettings,
		strValue = strValue,
		strCallback = strCallback
	}
	
	wndControl:SetData(tData)
	wndControl:AddEventHandler("ButtonCheck", 	"OnChechBoxCheck", ForgeUIInst)
	wndControl:AddEventHandler("ButtonUncheck", "OnChechBoxCheck", ForgeUIInst)
	
	wndControl:SetCheck(tSettings[strValue])
end

function ForgeUI:OnChechBoxCheck( wndHandler, wndControl )
	local tData = wndControl:GetData()
	if tData == nil then return end
	
	tData.tSettings[tData.strValue] = wndControl:IsChecked()
	
	if tData.strCallback ~= nil then
		if tData.tAddon.tStylers[tData.strCallback] ~= nil then
			tData.tAddon.tStylers[tData.strCallback][tData.strCallback](tData.tAddon)
		else
			tData.tAddon[tData.strCallback](tData.tAddon, wndControl)
		end
	end
end

-----------------------------------------------------------------------------------------------
-- Number box
-----------------------------------------------------------------------------------------------

function ForgeUI.API_RegisterNumberBox(tAddon, wndControl, tSettings, strValue, tOptions, strCallback)
	local tData = {
		tAddon = tAddon,
		tSettings = tSettings,
		strValue = strValue,
		tOptions = tOptions,
		strCallback = strCallback
	}
	
	tData.prevValue = tSettings[strValue]
	
	wndControl:SetData(tData)
	wndControl:AddEventHandler("EditBoxChanged", 	"OnNumberBoxChanged", ForgeUIInst)
	
	wndControl:SetText(tSettings[strValue])
end

function ForgeUI:OnNumberBoxChanged( wndHandler, wndControl, strText )
	local tData = wndControl:GetData()
	if tData == nil then return end
	
	local newText = wndControl:GetText()
	
	if tonumber(newText) ~= nil then
		local newNumber = tonumber(newText)
	
		local tOptions = tData.tOptions
		if tOptions ~= nil then
			if tOptions.nMin ~= nil then
				if newNumber < tOptions.nMin then
					newNumber = tOptions.nMin
				end
			end
		end
		
		tData.tSettings[tData.strValue] = newNumber
		tData.prevValue = newNumber
		
		if tData.strCallback ~= nil then
			if tData.tAddon.tStylers[tData.strCallback] ~= nil then
				tData.tAddon.tStylers[tData.strCallback][tData.strCallback](tData.tAddon)
			else
				tData.tAddon[tData.strCallback](tData.tAddon, wndControl)
			end
		end
	else
		if wndControl:GetText() == "-" then return end
		wndControl:SetText(tData.prevValue)
	end
end

-----------------------------------------------------------------------------------------------
-- Dropdown
-----------------------------------------------------------------------------------------------
function ForgeUI.API_RegisterDropdown(tAddon, wndControl, tSettings, strValue, tOptions, strCallback)
	local wndDropdown = Apollo.LoadForm(ForgeUIInst.xmlUI, "ForgeUI_Dropdown", wndControl, ForgeUIInst)
	wndDropdown:FindChild("Value"):SetText(tOptions[tSettings[strValue]])
	
	for k, v in pairs(tOptions) do
		local wndButton = Apollo.LoadForm(ForgeUIInst.xmlUI, "ForgeUI_DropdownButton", wndDropdown:FindChild("OptionsHolder"), ForgeUIInst)
		
		local tData = {
			tAddon = tAddon,
			tSettings = tSettings,
			strValue = strValue,
			strCallback = strCallback,
			key = k,
		}
		
		wndButton:FindChild("DropdownButton"):SetText(v)
		wndButton:FindChild("DropdownButton"):SetData(tData)
	end
	
	local nLeft, nTop, nRight, nBottom = wndDropdown:FindChild("OptionsHolder"):GetAnchorOffsets()
	wndDropdown:FindChild("OptionsHolder"):SetAnchorOffsets(nLeft, nTop, nRight, 27 * (#tOptions + 1) + 2)
	
	wndDropdown:FindChild("OptionsHolder"):ArrangeChildrenVert()
end

function ForgeUI:OnDropdownButton( wndHandler, wndControl, eMouseButton )
	if wndControl:GetName() == "MoreButton" then
		wndControl:GetParent():FindChild("OptionsHolder"):Show(not wndControl:GetParent():FindChild("OptionsHolder"):IsShown())
	elseif wndControl:GetName() == "DropdownButton" then
		local tData = wndControl:GetData()
	
		wndControl:GetParent():GetParent():Show(false, true)
		wndControl:GetParent():GetParent():GetParent():FindChild("Value"):SetText(wndControl:GetText())
		
		if tData then
			if tData.tSettings and tData.strValue then
				tData.tSettings[tData.strValue] = tData.key
			end
			if tData.strCallback and tData.tAddon then
				if tData.tAddon[tData.strCallback] then
					tData.tAddon[tData.strCallback](tData.tAddon)
				end
			end
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

	if bResetDefaults == true then
		return {}
	end
	
	local tSett = {}
	local tAdd = tSettings_addons
	local tWindows = ForgeUI.CopyTable(tWindows, tSettings_windows)

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
			
			if not tWindows[addonName] then tWindows[addonName] = {} end
			if _tRegisteredWindows[addonName] ~= nil then
				for strName, tWindow in pairs(_tRegisteredWindows[addonName]) do
					local nLeft, nTop, nRight, nBottom = tWindow.wnd:GetAnchorOffsets()
					tWindows[addonName][strName] = {
						left = nLeft,
						top = nTop,
						right = nRight,
						bottom = nBottom
					}
				end
			end
		else
			tAdd[addonName] = nil
			tWindows[addonName] = nil
		end
	end
	
	return {
		_addons = tAdd,
		__settings = tSett,
		___windows = tWindows
	}
end

function ForgeUI:OnRestore(eType, tData)
	if tData._addons ~= nil then
		for name, data in pairs(tData._addons) do
			tSettings_addons[name] = data
		end
	end

	if tData.__settings ~= nil then
		tSettings = ForgeUI.CopyTable(tSettings, tData.__settings)
	end
	
	if tData.___windows ~= nil then
		tSettings_windows = ForgeUI.CopyTable(tSettings_windows, tData.___windows)
	end
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_Form Functions
-----------------------------------------------------------------------------------------------
function ForgeUI:OnForgeUIcmd(cmd, args)
	if cmd ~= "forgeui" then return end
	
	local tParams = {}
	for sOneParam in string.gmatch(args, "[^%s]+") do
		table.insert(tParams, sOneParam)
	end
	
	if args == "" then
		self:OnForgeUIOn()
	elseif tParams[1] == "reset" then
		self:ResetDefaults()
	elseif tParams[1] == "comm" then
		if tParams[2] == "returnVersion" then
			Print("Sending 'returnVersion' command")
			self:SendMessage("cmd", { strCommand = "returnVersion" })
		elseif tParams[2] == "print" then
			self:SendMessage("print", { strText = tParams[3] })
		end
	end
end

function ForgeUI:OnConfigure()
	self:OnForgeUIOn()
end

function ForgeUI:OnForgeUIOn()
	self.wndMain:Invoke()
end

function ForgeUI:OnFOrgeUIOff( wndHandler, wndControl, eMouseButton )
	self.wndMain:Close()
end

function ForgeUI:OnFocusCmd()
	GameLib.GetPlayerUnit():SetAlternateTarget(GameLib.GetTargetUnit())
end

function ForgeUI:ShowAddons( wndHandler, wndControl, eMouseButton )
	self.wndAddons:Show(not self.wndAddons:IsShown())
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
	bResetDefaults = true
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
	local wndConfirmWindow = Apollo.LoadForm(ForgeUIInst.xmlUI, "ForgeUI_ConfirmWindow", nil, ForgeUIInst)
	wndConfirmWindow:FindChild("YesButton"):SetData(fCallback)
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_AddonForm Functions
---------------------------------------------------------------------------------------------------

function ForgeUI:AddonForm_OnMore( wndHandler, wndControl, eMouseButton )
	wndControl:FindChild("Options"):Show(not wndControl:FindChild("Options"):IsShown())
end

function ForgeUI:AddonForm_OnReset( wndHandler, wndControl, eMouseButton )
	local tAddon = wndControl:GetParent():GetParent():GetParent():GetParent():GetData()
	ForgeUI.API_ResetAddonSettings(tAddon.strAddonName)
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_WarningWindow Functions
---------------------------------------------------------------------------------------------------

function ForgeUI.ShowWarning(strText)
	local wnd = Apollo.LoadForm(ForgeUIInst.xmlUI, "ForgeUI_WarningWindow", nil, ForgeUIInst)
	wnd:FindChild("Text"):SetText(strText)
end

function ForgeUI:ForgeUI_WarningWindow( wndHandler, wndControl, eMouseButton )
	local wnd = wndControl:GetParent()
	wnd:Show(false, false)
	wnd:Destroy()
end

---------------------------------------------------------------------------------------------------
-- Libraries
---------------------------------------------------------------------------------------------------
function ForgeUI:Debug(strText)
	if not self.tSettings.bDebug or not WildShell then return end
	
	WildShell:AppendText(strText, "FFBBBBBB")
end

function ForgeUI:Print(strText)
	if not WildShell then return end
	
	WildShell:AppendText(strText, "FF98C723")
end

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

function ForgeUI.GetTime()
	local l_time = GameLib.GetLocalTime()

	if ForgeUIInst.tSettings.b24HourFormat then
		return string.format("%02d:%02d", l_time.nHour, l_time.nMinute)	
	else
		if l_time.nHour > 12 then
			return string.format("%02d:%02d", l_time.nHour - 12, l_time.nMinute)
		else
			if l_time.nHour == 0 then
				return string.format("%02d:%02d", l_time.nHour + 12, l_time.nMinute)
			else
				return string.format("%02d:%02d", l_time.nHour, l_time.nMinute)
			end
		end
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