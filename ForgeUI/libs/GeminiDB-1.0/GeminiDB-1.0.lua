--- **GeminiDB-1.0** manages the saved variables of your addon.
-- It offers profile management, smart defaults and namespaces for modules.
-- Data can be saved in different data-types, depending on its intended usage.
-- The most common data-type is the `profile` type, which allows the user to choose
-- the active profile, and manage the profiles of all of his characters.
-- The following data types are available:
-- * **char** Character-specific data. Every character has its own database.
-- * **realm** Realm-specific data. All of the players characters on the same realm share this database.
-- * **global** Global Data. All characters on the same account share this database.
-- * **profile** Profile-specific data. All characters using the same profile share this database. The user can control which profile should be used.
--
-- Creating a new Database using the `:New` function will return a new DBObject. A database will inherit all functions
-- of the DBObjectLib listed here.
-- If you create a new namespaced child-database (`:RegisterNamespace`), you'll get a DBObject as well, but note
-- that the child-databases cannot individually change their profile, and are linked to their parents profile - and because of that,
-- the profile related APIs are not available. Only `:RegisterDefaults` and `:ResetProfile` are available on child-databases.
--
-- For more details on how to use GeminiDB-1.0, see the GeminiDB-1.0 Tutorial.
--
-- @usage
-- MyAddon = Apollo.GetPackage("Gemini:Addon-1.0"):NewAddon("DBExample")
--
-- -- declare defaults to be used in the DB
-- local defaults = {
--   profile = {
--     setting = true,
--   }
-- }
--
-- function MyAddon:OnInitialize()
--   self.db = Apollo.GetPackage("Gemini:DB-1.0").tPackage:New(self, defaults, true)
-- end
-- @class file
-- @name GeminiDB-1.0.lua
local MAJOR, MINOR = "Gemini:DB-1.0a", 6
local APkg = Apollo.GetPackage(MAJOR)
if APkg and (APkg.nVersion or 0) >= MINOR then
	return -- no upgrade is needed
end
local GeminiDB = APkg and APkg.tPackage or {}

-- Lua APIs
local type, pairs, next, error, tinsert, tremove = type, pairs, next, error, table.insert, table.remove
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget

-- Wildstar APIs
local Apollo, GameLib = Apollo, GameLib

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
--GLOBALS:

local CallbackHandler, AddonLog
local CallbackDummy = { Fire = function() end }

local DBObjectLib = {}
GeminiDB.db_registry = GeminiDB.db_registry or {}
GeminiDB.tRestoreQueue = GeminiDB.tRestoreQueue or {}

--[[-------------------------------------------------------------------------
	GeminiDB Utility Functions
---------------------------------------------------------------------------]]

-- this locale lookup table is accurate for build 6512
local ktLocales = {
	[1] = "enUS",
	[2] = "deDE",
	[3] = "frFR",
	[4] = "koKR",
}

-- check the locale.languageId console variable set by the launcher
-- if not found, default to enUS
local function GetLocale()
	local strCancel = Apollo.GetString(1)

	-- German
	if strCancel == "Abbrechen" then
		return ktLocales[2]
	end

	-- French
	if strCancel == "Annuler" then
		return ktLocales[3]
	end

	-- Other
	return ktLocales[1]
	-- return ktLocales[(Apollo.GetConsoleVariable("locale.languageId") or 1)]
end

-- Simple shallow copy for copying defaults
local function copyTable(src, dest)
	if type(dest) ~= "table" then dest = {} end
	if type(src) == "table" then
		for k,v in pairs(src) do
			if type(v) == "table" then
				-- try to index the key first so that the metatable creates the defaults, if set, and use that table
				v = copyTable(v, dest[k])
			end
			dest[k] = v
		end
	end
	return dest
end

