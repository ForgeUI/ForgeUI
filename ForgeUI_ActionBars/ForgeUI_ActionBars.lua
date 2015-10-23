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
                nSelectedMount = 0,
                nSelectedPotion = 0,
                nSelectedPath = 0,
                bShowHotkeys = true,
                tSideBar1 = {
                        bShow = true,
                        bVertical = true,
                        nButtons = 12,
                },
                tSideBar2 = {
                        bShow = false,
                        bVertical = true,
                        nButtons = 12,
                }
        }
       
        self.wndActionBars = {}
        self.tActionBars = {
                tActionBar = {
                        strName = "ActionBar",
                        strDisplayName = "Action bar",
                        strContent = "LASBar",
                        nContentMin = 0,
                        nContentMax = 7,
                        bShowHotkey = false,
                        bShowPopup = false,
                        crBorder = "FF000000",
                        strStyler = "LoadStyle_ActionBar",
                },
                tVehicleBar = {
                        strName = "VehicleBar",
                        strDisplayName = "Vehicle bar",
                        strContent = "RMSBar",
                        nContentMin = 0,
                        nContentMax = 5,
                        bShowHotkey = false,
                        bShowPopup = false,
                        crBorder = "FF000000",
                        strStyler = "LoadStyle_ActionBar",
                },
                tSpellBar = {
                        strName = "SpellBar",
                        strDisplayName = "Spell bar",
                        strContent = "SBar",
                        nContentMin = 84,
                        nContentMax = 91,
                        bShowHotkey = false,
                        bShowPopup = false,
                        crBorder = "FF000000",
                        strStyler = "LoadStyle_ActionBar",
                },
                tSideBar1 = {
                        strName = "SideBar1",
                        strDisplayName = "Side bar 1",
                        strContent = "ABar",
                        nContentMin = 12,
                        nContentMax = 23,
                        bShowHotkey = false,
                        bShowPopup = false,
                        crBorder = "FF000000",
                        strStyler = "LoadStyle_ActionBar",
                },
                tSideBar2 = {
                        strName = "SideBar2",
                        strDisplayName = "Side bar 2",
                        strContent = "ABar",
                        nContentMin = 24,
                        nContentMax = 35,
                        bShowHotkey = false,
                        bShowPopup = false,
                        bVertical = true,
                        crBorder = "FF000000",
                        strStyler = "LoadStyle_ActionBar",
                },
                tStanceButton = {
                        strName = "StanceButton",
                        strDisplayName = "Stance",
                        strContent = "GCBar",
                        nContent = 2,
                        bShowHotkey = false,
                        bShowPopup = true,
                        crBorder = "FF000000",
                        strStyler = "LoadStyle_ActionButton",
                },
                tMountButton = {
                        strName = "MountButton",
                        strDisplayName = "Mount",
                        strContent = "GCBar",
                        nContent = 26,
                        bShowHotkey = false,
                        bShowPopup = true,
                        crBorder = "FF000000",
                        strStyler = "LoadStyle_ActionButton",
                },
                tRecallButton = {
                        strName = "RecallButton",
                        strDisplayName = "Recall",
                        strContent = "GCBar",
                        nContent = 18,
                        bShowHotkey = false,
                        bShowPopup = true,
                        crBorder = "FF000000",
                        strStyler = "LoadStyle_ActionButton",
                },
                tGadgetButton = {
                        strName = "GadgetButton",
                        strDisplayName = "Gadget",
                        strContent = "GCBar",
                        nContent = 0,
                        bShowHotkey = false,
                        bShowPopup = false,
                        crBorder = "FF000000",
                        strStyler = "LoadStyle_ActionButton",
                },
                tPotionButton = {
                        strName = "PotionButton",
                        strDisplayName = "Potion",
                        strContent = "GCBar",
                        nContent = 27,
                        bShowHotkey = false,
                        bShowPopup = true,
                        crBorder = "FF000000",
                        strStyler = "LoadStyle_ActionButton",
                },
                tPathButton = {
                        strName = "PathButton",
                        strDisplayName = "Path",
                        strContent = "LASBar",
                        nContent = 9,
                        bShowHotkey = false,
                        bShowPopup = true,
                        crBorder = "FF000000",
                        strStyler = "LoadStyle_ActionButton",
                },
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
 
function ForgeUI_ActionBars:CreateBar(tOptions)
        local wnd = self.wndActionBars[tOptions.strName]
        if wnd == nil then
                wnd = Apollo.LoadForm(self.xmlDoc, "ForgeUI_" .. tOptions.strName, ForgeUI.HudStratum3, self)
                self.wndActionBars[tOptions.strName] = wnd
        end
       
        wnd:FindChild("Holder"):DestroyChildren()
       
        local tSettings = self.tSettings["t" .. tOptions.strName]
        if tSettings ~= nil then
                if not tSettings.bShow then return end
        end
       
        ForgeUI.API_RegisterWindow(self, wnd, tOptions.strName, { bMaintainRatio = true, strDisplayName = tOptions.strDisplayName })
        ForgeUI.API_RegisterWindow(self, wnd:FindChild("Holder"), tOptions.strName .. "_holder", { strParent = tOptions.strName, bInvisible = true, bMaintainRatio = true })
 
        if tSettings ~= nil and tSettings.bVertical then
                if wnd:GetWidth() > wnd:GetHeight() then
                        local nLeft, nTop, nRight, nBottom = wnd:GetAnchorOffsets()
                        wnd:SetAnchorOffsets(nLeft, nTop, nLeft + wnd:GetHeight(), nTop + wnd:GetWidth())
                end
        elseif tSettings ~= nil and not tSettings.bVertical then
                if wnd:GetHeight() > wnd:GetWidth() then
                        local nLeft, nTop, nRight, nBottom = wnd:GetAnchorOffsets()
                        wnd:SetAnchorOffsets(nLeft, nTop, nLeft + wnd:GetHeight(), nTop + wnd:GetWidth())
                end
        end
 
        local nButtons = tOptions.nContentMax - tOptions.nContentMin + 1
        local i = 0
        for id = tOptions.nContentMin, tOptions.nContentMax do
                if tSettings ~= nil and i >= tSettings.nButtons then
                else
                        local wndBarButton = Apollo.LoadForm(self.xmlDoc, "ForgeUI_BarButton", wnd:FindChild("Holder"), self)
                        wndBarButton:SetData(tOptions)
                       
                        if tOptions.bShowPopup then
                                wndBarButton:AddEventHandler("MouseButtonDown", "BarButton_OnMouseDown", self)
                        end
                       
                        local wndButton = Apollo.LoadForm(self.xmlDoc, tOptions.strContent, wndBarButton:FindChild("Holder"), self)
                        wndButton:SetContentId(id)
                       
                        if tSettings ~= nil and tSettings.bVertical then
                                wndBarButton:SetAnchorPoints(0, (1 / nButtons) * i, 1, (1 / nButtons) * (i + 1))
                                wndBarButton:SetAnchorOffsets(0, 0, 0, 1)
                        else
                                wndBarButton:SetAnchorPoints((1 / nButtons) * i, 0, (1 / nButtons) * (i + 1), 1)
                                wndBarButton:SetAnchorOffsets(0, 0, 1, 0)
                        end
                       
                        ForgeUI.API_RegisterWindow(self, wndBarButton, tOptions.strName .. "_" .. i, { strParent = tOptions.strName .. "_holder", crBorder = "FFFFFFFF", bMaintainRatio = true, strDisplayName = i })
                end
               
                i = i + 1
        end
       
        self.tStylers[tOptions.strStyler][tOptions.strStyler](self, wnd, tOptions)
       
        return wnd
end
 
function ForgeUI_ActionBars:CreateButton(tOptions)
        local wnd = self.wndActionBars[tOptions.strName]
        if wnd == nil then
                wnd = Apollo.LoadForm(self.xmlDoc, "ForgeUI_" .. tOptions.strName, ForgeUI.HudStratum3, self)
                self.wndActionBars[tOptions.strName] = wnd
        end
       
        wnd:DestroyChildren()
       
        ForgeUI.API_RegisterWindow(self, wnd, tOptions.strName, { bMaintainRatio = true, strDisplayName = tOptions.strDisplayName })
       
        local wndBarButton = Apollo.LoadForm(self.xmlDoc, "ForgeUI_BarButton", wnd, self)
        wndBarButton:SetData(tOptions)
       
        if tOptions.bShowPopup then
                wndBarButton:AddEventHandler("MouseButtonDown", "BarButton_OnMouseDown", self)
        end
       
        local wndButton = Apollo.LoadForm(self.xmlDoc, tOptions.strContent, wndBarButton:FindChild("Holder"), self)
        wndButton:SetContentId(tOptions.nContent)
       
        self.tStylers[tOptions.strStyler][tOptions.strStyler](self, wnd, tOptions)
       
        return wnd
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
 
        local tMountList = CollectiblesLib.GetMountList()
        local tSelectedSpellObj = nil
 
        local nCount = 0
        for idx, tMount in pairs(tMountList) do
                if tMount.bIsKnown then
                        if nCount < 10 then nCount = nCount + 1 end
                       
                        local tSpellObject = tMount.splObject
       
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
       
        GameLib.SetShortcutPotion(self.tSettings.nSelectedPotion)
 
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
       
       
--      if self.tSettings.nSelectedPath > 0 and ActionSetLib.IsSpellCompatibleWithActionSet(self.tSettings.nSelectedPath, tActionSet) ~= 3 then
    if self.tSettings.nSelectedPath > 0 then
                Event_FireGenericEvent("PathAbilityUpdated", self.tSettings.nSelectedPath)
                tActionSet[10] = self.tSettings.nSelectedPath
        else
                tActionSet[10] = tActionSet[10]
                self.tSettings.nSelectedPath = tActionSet[10]
        end
       
        ActionSetLib.RequestActionSetChanges(tActionSet)
       
        local nLeft, nTop, nRight, nBottom = wndPopup:GetAnchorOffsets()
        wndPopup:SetAnchorOffsets(nLeft, -(nCount * nSize), nRight, nBottom)
       
        wndList:ArrangeChildrenVert(0)
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
        local wndBtn = ForgeUI.API_AddItemButton(self, "Action bars")
        ForgeUI.API_AddListItemToButton(self, wndBtn, "General", { strContainer = "ForgeUI_General", bDefault = true })
        ForgeUI.API_AddListItemToButton(self, wndBtn, "Side bar 1", { strContainer = "ForgeUI_Secondary1" })
        ForgeUI.API_AddListItemToButton(self, wndBtn, "Side bar 2", { strContainer = "ForgeUI_Secondary2" })
 
        Apollo.RegisterEventHandler("ShowActionBarShortcut",    "ShowShortcutBar", self)
end
 
function ForgeUI_ActionBars:ForgeAPI_AfterRestore()
        -- settings
       
        ForgeUI.API_RegisterCheckBox(self, self.wndContainers["ForgeUI_General"]:FindChild("bShowHotkeys"), self.tSettings, "bShowHotkeys", "CreateBars")
       
        ForgeUI.API_RegisterCheckBox(self, self.wndContainers["ForgeUI_Secondary1"]:FindChild("bShow"), self.tSettings.tSideBar1, "bShow", "CreateBars")
       
        ForgeUI.API_RegisterCheckBox(self, self.wndContainers["ForgeUI_Secondary2"]:FindChild("bShow"), self.tSettings.tSideBar2, "bShow", "CreateBars")
       
        if GameLib.GetPlayerUnit() then
                self:OnCharacterCreated()
        else
                Apollo.RegisterEventHandler("CharacterCreated",         "OnCharacterCreated", self)
        end
end
 
function ForgeUI_ActionBars:OnCharacterCreated()
        self.timer = ApolloTimer.Create(1.0, true, "OnTimer", self)
end
 
function ForgeUI_ActionBars:OnTimer()
        self:CreateBars()
       
        GameLib.SetDefaultRecallCommand(GameLib.GetDefaultRecallCommand())
        self.wndRecallBtn:FindChild("GCBar"):SetContentId(GameLib.GetDefaultRecallCommand())
       
        self.timer:Stop()
end
 
function ForgeUI_ActionBars:CreateBars()
        self.wndActionBar = self:CreateBar(self.tActionBars.tActionBar)
        if self.wndVehicleBar then
                self.wndActionBar:Show(not self.wndVehicleBar:IsShown(), true)
        end
 
        self.wndSideBar1 = self:CreateBar(self.tActionBars.tSideBar1)
        self.wndSideBar2 = self:CreateBar(self.tActionBars.tSideBar2)
       
        self.wndGadgetBtn = self:CreateButton(self.tActionBars.tGadgetButton)
       
        self.wndPotionBtn = self:CreateButton(self.tActionBars.tPotionButton)
        self:FillPotions(self.wndPotionBtn)
       
        self.wndPathBtn = self:CreateButton(self.tActionBars.tPathButton)
        self:FillPath(self.wndPathBtn)
       
        self.wndStanceBtn = self:CreateButton(self.tActionBars.tStanceButton)
        self:FillStances(self.wndStanceBtn)
       
        self.wndMountBtn = self:CreateButton(self.tActionBars.tMountButton)
        self:FillMounts(self.wndMountBtn)
       
        self.wndRecallBtn = self:CreateButton(self.tActionBars.tRecallButton)
        self:FillRecalls(self.wndRecallBtn)
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
        for strName, wndBarButton in pairs(wnd:FindChild("Holder"):GetChildren()) do
                wndBarButton:SetBGColor(tOptions.crBorder)
                wndBarButton:FindChild(tOptions.strContent):SetStyleEx("DrawHotkey", self.tSettings.bShowHotkeys)
                wndBarButton:FindChild(tOptions.strContent):SetStyle("NoClip", tOptions.bShowHotkey)
               
                wndBarButton:FindChild("Popup"):SetBGColor(tOptions.crBorder)
        end
end
 
function ForgeUI_ActionBars:LoadStyle_ActionButton(wnd, tOptions)
        local wndBarButton = wnd:FindChild("ForgeUI_BarButton")
 
        wndBarButton:SetBGColor(tOptions.crBorder)
        wndBarButton:FindChild(tOptions.strContent):SetStyleEx("DrawHotkey", self.tSettings.bShowHotkeys)
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
 
 
----------------------------------------------------------------------------------------------
-- ForgeUI_ActionBars Instance
-----------------------------------------------------------------------------------------------
local ForgeUI_ActionBarsInst = ForgeUI_ActionBars:new()
ForgeUI_ActionBarsInst:Init()
