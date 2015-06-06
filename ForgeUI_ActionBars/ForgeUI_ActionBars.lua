----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI addon
--
-- name: 		ForgeUI_SprintDash.lua
-- author:		Winty Badass@Jabbit
-- about:		Sprint/Dash meter addon for ForgeUI
-----------------------------------------------------------------------------------------------

require "Window"

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI

-----------------------------------------------------------------------------------------------
-- ForgeUI Addon Definition
-----------------------------------------------------------------------------------------------
local ForgeUI_ActionBars = {
	_NAME = "ForgeUI_ActionBars",
	_API_VERSION = 3,
	_VERSION = "2.0",
	DISPLAY_NAME = "Action bars",

	tSettings = {
    char = {
  		nSelectedMount = 0,
  		nSelectedPotion = 0,
  		nSelectedPath = 0,
    },
    profile = {
  		tFrames = {
				ActionBar = {
					strKey = "ForgeUI_ActionBar",
					strName = "Action bar",
					strSnapTo = "bottom",
					strContentType = "LASBar",
					nButtons = 8,
					nButtonSize = 50,
					nMinId = 0,
					nButtonPadding = 3,
					bDrawHotkey = false,
					bDrawShortcutBottom = true,
				},
				SecondaryBarOne = {
					strKey = "ForgeUI_SecondaryBarOne",
					strName = "Secondary bar",
					strSnapTo = "right",
					strContentType = "ABar",
					nButtons = 12,
					nButtonSize = 40,
					nMinId = 0,
					nButtonPadding = 0,
					bDrawHotkey = false,
					bDrawShortcutBottom = false,
				},
			}
    }
	}
}

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local tSnapToPoints = {
	["bottom"] = { 0.5, 1, 0.5, 1 },
	["right"] = { 1, 0.5, 1, 0.5 },
	["top"] = { 0.5, 0, 0.5, 0 },
	["left"] = { 0, 0.5, 0, 0.5 },
}

local tSnapToOffsets = {
	["bottom"] = { 0, -15, 0, -15 },
	["right"] = { -5, 0, -5, 0 },
	["top"] = { 0, 15, 0, 15 },
	["left"] = { 5, 0, 5, 0 },
}

-----------------------------------------------------------------------------------------------
-- Local
-----------------------------------------------------------------------------------------------
local tBars = {}
local wndMenuItem = nil

-----------------------------------------------------------------------------------------------
-- Addon functions
-----------------------------------------------------------------------------------------------
function ForgeUI_ActionBars:GenerateBar(tBar)
	local wndNewBar = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Bar", F:API_GetStratum("high"), self)
	wndNewBar:SetData(tBar)

	tBars[tBar.strKey] = wndNewBar

	self:SetupBar(tBar)
	self:SetupButtons(tBar)
	self:EditButtons(tBar)

	F:API_AddMenuToMenuItem(self, wndMenuItem, tBar.strName, tBar.strKey)

	return wndNewBar
end

function ForgeUI_ActionBars:SetupBar(tBar)
	local wndBar = tBars[tBar.strKey]

	wndBar:SetAnchorPoints(unpack(tSnapToPoints[tBar.strSnapTo]))
	wndBar:SetAnchorOffsets(self:Helper_BarOffsets(tBar))

	if tBar.strSnapToLast ~= tBar.strSnapTo then
		F:API_ResetMover(self, tBar.strKey)
	end
	F:API_RegisterMover(self, wndBar, tBar.strKey, tBar.strName, "general", { strStratum = "high" })
	tBar.strSnapToLast = tBar.strSnapTo
end

function ForgeUI_ActionBars:SetupButtons(tBar)
	local wndBar = tBars[tBar.strKey]

	wndBar:DestroyChildren()
	for i = tBar.nMinId, tBar.nButtons - 1 do
		local wndBarButton = Apollo.LoadForm(self.xmlDoc, "ForgeUI_BarButton", wndBar, self)
	end
end