-- Called to add defaults to a section of the database
--
-- When a ["*"] default section is indexed with a new key, a table is returned
-- and set in the host table.  These tables must be cleaned up by removeDefaults
-- in order to ensure we don't write empty default tables.
local function copyDefaults(dest, src)
	-- this happens if some value in the SV overwrites our default value with a non-table
	--if type(dest) ~= "table" then return end
	for k, v in pairs(src) do
		if k == "*" or k == "**" then
			if type(v) == "table" then
				-- This is a metatable used for table defaults
				local mt = {
					-- This handles the lookup and creation of new subtables
					__index = function(t,k)
							if k == nil then return nil end
							local tbl = {}
							copyDefaults(tbl, v)
							rawset(t, k, tbl)
							return tbl
						end,
				}
				setmetatable(dest, mt)
				-- handle already existing tables in the SV
				for dk, dv in pairs(dest) do
					if not rawget(src, dk) and type(dv) == "table" then
						copyDefaults(dv, v)
					end
				end
			else
				-- Values are not tables, so this is just a simple return
				local mt = {__index = function(t,k) return k~=nil and v or nil end}
				setmetatable(dest, mt)
			end
		elseif type(v) == "table" then
			if not rawget(dest, k) then rawset(dest, k, {}) end
			if type(dest[k]) == "table" then
				copyDefaults(dest[k], v)
				if src['**'] then
					copyDefaults(dest[k], src['**'])
				end
			end
		else
			if rawget(dest, k) == nil then
				rawset(dest, k, v)
			end
		end
	end
end

-- Called to remove all defaults in the default table from the database
local function removeDefaults(db, defaults, blocker)
	-- remove all metatables from the db, so we don't accidentally create new sub-tables through them
	setmetatable(db, nil)
	-- loop through the defaults and remove their content
	for k,v in pairs(defaults) do
		if k == "*" or k == "**" then
			if type(v) == "table" then
				-- Loop through all the actual k,v pairs and remove
				for key, value in pairs(db) do
					if type(value) == "table" then
						-- if the key was not explicitly specified in the defaults table, just strip everything from * and ** tables
						if defaults[key] == nil and (not blocker or blocker[key] == nil) then
							removeDefaults(value, v)
							-- if the table is empty afterwards, remove it
							if next(value) == nil then
								db[key] = nil
							end
						-- if it was specified, only strip ** content, but block values which were set in the key table
						elseif k == "**" then
							removeDefaults(value, v, defaults[key])
						end
					end
				end
			elseif k == "*" then
				-- check for non-table default
				for key, value in pairs(db) do
					if defaults[key] == nil and v == value then
						db[key] = nil
					end
				end
			end
		elseif type(v) == "table" and type(db[k]) == "table" then
			-- if a blocker was set, dive into it, to allow multi-level defaults
			removeDefaults(db[k], v, blocker and blocker[k])
			if next(db[k]) == nil then
				db[k] = nil
			end
		else
			-- check if the current value matches the default, and that its not blocked by another defaults table
			if db[k] == defaults[k] and (not blocker or blocker[k] == nil) then
				db[k] = nil
			end
		end
	end
end

-- This is called when a table section is first accessed, to set up the defaults
local function initSection(db, section, svstore, key, defaults)
	local sv = rawget(db, "sv")

	local tableCreated
	if not sv[svstore] then sv[svstore] = {} end
	if not sv[svstore][key] then
		sv[svstore][key] = {}
		tableCreated = true
	end

	local tbl = sv[svstore][key]

	if defaults then
		copyDefaults(tbl, defaults)
	end
	rawset(db, section, tbl)

	return tableCreated, tbl
end

