-- BaseStage.lua
-- base stage contains piles and crates
-- it's used to draw the stage, the goal and the level select
-- it has a config table that says what the sprites and dimensions are
-- State of the base stage contains an array of piles in the same format as the level defs
BaseStage = class(Panel)

function BaseStage:init(config,screen,state)
    Panel.init(self,config.x,config.y)
    self.config = config
    self.screen = screen
    self.initialState = state
    self:makeBackground()
    self:makePiles()
end

function BaseStage:makeBackground()
    -- store the background object, because in level select we need to translate it a bit
    self.background = SpriteObj(0,0,self.config.w,self.config.h)
    self.screen:doDraw(self.background,self.config.sprite,-9)
    self:add(self.background)
end

function BaseStage:makePiles()
    self.piles = {}
    self.crateConfigs = {} -- keeps track of initial random aspects of crates so we can restore

    for idx,pileState in ipairs(self.initialState) do
        self:addPile()
        self.crateConfigs[idx] = {}
        for _,colStr in ipairs(pileState) do
            -- make a crate
            local randoms = self:crateRandoms(colStr)
            self.piles[idx]:push(randoms)
            table.insert(self.crateConfigs[idx],randoms)
        end
    end
end

-- puts the state back to the initialState. Takes care of keeping all the random
-- aspects the same
function BaseStage:resetState()
    for idx,pileConfigs in ipairs(self.crateConfigs) do
        local pile = self.piles[idx]
        -- empty the pile
        while pile:size() > 0 do pile:pop() end
        for _,crateRandoms in ipairs(pileConfigs) do
            self.piles[idx]:push(crateRandoms)
        end
    end
end

-- copy the state from another stage, for the level to win transition
function BaseStage:copyState(other)
    for idx,oPile in ipairs(other.piles) do
        local pile = self.piles[idx]
        -- empty the pile
        while pile:size() > 0 do pile:pop() end
        
        for crate in oPile.crates:iter() do
            local crateCfg = {
                colStr = crate.colStr,
                imgName = crate.imgName,
                dx = oPile:crateDx(crate),
                inverted = crate.obj.w < 0
            }
            self.piles[idx]:push(crateCfg)
        end
    end
end

-- makes up the random charaterics of a crate: sprite, dx, inverted
function BaseStage:crateRandoms(colStr)
    local imgName = Table.random(self.config.crateSprites[colStr])
    local dx = math.random(self.config.crateOffsets.min,self.config.crateOffsets.max)
    
    -- a bit of hack here. If the min crate offset is 0, then don't invert crates
    local inverted = (self.config.crateOffsets.min ~= 0)
    if inverted then inverted = (math.random() > .5) end
    
    return {colStr = colStr,imgName = imgName, dx = dx, inverted = inverted}
end

-- adds a pile on the right and re-centers the piles
function BaseStage:addPile(bindPile)
    assert(#self.piles < self.config.maxPiles,"trying to add too many piles") 
    
    local newPile
    if #self.piles == 0 then
        local pileNum = math.floor(self.config.maxPiles/2)
        newPile = Pile(pileNum*self.config.pile.w,self.config.pile.y,
            self.config.pile,self.screen)
    else
        -- shift the piles to left by half
        for _,pile in ipairs(self.piles) do 
            pile:translate(-math.floor(self.config.pile.w/2),0)
        end
        newPile = Pile(self.piles[#self.piles].x - self.x +
            self.config.pile.w,self.config.pile.y,
            self.config.pile,self.screen)
    end
    
    self:add(newPile)
    table.insert(self.piles,newPile)
    
    -- bind pile is used when adding piles in editor mode
    -- for regular mode we don't need this because the whole 
    -- level is bound all at once
    if bindPile then newPile:bind() end
end

function BaseStage.compareStages(stage1,stage2)
    if #stage1.piles ~= #stage2.piles then return(false) end

    for p = 1,#stage1.piles do
        local p1 = stage1.piles[p]
        local p2 = stage2.piles[p]
        if p1:size() ~= p2:size() then return false end
        
        local p1Iter = p1.crates:iter()
        local p2Iter = p2.crates:iter()
        
        for b = 1,p1:size() do
            local crate1 = p1Iter()
            local crate2 = p2Iter()
            if crate1.colStr ~= crate2.colStr then return false end
        end
    end
    return true
end
