--- **GeminiHook-1.0** offers safe Hooking/Unhooking of functions, methods and frame scripts.
-- Using GeminiHook-1.0 is recommended when you need to unhook your hooks again, so the hook chain isn't broken
-- when you manually restore the original function.
--
-- **GeminiHook-1.0** can be embeded into your addon, either explicitly by calling GeminiHook:Embed(MyAddon) or by 
	-- Note: AceAddon functionality not currently ported, Explicit embedding only currently
-- specifying it as an embeded library in your AceAddon. All functions will be available on your addon object
-- and can be accessed directly, without having to explicitly call GeminiHook itself.\\
-- It is recommended to embed GeminiHook, otherwise you'll have to specify a custom `self` on all calls you
-- make into GeminiHook.
-- @class file
-- @name GeminiHook-1.0
local MAJOR, MINOR = "Gemini:Hook-1.0", 1
-- Get a reference to the package information if any
local APkg = Apollo.GetPackage(MAJOR)
-- If there was an older version loaded we need to see if this is newer
if APkg and (APkg.nVersion or 0) >= MINOR then
	return -- no upgrade needed
end
-- Set a reference to the actual package or create an empty table
local GeminiHook = APkg and APkg.tPackage or {}

GeminiHook.embeded = GeminiHook.embeded or {}
GeminiHook.registry = GeminiHook.registry or setmetatable({}, {__index = function(tbl, key) tbl[key] = {} return tbl[key] end })
GeminiHook.handlers = GeminiHook.handlers or {}
GeminiHook.actives = GeminiHook.actives or {}
GeminiHook.hooks = GeminiHook.hooks or {}

-- local upvalues
local registry = GeminiHook.registry
local handlers = GeminiHook.handlers
local actives = GeminiHook.actives

-- Lua APIs
local pairs, next, type = pairs, next, type
local format = string.format
local assert, error = assert, error

local _G = _G

-- functions for later definition
local createHook, hook

-- upgrading of embeded is done at the bottom of the file
local mixins = {
	"Hook", "PostHook",
	"Unhook", "UnhookAll",
	"IsHooked",
	"RawHook",
}

-- GeminiHook:Embed( target )
-- target (object) - target object to embed GeminiHook in
--
-- Embeds AceEevent into the target object making the functions from the mixins list available on target:..
function GeminiHook:Embed( target )
	for k, v in pairs( mixins ) do
		target[v] = self[v]
	end
	self.embeded[target] = true
	-- inject the hooks table safely
	target.hooks = target.hooks or {}
	return target
end

-- GeminiHook:OnEmbedDisable( target )
-- target (object) - target object that is being disabled
--
-- Unhooks all hooks when the target disables.
-- this method should be called by the target manually or by an addon framework
function GeminiHook:OnEmbedDisable( target )
	target:UnhookAll()
end

function createHook(self, handler, orig, bPost, bFailsafe)
	local uid
	local method = type(handler) == "string"
	if bFailsafe then
		-- failsafe hook creation
		uid = function(...)
			if actives[uid] then
				if method then
					self[handler](self, ...)
				else
					handler(...)
				end
			end
			return orig(...)
		end
		-- /failsafe hook
	elseif not bPost then
		-- RawHook
		uid = function(...)
			if actives[uid] then
				if method then
					return self[handler](self, ...)
				else
					return handler(...)
				end
			else
				return orig(...)
			end
		end
		-- /rawhook hook
	else
		-- PostHook
		uid = function(...)
			local tOrigRetVal, tHookRetVal = {orig(...)}, nil
			if actives[uid] then
				if method then
					tHookRetVal = {self[handler](self, ...)}
				else
					tHookRetVal = {handler(...)}
				end
			end
			return tOrigRetVal, tHookRetVal
		end
		-- /posthook hook
	end
	return uid
end

