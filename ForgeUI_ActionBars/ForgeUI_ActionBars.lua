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
		["LoadStyle_ActionButton"] = self,
	}
	
	-- optional
	self.settings_version = 1
    self.tSettings = {
		tActionBar = {
			strName = "ActionBar",
			strContent = "LASBar",
			nContentMin = 0,
			nContentMax = 7,
			bShowHotkey = true,
			crBorder = "FF000000",
			strStyler = "LoadStyle_ActionBar",
		},
		tStanceButton = {
			strName = "StanceButton",
			strContent = "GCBar",
			nContent = 2,
			bShowHotkey = true,
			crBorder = "FF000000",
			strStyler = "LoadStyle_ActionButton",
		},
	}
	
	self.tActionBars = {}

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

function ForgeUI_ActionBars:CreateBar(tOptions)
	local wnd = self.tActionBars[tOptions.strName]
	if self.tActionBars[tOptions.strName] == nil then
		wnd = Apollo.LoadForm(self.xmlDoc, "ForgeUI_" .. tOptions.strName, ForgeUI.HudStratum3, self)
	end
	
	ForgeUI.API_RegisterWindow(self, wnd, tOptions.strName, { bMaintainRatio = true })
	ForgeUI.API_RegisterWindow(self, wnd:FindChild("Holder"), tOptions.strName .. "_holder", { strParent = tOptions.strName, bInvisible = true, bMaintainRatio = true })
	
	wnd:FindChild("Holder"):DestroyChildren()

	local nButtons = tOptions.nContentMax - tOptions.nContentMin + 1
	local i = 0
	for id = tOptions.nContentMin, tOptions.nContentMax do
		local wndBarButton = Apollo.LoadForm(self.xmlDoc, "ForgeUI_BarButton", wnd:FindChild("Holder"), self)
		wndBarButton:SetData(tOptions)
		
		local wndButton = Apollo.LoadForm(self.xmlDoc, tOptions.strContent, wndBarButton:FindChild("Holder"), self)
		wndButton:SetContentId(id)
		
		wndBarButton:SetAnchorPoints((1 / nButtons) * i, 0, (1 / nButtons) * (i + 1), 1)
		wndBarButton:SetAnchorOffsets(0, 0, 1, 0)
		
		ForgeUI.API_RegisterWindow(self, wndBarButton, tOptions.strName .. "_" .. i, { strParent = tOptions.strName .. "_holder", crBorder = "FFFFFFFF", bMaintainRatio = true })
		
		i = i + 1
	end
	
	self.tStylers[tOptions.strStyler][tOptions.strStyler](self, wnd, tOptions)
	
	return wnd
end

function ForgeUI_ActionBars:CreateButton(tOptions)
	local wnd = self.tActionBars[tOptions.strName]
	if self.tActionBars[tOptions.strName] == nil then
		wnd = Apollo.LoadForm(self.xmlDoc, "ForgeUI_" .. tOptions.strName, ForgeUI.HudStratum3, self)
	end
	
	ForgeUI.API_RegisterWindow(self, wnd, tOptions.strName, { bMaintainRatio = true })
	
	wnd:DestroyChildren()
	
	local wndBarButton = Apollo.LoadForm(self.xmlDoc, "ForgeUI_BarButton", wnd, self)
	wndBarButton:SetData(tOptions)
	
	local wndButton = Apollo.LoadForm(self.xmlDoc, tOptions.strContent, wndBarButton:FindChild("Holder"), self)
	wndButton:SetContentId(tOptions.nContent)
	
	self.tStylers[tOptions.strStyler][tOptions.strStyler](self, wnd, tOptions)
	
	return wnd
end

-- filling methods
function ForgeUI_ActionBars:FillStances(wnd)
	local wndPopup = wnd:FindChild("Popup")
	local wndList = wnd:FindChild("List")
	local nSize = wndList:GetWidth()

	wndList:DestroyChildren()
	
	local nCount = 0
	for idx, spellObject in pairs(GameLib.GetClassInnateAbilitySpells().tSpells) do
		if idx % 2 == 1 then
			nCount = nCount + 1
			local wndCurr = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellBtn", wndList, self)
			wndCurr:SetData({sType = "stance"})
			wndCurr:FindChild("Icon"):SetSprite(spellObject:GetIcon())
			wndCurr:FindChild("Button"):SetData(nCount)
			
			wndCurr:SetAnchorOffsets(0, 0, nSize, nSize)

			if Tooltip and Tooltip.GetSpellTooltipForm then
				wndCurr:SetTooltipDoc(nil)
				Tooltip.GetSpellTooltipForm(self, wndCurr, spellObject)
			end
		end
	end
	
	local nLeft, nTop, nRight, nBottom = wndPopup:GetAnchorOffsets()
	wndPopup:SetAnchorOffsets(nLeft, -(nCount * nSize), nRight, nBottom)
	
	wndList:ArrangeChildrenVert()
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
	
