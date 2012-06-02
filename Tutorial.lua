-- Tutorial.lua 
-- more functions of the level class

function Level:cleanPopovers()
    self.popovers = {}

    -- clean the shade
    if self.shade then
        self:undoDraw(self.shade)
        self.shade = nil
    end
    
    -- clean the highlights
    self:removeHighlights() -- defined in the screen class

    Events.unbind(self,"tutorial_play")
    Events.unbind(self,"tutorial_smoke_drop")
    Events.unbind(self,"tutorial_register_drop")
    Events.unbind(self,"tutorial_toolbox_pickup")
    Events.unbind(self,"tutorial_toolbox_right")
    Events.unbind(self,"tutorial_toolbox_left")
    Events.unbind(self,"tutorial_toolbox_f1")
    Events.unbind(self,"tutorial_toolbox_f2")
    Events.unbind(self,"tutorial_toolbox_yellow")
    Events.unbind(self,"tutorial_toolbox_none")
    Events.unbind(self, "tutorial_register_pickup")
    Events.unbind(self, "hint_hide")
end

function Level:highlight(obj,extraZ)
    extraZ = extraZ or 0
    
    -- make a shade
    if not self.shade then
        local shadeMake = function()
            strokeWidth(-1)
            fill(0,0,0,140)
            rectMode(CORNER)
            rect(0,0,WIDTH,HEIGHT)
        end
        Screen.makeSprite("shade",shadeMake,WIDTH,HEIGHT)
        self.shade = SpriteObj(0,0,WIDTH,HEIGHT)
        self:doDraw(self.shade,"shade",49)
    end
    
    if obj.highlight then obj:highlight(self,50+extraZ)
    else self:highlightObj(obj,50+extraZ) end
end

function Level:addTutorial()
    local insUsed = self.program:insUsed()
    if insUsed > 0 then return nil end
    
    if self.title == levels[1].name then
        self:tutorial1_1()
    elseif self.title == levels[2].name then
        self:tutorial2_1()
    elseif self.title == levels[3].name then
        self:tutorial3_1()
    elseif self.title == levels[4].name then
        self:tutorial4_1()
    elseif self.title == levels[5].name then
        self:tutorial5_1()
    end
end

function Level:tutorial5_1()
    self:cleanPopovers()
    
    -- setup a different level where it's easier to teach conditionals
    local tutLevel = {
        name = self.title .. "2",
        claw = 1,
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","yellow","none","multi"},
        stage = {{"yellow","yellow","yellow","yellow"},{}},
        goal = {{},{"yellow","yellow","yellow","yellow"}},
    }
    
    Events.trigger("play",false)
    self:unbind()
    currentScreen = Level(tutLevel)
    currentScreen:bind()
    Events.trigger("play",false)
    
    currentScreen.program:setSolution("(pickup,)(right,)(left,)(f1,)(,)(,)(,)(,)\n(,)(,)(,)(,)(,)(,)(,)(,)")
    
    -- set what's active
    currentScreen:setActive(false)
    currentScreen.active = true
    currentScreen.menuB.active = true
    currentScreen:highlight(self.menuB)
    currentScreen.toolbox.active = true
    local objs = currentScreen.toolbox:setActiveTools({"yellow"})
    for _,obj in ipairs(objs) do currentScreen:highlight(obj) end
    
    -- create the popover
    local popover = Popover(207,175,450,150)
    popover:arrow("right",25)
    popover:setText("            Conditional modifiers\nDrag     onto     in Prog1. It will only execute if the claw is holding a\nyellow     crate",25)
    popover:addIcon(Command.spriteMap.yellow,65,79,30,28)
    popover:addIcon(Command.spriteMap.right,153,75,30,32)
    popover:addIcon("Cargo Bot:Crate Goal Yellow",88,10,30,30)
    popover:show()
    Events.bind("tutorial_toolbox_yellow",currentScreen,currentScreen.tutorial5_2)
    table.insert(currentScreen.popovers,popover)
end

function Level:tutorial5_1retry()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.toolbox.active = true
    local objs = self.toolbox:setActiveTools({"yellow"})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(535,192,125,45)
    popover:arrow("right",10)
    popover:setText("Try again",25)
    popover:show()
    Events.bind("tutorial_toolbox_yellow",self,self.tutorial5_2)
    table.insert(self.popovers,popover) 
end

