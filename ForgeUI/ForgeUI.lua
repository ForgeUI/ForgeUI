require "Window"
 
local ForgeUI = {}
local ForgeColor
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
AUTHOR = "Adam Jedlicka"
AUTHOR_LONG = "Winty Badass@Jabbit"
API_VERSION = 2

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

local tStylers = {}

local tRegisteredWindows = {} -- saving windows for repositioning them later

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
	self.version = "0.3.0"
	self.author = "WintyBadass"
	self.strAddonName = "~ForgeUI"
	self.strDisplayName = "ForgeUI"
	
	self.wndContainers  = {}
	
	-- optional
	self.settings_version = 1
    self.tSettings = {
		crMain = "FFFF0000",
		tClassColors = {
			crEngineer = "FFEFAB48",
			crEsper = "FF1591DB",
			crMedic = "FFFFE757",
			crSpellslinger = "FF98C723",
			crStalker = "FFD23EF4",
			crWarrior = "FFF54F4F"
		}
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
	self.xmlDoc = XmlDoc.CreateFromFile("ForgeUI.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- ForgeUI OnDocLoaded
-----------------------------------------------------------------------------------------------
function ForgeUI:OnDocLoaded()
	if self.xmlDoc == nil or not self.xmlDoc:IsLoaded() then return end
	
	ForgeColor = Apollo.GetPackage("ForgeColor").tPackage
	
	-- sprites
	Apollo.LoadSprites("ForgeUI_Sprite.xml", "ForgeUI_Sprite")
	Apollo.LoadSprites("ForgeUI_Icons.xml", "ForgeUI_Icons")
	
	-- tratums
	self.WorldStratum0 = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Stratum", nil, self)
	self.WorldStratum1 = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Stratum", nil, self)
	
	self.HudStratum0 = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Stratum", nil, self)
	self.HudStratum1 = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Stratum", nil, self)
	self.HudStratum2 = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Stratum", nil, self)
	self.HudStratum3 = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Stratum", nil, self)
	self.HudStratum4 = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Stratum", nil, self)
	self.HudStratum5 = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Stratum", nil, self)
	
	-- main window
    self.wndMain = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Form", nil, self)
	self.wndMain:FindChild("Version"):FindChild("Text"):SetText(self.version)
	self.wndMain:FindChild("Author"):FindChild("Text"):SetText(AUTHOR_LONG)
	
	-- addons list
	self.wndAddons = Apollo.LoadForm(self.xmlDoc, "ForgeUI_AddonsForm", self.wndMain, self)
	
	-- movables
	self.wndMovables = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Movables", nil, self)
	
	-- item list & container
	self.wndItemList = self.wndMain:FindChild("ForgeUI_Form_ItemList")
	self.wndItemContainer = self.wndMain:FindChild("ForgeUI_Form_ItemContainer")
	
	self.wndMainItemListHolder = Apollo.LoadForm(self.xmlDoc, "ForgeUI_ListHolder", self.wndItemList, self)

	-- slash commands
	Apollo.RegisterSlashCommand("forgeui", "OnForgeUIcmd", self)
	Apollo.RegisterSlashCommand("focus", "OnFocusCmd", self)
	
	bCanRegisterAddons = true
	
	ForgeUI.API_RegisterAddon(self)
	
	for _, tAddon in pairs(tAddonsToRegister) do -- loading not registered addons
		ForgeUI.API_RegisterAddon(tAddon)
	end
end

function ForgeUI:ForgeAPI_AfterRegistration()
	ForgeUI.API_AddItemButton(self, "Home", { bDefault = true, strContainer = "ForgeUI_Home" })
	ForgeUI.API_AddItemButton(self, "General", { strContainer = "ForgeUI_General" })
end

function ForgeUI:ForgeAPI_AfterRestore()
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.ForgeUI_General:FindChild("crEngineer"), self.tSettings.tClassColors, "crEngineer", false)
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.ForgeUI_General:FindChild("crEsper"), self.tSettings.tClassColors, "crEsper", false)
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.ForgeUI_General:FindChild("crMedic"), self.tSettings.tClassColors, "crMedic", false)
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.ForgeUI_General:FindChild("crSpellslinger"), self.tSettings.tClassColors, "crSpellslinger", false)
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.ForgeUI_General:FindChild("crStalker"), self.tSettings.tClassColors, "crStalker", false)
	ForgeUI.API_RegisterColorBox(self, self.wndContainers.ForgeUI_General:FindChild("crWarrior"), self.tSettings.tClassColors, "crWarrior", false)
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
		
		local wndAddon = Apollo.LoadForm(ForgeUIInst.xmlDoc, "ForgeUI_AddonForm", ForgeUIInst.wndAddons, ForgeUIInst)
		wndAddon:FindChild("AddonName"):SetText(tAddon.strDisplayName)
		
		wndAddon:SetData(tAddon)
		
		ForgeUIInst.wndAddons:ArrangeChildrenVert()
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
	
end

