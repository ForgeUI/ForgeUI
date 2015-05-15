local ForgeUI = Apollo.GetAddon("ForgeUI")
local SupplySatchel

local Theme = ForgeUI:API_RegisterTheme("SupplySatchel", true)

local strPrefix
local tToc

local fnOnLoad

function Theme:Init()
	SupplySatchel = Apollo.GetAddon("SupplySatchel")
	
	strPrefix = Apollo.GetAssetFolder()
	tToc = XmlDoc.CreateFromFile("toc.xml"):ToTable()
	
	fnOnLoad = SupplySatchel.OnLoad
	SupplySatchel.OnLoad = self.OnFakeLoad
end

function Theme:OnFakeLoad(bLoad)

end

function Theme:OnLoad()
	for k,v in ipairs(tToc) do
		local strPath = string.match(v.Name, "(.*)[\\/]SupplySatchel")
		if strPath ~= nil and strPath ~= "" then
			strPrefix = strPrefix .. "\\" .. strPath .. "\\"
			break
		end
	end
	
	self.xmlDoc = XmlDoc.CreateFromFile(strPrefix .. "SupplySatchel.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self)
end

function Theme:OnUnload()
	for k,v in ipairs(tToc) do
		local strPath = string.match(v.Name, "(.*)[\\/]SupplySatchel")
		if strPath ~= nil and strPath ~= "" then
			strPrefix = strPrefix .. "\\" .. strPath .. "\\"
			break
		end
	end
	
	self.xmlDoc = XmlDoc.CreateFromFile(strPrefix .. "SupplySatchelOrig.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self)
end

