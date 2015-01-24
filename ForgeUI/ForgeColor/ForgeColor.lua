local MAJOR, MINOR = "ForgeColor", 1
local APkg = Apollo.GetPackage(MAJOR)
if APkg and (APkg.nVersion or 0) >= MINOR then return end

require "Window"

local ForgeUI
local ForgeColor = APkg and APkg.tPackage or {}

-----------------------------------------------------------------------------------------------
-- Upvalues
-----------------------------------------------------------------------------------------------
local ipairs, pairs, strmatch, strlen = ipairs, pairs, string.match, string.len
local error, select, strformat, type, unpack = error, select, string.format, type, unpack
local strsub, tonumber, mathmax, mathmin = string.sub, tonumber, math.max, math.min
local setmetatable, tinsert, tremove = setmetatable, table.insert, table.remove
local strlower = string.lower

-- Wildstar APIs
local Apollo, Print, XmlDoc = Apollo, Print, XmlDoc

local floor = math.floor
local GetCurrentColor

local tSavedColors = {
	"FFFFFFFF", "FFCCCCCC", "FFB0B0B0", "FF959595", "FF757575",
	"FF666666", "FF4C4C4C", "FF333333", "FF1A1A1A", "FF000000",
	
	"FFB60F2E", "FF7D8EE2", "FFC12A0F", "FFB6FBEB", "FFFF9900",
	"FF001170", "FF011700", "FF000117", "FF117000", "FF343117",
	"FF207584", "FFF5CA9E", "FF854513", "FF8B2500", "FF8B0000",
	"FFFFFACD", "FF20B2AA", "FFCDD7F7", "FFB6FBEB", "FF311811",
	
	"FF98C723", "FFD23EF4", "FF1591DB", "FFEFAB48", "FFF54F4F", "FFFFE757", -- class colors
}

local tAddon = nil
local crDefault = nil
local fCallback = nil
local tSettings = nil
local strKey = nil
local wndControl = nil

function ForgeColor:Show(tAdd, crDef, tOptions)
	if self.wndPicker == nil then
		self.wndPicker = Apollo.LoadForm(self.xmlDoc, "ForgeColor_Picker", nil, self)
		self:Init()
	end
	
	tAddon = nil
	crDefault = nil
	fCallback = nil
	tSettings = nil
	strKey = nil
	wndControl = nil
	
	tAddon = tAdd
	crDefault = crDef
	if crDefault ~= nil then
		local h, s, v, a = self:RGBtoHSV(self:HexToRGB(crDefault, false))
	
		self:SetHue(h)
		self.s = s
		self.v = v
		self.a = a
		
		self:UpdateColor()
	end
	
	if tOptions ~= nil then
		fCallback = tOptions.fCallback
		tSettings = tOptions.tSettings
		strKey = tOptions.strKey
		wndControl = tOptions.wndControl
	end
	
	self.wndPicker:Show(true)
end

function ForgeColor:Hide()
	if self.wndPicker ~= nil then
		self.wndPicker:Show(false)
		
		tAddon = nil
		crDefault = nil
		fCallback = nil
		tSettings = nil
		strKey = nil
		wndControl = nil
	end
end

function ForgeColor:OnLoad()
	local strPrefix = Apollo.GetAssetFolder()
	local tToc = XmlDoc.CreateFromFile("toc.xml"):ToTable()
	for k,v in ipairs(tToc) do
		local strPath = strmatch(v.Name, "(.*)[\\/]ForgeColor")
		if strPath ~= nil and strPath ~= "" then
			strPrefix = strPrefix .. "\\" .. strPath .. "\\"
			break
		end
	end
	
	self.xmlDoc = XmlDoc.CreateFromFile(strPrefix.."ForgeColor.xml")
end

