require "Window"

local MAJOR, MINOR = "ForgeOptions", 1

local APkg = Apollo.GetPackage(MAJOR)
if APkg and (APkg.nVersion or 0) >= MINOR then return end

local ForgeUI = Apollo.GetAddon("ForgeUI")
local ForgeOptions = APkg and APkg.tPackage or {}

local ForgeOptionsInst

local ipairs, pairs, strmatch, strlen = ipairs, pairs, string.match, string.len

-- hooks
local fnAfterRegistration
local fnAfterRegistrationOrig

local fnAfterRestore
local fnAfterRestoreOrig

-- variables
local wndAdvancedBtn

function ForgeOptions:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	
	-- mandatory 
    self.api_version = 2
	self.version = "1.0.0"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_Options"
	self.strDisplayName = "Advanced options"
	
	self.wndContainers = {}
	
	self.tStylers = {}
	
	-- optional
	self.settings_version = 1
    self.tSettings = {}
	
	return o
end

function ForgeOptions:OnLoad()
	local strPrefix = Apollo.GetAssetFolder()
	local tToc = XmlDoc.CreateFromFile("toc.xml"):ToTable()
	for k,v in ipairs(tToc) do
		local strPath = strmatch(v.Name, "(.*)[\\/]ForgeOptions")
		if strPath ~= nil and strPath ~= "" then
			strPrefix = strPrefix .. "\\" .. strPath .. "\\"
			break
		end
	end
	
	self.xmlDoc = XmlDoc.CreateFromFile(strPrefix .. "ForgeOptions.xml")
end

function ForgeOptions:Init()
	fnAfterRegistrationOrig = ForgeUI.ForgeAPI_AfterRegistration
	ForgeUI.ForgeAPI_AfterRegistration = fnAfterRegistration
	
	fnAfterRestoreOrig = ForgeUI.ForgeAPI_AfterRestore
	ForgeUI.ForgeAPI_AfterRestore = fnAfterRestore
end

function ForgeOptions:OnAdvancedOptions()
	ForgeUI.API_ToggleItemButton(wndAdvancedBtn, ForgeUI.tSettings.bAdvanced)
end

-- hooked functions
fnAfterRegistration = function(luaCaller)
	fnAfterRegistrationOrig(luaCaller)
	
	wndAdvancedBtn = ForgeUI.API_AddItemButton(ForgeOptionsInst, "Advanced options", { strContainer = "ForgeUI_Advanced", xmlDoc = ForgeOptionsInst.xmlDoc })
end

fnAfterRestore = function(luaCaller)
	fnAfterRestoreOrig(luaCaller)
	
	ForgeUI.API_RegisterCheckBox(ForgeOptionsInst, luaCaller.wndContainers.ForgeUI_General:FindChild("bAdvanced"):FindChild("CheckBox"), luaCaller.tSettings, "bAdvanced", "OnAdvancedOptions")
	ForgeUI.API_ToggleItemButton(wndAdvancedBtn, luaCaller.tSettings.bAdvanced)
end

--- api
function ForgeOptions:API_AddAdvancedOption(tAddon, strGroup, strText, strType, tSettings, strKey, strCallback, tOptions)
	local wndGroup
	
	for k, v in pairs(ForgeOptionsInst.wndContainers["ForgeUI_Advanced"]:GetChildren()) do
		if v:GetData() == strGroup then
			wndGroup = v
		end
	end
	
	if not wndGroup then
		wndGroup = Apollo.LoadForm(ForgeOptionsInst.xmlDoc, "ForgeUI_Group", ForgeOptionsInst.wndContainers["ForgeUI_Advanced"], ForgeOptionsInst)
		wndGroup:FindChild("Text"):SetText(strGroup)
		wndGroup:SetData(strGroup)
		
		wndGroup:FindChild("Button"):AddEventHandler("ButtonSignal", "OnGroupButtonSignal", ForgeOptionsInst)
	end

	local wndOption = Apollo.LoadForm(ForgeOptionsInst.xmlDoc, "ForgeUI_Option", wndGroup:FindChild("Container"), ForgeUI)
	
	local tData = {}
	tData.tAddon = tAddon
	tData.tSettings = tSettings
	tData.strKey = strKey
	tData.strType = strType
	
	wndOption:FindChild("Text"):SetText(strText)
	
	if strType == "boolean" then
		wndOption:FindChild("CheckBox"):Show(true, true)
		
		ForgeUI.API_RegisterCheckBox(tAddon, wndOption:FindChild("CheckBox"), tSettings, strKey, strCallback)
	elseif strType == "number" then
		wndOption:FindChild("NumberBox"):Show(true, true)
		
		ForgeUI.API_RegisterNumberBox(tAddon, wndOption:FindChild("NumberBox"):FindChild("EditBox"), tSettings, strKey, strCallback)
	elseif strType == "dropdown" then
		wndOption:FindChild("Dropdown"):Show(true, true)
		
		ForgeUI.API_RegisterDropdown(self, wndOption:FindChild("Dropdown"), tSettings, strKey, tOptions.tDropdown, strCallback)
	end
	
	wndOption:SetData(tData)
	
	
	local nLeft, nTop, nRight, nBottom = wndGroup:GetAnchorOffsets()
	wndGroup:SetAnchorOffsets(nLeft, nTop, nRight, nTop + 35 + #wndGroup:FindChild("Container"):GetChildren() * 30 + 2)
	
	wndGroup:FindChild("Container"):ArrangeChildrenVert()
	ForgeOptionsInst.wndContainers["ForgeUI_Advanced"]:ArrangeChildrenVert()
	
	return wndOption
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_Group Functions
---------------------------------------------------------------------------------------------------
function ForgeOptions:OnGroupButtonSignal( wndHandler, wndControl, eMouseButton )
	if not wndControl:GetName() == "Button" then return end
	
	local wndGroup = wndControl:GetParent():GetParent():GetParent()
	
	if wndControl:GetText() == "-" then
		wndControl:SetText("+")
		wndGroup:FindChild("Container"):Show(false, true)
		local nLeft, nTop, nRight, nBottom = wndGroup:GetAnchorOffsets()
		wndGroup:SetAnchorOffsets(nLeft, nTop, nRight, nTop + 35)
	elseif wndControl:GetText() == "+" then
		wndControl:SetText("-")
		wndGroup:FindChild("Container"):Show(true, true)
		local nLeft, nTop, nRight, nBottom = wndGroup:GetAnchorOffsets()
		
		wndGroup:SetAnchorOffsets(nLeft, nTop, nRight, nTop + 35 + #wndGroup:FindChild("Container"):GetChildren() * 30 + 2)
	end
	
	wndGroup:FindChild("Container"):ArrangeChildrenVert()
	ForgeOptionsInst.wndContainers["ForgeUI_Advanced"]:ArrangeChildrenVert()
end

ForgeOptionsInst = ForgeOptions:new()
Apollo.RegisterPackage(ForgeOptionsInst, MAJOR, MINOR, {})