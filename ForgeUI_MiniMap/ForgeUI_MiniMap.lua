require "Window"
 
local ForgeUI
local ForgeUI_MiniMap = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local tMining = { "IronNode", "TitaniumNode", "ZephyriteNode", "PlatinumNode", "HydrogemNode", "XenociteNode", "ShadeslateNode", "GalactiumNode", "NovaciteNode" }
local tRelic = { "StandardRelicNode", "AcceleratedRelicNode", "AdvancedRelicNode", "DynamicRelicNode", "KineticRelicNode" }
local tHarvest = { "SpirovineNode", "BladeleafNode", "YellowbellNode", "PummelgranateNode", "SerpentlilyNode", "GoldleafNode", "HoneywheatNode", "CrowncornNode", "CoralscaleNode", "LogicleafNode", "StoutrootNode", "GlowmelonNode", "FaerybloomNode", "WitherwoodNode", "FlamefrondNode", "GrimgourdNode", "MourningstarNode", "BloodbriarNode", "OctopodNode", "HeartichokeNode", "SmlGrowthshroomNode", "MedGrowthshroomNode", "LrgGrowthshroomNode", "SmlHarvestshroomNode", "MedHarvestshroomNode", "LrgHarvestshroomNode", "SmlRenewshroomNode", "MedRenewshroomNode", "LrgRenewshroomNode" }
local tSurvivalist = { "AlgorocTreeNode", "CelestionTreeNode", "DeraduneTreeNode", "EllevarTreeNode", "GalerasTreeNode", "AuroriaTreeNode", "WhitevaleTreeNode", "DreadmoorTreeNode", "FarsideTreeNode", "CoralusTreeNode", "MurkmireTreeNode", "WilderrunTreeNode", "MalgraveTreeNode", "HalonRingTreeNode", "GrimvaultTreeNode", "CrimsonIsleTreeNode" }
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function ForgeUI_MiniMap:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

	self.tUnits = {}
	self.tUnitsInQueue = {}
	self.nGroupMemberCount = 0

	Apollo.RegisterEventHandler("UnitCreated", 		"OnUnitCreated", self)
	Apollo.RegisterEventHandler("UnitDestroyed", 	"OnUnitDestroyed", self)

    -- mandatory 
    self.api_version = 2
	self.version = "0.1.0"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_MiniMap"
	self.strDisplayName = "MiniMap"
	
	self.wndContainers = {}
	
	self.tStylers = {
		["LoadStyle_Minimap"] = self,
	}
	
	-- optional
	self.settings_version = 1
	self.tSettings = {
		nZoomLevel = 1,
		bShowNsew = false,
		tMarkers = {
			FriendlyPlayer = 	{ strName = "Friendly player", bShow = true, crObject = "FFFFFFFF" , strIcon = "ClientSprites:MiniMapFriendDiamond", objectType = "eObjectTypeFriendlyPlayer"},
			PartyPlayer = 		{ strName = "Party player", bShow = true, crObject = "FF006CFF" , strIcon = "ClientSprites:MiniMapFriendDiamond", objectType = "eObjectTypeFriendlyPlayer"},
			HostilePlayer = 	{ strName = "Hostile player", bShow = true, crObject = "FFFF0000" , strIcon = "ClientSprites:MiniMapFriendDiamond", objectType = "eObjectTypeHostilePlayer" },
			Hostile = 			{ strName = "Hostile NPC", bShow = true, crObject = "FFFF0000" , objectType = "eObjectTypeNPC" },
			Neutral = 			{ strName = "Neutral NPC", bShow = true, crObject = "FFFFCC00" , objectType = "eObjectTypeNPC" },
			InstancePortal = 	{ strName = "Instance portal", bShow = false, crObject = "FFFFFFFF", strIcon = "IconSprites:Icon_MapNode_Map_Portal", objectType = "eObjectTypeNPC" },
			Vendor = 			{ strName = "Vendor", bShow = false, crObject = "FFFFFFFF", strIcon = "IconSprites:Icon_MapNode_Map_Vendor", objectType = "eObjectTypeVendor" },
			Dye	= 				{ strName = "Dye", bShow = false, crObject = "FFFFFFFF", strIcon = "IconSprites:Icon_MapNode_Map_DyeSpecialist", objectType = "eObjectTypeVendor" },
			Mail = 				{ strName = "Mail", bShow = false, crObject = "FFFFFFFF", strIcon = "IconSprites:Icon_MapNode_Map_Mailbox", objectType = "eObjectTypeOthers" },
			FlightPath = 		{ strName = "Flight path", bShow = true, crObject = "FFFFFFFF", strIcon = "IconSprites:Icon_MapNode_Map_Taxi", objectType = "eObjectTypeOthers" },
			Mining = 			{ strName = "Mining", bShow = false, crObject = "FFFFFFFF", strIcon = "IconSprites:Icon_MapNode_Map_Node_Mining", objectType = "eObjectTypeHarvest" },
			Relic = 			{ strName = "Relic hunting", bShow = false, crObject = "FFFFFFFF", strIcon = "IconSprites:Icon_MapNode_Map_Node_Relic", objectType = "eObjectTypeHarvest" },
			Harvest = 			{ strName = "Harvesting", bShow = false, crObject = "FFFFFFFF", strIcon = "IconSprites:Icon_MapNode_Map_Node_Plant", objectType = "eObjectTypeHarvest" },
			Survivalist = 		{ strName = "Survivalist", bShow = false, crObject = "FFFFFFFF", strIcon = "IconSprites:Icon_MapNode_Map_Node_Tree", objectType = "eObjectTypeHarvest" },
			QuestNewDaily = 	{ strName = "Daily quest", bShow = true, crObject = "FFFFFFFF", strIcon = "IconSprites:Icon_MapNode_Map_Quest", objectType = "eObjectTypeQuest" },
			QuestNew = 			{ strName = "Quest", bShow = true, crObject = "FFFFFFFF", strIcon = "IconSprites:Icon_MapNode_Map_Quest", objectType = "eObjectTypeQuest" }
		}
	}
	
	return o