-- Metatable to handle the dynamic creation of sections and copying of sections.
local dbmt = {
	__index = function(t, section)
			local keys = rawget(t, "keys")
			local key = keys[section]
			if key then
				if type(key) == "function" then
					if not keys[section](keys) then
						error("Attempt to access character-specific field " .. section .. " before character loaded.")
					end
					-- the key has changed so we need to obtain it again.
					key = keys[section]	
				end
				local defaultTbl = rawget(t, "defaults")
				local defaults = defaultTbl and defaultTbl[section]

				if section == "profile" then
					local new = initSection(t, section, "profiles", key, defaults)
					if new then
						-- Callback: OnNewProfile, database, newProfileKey
						t.callbacks:Fire("OnNewProfile", t, key)
					end
				elseif section == "profiles" then
					local sv = rawget(t, "sv")
					if not sv.profiles then sv.profiles = {} end
					rawset(t, "profiles", sv.profiles)
				elseif section == "global" then
					local sv = rawget(t, "sv")
					if not sv.global then sv.global = {} end
					if defaults then
						copyDefaults(sv.global, defaults)
					end
					rawset(t, section, sv.global)
				else
					initSection(t, section, section, key, defaults)
				end
			end

			return rawget(t, section)
		end
}

local function validateDefaults(defaults, keyTbl, offset)
	if not defaults then return end
	offset = offset or 0
	for k in pairs(defaults) do
		if not keyTbl[k] or k == "profiles" then
			error(("Usage: GeminiDBObject:RegisterDefaults(defaults): '%s' is not a valid datatype."):format(k), 3 + offset)
		end
	end
end

local preserve_keys = {
	["callbacks"] = true,
	["RegisterCallback"] = true,
	["UnregisterCallback"] = true,
	["UnregisterAllCallbacks"] = true,
	["children"] = true,
}

local realmKey = GameLib.GetRealmName()
local charKey = GameLib.GetAccountRealmCharacter().strCharacter .. " - " .. realmKey
local localeKey = GetLocale():lower()

local function populateKeys(self)
	local uPlayer = GameLib.GetPlayerUnit()
	if not uPlayer then
		-- No changes
		return false
	end
	self["class"] = "Class - " .. uPlayer:GetClassId()
	self["race"] = "Race - " .. uPlayer:GetRaceId()

	-- Changes made
	return true
end

-- Actual database initialization function
local function initdb(sv, defaults, defaultProfile, olddb, parent)
	-- Generate the database keys for each section

	-- map "true" to our "Default" profile
	if defaultProfile == true then defaultProfile = "Default" end

	local profileKey
	if not parent then
		-- Make a container for profile keys
		if not sv.profileKeys then sv.profileKeys = {} end

		-- Try to get the profile selected from the char db
		profileKey = sv.profileKeys[charKey] or defaultProfile or charKey

		-- save the selected profile for later
		sv.profileKeys[charKey] = profileKey
	else
		-- Use the profile of the parents DB
		profileKey = parent.keys.profile or defaultProfile or charKey

		-- clear the profileKeys in the DB, namespaces don't need to store them
		sv.profileKeys = nil
	end

	-- This table contains keys that enable the dynamic creation
	-- of each section of the table.  The 'global' and 'profiles'
	-- have a key of true, since they are handled in a special case
	local keyTbl= {
		["char"] = charKey,
		["realm"] = realmKey,
		["profile"] = profileKey,
		["locale"] = localeKey,
		["global"] = true,
		["profiles"] = true,
		["class"] = populateKeys,
		["race"] = populateKeys,
	}

	validateDefaults(defaults, keyTbl, 1)

	-- This allows us to use this function to reset an entire database
	-- Clear out the old database
	if olddb then
		for k,v in pairs(olddb) do if not preserve_keys[k] then olddb[k] = nil end end
	end

	-- Give this database the metatable so it initializes dynamically
	local db = setmetatable(olddb or {}, dbmt)

	if not rawget(db, "callbacks") then
		-- try to load CallbackHandler-1.0 if it loaded after our library
		if not CallbackHandler then
			local APkg = Apollo.GetPackage("Gemini:CallbackHandler-1.0")
			CallbackHandler = APkg and APkg.tPackage or nil
		end
		db.callbacks = CallbackHandler and CallbackHandler:New(db) or CallbackDummy
	end

	-- Copy methods locally into the database object, to avoid hitting
	-- the metatable when calling methods

	if not parent then
		for name, func in pairs(DBObjectLib) do
			db[name] = func
		end
	else
		-- hack this one in
		db.RegisterDefaults = DBObjectLib.RegisterDefaults
		db.ResetProfile = DBObjectLib.ResetProfile
		db.ResetSection = DBObjectLib.ResetSection
	end

	-- Set some properties in the database object
	db.profiles = sv.profiles
	db.keys = keyTbl
	db.sv = sv
	db.defaults = defaults
	db.defaultProfile = defaultProfile
	db.parent = parent

	return db
