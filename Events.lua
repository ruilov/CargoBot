-- Events.lua

-- Events facilitates message passing between objects. 
-- Mostly for user generated events
-- but some internal events too like "won" or "died" or "moveDone"
-- Classes that respond to events should define a bindEvents method where all the events 
-- are bound so that they can be easily rebinded if needed
Events = class()

Events.__callbacks = {}

function Events.bind(event,obj,func)
    if not Events.__callbacks[event] then
        Events.__callbacks[event] = {}
    end
    
    if not Events.__callbacks[event][obj] then
        Events.__callbacks[event][obj] = {}
    end
    
    Events.__callbacks[event][obj][func] = 1
end

-- event is optional
function Events.unbind(obj,event)
    for evt,cbs in pairs(Events.__callbacks) do
        if event == nil or event == evt then
            cbs[obj]=nil
        end
    end
end

function Events.unbindEvent(event)
    Events.__callbacks[event] = nil
end

function Events.trigger(event,...)
    if Events.__callbacks[event] then
        -- make a clone of the callbacks. This is because callbacks 
        -- can bind or unbind events. for example Stage.play can
        -- recreate its state and needs to rebind
        local clone = {}
        for obj,funcs in pairs(Events.__callbacks[event]) do
            clone[obj] = {}
            for func,dummy in pairs(funcs) do
                clone[obj][func] = 1
            end
        end

        for obj,funcs in pairs(clone) do
            for func,dummy in pairs(funcs) do
                
                local argCopy = Table.clone(arg)
                table.insert(argCopy,1,obj)
                func(unpack(argCopy))
            end
        end
    end
end
