-- Program.lua
-- represents the user program with all the registers

Program = class(Panel)

function Program:init(screen,numIns)
    Panel.init(self,10,30)
    self.screen = screen
    self.numIns = numIns
    self.smokes = {}
    self.active = true
    self:makeFunctions()
    self:makeMiscSprites()
    self:resetPointer()
end

function Program:makeMiscSprites()
    self.resetB = Button(630,30,99,48)
    self.screen:doDraw(self.resetB,"Cargo Bot:Clear Button",1)
    self.resetB.onEnded = function(but,t) Events.trigger("shaking") end -- hack alert, fake shaking
    self:add(self.resetB)
end

function Program:makeFunctions()
    self.registers = {}
    self.labels = {}
    
    local numFuncs = 4 -- this is the maximum num of funcs, so we can calculate y coords
    local regDims = {
        w = 50,
        h = 77,
        slot = {w=50,h=54},
        command = {x = 0, y = 0, w = 50, h = 54},
        conditional = {x = 0, y = 34, w = 50, h = 43},
    }
    local labelW = 50
    
    if #self.numIns > 4 then -- use the small dims
        assert(#self.numIns==5,"too many functions")
        numFuncs = 5
        regDims = {
            w = 40,
            h = 60,
            slot = {w=40,h=40},
            command = {x = 0, y = 0, w = 40, h = 40},
            conditional = {x = 0, y = 20, w = 40, h = 40}
        }
        labelW = 40
    end
    
    for fi,fIns in ipairs(self.numIns) do
        -- make one function
        local y = (numFuncs-fi)*(regDims.h+5)        
        self.registers[fi] = {}
        for ri = 1,fIns do
            local x = (ri-1) * regDims.w + labelW - 3
            
            -- make a slot for one instruction 
            local register = Register(x,y,regDims,ri==fIns,self.screen)
            register.active = true
            self:add(register)
            self.registers[fi][ri] = register
        end
        
        -- f label
        local labelF = "f"..fi
        local label = Command(labelF,0,y,labelW,regDims.command.h)
        self.screen:doDraw(label,Command.spriteMap[labelF],-2)
        label:setTint(color(150,150,150,255))
        self:add(label)
        table.insert(self.labels,label)
    end
end

function Program:bindEvents()
    Events.bind("drop",self,self.dropped)
    Events.bind("dragMoving",self,self.dragMoving)
    Events.bind("play",self,self.play)
    Events.bind("won",self,self.won)
    --Events.bind("shaking",self,self.reset) -- the level class now answers to shaking events
end

function Program:unselect()
    if self.selected then
        self.selected:unselect()
        self.selected = nil
    end
end

-- find the register at this position
function Program:registerAt(pos)
    for fi,func in ipairs(self.registers) do
        for ri,register in ipairs(func) do
            if register:inbounds(pos) then
                return register
            end
        end
    end
    return nil
end

function Program:dragMoving(dragObj)
    self:unselect()
    local objMiddle = vec2(dragObj.x,dragObj.y) + vec2(dragObj.w,dragObj.h)/2
    local register = self:registerAt(objMiddle,dragAnchor)
    if register then 
        self.selected = register
        register:select() 
    end
end

-- callback for when the user drops a command. 
-- Finds which register to set and set it
function Program:dropped(dragObj)
    self:unselect()
    
    local objMiddle = vec2(dragObj.x,dragObj.y) + vec2(dragObj.w,dragObj.h)/2
    local register = self:registerAt(objMiddle)
    if register and register.active then
        sounds:play("drop_tile_register")
        local type = Command.type(dragObj.command)
        if type == "command" then 
            register:setCommand(dragObj.command)
        else 
            register:setConditional(dragObj.command)
        end
        
        Events.trigger("tutorial_register_drop")
        
        -- strictly not needed, but make sure we don't set more than one
        return nil 
    end

    -- if we get here it means the user dropped the command away
    local smoke = Smoke(objMiddle.x-self.x,objMiddle.y-self.y,self.screen)
    self:add(smoke)
    
    sounds:play("drop_tile_smoke")
    Events.trigger("tutorial_smoke_drop")
end

function Program:solutionStr()
    local s = ""
    for fi,func in ipairs(self.registers) do
        for ri,reg in ipairs(func) do
            local cmd = reg:getCommand()
            local cond = reg:getConditional()
            s = s.."("..cmd..","..cond..")"
        end
        s = s.."\n"
    end
    return s
end

function Program:setSolution(s)
    local fi = 0
    for tok in s:gmatch("[^\n]+") do
        fi = fi + 1
        local ri = 0
        for cmd,cond in tok:gmatch("%((%w*),(%w*)%)") do
            ri = ri + 1
            if fi <= #self.registers and ri <= #self.registers[fi] then
                local reg = self.registers[fi][ri]
                reg:setCommand(cmd)
                reg:setConditional(cond)
            end
        end
    end
end

function Program:reset()
    Events.trigger("play",false)
    self:clear()
    Events.trigger("saveSolution")
end

function Program:clear()
    for fi,func in ipairs(self.registers) do
        for i,reg in ipairs(func) do
            reg:setCommand("")
            reg:setConditional("")
        end
    end
end

function Program:resetPointer()
    self.stack = Stack()
    self.pointer = {f=1,ins=0}
end

-- need to know the clawBlock to do the conditionals
function Program:nextMove(clawCrate)
    -- try to increment the pointer within this function
    local count = 0
    
    while(true) do
        count = count + 1
        if count > 1000 then 
            return "" 
        end
        
        self.pointer.ins = self.pointer.ins + 1

        if self.pointer.ins > #self.registers[self.pointer.f] then
            -- reached the end of this instruction
            -- if there's a stack, then pop it
            if self.stack:size() > 0 then 
                self.pointer = self.stack:pop()
            else  -- done executing. need to signal this?
                self.pointer.ins = self.pointer.ins - 1
                return ""
            end
        else
            local reg = self.registers[self.pointer.f][self.pointer.ins]
            local command = reg:getCommand()
            local conditional = reg:getConditional()

            if command ~= "" and 
                (conditional == "" or 
                (conditional=="multi" and clawCrate) or
                (conditional == "none" and not clawCrate) or
                (clawCrate and conditional==clawCrate.colStr)) then
                -- reached a non idle func
                if command:sub(1,1) == "f" then
                    local nextF = command:sub(2,2)+0
                    self.stack:push(self.pointer)
                    self.pointer = {f=nextF,ins=0}
                    -- pulse
                    self:unpulse()
                    reg:pulse()
                    self.pulsed = reg
                    
                    self.pulsedLabel = self.labels[self.pointer.f]
                    self.pulsedLabel:setTint(color(255,255,255,255))
                    
                    return command
                else
                    -- reached a real move
                    self:unpulse()
                    reg:pulse()
                    self.pulsed = reg
                    
                    self.pulsedLabel = self.labels[self.pointer.f]
                    self.pulsedLabel:setTint(color(255,255,255,255))
                    return command
                end
            end
        end
    end
end

function Program:play(val)
    self:resetPointer()
    self:unpulse()
end

function Program:won()
    self:unpulse()
end

-- unpulses whichever instruction is currently pulsed
function Program:unpulse()
    if self.pulsed then
        self.pulsed:unpulse()
        self.pulsed = nil
    end
    
    if self.pulsedLabel then
        self.pulsedLabel:setTint(color(150,150,150,255))
        self.pulsedLabel = nil
    end
end

-- for scoring when the user wins
function Program:insUsed()
    local count = 0
    for fi,func in ipairs(self.registers) do
        for ri,reg in ipairs(func) do
            local cmd = reg:getCommand()
            if cmd ~= "" then count = count + 1 end
        end
    end
    return count
end

function Program:setActiveRegisters(list)
    local retVal = {}
    for idx,regs in ipairs(self.registers) do
        for _,reg in ipairs(regs) do 
            reg:setActive((list==nil))
        end
    end
    
    if list then
        for idx,regs in ipairs(list) do
            for _,reg in ipairs(regs) do
                local obj = self.registers[idx][reg]
                obj:setActive(true)
                table.insert(retVal,obj)
            end
        end
    end
    return retVal
end
