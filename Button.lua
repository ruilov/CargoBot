-- Button.lua
-- a little useful class for objects that know how to handle touches

Button = class(SpriteObj)

function Button:init(x,y,w,h)
    SpriteObj.init(self,x,y,w,h)
    self.active = true
    self.extras = {left=0,right=0,top=0,bottom=0}
end

function Button:setExtras(extras)
    for k,v in pairs(extras) do
        self.extras[k] = v
    end
end

function Button:onTouched(t) end -- user defined
function Button:onEnded(t) end -- user defined
function Button:onBegan(t) end -- user defined
function Button:onMoving(t) end -- user defined

-- return values used by the screen class to implement z-order for buttons
function Button:touched(t)
    if self:inbounds(t) then
        self:onTouched(t)
        if t.state == BEGAN then self:onBegan(t)
        elseif t.state == MOVING then self:onMoving(t)
        elseif t.state == ENDED then self:onEnded(t)
        end
        return true
    end
    return false
end

function Button:inbounds(t)
    local x1,y1,x2,y2 = self:boundingBox()
    x1 = x1 - self.extras.left
    y1 = y1 - self.extras.bottom
    x2 = x2 + self.extras.right
    y2 = y2 + self.extras.top
    return (t.x>=x1 and t.y>=y1 and t.x<=x2 and t.y<=y2)
end
