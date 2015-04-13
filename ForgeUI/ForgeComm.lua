require "ICComm"

local LibJSON

local ForgeUI = Apollo.GetAddon("ForgeUI")

local tMessageFormat = {
	strAuthor = "",
	strMessageSign = "",
	tMessage = {}
}

function ForgeUI:InitComm()
	LibJSON = Apollo.GetPackage("Lib:dkJSON-2.5").tPackage

	self.icComm = ICCommLib.JoinChannel("ForgeUI", ICCommLib.CodeEnumICCommChannelType.Global);
	
	self.icComm:SetSendMessageResultFunction("OnMessageSent", self)
	self.icComm:SetReceivedMessageFunction("OnMessageReceived", self);
end

function ForgeUI:OnMessageSent(iccomm, eResult, idMessage)

end

function ForgeUI:OnMessageReceived(channel, strMessage, idMessage)
	local tMsg = LibJSON.decode(strMessage)
	
	if tMsg.strMessageSign == "command" then
		if tMsg.tMessage.strCommand == "returnVersion" then
			local tNewMsg = {
				author = GameLib.GetPlayerUnit():GetName(),
				strMessageSign = "print",
				tMessage = {
					strText = GameLib.GetPlayerUnit():GetName() .. " - " .. ForgeUI.version
				}
			}
			
			self.icComm:SendPrivateMessage(tMsg.strAuthor, LibJSON.encode(tNewMsg))
		end
	elseif tMsg.strMessageSign == "print" then
		Print(tMsg.tMessage.strText)
	end
end

function ForgeUI:SendMessage(strMsgSign, tMsg)
	local tMessage = {
		strAuthor = GameLib.GetPlayerUnit():GetName(),
		strMessageSign = strMsgSign,
		tMessage = {
			strCommand = "returnVersion"
		}
	}
	
	strMessage = LibJSON.encode(tMessage)
	self.icComm:SendMessage(strMessage)
end