function ForgeColor:Init()
	if ForgeUI == nil then
		ForgeUI = Apollo.GetAddon("ForgeUI")
	end

	self.h = 1
	self.s = 1
	self.v = 1
	self.a = 1

	self.wndPicker:FindChild("CloseButton"):AddEventHandler("ButtonSignal", 				"Hide", self)
	
	self.wndPicker:FindChild("Picker:Gradient"):AddEventHandler("MouseButtonDown", 			"OnPickerDown", self)
	self.wndPicker:FindChild("Picker:Gradient"):AddEventHandler("MouseButtonUp", 			"OnPickerUp", self)
	self.wndPicker:FindChild("Picker:Gradient"):AddEventHandler("MouseExit", 				"OnPickerExit", self)
	self.wndPicker:FindChild("Picker:Gradient"):AddEventHandler("MouseMove", 				"OnPickerMove", self)
	
	self.wndPicker:FindChild("ColorSelector:Gradient"):AddEventHandler("MouseButtonDown", 	"OnSelectorDown", self)
	self.wndPicker:FindChild("ColorSelector:Gradient"):AddEventHandler("MouseButtonUp", 	"OnSelectorUp", self)
	self.wndPicker:FindChild("ColorSelector:Gradient"):AddEventHandler("MouseExit", 		"OnSelectorExit", self)
	self.wndPicker:FindChild("ColorSelector:Gradient"):AddEventHandler("MouseMove", 		"OnSelectorMove", self)
	
	for _, cr in pairs(tSavedColors) do
		local color = Apollo.LoadForm(self.xmlDoc, "ForgeColor_Color", self.wndPicker:FindChild("SavedColors"), self)
		color:FindChild("Color"):SetBGColor(cr)
		color:FindChild("Color"):SetData(cr)
		
		color:FindChild("Color"):AddEventHandler("MouseButtonDown",							"OnSavedColorDown", self)
	end
	
	self.wndPicker:FindChild("SavedColors"):ArrangeChildrenTiles()
end

function ForgeColor:SetHue( hue )
	local newHue = hue
	if newHue > 1 then newHue = 1 elseif newHue < 0 then newHue = 0 end
	
	self.h = newHue
	self.wndPicker:FindChild("Picker:Gradient"):SetBGColor(self:RGBAToHex(self:HSVtoRGB(newHue, 1, 1, 1)))
end

function ForgeColor:UpdateColor()
	local crNew = self:RGBAToHex(self:HSVtoRGB(self.h, self.s, self.v, self.a))
	
	self.wndPicker:FindChild("ColorBox"):SetText(string.sub(crNew, 3, 8):upper())
	self.wndPicker:FindChild("ColorBox"):SetTextColor(crNew)
	
	if tAddon ~= nil and fCallback ~= nil then
		tAddon[fCallback]("ForgeColor_callback", crNew, strKey)
	end
	
	if tAddon ~= nil and wndControl ~= nil and wndControl:GetData() then
		local tData = wndControl:GetData()
		if tData.bAlpha then
			wndControl:SetText(crNew)
		else
			wndControl:SetText(string.sub(crNew, 3, 8):upper())
		end
		--ForgeUI.API_ColorBoxChange(tData.tAddon, wndControl, tData.tSettings, tData.sValue, false, tData.bAlpha)
		ForgeUI["OnColorBoxChanged"]( self, wndControl, wndControl, crNew )
	end
	
	if tAddon ~= nill and tSettings ~= nil and strKey ~= nil then
		tSettings[strKey] = crNew
	end
end

-----------------------------------------------------------------------------------------------
-- Picker
-----------------------------------------------------------------------------------------------

local bPickerMouse = false
function ForgeColor:UpdatePickerColor( x, y )
	if bPickerMouse == false then return end	

	local fSaturation, fLightness  = x, y
	fLightness = 1 - ((fLightness + 10) / 256)
	fSaturation = ((fSaturation + 10) / 256)
	if fLightness > 1 then fLightness = 1 elseif fLightness < 0 then fLightness = 0 end
	if fSaturation > 1 then fSaturation = 1 elseif fSaturation < 0 then fSaturation = 0 end
	
	self.s = fSaturation
	self.v = fLightness
	
	self:UpdateColor()
end

function ForgeColor:OnPickerMove( wndHandler, wndControl, nLastRelativeMouseX, nLastRelativeMouseY )
	self:UpdatePickerColor(nLastRelativeMouseX, nLastRelativeMouseY)
end

