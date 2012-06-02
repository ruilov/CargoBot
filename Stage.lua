-- Stage.lua
-- stage is where the action happens. handles the claw animation based on commands that
-- are passed in

Stage = class(BaseStage)

function Stage.config()
    local config = {x=0,y=380,w=768,h=312,sprite="Cargo Bot:Game Area"}
    config.shadows = true
    config.maxPiles = 9
    config.crate = {w=40,h=40,borderY=-2,shadows=config.shadows}
    
    -- setup dimensions for the piles
    config.pile = {
        y = 0,
        base={h=14,borderY=-3,sprite="Cargo Bot:Platform"},
        crate=config.crate,
        shadows = config.shadows
    }
    -- we need pile width to know how far apart to draw the piles
    config.pile.w = math.floor(config.w / config.maxPiles)
    config.pile.h = config.h -- needed for editor mode to know whether a block should be added
    config.pile.base.w = math.floor(config.pile.w*.8)
    
    -- setup dimensions for the claw
    config.claw = {
        middleH = 13,  -- height of the horizontal extendible beam
        maxHoleW = 60,  -- the maximum allowed width of the claw hole
        beamSprite = "Cargo Bot:Claw Middle",
        leftSprite = "Cargo Bot:Claw Left",
        rightSprite = "Cargo Bot:Claw Right",
        w = 100 -- for editor mode
    }

    config.claw.arm = {w=18,h=56,border=4}  -- border is so that the claw touches the crate
    config.claw.base = {w=31,h=9,sprite="Cargo Bot:Claw Base"}
    config.claw.pole = {w=14,minH=5,sprite="Cargo Bot:Claw Arm"}
    config.claw.crate = config.crate    
    config.claw.minH = config.crate.h+config.claw.middleH+config.claw.base.h+config.claw.pole.minH
    config.claw.maxH = config.h - config.pile.base.h - config.pile.base.borderY
    -- clawLength is diff between the end of the pole and the end of the claw
    config.claw.clawLength = math.floor(config.claw.crate.h*.85 + config.claw.middleH)
    
    config.crateSprites = {
        blue = {"Cargo Bot:Crate Blue 1","Cargo Bot:Crate Blue 2","Cargo Bot:Crate Blue 3"},
        red = {"Cargo Bot:Crate Red 1","Cargo Bot:Crate Red 2","Cargo Bot:Crate Red 3"},
        green = {"Cargo Bot:Crate Green 1","Cargo Bot:Crate Green 2","Cargo Bot:Crate Green 3"},
        yellow = {"Cargo Bot:Crate Yellow 1","Cargo Bot:Crate Yellow 2",
            "Cargo Bot:Crate Yellow 3"},
    }
    -- the little dx offsets
    config.crateOffsets = {min=-2,max=2}
    return config
end

function Stage:init(screen,state)
    BaseStage.init(self,Stage.config(),screen,state.piles)
    self.clawPos = state.claw
    self.initClawPos = state.claw
    self.speed = 8
    self:makeWalls()
    self:createClaw()
    self.editorM = false
end

function Stage:bindEvents()
    Events.bind("play",self,Stage.play)
    Events.bind("fast",self,Stage.fast)
end

function Stage:play(val)
    self:resetAnimation()
    -- reset the state
    if not val then self:resetState() end
    if self.bodies then self:clearPhysics() end
end

function Stage:fast(val)
    if val then self.speed = 30
    else self.speed = 8 end
end

function Stage:resetAnimation()
    self.animation = "na" -- used for animating the claw moves
    self.move = ""
    self.isWaiting = true
end

function Stage:resetState()
    BaseStage.resetState(self)

    -- reset the claw
    self.clawPos = self.initClawPos
    self:positionClaw()
end

function Stage:copyState(other)
    BaseStage.copyState(self,other)
    
    self.clawPos = other.clawPos
    self:positionClaw()
end