function Level:tutorial5_2()
    self:cleanPopovers()
    self:highlight(self.dragObj,1)
    
    -- set what's active
    self:setActive(false)
    local objs = self.program:setActiveRegisters({{2}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(75,360,160,50)
    popover:arrow("down",46)
    popover:setText("Drop it here",25)
    popover:show()
    Events.bind("tutorial_smoke_drop",self,self.tutorial5_1retry)
    Events.bind("tutorial_register_drop",self,self.tutorial5_3)
    table.insert(self.popovers,popover)
end

function Level:tutorial5_3()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.toolbox.active = true
    self.program:setActiveRegisters({})
    local objs = self.toolbox:setActiveTools({"none"})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(52,100,450,120)
    popover:arrow("right",42)
    popover:setText("Drag     onto     in Prog1. It will only execute if the claw is not holding any crates",25)
    popover:addIcon(Command.spriteMap.none,65,79,30,28)
    popover:addIcon(Command.spriteMap.left,153,79,30,32)
    popover:show()
    Events.bind("tutorial_toolbox_none",self,self.tutorial5_4)
    table.insert(self.popovers,popover) 
end

function Level:tutorial5_3retry()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.toolbox.active = true
    local objs = self.toolbox:setActiveTools({"none"})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(375,130,125,45)
    popover:arrow("right",10)
    popover:setText("Try again",25)
    popover:show()
    Events.bind("tutorial_toolbox_none",self,self.tutorial5_4)
    table.insert(self.popovers,popover) 
end

function Level:tutorial5_4()
    self:cleanPopovers()
    self:highlight(self.dragObj,1)
    
    -- set what's active
    self:setActive(false)
    local objs = self.program:setActiveRegisters({{3}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(120,360,160,50)
    popover:arrow("down",46)
    popover:setText("Drop it here",25)
    popover:show()
    Events.bind("tutorial_smoke_drop",self,self.tutorial5_3retry)
    Events.bind("tutorial_register_drop",self,self.tutorial5_5)
    table.insert(self.popovers,popover)
end

function Level:tutorial5_5()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.program:setActiveRegisters({})
    self.stepB.active = true
    self:highlight(self.stepB)
    
    -- create the popover
    local popover = Popover(255,702,405,85)
    popover:arrow("right",25)
    popover:setText("This is the step buttom. Press it to execute a single instruction.",25)
    popover:show()
    Events.unbindEvent("won")
    --Events.bind("hint_hide",self,self.cleanPopovers)
    Events.bind("tutorial_nostep",self,self.tutorial5_6)
    Events.bind("won",self,self.tutorial5_7)
    table.insert(self.popovers,popover)
end

function Level:tutorial5_6()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.program:setActiveRegisters({})
    self.stepB.active = true
    self:highlight(self.stepB)
    
    -- create the popover
    local popover = Popover(455,780,305,85)
    popover:arrow("down",260)
    popover:setText("Press it at your own pace until the program is done",25)
    popover:show()
    Events.unbindEvent("won")
    Events.bind("tutorial_nostep",self,self.tutorial5_6)
    Events.bind("won",self,self.tutorial5_7)
    table.insert(self.popovers,popover)
end

function Level:tutorial5_7()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self:highlight(self.program.resetB)
    self.program.resetB.active = true
    
    -- create the popover
    local popover = Popover(247,20,375,150)
    popover:arrow("right",55)
    popover:setText("               That's it!\n\nOne last thing: use this button to clear your work. Try it now.",25)
    popover:show()
    Events.unbindEvent("won")
    Events.bind("shaking",self,
        function(but)
            self:shaking()
            self:cleanPopovers()
        end
    )
    Events.bind("tutorial_shakeok",self,self.tutorial5_8)
    table.insert(self.popovers,popover)
end

function Level:tutorial5_8()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    
    -- create the popover
    local popover = Popover(195,500,375,120)
    popover:setText("Good job, you've completed the tutorial. Now go and have fun!\n(touch to continue)",25)
    popover:show()
    Events.unbindEvent("won")
    Events.bind("hint_hide",self,self.tutorial5_9)
    table.insert(self.popovers,popover)
end

function Level:tutorial5_9()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(true)
    self.program:setActiveRegisters()
    self.toolbox:setActiveTools()
    
    -- display the actual level now
    Events.trigger("play",false)
    self:unbind()
    currentScreen = Level(levels[5])
    currentScreen:bind()
    Events.trigger("play",false)
end

function Level:tutorial4_1()
    self:cleanPopovers()
    
    self.program:setSolution("(pickup,)(right,)(pickup,)(left,)(pickup,)(right,)(pickup,)(left,)\n(,)(,)(,)(,)(,)(,)(,)(,)")
    
    -- set what's active
    self:setActive(false)

    -- create the popover
    local popover = Popover(180,500,400,120)
    popover:setText("Use Progs to make your solutions shorter. Shorter programs are awarded more stars",25)
    popover:show()
    Events.bind("hint_hide",self,self.tutorial4_2)
    table.insert(self.popovers,popover) 
end

function Level:tutorial4_retry()
    self:cleanPopovers()
    
    self.program:setSolution("(pickup,)(right,)(pickup,)(left,)(pickup,)(right,)(pickup,)(left,)\n(,)(,)(,)(,)")
    
    -- set what's active
    self:setActive(false)

    -- create the popover
    local popover = Popover(280,520,140,45)
    popover:setText("Try again!",25)
    popover:show()
    Events.bind("hint_hide",self,self.tutorial4_2)
    table.insert(self.popovers,popover) 
end

function Level:tutorial4_2()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.program.active = true
    local objs = self.program:setActiveRegisters({{1}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(20,350,190,50)
    popover:arrow("down",46)
    popover:setText("Move to Prog2",25)
    popover:show()
    Events.bind("tutorial_register_pickup",self,self.tutorial4_3)
    table.insert(self.popovers,popover)
end

function Level:tutorial4_3()
    self:cleanPopovers()
    self:highlight(self.dragObj,1)
    
    -- set what's active
    self:setActive(false)
    local objs = self.program:setActiveRegisters({{},{1}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(20,125,160,50)
    popover:arrow("up",46)
    popover:setText("Drop it here",25)
    popover:show()
    Events.bind("tutorial_smoke_drop",self,self.tutorial4_retry)
    Events.bind("tutorial_register_drop",self,self.tutorial4_4)
    table.insert(self.popovers,popover)
end

function Level:tutorial4_4()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.program.active = true
    local objs = self.program:setActiveRegisters({{2}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(75,350,190,50)
    popover:arrow("down",46)
    popover:setText("Move to Prog2",25)
    popover:show()
    Events.bind("tutorial_register_pickup",self,self.tutorial4_5)
    table.insert(self.popovers,popover)
end

function Level:tutorial4_5()
    self:cleanPopovers()
    self:highlight(self.dragObj,1)
    
    -- set what's active
    self:setActive(false)
    local objs = self.program:setActiveRegisters({{},{2}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(75,125,160,50)
    popover:arrow("up",46)
    popover:setText("Drop it here",25)
    popover:show()
    Events.bind("tutorial_smoke_drop",self,self.tutorial4_retry)
    Events.bind("tutorial_register_drop",self,self.tutorial4_6)
    table.insert(self.popovers,popover)
end

function Level:tutorial4_6()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.program.active = true
    local objs = self.program:setActiveRegisters({{3}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(125,350,190,50)
    popover:arrow("down",46)
    popover:setText("Move to Prog2",25)
    popover:show()
    Events.bind("tutorial_register_pickup",self,self.tutorial4_7)
    table.insert(self.popovers,popover)
end

function Level:tutorial4_7()
    self:cleanPopovers()
    self:highlight(self.dragObj,1)
    
    -- set what's active
    self:setActive(false)
    local objs = self.program:setActiveRegisters({{},{3}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(125,125,160,50)
    popover:arrow("up",46)
    popover:setText("Drop it here",25)
    popover:show()
    Events.bind("tutorial_smoke_drop",self,self.tutorial4_retry)
    Events.bind("tutorial_register_drop",self,self.tutorial4_8)
    table.insert(self.popovers,popover)
end

function Level:tutorial4_8()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.program.active = true
    local objs = self.program:setActiveRegisters({{4}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(170,350,190,50)
    popover:arrow("down",46)
    popover:setText("Move to Prog2",25)
    popover:show()
    Events.bind("tutorial_register_pickup",self,self.tutorial4_9)
    table.insert(self.popovers,popover)
end

function Level:tutorial4_9()
    self:cleanPopovers()
    self:highlight(self.dragObj,1)

    -- set what's active
    self:setActive(false)
    local objs = self.program:setActiveRegisters({{},{4}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(170,125,160,50)
    popover:arrow("up",46)
    popover:setText("Drop it here",25)
    popover:show()
    Events.bind("tutorial_smoke_drop",self,self.tutorial4_retry)
    Events.bind("tutorial_register_drop",self,self.tutorial4_10)
    table.insert(self.popovers,popover)
end

function Level:tutorial4_10()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.toolbox.active = true
    local objs = self.toolbox:setActiveTools({"f2"})
    for _,obj in ipairs(objs) do self:highlight(obj) end

    -- create the popover
    local popover = Popover(290,185,215,50)
    popover:arrow("right",12)
    popover:setText("Drag     to Prog1",25)
    popover:addIcon(Command.spriteMap.f2,65,8,30,32)
    popover:show()
    Events.bind("tutorial_toolbox_f2",self,self.tutorial4_11)
    table.insert(self.popovers,popover)
end

function Level:tutorial4_11()
    self:cleanPopovers()
    self:highlight(self.dragObj,1)
    
    -- set what's active
    self:setActive(false)
    local objs = self.program:setActiveRegisters({{1}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(20,350,160,50)
    popover:arrow("down",46)
    popover:setText("Drop it here",25)
    popover:show()
    Events.bind("tutorial_smoke_drop",self,self.tutorial4_10)
    Events.bind("tutorial_register_drop",self,self.tutorial4_12)
    table.insert(self.popovers,popover)
end

function Level:tutorial4_12()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.toolbox.active = true
    local objs = self.toolbox:setActiveTools({"f2"})
    for _,obj in ipairs(objs) do self:highlight(obj) end

    -- create the popover
    local popover = Popover(280,190,220,50)
    popover:arrow("right",10)
    popover:setText("Drag another one",25)
    popover:show()
    Events.bind("tutorial_toolbox_f2",self,self.tutorial4_13)
    table.insert(self.popovers,popover)
end

function Level:tutorial4_13()
    self:cleanPopovers()
    self:highlight(self.dragObj,1)
    
    -- set what's active
    self:setActive(false)
    local objs = self.program:setActiveRegisters({{2}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(75,350,160,50)
    popover:arrow("down",46)
    popover:setText("Drop it here",25)
    popover:show()
    Events.bind("tutorial_smoke_drop",self,self.tutorial4_12)
    Events.bind("tutorial_register_drop",self,self.tutorial4_14)
    table.insert(self.popovers,popover)
end

function Level:tutorial4_14()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(true)
    self.program:setActiveRegisters()
    self.toolbox:setActiveTools()
    self:highlight(self.playB)
    
    -- create the popover
    local popover = Popover(185,102,400,220)
    popover:arrow("down",180)
    popover:setText("Each time Prog2 is executed, its entire sequence is executed\n\nPress play to see how it works, and try to solve this level using Prog2",25)
    popover:show()
    Events.bind("hint_hide",self,self.cleanPopovers)
    table.insert(self.popovers,popover)
end

function Level:tutorial1_1()
    self:cleanPopovers()

    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.toolbox.active = true

    local objs = self.toolbox:setActiveTools({"pickup"})
    for _,obj in ipairs(objs) do self:highlight(obj) end
        
    -- create the popover
    local popover = Popover(315,225,240,88)
    popover:arrow("right",30)
    popover:setText("Program your claw, drag     to Prog1",25)
    popover:addIcon(Command.spriteMap.pickup,65,12,30,32)
    popover:show()
    Events.bind("tutorial_toolbox_pickup",self,self.tutorial1_2)
    table.insert(self.popovers,popover)
end

function Level:tutorial1_2()
    self:cleanPopovers()
    self:highlight(self.dragObj,1)
    
    -- set what's active
    self:setActive(false)
    local objs = self.program:setActiveRegisters({{1}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(20,350,160,50)
    popover:arrow("down",46)
    popover:setText("Drop it here",25)
    popover:show()
    Events.bind("tutorial_smoke_drop",self,self.tutorial1_1)
    Events.bind("tutorial_register_drop",self,self.tutorial1_3)
    table.insert(self.popovers,popover)
end

function Level:tutorial1_3()
    self:cleanPopovers()
    
    -- set what's active
    --[[
    self:setActive(true)
    self.program:setActiveRegisters()
    self.toolbox:setActiveTools()
    self:highlight(self.playB)
    --]]
    
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.playB.active = true
    self:highlight(self.playB)
    
    -- create the popover
    local popover = Popover(318,102,140,50)
    popover:arrow("down",53)
    popover:setText("Press play",25)
    popover:show()
    Events.bind("tutorial_play",self,self.tutorial1_4)
    table.insert(self.popovers,popover)
end

function Level:tutorial1_4()
    self:cleanPopovers()
    
    self:setActive(false)

    -- create the popover
    local popover = Popover(0,0,0,0)
    Events.bind("tutorial_nomove",self,self.tutorial1_5)
    table.insert(self.popovers,popover)
end

function Level:tutorial1_5()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.playB.active = true
    self:highlight(self.playB)
        
    -- create the popover
    local popover = Popover(240,102,275,80)
    popover:arrow("down",125)
    popover:setText("Your program finished executing. Press stop",25)
    popover:show()
    Events.bind("tutorial_stop",self,self.tutorial1_6)
    table.insert(self.popovers,popover)
end

function Level:tutorial1_6()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.toolbox.active = true
    local objs = self.toolbox:setActiveTools({"right"})
    for _,obj in ipairs(objs) do self:highlight(obj) end

    -- create the popover
    local popover = Popover(290,245,215,50)
    popover:arrow("right",12)
    popover:setText("Drag     to Prog1",25)
    popover:addIcon(Command.spriteMap.right,65,8,30,32)
    popover:show()
    Events.bind("tutorial_toolbox_right",self,self.tutorial1_7)
    table.insert(self.popovers,popover)
end

function Level:tutorial1_7()
    self:cleanPopovers()
    self:highlight(self.dragObj,1)
    
    -- set what's active
    self:setActive(false)
    local objs = self.program:setActiveRegisters({{2}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(75,350,160,50)
    popover:arrow("down",46)
    popover:setText("Drop it here",25)
    popover:show()
    Events.bind("tutorial_smoke_drop",self,self.tutorial1_6)
    Events.bind("tutorial_register_drop",self,self.tutorial1_8)
    table.insert(self.popovers,popover)
end

function Level:tutorial1_8()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.toolbox.active = true
    local objs = self.toolbox:setActiveTools({"pickup"})
    for _,obj in ipairs(objs) do self:highlight(obj) end

    -- create the popover
    local popover = Popover(335,245,215,50)
    popover:arrow("right",12)
    popover:setText("Drag     to Prog1",25)
    popover:addIcon(Command.spriteMap.pickup,65,8,30,32)
    popover:show()
    Events.bind("tutorial_toolbox_pickup",self,self.tutorial1_9)
    table.insert(self.popovers,popover)
end

function Level:tutorial1_9()
    self:cleanPopovers()
    self:highlight(self.dragObj,1)
    
    -- set what's active
    self:setActive(false)
    local objs = self.program:setActiveRegisters({{3}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(125,350,160,50)
    popover:arrow("down",46)
    popover:setText("Drop it here",25)
    popover:show()
    Events.bind("tutorial_smoke_drop",self,self.tutorial1_8)
    Events.bind("tutorial_register_drop",self,self.tutorial1_10)
    table.insert(self.popovers,popover)
end

function Level:tutorial1_10()
    self:cleanPopovers()
    
    -- set what's active
    --[[
    self:setActive(true)
    self.program:setActiveRegisters()
    self.toolbox:setActiveTools()
    self:highlight(self.playB)
    --]]
    
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.playB.active = true
    self:highlight(self.playB)
    
    -- create the popover
    local popover = Popover(318,102,140,50)
    popover:arrow("down",53)
    popover:setText("Press play",25)
    popover:show()
    Events.bind("tutorial_play",popover,popover.hide)
    Events.bind("tutorial_play",self,self.cleanPopovers)
    table.insert(self.popovers,popover)
end

function Level:tutorial2_1()
    self:cleanPopovers()
    
    self:highlight(self.goal,100)
    
    -- create the popover
    local popover = Popover(207,627,350,80)
    popover:arrow("up",150)
    popover:setText("Now try it yourself. Move the crate further as show above",25)
    popover:show()
    Events.bind("hint_hide",self,self.cleanPopovers)
    table.insert(self.popovers,popover)
end

function Level:tutorial3_1()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.toolbox.active = true
    local objs = self.toolbox:setActiveTools({"f1"})
    for _,obj in ipairs(objs) do self:highlight(obj) end

    -- create the popover
    local popover = Popover(452,230,210,80)
    popover:arrow("right",25)
    popover:setText("  Create a loop\nDrag     to Prog1",25)
    popover:addIcon(Command.spriteMap.f1,65,8,30,32)
    popover:show()
    Events.bind("tutorial_toolbox_f1",self,self.tutorial3_2)
    table.insert(self.popovers,popover)
end

function Level:tutorial3_2()
    self:cleanPopovers()
    self:highlight(self.dragObj,1)
    
    -- set what's active
    self:setActive(false)
    local objs = self.program:setActiveRegisters({{1}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(20,350,160,50)
    popover:arrow("down",46)
    popover:setText("Drop it here",25)
    popover:show()
    Events.bind("tutorial_smoke_drop",self,self.tutorial3_1)
    Events.bind("tutorial_register_drop",self,self.tutorial3_3)
    table.insert(self.popovers,popover)
end

function Level:tutorial3_3()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.program.active = true
    local objs = self.program:setActiveRegisters({{1}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(20,350,310,125)
    popover:arrow("down",46)
    popover:setText("You can also move commands around. Pick it up from here to move it",25)
    popover:show()
    Events.bind("tutorial_register_pickup",self,self.tutorial3_4)
    table.insert(self.popovers,popover)
end

function Level:tutorial3_3retry()
    self:cleanPopovers()
    
    self.program:setSolution("(f1,)(,)(,)(,)(,)(,)(,)(,)\n(,)(,)(,)(,)(,)(,)(,)(,)")
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.program.active = true
    local objs = self.program:setActiveRegisters({{1}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(20,350,250,45)
    popover:arrow("down",46)
    popover:setText("Try to move it again",25)
    popover:show()
    Events.bind("tutorial_register_pickup",self,self.tutorial3_4)
    table.insert(self.popovers,popover)
end

function Level:tutorial3_4()
    self:cleanPopovers()
    self:highlight(self.dragObj,1)
    
    -- set what's active
    self:setActive(false)
    local objs = self.program:setActiveRegisters({{2}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(75,350,160,50)
    popover:arrow("down",46)
    popover:setText("Drop it here",25)
    popover:show()
    Events.bind("tutorial_smoke_drop",self,self.tutorial3_3retry)
    Events.bind("tutorial_register_drop",self,self.tutorial3_5)
    table.insert(self.popovers,popover)
end

function Level:tutorial3_5()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.toolbox.active = true
    local objs = self.toolbox:setActiveTools({"pickup"})
    for _,obj in ipairs(objs) do self:highlight(obj) end

    -- create the popover
    local popover = Popover(335,245,215,50)
    popover:arrow("right",12)
    popover:setText("Drag     to Prog1",25)
    popover:addIcon(Command.spriteMap.pickup,65,8,30,32)
    popover:show()
    Events.bind("tutorial_toolbox_pickup",self,self.tutorial3_6)
    table.insert(self.popovers,popover)
end

function Level:tutorial3_6()
    self:cleanPopovers()
    self:highlight(self.dragObj,1)
    
    -- set what's active
    self:setActive(false)
    local objs = self.program:setActiveRegisters({{1}})
    for _,obj in ipairs(objs) do self:highlight(obj) end
    
    -- create the popover
    local popover = Popover(20,350,160,50)
    popover:arrow("down",46)
    popover:setText("Drop it here",25)
    popover:show()
    Events.bind("tutorial_smoke_drop",self,self.tutorial3_5)
    Events.bind("tutorial_register_drop",self,self.tutorial3_7)
    table.insert(self.popovers,popover)
end

function Level:tutorial3_7()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(false)
    self.active = true
    self.menuB.active = true
    self:highlight(self.menuB)
    self.playB.active = true
    self:highlight(self.playB)
    
    -- create the popover
    local popover = Popover(318,102,140,50)
    popover:arrow("down",53)
    popover:setText("Press play",25)
    popover:show()
    Events.bind("tutorial_play",self,self.tutorial3_8)
    table.insert(self.popovers,popover)
end

function Level:tutorial3_8()
    self:cleanPopovers()
    
    -- set what's active
    self:setActive(true)
    
    -- create the popover
    local popover = Popover(150,270,470,80)
    popover:setText("Well done, the program is now looping\nTry to solve this level now using a loop",25)
    popover:show()
    Events.bind("hint_hide",self,self.cleanPopovers)
    table.insert(self.popovers,popover)
end
