-- StagePhysics.lua
-- implements methods for when the stage animation is in physics mode
-- this happens if a pile more than 6 crates high (pileToppled) or
-- if the claw goes out of bounds (clawOOB)

-- callback for pile toppled events
function Stage:pileToppled(crate,dir)
    self.claw:open(20) -- give the crate some extra space
    
    self:startPhysics()
    
    -- apply force to the crate
    for body,info in pairs(self.bodies) do
        if info.obj == crate.obj then
            body:applyForce(vec2(3000,-2000)*dir)
        end
    end
end

-- callback for claw out of bounds
function Stage:clawOOB(arm,dir)
    sounds:play("bump_claw")
    self:startPhysics(true)

    -- apply force to the arm
    for body,info in pairs(self.bodies) do
        if info.obj == arm then
            body:applyForce(vec2(200*(-dir),-100),vec2(info.obj:getX(),info.obj:getY()))
        end
    end
end

function Stage:startPhysics(includeClaw)
    physics.gravity(vec2(0,-1000))
    self.bodies = self:physicsBodies(includeClaw)
    physics.resume()
end

function Stage:clearPhysics()
    if not self.bodies then return nil end
    
    for body,info in pairs(self.bodies) do
        body:destroy()
    end
    self.bodies = nil
    physics.pause()
    
    -- reset the claw arms
    self.claw:repositionArms()
end

function Stage:tickPhysics()
    if not self.bodies then return nil end

    --self:drawBodies()
    
    for body,info in pairs(self.bodies) do
        local w,h = 0,0
        local points = body.points
        for _,p in ipairs(points) do
            w = math.max(w,p.x)
            h = math.max(h,p.y)
        end
            
        if body.type == DYNAMIC then
            local obj = info.obj
            obj:setAngle(body.angle) 
            
            -- calculate the center of the physics body
            local bodyCenter = vec2(w,h)/2
            bodyCenter = bodyCenter:rotate(math.rad(body.angle))
            bodyCenter = bodyCenter + vec2(body.x,body.y)
            
            -- calculate the center of the sprite obj
            local objCenter = vec2(obj:getX(),obj:getY()) +
                vec2(obj:getW(),obj:getH())/2
            
            -- translate the obj
            local dpos = bodyCenter - objCenter
            obj:translate(dpos.x,dpos.y)
        end
    end
end

function Stage:collide(contact)
    local a = contact.bodyA
    local b = contact.bodyB
    
    -- this shouldn't happen but codea seems to have a bug and it does happen
    if a==nil or b==nil then return nil end
    
    local infoa = self.bodies[a]
    local infob = self.bodies[b]
    
    -- this shouldnt be needed either but alas
    if infoa == nil or infob == nil then return nil end
    
    if a.type ~= STATIC or b.type ~= STATIC then
        local normal = contact.normalImpulse
        if normal > 0 then
            sounds:collide(infoa.type,infob.type,contact)
        end
    end
end

