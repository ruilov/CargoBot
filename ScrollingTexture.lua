-- ScrollingTexture.lua

ScrollingTexture = class(Panel)

function ScrollingTexture:init(imgName,screen,x,y,w,h,z)
    Panel.init(self,x,y)
    self.texOffset = 0
    self.imgName = imgName
    self.screen = screen
    local imgW,imgH = spriteSize(imgName)
    local nw = w / imgW
    local nh = h / imgH
    
    
    self.objs = {}
    for x = 1,nw do
        for y = 1,nh do
            local obj = SpriteObj((x-1)*imgW,(y-1)*imgH,imgW,imgH)
            screen:doDraw(obj,imgName,z)
            self:add(obj)
            table.insert(self.objs,obj)
        end
    end
end

function ScrollingTexture:tick()
    self.texOffset = self.texOffset + DeltaTime * 0.2
    for _,obj in ipairs(self.objs) do
        obj:setRectTex(self.texOffset,self.texOffset,1,1)
    end
end

function ScrollingTexture:copyToScreen(screen,z)
    for _,obj in ipairs(self.objs) do
        self.screen:undoDraw(obj)
        self.screen:remove(obj)
        
        screen:doDraw(obj,self.imgName,z)
        obj:setRectTex(self.texOffset,self.texOffset,1,1)
    end
    self.screen = screen
end