function ForgeUI_ActionBars:EditButtons(tBar)
	local wndBar = tBars[tBar.strKey]

	for k, v in pairs(wndBar:GetChildren()) do
		local i = k - 1
		local wndBarButton = v

		if tBar.strSnapTo == "bottom" or tBar.strSnapTo == "top" then
			wndBarButton:SetAnchorOffsets(
				i * tBar.nButtonSize - i + tBar.nButtonPadding * i,
				0,
				(i + 1) * tBar.nButtonSize - i + tBar.nButtonPadding * i,
				tBar.nButtonSize)
		elseif tBar.strSnapTo == "right" or tBar.strSnapTo == "left" then
			wndBarButton:SetAnchorOffsets(
				0,
				i * tBar.nButtonSize - i + tBar.nButtonPadding * i,
				tBar.nButtonSize,
				(i + 1) * tBar.nButtonSize - i + tBar.nButtonPadding * i)
		end

		local tXml = self.xmlDoc:ToTable()
		local tActionButton
		for k, v in pairs(tXml) do
			if v.Name == "ForgeUI_ActionButton" then
				tActionButton = v
			end
		end

		tActionButton.ContentId = i
		tActionButton.ContentType = tBar.strContentType
		tActionButton.DrawHotkey = tBar.bDrawHotkey
		tActionButton.DrawShortcutBottom = false

		wndBarButton:FindChild("Holder"):DestroyChildren()
		wndBarButton:FindChild("Holder"):SetAnchorOffsets(1, 1, -1, -1)
		wndBarButton:FindChild("Hotkey"):Show(false)

		if tBar.strSnapTo == "bottom" or tBar.strSnapTo == "top" then
			tActionButton.DrawShortcutBottom = tBar.bDrawShortcutBottom

			wndBarButton:FindChild("Holder"):SetAnchorOffsets(1, 1, -1, tBar.bDrawShortcutBottom and 10 or -1)
			wndBarButton:FindChild("Hotkey"):Show(tBar.bDrawShortcutBottom)
		end

		Apollo.LoadForm(XmlDoc.CreateFromTable(tXml), "ForgeUI_ActionButton", wndBarButton:FindChild("Holder"), self)
	end
end

-- filling methods
-- stances
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

-- mounts
function ForgeUI_ActionBars:FillMounts(wnd)
	local wndPopup = wnd:FindChild("Popup")
	local wndList = wnd:FindChild("List")

	local nSize = wndList:GetWidth()

	wndList:DestroyChildren()

	local tMountList = GameLib.GetMountList()
	local tSelectedSpellObj = nil

	local nCount = 0
	for idx, tMount in pairs(tMountList) do
		if tMount.bIsKnown then
			nCount = nCount + 1

			local tSpellObject = tMount.splObject

			if tSpellObject:GetId() == self._DB.char.nSelectedMount then
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
	end

	if tSelectedSpellObj == nil and #tMountList > 0 then
		tSelectedSpellObj = tMountList[1].splObject
	end

	if tSelectedSpellObj ~= nil then
		GameLib.SetShortcutMount(tSelectedSpellObj:GetId())
	end

	local nLeft, nTop, nRight, nBottom = wndPopup:GetAnchorOffsets()
	wndPopup:SetAnchorOffsets(nLeft, -(nCount * nSize), nRight, nBottom)

	wndList:ArrangeChildrenVert()

	wnd:Show(nCount > 0, true)
end

