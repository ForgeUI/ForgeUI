require "Window"
 
local ForgeUI
local ForgeOptions
local ForgeUI_ToolTips = {}

local ToolTips
local ToolTips_OnDocumentReady = nil

local ktClassToIcon = {
	[GameLib.CodeEnumClass.Medic]       	= "ForgeUI_Medic",
	[GameLib.CodeEnumClass.Esper]       	= "ForgeUI_Esper",
	[GameLib.CodeEnumClass.Warrior]     	= "ForgeUI_Warrior",
	[GameLib.CodeEnumClass.Stalker]     	= "ForgeUI_Stalker",
	[GameLib.CodeEnumClass.Engineer]    	= "ForgeUI_Engineer",
	[GameLib.CodeEnumClass.Spellslinger]  	= "ForgeUI_Spellslinger",
}

function ForgeUI_ToolTips:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- mandatory 
    self.api_version = 2
	self.version = "1.0.0"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_ToolTips"
	self.strDisplayName = "ToolTips"
	
	self.wndContainers = {}
	
	self.tStylers = {}
	
	-- optional
	self.settings_version = 1
    self.tSettings = {
		strTooltipPosition = "TPT_NavText", -- TPT_OnCursor
		bShowInCombat = false,
	}


    return o
end

local ForgeUI_ToolTipsInst

function ForgeUI_ToolTips:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"ForgeUI", "ToolTips"
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end

function ForgeUI_ToolTips:OnLoad()
    if ForgeUI == nil then -- forgeui loaded
		ForgeUI = Apollo.GetAddon("ForgeUI")
	end
	
	ForgeUI.API_RegisterAddon(self)
end

local GenerateUnitTooltipForm
local GenerateBuffTooltipForm
local GenerateSpellTooltipForm
local GenerateItemTooltipForm

local origGenerateUnitTooltipForm
local origGenerateBuffTooltipForm
local origGenerateSpellTooltipForm
local origGenerateItemTooltipForm

function ForgeUI_ToolTips:ForgeAPI_AfterRegistration()
	ToolTips = Apollo.GetAddon("ToolTips")
	ForgeOptions = Apollo.GetPackage("ForgeOptions").tPackage

	ToolTips_OnDocumentReady = ToolTips.OnDocumentReady
	ToolTips.OnDocumentReady = ForgeUI_ToolTips.TooltipsHook_OnDocumentReady
	
	-- hooks
	ToolTips.UnitTooltipGen = self.UnitTooltipGen
end

function ForgeUI_ToolTips:ForgeAPI_AfterRestore()
	ForgeOptions:API_AddAdvancedOption(self, "ToolTips", "Show tooltips in combat", "boolean", self.tSettings, "bShowInCombat", "OnOptionChanged", {})
	ForgeOptions:API_AddAdvancedOption(self, "ToolTips", "Unit's tooltip position", "dropdown", self.tSettings, "strTooltipPosition", "Testicek", {
		tDropdown = {
			["TPT_OnCursor"] = "Cursor",
			["TPT_NavText"] = "Fixed",
		}
	})
end

function ForgeUI_ToolTips.Testicek()
	Print("A")

	local wndContainer = GameLib.GetWorldTooltipContainer()
	wndContainer:SetTooltipType(Window[ForgeUI_ToolTipsInst.tSettings.strTooltipPosition])
end

function ForgeUI_ToolTips.TooltipsHook_OnDocumentReady(tooltips)
	ToolTips_OnDocumentReady(tooltips)
	local ToolTipsInst = tooltips
	
	origGenerateUnitTooltipForm = ToolTips.UnitTooltipGen
	ToolTips.UnitTooltipGen = GenerateUnitTooltipForm
	
	origGenerateBuffTooltipForm = Tooltip.GetBuffTooltipForm
	Tooltip.GetBuffTooltipForm = GenerateBuffTooltipForm
	
	origGenerateSpellTooltipForm = Tooltip.GetSpellTooltipForm 
	Tooltip.GetSpellTooltipForm  = GenerateSpellTooltipForm
	
	origGenerateItemTooltipForm = Tooltip.GetItemTooltipForm
	Tooltip.GetItemTooltipForm = GenerateItemTooltipForm
	
	local wndContainer = GameLib.GetWorldTooltipContainer()
	wndContainer:SetTooltipType(Window[ForgeUI_ToolTipsInst.tSettings.strTooltipPosition])
