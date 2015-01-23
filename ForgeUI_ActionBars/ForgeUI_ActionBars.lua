require "Window"
require "AbilityBook"
require "GameLib"
require "PlayerPathLib"
require "Tooltip"
require "Unit"
 
-----------------------------------------------------------------------------------------------
-- ForgeUI_ActionBars Module Definition
-----------------------------------------------------------------------------------------------
local ForgeUI
local ForgeUI_ActionBars = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------

local knPathLASIndex = 10

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
	
	-- optional
	self.tSettings = {
		nSelectedMount = 0,
		nSelectedPotion = 0
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
 

-----------------------------------------------------------------------------------------------
-- ForgeUI_ActionBars OnLoad
-----------------------------------------------------------------------------------------------
function ForgeUI_ActionBars:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("ForgeUI_ActionBars.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

function ForgeUI_ActionBars:ForgeAPI_AfterRegistration()
	self.wndActionBar = Apollo.LoadForm(self.xmlDoc, "ForgeUI_ActionBar", ForgeUI.HudStratum4, self)
	self.wndSideBar1 = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SideBar1", ForgeUI.HudStratum4, self)
	self.wndShortcuBar = Apollo.LoadForm(self.xmlDoc, "ForgeUI_ShortcutBar", ForgeUI.HudStratum4, self)
	self.wndStanceBar = Apollo.LoadForm(self.xmlDoc, "ForgeUI_StanceBar", ForgeUI.HudStratum4, self)
	self.wndGadgetBar = Apollo.LoadForm(self.xmlDoc, "ForgeUI_GadgetBar", ForgeUI.HudStratum4, self)
	self.wndPotionBar = Apollo.LoadForm(self.xmlDoc, "ForgeUI_PotionBar", ForgeUI.HudStratum4, self)
	self.wndMountBar = Apollo.LoadForm(self.xmlDoc, "ForgeUI_MountBar", ForgeUI.HudStratum4, self)
	self.wndRecallBar = Apollo.LoadForm(self.xmlDoc, "ForgeUI_RecallBar", ForgeUI.HudStratum4, self)
	self.wndPathBar = Apollo.LoadForm(self.xmlDoc, "ForgeUI_PathBar", ForgeUI.HudStratum4, self)
	
	ForgeUI.API_RegisterWindow(self, self.wndActionBar, "ForgeUI_ActionBar", { bMaintainRatio = true, strDisplayName = "Action bar" })
	ForgeUI.API_RegisterWindow(self, self.wndSideBar1, "ForgeUI_SideBar1", { bMaintainRatio = true, strDisplayName = "Side bar" })
	ForgeUI.API_RegisterWindow(self, self.wndShortcuBar, "ForgeUI_ShortcutBar", { bMaintainRatio = true, strDisplayName = "Shortcut bar" })
	ForgeUI.API_RegisterWindow(self, self.wndStanceBar, "ForgeUI_StanceBar", { bMaintainRatio = true, strDisplayName = "Stance" })
	ForgeUI.API_RegisterWindow(self, self.wndGadgetBar, "ForgeUI_GadgetBar", { bMaintainRatio = true, strDisplayName = "Gadget" })
	ForgeUI.API_RegisterWindow(self, self.wndPotionBar, "ForgeUI_PotionBar", { bMaintainRatio = true, strDisplayName = "Potion" })
	ForgeUI.API_RegisterWindow(self, self.wndMountBar, "ForgeUI_MountBar", { bMaintainRatio = true, strDisplayName = "Mount" })
	ForgeUI.API_RegisterWindow(self, self.wndRecallBar, "ForgeUI_RecallBar", { bMaintainRatio = true, strDisplayName = "Recall" })
	ForgeUI.API_RegisterWindow(self, self.wndPathBar, "ForgeUI_PathBar", { bMaintainRatio = true, strDisplayName = "Path" })
	
	Apollo.RegisterEventHandler("AbilityBookChange", 		"RedrawActionBars", self)
	Apollo.RegisterEventHandler("ShowActionBarShortcut", 	"ShowShortcutBar", self)
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_ActionBars OnDocLoaded
-----------------------------------------------------------------------------------------------
function ForgeUI_ActionBars:OnDocLoaded()
	if self.xmlDoc == nil or not self.xmlDoc:IsLoaded() then return end
	
	if ForgeUI == nil then -- forgeui loaded
		ForgeUI = Apollo.GetAddon("ForgeUI")
	end
	
	ForgeUI.API_RegisterAddon(self)
end

function ForgeUI_ActionBars:RedrawActionBars()
	self:RedrawActionBar()
	self:RedrawRecalls()
	self:RedrawPath()
	self:RedrawMounts()
	self:RedrawPotions()
	self:RedrawStances()
	self:RedrawShortcutBar()
end

function ForgeUI_ActionBars:RedrawActionBar()
	self.wndActionBar:DestroyChildren()
	self.wndSideBar1:DestroyChildren()

	for i = 0, 7 do
		local wndActionBtn = Apollo.LoadForm(self.xmlDoc, "ForgeUI_ActionBtn", self.wndActionBar, self)
		wndActionBtn:FindChild("ActionBarButton"):SetContentId(i)
		wndActionBtn:SetAnchorPoints(0.125 * i, 0, 0.125 * (i + 1), 1)
	end
	
	for i = 0, 11 do
		local wndActionBtn = Apollo.LoadForm(self.xmlDoc, "ForgeUI_ActionBtn1", self.wndSideBar1, self)
		wndActionBtn:FindChild("ActionBarButton"):SetContentId(i + 12)
		wndActionBtn:SetAnchorPoints(0, (1 / 12) * i, 1, (1 / 12) * (i + 1))
	end
end

function ForgeUI_ActionBars:RedrawShortcutBar()
	self.wndShortcuBar:DestroyChildren()

	local nCount = 0
	for idx = 4, ActionSetLib.CodeEnumShortcutSet.Count do
		if IsActionBarSetVisible(idx) then
			nCount = nCount + 1
			for i = 0, 7 do
				local wndActionBtn = Apollo.LoadForm(self.xmlDoc, "ForgeUI_ShortcutBtn", self.wndShortcuBar, self)
				wndActionBtn:FindChild("ActionBarButton"):SetContentId(idx * 12 + i)
				wndActionBtn:SetAnchorPoints(0.125 * i, 0, 0.125 * (i + 1), 1)
			end
		end
	end
end

function ForgeUI_ActionBars:ShowShortcutBar(nBar, bIsVisible, nShortcuts)
	self:RedrawShortcutBar()
   	self.wndShortcuBar:Show(bIsVisible, true)
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_StanceBar Functions
---------------------------------------------------------------------------------------------------
function ForgeUI_ActionBars:OnStancePopup( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if eMouseButton ~= 1 then return end
	local wndPopup = self.wndStanceBar:FindChild("Popup")
	
	self:RedrawStances()
	
	wndPopup:Show(not wndPopup:IsShown())
end

function ForgeUI_ActionBars:RedrawStances()
	local wndPopup = self.wndStanceBar:FindChild("Popup")
	local wndList = self.wndStanceBar:FindChild("List")
	local nSize = wndList:GetWidth()

	wndList:DestroyChildren()
	
	local nCount = 0
	for idx, spellObject in pairs(GameLib.GetClassInnateAbilitySpells().tSpells) do
		if idx % 2 == 1 then
			nCount = nCount + 1
			local strKeyBinding = GameLib.GetKeyBinding("SetStance"..nCount) -- hardcoded formatting
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

---------------------------------------------------------------------------------------------------
-- ForgeUI_PotionBar Functions
---------------------------------------------------------------------------------------------------

function ForgeUI_ActionBars:OnPotionPopup( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if eMouseButton ~= 1 then return end
	local wndPopup = self.wndPotionBar:FindChild("Popup")
	
	self:RedrawPotions()
	
	wndPopup:Show(not wndPopup:IsShown())
end

function ForgeUI_ActionBars:RedrawPotions()
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end
	
	local wndPopup = self.wndPotionBar:FindChild("Popup")
	local wndList = self.wndPotionBar:FindChild("List")
	
	local nSize = wndList:GetWidth()
	
	wndList:DestroyChildren()
	
	local tItemList = unitPlayer:GetInventoryItems()
	local tPotions = {}
	
	for idx, tItemData in pairs(tItemList) do
		if tItemData and tItemData.itemInBag and tItemData.itemInBag:GetItemCategory() == 48 then--and tItemData.itemInBag:GetConsumable() == "Consumable" then
			local itemPotion = tItemData.itemInBag
			tPotions[itemPotion:GetItemId()] = {
				itemObject = itemPotion,
				nCount = itemPotion:GetStackCount()
			}
		end
	end
	
	local nCount = 0
	for idx, tData  in pairs(tPotions) do
		nCount = nCount + 1
	
		local wndCurr = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellBtn", wndList, self)
		wndCurr:SetData({sType = "potion"})
		wndCurr:FindChild("Icon"):SetSprite(tData.itemObject:GetIcon())
		wndCurr:FindChild("Button"):SetData(tData.itemObject)

		wndCurr:SetAnchorOffsets(0, 0, nSize, nSize)
		
		wndCurr:SetTooltipDoc(nil)
		Tooltip.GetItemTooltipForm(self, wndCurr, tData.itemObject, {})
	end

	GameLib.SetShortcutPotion(self.tSettings.nSelectedPotion)

	local nLeft, nTop, nRight, nBottom = wndPopup:GetAnchorOffsets()
	wndPopup:SetAnchorOffsets(nLeft, -(nCount * nSize), nRight, nBottom)
	
	wndList:ArrangeChildrenVert()
	
	--self.wndPotionBar:Show(nCount > 0)
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_MountBar Functions
---------------------------------------------------------------------------------------------------

function ForgeUI_ActionBars:OnMountPopup( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if eMouseButton ~= 1 then return end
	local wndPopup = self.wndMountBar:FindChild("Popup")
	
	self:RedrawMounts()
	
	wndPopup:Show(not wndPopup:IsShown())
end

function ForgeUI_ActionBars:RedrawMounts()
	local wndPopup = self.wndMountBar:FindChild("Popup")
	local wndList = self.wndMountBar:FindChild("List")
	
	local nSize = wndList:GetWidth()
	
	wndList:DestroyChildren()

	local tMountList = AbilityBook.GetAbilitiesList(Spell.CodeEnumSpellTag.Mount) or {}
	local tSelectedSpellObj = nil

	local nCount = 0
	for idx, tMount in pairs(tMountList) do
		nCount = nCount + 1
		
		local tSpellObject = tMount.tTiers[1].splObject

		if tSpellObject:GetId() == self.tSettings.nSelectedMount then
			tSelectedSpellObj = tSpellObject
		end

		local wndCurr = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellBtn", wndList, self)
		wndCurr:SetData({sType = "mount"})
		wndCurr:FindChild("Icon"):SetSprite(tSpellObject:GetIcon())
		wndCurr:FindChild("Button"):SetData(tSpellObject)

		wndCurr:SetAnchorOffsets(0, 0, nSize, nSize)
		
		if Tooltip and Tooltip.GetSpellTooltipForm then
			wndCurr:SetTooltipDoc(nil)
			Tooltip.GetSpellTooltipForm(self, wndCurr, tSpellObject, {})
		end
	end

	if tSelectedSpellObj == nil and #tMountList > 0 then
		tSelectedSpellObj = tMountList[1].tTiers[1].splObject
	end

	if tSelectedSpellObj ~= nil then
		GameLib.SetShortcutMount(tSelectedSpellObj:GetId())
	end

	local nLeft, nTop, nRight, nBottom = wndPopup:GetAnchorOffsets()
	wndPopup:SetAnchorOffsets(nLeft, -(nCount * nSize), nRight, nBottom)
	
	wndList:ArrangeChildrenVert()
	
	self.wndMountBar:Show(nCount > 0)
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_RecallBar Functions
---------------------------------------------------------------------------------------------------

function ForgeUI_ActionBars:OnRecallPopup( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if eMouseButton ~= 1 then return end
	local wndPopup = wndHandler:FindChild("Popup")
	local wndList = wndPopup:FindChild("List")

	self:RedrawRecalls()
	
	wndPopup:Show(not wndPopup:IsShown())
end

function ForgeUI_ActionBars:OnRecallEntry( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if eMouseButton == 1 then
		GameLib.SetDefaultRecallCommand(wndControl:FindChild("RecallActionBtn"):GetData())
		self.wndRecallBar:FindChild("ActionBarButton"):SetContentId(wndControl:FindChild("RecallActionBtn"):GetData())
	end
	self.wndRecallBar:FindChild("Popup"):Show(false, true)
end

function ForgeUI_ActionBars:RedrawRecalls()
	local wndPopup = self.wndRecallBar:FindChild("Popup")
	local wndList = self.wndRecallBar:FindChild("List")

	local nSize = wndList:GetWidth()
	
	wndList:DestroyChildren()
	
	local nCount = 0
	local bHasBinds = false
	local bHasWarplot = false
	local guildCurr = nil
	
	-- todo: condense this 
	if GameLib.HasBindPoint() == true then
		--load recall
		local wndBind = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellActionBtn", wndList, self)
		wndBind:FindChild("RecallActionBtn"):SetContentId(GameLib.CodeEnumRecallCommand.BindPoint)
		wndBind:FindChild("RecallActionBtn"):SetData(GameLib.CodeEnumRecallCommand.BindPoint)
		
		wndBind:SetAnchorOffsets(0, 0, nSize, nSize)
		
		bHasBinds = true
		nCount = nCount + 1
	end
	
	if HousingLib.IsResidenceOwner() == true then
		-- load house
		local wndHouse = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellActionBtn", wndList, self)
		wndHouse:FindChild("RecallActionBtn"):SetContentId(GameLib.CodeEnumRecallCommand.House)
		wndHouse:FindChild("RecallActionBtn"):SetData(GameLib.CodeEnumRecallCommand.House)
		
		wndHouse:SetAnchorOffsets(0, 0, nSize, nSize)

		bHasBinds = true
		nCount = nCount + 1		
	end

	-- Determine if this player is in a WarParty
	for key, guildCurr in pairs(GuildLib.GetGuilds()) do
		if guildCurr:GetType() == GuildLib.GuildType_WarParty then
			bHasWarplot = true
			break
		end
	end
	
	if bHasWarplot == true then
		-- load warplot
		local wndWarplot = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellActionBtn", wndList, self)
		wndWarplot:FindChild("RecallActionBtn"):SetContentId(GameLib.CodeEnumRecallCommand.Warplot)
		wndWarplot:FindChild("RecallActionBtn"):SetData(GameLib.CodeEnumRecallCommand.Warplot)
		
		wndWarplot:SetAnchorOffsets(0, 0, nSize, nSize)

		bHasBinds = true
		nCount = nCount + 1	
	end
	
	local bIllium = false
	local bThayd = false
	
	for idx, tSpell in pairs(AbilityBook.GetAbilitiesList(Spell.CodeEnumSpellTag.Misc) or {}) do
		if tSpell.bIsActive and tSpell.nId == GameLib.GetTeleportIlliumSpell():GetBaseSpellId() then
			bIllium = true
		end
		if tSpell.bIsActive and tSpell.nId == GameLib.GetTeleportThaydSpell():GetBaseSpellId() then
			bThayd = true
		end
	end
	
	if bIllium then
		-- load capital
		local wndWarplot = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellActionBtn", wndList, self)
		wndWarplot:FindChild("RecallActionBtn"):SetContentId(GameLib.CodeEnumRecallCommand.Illium)
		wndWarplot:FindChild("RecallActionBtn"):SetData(GameLib.CodeEnumRecallCommand.Illium)
		
		wndWarplot:SetAnchorOffsets(0, 0, nSize, nSize)

		bHasBinds = true
		nCount = nCount + 1
	end
	
	if bThayd then
		-- load capital
		local wndWarplot = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellActionBtn", wndList, self)
		wndWarplot:FindChild("RecallActionBtn"):SetContentId(GameLib.CodeEnumRecallCommand.Thayd)
		wndWarplot:FindChild("RecallActionBtn"):SetData(GameLib.CodeEnumRecallCommand.Thayd)	
			
		wndWarplot:SetAnchorOffsets(0, 0, nSize, nSize)

		bHasBinds = true
		nCount = nCount + 1
	end
	
	local nLeft, nTop, nRight, nBottom = wndPopup:GetAnchorOffsets()
	wndPopup:SetAnchorOffsets(nLeft, -(nCount * nSize), nRight, nBottom)
	
	wndList:ArrangeChildrenVert()
	
	self.wndRecallBar:Show(bHasBinds, true)
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_PathBar Functions
---------------------------------------------------------------------------------------------------

function ForgeUI_ActionBars:OnPathPopup( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if eMouseButton ~= 1 then return end
	local wndPopup = wndHandler:FindChild("Popup")
	local wndList = wndPopup:FindChild("List")
	
	wndList:ArrangeChildrenVert(0)
	wndPopup:Show(not wndPopup:IsShown())
end

function ForgeUI_ActionBars:RedrawPath()
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end

	local tAbilities = AbilityBook.GetAbilitiesList(Spell.CodeEnumSpellTag.Path)
	if not tAbilities then
		return	
	end

	local wndPopup = self.wndPathBar:FindChild("Popup")
	local wndList = self.wndPathBar:FindChild("List")
	
	local nSize = wndList:GetWidth()
	
	wndList:DestroyChildren()
	
	local nCount = 0
	local nListHeight = 0
	for _, tAbility in pairs(tAbilities) do
		if tAbility.bIsActive then
			nCount = nCount + 1
			local spellObject = tAbility.tTiers[tAbility.nCurrentTier].splObject
			local wndCurr = Apollo.LoadForm(self.xmlDoc, "ForgeUI_SpellBtn", wndList, self)
			wndCurr:SetData({sType = "path"})
			wndCurr:FindChild("Icon"):SetSprite(spellObject:GetIcon())
			wndCurr:FindChild("Button"):SetData(tAbility.nId)
			
			wndCurr:SetAnchorOffsets(0, 0, nSize, nSize)
			
			if Tooltip and Tooltip.GetSpellTooltipForm then
				wndCurr:SetTooltipDoc(nil)
				Tooltip.GetSpellTooltipForm(self, wndCurr, spellObject)
			end
		end
	end
	
	self.wndPathBar:Show(nCount > 0)
	
	local nLeft, nTop, nRight, nBottom = wndPopup:GetAnchorOffsets()
	wndPopup:SetAnchorOffsets(nLeft, -(nCount * nSize), nRight, nBottom)
	
	wndList:ArrangeChildrenVert(0)
end

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

function ForgeUI_ActionBars:OnSpellBtn( wndHandler, wndControl, eMouseButton )
	local sType = wndControl:GetParent():GetData().sType
	if sType == "stance" then
		GameLib.SetCurrentClassInnateAbilityIndex(wndHandler:GetData())
		self.wndStanceBar:FindChild("Popup"):Show(false, true)
	elseif sType == "mount" then
		self.tSettings.nSelectedMount = wndControl:GetData():GetId()
		self:RedrawMounts()
		self.wndMountBar:FindChild("Popup"):Show(false, true)
	elseif sType == "potion" then
		self.tSettings.nSelectedPotion = wndControl:GetData():GetItemId()
		self:RedrawPotions()
		self.wndPotionBar:FindChild("Popup"):Show(false, true)
	elseif sType == "path" then
		local tActionSet = ActionSetLib.GetCurrentActionSet()
		
		Event_FireGenericEvent("PathAbilityUpdated", wndControl:GetData())
		tActionSet[knPathLASIndex] = wndControl:GetData()
		ActionSetLib.RequestActionSetChanges(tActionSet)
		self:RedrawPath()
		
		self.wndPathBar:FindChild("Popup"):Show(false, true)
	end
end

function ForgeUI_ActionBars:ForgeAPI_AfterRestore()
	GameLib.SetDefaultRecallCommand(GameLib.GetDefaultRecallCommand())
	self.wndRecallBar:FindChild("ActionBarButton"):SetContentId(GameLib.GetDefaultRecallCommand())
	
	self:RedrawActionBars()
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_ActionBars Instance
-----------------------------------------------------------------------------------------------
local ForgeUI_ActionBarsInst = ForgeUI_ActionBars:new()
ForgeUI_ActionBarsInst:Init()