-- recalls
function ForgeUI_ActionBars:FillRecalls(wnd)
	local wndPopup = wnd:FindChild("Popup")
	local wndList = wnd:FindChild("List")

	local nSize = wndList:GetWidth()

	wndList:DestroyChildren()

	local nCount = 0
	local bHasBinds = false
	local bHasWarplot = false
	local guildCurr = nil

	-- todo: condense this
	if GameLib.HasBindPoint() == true then
		--load recall
		local wndBind = Apollo.LoadForm(self.xmlDoc, "GCBar", wndList, self)
		wndBind:SetContentId(GameLib.CodeEnumRecallCommand.BindPoint)
		wndBind:SetData(GameLib.CodeEnumRecallCommand.BindPoint)

		wndBind:AddEventHandler("MouseButtonDown", "RecallBtn_OnButtonDown", self)

		wndBind:SetAnchorPoints(0, 0, 0, 0)
		wndBind:SetAnchorOffsets(0, 0, nSize, nSize)

		bHasBinds = true
		nCount = nCount + 1
	end

	if HousingLib.IsResidenceOwner() == true then
		-- load house
		local wndHouse = Apollo.LoadForm(self.xmlDoc, "GCBar", wndList, self)
		wndHouse:SetContentId(GameLib.CodeEnumRecallCommand.House)
		wndHouse:SetData(GameLib.CodeEnumRecallCommand.House)

		wndHouse:AddEventHandler("MouseButtonDown", "RecallBtn_OnButtonDown", self)

		wndHouse:SetAnchorPoints(0, 0, 0, 0)
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
		local wndWarplot = Apollo.LoadForm(self.xmlDoc, "GCBar", wndList, self)
		wndWarplot:SetContentId(GameLib.CodeEnumRecallCommand.Warplot)
		wndWarplot:SetData(GameLib.CodeEnumRecallCommand.Warplot)

		wndWarplot:AddEventHandler("MouseButtonDown", "RecallBtn_OnButtonDown", self)

		wndWarplot:SetAnchorPoints(0, 0, 0, 0)
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
		local wndWarplot = Apollo.LoadForm(self.xmlDoc, "GCBar", wndList, self)
		wndWarplot:SetContentId(GameLib.CodeEnumRecallCommand.Illium)
		wndWarplot:SetData(GameLib.CodeEnumRecallCommand.Illium)

		wndWarplot:AddEventHandler("MouseButtonDown", "RecallBtn_OnButtonDown", self)

		wndWarplot:SetAnchorPoints(0, 0, 0, 0)
		wndWarplot:SetAnchorOffsets(0, 0, nSize, nSize)

		bHasBinds = true
		nCount = nCount + 1
	end

	if bThayd then
		-- load capital
		local wndWarplot = Apollo.LoadForm(self.xmlDoc, "GCBar", wndList, self)
		wndWarplot:SetContentId(GameLib.CodeEnumRecallCommand.Thayd)
		wndWarplot:SetData(GameLib.CodeEnumRecallCommand.Thayd)

		wndWarplot:AddEventHandler("MouseButtonDown", "RecallBtn_OnButtonDown", self)

		wndWarplot:SetAnchorPoints(0, 0, 0, 0)
		wndWarplot:SetAnchorOffsets(0, 0, nSize, nSize)

		bHasBinds = true
		nCount = nCount + 1
	end

	local nLeft, nTop, nRight, nBottom = wndPopup:GetAnchorOffsets()
	wndPopup:SetAnchorOffsets(nLeft, -(nCount * nSize), nRight, nBottom)

	wndList:ArrangeChildrenVert()

	wnd:Show(bHasBinds, true)
end

-- potions
function ForgeUI_ActionBars:FillPotions(wnd)
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end

	local wndPopup = wnd:FindChild("Popup")
	local wndList = wnd:FindChild("List")

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

	GameLib.SetShortcutPotion(self._DB.char.nSelectedPotion)

	local nLeft, nTop, nRight, nBottom = wndPopup:GetAnchorOffsets()
	wndPopup:SetAnchorOffsets(nLeft, -(nCount * nSize), nRight, nBottom)

	wndList:ArrangeChildrenVert()

	self.wndPotionBtn:Show(nCount > 0)
end

