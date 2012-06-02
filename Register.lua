-- Register.lua
-- A register represents a register slot in the user program
-- It can hold one command and one conditional 

Register = class(Panel)

function Register:init(x,y,config,isLast,screen)
    Panel.init(self,x,y)
    self.config = config
    self.screen = screen
    
    self:makeSlot(isLast)
    
    -- w,h so we can determine which register the user has dropped a move into
    -- also used for when the user tries to pick up an existing command
    self.w = config.w
    self.h = config.h
    self.button = Button(0,0,self.w,self.h)
    self:add(self.button)
end

function Register:inbounds(touch)
    return self.button:inbounds(touch)
end

function Register:makeSlot(isLast)
    local spr = "Cargo Bot:Register Slot"
    if isLast then spr = "Cargo Bot:Register Slot Last" end
    self.slot = SpriteObj(0,0,self.config.slot.w,self.config.slot.h)
    self.screen:doDraw(self.slot,spr,-1)
    self:add(self.slot)
end

function Register:select()
    self.slot:setTint(color(200,200,200,255))
    if self.command then
        self.command:setTint(color(200,200,200,255))
    end
end

function Register:unselect()
    self.slot:setTint(color(255,255,255,255))
    if self.command then
        self.command:setTint(color(255,255,255,255))
    end
end

function Register:setCommand(command)
    -- check if we're overwriting an existing command
    if self.command then 
        self:remove(self.command)
        self.screen:undoDraw(self.command)
    end
    
    if command == "" then
        self.command = nil
    else
        self.command = Command(command,self.config.command.x,self.config.command.y,
            self.config.command.w,self.config.command.h)
        self.screen:doDraw(self.command,Command.spriteMap[command],2)
        self.command.onBegan = function(but,t)
            self:setCommand("")
            Events.trigger("play",false)
            Events.trigger("drag",{but,t})
            Events.trigger("tutorial_register_pickup")
        end
        
        self.command:rotate(math.random(0,14)-7) 
        self:add(self.command)
    end
end

function Register:setConditional(command)
    if self.conditional then 
        self:remove(self.conditional)
        self.screen:undoDraw(self.conditional)
    end
    
    if command == "" then 
        self.conditional = nil
    else
        self.conditional = Command(command,self.config.conditional.x,
            self.config.conditional.y,
            self.config.conditional.w,
            self.config.conditional.h)
        self.screen:doDraw(self.conditional,Command.spriteMap[command],1)
        self.conditional.onBegan = function(but,t)
            self:setConditional("")
            Events.trigger("play",false)
            Events.trigger("drag",{but,t})
            Events.trigger("tutorial_register_pickup")
        end
        self:add(self.conditional)
    end
end

---- GETTERs ----------
function Register:hasCommand()
    return self.command
end

function Register:getCommand()
    if not self.command then return "" end
    return self.command.command
end

function Register:hasConditional()
    return self.conditional
end

function Register:getConditional()
    if not self.conditional then return "" end
    return self.conditional.command
end

function Register:pulse()
    local pulseScale = 1.2
    if self.command then
        self.command:setSize(self.config.command.w*pulseScale,
            self.config.command.h*pulseScale)
        self.command:translate(-self.config.command.w*(pulseScale-1)/2,
            -self.config.command.h*(pulseScale-1)/2)
            
        -- move it up a few z-orders so that it draws on top of other stuff
        self.screen:undoDraw(self.command)
        self.screen:doDraw(self.command,Command.spriteMap[self.command.command],5)
    end
end

function Register:unpulse()
    local pulseScale = 1.2
    if self.command then
        self.command:setSize(self.config.command.w,self.config.command.h)
        self.command:translate(self.config.command.w*(pulseScale-1)/2,
            self.config.command.h*(pulseScale-1)/2)
        
        -- move it back down in the z-order
        self.screen:undoDraw(self.command)
        self.screen:doDraw(self.command,Command.spriteMap[self.command.command],2)
    end
end
