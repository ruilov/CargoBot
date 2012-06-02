-- WinScreen.lua

WinScreen = class(Screen)

function WinScreen:init(level,starTexs)
    Screen.init(self)
    Music.switch("Win")
    self.level = level
    self.numStars = self.level:starsEarned()
    IO.saveScore(self.numStars,level.title)
    
    -- stage
    local stageState = {piles=level.levelData.stage,claw=level.levelData.claw}
    self.stage = Stage(self,stageState)
    self:add(self.stage)
    -- make sure the random aspects of blocks remain the same for continuity
    self.stage.crateConfigs = level.stage.crateConfigs
    self.stage:copyState(level.stage)
    
    -- floor
    local obj = SpriteObj(0,359,768,21)
    self:doDraw(obj,"Cargo Bot:Game Area Floor",-7)
    
    -- roof
    local obj = SpriteObj(0,687,768,26)
    self:doDraw(obj,"Cargo Bot:Game Area Roof",-7)
    
    -- stary background
    for _,obj in ipairs(starTexs) do
        obj:copyToScreen(self,-10)
        self:add(obj)
    end
    
    -- stars
    local starSpacing = 100
    for i = 1,3 do
        local x = WIDTH / 2 - starSpacing / 2 + (i-2) * starSpacing
        local y = 780
            
        if self.numStars < 4 then
            local spr = "Cargo Bot:Star Filled"
            if i > self.numStars then spr = "Cargo Bot:Star Empty" end
            local obj = SpriteObj(x,y,95,92)
            self:doDraw(obj,spr)
            self:add(obj)
        else
            local obj = SpriteObj(x,y,95,92)
            self:doDraw(obj,"Cargo Bot:Star Filled")
            
            -- PULSING STARS
            local starPulse = function(ds)
                local w,h = obj:getSize()
                obj:setSize(w+ds,h+ds)
                local x,y = obj:getPos()
                obj:translate(-ds/2,-ds/2)
            end
            
            local grow = false
            local tweenerMaker
            tweenerMaker = function()
                -- reset the size to make sure the size doesnt diverge over time
                if not grow then
                    local w,h = obj:getSize()
                    starPulse(95 - w)
                end
                
                local count = 0
                local f = function()
                    count = count + 1
                    if count > 2 then
                        count = 0
                        if grow then starPulse(2) else starPulse(-2) end
                    end
                end
                
                grow = not grow
                local tweener = Tweener(.7,f,tweenerMaker)
                Tweener.add(tweener)
            end
            
            tweenerMaker()
        end
    end
    
    -- fastforward button
    local ffSprites = {}
    ffSprites[true] = "Cargo Bot:Fast Button Active"
    ffSprites[false] = "Cargo Bot:Fast Button Inactive"
    self.ffB = Button(10,720,74,37)
    self.ffB.fast = (self.stage.speed > 10)
    self:doDraw(self.ffB,ffSprites[self.ffB.fast])
    self:add(self.ffB)
    -- called by the WinScreen class on fast events
    self.ffB.setSprite = function(but)
        self:doDraw(but,ffSprites[but.fast])
    end
    self.ffB.onEnded = function(but,t)
        but.fast = not but.fast
        Events.trigger("fast",but.fast)
    end
    
    -- next level button
    self.nextB = Button(305,250,157,53) --305
    --sprite("Cargo Bot:Menu Button")
    self:doDraw(self.nextB,"Cargo Bot:Next Button")
    self.nextB.onEnded = function(o,t) self:nextLevel() end
    self:add(self.nextB)
    
    -- replay button
    self.replayB = Button(284,155,199,59)
    self:doDraw(self.replayB,"Cargo Bot:Replay Button")
    self.replayB.onEnded = function(o,t) self:replay() end
    self:add(self.replayB)
    
    -- menu button
    self.menuB = Button(297,60,174,51) --297
    self:doDraw(self.menuB,"Cargo Bot:Menu Button")
    self.menuB.onEnded = function(o,t) self:menu() end
    self:add(self.menuB)
    
    -- play solution button
    self.playB = Button(10,390,29,34)
    self:doDraw(self.playB,"Cargo Bot:Play Solution Icon",1)
    self.playB.onEnded = function(o,t) self:playSolution() end
    self.playB:setTint(color(255,255,255,100))
    self.playB:setExtras({left=100,right=0,top=10,bottom=10})
    self:add(self.playB)
      
    -- tip
    self.tip1 = SpriteObj(20,260,137,103)
    self:doDraw(self.tip1,"Cargo Bot:View Again Tip")
    self:add(self.tip1)
    
    -- stop button 1
    local drawStop = function()
        rectMode(CORNER)
        strokeWidth(-1)
        fill(255,255,255,100)
        rect(0,0,30,30)
    end
    Screen.makeSprite("winStopB",drawStop,30,30)
    self.stopB1 = Button(10,390,30,30)
    self.stopB1.onEnded = function(o,t) self:stopPlaying() end
    self.stopB1:setExtras({left=100,right=0,top=10,bottom=10})
    
    -- record solution button
    self.recordB = Button(715,390,45,31)
    self:doDraw(self.recordB,"Cargo Bot:Record Solution Icon",1)
    self.recordB.onEnded = function(o,t) self:recordSolution() end
    self.recordB:setTint(color(255,255,255,100))
    self:add(self.recordB)
    
    -- tip
    local obj = SpriteObj(645,270,114,93)
    self:doDraw(obj,"Cargo Bot:Record Tip")
    self:add(obj)
    
    -- the second stop button
    self.stopB2 = Button(715,390,30,30)
    self.stopB2.onEnded = function(o,t) self:stopPlaying() end
    --self.stopB2:setExtras({left=100,right=0,top=10,bottom=10})
    
    -- YOU GOT IT
    local gotItSpr = "yougotsprite"
    local w,h = Screen.makeTextSprite(gotItSpr,"YOU GOT IT",{fontSize=120})
    local obj = SpriteObj((WIDTH - w)/2,860,w,h)
    self:doDraw(obj,gotItSpr)
    self:add(obj)
    
    -- shadow - could also use ShadowObj but this is simple enough
    local obj = SpriteObj((WIDTH - w)/2-5,860-5,w,h)
    self:doDraw(obj,gotItSpr,-1)
    self:add(obj)
    obj:setTint(color(40,40,40,100))
    
    -- Message about number of stars earned
    local msg = "You earned "..self.numStars.." stars!"
    if self.numStars == 1 then msg = "You earned 1 star" end
    if self.numStars == 4 then msg = "You found the shortest solution!" end
    local fontArgs = {fontSize=35}
    if self.numStars == 5 then
        msg = "Congratulations, you found an unknown solution. Please upload to youtube!"
        fontArgs = {
            fontSize = 20,
            fill = color(0, 255, 48, 255),
            textWrapWidth = 400
        }
    end
    
    -- now make the actual objs
    local starMsgSpr = "startMsg"..self.numStars.."sprite"
    local w,h = Screen.makeTextSprite(starMsgSpr,msg,fontArgs)
    local obj = SpriteObj((WIDTH - w)/2,720,w,h)
    self:doDraw(obj,starMsgSpr)
    self:add(obj)
    
    -- shadow - could also use ShadowObj but this is simple enough
    local obj = SpriteObj((WIDTH - w)/2-3,720-3,w,h)
    self:doDraw(obj,starMsgSpr,-1)
    self:add(obj)
    obj:setTint(color(40,40,40,100))
