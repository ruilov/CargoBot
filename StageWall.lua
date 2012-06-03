-- StageWall.lua

StageWall = class(Panel)

function StageWall:init(x,y,w,h,screen)
    Panel.init(self,x,y)
    
    -- dimensions needed for the physics
    self.w = w
    self.h = h
    
    -- make the pole
    local obj = ShadowObj(-w/2,8,w,h-16)
    self:add(obj)
    screen:doDraw(obj,"Cargo Bot:Claw Arm",0,-8)
    self.pole = obj -- for detecting when we collide

    -- the top base
    local obj = ShadowObj(16,h-9,-32,9)
    self:add(obj)
    screen:doDraw(obj,"Cargo Bot:Claw Base",0,-8)

    -- the bottom base
    local obj = ShadowObj(16,9,-32,-9)
    self:add(obj)
    screen:doDraw(obj,"Cargo Bot:Claw Base",0,-8)
    self.base = obj -- needed for the physics
    
    -- so that the sprite shadows show in the correct direction
    if self.x > WIDTH / 2 then self:flipX() end
end
