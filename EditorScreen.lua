-- EditorScreen.lua
-- the place where you go to create new levels. Looks like the level screen but acts different

EditorScreen = class(Screen)

function EditorScreen:init()
    Screen.init(self)
    
    -- floor
    local obj = SpriteObj(0,359,768,21)
    self:doDraw(obj,"Cargo Bot:Game Area Floor",-7)
    
    -- roof
    local obj = SpriteObj(0,687,768,26)
    self:doDraw(obj,"Cargo Bot:Game Area Roof",-7)
    
    -- lower BG
    local obj = SpriteObj(0,0,768,364)
    self:doDraw(obj,"Cargo Bot:Game Lower BG",-10)

    -- upper BG
    local obj = SpriteObj(0,708,768,364)
    self:doDraw(obj,"Cargo Bot:Game Upper BG",-10)
end