end

function WinScreen:tick()
    Screen.tick(self)
    if self.playing then self.level:run(self.stage) end -- so that won events only generate once
end

function WinScreen:bindEvents()
    -- need to bind play so that the level knows it's now playing and it will start
    -- executing the instructions
    Events.bind("play",self.level,self.level.play)
    Events.bind("play",self.level.program,self.level.program.play)
    Events.bind("won",self,self.donePlaying)
    Events.bind("fast",self,self.fast)
end

function WinScreen:fast()
    self.ffB:setSprite()
end

function WinScreen:unbind()
    Panel.unbind(self)
    self.level:unbind() -- need this because we bound the play event to the level
    self.level.program:unbind()
end

function WinScreen:playSolution()
    -- show the program
    self.level.program:undraw(self)
    self.level.program:undraw(self.level)
    local sol = self.level.program:solutionStr()
    self.level.program:clear()
    self.level.program:removeAll()
    
    self.level.program.screen = self
    self.level.program:makeFunctions()
    self.level.program:setSolution(sol)
    
    -- trigger events
    Events.trigger("play",false) -- resets the stage state
    Events.trigger("play",true)  -- start playing
    self.playing = true
    
    -- remove the text buttons
    self:undoDraw(self.nextB)
    self:undoDraw(self.replayB)
    self:undoDraw(self.menuB)
    self:undoDraw(self.tip1)
    self:remove(self.nextB)
    self:remove(self.replayB)
    self:remove(self.menuB)
    self:remove(self.tip1)
    
    -- change the play buttons to stop buttons
    self:undoDraw(self.playB)
    self:remove(self.playB)
    self:doDraw(self.stopB1,"winStopB",1)
    self:add(self.stopB1)
    
    self:undoDraw(self.recordB)
    self:remove(self.recordB)
    self:doDraw(self.stopB2,"winStopB",1)
    self:add(self.stopB2)
      
    -- only the stop buttons are active
    self:setActive(false)
    self.active = true
    self.stopB1.active = true
    self.stopB2.active = true
    self.ffB.active = true
    self.level.program:setActive(false)
    --self.program:setActiveRegisters({})
