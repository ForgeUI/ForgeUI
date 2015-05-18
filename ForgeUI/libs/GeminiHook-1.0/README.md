GeminiHook
==========

Wildstar Library - Offers safe Hooking/Unhooking of functions, and methods


**GeminiHook-1.0** offers safe Hooking/Unhooking of functions and methods.
Using GeminiHook-1.0 is recommended when you need to unhook your hooks again, so the hook chain isn't broken when you manually restore the original function.

**GeminiHook-1.0** can be embeded into your addon, either explicitly by calling GeminiHook:Embed(MyAddon) or by specifying it as an embeded library in your GeminiAddon. All functions will be available on your addon object and can be accessed directly, without having to explicitly call GeminiHook itself.
It is recommended to embed GeminiHook, otherwise you'll have to specify a custom `self` on all calls you make into GeminiHook.


##GeminiHook:Hook([object], method, [handler])
Hook a function or a method on an object. 
The hook created will be a "safe hook", that means that your handler will be called before the hooked function ("Pre-Hook"), and you don't have to call the original function yourself, however you cannot stop the execution of the function, or modify any of the arguments/return values.
This type of hook is typically used if you need to know if some function got called, and don't want to modify it.

###Parameters

* **object**
	* The object to hook a method from

* **method**
	* If object was specified, the name of the method, or the name of the function to hook.

* **handler**
	* The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked function)

###Usage

```lua
-- create an addon with GeminiHook embeded
MyAddon = Apollo.GetPackage("Gemini:Addon-1.0").tPackage:NewAddon("HookDemo", false, {}, "Gemini:Hook-1.0")

function MyAddon:OnEnable()
  -- Hook GetCurrentZoneName
  self:Hook("GetCurrentZoneName")
end

function MyAddon:GetCurrentZoneName()
  Print("Showing Zone Name!")
end
```

##GeminiHook:IsHooked([obj], method)
Check if the specific function, method or script is already hooked.

###Parameters

* **obj**
	* The object or frame to unhook from

* **method**
	* The name of the method, function or script to unhook from.


##GeminiHook:RawHook([object], method, [handler])
RawHook a function or a method on an object. 
The hook created will be a "raw hook", that means that your handler will completly replace the original function, and your handler has to call the original function (or not, depending on your intentions).
The original function will be stored in `self.hooks[object][method]` or `self.hooks[functionName]` respectively.
This type of hook can be used for all purposes, and is usually the most common case when you need to modify arguments or want to control execution of the original function.

###Parameters

* **object**
	* The object to hook a method from

* **method**
	* If object was specified, the name of the method, or the name of the function to hook.

**handler**
	* The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked function)

###Usage

```lua
-- create an addon with GeminiHook embeded
MyAddon = Apollo.GetPackage("Gemini:Addon-1.0").tPackage:NewAddon("HookDemo", false, {}, "Gemini:Hook-1.0")

function MyAddon:OnEnable()
  -- Hook OnGenerateTooltip
  self:RawHook(Apollo.GetAddon("Inventory"),"OnGenerateTooltip")
end

function MyAddon:OnGenerateTooltip(luaCaller, wndControl, wndHandler, tType, item)
  if item ~= nil and item:IsEquippable() then
    Print("Equippable item, no tooltip for you!")
  else
    self.hooks[Apollo.GetAddon("Inventory")].OnGenerateTooltip(luaCaller, wndControl, wndHandler, tType, item)
  end
end
```

##GeminiHook:PostHook([object], method, [handler])
Post Hook a function or a method on an object. 
Post Hooks are always called after the original function was called, and you cannot modify the arguments, return values or control the execution.  PostHook returns 2 arguments:
a table containing the return values of the original function and either nil or the return values of the hook function

###Parameters

* **object**
	* The object to hook a method from

* **method**
	* If object was specified, the name of the method, or the name of the function to hook.

* **handler**
	* The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked function)


##GeminiHook:Unhook([obj], method)
Unhook from the specified function, method or script.

Parameters

* **obj**
	* The object or frame to unhook from

* **method**
	* The name of the method, function or script to unhook from.


##GeminiHook:UnhookAll()
Unhook all existing hooks for this addon.