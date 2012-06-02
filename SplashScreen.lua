-- SplashScreen.lua
-- the first screen that shows up when you start the game. Shows until the music is loaded
-- then transitions out to the StartScreen
SplashScreen = class(Screen)

function SplashScreen:init()
    Screen.init(self)
    
    Music.startLoading("StartScreen")
    
    -- background
    self.back = SpriteObj(0,0,WIDTH,HEIGHT)
    self:doDraw(self.back,"Cargo Bot:Startup Screen")
    self:add(self.back)
    
    -- loading message
    local w,h = Screen.makeTextSprite("loadingMsg","LOADING",{fontSize=30,
        fill=color(211, 164, 133, 255)})
    self.loadW,self.loadH = w,h
    self.loading = SpriteObj((WIDTH-w)/2,935,w,h)
    self:doDraw(self.loading,"loadingMsg",2)
    self:add(self.loading)
    
    -- progress bar
    self.bar = ProgressBar((WIDTH)/2,875,w,40,self)
    self.bar:setVal(0)
    self:add(self.bar)
end

function SplashScreen:bindEvents()
    Events.bind("musicLoaded",self,self.transitionOut) -- triggered by Music.tick()
end

function SplashScreen:tick()
    if Music.loadProgress ~= self.bar.val then
        self.bar:setVal(Music.loadProgress)
    end
    
    Music.tick()
end

function SplashScreen:transitionOut()
    local tweener = Tweener(1,
        function(r) self:setTint(color((1-r)*255,(1-r)*255,(1-r)*255,255)) end,
        function() self:transitionStartScreen() end)
    Tweener.add(tweener)
end

function SplashScreen:transitionStartScreen()
    local startScreen = StartScreen()
    transitionScreen:startClosed(self,startScreen)
    currentScreen = transitionScreen
end

ProgressBar = class(Panel)

function ProgressBar:init(x,y,w,h,screen)
    Panel.init(self,x-254/2,y)
    self.screen = screen
    self.w = w
    self.h = h
    
    local back = SpriteObj(0,0,254,57)
    self:add(back)
    self.screen:doDraw(back,"Cargo Bot:Loading Bar",2)
end

function ProgressBar:setVal(val)
    val = math.min(val,1)
    val = math.max(val,0)

    if self.blocks then
        for _,block in ipairs(self.blocks) do
            self.screen:undoDraw(block)
            self:remove(block)
        end
    end
    
    self.blocks = {}

    -- full blocks
    local fulls = math.floor(val*5)
    for i = 1,math.min(fulls+1,5) do
        local block = SpriteObj(i*49-41,8,43,43)
        local spr = "Cargo Bot:Crate Yellow " .. ((i%3)+1)
        self.screen:doDraw(block,spr,3)
        self:add(block)
        table.insert(self.blocks,block)
        if i == fulls+1 then -- the last block is with lower alpha
           local alpha = math.floor(val*15) - fulls * 3
            alpha = 255 * (alpha/3)
            block:setTint(color(255,255,255,alpha))
        end
    end
end
