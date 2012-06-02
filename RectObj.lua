-- RectObj.lua

-- RectObj is a helper class that is used by things that have dimensions and angles
RectObj = class(PositionObj)

function RectObj:init(x,y,w,h)
    PositionObj.init(self,x,y)
    self.w = w
    self.h = h
    self.mode = CORNER
    self.angle = 0 -- in rads
    
end

---------------------- SETTERS -----------------------
function RectObj:setMode(mode)
    self.mode = mode
end

function RectObj:setSize(w,h)
    self.w = w
    self.h = h
end

-- ang in degrees
function RectObj:rotate(ang)
    self.angle = self.angle + math.rad(ang)
end

function RectObj:setAngle(ang)
    self.angle = math.rad(ang)
end

-- flips along the x-axis
function RectObj:flipX()
    self.x = self.x + self.w
    self.w = self.w * (-1)
end

---------------------- GETTERS -----------------------

function RectObj:getW()
    return self.w
end

function RectObj:getH()
    return self.h
end

function RectObj:getSize()
    return self.w,self.h
end

function RectObj:getAngle()
    return math.deg(self.angle)
end

function RectObj:inbounds(t)
    local x1,y1,x2,y2 = self:boundingBox()
    return (t.x>=x1 and t.y>=y1 and t.x<=x2 and t.y<=y2)
end

function RectObj:boundingBox()
    local x,y = self.x,self.y
    local w,h = self.w,self.h
    if w < 0 then
        w = -w
        x = x - w
    end
    if h < 0 then
        h = -h
        y = y - h
    end
    if mode == CENTER then
        x = x - w/2
        y = y - h/2
    end
    return x,y,x+w,y+h
end
