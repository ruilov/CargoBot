-- BaseMenu.lua
-- Helper class that is subclassed by the two types of level select screens
BaseSelect = class(BaseMenuScreen)

function BaseSelect:init(title)
    BaseMenuScreen.init(self,title)
    self.score = 0
    
    -- the corner star
    local star = SpriteObj(WIDTH-120,HEIGHT-120,95,92)
    self:doDraw(star,"Cargo Bot:Star Filled")
end

function BaseSelect:draw()
    Screen.draw(self)
    
    -- the score
    font("Futura-CondensedExtraBold")
    fontSize(30)
    if self.score >= 100 then fontSize(20) end
    textMode(CENTER)
    fill(120, 56, 30, 255)
    text(self.score,WIDTH-73,HEIGHT-70)
end