-- includeClaw true means that the claw is dynamic, otherwise it's static
function Stage:physicsBodies(includeClaw)
    local bodies = {}

    for _,pile in ipairs(self.piles) do
        -- make the crates
        for crate in pile.crates:iter() do
            local w,h = crate.obj:getSize()
            local isInverted = false
            if w < 0 then 
                w = -w 
                isInverted = true
            end
            h = h - 2.5
            w = w - 2
            local box = physics.body(POLYGON,vec2(0,0),vec2(w,0),
                vec2(w,h),vec2(0,h))
                
            box.x = crate.obj:getX()
            if isInverted then box.x = box.x - (w+2) end
            
            box.y = crate.obj:getY()+2
            --box.density = 1
            box.restitution = .6
            box.friction = 0.08
            box.info = {type="crate"}
            bodies[box] = {obj=crate.obj,type="crate"}
        end
        
        -- make the pile bases
        local w,h = pile.base.w - 8,pile.base.h - 2
        local box = physics.body(POLYGON,vec2(0,0),vec2(w,0),
            vec2(w,h),vec2(0,h))
        box.x = pile.base.x + 4
        box.y = pile.base.y
        box.type = STATIC
        bodies[box] = {type="base"}
    end
    
    if includeClaw and self.claw.crate then
        local crate = self.claw.crate
        local w,h = crate.obj:getSize()
        local isInverted = false
        if w < 0 then 
            w = -w 
            isInverted = true
        end
        h = h - 2.5
        w = w - 2
        local box = physics.body(POLYGON,vec2(0,0),vec2(w,0),
            vec2(w,h),vec2(0,h))
        box.x = crate.obj:getX()
        if isInverted then box.x = box.x - (w+2) end
        box.y = crate.obj:getY()+2
        box.restitution = .6
        box.friction = 0.08
        bodies[box] = {obj=crate.obj,type="crate"}
    end

    -- make the claw arms
    local arms = {{self.claw.leftArm,leftArm},{self.claw.rightArm,rightArm}}
    for _,elem in ipairs(arms) do
        local arm,isDyn = elem[1],elem[2]
        local w,h = arm:getW(),arm:getH()
        local points = {vec2(w,0),vec2(w-6,0),vec2(1,33),vec2(9,h-2),vec2(w,h-2)}
        if arm == self.claw.rightArm then
            for _,p in ipairs(points) do
                p.x = arm:getW() - p.x + 1
            end
        end
        local box = physics.body(POLYGON,unpack(points))
        box.x = arm:getX()
        box.y = arm:getY()
        box.type = STATIC
        if includeClaw then 
            box.type = DYNAMIC
            box.restitution = .4
            box.friction = 0.08
        end
        bodies[box] = {obj=arm,type="claw"}
    end

    -- make the claw beam
    local w,h = self.claw.beam:getW(),self.claw.beam:getH()
    local box = physics.body(POLYGON,vec2(0,0),vec2(w,0),
        vec2(w,h),vec2(0,h))
    box.x = self.claw.beam:getX()
    box.y = self.claw.beam:getY()
    box.type = STATIC
    if includeClaw then 
        box.type = DYNAMIC
        box.restitution = .4
        box.friction = 0.08
    end
    bodies[box] = {obj=self.claw.beam,type="claw"}

    -- make the walls
    for _,wall in ipairs(self.walls) do
        local box = physics.body(POLYGON,vec2(0,0),vec2(wall.w,0),
            vec2(wall.w,wall.h),vec2(0,wall.h))
        box.x = wall.x - wall.w/2
        box.y = wall.y
        box.type = STATIC
        bodies[box] = {type="wall"}
        
        -- base
        local w,h = wall.base:getSize()
        local x,y = wall.base:getPos()
        local box = physics.body(POLYGON,vec2(0,0),vec2(w,0),
            vec2(w,h),vec2(0,h))
        box.x = x
        box.y = y
        box.type = STATIC
        bodies[box] = {type="wall"}
    end

    -- make the ground
    local ground = physics.body(POLYGON,vec2(0,0),vec2(WIDTH,0),
        vec2(WIDTH,20),vec2(0,20))
    ground.x = 0
    ground.y = self.config.y-20
    ground.type = STATIC
    bodies[ground] = {type="ground"}
    
    return bodies
end

-- for debugging
function Stage:drawBodies()
    if not self.bodies then return nil end
    pushStyle()
    noSmooth()
    strokeWidth(1)
    stroke(255, 255, 255, 255)
    for body,info in pairs(self.bodies) do
        pushMatrix()
        translate(body.x,body.y)
        rotate(body.angle)
        local points = body.points
        for idx,p in ipairs(points) do
            local p2 = points[idx%(#points)+1]
            line(p.x,p.y,p2.x,p2.y)
        end
        popMatrix()
    end
    popStyle()
end
