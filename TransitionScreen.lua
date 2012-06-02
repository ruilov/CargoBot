-- TransitionScreen.lua
-- a screen that shows two walls of crates closing in and then out when we switch between
-- game screens

TransitionScreen = class(Screen)

function TransitionScreen:init()
    Screen.init(self)
    self.closeAmount = 1
    
    -- create the walls
    local crateW,crateH = spriteSize("Cargo Bot:Title Large Crate 1")
    self.walls = {{},{}}
    for wallIdx,wallX in ipairs({-crateW/2,WIDTH/2}) do
        -- for each wall
        for x = 1,WIDTH/2,crateW do
            -- each pile
            local numCrates = math.random(3,10)
            for crateIdx=1,numCrates do
                -- each crate
                local offset = math.random(-5, 5) * ((crateIdx+1)/numCrates)
                local obj = SpriteObj(wallX+x+offset,(crateIdx-1)*crateH,crateW,crateH)
                if math.random() < .5 then obj:flipX() end
                local spr = "Cargo Bot:Title Large Crate " .. math.random(1,3)
                self:doDraw(obj,spr,1)

                obj:setAngle(math.random(-3,3))
                local shade = math.min( (crateIdx-1)*20 + math.random(50,90), 255 )
                obj:setTint(color(shade,shade,shade,255))
                self.walls[wallIdx][obj] = shade
                
                obj.closedX = obj.x
                if wallIdx == 1 then obj.openX = obj.x - WIDTH/2
                else obj.openX = obj.x + WIDTH/2 end
            end
        end
    end
end

function TransitionScreen:draw()
    if self.background then
        self.background:draw()
        spriteMode(CORNER)
        tint(50,50,70,255*self.closeAmount)
        sprite("Cargo Bot:Game Lower BG",0,0,WIDTH,HEIGHT)
    end
    Screen.draw(self)
end

-- closes and opens the walls
function TransitionScreen:setCloseAmount(val)
    self.closeAmount = val
    for _,wall in ipairs(self.walls) do
        for obj,_ in pairs(wall) do
            local x = obj.openX * (1 - val) + obj.closedX * val
            obj:translate(x-obj.x,0)
        end
    end
end

-- fades the screen in and out with tint. Used for the splashscreen
function TransitionScreen:setBrightness(p) -- p is between 0 and 1
    for _,wall in ipairs(self.walls) do
        for block,shade in pairs(wall) do
            block:setTint(color(p*shade,p*shade,p*shade,255))
        end
    end
end

function TransitionScreen:start(oldScreen,newScreen,skipCutScene)
    self:bind()
    if oldScreen then oldScreen:unbind() end
    
    if skipCutScene then
        self:unbind()
        currentScreen = newScreen
        currentScreen:bind()
        return nil
    end
    
    self.newScreen = newScreen
    self.background = oldScreen
    self.midCallback = nil
    self.endCallback = nil
    self.openTime = .5
    
    local tweener = Tweener(.7,function(p) self:setCloseAmount(math.min(1,7/5*p)) end,
            function() self:openIt() end )
    Tweener.add(tweener)
end

-- used by the splashScreen
function TransitionScreen:startClosed(oldScreen,newScreen)
    self:bind()
    if oldScreen then oldScreen:unbind() end
    
    self.newScreen = newScreen
    self.background = oldScreen
    self.midCallback = nil
    self.endCallback = nil
    self.openTime = 1.5
    self:setCloseAmount(1)
    self:setBrightness(0)
    self:setTint(color(0,0,0,255))
    local tweener = Tweener(1.5,function(p) 
        if p < .5 then self:setBrightness(p/.5) end
    end,function() self:setBrightness(1) self:openIt() end )
    Tweener.add(tweener)
end

function TransitionScreen:openIt()
    self.background = self.newScreen
    
    self:unbind()
    self.newScreen:bind()
    -- used by winscreen.replay
    if self.midCallback then self.midCallback() end
    
    local tweener = Tweener(self.openTime,function(p) self:setCloseAmount((1-p)) end,
        function() 
            currentScreen = self.newScreen
            -- used for when we select a level, from level select or winscreen.next
            if self.endCallback then self.endCallback() end
        end)
    Tweener.add(tweener)
end