end

local function createdb(oAddon, defaults, defaultProfile)
	local tNewDB = {}

	local db = initdb(tNewDB, defaults, defaultProfile)

	-- store the DB in the registry
	GeminiDB.db_registry[oAddon] = db

	return db
end

local function shutdowndb(db)
	db.callbacks:Fire("OnDatabaseShutdown", db)
	db:RegisterDefaults(nil)

	-- cleanup sections that are empty without defaults
	local sv = rawget(db, "sv")
	for section in pairs(db.keys) do
		if rawget(sv, section) then
			-- global is special, all other sections have sub-entrys
			-- also don't delete empty profiles on main dbs, only on namespaces
			if section ~= "global" and (section ~= "profiles" or rawget(db, "parent")) then
				for key in pairs(sv[section]) do
					if not next(sv[section][key]) then
						sv[section][key] = nil
					end
				end
			end
			if not next(sv[section]) then
				sv[section] = nil
			end
		end
	end
end

-- strip all defaults from the database
-- and cleans up empty sections
local function OnSave(self, eLevel)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.General then
		return nil
	end

	local db = GeminiDB.db_registry[self]
	if not db then return nil end

	shutdowndb(db)

	if db.children then
		for namespace, namespaceDB in pairs(db.children) do
			shutdowndb(namespaceDB)
		end
	end

	-- Return the data to save out
	return rawget(db, "sv")
end

local function OnRestore(self, eLevel, tSavedData)
	local db = GeminiDB.db_registry[self]
	local tCancelDefaultProcessing = { bCancelDefault = false }
	db.callbacks:Fire("OnDatabaseImport", db, eLevel, tSavedData, tCancelDefaultProcessing)

	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.General or
			tCancelDefaultProcessing.bCancelDefault then
		return
	end

	copyTable(tSavedData, db.sv)

	local sv = rawget(db, "sv")
	-- Try to get the profile selected from the char db
	local profileKey = sv.profileKeys[charKey] or db.defaultProfile or charKey
	-- save the selected profile for later
	sv.profileKeys[charKey] = profileKey

	-- Set profile to the correct profile
	local keyTbl = rawget(db, "keys")
	keyTbl.profile = profileKey

	-- If there are namespace DBs then select the correct profile now too.
	if db.children then
		for namespace, namespaceDB in pairs(db.children) do
			-- Set profile to the correct profile
			local keyTbl = rawget(namespaceDB, "keys")
			keyTbl.profile = profileKey
		end
	end

	db.callbacks:Fire("OnDatabaseStartup", db)
end

--[[-------------------------------------------------------------------------
	GeminiDB Object Method Definitions
---------------------------------------------------------------------------]]

--- Sets the defaults table for the given database object by clearing any
-- that are currently set, and then setting the new defaults.
-- @param defaults A table of defaults for this database
function DBObjectLib:RegisterDefaults(defaults)
	if defaults and type(defaults) ~= "table" then
		error("Usage: GeminiDBObject:RegisterDefaults(defaults): 'defaults' - table or nil expected.", 2)
	end

	validateDefaults(defaults, self.keys)

	-- Remove any currently set defaults
	if self.defaults then
		for section,key in pairs(self.keys) do
			if self.defaults[section] and rawget(self, section) then
				removeDefaults(self[section], self.defaults[section])
			end
		end
	end

	-- Set the DBObject.defaults table
	self.defaults = defaults

	-- Copy in any defaults, only touching those sections already created
	if defaults then
		for section,key in pairs(self.keys) do
			if defaults[section] and rawget(self, section) then
				copyDefaults(self[section], defaults[section])
			end
		end
	end