function ForgeColor:OnPickerDown( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if eMouseButton == 0 then
		bPickerMouse = true
		
		self:UpdatePickerColor(nLastRelativeMouseX, nLastRelativeMouseY)
	end
end

function ForgeColor:OnPickerUp( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if eMouseButton == 0 then
		bPickerMouse = false
	end
end

function ForgeColor:OnPickerExit()
	bPickerMouse = false
end

-----------------------------------------------------------------------------------------------
-- Selector
-----------------------------------------------------------------------------------------------

local bSelectorMouse = false
function ForgeColor:UpdateSelectorColor( x, y )
	if bSelectorMouse == false then return end
	self:SetHue(x / 255)
	
	self:UpdateColor()
end

function ForgeColor:OnSelectorMove( wndHandler, wndControl, nLastRelativeMouseX, nLastRelativeMouseY )
	self:UpdateSelectorColor(nLastRelativeMouseX, nLastRelativeMouseY)
end

function ForgeColor:OnSelectorDown( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if eMouseButton == 0 then
		bSelectorMouse = true
		
		self:UpdateSelectorColor(nLastRelativeMouseX, nLastRelativeMouseY)
	end
end

function ForgeColor:OnSelectorUp( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if eMouseButton == 0 then
		bSelectorMouse = false
	end
end

function ForgeColor:OnSelectorExit()
	bSelectorMouse = false
end

-----------------------------------------------------------------------------------------------
-- Saved colors
-----------------------------------------------------------------------------------------------

function ForgeColor:OnSavedColorDown( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	local newColor = wndControl:GetData()
	local h, s, v, a = self:RGBtoHSV(self:HexToRGB(newColor, false))
	
	self:SetHue(h)
	self.s = s
	self.v = v
	self.a = a
	
	self:UpdateColor()
end

-----------------------------------------------------------------------------------------------
-- Libraries
-----------------------------------------------------------------------------------------------

function ForgeColor:RGBAToHex(r, g, b, a, bAlpha)
	a = a or 255
	return strformat("%02x%02x%02x%02x", a, r, g, b)
end

function ForgeColor:HexToRGB(hexa, bAlpha)
	local color = "FFFFFFFF"
	if bAlpha then
		color = hexa
	else
		color = string.sub(hexa, 3, 8)
	end

	local r = tonumber(string.sub(color, 1, 2), 16)
	local g = tonumber(string.sub(color, 3, 4), 16)
	local b = tonumber(string.sub(color, 5, 6), 16)
	
	return r, g, b, 255
end

-----------------------------------------------------------------------------------------------
-- Color Utility Functions
-- Adapted From https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
-----------------------------------------------------------------------------------------------
function ForgeColor:RGBtoHSV(r, g, b, a)
	a = a or 255
	r, g, b, a = r / 255, g / 255, b / 255, a / 255
	local max, min = mathmax(r, g, b), mathmin(r, g, b)
	local h, s, v
	v = max

	local d = max - min
	if max == 0 then s = 0 else s = d / max end

	if max == min then
		h = 0 -- achromatic
	else
		if max == r then
			h = (g - b) / d
			if g < b then h = h + 6 end
			elseif max == g then h = (b - r) / d + 2
			elseif max == b then h = (r - g) / d + 4
		end
		h = h / 6
	end

	return h, s, v, a
end

function ForgeColor:HSVtoRGB(h, s, v, a)
	local r, g, b

	a = a or 1

	local i = floor(h * 6);
	local f = h * 6 - i;
	local p = v * (1 - s);
	local q = v * (1 - f * s);
	local t = v * (1 - (1 - f) * s);

	i = i % 6

	if i == 0 then r, g, b = v, t, p
	elseif i == 1 then r, g, b = q, v, p
	elseif i == 2 then r, g, b = p, v, t
	elseif i == 3 then r, g, b = p, q, v
	elseif i == 4 then r, g, b = t, p, v
	elseif i == 5 then r, g, b = v, p, q
	end

	return floor(r * 255), floor(g * 255), floor(b * 255), floor(a * 255)
end

function ForgeColor:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

Apollo.RegisterPackage(ForgeColor:new(), MAJOR, MINOR, {})