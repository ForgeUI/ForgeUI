require "ICComm"

local MAJOR, MINOR = "ForgeComm", 1

local APkg = Apollo.GetPackage(MAJOR)
if APkg and (APkg.nVersion or 0) >= MINOR then return end

local ForgeUI = Apollo.GetAddon("ForgeUI")
local ForgeComm = {}

function ForgeComm:OnMessageSent(iccomm, eResult, idMessage)

end

function ForgeComm:OnMessageReceived(channel, strMessage, idMessage)
	if strMessage == "returnVersion" then
		self:ReturnVersion()
	end
end

function ForgeComm:ReturnVersion()
	self.icComm.SendPrivateMessage("Winty Badass@Jabbit", GameLib.GetPlayerUnit():GetName() .. " - " .. ForgeUI.version) 
end

function ForgeComm:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	
	-- CComLib
	o.icComm = ICCommLib.JoinChannel("ForgeUI", ICCommLib.CodeEnumICCommChannelType.Global);
	
	o.icComm:SetSendMessageResultFunction("OnMessageSent", self)
	o.icComm:SetReceivedMessageFunction("OnMessageReceived", self)
	
	return o
end

Apollo.RegisterPackage(ForgeComm:new(), MAJOR, MINOR, {})