end

--- Changes the profile of the database and all of it's namespaces to the
-- supplied named profile
-- @param name The name of the profile to set as the current profile
function DBObjectLib:SetProfile(name)
	if type(name) ~= "string" then
		error("Usage: GeminiDBObject:SetProfile(name): 'name' - string expected.", 2)
	end

	-- changing to the same profile, dont do anything
	--if name == self.keys.profile then
	--	self.callbacks:Fire("OnProfileChanged", self, name)
	--	return
	--end

	local oldProfile = self.profile
	local defaults = self.defaults and self.defaults.profile

	-- Callback: OnProfileShutdown, database
	self.callbacks:Fire("OnProfileShutdown", self)

	if oldProfile and defaults then
		-- Remove the defaults from the old profile
		removeDefaults(oldProfile, defaults)
	end

	self.profile = nil
	self.keys["profile"] = name

	-- if the storage exists, save the new profile
	-- this won't exist on namespaces.
	if self.sv.profileKeys then
		self.sv.profileKeys[charKey] = name
	end

	-- populate to child namespaces
	if self.children then
		for _, db in pairs(self.children) do
			DBObjectLib.SetProfile(db, name)
		end
	end

	-- Callback: OnProfileChanged, database, newProfileKey
	self.callbacks:Fire("OnProfileChanged", self, name)
end

--- Returns a table with the names of the existing profiles in the database.
-- You can optionally supply a table to re-use for this purpose.
-- @param tbl A table to store the profile names in (optional)
function DBObjectLib:GetProfiles(tbl)
	if tbl and type(tbl) ~= "table" then
		error("Usage: GeminiDBObject:GetProfiles(tbl): 'tbl' - table or nil expected.", 2)
	end

	-- Clear the container table
	if tbl then
		for k,v in pairs(tbl) do tbl[k] = nil end
	else
		tbl = {}
	end

	local curProfile = self.keys.profile

	local i = 0
	for profileKey in pairs(self.profiles) do
		i = i + 1
		tbl[i] = profileKey
		if curProfile and profileKey == curProfile then curProfile = nil end
	end

	-- Add the current profile, if it hasn't been created yet
	if curProfile then
		i = i + 1
		tbl[i] = curProfile
	end

	return tbl, i
end

--- Returns the current profile name used by the database
function DBObjectLib:GetCurrentProfile()
	return self.keys.profile
end

--- Deletes a named profile.  This profile must not be the active profile.
-- @param name The name of the profile to be deleted
-- @param silent If true, do not raise an error when the profile does not exist
function DBObjectLib:DeleteProfile(name, silent)
	if type(name) ~= "string" then
		error("Usage: GeminiDBObject:DeleteProfile(name): 'name' - string expected.", 2)
	end

	if self.keys.profile == name then
		error("Cannot delete the active profile in an GeminiDBObject.", 2)
	end

	if not rawget(self.profiles, name) and not silent then
		error("Cannot delete profile '" .. name .. "'. It does not exist.", 2)
	end

	self.profiles[name] = nil

	-- populate to child namespaces
	if self.children then
		for _, db in pairs(self.children) do
			DBObjectLib.DeleteProfile(db, name, true)
		end
	end

	-- switch all characters that use this profile back to the default
	if self.sv.profileKeys then
		for key, profile in pairs(self.sv.profileKeys) do
			if profile == name then
				self.sv.profileKeys[key] = nil
			end
		end
	end

	-- Callback: OnProfileDeleted, database, profileKey
	self.callbacks:Fire("OnProfileDeleted", self, name)
end

