CreditsScreen = class(Screen)

function CreditsScreen:init(oldScreen)
    Screen.init(self)
    
    -- background
    self.back = Button(0,0,WIDTH,HEIGHT)
    self:doDraw(self.back,"Cargo Bot:Startup Screen")
    self:add(self.back)
    self.back.onEnded = function(obj,t)
        transitionScreen:start(self,oldScreen)
        currentScreen = transitionScreen
    end
end
