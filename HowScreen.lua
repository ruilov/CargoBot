-- HowScreen.lua
-- a credits screen with links to the codea home page
HowScreen = class(Screen)

function HowScreen:init(oldScreen)
    Screen.init(self)

    -- background
    local obj = Button(0,0,WIDTH,HEIGHT)
    self:doDraw(obj,"Cargo Bot:Opening Background",-1)
    obj.onEnded = function(obj,t)
        transitionScreen:start(self,oldScreen)
        currentScreen = transitionScreen
    end

    -- codea logo
    local obj = Button((WIDTH - 405)/2,HEIGHT - 170,405,132)
    self:doDraw(obj,"Cargo Bot:Codea Logo")
    obj.onEnded = function(obj,t)
        openURL( "http://twolivesleft.com/Codea" )
    end
    
    -- about info panel
    local obj = Button(0,600,768,237)
    self:doDraw(obj,"Cargo Bot:About Info Panel")
    obj.onEnded = function(obj,t)
        openURL( "http://twolivesleft.com/Codea" )
    end
    
    -- codea icon
    local obj = Button((WIDTH - 322)/2,290,322,322)
    self:doDraw(obj,"Cargo Bot:Codea Icon")
    obj.onEnded = function(obj,t)
        openURL( "http://twolivesleft.com/Codea" )
    end
    
    -- made with codea
    local codea = Button(20,20,186,32)
    self:doDraw(codea,"Cargo Bot:Made With Codea")
    codea:setTint(color(255,255,255,128))
    codea.onEnded = function(obj,t)
        openURL( "http://twolivesleft.com/Codea" )
    end
    
    -- tap here for more
    local moreSprite = "moreCodea"
    local w,h = Screen.makeTextSprite(moreSprite,"Tap Here for more information about Codea™",
        {fontSize=25,fill=color(236, 229, 229, 128),font="HelveticaNeue-Bold"})
    local obj = Button((WIDTH - w)/2,270-h,w,h)
    self:doDraw(obj,moreSprite)
    obj.onEnded = function(obj,t)
        openURL( "itms-apps://itunes.com/apps/Codea" )
    end
    obj:setExtras({left=20,right=20,top=20,bottom=20})
    
    local backSprite = "hereback"
    local w,h = Screen.makeTextSprite(backSprite,"Tap Here to go Back",
        {fontSize=25,fill=color(198, 155, 155, 128),font="HelveticaNeue-Bold"})
    local obj = SpriteObj((WIDTH - w)/2,180-h,w,h)
    self:doDraw(obj,backSprite)
end
