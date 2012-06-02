-- ShadowObj.lua
-- A spriteObj that also has a shadow. The shadowOffset method controls the offset of
-- the shadow relative to the spriteObj. It is configured for the stage shadows but
-- can be overwritten for other lightining configurations
-- Note that the SpriteObj and the shadow belong to different meshes so that they
-- can be set at different z-coordinates (but of course the same mesh can be used for both,
-- if so desired)
ShadowObj = class(SpriteObj)

-- defines the offset of the shadow relative to the main spriteObj. Feel free to
-- overwrite
function ShadowObj:shadowOffset(x,y)
    return math.floor((x - WIDTH/2)*100/WIDTH),math.floor((y - HEIGHT*.68)*40/HEIGHT)
end

function ShadowObj:init(x,y,w,h)
    SpriteObj.init(self,x,y,w,h)
    self.shadow = SpriteObj(x,y,w,h)
    self.sizeOff = vec2(0,0)
end

function ShadowObj:setSizeOff(dw,dh)
    self.sizeOff = vec2(dw,dh)
    self:positionShadow()
end

function ShadowObj:positionShadow()
    -- get the offsets of the corners
    local ox,oy = self:shadowOffset(self.x,self.y)
    local oxw,oyh = self:shadowOffset(self.x+self.w,self.y + self.h)
    
    local sx,sy = self.x+ox,self.y+oy
    local sxw = self.x + self.w + oxw
    local syh = self.y + self.h + oyh
    local sw,sh = sxw - sx + self.sizeOff.x, syh - sy + self.sizeOff.y
    -- set the location    
    self.shadow:translate(sx - self.shadow.x, sy - self.shadow.y)
    -- set the size
    self.shadow:setSize(sw,sh)
end

----- Overwrite the various setters from SpriteObj to update the shadow as well ----
function ShadowObj:setMode(mode)
    SpriteObj.setMode(self,mode)
    self.shadow:setMode(mode)
    self:positionShadow()
end

function ShadowObj:setSize(w,h)
    SpriteObj.setSize(self,w,h)
    --self.shadow:setSize(w,h) -- positionShadow sets the size
    self:positionShadow()
end

function ShadowObj:translate(dx,dy)
    SpriteObj.translate(self,dx,dy)
    -- self.shadow:translate(dx,dy)  -- positionShadow sets the position
    self:positionShadow()
end

-- ang in degrees
function ShadowObj:rotate(ang)
    SpriteObj.rotate(self,ang)
    self.shadow:rotate(ang)
    self:positionShadow()
end

function ShadowObj:setAngle(ang)
    SpriteObj.setAngle(self,ang)
    self.shadow:setAngle(ang)
    self:positionShadow()
end
