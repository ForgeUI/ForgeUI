-----------------------------------------------------------------------------------------------
-- Client Lua Script for ForgeUI
--
-- name: 		util.lua
-- author:		Winty Badass@Jabbit
-- about:		ForgeUI util libraries
-----------------------------------------------------------------------------------------------

local F, A, M, G = unpack(_G["ForgeLibs"]) -- imports ForgeUI, Addon, Module, GUI

local Util = {}

local WildShell = WildShell

-----------------------------------------------------------------------------------------------
-- Local variables
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- ForgeUI module functions
-----------------------------------------------------------------------------------------------
function Util:ForgeAPI_Init()
	
end

function Util:Debug(strKey, strText, crText)
	if not self.tSettings.bDebug or not WildShell then return end
	
	if crText then
		WildShell:Debug(strKey, strText, crText)
	else
		WildShell:Debug(strKey, strText, "FFBBBBBB")
	end
end

function Util:Print(strKey, strText)
	if not WildShell then return end
	
	WildShell:Debug(strKey, strText, "FF98C723")
end


function Util:CopyTable(tNew, tOld)
	if tOld == nil then return end
	if tNew == nil then
		tNew = {}
	end
	
	for k, v in pairs(tOld) do
		if type(v) == "table" then
			tNew[k] = self:CopyTable(tNew[k], v)
		else
			tNew[k] = v
		end
	end
	return tNew
end

function Util:ShortNum(num)
	local tmp = tostring(num)
    if not num then
        return 0
    elseif num >= 1000000 then
        ret = string.sub(tmp, 1, string.len(tmp) - 6) .. "." .. string.sub(tmp, string.len(tmp) - 5, string.len(tmp) - 5) .. "M"
    elseif num >= 1000 then
        ret = string.sub(tmp, 1, string.len(tmp) - 3) .. "." .. string.sub(tmp, string.len(tmp) - 2, string.len(tmp) - 2) .. "k"    else
        ret = num -- hundreds
    end
    return ret
end

function Util:FormatDuration(tim)
	if tim == nil then return end 
	if (tim>86400) then
		return ("%.0fd"):format(tim/86400)
	elseif (tim>3600) then
		return ("%.0fh"):format(tim/3600)
	elseif (tim>60) then
		return ("%.0fm"):format(tim/60)
	elseif (tim>5) then
		return ("%.0fs"):format(tim)
	elseif (tim>0) then
		return ("%.1fs"):format(tim)
	elseif (tim==0) then
		return ""
	end
end

function Util:GetTime()
	local l_time = GameLib.GetLocalTime()

	if ForgeUIInst.tSettings.b24HourFormat then
		return string.format("%02d:%02d", l_time.nHour, l_time.nMinute)	
	else
		if l_time.nHour > 12 then
			return string.format("%02d:%02d", l_time.nHour - 12, l_time.nMinute)
		else
			if l_time.nHour == 0 then
				return string.format("%02d:%02d", l_time.nHour + 12, l_time.nMinute)
			else
				return string.format("%02d:%02d", l_time.nHour, l_time.nMinute)
			end
		end
	end
end

function Util:Round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function Util:ConvertAlpha(value)	
	return string.format("%02X", math.floor(value * 255 + 0.5))
end

function Util:GenerateGradient(strColorStart, strColorEnd, nSteps, nStep, bAlpha)
	local colorBegin
	local colorEnd

	if bAlpha then
		colorBegin = string.sub(strColorStart, 3, 8)
		colorEnd = string.sub(strColorEnd, 3, 8)
	else
		colorBegin = strColorStart
		colorEnd = strColorEnd
	end
	
	local colorR0 = tonumber(string.sub(colorBegin, 1, 2), 16)
	local colorG0 = tonumber(string.sub(colorBegin, 3, 4), 16)
	local colorB0 = tonumber(string.sub(colorBegin, 5, 6), 16)
  	
	local colorR1 = tonumber(string.sub(colorEnd, 1, 2), 16)
	local colorG1 = tonumber(string.sub(colorEnd, 3, 4), 16)
	local colorB1 = tonumber(string.sub(colorEnd, 5, 6), 16)

	local colorR = ((colorR1 - colorR0) / nSteps * nStep) + colorR0
	local colorG = ((colorG1 - colorG0) / nSteps * nStep) + colorG0
	local colorB = ((colorB1 - colorB0) / nSteps * nStep) + colorB0
	
    if bAlpha then
        return string.format("FF%02x%02x%02x", colorR, colorG, colorB)
    else
	   return string.format("%02x%02x%02x", colorR, colorG, colorB)
    end
end

function Util:MakeString(l)
    if l < 1 then return nil end
    local s = ""
    for i = 1, l do
        n = math.random(97, 122)
        s = s .. string.char(n)
    end
    return s
end

Util = F:API_NewModule(Util, "util", { bGlobal = true })
