-- Client lua script
require "Window"
require "Apollo"
require "DialogSys"
require "Quest"
require "MailSystemLib"
require "Sound"
require "GameLib"
require "Tooltip"
require "XmlDoc"
require "PlayerPathLib"
require "CommunicatorLib"
require "MatchingGame"

local ForgeUI
local ForgeUI_Datachron = {}

local kstrModeLabelZone = Apollo.GetString("CRB_Zone_Objectives")
local kstrModeLabelInterface = Apollo.GetString("CRB_Interfaces")

local kcrTitleEnabled = CColor.new(49/255, 252/255, 246/255, 1)
local kcrTitleDisabled = CColor.new(128/255, 64/255, 64/255, 1)
local kcrBodyEnabled = CColor.new(47/255, 148/255, 172/255, 1)
local kcrBodyDisabled = CColor.new(128/255, 0/255, 0/255, 1)

local knSaveVersion = 1

function ForgeUI_Datachron:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	-- mandatory 
    self.api_version = 2
	self.version = "0.1.0"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_Datachron"
	self.strDisplayName = "Datachron"
	
	self.wndContainers = {}
	
	-- optional
	self.tSettings = {

	}
	
	o.wndMain = nil
	o.strZoneName = nil
	o.idCreature = nil
	o.idState = nil

	o.idSpamMsg = 0
	o.bMaximized = false

	return o
end

function ForgeUI_Datachron:Init()
	Apollo.RegisterAddon(self, false, nil, {"ForgeUI", "PathExplorerContent", "PathScientistContent", "PathSettlerContent", "PathSoldierContent", "MatchTracker", "QuestTracker"})
end

