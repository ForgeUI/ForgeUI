----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI addon
--
-- name: 		ForgeUI_ToolTips.lua
-- author:		Winty Badass@Jabbit
-- about:		Tooltips meter addon for ForgeUI
-----------------------------------------------------------------------------------------------

require "Window"
 
local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI

-----------------------------------------------------------------------------------------------
-- ForgeUI Addon Definition
-----------------------------------------------------------------------------------------------
local ForgeUI_ToolTips = {
    _NAME = "ForgeUI_ToolTips",
	_API_VERSION = 3,
	VERSION = "2.0",

    settings_version = 2,
    tSettings = {
		profile = {
			strTooltipPosition = "TPT_NavText", -- TPT_NavText TPT_OnCursor
			bShowInCombat = false,
			bShowBuffId = false,
			bShowSpellId = false,
		}
	}
}

-- /eval F:API_GetAddon("ForgeUI_ToolTips")._DB.profile.strTooltipPosition = "TPT_NavText"
-- /eval F:API_GetAddon("ForgeUI_ToolTips")._DB.profile.strTooltipPosition = "TPT_OnCursor"

-----------------------------------------------------------------------------------------------
-- Local variables
-----------------------------------------------------------------------------------------------
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

local GenerateUnitTooltipForm
local GenerateBuffTooltipForm
local GenerateSpellTooltipForm
local GenerateItemTooltipForm

local origGenerateUnitTooltipForm
local origGenerateBuffTooltipForm
local origGenerateSpellTooltipForm
local origGenerateItemTooltipForm

function ForgeUI_ToolTips:ForgeAPI_Init()
	Apollo.LoadSprites("..\ForgeUI\ForgeUI_Sprite.xml");
	
	ToolTips = Apollo.GetAddon("ToolTips")
	
	F:PostHook(ToolTips, "OnDocumentReady", self.OnDocumentReady)
end

function ForgeUI_ToolTips:OnDocumentReady(tooltips)
	origGenerateUnitTooltipForm = ToolTips.UnitTooltipGen
	ToolTips.UnitTooltipGen = GenerateUnitTooltipForm

	origGenerateBuffTooltipForm = Tooltip.GetBuffTooltipForm
	Tooltip.GetBuffTooltipForm = GenerateBuffTooltipForm

	origGenerateSpellTooltipForm = Tooltip.GetSpellTooltipForm
	Tooltip.GetSpellTooltipForm  = GenerateSpellTooltipForm

	origGenerateItemTooltipForm = Tooltip.GetItemTooltipForm
	Tooltip.GetItemTooltipForm = GenerateItemTooltipForm

	local wndContainer = GameLib.GetWorldTooltipContainer()
	wndContainer:SetTooltipType(Window[ForgeUI_ToolTips._DB.profile.strTooltipPosition])
end

-----------------------------------------------------------------------------------------------
-- Hooks
-----------------------------------------------------------------------------------------------
GenerateBuffTooltipForm = function(luaCaller, wndParent, splSource, tFlags)
	local wndToolTip = origGenerateBuffTooltipForm(luaCaller, wndParent, splSource, tFlags)

	if not wndToolTip then
		return
	end
	
	wndToolTip:SetStyle("Picture", true)
	wndToolTip:SetStyle("Border", false)
	wndToolTip:SetSprite("ForgeUI_BorderLight")
	wndToolTip:SetBGColor("FF000000")

	wndToolTip:FindChild("NameString"):SetStyle("Picture", false)
	wndToolTip:FindChild("NameString"):SetSprite("ForgeUI_BorderLight")
	wndToolTip:FindChild("NameString"):SetBGColor("CC000000")
	wndToolTip:FindChild("NameString"):SetFont("Nameplates")

	wndToolTip:FindChild("DispellableString"):SetFont("Nameplates")

	wndToolTip:FindChild("GeneralDescriptionString"):SetStyle("Picture", false)
	wndToolTip:FindChild("GeneralDescriptionString"):SetSprite("ForgeUI_BorderLight")
	wndToolTip:FindChild("GeneralDescriptionString"):SetBGColor("CC000000")
	wndToolTip:FindChild("GeneralDescriptionString"):SetFont("Nameplates")

	local nLeft, nTop, nRight, nBottom = wndToolTip:GetAnchorOffsets()
	wndToolTip:SetAnchorOffsets(nLeft, nTop, nRight, nBottom - 45)
	
	-- show spellid of buff/debuff
	local buffName = wndToolTip:FindChild("NameString"):GetText();
	if ForgeUI_ToolTips._DB.profile.bShowBuffId then
		wndToolTip:FindChild("NameString"):SetText(buffName .. " (" .. splSource:GetId() ..")")
	else
		wndToolTip:FindChild("NameString"):SetText(buffName)
	end

	return wndToolTip
end

