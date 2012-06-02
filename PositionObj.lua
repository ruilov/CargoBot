-- PositionObj.lua

-- a helper class that is subclassed by anything that has a position
PositionObj = class()

function PositionObj:init(x,y)
    self.x = x
    self.y = y
end

function PositionObj:translate(dx,dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function PositionObj:getX()
    return self.x
end

function PositionObj:getY()
    return self.y
end

function PositionObj:getPos()
    return self.x,self.y
end
