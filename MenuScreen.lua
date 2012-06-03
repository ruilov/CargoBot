-- MenuScreen.lua
-- a screen that shows options for regular game or editor mode

MenuScreen = class(BaseMenuScreen)

function MenuScreen:init()
    BaseMenuScreen.init(self,"CARGO-BOT")

    -- back arrow
    local arrow = Button(10,HEIGHT - 37,13,27)
    arrow:flipX()
    self:doDraw(arrow,"Cargo Bot:How Arrow")
    self:add(arrow)
    arrow.onEnded = function(obj,t)
        transitionScreen:start(self,StartScreen())
        currentScreen = transitionScreen
    end
    
    -- back
    local backSprite = "backSprite"
    local w,h = Screen.makeTextSprite(backSprite,"BACK",
        {fontSize=28,fill=color(220, 178, 143, 255)})
    local backString = Button(30,HEIGHT - 44,w,h)
    self:doDraw(backString,backSprite)
    backString.onEnded = arrow.onEnded
    backString:setExtras({left=20,right=20,top=20,bottom=20})
    
    -- play game item
    -- 72,304,500
    self:makeItem(72,500,"PLAY",PackSelect(),1)

    -- edit game item
    self:makeItem(304,500,"CREATE",PackSelect(),2)
    
    -- setting item
    self:makeItem(536,500,"SETTINGS",SettingsScreen(),3)
end

function MenuScreen:makeItem(x,y,title,screen,type)
    local item = Button(x,y,159,160)
    self:doDraw(item,"Cargo Bot:Title Large Crate "..type)
    local itemStringSprite = "menuItem" .. title
    local w,h = Screen.makeTextSprite(itemStringSprite,title,
        {fontSize=30,fill=color(255, 228, 0, 255)})
    local stringObj = SpriteObj(x+(159)/2,y+(160)/2,w,h)
    self:doDraw(stringObj,itemStringSprite,1)
    stringObj:setMode(CENTER)
    item.onEnded = function(but,t)
        transitionScreen:start(self,screen)
        currentScreen = transitionScreen
    end
end
