-- Level.lua
-- Level represents the main game area. It contains the stage, the goal,
-- toolbox, program, etc, and handles the user interaction
-- Z-coords are:
-- -10, the lower and upper backgrounds
-- -9 the stage background
-- -8 the stage shadows
-- -7 the stage floor/roof

Level = class(Screen)

function Level:init(levelData)
    Screen.init(self)
    Music.switch("Tutorial")
    
    self.levelData = levelData
    self.title = levelData.name
    self.starThresholds = levelData.stars
    
    self.wonIt = false
    self.animating = false
    
    self.popovers = {}
    self.highlights = {}
    self.active = true
    
    -- floor
    local obj = SpriteObj(0,359,768,21)
    self:doDraw(obj,"Cargo Bot:Game Area Floor",-7)
    
    -- roof
    local obj = SpriteObj(0,687,768,26)
    self:doDraw(obj,"Cargo Bot:Game Area Roof",-7)
    
    -- lower BG
    local obj = SpriteObj(0,0,768,364)
    self:doDraw(obj,"Cargo Bot:Game Lower BG",-10)

    -- upper BG
    local obj = SpriteObj(0,708,768,364)
    self:doDraw(obj,"Cargo Bot:Game Upper BG",-10)
    
    -- the stage
    local stageState = {piles=levelData.stage,claw=levelData.claw}
    self.stage = Stage(self,stageState)
    self:add(self.stage)
    
    -- the goal
    local goalState = {piles=levelData.goal}
    self.goal = Goal(self,goalState)
    self:add(self.goal)
    
    -- title
    local sprName = "levelTitle"..self.title
    local w,h = Screen.makeTextSprite(sprName,self.title,
        {fontSize=47,fill=color(223, 179, 179, 255)})
    self.titleObj = SpriteObj((WIDTH-w)/2,950,w,h)
    self:doDraw(self.titleObj,sprName)
    self:add(self.titleObj)
    
    -- goal title
    local sprName = "goalTitle"
    local w,h = Screen.makeTextSprite(sprName,"GOAL",{fontSize=25})
    local titleObj = SpriteObj((WIDTH-w)/2,915,w,h)
    self:doDraw(titleObj,sprName)
    self:add(titleObj)
    
    -- play button
    local playSprites = {}
    playSprites[true] = "Cargo Bot:Play Button"
    playSprites[false] = "Cargo Bot:Stop Button"
    
    self.playB = Button(302,0,164,80)
    self:doDraw(self.playB,playSprites[true])
    self:add(self.playB)
    -- called by the level class on play events
    self.playB.setSprite = function(but,play)
        self:doDraw(but,playSprites[play])
    end
    self.playB.onEnded = function(but,t)
        if not self.playing then sounds:play("click_play")
        else sounds:play("click_stop") end
        Events.trigger("play",not self.animating)
            
        if self.animating then Events.trigger("tutorial_play")
        else Events.trigger("tutorial_stop") end
    end
    
    -- menu button
    self.menuB = Button(10,970,99,48)
    self:doDraw(self.menuB,"Cargo Bot:Menu Game Button")
    self:add(self.menuB)
    self.menuB.onEnded = function(but,t)
        Events.trigger("play",false)
        Events.trigger("levelSelect",self) 
    end

    -- the toolbox
    self.toolbox = Toolbox(self,levelData.toolbox)
    self:add(self.toolbox)
    
    -- program
    self.program = Program(self,levelData.funcs)
    self:add(self.program)
    
    -- step button    
    self.stepB = Button(685,720,74,37)
    self:doDraw(self.stepB,"Cargo Bot:Step Button")
    self.stepB.onEnded = function(but,t)
        but:setTint(color(100,100,100,255))
        self:step()
    end
    self:add(self.stepB)
    self.stepB:setExtras({left=20,right=20,top=20,bottom=20})
    
    -- fastforward button
    local ffSprites = {}
    ffSprites[true] = "Cargo Bot:Fast Button Active"
    ffSprites[false] = "Cargo Bot:Fast Button Inactive"
    self.ffB = Button(10,720,74,37)
    self.ffB.fast = false
    self:doDraw(self.ffB,ffSprites[false])
    self:add(self.ffB)
    -- called by the level class on fast events
    self.ffB.setSprite = function(but)
        self:doDraw(but,ffSprites[but.fast])
    end
    self.ffB.onEnded = function(but,t)
        but.fast = not but.fast
        Events.trigger("fast",but.fast)
    end
    self.ffB:setExtras({left=20,right=20,top=20,bottom=20})

    -- hint button    
    local hintB = Button(658,970,100,50)
    self:doDraw(hintB,"Cargo Bot:Hints Button")
    hintB.onEnded = function(but,t)
        Events.trigger("play",false)
        if #self.popovers == 0 then
            local popover = Popover(0,0,0,0)
            popover:setText(levelData.hint,25)
            popover:pack()
            popover.y = HEIGHT - popover.h - 70
            popover.x = WIDTH - popover.w - 12
            Events.bind("hint_hide",self,self.cleanPopovers)
            popover:show()
            table.insert(self.popovers,popover)
        end
    end
    self:add(hintB)
    
    local solution = IO.readSolution(self.title)
    if solution then self.program:setSolution(solution) end
