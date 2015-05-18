-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		profiles.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI profiles library
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- ForgeUI Library Definition
-----------------------------------------------------------------------------------------------
local Profiles = {}

-----------------------------------------------------------------------------------------------
-- ForgeUI Library Initialization
-----------------------------------------------------------------------------------------------
local new = function(self, o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	
	
	
	return o
end

-----------------------------------------------------------------------------------------------
-- Local variables
-----------------------------------------------------------------------------------------------
local strPlayerName
local strActiveProfile

-----------------------------------------------------------------------------------------------
-- Profiles functions
-----------------------------------------------------------------------------------------------
function Profiles:AfterRestore(tForgeSavedData)
	strPlayerName = GameLib.GetPlayerUnit():GetName()
	
	if not tForgeSavedData.tGeneral._tInfo[strPlayerName] then
		tForgeSavedData.tGeneral._tInfo[strPlayerName] = {}
		tForgeSavedData.tGeneral._tInfo[strPlayerName].strActiveProfile = strPlayerName
		strActiveProfile = strPlayerName
	else
		strActiveProfile = tForgeSavedData.tGeneral._tInfo[strPlayerName].strActiveProfile
	end
end

function Profiles:OnSave(tForgeSavedData)
	tForgeSavedData.tGeneral._tInfo[strPlayerName] = {
		strActiveProfile = strActiveProfile,
	}
end

-----------------------------------------------------------------------------------------------
-- Profiles public API functions
-----------------------------------------------------------------------------------------------
function Profiles:API_GetProfile(tData)
	if tData.tProfiles[strActiveProfile] then
		return tData.tProfiles[strActiveProfile]
	else
		tData.tProfiles[strActiveProfile] = {}
		return tData.tProfiles[strActiveProfile]
	end
end

_G["ForgeLibs"][5] = new(Profiles)

