-- LevelSelect.lua
-- LevelSelect shows one of the 6 levels for each pack and lets the user choose one
LevelSelect = class(BaseSelect)

function LevelSelect:init(name,score)
    BaseSelect.init(self,name)
    self.name = name
    self.score = score
    
    -- back arrow
    local arrow = Button(10,HEIGHT - 37,13,27)
    arrow:flipX()
    self:doDraw(arrow,"Cargo Bot:How Arrow")
    self:add(arrow)
    arrow.onEnded = function(obj,t)
        Events.trigger("levelSelect",self,true)
    end
    
    -- back
    local backSprite = "backSprite"
    local w,h = Screen.makeTextSprite(backSprite,"BACK",
        {fontSize=28,fill=color(220, 178, 143, 255)})
    local backString = Button(30,HEIGHT - 44,w,h)
    self:doDraw(backString,backSprite)
    backString.onEnded = arrow.onEnded
    backString:setExtras({left=20,right=20,top=20,bottom=20})
    
    -- find the right pack
    local pack = nil
    local packIdx = nil
    for idx,p in ipairs(packs) do
        if p.name == self.name then
            pack = p.levels
            packIdx = idx
        end
    end
    assert(pack~=nil,"could not find pack "..self.name)
    
    Screen.makeSprite("levelSelectArrow",LevelSelect.makeArrow,60,50)
    
    -- arrow right
    if packIdx < #packs then
        local rightB = Button(WIDTH-55,485,60,50)
        rightB.onEnded = function(but,t)
            local newName = packs[packIdx+1].name
            local newLevelSelect = LevelSelect(newName,self.score)
            transitionScreen:start(self,newLevelSelect,true)
        end
        self:add(rightB)
        self:doDraw(rightB,"levelSelectArrow")
        rightB:setTint(color(255,255,255,128))
    end
    
    -- left arrow
    if packIdx > 1 then
        local leftB = Button(50,485,-60,50)
        leftB.onEnded = function(but,t)
            local newName = packs[packIdx-1].name
            local newLevelSelect = LevelSelect(newName,self.score)
            transitionScreen:start(self,newLevelSelect,true)
        end
        self:add(leftB)
        self:doDraw(leftB,"levelSelectArrow")
        leftB:setTint(color(255,255,255,128))
    end

    -- create the level items
    local itemW = 250
    local itemH = 180
    local ystart = HEIGHT - 200
    local yspace = 50
    for idx,level in ipairs(pack) do
        -- find the curresponding level
        local levelData
        for n,d in ipairs(levels) do
            if d.name == level then
                levelData = d
            end
        end
        assert(levelData~=nil,"Could not find level "..level)
        
        local item = LevelItem(levelData,self)
        local xgrid = (idx-1)%2+1
        local ygrid = math.floor((idx-1)/2) + 1
        local x = 50
        if xgrid == 2 then x = 400 end

        local y = yspace*(ygrid-1)+itemH*ygrid
        item:translate(x,ystart-y)
        self:add(item)
    end
end

function LevelSelect.makeBackButton()
    spriteMode(CORNERS)
    noTint()
    sprite("Cargo Bot:Replay Button",-95,0,40,34)
end

function LevelSelect.makeArrow()
    spriteMode(CORNERS)
    noTint()
    sprite("Cargo Bot:Next Button",-95,0,40,34)
end

LevelItemStage = class(BaseStage)

-- config for the goal display
function LevelItemStage:config()
    local config = {x=0,y=0,w=248,h=149,sprite="Cargo Bot:Level Select BG"}
    config.shadows = false
    config.maxPiles = 9
    config.crate = {w=10,h=11,borderY=-1,shadows=config.shadows}
    
    -- setup dimensions for the piles
    config.pile = {
        y = 4,
        base={h=5,borderY=-1,sprite="Cargo Bot:Platform"},
        crate = config.crate,
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

function LevelItemStage:init(screen,state)
    BaseStage.init(self,LevelItemStage.config(),screen,state.piles)
end

LevelItem = class(Panel)

function LevelItem:init(levelData,screen)
    Panel.init(self,0,0)
    self.title = levelData.name
    self.screen = screen
    
    local button = Button(0,0,308,186)
    button.onEnded = function(but,t)
        local level = Level(levelData)
        transitionScreen:start(screen,level)
        transitionScreen.endCallback = function() 
            sounds:play("select_level")
            level:addTutorial()
        end
        currentScreen = transitionScreen
    end
    self:add(button)

    -- create the stage
    local stageState = {piles = levelData.stage}
    self.stage = LevelItemStage(screen,stageState)
    
    -- the frame
    local frame = SpriteObj(0,0,308,186)
    screen:doDraw(frame,"Cargo Bot:Level Select Frame",-8)
    self:add(frame)
    
    -- position the stage
    local dx = (frame.w - self.stage.config.w)/2 + 3
    local dy = 23
    self.stage:translate(dx,dy)
    self.stage.background:translate(0,-10)
    self:add(self.stage)
    
    -- title
    local spriteName = "levelItemTitle"..self.title
    local w,h = Screen.makeTextSprite(spriteName,self.title,{fontSize=23})
    local titleX = 160-w/2
    local titleY = 110
    self.titleObj = SpriteObj(titleX,titleY,w,h)
    screen:doDraw(self.titleObj,spriteName,100)
    self:add(self.titleObj)

    -- stars
    local numStars = IO.levelTopScore(levelData.name)
    local starSpacing = 38
    for i = 1,3 do
        local spr = "Cargo Bot:Star Filled"
        if i > numStars then spr = "Cargo Bot:Star Empty" end
        local x = 100 + (i-1) * starSpacing
        local obj = SpriteObj(x,-28,35,34)
        screen:doDraw(obj,spr)
        self:add(obj)
        if numStars > 3 then
            
            local starPulse = function(ds)
                local w,h = obj:getSize()
                obj:setSize(w+ds,h+ds)
                local x,y = obj:getPos()
                obj:translate(-ds/2,-ds/2)
            end
            
            local grow = false
            local tweenerMaker
            tweenerMaker = function()
                -- reset the size to make sure the size doesnt diverge over time
                if not grow then
                    local w,h = obj:getSize()
                    starPulse(35 - w)
                end
                
                local count = 0
                local f = function()
                    count = count + 1
                    if count > 3 then
                        count = 0
                        if grow then starPulse(2) else starPulse(-2) end
                    end
                end
                
                grow = not grow
                local tweener = Tweener(.4,f,tweenerMaker)
                Tweener.add(tweener)
            end
            
            tweenerMaker()
        end
    end
end

function LevelItem:setDrawTitle(val)
    if val then self.screen:doDraw(self.titleObj,"title"..self.title,100)
    else self.screen:undoDraw(self.titleObj) end
end
