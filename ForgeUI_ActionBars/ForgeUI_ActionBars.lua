require "Window"

local ForgeUI 
local ForgeUI_ActionBars = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------

 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function ForgeUI_ActionBars:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

   -- mandatory 
    self.api_version = 2
	self.version = "0.1.0"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_ActionBars"
	self.strDisplayName = "Action bars"
	
	self.wndContainers = {}
	
	self.tStylers = {
		["LoadStyle_ActionBar"] = self,
	}
	
	-- optional
	self.settings_version = 1
    self.tSettings = {
		tActionBar = {
			strContent = "LASBar",
			nContentMin = 0,
			nContentMax = 7,
			bVertical = false,
			bShowHotkey = true,
			crBorder = "FF000000",
		}
	}

    return o
end

function ForgeUI_ActionBars:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"ForgeUI"
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end

function ForgeUI_ActionBars:CreateBar(wnd, tOptions)
	wnd:FindChild("Holder"):DestroyChildren()

	local nButtons = tOptions.nContentMax - tOptions.nContentMin + 1
	local i = 0
	for id = tOptions.nContentMin, tOptions.nContentMax do
		local wndnBarButton = Apollo.LoadForm(self.xmlDoc, "ForgeUI_BarButton", wnd:FindChild("Holder"), self)
		local wndButton = Apollo.LoadForm(self.xmlDoc, tOptions.strContent, wndnBarButton:FindChild("Holder"), self)
		wndButton:SetContentId(id)
		
		if tOptions.bVertical then
		else
			wndnBarButton:SetAnchorPoints((1 / nButtons) * i, 0, (1 / nButtons) * (i + 1), 1)
			wndnBarButton:SetAnchorOffsets(0, 0, 1, 0)
		end
		
		ForgeUI.API_RegisterWindow(self, wndnBarButton, "ForgeUI_ActionBar_" .. id, { strParent = "ForgeUI_ActionBar_Holder", bMaintainRatio = true, crBorder = "FFCCCCCC", strDisplayName = id })
		
		i = i + 1
	end
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_ActionBars Registration
-----------------------------------------------------------------------------------------------
function ForgeUI_ActionBars:OnLoad()
    self.xmlDoc = XmlDoc.CreateFromFile("ForgeUI_ActionBars.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

function ForgeUI_ActionBars:OnDocLoaded()
	if self.xmlDoc == nil and not self.xmlDoc:IsLoaded() then return end
	
	if ForgeUI == nil then -- forgeui loaded
		ForgeUI = Apollo.GetAddon("ForgeUI")
	end
	
	ForgeUI.API_RegisterAddon(self)
end

function ForgeUI_ActionBars:ForgeAPI_AfterRegistration()
	self.wndActionBar = Apollo.LoadForm(self.xmlDoc, "ForgeUI_ActionBar", ForgeUI.HudStratum2, self)
	
	ForgeUI.API_RegisterWindow(self, self.wndActionBar, "ForgeUI_ActionBar", { strDisplayName = "Action bar", nLevel = 3, bMaintainRatio = true })
	ForgeUI.API_RegisterWindow(self, self.wndActionBar:FindChild("Holder"), "ForgeUI_ActionBar_Holder", { strParent = "ForgeUI_ActionBar", bInvisible = true })
end

function ForgeUI_ActionBars:ForgeAPI_AfterRestore()
	self:CreateBar(self.wndActionBar, self.tSettings.tActionBar)
	self.tStylers["LoadStyle_ActionBar"]["LoadStyle_ActionBar"](self)
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_ActionBars Styles
-----------------------------------------------------------------------------------------------
function ForgeUI_ActionBars:LoadStyle_ActionBar()
	for strName, wndBarButton in pairs(self.wndActionBar:FindChild("Holder"):GetChildren()) do
		wndBarButton:SetBGColor(self.tSettings.tActionBar.crBorder)
		wndBarButton:FindChild("Hotkey"):SetBGColor(self.tSettings.tActionBar.crBorder)
		wndBarButton:FindChild("Hotkey"):Show(self.tSettings.tActionBar.bShowHotkey)
		wndBarButton:FindChild("LASBar"):SetStyle("NoClip", self.tSettings.tActionBar.bShowHotkey)
	end
end

---------------------------------------------------------------------------------------------------
-- LASBar Functions
---------------------------------------------------------------------------------------------------

function ForgeUI_ActionBars:OnGenerateTooltip(wndControl, wndHandler, eType, arg1, arg2)
	local xml = nil
	if eType == Tooltip.TooltipGenerateType_ItemInstance then -- Doesn't need to compare to item equipped
		Tooltip.GetItemTooltipForm(self, wndControl, arg1, {})
	elseif eType == Tooltip.TooltipGenerateType_ItemData then -- Doesn't need to compare to item equipped
		Tooltip.GetItemTooltipForm(self, wndControl, arg1, {})
	elseif eType == Tooltip.TooltipGenerateType_GameCommand then
		xml = XmlDoc.new()
		xml:AddLine(arg2)
		wndControl:SetTooltipDoc(xml)
	elseif eType == Tooltip.TooltipGenerateType_Macro then
		xml = XmlDoc.new()
		xml:AddLine(arg1)
		wndControl:SetTooltipDoc(xml)
	elseif eType == Tooltip.TooltipGenerateType_Spell then
		if Tooltip ~= nil and Tooltip.GetSpellTooltipForm ~= nil then
			Tooltip.GetSpellTooltipForm(self, wndControl, arg1)
		end
	elseif eType == Tooltip.TooltipGenerateType_PetCommand then
		xml = XmlDoc.new()
		xml:AddLine(arg2)
		wndControl:SetTooltipDoc(xml)
	end
end

----------------------------------------------------------------------------------------------
-- ForgeUI_ActionBars Instance
-----------------------------------------------------------------------------------------------
local ForgeUI_ActionBarsInst = ForgeUI_ActionBars:new()
ForgeUI_ActionBarsInst:Init()