end

function ForgeUI_MiniMap:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"ForgeUI"
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- ForgeUI_MiniMap OnLoad
-----------------------------------------------------------------------------------------------
function ForgeUI_MiniMap:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("ForgeUI_MiniMap.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_MiniMap OnDocLoaded
-----------------------------------------------------------------------------------------------
function ForgeUI_MiniMap:OnDocLoaded()
	if self.xmlDoc == nil or not self.xmlDoc:IsLoaded() then return end
	
	if ForgeUI == nil then -- forgeui loaded
		ForgeUI = Apollo.GetAddon("ForgeUI")
	end
	
	ForgeUI.API_RegisterAddon(self)
end

function ForgeUI_MiniMap:ForgeAPI_AfterRegistration()
	Apollo.RegisterEventHandler("ZoneMapPing", 					"OnMapPing", self)
	Apollo.RegisterEventHandler("UnitActivationTypeChanged", 	"OnUnitChanged", self)
	Apollo.RegisterEventHandler("UnitMiniMapMarkerChanged", 	"OnUnitChanged", self)
	
	Apollo.RegisterTimerHandler("PingTimer", "OnPingTimer", self)
	Apollo.CreateTimer("PingTimer", 1, false)
	Apollo.StopTimer("PingTimer")
	
	Apollo.LoadSprites("SquareMapTextures_NoCompass.xml")
	
	self.tPingObjects = {}
	
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "ForgeUI_MiniMap", "FixedHudStratumLow", self)
	self.wndMiniMap = self.wndMain:FindChild("MiniMapWindow")
	
	ForgeUI.API_RegisterWindow(self, self.wndMain, "ForgeUI_Minimap", { strDisplayName = "Minimap"})
	
	self:CreateOverlayObjectTypes()
	
	-- main window
	ForgeUI.API_AddItemButton(self, "Minimap", { strContainer = "ForgeUI_Container" })
	
	-- build minimap window
	local l_time = GameLib.GetLocalTime()
	self.wndMain:FindChild("Clock"):SetText(string.format("%02d:%02d", l_time.nHour, l_time.nMinute))
	self:UpdateZoneName()
	
	self:HandleNewUnits()
	Apollo.RegisterTimerHandler("TimeUpdateTimer", 	"OnUpdateTimer", self)
end

function ForgeUI_MiniMap:OnUpdateTimer()
	self:HandleNewUnits()

	self:UpdateZoneName()

	local l_time = GameLib.GetLocalTime()
	self.wndMain:FindChild("Clock"):SetText(string.format("%02d:%02d", l_time.nHour, l_time.nMinute))
	
	if self.nGroupMemberCount ~= GroupLib.GetMemberCount() then
		self.nGroupMemberCount = GroupLib.GetMemberCount()
		self:UpdateAllUnits()
	end
end

function ForgeUI_MiniMap:OnUnitCreated(unit)
	if unit == nil or not unit:IsValid() or unit == GameLib.GetPlayerUnit() then return end

	self.tUnitsInQueue[unit:GetId()] = unit
	self.tUnits[unit:GetId()] = unit
end

function ForgeUI_MiniMap:OnUnitDestroyed(unit)
	if unit == nil or not unit:IsValid() then return end
	
	self.tUnits[unit:GetId()] = nil
