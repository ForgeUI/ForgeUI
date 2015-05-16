----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		hui.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI GUI handler
-----------------------------------------------------------------------------------------------

local F, A, M, G = unpack(_G["ForgeLibs"]) -- imports ForgeUI, Addon, Module, GUI

-----------------------------------------------------------------------------------------------
-- ForgeUI Module Definition
-----------------------------------------------------------------------------------------------
local Gui = {}

-----------------------------------------------------------------------------------------------
-- ForgeUI Module Initialization
-----------------------------------------------------------------------------------------------
local strPrefix
local xmlDoc = nil

function Gui:Init()
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
-- ForgeUI Holder
-----------------------------------------------------------------------------------------------
function Gui:API_AddHolder(tModule, wnd, tOptions)
	local wndText = Apollo.LoadForm(xmlDoc, "ForgeUI_Holder", wnd, self)
	
	return wndText
end

-----------------------------------------------------------------------------------------------
-- ForgeUI Text
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

_G["ForgeLibs"][4] = Gui

