-- Toolbox.lua
-- toolbox is where the draggable instructions sit for the user to drag them

Toolbox = class(Panel)

function Toolbox:init(screen,toolStrs)
    Panel.init(self,490,40)
    self.screen = screen
    self.active = true
    
    self:makeBackground()
    self:makeTools(toolStrs)
end

function Toolbox:makeBackground()
    -- we use self.back later to find the dimensions of the toolbox
    self.back = SpriteObj(0,0,268,300)
    self.screen:doDraw(self.back,"Cargo Bot:Toolbox",-1)
    self:add(self.back)
end

function Toolbox:makeTools(tools)
    local allTools = {"right","pickup","left","f1","f2","f3","f4","f5",
    "blue","red","green","yellow","none","multi"}
    tools = tools or allTools
    self.tools = {}
    
    -- some layout configurations
    local perRow = 4
    local left = 26
    local top = 45
    local horSpacing = 3
    local vertSpacing = 4
    local dims = {
        command = {w = 50, h = 54},
        conditional = {w = 50, h = 43}
    }
    
    -- variables that we increment in the loop below to keep track of the current position
    local x = left
    local y = self.back.h - top
    local count = 0
    local rowMaxH = 0
    
    for idx,tool in ipairs(tools) do
        count = count + 1
        local thisDims = dims[Command.type(tool)]
        local move = Command(tool,x,y-thisDims.h,thisDims.w,thisDims.h)
        move.onBegan = function(mov,t)
            Events.trigger("play",false)
            Events.trigger("drag",{mov,t})
            Events.trigger("tutorial_toolbox_"..tool)
        end
        self.screen:doDraw(move,Command.spriteMap[tool])
        self:add(move)
        table.insert(self.tools,move)
        
        -- increment the coordinates
        rowMaxH = math.max(rowMaxH,thisDims.h)
        x = x + thisDims.w + horSpacing
        if count == perRow then
            y = y - rowMaxH - vertSpacing
            x = left
            count = 0
            rowMaxH = 0
        end
    end
end

function Toolbox:setActiveTools(tools)
    local retVal = {}
    if tools == nil then
        for _,tool in ipairs(self.tools) do 
            tool.active = true
        end
    else
        local asTable = {}
        for _,tool in ipairs(tools) do asTable[tool] = 1 end
        
        for _,tool in ipairs(self.tools) do
            local val = (asTable[tool.command]~=nil)
            tool.active = val
            if val then table.insert(retVal,tool) end
        end
    end
    return retVal
end
