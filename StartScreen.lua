-- StartScreen.lua
-- a screen that shows crates falling on the screen

StartScreen = class(Screen)

function StartScreen:init()
    Screen.init(self)
    
    physics.gravity(vec2(0,-1000))
    physics.resume()

    self.crateT = -100 -- when ellapsedtime is greater than this, spawn
    self.bodies = {}
    self.unusedPool = {}
    
    local tinyR = 4
    
    -- background
    local background = Button(0,0,WIDTH,HEIGHT)
    self:doDraw(background,"Cargo Bot:Opening Background",-2)
    background.onEnded = function(obj,t) 
        self:stopPhysics()
        --local packSelect = PackSelect()
        --transitionScreen:start(self,packSelect)
        local menuScreen = MenuScreen()
        transitionScreen:start(self,menuScreen)
        currentScreen = transitionScreen
    end
    
    -- title
    local title = SpriteObj(35,650,699,150)
    self:doDraw(title,"Cargo Bot:Cargo Bot Title",1)
    
    -- made with codea
    local codea = Button(20,20,186,32)
    self:doDraw(codea,"Cargo Bot:Made With Codea")
    codea:setTint(color(255,255,255,128))
    codea.onEnded = function(obj,t)
        openURL( "http://twolivesleft.com/Codea" )
    end
    
    -- how this game was made arrow
    local arrow = Button(740,20,13,27)
    self:doDraw(arrow,"Cargo Bot:How Arrow")
    arrow.onEnded = function(obj,t)
        self:stopPhysics()
        local how = HowScreen(StartScreen())
        transitionScreen:start(self,how)
        currentScreen = transitionScreen
    end
    
    -- how this game was created?
    local howSprite = "howCreatedSprite"
    local w,h = Screen.makeTextSprite(howSprite,"HOW WAS THIS GAME CREATED?",
        {fontSize=25,fill=color(221,143,143,128)})
    local howString = Button(730-w,15,w,h)
    self:doDraw(howString,howSprite)
    howString.onEnded = arrow.onEnded
    howString:setExtras({left=20,right=40,top=20,bottom=20})
    
    -- the ground
    local y = 300
    local h = 30
    local ground = ShadowObj(0,y,WIDTH,h)
    ground.shadowOffset = function(o,x,y) return StartScreen.shadowOffset(x,y) end
    self:doDraw(ground,"Cargo Bot:Claw Middle",0,-1)
    ground:setTint(color(0,0,0,255))
    ground:setSizeOff(0,0)
    self.groundY = 330
    
    -- create the physics for the conveyor belt
    local x = -2*tinyR
    while x < WIDTH + 50 do
        local circle = physics.body(CIRCLE, tinyR)
        circle.interpolate = true
        circle.x = x
        circle.y = y+h-tinyR
        circle.type = KINEMATIC
        circle.angularVelocity = -2000
        circle.friction = 2
        table.insert(self.bodies,{body=circle,obj=nil})
        x = x + 2 * tinyR
    end
end

function StartScreen:stopPhysics()
    -- clear the physics
    local tabs = {self.bodies,self.unused}
    for _,tab in ipairs(tabs) do
        for idx,elem in ipairs(tab) do
            local body = elem.body
            body:destroy()
            body = nil
        end
    end
        
    physics.pause()
end

function StartScreen:tick()
    Screen.tick(self)
    self:newCrate()
    self:physSimulation()
    self:cleanCrates()
end

function StartScreen.shadowOffset(x,y)
    return math.floor((x - WIDTH/2)*100/WIDTH),math.floor((y - HEIGHT)*100/HEIGHT)
end

function StartScreen:newCrate()
    if ElapsedTime < self.crateT then return nil end
    
    local y = HEIGHT + 100
    local x = 200 + math.random(-50,50)
    local ang = math.random(-30,30)
    
    local obj,body

    if #self.unusedPool > 0 then
        local elem = self.unusedPool[1]
        table.remove(self.unusedPool,1)
        obj = elem.obj
        body = elem.body
        
        obj:translate(x-obj.x,y-obj.y)
        obj:setAngle(ang)
        body.x = x
        body.y = y
        body.angle = ang
        body.linearVelocity = vec2(0,0)
        body.angularVelocity = 0
    else
        local type = math.random(1,3)
        local spr
        if type == 1 then spr = "Cargo Bot:Title Large Crate 1"
        elseif type == 2 then spr = "Cargo Bot:Title Large Crate 2"
        else spr = "Cargo Bot:Title Large Crate 3" end
        local w,h = 107,106

        obj = ShadowObj(x,y,w,h)
        obj.shadowOffset = function(o,x,y) return StartScreen.shadowOffset(x,y) end
        self:doDraw(obj,spr,0,-1)
        obj:setAngle(ang)
        obj:setSizeOff(-4,-2)
        --obj:setTint(color(153, 120, 25, 255))
        self:add(obj)

        local dy = 2
        local dx = 2
        body = physics.body(POLYGON,vec2(dx,dy),vec2(w-dx,dy),vec2(w-dx,h-dy),vec2(dx,h-dy))
        body.x = x
        body.y = y
        body.angle = ang
        body.restitution = 0
        body.friction = .3
    end
    
    table.insert(self.bodies,{body=body,obj=obj})

    self.crateT = ElapsedTime + math.random()+.1
end

function StartScreen:cleanCrates()
    local n = #self.bodies
    for idx = n,1,-1 do
        elem = self.bodies[idx]
        local body = elem.body
        if (body.x < -200 or body.x > WIDTH+150 or body.y<0)and body.type == DYNAMIC then
            table.insert(self.unusedPool,elem)
            table.remove(self.bodies,idx)
        end
    end
end

-- fixme: this code is exactly the same as Level:physSimulation. combined the two
function StartScreen:physSimulation()
    for idx,elem in ipairs(self.bodies) do
        local body = elem.body
        if body.shapeType == POLYGON then
            local w,h = 0,0
            local points = body.points
            for _,p in ipairs(points) do
                w = math.max(w,p.x)
                h = math.max(h,p.y)
            end

            if body.type == DYNAMIC then
                local obj = elem.obj
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
                
                local grayValue = 90 + 165*(obj.y - self.groundY) / (HEIGHT - self.groundY)
                --print(obj.x,self.ground.x)
                obj:setTint(color(grayValue,grayValue,grayValue,255))
            end
        end
    end
end

-- for debugging
function StartScreen:drawBodies()
    noSmooth()
    strokeWidth(1)
    ellipseMode(CENTER)
    stroke(255, 255, 255, 255)
    noFill()
    for _,elem in ipairs(self.bodies) do
        local body = elem.body
        pushMatrix()
        translate(body.x,body.y)
        rotate(body.angle)
        
        if body.shapeType == CIRCLE then
            line(0,0,body.radius-3,0)
            ellipse(0,0,body.radius*2)
        else
            local points = body.points
            for idx,p in ipairs(points) do
                local p2 = points[idx%(#points)+1]
                line(p.x,p.y,p2.x,p2.y)
            end
        end
        popMatrix()
    end
end
