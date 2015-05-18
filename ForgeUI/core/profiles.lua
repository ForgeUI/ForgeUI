-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		profiles.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI profiles library
-----------------------------------------------------------------------------------------------

local F, A, M, G, P = unpack(_G["ForgeLibs"]) -- imports ForgeUI, Addon, Module, GUI, Profiles

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
local strNewProfile
local strRemoveProfile

local tProfiles = {}

-----------------------------------------------------------------------------------------------
-- Profiles functions
-----------------------------------------------------------------------------------------------
function Profiles:AfterRestore(tForgeSavedData)
	strPlayerName = GameLib.GetPlayerUnit():GetName()
	
	if not tForgeSavedData.tGeneral._tInfo[strPlayerName] then
		tForgeSavedData.tGeneral._tInfo[strPlayerName] = {}
		tForgeSavedData.tGeneral._tInfo[strPlayerName].strActiveProfile = "Default - " .. strPlayerName
		strActiveProfile = "Default - " .. strPlayerName
	else
		strActiveProfile = tForgeSavedData.tGeneral._tInfo[strPlayerName].strActiveProfile
		
		for k, v in pairs(tForgeSavedData.tGeneral.tProfiles) do
			tProfiles[k] = k
		end
	end
	
	tProfiles[strActiveProfile] = strActiveProfile
	
	strNewProfile = strActiveProfile
end

function Profiles:OnSave(tForgeSavedData)
	if strRemoveProfile then
		tForgeSavedData.tGeneral.tProfiles[strRemoveProfile] = nil
		tForgeSavedData.tCharacter.tProfiles[strRemoveProfile] = nil
		
		tForgeSavedData.tGeneral._tInfo[strPlayerName] = {
			strActiveProfile = "Default - " .. strPlayerName,
		}
	else
		tForgeSavedData.tGeneral._tInfo[strPlayerName] = {
			strActiveProfile = strNewProfile,
		}
	end
end

-----------------------------------------------------------------------------------------------
-- Profiles public API functions
-----------------------------------------------------------------------------------------------
function Profiles:API_GetProfile(tData)
	if strActiveProfile == strRemoveProfile then return {} end

	if tData.tProfiles[strActiveProfile] then
		return tData.tProfiles[strActiveProfile]
	else
		tData.tProfiles[strActiveProfile] = {}
		return tData.tProfiles[strActiveProfile]
	end
end

function Profiles:API_ChangeProfile(strProfile)
	strNewProfile = strProfile
	F:Save()
end

function Profiles:API_RemoveProfile(strProfile)
	strRemoveProfile = strProfile
	F:Save()
end

function Profiles:API_GetProfileName()
	return strActiveProfile
end

function Profiles:API_GetProfiles()
	return tProfiles
end

_G["ForgeLibs"][5] = new(Profiles)