-----------------------------------------------------------------------------------------------
-- ForgeUI ItemList API
-----------------------------------------------------------------------------------------------
function ForgeUI.API_AddItemButton(tAddon, strDisplayName, tOptions)
	local wndButton = Apollo.LoadForm(ForgeUIInst.xmlDoc, "ForgeUI_Item", ForgeUIInst.wndMainItemListHolder, ForgeUIInst):FindChild("ForgeUI_Item_Button")
	wndButton:GetParent():FindChild("ForgeUI_Item_Text"):SetText(strDisplayName)
	
	local tData = {}
	tData.parentContainer = ForgeUIInst.wndMainItemListHolder
	
	if tOptions == nil then
		wndButton:SetData(tData)
		ForgeUIInst.wndMainItemListHolder:ArrangeChildrenVert()
		return wndButton
	end
	
	if tOptions.strContainer ~= nil then
		tAddon.wndContainers[tOptions.strContainer] = Apollo.LoadForm(tAddon.xmlDoc, tOptions.strContainer, ForgeUIInst.wndItemContainer, ForgeUIInst)
		tAddon.wndContainers[tOptions.strContainer]:Show(false, true)
		tData.itemContainer = tAddon.wndContainers[tOptions.strContainer]
	end
	
	wndButton:SetData(tData)
	
	ForgeUIInst.wndMainItemListHolder:ArrangeChildrenVert()
	
	if tOptions.bDefault then
		ForgeUIInst:SetActiveItem(wndButton)
	end
	
	return wndButton
end

function ForgeUI.API_AddListToItemButton(tAddon, wndButton, tList, tOptions)
end

function ForgeUI:SetActiveItem(wndControl)
	local data = wndControl:GetData()
	
	for _, wndButton in pairs(data.parentContainer:GetChildren()) do
		wndButton:FindChild("ForgeUI_Item_Text"):SetTextColor("FFFFFFFF")
		if wndButton:FindChild("ForgeUI_Item_Button"):GetData().itemContainer ~= nil then
			wndButton:FindChild("ForgeUI_Item_Button"):GetData().itemContainer:Show(false, true)
		end
	end
	
	wndControl:GetParent():FindChild("ForgeUI_Item_Text"):SetTextColor(self.tSettings.crMain)
	if data.itemContainer ~= nil then
		data.itemContainer:Show(true, true)
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
			wndMovable = Apollo.LoadForm(ForgeUIInst.xmlDoc, "ForgeUI_Movable", _tRegisteredWindows[tAddon.strAddonName][tSettings.strParent].movable, ForgeUIInst)
		elseif tSettings.nLevel ~= nil then
			if tSettings.nLevel > 0 and tSettings.nLevel < 5 then
				wndMovable = Apollo.LoadForm(ForgeUIInst.xmlDoc, "ForgeUI_Movable", ForgeUIInst.wndMovables:FindChild("Movables" .. tSettings.nLevel), ForgeUIInst)
			else
				wndMovable = Apollo.LoadForm(ForgeUIInst.xmlDoc, "ForgeUI_Movable", ForgeUIInst.wndMovables:FindChild("Movables"), ForgeUIInst)
			end
		end
	end
	if wndMovable == nil then
		wndMovable = Apollo.LoadForm(ForgeUIInst.xmlDoc, "ForgeUI_Movable", ForgeUIInst.wndMovables:FindChild("Movables"), ForgeUIInst)
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
	end
	
	wndMovable:AddEventHandler("WindowMove", "OnMovableMove", ForgeUIInst)
	
	_tRegisteredWindows[tAddon.strAddonName][strName].movable = wndMovable
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

	for _, tAddon in pairs(_tRegisteredWindows) do
		for _, tMovable in pairs(tAddon) do
			tMovable.movable:Show(false, true)
			tMovable.wnd:Show(tMovable.wnd_shown, true)
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
	
	if tData.strCallback ~= nil then
		if tData.tAddon.tStylers[tData.strCallback] ~= nil then
			tData.tAddon.tStylers[tData.strCallback][tData.strCallback](tData.tAddon)
		else
			tData.tAddon[tData.strCallback](tData.tAddon)
		end
	end
	
	tData.tSettings[tData.strValue] = wndControl:IsChecked()
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
	local tWindows = {}

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
			
			tWindows[addonName] = {}
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
		end
	end
	
	return {
		_addons = tAdd,
		__settings = tSett,
		___windows = tWindows
	}
end

function ForgeUI:OnRestore(eType, tData)
	if tData.__settings ~= nil then
		tSettings = ForgeUI.CopyTable(tSettings, tData.__settings)
	end
	
	if tData._addons ~= nil then
		for name, data in pairs(tData._addons) do
			tSettings_addons[name] = data
		end
	end
	
	if tData.___windows ~= nil then
		tSettings_windows = ForgeUI.CopyTable(tSettings_windows, tData.___windows)
	end
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_Form Functions
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
	local wndConfirmWindow = Apollo.LoadForm(ForgeUIInst.xmlDoc, "ForgeUI_ConfirmWindow", nil, ForgeUIInst)
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