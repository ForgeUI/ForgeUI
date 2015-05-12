require "Window"

local MAJOR, MINOR = "ForgeNotifications", 1

local APkg = Apollo.GetPackage(MAJOR)
if APkg and (APkg.nVersion or 0) >= MINOR then return end

local ForgeUI = Apollo.GetAddon("ForgeUI")
local ForgeNotifications = APkg and APkg.tPackage or {}

local Inst

-- variables
local bCheckedForVersion = false

-- local functions
local fnVersionCheck
local fnIsNewVersion

function ForgeNotifications:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	
	-- mandatory 
    self.api_version = 2
	self.version = "1.0.0"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_Notifications"
	self.strDisplayName = "Notifications"
	
	self.wndContainers = {}
	self.tStylers = {}
	
	self.tNotifications = {}
	
	return o
end

function ForgeNotifications:OnLoad()
	local strPrefix = Apollo.GetAssetFolder()
	local tToc = XmlDoc.CreateFromFile("toc.xml"):ToTable()
	for k,v in ipairs(tToc) do
		local strPath = string.match(v.Name, "(.*)[\\/]ForgeNotifications")
		if strPath ~= nil and strPath ~= "" then
			strPrefix = strPrefix .. "\\" .. strPath .. "\\"
			break
		end
	end
	
	self.xmlDoc = XmlDoc.CreateFromFile(strPrefix .. "ForgeNotifications.xml")
end

function ForgeNotifications:Init()
	ForgeUI:CommAPI_RegisterFunction("VersionCheck", fnVersionCheck)
	ForgeUI:CommAPI_RegisterFunction("IsNewVersion", fnIsNewVersion)

	self.wndHolder = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Notifications", nil, self)

	Apollo.RegisterTimerHandler("StartupTimer", "OnStartupTimer", self)
	Apollo.CreateTimer("StartupTimer", 5.0, false)
	
	Apollo.RegisterTimerHandler("NotificationTimer", "OnNotificationTimer", self)
	Apollo.CreateTimer("NotificationTimer", 0.1, true)
	Apollo.StopTimer("NotificationTimer")
end

function ForgeNotifications:OnStartupTimer()
	self:CheckForVersions()
end

function ForgeNotifications:OnNotificationTimer()
	if #self.tNotifications == 0 then 
		Apollo.StopTimer("NotificationTimer")
		return 
	end
	
	for k, v in pairs(self.tNotifications) do
		if not v then
			table.remove(self.tNotifications, k)
			
			self.wndHolder:ArrangeChildrenVert(2)
		else
			local tData = v:GetData()
			
			tData.fDuration = tData.fDuration - 0.1
			if tData.fDuration <= 0 then
				v:Show(false)
				v:Destroy()
				table.remove(self.tNotifications, k)
				
				self.wndHolder:ArrangeChildrenVert(2)
			end
		end
	end
end

-- comm - version checking
fnIsNewVersion = function(strHash, strSender, tParams)
	if not bCheckedForVersion then
		Inst:API_ShowNotification(self, "New version", "New version of ForgeUI is available on curse.com!", 10)
		ForgeUI.wndMain:FindChild("NewVersion"):Show(true)
	end

	bCheckedForVersion = true
end

function ForgeNotifications:CheckForVersions()
	ForgeUI:SendMessage("func", { strKey = "VersionCheck", tParams = { nVersion = ForgeUI.nVersion }})
end

fnVersionCheck = function(strHash, strSender, tParams)
	if tParams.nVersion < ForgeUI.nVersion then
		ForgeUI:SendPrivateMessage(strSender, "func", { strKey = "IsNewVersion" })
	end
end

-- api
function ForgeNotifications:API_ShowNotification(tAddon, strTitle, strText, fDuration, strCallback)
	local wndNotification = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Notification", self.wndHolder, self)
	
	local tData = {}
	tData.tAddon = tAddon
	tData.strCallback = strCallback
	tData.fDuration = fDuration or ForgeUI.tSettings.fNotificationDuration
	
	if strTitle then wndNotification:FindChild("Title"):SetText(strTitle) end
	if strText then wndNotification:FindChild("Text"):SetText(strText) end
	
	wndNotification:FindChild("CloseButton"):AddEventHandler("ButtonSignal", "OnCloseButtonSignal", self)
	
	wndNotification:SetData(tData)
	
	table.insert(self.tNotifications, wndNotification)
	
	Sound.Play(180)
	
	self.wndHolder:ArrangeChildrenVert(2)
	
	Apollo.StartTimer("NotificationTimer")
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_Notification Functions
---------------------------------------------------------------------------------------------------
function ForgeNotifications:OnCloseButtonSignal( wndHandler, wndControl )
	if not wndControl:GetName() == "CloseButton" then return end
	
	wndNotification = wndControl:GetParent():GetParent():GetParent()
	
	wndNotification:Show(false)
	
	self.wndHolder:ArrangeChildrenVert(2)
end

Inst = ForgeNotifications:new()
Apollo.RegisterPackage(Inst, MAJOR, MINOR, {})