end

function ForgeUI_MiniMap:OnUnitChanged(unit, eType)
	if unit == nil then
		return
	end
	
	self.wndMiniMap:RemoveUnit(unit)
	self.tUnitsInQueue[unit:GetId()] = unit
end

function ForgeUI_MiniMap:UpdateAllUnits()
	self.wndMiniMap:RemoveAllObjects()
	
	for _, unit in pairs(self.tUnits) do
		self:OnUnitCreated(unit)
	end
	
	self:HandleNewUnits()
end

function ForgeUI_MiniMap:HandleNewUnits()
	for idx, unit in pairs(self.tUnitsInQueue) do
		self.tUnitsInQueue[idx] = nil
		if unit == nil or not unit:IsValid() then return end
	
		local tTypes = {}
		
		-- players
		if unit:GetType() == "Player" then
			local eDispotition = unit:GetDispositionTo(GameLib.GetPlayerUnit())
			if eDispotition == Unit.CodeEnumDisposition.Hostile then
				tTypes = { "HostilePlayer" }
			elseif eDispotition == Unit.CodeEnumDisposition.Friendly and not unit:IsThePlayer() then
				if unit:IsInYourGroup() then
					tTypes = { "PartyPlayer" }
				else
					tTypes = { "FriendlyPlayer" }
				end
			end
		else
			tTypes = unit:GetMiniMapMarkers()
		end
		
		-- ahrvest
		if unit:GetType() == "Harvest" then
			tTypes = unit:GetMiniMapMarkers()
			for idx, type in pairs(tTypes) do
				for k, v in pairs(tMining) do
					if v == type then tTypes[k] = "Mining" end
				end
				for k, v in pairs(tRelic) do
					if v == type then tTypes[k] = "Relic" end
				end
				for k, v in pairs(tHarvest) do
					if v == type then tTypes[k] = "Harvest" end
				end
				for k, v in pairs(tSurvivalist) do
					if v == type then tTypes[k] = "Survivalist" end
				end
			end
		end
		
		for idx, type in pairs(tTypes) do
			if self.tSettings.tMarkers[type] and self.tSettings.tMarkers[type].bShow == true then
				local tInfo = self:GetDefaultMarker(unit)
			
				tMarker = self.tSettings.tMarkers[type]
				if tMarker.strIcon then
					tInfo.strIcon = tMarker.strIcon 
				end
				if tMarker.strIconEdge then
					tInfo.strIconEdge = tMarker.strIconEdge 
				end
				if tMarker.crObject then
					tInfo.crObject = tMarker.crObject
				end
				if tMarker.crEdge then
					tInfo.crEdge = tMarker.crEdge 
				end
				
				local objectType = GameLib.CodeEnumMapOverlayType.Unit
				if tMarker.objectType then
					objectType = self[tMarker.objectType]
				end
				
				self.wndMiniMap:AddUnit(unit, objectType, tInfo, {}, false)
			end
		end
	end
end

function ForgeUI_MiniMap:GetDefaultMarker(unit)
	local tInfo = {
		strIcon = "ClientSprites:MiniMapMarkerTiny",
		strIconEdge = "",
		crObject = "FFFFFFFF",
		crEdge = "FFFFFFFF",
		bAboveOverlay = false
	}
	
	return tInfo
end

function ForgeUI_MiniMap:UpdateZoneName()
	local strZoneName = GetCurrentZoneName()
	
	local tInstanceSettingsInfo = GameLib.GetInstanceSettings()

	local strDifficulty = nil
	if tInstanceSettingsInfo.eWorldDifficulty == GroupLib.Difficulty.Veteran then
		strDifficulty = "Veteran"
	end

	local strScaled = nil
	if tInstanceSettingsInfo.bWorldForcesLevelScaling == true then
		strScaled = "Scalled"
	end

	local strAdjustedZoneName = strZoneName
	if strDifficulty and strScaled then
		strAdjustedZoneName = strZoneName .. " (" .. strDifficulty .. "-" .. strScaled .. ")"
	elseif strDifficulty then
		strAdjustedZoneName = strZoneName .. " (" .. strDifficulty .. ")"
	elseif strScaled then
		strAdjustedZoneName = strZoneName .. " (" .. strScaled .. ")"
	end

	self.wndMain:FindChild("ZoneName"):SetText(strAdjustedZoneName or "Unknown")
end