--- Copies a named profile into the current profile, overwriting any conflicting
-- settings.
-- @param name The name of the profile to be copied into the current profile
-- @param silent If true, do not raise an error when the profile does not exist
function DBObjectLib:CopyProfile(name, silent)
	if type(name) ~= "string" then
		error("Usage: GeminiDBObject:CopyProfile(name): 'name' - string expected.", 2)
	end

	if name == self.keys.profile then
		error("Cannot have the same source and destination profiles.", 2)
	end

	if not rawget(self.profiles, name) and not silent then
		error("Cannot copy profile '" .. name .. "'. It does not exist.", 2)
	end

	-- Reset the profile before copying
	DBObjectLib.ResetProfile(self, nil, true)

	local profile = self.profile
	local source = self.profiles[name]

	copyTable(source, profile)

	-- populate to child namespaces
	if self.children then
		for _, db in pairs(self.children) do
			DBObjectLib.CopyProfile(db, name, true)
		end
	end

	-- Callback: OnProfileCopied, database, sourceProfileKey
	self.callbacks:Fire("OnProfileCopied", self, name)
end

--- Resets the current profile to the default values (if specified).
-- @param noChildren if set to true, the reset will not be populated to the child namespaces of this DB object
-- @param noCallbacks if set to true, won't fire the OnProfileReset callback
function DBObjectLib:ResetProfile(noChildren, noCallbacks)
	local profile = self.profile

	for k,v in pairs(profile) do
		profile[k] = nil
	end

	local defaults = self.defaults and self.defaults.profile
	if defaults then
		copyDefaults(profile, defaults)
	end

	-- populate to child namespaces
	if self.children and not noChildren then
		for _, db in pairs(self.children) do
			DBObjectLib.ResetProfile(db, nil, noCallbacks)
		end
	end

	-- Callback: OnProfileReset, database
	if not noCallbacks then
		self.callbacks:Fire("OnProfileReset", self)
	end
end

--- Resets the current profile to the default values (if specified).
-- @param name The name of the database section to reset
-- @param noChildren if set to true, the reset will not be populated to the child namespaces of this DB object
-- @param noCallbacks if set to true, won't fire the On Type Reset callback
function DBObjectLib:ResetSection(name, noChildren, noCallbacks)
	if not name then
		error(("Usage: GeminiDBObject:ResetSection(name, noChildren, noCallbacks): 'name' - string required."))
	end
	local keyTbl = rawget(self, "keys")
	if not keyTbl[name] or name == "profiles" then
		error(("Usage: GeminiDBObject:ResetSection(name, noChildren, noCallbacks): '%s' is not a valid section."):format(type))
	end
	local section = self[name]

	for k,v in pairs(section) do
		section[k] = nil
	end

	local defaults = self.defaults and self.defaults[name]
	if defaults then
		copyDefaults(section, defaults)
	end

	-- populate to child namespaces
	if self.children and not noChildren then
		for _, db in pairs(self.children) do
			DBObjectLib.ResetSection(db, name, nil, noCallbacks)
		end
	end

	-- Callback: OnSectionReset, database, sectionName
	if not noCallbacks then
		self.callbacks:Fire("OnSectionReset", self, name)
	end
end

--- Resets the entire database, using the string defaultProfile as the new default
-- profile.
-- @param defaultProfile The profile name to use as the default
function DBObjectLib:ResetDB(defaultProfile)
	if defaultProfile and type(defaultProfile) ~= "string" then
		error("Usage: GeminiDBObject:ResetDB(defaultProfile): 'defaultProfile' - string or nil expected.", 2)
	end

	local sv = self.sv
	for k,v in pairs(sv) do
		sv[k] = nil
	end

	local parent = self.parent

	initdb(sv, self.defaults, defaultProfile, self)

	-- fix the child namespaces
	if self.children then
		if not sv.namespaces then sv.namespaces = {} end
		for name, db in pairs(self.children) do
			if not sv.namespaces[name] then sv.namespaces[name] = {} end
			initdb(sv.namespaces[name], db.defaults, self.keys.profile, db, self)
		end
	end

	-- Callback: OnDatabaseReset, database
	self.callbacks:Fire("OnDatabaseReset", self)
	-- Callback: OnProfileChanged, database, profileKey
	self.callbacks:Fire("OnProfileChanged", self, self.keys["profile"])

	return self