function ForgeUI_Datachron:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("ForgeUI_Datachron.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self) 
end

function ForgeUI_Datachron:OnDocumentReady()
	if self.xmlDoc == nil then
		return
	end
	
	if ForgeUI == nil then -- forgeui loaded
		ForgeUI = Apollo.GetAddon("ForgeUI")
	end
	
	ForgeUI.API_RegisterAddon(self)
end

function ForgeUI_Datachron:ForgeAPI_AfterRegistration()
	Apollo.RegisterSlashCommand("datachron", "OnDatachronOn", self)
	
	Apollo.RegisterEventHandler("Datachron_HideCallPulse", 			"OnDatachron_HideCallPulse", self)

	Apollo.RegisterEventHandler("ChangeWorld", 						"OnChangeWorld", self) -- From code
	Apollo.RegisterEventHandler("SetPlayerPath", 					"SetPath", self) -- From code

	-- Events
	Apollo.RegisterEventHandler("GenericEvent_RestoreDatachron", 	"OnGenericEvent_RestoreDatachron", self)
	Apollo.RegisterEventHandler("Communicator_ShowSpamMsg", 		"OnCommShowSpamMsg", self)
	Apollo.RegisterEventHandler("ShowResurrectDialog", 				"OnShowResurrectDialog", self)
	Apollo.RegisterEventHandler("PlayerResurrected", 				"OnPlayerResurrected", self)
	Apollo.RegisterEventHandler("CommDisplay_Closed", 				"OnCommDisplay_Closed", self) -- Comm Display X button clicked
	Apollo.RegisterEventHandler("QuestStateChanged", 				"OnQuestStateChanged", self) -- Currently for Comm Queue only
	Apollo.RegisterEventHandler("Dialog_ShowState", 				"OnDialog_ShowState", self) -- Talking to an NPC
	Apollo.RegisterEventHandler("Dialog_Close", 					"OnDialog_Close", self) -- Speech Bubble Close clicked
	Apollo.RegisterEventHandler("Tutorial_RequestUIAnchor", 		"OnTutorial_RequestUIAnchor", self)
	
	Apollo.RegisterEventHandler("Communicator_EndIncoming", 		"OnCommunicator_EndIncoming", self) -- This is a missed call
	Apollo.RegisterEventHandler("Communicator_SpamVOEnded", 		"OnCommunicator_SpamVOEnded", self)
	Apollo.RegisterEventHandler("Communicator_ShowQuestMsg", 		"OnCommunicator_ShowQuestMsg", self)

	self.timerMissedCall = ApolloTimer.Create(60.0, false, "Datachron_MaxMissedCallTimer", self)
	self.timerMissedCall:Stop()
	
	self.timerNPCBubbleFade = ApolloTimer.Create(9.500, false, "OnNpcBubbleFade", self)
	self.timerNPCBubbleFade:Stop()

	g_wndDatachron 			= Apollo.LoadForm(self.xmlDoc, "ForgeUI_Datachron", "FixedHudStratum", self) -- Do not rename. This is global and used by other forms as a parent.
	g_wndDatachron:Show(false, true)
	
	ForgeUI.API_RegisterWindow(self, g_wndDatachron, "ForgeUI_Datachron", { strDisplayName = "Datachron" })

	self.wndMinimized 		= Apollo.LoadForm(self.xmlDoc, "MinimizedState", "FixedHudStratum", self)
	self.wndZoneNameMin	 	= self.wndMinimized:FindChild("ZoneNameMin")

	-- ForgeUI_Datachron Modes
	self.wndPathContainer 			= g_wndDatachron:FindChild("PathContainer")
	self.wndPathContainerTopLevel 	= g_wndDatachron:FindChild("PathContainerTopLevel")

	self.bSoldierLoaded = false
	self.bSettlerLoaded = false
	self.bExplorerLoaded = false
	self.bScientistLoaded = false
	self.bHoldoutLoaded = false

	self.strCurrentState = nil -- SpamOngoing, MissedCall, NoCalls, DialogOngoing, IncomingOngoing, CommQueueAvail

	self.tQueuedSpamMsgs = {}

	self.wndZoneNameMin:SetText(kstrModeLabelZone)

	self.bIncomingOngoing = false -- TODO Get rid of this when the missed event no longer fires at the start
	self.tListOfDeniedCalls = {}
	-- End Call System

	self:SetPath()

	if self.bMaximized then
		self:OnRestoreDatachron()
	else
		self:OnMinimizeDatachron()
	end

	self:ProcessDatachronState()

	Event_FireGenericEvent("Datachron_LoadPvPContent")
end

function ForgeUI_Datachron:SetPath()
	local unitPlayer = GameLib:GetPlayerUnit()
	if not unitPlayer then
		return
	end

	local ePathType = PlayerPathLib:GetPlayerPathType()
	if self.wndPathContainerTopLevel then
		self.wndPathContainerTopLevel:Show(ePathType == PlayerPathLib.PlayerPathType_Scientist)
	end

	-- TODO REFACTOR
	if ePathType ~= PlayerPathLib.PlayerPathType_Soldier then
		if self.bHoldoutLoaded == false then
			self.bHoldoutLoaded = true
			Event_FireGenericEvent("Datachron_LoadQuestHoldoutContent")
		else
			Event_FireGenericEvent("Datachron_ToggleHoldoutContent", true)
		end

		if ePathType == PlayerPathLib.PlayerPathType_Explorer then
			if self.bExplorerLoaded == false then
				self.bExplorerLoaded = true
				Event_FireGenericEvent("Datachron_LoadPathExplorerContent")
			end
			Event_FireGenericEvent("Datachron_TogglePathContent", PlayerPathLib.PlayerPathType_Explorer)
		elseif ePathType == PlayerPathLib.PlayerPathType_Scientist then
			if self.bScientistLoaded == false then
				self.bScientistLoaded = true
				Event_FireGenericEvent("Datachron_LoadPathScientistContent")
			end
			Event_FireGenericEvent("Datachron_TogglePathContent", PlayerPathLib.PlayerPathType_Scientist)
		elseif ePathType == PlayerPathLib.PlayerPathType_Settler then
			if self.bSettlerLoaded == false then
				self.bSettlerLoaded = true
				Event_FireGenericEvent("Datachron_LoadPathSettlerContent")
			end
			Event_FireGenericEvent("Datachron_TogglePathContent", PlayerPathType_Settler)
		else
			return
		end
	else
		Event_FireGenericEvent("Datachron_ToggleHoldoutContent", false)

		if self.bSoldierLoaded == false then
			self.bSoldierLoaded = true
			Event_FireGenericEvent("Datachron_LoadPathSoldierContent")
		end
		Event_FireGenericEvent("Datachron_TogglePathContent", PlayerPathLib.PlayerPathType_Soldier)
	end
end

---------------------------------------------------------------------------------------------------
-- Maximize/Minimize
---------------------------------------------------------------------------------------------------

function ForgeUI_Datachron:OnGenericEvent_RestoreDatachron()
	if not g_wndDatachron:IsShown() then
		self:OnRestoreDatachron()
	end
end

function ForgeUI_Datachron:OnMinimizeDatachron()
	self.wndMinimized:FindChild("DisableCommBtnMin"):SetCheck(false)
	self.wndMinimized:FindChild("DisableCommBtnMin"):SetTooltip(Apollo.GetString("Datachron_Maximize"))

	g_wndDatachron:Show(false)
	Event_FireGenericEvent("DatachronMinimized")
	g_wndDatachron:FindChild("QueuedCallsContainer"):Show(false)

	Sound.Play(Sound.PlayUI38CloseRemoteWindowDigital)
end

function ForgeUI_Datachron:OnRestoreDatachron()
	self.wndMinimized:FindChild("DisableCommBtnMin"):SetCheck(true)
	self.wndMinimized:FindChild("DisableCommBtnMin"):SetTooltip(Apollo.GetString("CRB_Datachron_MinimizeBtn_Desc"))

	g_wndDatachron:Show(true)
	Event_FireGenericEvent("DatachronRestored")

	Sound.Play(Sound.PlayUI37OpenRemoteWindowDigital)
end

---------------------------------------------------------------------------------------------------
-- Tutorial anchor request
---------------------------------------------------------------------------------------------------

function ForgeUI_Datachron:OnTutorial_RequestUIAnchor(eAnchor, idTutorial, strPopupText)
	if eAnchor ~= GameLib.CodeEnumTutorialAnchor.ForgeUI_Datachron then return end

	local tRect = {}
	if self.wndMinimized:IsShown() then
		tRect.l, tRect.t, tRect.r, tRect.b = self.wndMinimized:GetRect()
	else
		tRect.l, tRect.t, tRect.r, tRect.b = g_wndDatachron:GetRect()
	end

	Event_FireGenericEvent("Tutorial_RequestUIAnchorResponse", eAnchor, idTutorial, strPopupText, tRect)
end

---------------------------------------------------------------------------------------------------
-- Call System
---------------------------------------------------------------------------------------------------

function ForgeUI_Datachron:OnCommPotraitClicked()
	self:OnCommPlayBtn() -- From Comm Display
end

function ForgeUI_Datachron:HideCommDisplay()
	Event_FireGenericEvent("HideCommDisplay")
	self.idCreature = nil
	self:DrawCallSystem()
end

function ForgeUI_Datachron:SetCommunicatorCreature(idCreature)
	self.idCreature = idCreature
	if self.idCreature ~= 0 then
		local strCreatureName = Creature_GetName(self.idCreature)

		if strCreatureName == nil then
			strCreatureName = Apollo.GetString("Datachron_UnknownCreature")
		end

		self.wndMinimized:FindChild("IncomingCreatureNameMin"):SetText(strCreatureName)
	end
end

---------------------------------------------------------------------------------------------------
-- Event Routing for Call System
---------------------------------------------------------------------------------------------------

function ForgeUI_Datachron:OnShowResurrectDialog()
	self:DrawCallSystem("TurnOffButtons")
end

function ForgeUI_Datachron:OnPlayerResurrected()
	self:ProcessDatachronState()
end

function ForgeUI_Datachron:OnDialog_Close() -- User clicks done in the dialog speech bubbles
	self.timerNPCBubbleFade:Stop()

	if next(self.tQueuedSpamMsgs) ~= nil then
		self:HideCommDisplay()
		self:ProcessDatachronState()
	else
		self.timerNPCBubbleFade = ApolloTimer.Create(9.500, false, "OnNpcBubbleFade", self)
	end
end

function ForgeUI_Datachron:OnNpcBubbleFade()
	-- NPC bubble fades out
	self:HideCommDisplay()
	if self.idSpamMsg ~= 0 then
		CommunicatorLib.QueueNextCall(self.idSpamMsg)
	end
	self:ProcessDatachronState()
end

function ForgeUI_Datachron:OnCommDisplay_Closed()
	-- User clicks x button on the comm display
	self.timerNPCBubbleFade:Stop()
	self:HideCommDisplay()
	if self.idSpamMsg ~= 0 then
		CommunicatorLib.QueueNextCall(self.idSpamMsg)
	end
	self:ProcessDatachronState()
end

function ForgeUI_Datachron:OnCommunicator_SpamVOEnded()
	if self.strCurrentState == "SpamOngoing" then
		self:DrawCallSystem("SpamEnd")
	end
end

function ForgeUI_Datachron:OnCommunicator_EndIncoming()
	 -- Only do stuff if this end event comes when there is an incoming to end

	if self.bIncomingOngoing then
		-- Run off queued spam when an end event comes before going to missed
		if #self.tQueuedSpamMsgs > 0 then
			self:ProcessSpamQueue()
		end

		-- After running off spam see if we can go into missed
		self:DrawCallSystem(self:BuildCallbackList() and "MissedCall" or "NoCalls")
	end
end

function ForgeUI_Datachron:OnDialog_ShowState(eState, queCurr) -- Talking to an NPC
	local idQuest = 0
	if queCurr then
		idQuest = queCurr:GetId()
	end -- TODO guard for nil better

	local tResponseList = DialogSys.GetResponses(idQuest)
	if tResponseList == nil or #tResponseList == 0 or eState == DialogSys.DialogState_Inactive then
		self:ProcessDatachronState()
	end

	local idCreature = DialogSys.GetCommCreatureId()

	if idCreature == nil then
		self:ProcessDatachronState()
		return
	end

	if eState == DialogSys.DialogState_TopicChoice or
		 eState == DialogSys.DialogState_QuestAccept or
		 eState == DialogSys.DialogState_QuestComplete or
		 eState == DialogSys.DialogState_QuestIncomplete then

		self.strCurrentState = "DialogOngoing"

		self.timerNPCBubbleFade:Stop()

		local tLayout = nil
		if queCurr then
			tLayout = CommunicatorLib.GetMessageLayoutForQuest(queCurr)
		end

		Event_FireGenericEvent("CommDisplayQuestText", eState, idQuest, true, tLayout)

		self:SetCommunicatorCreature(idCreature)
		self:DrawCallSystem("TurnOffButtons")
		self:DrawCallSystem()
	else
		self:ProcessDatachronState()
	end
end

function ForgeUI_Datachron:OnCommunicator_ShowQuestMsg(idMsg, idCreature, queSource, strText)
	if self.strCurrentState == "DialogOngoing" then
		return -- don't interrupt an existing dialog
	end

	if self.strCurrentState == "IncomingOngoing" and self.idCreature == idCreature then
		return -- don't double show
	end

	if queSource:GetState() == Quest.QuestState_Achieved then
		return -- don't show for achieved quests that should go to the tracker
	end

	if self.strCurrentState == "SpamOngoing" then
		Event_FireGenericEvent("CloseCommDisplay") -- TODO Refactor this into HideCommDisplay
		Sound.Play(Sound.PlayUIDatachronEnd)
	end

	self.strCurrentState = "IncomingOngoing"

	self:SetCommunicatorCreature(idCreature)
	self:DrawCallSystem()

	if queSource and queSource:GetId() and queSource:GetId() ~= 0 then
		 -- For deny to put this quest into a deny queue
		self.wndMinimized:FindChild("CommCallDenyMin"):SetData(queSource:GetId())
	end
end

function ForgeUI_Datachron:OnCommShowSpamMsg(idMsg, idCreature, strText, bPriorty)
	local pmNew = CommunicatorLib.GetPathMissionDelivered(idMsg)  -- TODO: Remove once we no longer recieve unlock calls
	if pmNew then
		return false
	end 	 -- TODO: Remove once we no longer recieve unlock calls

	-- priority spam includes the goodbye message from givers. It needs to take priority over other spam messages, or else the goodbye can come in at a weird time.
	if bPriorty then
		table.insert(self.tQueuedSpamMsgs, 1, {idMsg, idCreature, strText})
	else
		table.insert(self.tQueuedSpamMsgs, {idMsg, idCreature, strText})
	end

	-- if we're not in any of these states, recalculate state
	if self.strCurrentState ~= "DialogOngoing" and self.strCurrentState ~= "IncomingOngoing"
		and self.strCurrentState ~= "SpamOngoing" then
		self:ProcessDatachronState()
	end
end

function ForgeUI_Datachron:OnQuestStateChanged()
	if self.strCurrentState == "CommQueueAvail" and g_wndDatachron:FindChild("QueuedCallsContainer"):IsShown() then
		-- Run Build List, and if empty process state
		if self:BuildCallbackList() == false then
			self:ProcessDatachronState()
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Simple UI Functions
---------------------------------------------------------------------------------------------------

function ForgeUI_Datachron:OnDatachron_HideCallPulse() -- One click hide from the HUD Interact, until a new state
	if self.wndMinimized and self.wndMinimized:IsValid() then -- Once you click it, it's gone until a new state.
		self.wndMinimized:FindChild("CommCallPulseMinBlue"):Show(false)
		self.wndMinimized:FindChild("CommCallPulseMinRed"):Show(false)
	end
end

function ForgeUI_Datachron:OnCommPlayBtn()
	-- This has both the queue open and play button functionality
	
	if self.strCurrentState ~= "CommQueueAvail" and self.strCurrentState ~= "MissedCall" then
		CommunicatorLib.CallbackLastContact()
		Event_HideQuestLog()
		return
	end

	if self.strCurrentState == "MissedCall" then -- Demote MissedCall to CommQueueAvail
		local bBuildCallbackList = self:BuildCallbackList()
		self:DrawCallSystem(bBuildCallbackList and "CommQueueAvail" or "NoCalls")
		if not bBuildCallbackList then
			return
		end
	end

	if not g_wndDatachron:IsShown() then -- Restores from minimized, as per spec
		self:OnRestoreDatachron()
	end

	self.wndMinimized:FindChild("CommCallPulseMinBlue"):Show(false)
	g_wndDatachron:FindChild("QueuedCallsContainer"):Show(not g_wndDatachron:FindChild("QueuedCallsContainer"):IsShown())
end

function ForgeUI_Datachron:OnDenyCallbackBtn(wndHandler, wndControl) -- CommCallDeny
	if wndHandler and wndHandler:GetData() then
		self.tListOfDeniedCalls[wndHandler:GetData()] = wndHandler:GetData()
	end

	if self.strCurrentState == "DialogOngoing" then
		Sound.Play(Sound.PlayUIDatachronEnd)
	end

	if self.strCurrentState == "SpamOngoing" then
		Event_FireGenericEvent("CloseCommDisplay")
		self.timerNPCBubbleFade:Stop()
		self:OnNpcBubbleFade() -- Warning, instead of going to NoCalls simulate a BubbleFade. Potentially hazardous.
		return
	end

	CommunicatorLib.IgnoreCallback()

	-- Update the callback list then go right into that state
	self:DrawCallSystem(self:BuildCallbackList() and "CommQueueAvail" or "NoCalls")
end

function ForgeUI_Datachron:OnQueuedCallsItemClick(wndHandler, wndControl)
	if wndHandler ~= wndControl or not wndHandler:GetParent() or not wndHandler:GetParent():GetData() then
		return
	end

	CommunicatorLib.CallContact(wndHandler:GetParent():GetData())

	if DialogSys.GetCommCreatureId() and Creature_GetName(DialogSys.GetCommCreatureId()) then
		self.wndMinimized:FindChild("IncomingCreatureNameMin"):SetText(Creature_GetName(DialogSys.GetCommCreatureId()))
	end

	self:DrawCallSystem("DialogOngoing")
end

function ForgeUI_Datachron:OnQueuedCallsIgnoreBtn(wndHandler, wndControl)
	if wndHandler ~= wndControl or not wndHandler:GetParent() or not wndHandler:GetParent():GetData() then
		return
	end

	local queQueued = wndHandler:GetParent():GetData()
	if queQueued then
		queQueued:ToggleIgnored()
	end
	-- OnQuestStateChanged will do redrawing as we have to wait after TogglingIgnore
end

function ForgeUI_Datachron:BuildCallbackList()
	local bResult = false
	g_wndDatachron:FindChild("QueuedCallsList"):DestroyChildren()

	local tCallbackList = Quest:GetCallbackList(true) -- Boolean is to show out leveled quests or not
	if tCallbackList == nil or #tCallbackList <= 0 then
		return false
	end

	for key, queCurr in ipairs(tCallbackList) do
		if queCurr:GetState() == Quest.QuestState_Mentioned then
			bResult = true

			local wndQCall = Apollo.LoadForm(self.xmlDoc, "QueuedCallsItem", g_wndDatachron:FindChild("QueuedCallsList"), self)
			wndQCall:SetData(queCurr)

			if self.tListOfDeniedCalls[queCurr:GetId()] ~= nil then
				wndQCall:FindChild("QueuedCallsTitle"):SetText(String_GetWeaselString(Apollo.GetString("Datachron_SkippedCall"), queCurr:GetTitle()))
			else
				wndQCall:FindChild("QueuedCallsTitle"):SetText(String_GetWeaselString(Apollo.GetString("Datachron_MissedCall"), queCurr:GetTitle()))
			end
		end
	end

	g_wndDatachron:FindChild("QueuedCallsList"):ArrangeChildrenVert(0)

	return bResult
end

---------------------------------------------------------------------------------------------------
-- The Main State Machine and Draw Method
---------------------------------------------------------------------------------------------------

function ForgeUI_Datachron:DrawCallSystem(strNewState)
	local strLocalState = self.strCurrentState

	if strNewState and strNewState ~= "" then
		if strNewState == nil or strNewState == "" then
			return
		else
			strLocalState = strNewState
			self.strCurrentState = strNewState
		end
	end

	self.bIncomingOngoing = false
	Event_FireGenericEvent("DatachronCallCleared")
	self.timerMissedCall:Stop()

	-- Super Huge State Machine
	local ktValidDenyEnable =
	{
		["IncomingOngoing"] = true,
		["SpamOngoing"] = true,
		["DialogOngoing"] = true,
		["SpamEnd"] = true,
	}

	local ktValidPlayEnable =
	{
		["IncomingOngoing"] = true,
		["CommQueueAvail"] = true,
		["MissedCall"] = true,
	}

	local ktValidIndicatorPulse =
	{
		["IncomingOngoing"] = "sprDC_GreenPulse",
		["CommQueueAvail"] = "sprDC_BluePulse",
		["MissedCall"] = "sprDC_RedPulse",
	}

	local ktValidPlaySprite =
	{
		["CommQueueAvail"] = "HUD_BottomBar:btn_HUD_Datachron_CallAvailable",
		["MissedCall"] = "HUD_BottomBar:btn_HUD_Datachron_CallMissed",
	}

	self.wndMinimized:FindChild("CommCallPulseMinRed"):Show(strLocalState == "MissedCall")
	self.wndMinimized:FindChild("CommCallPulseMinBlue"):Show(strLocalState == "CommQueueAvail")

	g_wndDatachron:FindChild("QueuedCallsContainer"):Show(false) -- Every action hides this menu, even dialog

	self.wndMinimized:FindChild("CommCallDenyMin"):Enable(ktValidDenyEnable[strLocalState])
	self.wndMinimized:FindChild("CommPlayBtnMin"):Enable(ktValidPlayEnable[strLocalState])
	self.wndMinimized:FindChild("CommPlayBtnMin"):ChangeArt(ktValidPlaySprite[strLocalState] or "HUD_BottomBar:btn_HUD_Datachron_CallPlay")

	-- Super Huge State Machine
	if strLocalState == "SpamEnd" then
		Event_FireGenericEvent("StopTalkingCommDisplay")
	elseif strLocalState == "CommQueueAvail" then
		self.wndMinimized:FindChild("IncomingCreatureNameMin"):SetText(Apollo.GetString("Datachron_CallsPending"))
	elseif strLocalState == "NoCalls" then
		self.tListOfDeniedCalls = {}
		self.wndMinimized:FindChild("IncomingCreatureNameMin"):SetText("")
	elseif strLocalState == "IncomingOngoing" then
		self.bIncomingOngoing = true
		Event_FireGenericEvent("DatachronCallIncoming")
	elseif strLocalState == "MissedCall" then
		Event_FireGenericEvent("DatachronCallMissed")
		self.timerMissedCall:Start()
		self.wndMinimized:FindChild("IncomingCreatureNameMin"):SetText(Apollo.GetString("Datachron_MissedCallTitle"))
	elseif strLocalState == "SpamOngoing" or strLocalState == "DialogOngoing" or strLocalState == "TurnOffButtons" then
		-- Do nothing (rely on default states)
	end
end

function ForgeUI_Datachron:ProcessDatachronState()
	-- This computes the state once we're 'done'
	-- If IncomingOngoing Delay -> Check Queued Spam -> Comm Queue Avail -> Go to No Calls

	if self.strCurrentState == "IncomingOngoing" then
		return
	elseif #self.tQueuedSpamMsgs > 0 then
		self:ProcessSpamQueue()
	elseif self:BuildCallbackList() then
		self:DrawCallSystem("CommQueueAvail")
	elseif self.strCurrentState ~= "NoCalls" then
		self:DrawCallSystem("NoCalls")
	end
end

function ForgeUI_Datachron:ProcessSpamQueue()
	if self.strCurrentState == "DialogOngoing" then
		self:HideCommDisplay()
	end

	local tSpamMsg = table.remove(self.tQueuedSpamMsgs, 1)
	local idMsg = tSpamMsg[1]
	local idCreature = tSpamMsg[2]
	local strText = tSpamMsg[3]

	self.idSpamMsg = idMsg

	local tLayout = CommunicatorLib.GetMessageLayoutForSpam(idMsg)

	Event_FireGenericEvent("CommDisplayRegularText", idMsg, idCreature, strText, tLayout)

	self.strCurrentState = "SpamOngoing"

	local fDuration = 9.500
	if tLayout and tLayout.fDuration then
		fDuration = tLayout.fDuration
	end

	self.timerNPCBubbleFade:Stop()
	self.timerNPCBubbleFade = ApolloTimer.Create(fDuration, false, "OnNpcBubbleFade", self)
	self:SetCommunicatorCreature(idCreature)
	Event_FireGenericEvent("ShowCommDisplay")
	self:DrawCallSystem()

	-- post the message to the chat log
	Chat_PostDatachronMsg(idCreature, strText)
end

function ForgeUI_Datachron:Datachron_MaxMissedCallTimer()
	if self.strCurrentState == "MissedCall" then
		self:DrawCallSystem(self:BuildCallbackList() and "CommQueueAvail" or "NoCalls")
	end
end

function ForgeUI_Datachron:OnDatachronOn()
	if self.wndMinimized:FindChild("DisableCommBtnMin"):IsChecked() then
		self:OnMinimizeDatachron()
	else
		self:OnRestoreDatachron()
	end
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_Datachron Functions
---------------------------------------------------------------------------------------------------

function ForgeUI_Datachron:OnCloseButton( wndHandler, wndControl, eMouseButton )
	self:OnMinimizeDatachron()
end

local ForgeUI_DatachronInst = ForgeUI_Datachron:new()
ForgeUI_DatachronInst:Init()