GenerateSpellTooltipForm = function(luaCaller, wndParent, splSource, tFlags)	
	local wndToolTip = origGenerateSpellTooltipForm(luaCaller, wndParent, splSource, tFlags)

	if wndToolTip then
		
		wndToolTip:SetStyle("Picture", false)
		wndToolTip:SetSprite("ForgeUI_BorderLight")
		wndToolTip:SetBGColor("CC000000")
	
		-- show item id
		local wndTopDataBlock = wndToolTip:FindChild("TopDataBlock")
		local wndName = wndTopDataBlock:FindChild("NameString")
		if ForgeUI_ToolTips._DB.profile.bShowSpellId then
			wndName:SetAML(string.format("<P Font=\"CRB_HeaderSmall\" TextColor=\"UI_TextHoloTitle\">%s</P>", splSource:GetName() .. " (" .. splSource:GetId() .. ")" ))
		else
			wndName:SetAML(string.format("<P Font=\"CRB_HeaderSmall\" TextColor=\"UI_TextHoloTitle\">%s</P>", splSource:GetName()))
		end
		
		wndToolTip:FindChild("BGArt2"):SetSprite("ForgeUI_BorderLight")
		wndToolTip:FindChild("BGArt2"):SetBGColor("FF000000")
		wndToolTip:FindChild("BGArt2"):SetAnchorOffsets(3, 3, -3, -3)	

	end

	return wndToolTip
end

GenerateItemTooltipForm = function(luaCaller, wndParent, itemSource, tFlags, nCount)
	local wndToolTip, wndTooltipComp = origGenerateItemTooltipForm(luaCaller, wndParent, itemSource, tFlags, nCount)

	if wndToolTip then
		wndToolTip:FindChild("ItemTooltipBG"):SetSprite("ForgeUI_BorderLight")
		wndToolTip:FindChild("ItemTooltipBG"):SetBGColor("FF000000")

		wndToolTip:FindChild("CurrentHeader"):SetSprite("ForgeUI_BorderLight")
		wndToolTip:FindChild("CurrentHeader"):SetBGColor("FF000000")

		wndToolTip:FindChild("ItemTooltip_BaseRarityFrame"):SetSprite("ForgeUI_BorderLight")
		wndToolTip:FindChild("ItemTooltip_BaseRarityFrame"):SetBGColor("FF000000")
	end

	if wndTooltipComp then
		wndTooltipComp:FindChild("ItemTooltipBG"):SetSprite("ForgeUI_BorderLight")
		wndTooltipComp:FindChild("ItemTooltipBG"):SetBGColor("FF000000")

		wndTooltipComp:FindChild("CurrentHeader"):SetSprite("ForgeUI_BorderLight")
		wndTooltipComp:FindChild("CurrentHeader"):SetBGColor("FF000000")

		wndTooltipComp:FindChild("ItemTooltip_BaseRarityFrame"):SetSprite("ForgeUI_BorderLight")
		wndTooltipComp:FindChild("ItemTooltip_BaseRarityFrame"):SetBGColor("FF000000")
	end

	return wndToolTip, wndTooltipComp
end

GenerateUnitTooltipForm = function(luaCaller, wndContainer, unitSource, strProp)
	origGenerateUnitTooltipForm(luaCaller, wndContainer, unitSource, strProp)

	local wndUnitTooltip = ToolTips.wndUnitTooltip

	if wndUnitTooltip then
		wndUnitTooltip:SetSprite("ForgeUI_BorderLight")
		wndUnitTooltip:SetBGColor("ForgeUI_BorderLight")

		-- TopDataBlock
		local wndTopDataBlock = wndUnitTooltip:FindChild("TopDataBlock")
		if wndTopDataBlock then
			--wndTopDataBlock:FindChild("NameString"):SetText(unitSource:GetName())
			--wndTopDataBlock:FindChild("NameString"):SetFont("CRB_Interface11_BO")

			local wndLevelBack = wndUnitTooltip:FindChild("LevelBack")
			if wndLevelBack then
				wndLevelBack:SetSprite("ForgeUI_BorderLight")
				wndLevelBack:SetBGColor("FF000000")
				wndTopDataBlock:FindChild("LevelString"):SetFont("CRB_ButtonHeader")
			end

			local wndClassBack = wndUnitTooltip:FindChild("ClassBack")
			if wndClassBack then
				wndClassBack:SetSprite("ForgeUI_BorderLight")
				wndClassBack:SetBGColor("FF000000")

				wndUnitTooltip:FindChild("ClassIcon"):SetSprite(ktClassToIcon[unitSource:GetClassId()])
			end

			local wndPathBack = wndUnitTooltip:FindChild("PathBack")
			if wndPathBack then
				wndPathBack:SetSprite("ForgeUI_BorderLight")
				wndPathBack:SetBGColor("FF000000")
			end
		end

		-- MiddleDataBlock
		local wndMiddleDataBlock = wndUnitTooltip:FindChild("MiddleDataBlock")
		if wndMiddleDataBlock then
			wndMiddleDataBlock:SetSprite("ForgeUI_BorderLight")
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
			wndDispositionArtFrame:SetSprite("ForgeUI_BorderLight")
			wndDispositionArtFrame:SetBGColor("FF000000")
		end

		local wndAffiliationString = wndUnitTooltip:FindChild("AffiliationString")
		if wndAffiliationString then
			wndAffiliationString:SetFont("Nameplates")
		end
	end
end

function ForgeUI_ToolTips:OnMouseOverUnitChanged(unit)
	GenerateUnitTooltipForm(self, GameLib.GetWorldTooltipContainer(), unit, "")
end

function ForgeUI_ToolTips:ForgeAPI_LoadSettings()

end

-----------------------------------------------------------------------------------------------
-- ForgeUI_ToolTips Instance
-----------------------------------------------------------------------------------------------
ForgeUI_ToolTips = F:API_NewAddon(ForgeUI_ToolTips)