-- path
function ForgeUI_ActionBars:FillPath(wnd)
	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil or not unitPlayer:IsValid() then return end

	local tAbilities = AbilityBook.GetAbilitiesList(Spell.CodeEnumSpellTag.Path)
	if not tAbilities then
		return
	end

	local wndPopup = wnd:FindChild("Popup")
	local wndList = wnd:FindChild("List")

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

	wnd:Show(nCount > 0)

	local tActionSet = ActionSetLib.GetCurrentActionSet()

	if self._DB.char.nSelectedPath > 0 and ActionSetLib.IsSpellCompatibleWithActionSet(self._DB.char.nSelectedPath) ~= 3 then
		Event_FireGenericEvent("PathAbilityUpdated", self._DB.char.nSelectedPath)
		tActionSet[10] = self._DB.char.nSelectedPath
	else
		tActionSet[10] = tActionSet[10]
		self._DB.char.nSelectedPath = tActionSet[10]
	end
	ActionSetLib.RequestActionSetChanges(tActionSet)

	local nLeft, nTop, nRight, nBottom = wndPopup:GetAnchorOffsets()
	wndPopup:SetAnchorOffsets(nLeft, -(nCount * nSize), nRight, nBottom)

	wndList:ArrangeChildrenVert(0)
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_ActionBars Registration
-----------------------------------------------------------------------------------------------
function ForgeUI_ActionBars:ForgeAPI_Init()
  self.xmlDoc = XmlDoc.CreateFromFile("..//ForgeUI_ActionBars//ForgeUI_ActionBars.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)

	wndMenuItem = F:API_AddMenuItem(self, self.DISPLAY_NAME, "General")
end

function ForgeUI_ActionBars:OnDocLoaded()
	if self.xmlDoc == nil and not self.xmlDoc:IsLoaded() then return end

  --Apollo.RegisterEventHandler("ShowActionBarShortcut", 	"ShowShortcutBar", self) -- TODO: Make it work

  if GameLib.GetPlayerUnit() then
		self:OnCharacterCreated()
	else
		Apollo.RegisterEventHandler("CharacterCreated", 	"OnCharacterCreated", self)
	end
end

function ForgeUI_ActionBars:OnCharacterCreated()
	for k, v in pairs(self._DB.profile.tFrames) do
		self:GenerateBar(v)
	end
end

function ForgeUI_ActionBars:GenerateBars()
	self.wndActionBar = self:GenerateBar(self._DB.profile.tFrames.ActionBar)
end

function ForgeUI_ActionBars:ShowShortcutBar(nBar, bIsVisible, nShortcuts)
	if nBar == ActionSetLib.CodeEnumShortcutSet.VehicleBar then -- vehiclebar
		if self.wndActionBar then
			self.wndActionBar:Show(not bIsVisible, true)
		end

		if bIsVisible then
			self.wndVehicleBar = self:CreateBar(self.tActionBars.tVehicleBar)
			self.wndVehicleBar:Show(bIsVisible, true)
		elseif self.wndVehicleBar ~= nil then
			self.wndVehicleBar:Show(bIsVisible, true)
		end
	end

	if nBar == ActionSetLib.CodeEnumShortcutSet.FloatingSpellBar then -- spellbar
		if bIsVisible then
			self.wndSpellBar = self:CreateBar(self.tActionBars.tSpellBar)
			self.wndSpellBar:Show(bIsVisible, true)
		elseif self.wndSpellBar ~= nil then
			self.wndSpellBar:Show(bIsVisible, true)
		end
	end
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_ActionBars Styles
-----------------------------------------------------------------------------------------------
function ForgeUI_ActionBars:LoadStyle_ActionBar(wnd, tOptions)
	for strName, wndBarButton in pairs(wnd:GetChildren()) do
		wndBarButton:SetBGColor(tOptions.crBorder)
		wndBarButton:FindChild(tOptions.strContent):SetStyleEx("DrawHotkey", self._DB.profile.bShowHotkeys)
		wndBarButton:FindChild(tOptions.strContent):SetStyle("NoClip", tOptions.bShowHotkey)

		wndBarButton:FindChild("Popup"):SetBGColor(tOptions.crBorder)
	end
end

function ForgeUI_ActionBars:LoadStyle_ActionButton(wnd, tOptions)
	local wndBarButton = wnd:FindChild("ForgeUI_BarButton")

	wndBarButton:SetBGColor(tOptions.crBorder)
	wndBarButton:FindChild(tOptions.strContent):SetStyleEx("DrawHotkey", self._DB.profile.bShowHotkeys)
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
		self.wndStanceBtn:FindChild("Popup"):Show(false, true)
		GameLib.SetCurrentClassInnateAbilityIndex(wndHandler:GetData())
	elseif sType == "mount" then
		self.wndMountBtn:FindChild("Popup"):Show(false, true)
		self.tSettings.nSelectedMount = wndControl:GetData():GetId()
		GameLib.SetShortcutMount(self.tSettings.nSelectedMount)
	elseif sType == "potion" then
		self.wndPotionBtn:FindChild("Popup"):Show(false, true)
		self.tSettings.nSelectedPotion = wndControl:GetData():GetItemId()
		GameLib.SetShortcutPotion(wndControl:GetData():GetItemId())
	elseif sType == "path" then
		local tActionSet = ActionSetLib.GetCurrentActionSet()

		self.tSettings.nSelectedPath = wndControl:GetData()

		Event_FireGenericEvent("PathAbilityUpdated", self.tSettings.nSelectedPath)
		tActionSet[10] = self.tSettings.nSelectedPath
		ActionSetLib.RequestActionSetChanges(tActionSet)

		self.wndPathBtn:FindChild("Popup"):Show(false, true)
	end
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_BarButton Functions
---------------------------------------------------------------------------------------------------
function ForgeUI_ActionBars:BarButton_OnMouseDown( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if wndControl:GetName() == "ForgeUI_BarButton" and eMouseButton == 1 then
		wndControl:FindChild("Popup"):Show(true, true)

		self:FillMounts(self.wndMountBtn)
		self:FillStances(self.wndStanceBtn)
		self:FillPath(self.wndPathBtn)
		self:FillPotions(self.wndPotionBtn)
		self:FillRecalls(self.wndRecallBtn)
	end
end

function ForgeUI_ActionBars:RecallBtn_OnButtonDown( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	local wnd = wndControl:GetParent():GetParent():GetParent()
	if wndControl:GetName() == "GCBar" and eMouseButton == 1 then
		GameLib.SetDefaultRecallCommand(wndControl:GetData())
		wnd:FindChild("GCBar"):SetContentId(wndControl:GetData())
	end
	wnd:FindChild("Popup"):Show(false, true)
end

-----------------------------------------------------------------------------------------------
-- Helpers
-----------------------------------------------------------------------------------------------
function ForgeUI_ActionBars:Helper_BarOffsets(tBar)
	local nLeft, nTop, nRight, nBottom = unpack(tSnapToOffsets[tBar.strSnapTo])
	if tBar.strSnapTo == "bottom" then
		local nWidth = tBar.nButtons * tBar.nButtonSize - tBar.nButtons + tBar.nButtons * tBar.nButtonPadding

		nLeft = nWidth / -2
		nRight = nWidth / 2

		nTop = nTop - tBar.nButtonSize
	elseif tBar.strSnapTo == "top" then
		local nWidth = tBar.nButtons * tBar.nButtonSize - tBar.nButtons + tBar.nButtons * tBar.nButtonPadding

		nLeft = nWidth / -2
		nRight = nWidth / 2

		nBottom = nBottom + tBar.nButtonSize
	elseif tBar.strSnapTo == "right" then
		local nHeight = tBar.nButtons * tBar.nButtonSize - tBar.nButtons + tBar.nButtons * tBar.nButtonPadding

		nTop = nHeight / -2
		nBottom = nHeight / 2

		nLeft = nLeft - tBar.nButtonSize
	elseif tBar.strSnapTo == "left" then
		local nHeight = tBar.nButtons * tBar.nButtonSize - tBar.nButtons + tBar.nButtons * tBar.nButtonPadding

		nTop = nHeight / -2
		nBottom = nHeight / 2

		nRight = nRight + tBar.nButtonSize
	end

	return nLeft, nTop, nRight, nBottom
end

function ForgeUI_ActionBars:ForgeAPI_PopulateOptions()
	for k, v in pairs(self._DB.profile.tFrames) do
		local wnd = self.tOptionHolders[v.strKey]

		G:API_AddCheckBox(self, wnd, "Show shourtcuts", v, "bDrawShortcutBottom", { tMove = {0, 0},
			fnCallback = function(...) self:EditButtons(v) end })
	end
end

-----------------------------------------------------------------------------------------------
-- ForgeUI addon registration
-----------------------------------------------------------------------------------------------
F:API_NewAddon(ForgeUI_ActionBars)