end

function ForgeUI_ActionBars:ForgeAPI_AfterRestore()
	self.wndActionBar = self:CreateBar(self.tSettings.tActionBar)
	
	self.wndStanceBtn = self:CreateButton(self.tSettings.tStanceButton)
	self:FillStances(self.wndStanceBtn)
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_ActionBars Styles
-----------------------------------------------------------------------------------------------
function ForgeUI_ActionBars:LoadStyle_ActionBar(wnd, tOptions)
	for strName, wndBarButton in pairs(wnd:FindChild("Holder"):GetChildren()) do
		wndBarButton:SetBGColor(tOptions.crBorder)
		wndBarButton:FindChild("Hotkey"):SetBGColor(tOptions.crBorder)
		wndBarButton:FindChild("Hotkey"):Show(tOptions.bShowHotkey)
		wndBarButton:FindChild(tOptions.strContent):SetStyle("NoClip", tOptions.bShowHotkey)
		
		wndBarButton:FindChild("Popup"):SetBGColor(tOptions.crBorder)
	end
end

function ForgeUI_ActionBars:LoadStyle_ActionButton(wnd, tOptions)
	local wndBarButton = wnd:FindChild("ForgeUI_BarButton")

	wndBarButton:SetBGColor(tOptions.crBorder)
	wndBarButton:FindChild("Hotkey"):SetBGColor(tOptions.crBorder)
	wndBarButton:FindChild("Hotkey"):Show(tOptions.bShowHotkey)
	wndBarButton:FindChild(tOptions.strContent):SetStyle("NoClip", tOptions.bShowHotkey)
	
	wndBarButton:FindChild("Popup"):SetBGColor(tOptions.crBorder)
end

---------------------------------------------------------------------------------------------------
-- LASBar Functions
---------------------------------------------------------------------------------------------------

function ForgeUI_ActionBars:OnGenerateTooltip(wndControl, wndHandler, eType, arg1, arg2)
	local xml = nil
	if eType == Tooltip.TooltipGenerateType_ItemInstance then -- Doesn't need to compare to item equipped
		Tooltip.GetItemTooltipForm(self, wndControl, arg1, {})
		Print("A")
	elseif eType == Tooltip.TooltipGenerateType_ItemData then -- Doesn't need to compare to item equipped
		Tooltip.GetItemTooltipForm(self, wndControl, arg1, {})
	elseif eType == Tooltip.TooltipGenerateType_GameCommand then
		xml = XmlDoc.new()
		xml:AddLine(arg2)
		wndControl:SetTooltipDoc(xml)
		Print("A")
	elseif eType == Tooltip.TooltipGenerateType_Macro then
		xml = XmlDoc.new()
		xml:AddLine(arg1)
		wndControl:SetTooltipDoc(xml)
		Print("A")
	elseif eType == Tooltip.TooltipGenerateType_Spell then
		if Tooltip ~= nil and Tooltip.GetSpellTooltipForm ~= nil then
			Tooltip.GetSpellTooltipForm(self, wndControl, arg1)
		end
		Print("A")
	elseif eType == Tooltip.TooltipGenerateType_PetCommand then
		xml = XmlDoc.new()
		xml:AddLine(arg2)
		wndControl:SetTooltipDoc(xml)
		Print("A")
	end
end

function ForgeUI_ActionBars:OnSpellBtn( wndHandler, wndControl, eMouseButton )
	local sType = wndControl:GetParent():GetData().sType
	if sType == "stance" then
		GameLib.SetCurrentClassInnateAbilityIndex(wndHandler:GetData())
	elseif sType == "mount" then
		self.tSettings.nSelectedMount = wndControl:GetData():GetId()
	elseif sType == "potion" then
		self.tSettings.nSelectedPotion = wndControl:GetData():GetItemId()
	elseif sType == "path" then
		local tActionSet = ActionSetLib.GetCurrentActionSet()
		
		Event_FireGenericEvent("PathAbilityUpdated", wndControl:GetData())
		tActionSet[knPathLASIndex] = wndControl:GetData()
		ActionSetLib.RequestActionSetChanges(tActionSet)
	end
	wndControl:GetParent():GetParent():GetParent():Show(false, true)
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_BarButton Functions
---------------------------------------------------------------------------------------------------

function ForgeUI_ActionBars:BarButton_OnMouseDown( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if wndControl:GetName() == "ForgeUI_BarButton" and eMouseButton == 1 then
		wndControl:FindChild("Popup"):Show(true, true)
	end
end

----------------------------------------------------------------------------------------------
-- ForgeUI_ActionBars Instance
-----------------------------------------------------------------------------------------------
local ForgeUI_ActionBarsInst = ForgeUI_ActionBars:new()
ForgeUI_ActionBarsInst:Init()
