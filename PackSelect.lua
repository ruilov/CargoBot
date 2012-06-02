-- PackSelect.lua
-- The screen where the user selects one of the level packs

PackSelect = class(BaseSelect)

function PackSelect:init()
    BaseSelect.init(self,"Level Packs")
    self.items = {}
    self:update()
end

function PackSelect:bindEvents()
    Events.bind("levelSelect",self,self.show)
end

function PackSelect:update()
    -- first reset
    for _,item in ipairs(self.items) do
        item:undraw(self)
    end
    self:removeAll()
    
    -- then recreate
    
    -- back arrow
    local arrow = Button(10,HEIGHT - 37,13,27)
    arrow:flipX()
    self:doDraw(arrow,"Cargo Bot:How Arrow")
    self:add(arrow)
    arrow.onEnded = function(obj,t)
        transitionScreen:start(self,StartScreen())
        currentScreen = transitionScreen
        --Events.trigger("levelSelect",self,true)
    end
    
    -- back
    local backSprite = "backSprite"
    local w,h = Screen.makeTextSprite(backSprite,"BACK",
        {fontSize=28,fill=color(220, 178, 143, 255)})
    local backString = Button(30,HEIGHT - 44,w,h)
    self:doDraw(backString,backSprite)
    backString.onEnded = arrow.onEnded
    backString:setExtras({left=20,right=20,top=20,bottom=20})
    
    self.score = IO.totalScore()

    -- create each of the pack items
    local itemW = 214
    local itemH = 212
    local xspace = (WIDTH - 2*itemW)/3
    local ystart = HEIGHT - 200
    local yspace = -6
    self.items = {}
    for idx,pack in ipairs(packs) do
        local item = PackItem(itemW,itemH,pack.name,self.score,self)
        local xgrid = (idx-1)%2+1
        local ygrid = math.floor((idx-1)/2) + 1
        item:translate(xspace*xgrid+itemW*(xgrid-1),ystart-yspace*(ygrid-1)-itemH*ygrid)
        self:add(item)
        table.insert(self.items,item)
    end
end

function PackSelect:show(oldScreen,skipCutScene)
    self:update()
    transitionScreen:start(oldScreen,self,skipCutScene)
    if not skipCutScene then currentScreen = transitionScreen end
    Music.switch("Start")
end

PackItem = class(Panel)

function PackItem:init(w,h,name,score,screen)
    Panel.init(self,0,0)
    self.w,self.h = w,h
    
    -- for detecting touches
    local button = Button(0,0,w,h)
    self:add(button)
    button.onEnded = function(but,t)
        local levelSelect = LevelSelect(name,score)
        transitionScreen:start(screen,levelSelect,true)
        --currentScreen = transitionScreen
        screen:bind() -- leave it bounded so we can go back to it from the level select screen
    end

    -- add the background
    local spr = "Cargo Bot:Pack " .. name
    local backObj = SpriteObj(0,0,w,h)
    screen:doDraw(backObj,spr,-1)
    self:add(backObj)
      
    -- add the star
    local score = IO.packScore(name)
    local starSpr = "Cargo Bot:Star Empty"
    if score > 0 then starSpr = "Cargo Bot:Star Filled" end
    local starObj = SpriteObj(w/2,h/2,95,92)
    starObj:setMode(CENTER)
    self:add(starObj)
    screen:doDraw(starObj,starSpr)
    
    -- add the text at the bottom
    local txt = "Tap to Play"
    if score > 0 then txt = score .. " of 18" end
    local txtSprite = txt .. "packItemSpr"
    local txtArgs = {fontSize = 20,fill=color(255, 255, 255, 255)}
    local txtW,txtH = Screen.makeTextSprite(txtSprite,txt,txtArgs)
    local txtObj = SpriteObj(w/2,50,txtW,txtH)
    screen:doDraw(txtObj,txtSprite)
    self:add(txtObj)
    txtObj:setMode(CENTER)
end
