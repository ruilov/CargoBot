-- Goa.lua
-- The area that appears on top in each level

Goal = class(BaseStage)

function Goal:config()
    local config = {x=184,y=720,w=400,h=198,sprite="Cargo Bot:Goal Area"}
    config.shadows = false
    config.maxPiles = 9
    config.crate = {w=21,h=21,borderY=-3,shadows=config.shadows}
    
    -- setup dimensions for the piles
    config.pile = {
        y = 7,
        base={h=10,borderY=-2,sprite="Cargo Bot:Platform"},
        crate=config.crate,
        shadows = config.shadows
    }
    -- we need pile width to know how far apart to draw the piles
    config.pile.w = math.floor(config.w / config.maxPiles)
    config.pile.h = config.h -- needed for editor mode to know whether a block should be added
    config.pile.base.w = math.floor(config.pile.w*.8)
    
    config.crateSprites = {
        blue = {"Cargo Bot:Crate Goal Blue"},
        red = {"Cargo Bot:Crate Goal Red"},
        green = {"Cargo Bot:Crate Goal Green"},
        yellow = {"Cargo Bot:Crate Goal Yellow"}
    }
    -- the little dx offsets
    config.crateOffsets = {min=0,max=0}
    return config
end

function Goal:init(screen,state)
    BaseStage.init(self,Goal.config(),screen,state.piles)
end