-- map pings
function ForgeUI_MiniMap:OnMapPing( idUnit, tPos )
	for idx, tCur in pairs(self.tPingObjects) do
		if tCur.idUnit == idUnit then
			self.wndMiniMap:RemoveObject(tCur.objMapPing)
			self.tPingObjects[idx] = nil
		end
	end

	local tInfo =
	{
		strIcon = "sprMap_PlayerPulseFast",
		crObject = CColor.new(1, 1, 1, 1),
		strIconEdge = "",
		crEdge = CColor.new(1, 1, 1, 1),
		bAboveOverlay = true,
	}
	
	table.insert(self.tPingObjects, {["idUnit"] = idUnit, ["objMapPing"] = self.wndMiniMap:AddObject(self.eObjectTypePing, tPos, "", tInfo), ["nTime"] = GameLib.GetGameTime()})
	
	Apollo.StartTimer("PingTimer")
end

function ForgeUI_MiniMap:OnPingTimer()
	local nCurTime = GameLib.GetGameTime()
	local nNumUnits = 0
	for idx, tCur in pairs(self.tPingObjects) do
		if (tCur.nTime + 4) < nCurTime then
			self.wndMiniMap:RemoveObject(tCur.objMapPing)
			self.tPingObjects[idx] = nil
		else
			nNumUnits = nNumUnits + 1
		end
	end
		
	if nNumUnits == 0 then
		Apollo.StopTimer("PingTimer")
	else
		Apollo.StartTimer("PingTimer")
	end

end

-- map overlays
function ForgeUI_MiniMap:CreateOverlayObjectTypes()
	self.eObjectTypeOthers				= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeVendor				= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeHarvest				= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeNPC					= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeFriendlyPlayer		= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeHostilePlayer		= self.wndMiniMap:CreateOverlayType()
	self.eObjectTypeQuest				= self.wndMiniMap:CreateOverlayType()
end

-- generate tooltip
function ForgeUI_MiniMap:OnGenerateTooltip(wndHandler, wndControl, eType, nX, nY)
	if eType ~= Tooltip.TooltipGenerateType_Map then
		wndControl:SetTooltipDoc(nil)
		return
	end
	
	local xml = XmlDoc.new()
	xml:StartTooltip(Tooltip.TooltipWidth)
	
	local nCount = 0
	local tMapObjects = self.wndMiniMap:GetObjectsAtPoint(nX, nY)
	for ids, mapObject in pairs(tMapObjects) do
		if mapObject.unit ~= nil then
			nCount = nCount + 1
			xml:AddLine(mapObject.unit:GetName(), crWhite, "CRB_InterfaceMedium")
		end
	end
	
	if nCount > 0 then
		wndControl:SetTooltipDoc(xml)
	else
		wndControl:SetTooltipDoc(nil)
	end
end

-- restore / save
function ForgeUI_MiniMap:ForgeAPI_AfterRestore()
	self.wndMiniMap:SetZoomLevel(self.tSettings.nZoomLevel)
	self.wndMain:FindChild("NSEW"):Show(self.tSettings.bShowNsew, true)
	
	ForgeUI.API_RegisterCheckBox(self, self.wndContainers.ForgeUI_Container:FindChild("bShowNsew"), self.tSettings, "bShowNsew", "LoadStyle_Minimap")
	
	local wndHolder = self.wndContainers.ForgeUI_Container:FindChild("Holder")
	for strName,  tMarker in pairs(self.tSettings.tMarkers) do
		local wndMarker = Apollo.LoadForm(self.xmlDoc, "ForgeUI_OptionContainer", wndHolder, ForgeUI.ForgeUIInst)
		
		wndMarker:FindChild("strName"):SetText(tMarker.strName)
		ForgeUI.API_RegisterCheckBox(self, wndMarker:FindChild("bShow"), self.tSettings.tMarkers[strName], "bShow", "UpdateAllUnits")
		ForgeUI.API_RegisterColorBox(self, wndMarker:FindChild("crObject"), self.tSettings.tMarkers[strName], "crObject", false, "UpdateAllUnits")
		
		wndMarker:SetData(strName)
	end
	wndHolder:ArrangeChildrenVert()
	
	self.tStylers["LoadStyle_Minimap"]["LoadStyle_Minimap"](self)
	self:UpdateAllUnits()
end

function ForgeUI_MiniMap:ForgeAPI_BeforeSave()
	self.tSettings.nZoomLevel = self.wndMiniMap:GetZoomLevel()
end
function ForgeUI_MiniMap:LoadStyle_Minimap()
	self.wndMain:FindChild("NSEW"):Show(self.tSettings.bShowNsew, true)
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_MiniMap Instance
-----------------------------------------------------------------------------------------------
local ForgeUI_MiniMapInst = ForgeUI_MiniMap:new()
ForgeUI_MiniMapInst:Init()