function hook(self, obj, method, handler, bPost, bRaw, usage)
	if not handler then handler = method end

	-- These asserts make sure GeminiHooks's devs play by the rules.
	assert(not bPost or type(bPost) == "boolean")
	assert(not bRaw or type(bRaw) == "boolean")
	assert(usage)
	
	-- Error checking Battery!
	if obj and type(obj) ~= "table" then
		error(format("%s: 'object' - nil or table expected got %s", usage, type(obj)), 3)
	end
	if type(method) ~= "string" then
		error(format("%s: 'method' - string expected got %s", usage, type(method)), 3)
	end
	if type(handler) ~= "string" and type(handler) ~= "function" then
		error(format("%s: 'handler' - nil, string, or function expected got %s", usage, type(handler)), 3)
	end
	if type(handler) == "string" and type(self[handler]) ~= "function" then
		error(format("%s: 'handler' - Handler specified does not exist at self[handler]", usage), 3)
	end

	local uid
	if obj then
		uid = registry[self][obj] and registry[self][obj][method]
	else
		uid = registry[self][method]
	end
	
	if uid then
		if actives[uid] then
			-- Only two sane choices exist here.  We either a) error 100% of the time or b) always unhook and then hook
			-- choice b would likely lead to odd debuging conditions or other mysteries so we're going with a.
			error(format("Attempting to rehook already active hook %s.", method))
		end
		
		if handlers[uid] == handler then -- turn on a decative hook, note enclosures break this ability, small memory leak
			actives[uid] = true
			return
		elseif obj then -- is there any reason not to call unhook instead of doing the following several lines?
			if self.hooks and self.hooks[obj] then
				self.hooks[obj][method] = nil
			end
			registry[self][obj][method] = nil
		else
			if self.hooks then
				self.hooks[method] = nil
			end
			registry[self][method] = nil
		end
		handlers[uid], actives[uid] = nil, nil
		uid = nil
	end
	
	local orig
	if obj then
		orig = obj[method]
	else
		orig = _G[method]
	end

	if not orig then
		error(format("%s: Attempting to hook a non existing target", usage), 3)
	end

	uid = createHook(self, handler, orig, bPost, not (bRaw or bPost))
	
	if obj then
		self.hooks[obj] = self.hooks[obj] or {}
		registry[self][obj] = registry[self][obj] or {}
		registry[self][obj][method] = uid

		self.hooks[obj][method] = orig
		obj[method] = uid
	else
		registry[self][method] = uid
		
		_G[method] = uid
		self.hooks[method] = orig
	end
	
	actives[uid], handlers[uid] = true, handler	
end

--- Hook a function or a method on an object.
-- The hook created will be a "safe hook", that means that your handler will be called
-- before the hooked function ("Pre-Hook"), and you don't have to call the original function yourself,
-- however you cannot stop the execution of the function, or modify any of the arguments/return values.\\
-- This type of hook is typically used if you need to know if some function got called, and don't want to modify it.
-- @paramsig [object], method, [handler]
-- @param object The object to hook a method from
-- @param method If object was specified, the name of the method, or the name of the function to hook.
-- @param handler The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked function)
-- @usage
-- -- create an addon with GeminiHook embeded
-- MyAddon = Apollo.GetPackage("Gemini:Addon-1.0"):NewAddon("HookDemo", false, {}, "Gemini:Hook-1.0")
-- 
-- function MyAddon:OnEnable()
--   self:Hook("GetCurrentZoneName")
-- end
--
-- function MyAddon:GetCurrentZoneName()
--   Print("Showing Zone Name!")
-- end
function GeminiHook:Hook(object, method, handler)
	if type(object) == "string" then
		method, handler, object = object, method, nil
	end

	hook(self, object, method, handler, false, false, "Usage: Hook([object], method, [handler])")	
end

--- RawHook a function or a method on an object.
-- The hook created will be a "raw hook", that means that your handler will completly replace
-- the original function, and your handler has to call the original function (or not, depending on your intentions).\\
-- The original function will be stored in `self.hooks[object][method]` or `self.hooks[functionName]` respectively.\\
-- This type of hook can be used for all purposes, and is usually the most common case when you need to modify arguments
-- or want to control execution of the original function.
-- @paramsig [object], method, [handler], [hookSecure]
-- @param object The object to hook a method from
-- @param method If object was specified, the name of the method, or the name of the function to hook.
-- @param handler The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked function)
-- @usage
-- -- create an addon with GeminiHook embeded
-- MyAddon = Apollo.GetPackage("Gemini:Addon-1.0").tPackage:NewAddon("HookDemo", false, {}, "Gemini:Hook-1.0")
-- 
-- function MyAddon:OnEnable()
--   -- Hook OnGenerateTooltip
--   self:RawHook(Apollo.GetAddon("Inventory"),"OnGenerateTooltip")
-- end
-- 
-- function MyAddon:OnGenerateTooltip(luaCaller, wndControl, wndHandler, tType, item)
--   if item ~= nil and item:IsEquippable() then
--     Print("Equippable item, no tooltip for you!")
--   else
--     self.hooks[Apollo.GetAddon("Inventory")].OnGenerateTooltip(luaCaller, wndControl, wndHandler, tType, item)
--   end
-- end
function GeminiHook:RawHook(object, method, handler)
	if type(object) == "string" then
		method, handler, object = object, method, nil
	end
	
	hook(self, object, method, handler, false, true, "Usage: RawHook([object], method, [handler])")
