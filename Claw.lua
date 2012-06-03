-- Claw.lua

Claw = class(Panel)

function Claw:init(x,y,h,config,screen)
    Panel.init(self,x,y)
    
    self.screen = screen
    self.config = config
    
    self.h = h  -- the full height
    
    self.holeW = self.config.maxHoleW
    self:addElems(h)
end

function Claw:addElems(h)
    -- clawLength is diff between the end of the pole and the end 
    -- of the claw
    local clawLength = self.config.clawLength
    -- pole end is well where the pole ends and the claw beams start
    local poleEnd = h - clawLength
    
    -- pole
    local offset = math.floor(-self.config.pole.w/2)
    self.pole = ShadowObj(offset,-poleEnd-2,self.config.pole.w,poleEnd-self.config.base.h+4)
    self.screen:doDraw(self.pole,self.config.pole.sprite,1,-8)
    self.pole:setSizeOff(0,-1)
    self:add(self.pole)
    
    -- horizontal beam
    local mh = self.config.middleH
    local horX = math.floor(-self.holeW/2)
    local horY = -poleEnd - mh
    self.beam = ShadowObj(horX-1,horY,self.holeW + 2, mh)
    self.screen:doDraw(self.beam,self.config.beamSprite,1,-8)
    self:add(self.beam)
    
    -- base
    local offset = math.floor(-self.config.base.w/2)
    local base = ShadowObj(offset,-self.config.base.h,self.config.base.w,self.config.base.h)
    self.screen:doDraw(base,self.config.base.sprite,2,-8)
    self:add(base)
    
    -- left arm
    local horX = math.floor(-self.holeW/2) - self.config.arm.w
    -- the vertical beam on the left
    self.leftArm = ShadowObj(horX,-h,self.config.arm.w,self.config.arm.h)
    self.screen:doDraw(self.leftArm,self.config.leftSprite,3,-8)
    self:add(self.leftArm)
    
    -- right arm
    local horX = math.floor(-self.holeW/2) + self.holeW
    self.rightArm = ShadowObj(horX,-h,self.config.arm.w,self.config.arm.h)
    self.screen:doDraw(self.rightArm,self.config.rightSprite,3,-8)
    self:add(self.rightArm)
end

-- drops the crate from the claw
function Claw:dropCrate()
    if self.crate then 
        self:remove(self.crate)
        self.screen:undoDraw(self.crate.obj)
    end
    local crate = self.crate
    self.crate = nil
    return crate
end

-- opens the hole by dx
-- optional in which case it opens all the way
function Claw:open(dx)
    dx = dx or (self.config.maxHoleW - self.holeW)
    self.holeW = self.holeW + dx
    
    self.beam:translate(-dx/2,0)
    local beamW,beamH = self.beam:getSize()
    self.beam:setSize(beamW + dx, beamH)
    self.leftArm:translate(-dx/2,0)
    self.rightArm:translate(dx/2,0)
end

-- positive dy makes it longer, negative makes it shorter 
function Claw:extend(dy)
    self.h = self.h + dy
    
    -- move a bunch of elems
    self.pole:translate(0,-dy)
    local poleW,poleH = self.pole:getSize()
    self.pole:setSize(poleW,poleH + dy)
    self.beam:translate(0,-dy)
    self.leftArm:translate(0,-dy)
    self.rightArm:translate(0,-dy)
    
    if self.crate then self.crate:translate(0,-dy) end
end

-- max height depends on the number of crates in the pile
function Claw:maxHeight(nCrates)
    if nCrates == 0 then 
        return self.config.maxH
    else
        -- temp is where the bottom of the middle beam needs to be
        local temp = self.config.maxH - 
            (self.config.crate.h + self.config.crate.borderY) * nCrates
        return temp + self.config.clawLength - self.config.middleH
    end
end

-- min hole width is enough for holding a crate
function Claw:minHoleW()
    return self.config.crate.w - 2
end

-- picks up a crate of this sprite type
function Claw:getCrate(crate)    
    self.crate = crate
    self.crate:addToScreen(self.screen)
    
    -- reposition this crate relative to the claw's coords before adding it
    local x = math.floor(-self.config.crate.w/2)
    local y = -(self.h - self.config.clawLength + self.config.middleH + 
        self.config.crate.h + self.config.crate.borderY)
    self.crate:translate(x - self.crate.x, y - self.crate.y)
    self:add(self.crate)
end

-- called after physics simulation
function Claw:repositionArms()
    --beam
    local clawLength = self.config.clawLength
    local poleEnd = self.h - clawLength
    local mh = self.config.middleH
    local x = math.floor(-self.holeW/2)-1
    local y = -poleEnd - mh
    self.beam:translate(x+self.x-self.beam.x,y+self.y-self.beam.y)
    self.beam:setAngle(0)
    
    -- left arm
    local x = math.floor(-self.holeW/2) - self.config.arm.w + self.x
    local y = -self.h + self.y
    self.leftArm:translate(x-self.leftArm.x,y-self.leftArm.y)
    self.leftArm:setAngle(0)

    -- right arm
    local x = math.floor(-self.holeW/2) + self.holeW + self.x
    local y = -self.h + self.y
    self.rightArm:translate(x-self.rightArm.x,y-self.rightArm.y)
    self.rightArm:setAngle(0)
end
