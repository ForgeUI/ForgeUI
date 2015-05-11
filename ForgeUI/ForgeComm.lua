require "ICComm"

local LibJSON

local ForgeUI = Apollo.GetAddon("ForgeUI")

function ForgeUI:InitComm()
	LibJSON = Apollo.GetPackage("Lib:dkJSON-2.5").tPackage

	self.icComm = ICCommLib.JoinChannel("ForgeUI", ICCommLib.CodeEnumICCommChannelType.Global);
	
	self.icComm:SetSendMessageResultFunction("OnMessageSent", self)
	self.icComm:SetReceivedMessageFunction("OnMessageReceived", self);
end

function ForgeUI:OnMessageSent(iccomm, eResult, idMessage)
	if not self.tSettings.bNetworking then return end

	-- debug
	self:Debug("ForgeComm - message sent: " .. idMessage)
end

function ForgeUI:OnMessageReceived(channel, strMessage, idMessage)
	if not self.tSettings.bNetworking then return end

	-- debug
	self:Debug("ForgeComm - message received: " .. idMessage .. " - " .. strMessage)
	
	local tMessage = LibJSON.decode(strMessage)
	local tMsg = tMessage.tMsg
	
	if tMessage.strSign == "cmd" then
		if not tMsg.strCommand then return end
		
		if tMsg.strCommand == "returnVersion" then
			self:SendPrivateMessage(tMessage.strAuthor, idMessage, "print", { strText = "ForgeComm [returnVersion] - " .. GameLib.GetPlayerUnit():GetName() .. " - " .. ForgeUI.sVersion })
		elseif tMsg.strCommand == "getNewerVersion" then
			if tMsg.nVersion < self.nVersion then
				self:SendPrivateMessage(tMessage.strAuthor, idMessage, "func", { strFunc = "IsNewVersion" })	
			end
		end
	elseif tMessage.strSign == "print" then
		self:Print(tMsg.strText)
	elseif tMessage.strSign == "func" then
		if ForgeUI[tMsg.strFunc] then
			ForgeUI[tMsg.strFunc]()
		end
	end
end

function ForgeUI:SendMessage(strSign, tMsg)
	if not self.tSettings.bNetworking then return end

	local tMessage = {
		strAuthor = GameLib.GetPlayerUnit():GetName(),
		strSign = strSign,
		tMsg = tMsg
	}
	
	strMessage = LibJSON.encode(tMessage)
	
	self.icComm:SendMessage(strMessage)
	
	if self.tSettings.bNetworkLoop then
		self:OnMessageReceived(self.icComm, strMessage, -1)
	end
end

function ForgeUI:SendPrivateMessage(strPlayer, idMessage, strSign, tMsg)
	if not self.tSettings.bNetworking then return end

	local tMessage = {
		strAuthor = GameLib.GetPlayerUnit():GetName(),
		idMessage = idMessage,
		strSign = strSign,
		tMsg = tMsg
	}
	
	strMessage = LibJSON.encode(tMessage)
	
	self.icComm:SendPrivateMessage(strPlayer, strMessage)
	
	if self.tSettings.bNetworkLoop then
		self:OnMessageReceived(self.icComm, strMessage, -1)
	end
end


