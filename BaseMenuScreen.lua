-- BaseMenuScreen.lua
-- a screen with the standard menu background and links for credits at the bottom
-- subclassed by most menu type of screens
BaseMenuScreen = class(Screen)

function BaseMenuScreen:init(title)
    Screen.init(self)
    self.title = title
    
    -- add the background
    local back = SpriteObj(0,0,WIDTH,HEIGHT)
    self:doDraw(back,"Cargo Bot:Game Lower BG",-12)

    -- add the other background 
    local bottom = SpriteObj(0,0,768,296)
    self:doDraw(bottom,"Cargo Bot:Opening Crates",-11)
    bottom:setTint(color(255,255,255,160))

    -- add the title
    local titleSprite = "selectTitle"..self.title
    local titleArgs = {fontSize = 80}
    local titleW,titleH = Screen.makeTextSprite(titleSprite,self.title,titleArgs)
    local titleObj = SpriteObj(WIDTH/2,930,titleW,titleH)
    self:doDraw(titleObj,titleSprite)
    titleObj:setMode(CENTER)

    -- credits
    local creditSprite = "credits"
    local w,h = Screen.makeTextSprite(creditSprite,"CREDITS",
        {fontSize=20,fill=color(221, 143, 143, 128)})
    local obj = Button(10, 10, w, h)
    self:doDraw(obj,creditSprite)
    obj:setExtras({left=20,right=20,top=20,bottom=20})
    obj.onEnded = function(obj,t)
        transitionScreen:start(self,CreditsScreen(self))
        currentScreen = transitionScreen
    end
    
    -- how this game was made arrow
    local arrow = Button(740,20,13,27)
    self:doDraw(arrow,"Cargo Bot:How Arrow")
    arrow.onEnded = function(obj,t)
        local how = HowScreen(self)
        transitionScreen:start(self,how)
        currentScreen = transitionScreen
    end
    
    -- how this game was created?
    local howSprite = "howCreatedSprite"
    local w,h = Screen.makeTextSprite(howSprite,"HOW WAS THIS GAME CREATED?",
        {fontSize=20,fill=color(221,143,143,128)})
    local howString = Button(730-w,15,w,h)
    self:doDraw(howString,howSprite)
    howString.onEnded = arrow.onEnded
    howString:setExtras({left=20,right=40,top=20,bottom=20})
end