end

function Level:bindEvents()
    Events.bind("play",self,self.play)
    Events.bind("drag",self,self.drag)
    Events.bind("saveSolution",self,self.saveSolution)
    Events.bind("fast",self,self.fast)
    Events.bind("won",self,self.wonCallback)
    if not self.noShake then Events.bind("shaking",self,self.shaking) end
end

function Level:setActive(val)
    Screen.setActive(self,val)
    if val then 
        Events.bind("shaking",self,self.shaking)
        self.noShake = false
    else
        self.noShake = true
        Events.unbind(self,"shaking") 
    end
end

function Level:draw()
    Screen.draw(self)
    for _,popover in ipairs(self.popovers) do
        popover:draw()
    end
end

function Level:collide(contact)
    self.stage:collide(contact)
end

-- because only the level knows the filename
function Level:saveSolution()
    local solutionStr = self.program:solutionStr()
    IO.saveSolution(self.title,solutionStr)
end

function Level:play(val)
    self.animating = val
    self.wonIt = false
    self.maxSteps = 10000000 -- number of user program steps allowed
    -- dont use events to make sure self.playing is up to date
    self.playB:setSprite(not self.animating) 
end

function Level:fast()
    self.ffB:setSprite()
end

-- callback for drag event
function Level:drag(args)
    sounds:play("select_tile")
    local obj,t = args[1],args[2]
    self.dragging = true
    self.dragObj = Command(obj.command,obj.x,obj.y,math.floor(obj.w*1.1),math.floor(obj.h*1.1))
    self.dragAnchor = vec2(t.x-obj.x,t.y-obj.y)
    self:doDraw(self.dragObj,Command.spriteMap[obj.command],10) -- above everything
    self:add(self.dragObj)
end

function Level:touched(t)
    -- why don't I implement dragging through Button.moving?
    -- because the user's finger may move outside the bounds of the object
    -- it's a hack until I've got somethin gbetter
    if not self.dragging then
        Events.trigger("hint_hide")
        -- only go to the children if not dragging something
        if self.active then Screen.touched(self,t) end
    else
        local newX = t.x - self.dragAnchor.x
        local newY = t.y - self.dragAnchor.y
        self.dragObj:translate(newX - self.dragObj.x,newY - self.dragObj.y)
        if t.state == MOVING then
            Events.trigger("dragMoving",self.dragObj)
        elseif t.state == ENDED then
            -- finished dragging
            self.dragging = false
            self:remove(self.dragObj)
            self:undoDraw(self.dragObj)
            Events.trigger("drop",self.dragObj)
            self:saveSolution()
        end
    end
end

function Level:tick()
    Screen.tick(self)
    self:run(self.stage)
end

-- stage argument is used by the win screen to play its stage rather than the
-- actual level stage
function Level:run(stage)
    self.stepB:setTint(color(255,255,255,255))
    
    stage = stage or self.stage
    
    if not self.animating then return nil end
    
    if stage.isWaiting then
        if self.maxSteps > 0 then
            if BaseStage.compareStages(stage,self.goal) then
                Events.trigger("won")
                return nil
            end
        
            local nextMove = self.program:nextMove(stage.claw.crate)
            if nextMove == "" then Events.trigger("tutorial_nomove") end
            stage:nextMove(nextMove)
            self.maxSteps = self.maxSteps - 1
        else
            Events.trigger("tutorial_nostep")
        end
    end
end

function Level:step()
    local wasPlaying = self.animating
    -- note that this trigger resets maxSteps
    if not self.animating then Events.trigger("play",true) end
    
    -- allow the user to batch up to 5 step calls
    if self.maxSteps < 5 then self.maxSteps = self.maxSteps + 1 end
    -- if we're not in step mode yet
    if self.maxSteps > 6 then
        -- stop right away
        if wasPlaying then self.maxSteps = 0
        -- start it up
        else self.maxSteps = 1 end
    end
end