end

-----------------------------------------------------------------------------------------------
-- Hooks
-----------------------------------------------------------------------------------------------
GenerateBuffTooltipForm = function(luaCaller, wndParent, splSource, tFlags)
	local wndToolTip = origGenerateBuffTooltipForm(luaCaller, wndParent, splSource, tFlags)
	
	wndToolTip:SetStyle("Picture", true)
	wndToolTip:SetStyle("Border", false)
	wndToolTip:SetSprite("ForgeUI_Border")
	wndToolTip:SetBGColor("FF000000")
	
	wndToolTip:FindChild("NameString"):SetStyle("Picture", true)
	wndToolTip:FindChild("NameString"):SetSprite("ForgeUI_Border")
	wndToolTip:FindChild("NameString"):SetBGColor("FF000000")
	wndToolTip:FindChild("NameString"):SetFont("Nameplates")
	
	wndToolTip:FindChild("DispellableString"):SetFont("Nameplates")
	
	wndToolTip:FindChild("GeneralDescriptionString"):SetStyle("Picture", true)
	wndToolTip:FindChild("GeneralDescriptionString"):SetSprite("ForgeUI_Border")
	wndToolTip:FindChild("GeneralDescriptionString"):SetBGColor("FF000000")
	wndToolTip:FindChild("GeneralDescriptionString"):SetFont("Nameplates")
	
	local nLeft, nTop, nRight, nBottom = wndToolTip:GetAnchorOffsets()
	wndToolTip:SetAnchorOffsets(nLeft, nTop, nRight, nBottom - 45)
	
	return wndToolTip
end

GenerateSpellTooltipForm = function(luaCaller, wndParent, splSource, tFlags)
	local wndToolTip = origGenerateSpellTooltipForm(luaCaller, wndParent, splSource, tFlags)
	
	wndToolTip:SetSprite("ForgeUI_Border")
	wndToolTip:SetBGColor("FF000000")
	
	wndToolTip:FindChild("BGArt2"):SetSprite("ForgeUI_Border")
	wndToolTip:FindChild("BGArt2"):SetBGColor("FF000000")
	wndToolTip:FindChild("BGArt2"):SetAnchorOffsets(3, 3, -3, -3)
	
	return wndToolTip
end

GenerateItemTooltipForm = function(luaCaller, wndParent, itemSource, tFlags, nCount)
	local wndToolTip, wndTooltipComp = origGenerateItemTooltipForm(luaCaller, wndParent, itemSource, tFlags, nCount)
	
	if wndToolTip then
		wndToolTip:FindChild("ItemTooltipBG"):SetSprite("ForgeUI_Border")
		wndToolTip:FindChild("ItemTooltipBG"):SetBGColor("FF000000")
	
		wndToolTip:FindChild("CurrentHeader"):SetSprite("ForgeUI_Border")
		wndToolTip:FindChild("CurrentHeader"):SetBGColor("FF000000")
		
		wndToolTip:FindChild("ItemTooltip_BaseRarityFrame"):SetSprite("ForgeUI_Border")
		wndToolTip:FindChild("ItemTooltip_BaseRarityFrame"):SetBGColor("FF000000")
	end
	
	if wndTooltipComp then
		wndTooltipComp:FindChild("ItemTooltipBG"):SetSprite("ForgeUI_Border")
		wndTooltipComp:FindChild("ItemTooltipBG"):SetBGColor("FF000000")
		
		wndTooltipComp:FindChild("CurrentHeader"):SetSprite("ForgeUI_Border")
		wndTooltipComp:FindChild("CurrentHeader"):SetBGColor("FF000000")
		
		wndTooltipComp:FindChild("ItemTooltip_BaseRarityFrame"):SetSprite("ForgeUI_Border")
		wndTooltipComp:FindChild("ItemTooltip_BaseRarityFrame"):SetBGColor("FF000000")
	end
	
	return wndToolTip, wndTooltipComp
