require "Window"

local F = _G["ForgeLibs"]["ForgeUI"] -- ForgeUI API
local G = _G["ForgeLibs"]["ForgeGUI"] -- ForgeGUI


local ForgeUI_PetFrames = {
	_NAME = "ForgeUI_PetFrames",
	_API_VERSION = 3,
	_VERSION = "2.0",
	DISPLAY_NAME = "Pet frames",

	tSettings = {
		profile = {
			crBorder = "FF000000",
			crBackground = "FF101010",
			crHpBar = "FF272727",
			crHpValue = "FF75CC26",
			crShieldValue = "FF0699F3"
		}
	}

}

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local tEngineerStances = {
	[0] = "",
	[1] = Apollo.GetString("EngineerResource_Aggro"),
	[2] = Apollo.GetString("EngineerResource_Defend"),
	[3] = Apollo.GetString("EngineerResource_Passive"),
	[4] = Apollo.GetString("EngineerResource_Assist"),
	[5] = Apollo.GetString("EngineerResource_Stay"),
}

----------------------------------------------------
-- ForgeAPI
-----------------------------------------------------------------------------------------------
function ForgeUI_PetFrames:ForgeAPI_Init()
	self.xmlDoc = XmlDoc.CreateFromFile("..//ForgeUI_PetFrames//ForgeUI_PetFrames.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
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
		self:AfterOnCharacterCreated()
	end
end

function ForgeUI_PetFrames:AfterOnCharacterCreated()
	self.wndPetFrames = Apollo.LoadForm(self.xmlDoc, "ForgeUI_PetFrames", F:API_GetStratum("Hud"), self)
	self.wndPetControl = Apollo.LoadForm(self.xmlDoc, "ForgeUI_PetControl", F:API_GetStratum("Hud"), self)

	F:API_AddMenuItem(self, self.DISPLAY_NAME, "General")
	F:API_RegisterMover(self, self.wndPetFrames, "PetFrames", "Pet frames", "general")
	F:API_RegisterMover(self, self.wndPetControl, "PetControl", "Pet control", "general")

	self.strStanceName = "Assist"
	self.tWndPetFrames = {}

	Apollo.RegisterEventHandler("PetStanceChanged", "OnPetStanceChanged", self)
	Apollo.RegisterEventHandler("PetSpawned", "OnPetSpawned", self)
	Apollo.RegisterEventHandler("PetDespawned", "OnPetDespawned", self)
	Apollo.RegisterEventHandler("Mount", "OnMount", self)
	
	F:API_RegisterEvent(self, "LazyUpdate", "OnNextFrame")
end

function ForgeUI_PetFrames:OnFrameClick( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	GameLib.SetTargetUnit(wndHandler:GetParent():GetData())
end


function ForgeUI_PetFrames:UpdatePetFrames()
	tPets = GameLib.GetPlayerPets()

	self.wndPetControl:Show(true, true)


	if #tPets == 0 then
		self.wndPetControl:Show(false, true)
	end

	for _, petFrame in pairs(self.tWndPetFrames) do
		petFrame:Show(false, true)
	end

	for i, pet in pairs(tPets) do
		if self.tWndPetFrames[i - 1] == nil then
			local newFrame = Apollo.LoadForm(self.xmlDoc, "ForgeUI_PetFrame", self.wndPetFrames, self)

			newFrame:FindChild("Border"):SetBGColor(self._DB.profile.crBorder)
			newFrame:FindChild("Background"):SetBGColor(self._DB.profile.crBackground)
			newFrame:FindChild("HPBar"):SetBarColor(self._DB.profile.crHpBar)
			newFrame:FindChild("HPValue"):SetTextColor(self._DB.profile.crHpValue)
			newFrame:FindChild("ShieldValue"):SetTextColor(self._DB.profile.crShieldValue)

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

function ForgeUI_PetFrames:OnNextFrame()
	self:UpdatePetFrames()
end

function ForgeUI_PetFrames:OnPetStanceChanged()
	self.strStanceName = tEngineerStances[Pet_GetStance(0)]
	self.wndPetControl:FindChild("StanceName"):SetText(self.strStanceName)
end

function ForgeUI_PetFrames:OnPetSpawned()
	self.wndPetControl:Show(true, true)
end

function ForgeUI_PetFrames:OnPetDespawned()
	despawnPets = GameLib.GetPlayerPets()

	if #despawnPets == 0 then
		self.wndPetControl:Show(false, true)
	end
end

function ForgeUI_PetFrames:OnMount()
	petTimer = ApolloTimer.Create(0.1, false, "MountPetTimer", self)
end

function ForgeUI_PetFrames:MountPetTimer()
	mountPets = GameLib.GetPlayerPets()

	if #mountPets > 0 then
		self.wndPetControl:Show(true, true)
	else
		self.wndPetControl:Show(false, true)
	end
end

function ForgeUI_PetFrames:ForgeAPI_LoadSettings()
	if self.tWndPetFrames == nil then return end

	for k, v in pairs(self.tWndPetFrames) do
		v:FindChild("Border"):SetBGColor(self._DB.profile.crBorder)
		v:FindChild("Background"):SetBGColor(self._DB.profile.crBackground)
		v:FindChild("HPBar"):SetBarColor(self._DB.profile.crHpBar)
		v:FindChild("HPValue"):SetTextColor(self._DB.profile.crHpValue)
		v:FindChild("ShieldValue"):SetTextColor(self._DB.profile.crShieldValue)
	end
end

function ForgeUI_PetFrames:ForgeAPI_PopulateOptions()
	if self.tOptionHolders == nil then return end

	local wnd = self.tOptionHolders["General"]

	G:API_AddColorBox(self, wnd, "Border color", self._DB.profile, "crBorder", { tMove = { 0, 0 }, fnCallback = self.ForgeAPI_LoadSettings })
	G:API_AddColorBox(self, wnd, "Background color", self._DB.profile, "crBackground", { tMove = { 0, 30 }, fnCallback = self.ForgeAPI_LoadSettings })
	G:API_AddColorBox(self, wnd, "Health bar color", self._DB.profile, "crHpBar", { tMove = { 0, 60 }, fnCallback = self.ForgeAPI_LoadSettings })
end

-----------------------------------------------------------------------------------------------
-- ForgeUI_PetFrames Instance
-----------------------------------------------------------------------------------------------
F:API_NewAddon(ForgeUI_PetFrames)