end

--- PostHook a function or a method on an object.
-- Post Hooks are always called after the original function was called, and you cannot modify the
-- arguments, return values or control the execution.  PostHook returns 2 arguments:
-- a table containing the return values of the original function and either nil or the return values
-- of the hook function
-- @paramsig [object], method, [handler]
-- @param object The object to hook a method from
-- @param method If object was specified, the name of the method, or the name of the function to hook.
-- @param handler The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked function)
-- @usage
function GeminiHook:PostHook(object, method, handler)
	if type(object) == "string" then
		method, handler, object = object, method, nil
	end

	hook(self, object, method, handler, true, false, "Usage: PostHook([object], method, [handler])")
end

--- Unhook from the specified function, method or script.
-- @paramsig [obj], method
-- @param obj The object or frame to unhook from
-- @param method The name of the method, function or script to unhook from.
function GeminiHook:Unhook(obj, method)
	local usage = "Usage: Unhook([obj], method)"
	if type(obj) == "string" then
		method, obj = obj, nil
	end
		
	if obj and type(obj) ~= "table" then
		error(format("%s: 'obj' - expecting nil or table got %s", usage, type(obj)), 2)
	end
	if type(method) ~= "string" then
		error(format("%s: 'method' - expeting string got %s", usage, type(method)), 2)
	end
	
	local uid
	if obj then
		uid = registry[self][obj] and registry[self][obj][method]
	else
		uid = registry[self][method]
	end
	
	if not uid or not actives[uid] then
		-- Declining to error on an unneeded unhook since the end effect is the same and this would just be annoying.
		return false
	end
	
	actives[uid], handlers[uid] = nil, nil
	
	if obj then
		registry[self][obj][method] = nil
		registry[self][obj] = next(registry[self][obj]) and registry[self][obj] or nil
		
		-- if the hook reference doesnt exist, then its a secure hook, just bail out and dont do any unhooking
		if not self.hooks[obj] or not self.hooks[obj][method] then return true end
		
		if obj and self.hooks[obj] and self.hooks[obj][method] and obj[method] == uid then -- unhooks methods
			obj[method] = self.hooks[obj][method]
		end
		
		self.hooks[obj][method] = nil
		self.hooks[obj] = next(self.hooks[obj]) and self.hooks[obj] or nil
	else
		registry[self][method] = nil
		
		-- if self.hooks[method] doesn't exist, then this is a SecureHook, just bail out
		if not self.hooks[method] then return true end
		
		if self.hooks[method] and _G[method] == uid then -- unhooks functions
			_G[method] = self.hooks[method]
		end
		
		self.hooks[method] = nil
	end
	return true
end

--- Unhook all existing hooks for this addon.
function GeminiHook:UnhookAll()
	for key, value in pairs(registry[self]) do
		if type(key) == "table" then
			for method in pairs(value) do
				self:Unhook(key, method)
			end
		else
			self:Unhook(key)
		end
	end
end

--- Check if the specific function, method or script is already hooked.
-- @paramsig [obj], method
-- @param obj The object or frame to unhook from
-- @param method The name of the method, function or script to unhook from.
function GeminiHook:IsHooked(obj, method)
	-- we don't check if registry[self] exists, this is done by evil magicks in the metatable
	if type(obj) == "string" then
		if registry[self][obj] and actives[registry[self][obj]] then
			return true, handlers[registry[self][obj]]
		end
	else
		if registry[self][obj] and registry[self][obj][method] and actives[registry[self][obj][method]] then
			return true, handlers[registry[self][obj][method]]
		end
	end
	
	return false, nil
end

--- Upgrade our old embeded
for target, v in pairs( GeminiHook.embeded ) do
	GeminiHook:Embed( target )
end

-- No special on Init code
function GeminiHook:OnLoad() end
-- No dependencies
function GeminiHook:OnDependencyError(strDep, strError) return false end

Apollo.RegisterPackage(GeminiHook, MAJOR, MINOR, {})