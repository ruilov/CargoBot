-- ShakeDetector.lua

ShakeDetector = class()

ShakeDetector.xs = {}
ShakeDetector.ys = {}
ShakeDetector.zs = {}

function ShakeDetector.check()
    local xs = ShakeDetector.xs
    local ys = ShakeDetector.ys
    local zs = ShakeDetector.zs
    
    table.insert(xs,UserAcceleration.x)
    table.insert(ys,UserAcceleration.y)
    table.insert(zs,UserAcceleration.z)
    while #xs > 10 do table.remove(xs,1) end
    while #ys > 10 do table.remove(ys,1) end
    while #zs > 10 do table.remove(zs,1) end
    local numSwitches = 0
    for _,arr in ipairs({xs,ys,zs}) do
        local avg = 0
        for i = 1, #arr-1 do
            avg = avg + math.abs(arr[i] - arr[i+1])
        end
        avg = avg / #arr
        if avg > .3 then numSwitches = numSwitches + 1 end
    end
        
    if numSwitches >= 2 then Events.trigger("shaking") end    
end