end

--- Creates a new database namespace, directly tied to the database.  This
-- is a full scale database in it's own rights other than the fact that
-- it cannot control its profile individually
-- @param name The name of the new namespace
-- @param defaults A table of values to use as defaults
function DBObjectLib:RegisterNamespace(name, defaults)
	if type(name) ~= "string" then
		error("Usage: GeminiDBObject:RegisterNamespace(name, defaults): 'name' - string expected.", 2)
	end
	if defaults and type(defaults) ~= "table" then
		error("Usage: GeminiDBObject:RegisterNamespace(name, defaults): 'defaults' - table or nil expected.", 2)
	end
	if self.children and self.children[name] then
		error ("Usage: GeminiDBObject:RegisterNamespace(name, defaults): 'name' - a namespace with that name already exists.", 2)
	end

	local sv = self.sv
	if not sv.namespaces then sv.namespaces = {} end
	if not sv.namespaces[name] then
		sv.namespaces[name] = {}
	end

	local newDB = initdb(sv.namespaces[name], defaults, self.keys.profile, nil, self)

	if not self.children then self.children = {} end
	self.children[name] = newDB
	return newDB
end

--- Returns an already existing namespace from the database object.
-- @param name The name of the new namespace
-- @param silent if true, the addon is optional, silently return nil if its not found
-- @usage
-- local namespace = self.db:GetNamespace('namespace')
-- @return the namespace object if found
function DBObjectLib:GetNamespace(name, silent)
	if type(name) ~= "string" then
		error("Usage: GeminiDBObject:GetNamespace(name): 'name' - string expected.", 2)
	end
	if not silent and not (self.children and self.children[name]) then
		error ("Usage: GeminiDBObject:GetNamespace(name): 'name' - namespace does not exist.", 2)
	end
	if not self.children then self.children = {} end
	return self.children[name]
end

--[[-------------------------------------------------------------------------
	GeminiDB Exposed Methods
---------------------------------------------------------------------------]]

--- Creates a new database object that can be used to handle database settings and profiles.
-- By default, an empty DB is created, using a character specific profile.
--
-- You can override the default profile used by passing any profile name as the third argument,
-- or by passing 'true' as the third argument to use a globally shared profile called "Default".
--
-- Note that there is no token replacement in the default profile name, passing a defaultProfile as "char"
-- will use a profile named "char", and not a character-specific profile.
-- @param tbl The name of variable, or table to use for the database
-- @param defaults A table of database defaults
-- @param defaultProfile The name of the default profile. If not set, a character specific profile will be used as the default.
-- You can also pass 'true' to use a shared global profile called "Default".
-- @usage
-- -- Create an empty DB using a character-specific default profile.
-- self.db = Apollo.GetPackage("Gemini:DB-1.0").tPackage:New(self)
-- @usage
-- -- Create a DB using defaults and using a shared default profile
-- self.db = Apollo.GetPackage("Gemini:DB-1.0").tPackage:New(self, defaults, true)
function GeminiDB:New(oAddon, defaults, defaultProfile)
	if not oAddon or type(oAddon) ~= "table" then
		error("Usage: GeminiDB:New(addon, defaults, defaultProfile): 'addon' - table expected.", 2)
	end

	if defaults and type(defaults) ~= "table" then
		error("Usage: GeminiDB:New(tbl, defaults, defaultProfile): 'defaults' - table expected.", 2)
	end

	if defaultProfile and type(defaultProfile) ~= "string" and defaultProfile ~= true then
		error("Usage: GeminiDB:New(tbl, defaults, defaultProfile): 'defaultProfile' - string or true expected.", 2)
	end

	oAddon.OnSave = OnSave
	oAddon.OnRestore = OnRestore

	return createdb(oAddon, defaults, defaultProfile)
end

Apollo.RegisterPackage(GeminiDB, MAJOR, MINOR, {})
