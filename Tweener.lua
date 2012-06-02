-- Tweener.lua

Tweener = class()

_tweeners = {}

function Tweener.add(tweener)
    table.insert(_tweeners,tweener) 
end

function Tweener.remove(tweener)
    Table.remove(_tweeners,tweener)
end

function Tweener.run()
    local clone = Table.clone(_tweeners)
    Table.map(function(x) x:tick() end,clone)
end

-- startObj and endObj are SpriteObj
-- objs are scaled and translated by the tweener so that at then end they are at
-- endObj's current position/size
-- Alpha is also modified, so that at the end endObj has its current alpha and
-- startObj has zero alpha
function Tweener.alphaTransition(dt,startObj,endObj)
    local startX,startY = startObj:getPos()
    local startW,startH = startObj:getSize()
    local endX,endY = endObj:getPos()
    local endW,endH = endObj:getSize()
    
    local startAlpha = startObj.tint.a
    local endAlpha = endObj.tint.a
    
    local tickFunc = function(tFrac)
        -- translate, setSize
        local newX = startX + tFrac * (endX - startX)
        local newY = startY + tFrac * (endY - startY)
        local newW = startW + tFrac * (endW - startW)
        local newH = startH + tFrac * (endH - startH)
        
        startObj:translate(newX - startObj:getX(),newY - startObj:getY())
        startObj:setSize(newW,newH)
        endObj:translate(newX - endObj:getX(),newY - endObj:getY())
        endObj:setSize(newW,newH)
        
        -- alpha changes
        local newStartAlpha = startAlpha + tFrac^(.25) * (0-startAlpha)
        local oldTint = startObj.tint
        startObj:setTint(color(oldTint.r,oldTint.g,oldTint.b,newStartAlpha))
        
        local newEndAlpha = 0 + tFrac^(0.25) * (endAlpha-0)
        local oldTint = startObj.tint
        endObj:setTint(color(oldTint.r,oldTint.g,oldTint.b,newEndAlpha))
    end
    
    tickFunc(0)
    local tweener = Tweener(dt,tickFunc)
    return tweener
end

function Tweener:init(dt,tickFunc,doneFunc)
    assert(dt~=nil,"dt cannot be nil")
    self.dt = dt
    self.t = 0
    self.tickFunc = tickFunc
    self.doneFunc = doneFunc
end

function Tweener:tick()
    if self.tickFunc then
        self.tickFunc(self.t/self.dt) 
    end
    self.t = self.t + DeltaTime
    if self.t >= self.dt then
        if self.tickFunc then
            self.tickFunc(1)
        end
        self:done() 
    end
end

function Tweener:done()
    if self.doneFunc then self.doneFunc() end
    Tweener.remove(self)
end