function Stage:positionClaw()
    self.claw:dropCrate()
    self.claw:open()
    local clawX = self:clawX()
    local clawY = self.config.h
    self.claw:translate(clawX+self.x-self.claw.x,clawY+self.y-self.claw.y)
    local clawH = self.config.claw.minH
    self.claw:extend(clawH - self.claw.h)
end

-- returns the x coord of the claw if it were at its clawPos
function Stage:clawX(pos)
    pos = pos or self.clawPos
    return self.piles[1].x + math.floor(self.config.pile.w * (pos-.5))
end

function Stage:makeWalls()
    local h = self.config.h
    local w = 15
    local y = 0
    local xs = {self:clawX(0),self:clawX(#self.piles+1)}
    if #self.piles == 8 then -- put the walls a little closer to they don't go off screen
        xs[1] = xs[1] + self.config.pile.w*.2
        xs[2] = xs[2] - self.config.pile.w*.2
    end
    
    self.walls = {}
    local wall = StageWall(xs[1],y,w,h,self.screen)
    self:add(wall)
    wall:translate(xs[1]-wall.x+self.x,y-wall.y+self.y)
    table.insert(self.walls,wall)
    
    local wall = StageWall(xs[2],y,w,h,self.screen)
    self:add(wall)
    wall:translate(xs[2]-wall.x+self.x,y-wall.y+self.y)
    table.insert(self.walls,wall)
end

-- doesnt necessarily recreate the claw. if not, then it 
-- resets the claw position
function Stage:createClaw()
    local clawY = self.config.h
    local clawH = self.config.claw.minH
    local clawX = self:clawX()
    self.claw = Claw(clawX,clawY,clawH,self.config.claw,self.screen)
    self:add(self.claw)
end

function Stage:nextMove(move)
    self.move = move
    if move == "pickup" then 
        self.animation = "lower"
        
        -- calculate dt for the sound library
        local pile = self.piles[self.clawPos]
        local numBlocks = pile.crates:size()
        if self.claw.crate then numBlocks = numBlocks + 1 end
        local maxH = self.claw:maxHeight(numBlocks)
        local dy = maxH - self.claw.h
        local dt = dy / self.speed * MY_DELTA_TIME        
        sounds:play("claw_down",dt)
    elseif move == "right" or move == "left" then
        
        -- check whether there's enough room to move
        local dp = 1
        if move == "left" then dp = -1 end
        self.clawPos = self.clawPos + dp
        
        -- calculate time to destination for the sound library
        local dx = math.abs(self:clawX() - self.claw.x)
        local dt = dx / self.speed * MY_DELTA_TIME
        --sounds:play("claw_sideways",dt)
    elseif move == "" or move:sub(1,1) == "f" then -- nothing
    else print("invalid move: ",self.move) end
end

function Stage:tick()
    -- if we're simulating physics
    if self.bodies then 
        self:tickPhysics()
        return nil
    end
    
    -- move is nil if we haven't initialized the animation yet
    if self.move == nil then return nil end
    
    -- otheriwse do the numarl simulation
    local speed = math.floor(self.speed*DeltaTime*60)
    
    if self.move == "pickup" then 
        self.isWaiting = self:pickupAnimation(speed)
    elseif self.move == "left" then 
        self.isWaiting = self:moveClawAnimation(-1,speed)
    elseif self.move == "right" then 
        self.isWaiting = self:moveClawAnimation(1,speed)
    elseif self.move == "" or self.move:sub(1,1) == "f" then 
        self.isWaiting = true
    else 
        assert(false,"invalid move: "..self.move) 
    end
end

-- move claw left/right
function Stage:moveClawAnimation(dir,speed)
    local targetX = self:clawX()
    local dx = math.min(speed,(targetX - self.claw.x)*dir)*dir
    self.claw:translate(dx,0)
    
    -- detect toppling a pile
    local oldPos = self.clawPos + dir * (-1)
    self:checkPileToppled(oldPos,dir)
    self:checkOutOfBounds(dx)
    return self.claw.x == targetX
end

-- checks if the claw will topple a pile. oldPos is the position that the claw is leaving
function Stage:checkPileToppled(oldPos,dir)
    local leavingPile = self.piles[oldPos]
    if leavingPile.crates:size() > 6 then
        local topCrate = leavingPile.crates:peek()
        local topX1 = topCrate.obj:getX()
        local topX2 = topCrate.obj:getX() + topCrate.obj:getW()
        if topCrate.obj:getW() < 0 then
            topX1, topX2 = topX2, topX1
        end
        
        if dir > 0 then
            if self.claw.leftArm:getX() + self.claw.leftArm:getW() > topX1 then
                self:pileToppled(topCrate,dir)
            end
        else
            if self.claw.rightArm:getX() < topX2 then
                self:pileToppled(topCrate,dir)
            end
        end
    end
end

-- checks if the claw is going out of bounds
function Stage:checkOutOfBounds(dx)
    if self.claw.leftArm:getX() < self.walls[1].pole.x + self.walls[1].pole.w then
        self.claw:translate(-dx,0)
        self:clawOOB(self.claw.leftArm,-1)
    elseif self.claw.rightArm:getX() + self.claw.rightArm:getW() > self.walls[2].x then
        self.claw:translate(-dx,0)
        self:clawOOB(self.claw.rightArm,1)
    end
end

-- does the pickup animation
function Stage:pickupAnimation(speed)
    if self.animation == "lower" then
        self:lowerClaw(speed)
    elseif self.animation == "close" then
        self:closeClaw(speed)
    elseif self.animation == "open" then
        self:openClaw(speed)
    elseif self.animation == "higher" then
        if self.claw.h > self.config.claw.minH then
            local dy = math.min(speed,self.claw.h - self.config.claw.minH)
            self.claw:extend(-dy)
        else -- we finished retracting the claw
            return true
        end 
    end
    return false
end

function Stage:lowerClaw(speed)
    -- calculate how low the claw can go given the num of blocks 
    -- in its pile
    local pile = self.piles[self.clawPos]
    local numBlocks = pile.crates:size()
    if self.claw.crate then numBlocks = numBlocks + 1 end
    local maxH = self.claw:maxHeight(numBlocks)
        
    if self.claw.h < maxH then
        -- make the claw longer by self.speed
        dy = math.min(speed,maxH - self.claw.h)
        self.claw:extend(dy)
    else
        -- check if we should drop a block
        if self.claw.crate then
            local crate = self.claw:dropCrate()
            local dx = math.random(self.config.crateOffsets.min,self.config.crateOffsets.max)
            pile:pushCrate(crate,dx)
            sounds:play("crate_drop")
            self.animation = "open"
        else  -- we're not holding a block
            self.animation = "close"
        end
    end
end

function Stage:closeClaw(speed)
    if self.claw.holeW > self.claw:minHoleW() then
        local dx = math.min(speed,self.claw.holeW - self.claw:minHoleW())
        self.claw:open(-dx)
    else -- finished closing, check if we should pick up a block
        local pile = self.piles[self.clawPos]
        if pile.crates:size() > 0 then
            -- pick up this block
            local crate = pile:pop()
            self.claw:getCrate(crate)
            sounds:play("claw_grabs_box")
            --sounds:play("claw_up")
            self.animation = "higher"
        else -- finished closing and didn't find a block
            self.animation = "open"
            sounds:play("claw_squeeze_empty")
        end
    end
end

function Stage:openClaw(speed)
    if self.claw.holeW < self.config.claw.maxHoleW then
        local dx = math.min(speed, self.config.claw.maxHoleW - self.claw.holeW)
        self.claw:open(dx)
    else 
        self.animation = "higher"
            
        -- calculate dt for the sound library
        local dy = self.claw.h - self.config.claw.minH
        local dt = dy / self.speed * MY_DELTA_TIME
        --sounds:play("claw_up")
    end
end
