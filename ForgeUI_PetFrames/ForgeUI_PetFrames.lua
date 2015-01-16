require "Window"
 
local ForgeUI_PetFrames = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
tEngineerStances = {
	[0] = "",
	[1] = Apollo.GetString("EngineerResource_Aggro"),
	[2] = Apollo.GetString("EngineerResource_Defend"),
	[3] = Apollo.GetString("EngineerResource_Passive"),
	[4] = Apollo.GetString("EngineerResource_Assist"),
	[5] = Apollo.GetString("EngineerResource_Stay"),
}
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function ForgeUI_PetFrames:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

     -- mandatory 
	self.api_version = 1
	self.version = "0.0.1"
	self.author = "WintyBadass"
	self.strAddonName = "ForgeUI_PetFrames"
	self.strDisplayName = "Pet frames"
	
	self.wndContainers = {}
	
	-- optional
	self.settings_version = 1
	self.tSettings = {
		crBorder = "FF000000",
		crBackground = "FF101010",
		crHpBar = "FF272727",
		crHpValue = "FF75CC26",
		crShieldValue = "FF0699F3"
	}

	self.strStanceName = "Assist"
	self.tWndPetFrames = {}
	
    return o
end

function ForgeUI_PetFrames:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"ForgeUI"
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- ForgeUI_PetFrames OnLoad
-----------------------------------------------------------------------------------------------
function ForgeUI_PetFrames:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("ForgeUI_PetFrames.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

function ForgeUI_PetFrames:OnFrameClick( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	GameLib.SetTargetUnit(wndHandler:GetParent():GetData())
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_PetFrames OnDocLoaded
-----------------------------------------------------------------------------------------------
function ForgeUI_PetFrames:OnDocLoaded()
	if self.xmlDoc == nil or not self.xmlDoc:IsLoaded() then return end
	
	if GameLib.GetPlayerUnit() then
		self:OnCharacterCreated()
	else
		Apollo.RegisterEventHandler("CharacterCreated", 	"OnCharacterCreated", self)
	end
end

function ForgeUI_PetFrames:OnCharacterCreated()
	local unitPlayer = GameLib.GetPlayerUnit()
	local eClassId = unitPlayer:GetClassId()
	if eClassId == GameLib.CodeEnumClass.Engineer then
		if ForgeUI == nil then -- forgeui loaded
			ForgeUI = Apollo.GetAddon("ForgeUI")
		end
		
		ForgeUI.RegisterAddon(self)
	end
end

function ForgeUI_PetFrames:ForgeAPI_AfterRegistration()
	Apollo.RegisterEventHandler("PetStanceChanged", "OnPetStanceChanged", self)
	Apollo.RegisterEventHandler("PetSpawned", "OnPetSpawned", self)
	Apollo.RegisterEventHandler("VarChange_FrameCount", "OnNextFrame", self)

	self.wndPetFrames = Apollo.LoadForm(self.xmlDoc, "ForgeUI_PetFrames", "FixedHudStratumLow", self)
	self.wndPetControl = Apollo.LoadForm(self.xmlDoc, "ForgeUI_PetControl", "FixedHudStratumLow", self)
	
	self.strStanceName = tEngineerStances[Pet_GetStance(0)]
	self.wndPetControl:FindChild("StanceName"):SetText(self.strStanceName)
	
	self.wndMovables = Apollo.LoadForm(self.xmlDoc, "ForgeUI_Movables", nil, self)
end

function ForgeUI_PetFrames:ForgeAPI_AfterRestore()
	ForgeUI.RegisterWindowPosition(self, self.wndPetControl, "ForgeUI_PetControl", self.wndMovables:FindChild("Movable_PetControl"))
	ForgeUI.RegisterWindowPosition(self, self.wndPetFrames, "ForgeUI_PetFrames", self.wndMovables:FindChild("Movable_PetFrames"))
end

function ForgeUI_PetFrames:UpdatePetFrames()
	tPets = GameLib.GetPlayerPets()
	
	if #tPets == 0 then
		self.wndPetControl:Show(false, true)
	end
	
	for _, petFrame in pairs(self.tWndPetFrames) do
		petFrame:Show(false, true)
	end
	
	for i, pet in pairs(tPets) do
		if self.tWndPetFrames[i - 1] == nil then
			local newFrame = Apollo.LoadForm(self.xmlDoc, "ForgeUI_PetFrame", self.wndPetFrames, self)

			newFrame:FindChild("Border"):SetBGColor(self.tSettings.crBorder)
			newFrame:FindChild("Background"):SetBGColor(self.tSettings.crBackground)
			newFrame:FindChild("HPBar"):SetBGColor(self.tSettings.crHpBar)
			newFrame:FindChild("HPValue"):SetTextColor(self.tSettings.crHpValue)
			newFrame:FindChild("ShieldValue"):SetTextColor(self.tSettings.crShieldValue)
		
			self.tWndPetFrames[i - 1] = newFrame			
			self.wndPetFrames:ArrangeChildrenVert()
		end
	
		local petFrame = self.tWndPetFrames[i - 1]
		
		petFrame:FindChild("Name"):SetText(pet:GetName())
		petFrame:FindChild("HPValue"):SetText(pet:GetHealth())
		petFrame:FindChild("ShieldValue"):SetText(pet:GetShieldCapacity())
		
		petFrame:FindChild("HPBar"):SetMax(pet:GetMaxHealth())
		petFrame:FindChild("HPBar"):SetProgress(pet:GetHealth())
		
		petFrame:SetData(pet)
		petFrame:Show(true, true)
	end
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_PetControl Functions
---------------------------------------------------------------------------------------------------

function ForgeUI_PetFrames:PetControl_OnMouseEnter( wndHandler, wndControl, x, y )
	self.wndPetControl:FindChild("StanceName"):SetText(wndControl:GetName())
end

function ForgeUI_PetFrames:PetControl_OnMouseExit( wndHandler, wndControl, x, y )
	self.wndPetControl:FindChild("StanceName"):SetText(self.strStanceName)
end

function ForgeUI_PetFrames:OnStancesButton( wndHandler, wndControl, eMouseButton )
	self.wndPetControl:FindChild("Stances"):Show(not self.wndPetControl:FindChild("Stances"):IsShown(), true)
end

function ForgeUI_PetFrames:PetControl_OnStanceBtn( wndHandler, wndControl, eMouseButton )
	self.wndPetControl:FindChild("Stances"):Show(false, true)
	
	if wndControl:GetName() == "Assist" then
		Pet_SetStance(0, 4)
	elseif wndControl:GetName() == "Passive" then
		Pet_SetStance(0, 3)
	elseif wndControl:GetName() == "Defend" then
		Pet_SetStance(0, 2)
	elseif wndControl:GetName() == "Aggro" then
		Pet_SetStance(0, 1)
	end
	
	self.wndPetControl:FindChild("StanceName"):SetText(wndControl:GetName())
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_PetControl EvenHandlers
---------------------------------------------------------------------------------------------------
function ForgeUI_PetFrames:OnNextFrame()
	self:UpdatePetFrames()
end

function ForgeUI_PetFrames:OnPetStanceChanged()
	self.strStanceName = tEngineerStances[Pet_GetStance(0)]
	self.wndPetControl:FindChild("StanceName"):SetText(self.strStanceName)
end

function ForgeUI_PetFrames:OnPetSpawned()
	
end

---------------------------------------------------------------------------------------------------
-- ForgeUI_Movables Functions
---------------------------------------------------------------------------------------------------

function ForgeUI_PetFrames:OnMovableMove( wndHandler, wndControl, nOldLeft, nOldTop, nOldRight, nOldBottom )
	self.wndPetControl:SetAnchorOffsets(self.wndMovables:FindChild("Movable_PetControl"):GetAnchorOffsets())
	self.wndPetFrames:SetAnchorOffsets(self.wndMovables:FindChild("Movable_PetFrames"):GetAnchorOffsets())
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_PetFrames Instance
-----------------------------------------------------------------------------------------------
local ForgeUI_PetFramesInst = ForgeUI_PetFrames:new()
ForgeUI_PetFramesInst:Init()
