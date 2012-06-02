-- Crate.lua

Crate = class(Panel)

function Crate:init(x,y,config,colStr,imgName,screen)
    Panel.init(self,x,y)
    self.config = config
    self.imgName = imgName
    self.colStr = colStr
    assert(self.colStr ~= nil, "creating a crate without a colstr")

    if not self.config.shadows then
        self.obj = SpriteObj(0,0,config.w,config.h)
    else
        self.obj = ShadowObj(0,0,config.w,config.h)
    end
    self:addToScreen(screen)
    self:add(self.obj)
end

function Crate:addToScreen(screen)
    if not self.config.shadows then
        screen:doDraw(self.obj,self.imgName)
    else
        screen:doDraw(self.obj,self.imgName,0,-8)
        self.obj:setSizeOff(0,-1)
    end
end
