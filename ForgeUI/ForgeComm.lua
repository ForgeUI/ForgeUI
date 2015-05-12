require "ICComm"

local ForgeUI = Apollo.GetAddon("ForgeUI")

-- libraries
local LibJSON

-- variables
local ForgeComm

local tFunctions = {}

local tSentMessages = {}
local tReceivedMessages = {}
local tErrorMessages = {}

-- functions
local fnCreateMessage
local fnReceivedMessage
local fnReturnVersion

function ForgeUI:InitComm()
	LibJSON = Apollo.GetPackage("Lib:dkJSON-2.5").tPackage

	ForgeComm = ICCommLib.JoinChannel("ForgeUI", ICCommLib.CodeEnumICCommChannelType.Global);
	
	ForgeComm:SetSendMessageResultFunction("OnMessageSent", self)
	ForgeComm:SetReceivedMessageFunction("OnMessageReceived", self)
	
	self:CommAPI_RegisterFunction("ReturnVersion", fnReturnVersion)
end

function ForgeUI:OnMessageSent(iccomm, eResult, idMessage)
	if not self.tSettings.bNetworking then return end
	
	self:Debug("ForgeComm [sent]: " .. tSentMessages[idMessage].strMessage)
	
	tSentMessages[idMessage].bSent = true
	
	if self.tSettings.bNetworkLoop then
		self:OnMessageReceived(ForgeComm, tSentMessages[idMessage].strMessage, GameLib.GetPlayerUnit():GetName())
	end
end

function ForgeUI:OnMessageReceived(iccomm, strMessage, strSender)
	if not self.tSettings.bNetworking or not strMessage then return end

	self:Debug("ForgeComm [received]: " .. strMessage)
	
	fnReceivedMessage(strMessage)
end

function ForgeUI:SendMessage(strType, tBody)
	if not self.tSettings.bNetworking then return end

	local tMessage = fnCreateMessage(strType, tBody)
	
	if tMessage then
		self:Debug("ForgeComm [queue]: " .. tMessage.strMessage)
	end
end

function ForgeUI:SendPrivateMessage(strTarget, strType, tBody)
	if not self.tSettings.bNetworking then return end

	local tMessage = fnCreateMessage(strType, tBody, strTarget)
	
	if tMessage then
		self:Debug("ForgeComm [queue]: " .. tMessage.strMessage)
	end
end

-- api
function ForgeUI:CommAPI_RegisterFunction(strKey, fnFunction)
	tFunctions[strKey] = fnFunction
end

-- local functions for security
fnCreateMessage = function(strType, tBody, strTarget)
	if not strType or not tBody or not GameLib.GetPlayerUnit() then return end

	local strSender = GameLib.GetPlayerUnit():GetName()
	local strHash = ForgeUI.MakeString(8)
	
	local tMessage = {
		_strSender = strSender,
		_strHash = strHash,
		strType = strType,
		tBody = tBody,
	}
	
	local strMessage = LibJSON.encode(tMessage)
	local id
	
	if strTarget then
		id = ForgeComm:SendPrivateMessage(strTarget, strMessage)
	else
		id = ForgeComm:SendMessage(strMessage)
	end
	
	tSentMessages[id] = {
		_id = id,
		_strHash = strHash,
		strTarget = strTarget,
		bSent = false,
		strMessage = strMessage,
	}
	
	return tSentMessages[id]
end

fnReceivedMessage = function(strMessage)
	if not strMessage then return end
	
	local tMessage = LibJSON.decode(strMessage)
	
	if not tMessage or not tMessage._strHash or not tMessage._strSender or not tMessage.strType then
		ForgeUI:Debug("ForgeComm [err-format]: " .. strMessage, "FFFF0000")
		table.insert(tErrorMessages, strMessage)
		return
	end
	
	tReceivedMessages[tMessage._strHash] = {
		_strHash = tMessage._strHash,
		_strSender = tMessage._strSender,
		strType = tMessage.strType,
		tBody = tMessage.tBody,
	}
	
	local tBody = tMessage.tBody
	
	if tMessage.strType == "print" then
		ForgeUI:Print(tostring(tBody.strText))
	elseif tMessage.strType == "func" then
		if tFunctions[tostring(tBody.strKey)] then
			tFunctions[tostring(tBody.strKey)](tMessage._strHash, tMessage._strSender, tBody.tParams)
		end
	end
end

-- net functions
fnReturnVersion = function(strHash, strSender, tParams)
	if not GameLib.GetPlayerUnit() then return end
	
	local strPlayerName = GameLib.GetPlayerUnit():GetName()
	local strVersion = ForgeUI.sVersion

	ForgeUI:SendPrivateMessage(strSender, "print", { strText = "ForgeComm [returnVersion]: " ..  strPlayerName .. " | " .. strVersion })
end

-- debug functions
function ForgeUI:DebugMessages()
	self:Debug(" --- sent messages ---")
	for k, v in pairs(tSentMessages) do
		self:Debug("[" .. tostring(k) .. ", " .. tostring(v.strTarget) .. ", " .. tostring(v.bSent) .."] " .. v.strMessage)
	end
	self:Debug(" --- received messages ---")
	for k, v in pairs(tReceivedMessages) do
		self:Debug("[" .. tostring(k) .. ", " .. tostring(v.strTarget) .. ", " .. tostring(v.bSent) .."] " .. tostring(v.strMessage))
	end
	self:Debug(" --- error messages ---")
	for k, v in pairs(tErrorMessages) do
		self:Debug("[" .. k .. "] " .. v)
	end
end


