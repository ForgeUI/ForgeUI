----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		hui.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI GUI library
-----------------------------------------------------------------------------------------------

require "Window"

-----------------------------------------------------------------------------------------------
-- ForgeUI Library Definition
-----------------------------------------------------------------------------------------------
local Gui = {}

-----------------------------------------------------------------------------------------------
-- ForgeUI Library Initialization
-----------------------------------------------------------------------------------------------
local strPrefix
local xmlDoc = nil

local new = function(self, o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	
	o.tDefaults = {
		strFont = "Nameplates",
	}
	
	return o
end

function Gui:ForgeAPI_Init()
	strPrefix = Apollo.GetAssetFolder()
	local tToc = XmlDoc.CreateFromFile("toc.xml"):ToTable()
	for k,v in ipairs(tToc) do
		local strPath = string.match(v.Name, "(.*)[\\/]Interface")
		if strPath ~= nil and strPath ~= "" then
			strPrefix = strPrefix .. "\\" .. strPath .. "\\"
			break
		end
	end
	
	xmlDoc = XmlDoc.CreateFromFile(strPrefix .. "\\interface\\gui.xml")
end

-----------------------------------------------------------------------------------------------
-- ForgeUI GUI elements
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- Holder
-----------------------------------------------------------------------------------------------
function Gui:API_AddHolder(tModule, wnd, tOptions)
	local wndText = Apollo.LoadForm(xmlDoc, "ForgeUI_Holder", wnd, self)
	
	return wndText
end

-----------------------------------------------------------------------------------------------
-- Text
-----------------------------------------------------------------------------------------------
function Gui:API_AddText(tModule, wnd, strText, tOptions)
	-- defaults
	local strFont = self.tDefaults.strFont
	local strText = strText

	-- load wnnd
	local wndText = Apollo.LoadForm(xmlDoc, "ForgeUI_Text", wnd, self)
	
	-- options
	if tOptions then
		if tOptions.tOffsets then
			wndText:SetAnchorOffsets(unpack(tOptions.tOffsets))
		end
	end
	
	-- set wnd
	wndText:SetText(strText)
	wndText:SetFont(strFont)
	
	-- calculate width of element
	local nTextWidth = Apollo.GetTextWidth(strFont, "  " .. strText .. "  ")
	local nLeft, nTop, nRight, nBottom = wndText:GetAnchorOffsets()
	wndText:SetAnchorOffsets(nLeft, nTop, nLeft + nTextWidth, nBottom)
	
	return wndText
end

-----------------------------------------------------------------------------------------------
-- ColorBox
-----------------------------------------------------------------------------------------------
function Gui:API_AddColorBox(tModule, wnd, strText, tSettings, strKey, tOptions)
	-- defaults
	local tData = {
		tModule = tModule,
		tSettings = tSettings,
		strKey = strKey,
		bShowAlpha = false,
		strColor = tSettings[strKey],
	}
	
	local strFont = self.tDefaults.strFont
	local strText = strText

	-- load wnnd
	local wndColorBox = Apollo.LoadForm(xmlDoc, "ForgeUI_ColorBox", wnd, self)
	
	-- event handlers
	wndColorBox:FindChild("EditBox"):AddEventHandler("EditBoxChanged", "OnColorBoxChanged", self)
	
	-- options
	if tOptions then
		if tOptions.tOffsets then
			wndColorBox:SetAnchorOffsets(unpack(tOptions.tOffsets))
		end
		
		if tOptions.tMove then
			local nLeft, nTop, nRight, nBottom = wndColorBox:GetAnchorOffsets()
			nLeft = nLeft + tOptions.tMove[1]
			nTop = nTop + tOptions.tMove[2]
			nRight = nRight + tOptions.tMove[1]
			nBottom = nBottom + tOptions.tMove[2]
			wndColorBox:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
		end
		
		if tOptions.fnCallback then
			tData.fnCallback = tOptions.fnCallback
		end
	end
	
	-- set wnd
	wndColorBox:FindChild("EditBox"):SetFont(strFont)
	wndColorBox:FindChild("Text"):SetText(strText)
	wndColorBox:FindChild("Text"):SetFont(strFont)
	
	-- data
	wndColorBox:SetData(tData)
	
	self:SetColorBox(wndColorBox, true)
	
	return wndColorBox
end

function Gui:SetColorBox(wndControl, bChangeText)
	local tData = wndControl:GetData()
	
	if tData.bShowAlpha then
		if bChangeText then
			wndControl:FindChild("EditBox"):SetText(tData.strColor)
		end
		wndControl:FindChild("EditBox"):SetTextColor(tData.strColor)
	else
		if bChangeText then
			wndControl:FindChild("EditBox"):SetText(string.sub(tData.strColor, 3, string.len(tData.strColor)))
		end
		wndControl:FindChild("EditBox"):SetTextColor(tData.strColor)
	end
	
	if tData.tSettings and tData.strKey then
		tData.tSettings[tData.strKey] = tData.strColor
	end
end

function Gui:OnColorBoxChanged(wndHandler, wndControl, strText)
	local tData = wndControl:GetParent():GetData()
	
	if tData.bShowAlpha and string.len(strText) > 8 then
		strText = string.sub(strText, 1, 8)
		wndControl:SetText(strText)
	elseif not tData.bShowAlpha and string.len(strText) > 6 then
		strText = string.sub(strText, 1, 6)
		wndControl:SetText(strText)
	end
	
	if tData.bShowAlpha and string.len(strText) == 8 then
		tData.strColor = strText
	elseif not tData.bShowAlpha and string.len(strText) == 6 then
		tData.strColor = "FF" .. strText
	end
	
	self:SetColorBox(wndControl:GetParent())
	
	if tData.fnCallback then
		tData.fnCallback(tData.tModule)
	end
end

-----------------------------------------------------------------------------------------------
-- CheckBox
-----------------------------------------------------------------------------------------------
function Gui:API_AddCheckBox(tModule, wnd, strText, tSettings, strKey, tOptions)
	-- defaults
	local tData = {
		tModule = tModule,
		tSettings = tSettings,
		strKey = strKey,
		bCheck = tSettings[strKey],
	}
	
	local strFont = self.tDefaults.strFont
	local strText = strText

	-- load wnnd
	local wndCheckBox = Apollo.LoadForm(xmlDoc, "ForgeUI_CheckBox", wnd, self)
	
	-- event handlers
	wndCheckBox:AddEventHandler("ButtonCheck", "OnCheckBoxCheck", self)
	wndCheckBox:AddEventHandler("ButtonUncheck", "OnCheckBoxCheck", self)
	
	-- options
	if tOptions then
		if tOptions.tOffsets then
			wndCheckBox:SetAnchorOffsets(unpack(tOptions.tOffsets))
		end
		
		if tOptions.tMove then
			local nLeft, nTop, nRight, nBottom = wndCheckBox:GetAnchorOffsets()
			nLeft = nLeft + tOptions.tMove[1]
			nTop = nTop + tOptions.tMove[2]
			nRight = nRight + tOptions.tMove[1]
			nBottom = nBottom + tOptions.tMove[2]
			wndCheckBox:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
		end
		
		if tOptions.fnCallback then
			tData.fnCallback = tOptions.fnCallback
		end
	end
	
	-- data
	wndCheckBox:SetData(tData)
	
	-- set wnd
	wndCheckBox:FindChild("Text"):SetFont(strFont)
	wndCheckBox:FindChild("Text"):SetText(strText)
	
	self:SetCheckBox(wndCheckBox)
	
	return wndCheckBox
end

function Gui:SetCheckBox(wndControl)
	local tData = wndControl:GetData()
	
	wndControl:FindChild("CheckBox"):SetCheck(tData.bCheck)
	
	if tData.tSettings and tData.strKey then
		tData.tSettings[tData.strKey] = tData.bCheck
	end
end

function Gui:OnCheckBoxCheck(wndHandler, wndControl, eMouseButton)
	local tData = wndControl:GetParent():GetData()
	
	tData.bCheck = wndControl:IsChecked()
	
	self:SetCheckBox(wndControl:GetParent())
	
	if tData.fnCallback then
		tData.fnCallback(tData.tModule)
	end
end

_G["ForgeLibs"][4] = new(Gui)