end

local b = true
GenerateUnitTooltipForm = function(luaCaller, wndContainer, unitSource, strProp)
	if not GameLib.GetPlayerUnit() then return end
	if not ForgeUI_ToolTipsInst.tSettings.bShowInCombat and GameLib.GetPlayerUnit():IsInCombat() then
		ToolTips.wndUnitTooltip:Show(false, true)
		return
	end

	origGenerateUnitTooltipForm(luaCaller, wndContainer, unitSource, strProp)
	
	local wndUnitTooltip = ToolTips.wndUnitTooltip
	
	if wndUnitTooltip then
		wndUnitTooltip:SetSprite("ForgeUI_Border")
		wndUnitTooltip:SetBGColor("ForgeUI_Border")
		
		-- TopDataBlock
		local wndTopDataBlock = wndUnitTooltip:FindChild("TopDataBlock")
		if wndTopDataBlock then
			wndTopDataBlock:FindChild("NameString"):SetText(unitSource:GetName())
			wndTopDataBlock:FindChild("NameString"):SetFont("CRB_Interface11_BO")
		
			local wndLevelBack = wndUnitTooltip:FindChild("LevelBack")
			if wndLevelBack then
				wndLevelBack:SetSprite("ForgeUI_Border")
				wndLevelBack:SetBGColor("FF000000")
				wndTopDataBlock:FindChild("LevelString"):SetFont("CRB_ButtonHeader")
			end
			
			local wndClassBack = wndUnitTooltip:FindChild("ClassBack")
			if wndClassBack then
				wndClassBack:SetSprite("ForgeUI_Border")
				wndClassBack:SetBGColor("FF000000")
				
				wndUnitTooltip:FindChild("ClassIcon"):SetSprite(ktClassToIcon[unitSource:GetClassId()])
			end
			
			local wndPathBack = wndUnitTooltip:FindChild("PathBack")
			if wndPathBack then
				wndPathBack:SetSprite("ForgeUI_Border")
				wndPathBack:SetBGColor("FF000000")
			end
		end
		
		-- MiddleDataBlock
		local wndMiddleDataBlock = wndUnitTooltip:FindChild("MiddleDataBlock")
		if wndMiddleDataBlock then
			wndMiddleDataBlock:SetSprite("ForgeUI_Border")
			wndMiddleDataBlock:SetBGColor("FF000000")
			wndMiddleDataBlock:SetFont("Nameplates")
			
			local wndUnitTooltip_Info = wndUnitTooltip:FindChild("UnitTooltip_Info")
			if wndUnitTooltip_Info then
				wndUnitTooltip_Info:SetFont("Nameplates")
			end
		end
		
		-- BottomDataBlock
		local wndBottomDataBlock = wndUnitTooltip:FindChild("BottomDataBlock")
		if wndBottomDataBlock then
			wndBottomDataBlock:SetFont("Nameplates")
			wndBottomDataBlock:FindChild("BreakdownString"):SetFont("Nameplates")
			wndBottomDataBlock:FindChild("XpAwardString"):SetFont("Nameplates")
		end
		
		local wndDispositionArtFrame = wndUnitTooltip:FindChild("DispositionArtFrame")
		if wndDispositionArtFrame then
			wndDispositionArtFrame:SetSprite("ForgeUI_Border")
			wndDispositionArtFrame:SetBGColor("FF000000")
		end
		
		local wndAffiliationString = wndUnitTooltip:FindChild("AffiliationString")
		if wndAffiliationString then
			wndAffiliationString:SetFont("Nameplates")
		end
	end
	
	--wndUnitTooltip:SetAnchorOffsets(500, 500, 800, 700)
end

function ForgeUI_ToolTips:OnMouseOverUnitChanged(unit)
	GenerateUnitTooltipForm(self, GameLib.GetWorldTooltipContainer(), unit, "")
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_ToolTips Instance
-----------------------------------------------------------------------------------------------
ForgeUI_ToolTipsInst = ForgeUI_ToolTips:new()
ForgeUI_ToolTipsInst:Init()