end

function WinScreen:donePlaying()
    self.playing = false
    if isRecording() then stopRecording() end
    
    -- hide the program
    self.level.program:undraw(self)
    self.level.program:undraw(self.level)
    local sol = self.level.program:solutionStr()
    self.level.program:clear()
    self.level.program:removeAll()
    
    self.level.program.screen = self.level
    self.level.program:makeFunctions()
    self.level.program:makeMiscSprites()
    self.level.program:setSolution(sol)
    
    -- add the text buttons
    self:doDraw(self.nextB,"Cargo Bot:Next Button")
    self:doDraw(self.replayB,"Cargo Bot:Replay Button")
    self:doDraw(self.menuB,"Cargo Bot:Menu Button")
    self:doDraw(self.tip1,"Cargo Bot:View Again Tip")
    self:add(self.nextB)
    self:add(self.replayB)
    self:add(self.menuB)
    self:add(self.tip1)
    
    -- change the buttons
    self:doDraw(self.playB,"Cargo Bot:Play Solution Icon",1)
    self:add(self.playB)
    self:undoDraw(self.stopB1)
    self:remove(self.stopB1)
    
    self:doDraw(self.recordB,"Cargo Bot:Record Solution Icon",1)
    self:add(self.recordB)
    self:undoDraw(self.stopB2)
    self:remove(self.stopB2)
    
    self:setActive(true)
end

function WinScreen:stopPlaying()
    Events.trigger("play",false) -- resets the stage state
    self:donePlaying()
end

function WinScreen:recordSolution()
    startRecording()
    self:playSolution()
end

function WinScreen:replay()
    self.level:setActive(true)
    transitionScreen:start(self,self.level)
    currentScreen = transitionScreen
    transitionScreen.midCallback = function() Events.trigger("play",false) end
    Music.switch("Tutorial")
end

function WinScreen:menu()
    Events.trigger("levelSelect",self)
end

function WinScreen:nextLevel()
    -- find the next level
    local levelIdx
    for idx,levelData in ipairs(levels) do
        if levelData.name == self.level.title then
            levelIdx = idx
            break
        end
    end
    levelIdx = math.min(levelIdx+1,#levels)
    local levelData = levels[levelIdx]
    local level = Level(levelData)
    transitionScreen:start(self,level)
    transitionScreen.endCallback = function()
        level:addTutorial()
    end
    currentScreen = transitionScreen
end
