-- Pile.lua
-- Piles contain a Stack of crates

Pile = class(Panel)

function Pile:init(x,y,config,screen)
    Panel.init(self,x,y)
    self.config = config
    self.screen = screen
    
    self.crates = Stack()
    
    -- the base of the pile
    local baseX = math.floor((self.config.w - self.config.base.w)/2)
    local baseW,baseH = self.config.base.w,self.config.base.h
    if self.config.shadows then
        self.base = ShadowObj(baseX,0,baseW,baseH)
        screen:doDraw(self.base,self.config.base.sprite,0,-8)
    else
        self.base = SpriteObj(baseX,0,baseW,baseH)
        screen:doDraw(self.base,self.config.base.sprite)
    end
    self:add(self.base)
end

function Pile:push(args)
    assert(args.imgName ~= nil, "Trying to push a crate with no imgName")
    assert(args.colStr ~= nil, "Truing to push a crate with no colStr")
    local imgName = args.imgName
    local colStr = args.colStr
    local dx = args.dx or 0
    local inverted = args.inverted or false
    
    --  calculate the coords of the crate
    local y = self.config.base.h + self.config.base.borderY
    y = y + self.crates:size() * (self.config.crate.h + self.config.crate.borderY)
    local x = math.floor((self.config.w - self.config.crate.w)/2)

    -- make the actual obj
    local crate = Crate(x+dx,y,self.config.crate,colStr,imgName,self.screen)
    if inverted then crate:flipX() end
    self.crates:push(crate)
    self:add(crate)
end

-- retrieves the dx of this crate in this pile based on its position
function Pile:crateDx(crate)
    local x = math.floor((self.config.w - self.config.crate.w)/2)
    return crate.x - x - self.x
end

-- push method for when we already have a crate object
function Pile:pushCrate(crate,dx)
    crate:addToScreen(self.screen)
    
    --  calculate the coords of the crate
    local y = self.config.base.h + self.config.base.borderY
    y = y + self.crates:size() * (self.config.crate.h + self.config.crate.borderY)
    local x = math.floor((self.config.w - self.config.crate.w)/2)
    x = x + dx
    crate:translate(x - crate.x, y - crate.y)
    
    self:add(crate)
    self.crates:push(crate)
end

-- return the crate itself
function Pile:pop()
    local crate = self.crates:pop()
    self:remove(crate)
    self.screen:undoDraw(crate.obj)
    return crate
end

function Pile:size()
    return self.crates:size()
end
