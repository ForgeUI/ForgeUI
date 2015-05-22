CallbackHandler
===============

CallbackHandler is a back-end utility library that makes it easy for a library to fire its events to interested parties.  This project an adaptation of the original CallbackHandler used in World of Warcraft for WildStar.  As such this documentation is almost identical to the World

##Including CallbackHandler-1.0 into your project

###Package
* get a copy of the current version
* copy CallbackHandler-1.0.lua into your library's folder
* set up your <library>.toc file to load CallbackHandler-1.0.lua (in case you support stand alone loading of the lib)

##Mixing in the CallbackHandler functions in your library
```lua
MyLib.callbacks = MyLib.callbacks or 
  Apollo.GetPackage("Gemini:CallbackHandler-1.0").tPackage:New(MyLib)
```

This adds 3 methods to your library:

* MyLib.RegisterCallback(self, "eventName"[, method, [arg]])
* MyLib.UnregisterCallback(self, "eventname")
* MyLib.UnregisterAllCallbacks(self)

_Make sure that the passed in self is your addon, and not the library itself, so the double-colon syntax will not work._

The "MyLib.callbacks" object is the callback registry itself, which you need to keep track of across library upgrades.

##Firing events
Assuming your callback registry is "MyLib.callbacks", firing named events is as easy as:

```lua
MyLib.callbacks:Fire("EventName", arg1, arg2, ...)
```

All arguments supplied to :Fire() are passed to the functions listening to the event.

##Advanced uses
###Renaming the methods

You can specify your own names for the methods installed by CallbackHandler:

```lua
MyLib.callbacks= MyLib.callbacks or 
  Apollo.GetPackage("Gemini:CallbackHandler-1.0").tPackage:New(MyLib, 
  "MyRegisterFunc", "MyUnregisterFunc", "MyUnregisterAllFunc" or false)
```

Giving **false** as the name for UnregisterAll means that you do not want to give users access to that API at all - it will not be installed.

##Tracking events being used

In some cases, it makes sense to know which events are being requested by your users. Perhaps to enable/disable code needed to track them.

CallbackHandler will always call *registry*:OnUsed() and :OnUnused() when an event starts/stops being used:

```lua
function MyLib.callbacks:OnUsed(target, eventname)
  -- "target" is == MyLib here
  print("Someone just registered for "..eventname.."!")
end

function MyLib.callbacks:OnUnused(target, eventname)
  print("Noone wants "..eventname.." any more")
end
```

"OnUsed" is only called if the event was previously unused. "OnUnused" is only called when the last user unregisters from an event. In other words, you won't see an "OnUnused" unless "OnUsed" has been called for an event. And you won't ever see two "OnUsed" in a row without "OnUnused" in between for an event.

##Multiple event registries

As you may or may not know, CallbackHandler is the workhorse of GeminiEvent. It is used twice in GeminiEvent: once for in-game events, and once for "messages".

Providing multiple registries in GeminiEvent was as easy as:

```lua
GeminiEvent.events = GeminiEvent.events or 
  Apollo.GetPackage("Gemini:CallbackHandler-1.0").tPackage:New(GeminiEvent, 
    "RegisterEvent", "UnregisterEvent", "UnregisterAllEvents")

GeminiEvent.SendEvent = Event_FireGenericEvent

GeminiEvent.messages = GeminiEvent.messages or 
  Apollo.GetPackage("Gemini:CallbackHandler-1.0").tPackage:New(GeminiEvent, 
    "RegisterMessage", "UnregisterMessage", "UnregisterAllMessages")

GeminiEvent.SendMessage = GeminiEvent.messages.Fire
```
Of course, there is also some code in GeminiEvent to do the actual driving of in-game events (using OnUsed and OnUnused), but this is really the core of it.