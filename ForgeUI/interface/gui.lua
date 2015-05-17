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
	local wndText = Apollo.LoadForm(xmlDoc, "ForgeUI_Text", wnd, self)
	wndText:SetText(strText)
	
	if tOptions then
		if tOptions.tOffsets then
			wndText:SetAnchorOffsets(unpack(tOptions.tOffsets))
		end
	end
	
	return wndText
end

_G["ForgeLibs"][4] = new(Gui)