function Level:wonCallback()
    self.animating = false
    self.wonIt = true
    self.active = false
    sounds:play("success")
    
    -- stary background
    self.starTexs = {}
    -- bottom
    local backBottom = ScrollingTexture("Cargo Bot:Starry Background",self,0,-HEIGHT,
        WIDTH,HEIGHT,4)
    self:add(backBottom)
    table.insert(self.starTexs,backBottom)
    -- top
    local backTop = ScrollingTexture("Cargo Bot:Starry Background",self,0,HEIGHT,
        WIDTH,HEIGHT,4)
    self:add(backTop)
    table.insert(self.starTexs,backTop)
    
    -- tweeners
    local tweener = Tweener(.5,function(p)
        local startB = -HEIGHT
        local endB = startB + 371
        local y = startB * (1-p) + endB * p
        backBottom:translate(0,y - backBottom.y)
        
        local startT = HEIGHT
        local endT = startT - 325
        local y = startT * (1-p) + endT * p
        backTop:translate(0,y - backTop.y)
    end,function() self:winTransition() end)
    Tweener.add(tweener)
end

function Level:winTransition()
    local winScreen = WinScreen(self,self.starTexs)
    transitionScreen:start(self,winScreen,true)
end

-- how many stars we earn with the current program (assuming it's a complete solution)
-- 4 means the optimal solution
-- 5 means better than the optimal solution
function Level:starsEarned()
    local n = self.program:insUsed()
    for idx,thr in ipairs(self.starThresholds) do
        if thr < n then return idx end
    end
    if n == self.starThresholds[3] then return 4
    else return 5 end
end

-- when the user shakes the ipad, this is called. Show a chicken box first
function Level:shaking()
    if self.resetShowing then return end -- we're already showing the dialog box
    self.resetShowing = true
    Events.trigger("play",false)
    local box = ChickenBox( (WIDTH - 423)/2, 400, self, 
        function() 
            -- ok callback
            self.resetShowing = false
            self.program:reset()
            Events.trigger("tutorial_shakeok")
        end,
        function() 
            -- cancel callback
            self.resetShowing = false 
            Events.trigger("tutorial_shakeok")
        end)
end

ChickenBox = class(Panel)

function ChickenBox:init(x,y,screen,okCallback,cancelCallback)
    Panel.init(self,x,y)
    
    screen:setActive(false)
    screen.active = true
    
    -- shade
    local shade = SpriteObj(-x,-y,WIDTH,HEIGHT)
    screen:doDraw(shade,"Cargo Bot:Background Fade",14)
    shade:setTint(color(255,255,255,170))
    self:add(shade)
    
    -- background
    local box = SpriteObj(0,0,423, 206)
    screen:doDraw(box,"Cargo Bot:Dialogue Box",15)
    self:add(box)
    
    -- cancel button
    local cancelBut = Button(23,30,98,48)
    screen:doDraw(cancelBut,"Cargo Bot:Dialogue Button",16)
    self:add(cancelBut)
    
    -- ok button
    local okBut = Button(423-98-23,30,98,48)
    screen:doDraw(okBut,"Cargo Bot:Dialogue Button",16)
    self:add(okBut)
    
    -- question  
    local qSpr = "levelChickenSpr"
    local w,h = Screen.makeTextSprite(qSpr,"Are you sure you want to clear your work?",
        {fontSize=25,font="Futura-Medium",
        textWrapWidth=400,textAlign=CENTER})
    local qTxt = SpriteObj(30,100,w,h)
    screen:doDraw(qTxt,qSpr,17)
    self:add(qTxt)  
    
    -- cancel text
    local cancelSpr = "levelCancelSpr"
    local w,h = Screen.makeTextSprite(cancelSpr,"CANCEL",
        {fontSize=25,font="Futura-CondensedExtraBold"})
    local cancelTxt = SpriteObj(32,36,w,h)
    screen:doDraw(cancelTxt,cancelSpr,17)
    self:add(cancelTxt)
    
    -- ok text
    local clearSpr = "levelClearSpr"
    local w,h = Screen.makeTextSprite(clearSpr,"CLEAR",
        {fontSize=25,font="Futura-CondensedExtraBold"})
    local clearTxt = SpriteObj(423-98-7,36,w,h)
    screen:doDraw(clearTxt,clearSpr,17)
    self:add(clearTxt)
    
    cancelBut.onEnded = function(but,t)
        screen:setActive(true)
        self:undraw(screen)
        cancelCallback()
    end
    
    okBut.onEnded = function(but,t)
        screen:setActive(true)
        self:undraw(screen)
        okCallback()
    end      
end
