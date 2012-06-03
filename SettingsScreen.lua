-- SettingsScreen.lua
-- where the user can set a profile and mute the music
SettingsScreen = class(BaseMenuScreen)

function SettingsScreen:init()
    BaseMenuScreen.init(self,"SETTINGS")
    
    -- back arrow
    local arrow = Button(10,HEIGHT - 37,13,27)
    arrow:flipX()
    self:doDraw(arrow,"Cargo Bot:How Arrow")
    self:add(arrow)
    arrow.onEnded = function(obj,t)
        transitionScreen:start(self,MenuScreen())
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
    
    self:musicSetting()
    self:profileSetting()
end

function SettingsScreen:draw()
    Screen.draw(self)
    if self.textbox then self.textbox:draw() end
end

function SettingsScreen:touched(touch)
    if touch.state == ENDED and self.textbox then
        if not self.textbox.profileBox:inbounds(touch) then
            self.textbox:inactivate()
            self.textbox.profileBox.active = true
            -- remake the name sprite
            local name = self.textbox.text
            IO.saveProfileName(self.textbox.profileIndex,name)
            
            self:makeProfileNameObj( name, true, self.textbox.profileBox )
            
            self.textbox = nil
        end
    end
    
    Screen.touched(self,touch)
end

function SettingsScreen:keyboard(key)
    if self.textbox then self.textbox:keyboard(key) end
end

function SettingsScreen:profileSetting()
    -- setting title
    local settingSprite = "profileSettingSprite"
    local w,h = Screen.makeTextSprite(settingSprite,"Profiles:",
        {fontSize = 45})
    local settingNameObj = SpriteObj(120,600,w,h)
    self:doDraw(settingNameObj,settingSprite)
    
    -- make the box sprite
    local boxSize = 150
    local makeBoxF = function(col,w)
        pushStyle()
        noSmooth()
        stroke(col)
        strokeWidth(w)
        noFill()
        rect(0,0,boxSize,boxSize)
        popStyle()
    end
    local profileBoxSpriteGrey = "profileBoxSpriteGrey"
    Screen.makeSprite(profileBoxSpriteGrey,function() makeBoxF(color(78,78,78,255),3) end,
        boxSize,boxSize)
    local profileBoxSpriteWhite = "profileBoxSpriteWhite"
    Screen.makeSprite(profileBoxSpriteWhite,function() makeBoxF(color(255,255,255,255),5) end,
        boxSize,boxSize)
        
    for profileIndex = 1,3 do
        -- make the box
        local x,y = -90 + 200 * profileIndex,420
        local star = SpriteObj(x+28,y+45,95,92)
        
        local name = IO.loadProfileName(profileIndex)
        -- load the score for this user
        local backup = CURRENT_USER
        CURRENT_USER = "Player "..profileIndex
        local score = IO.totalScore()
        CURRENT_USER = backup
            
        -- the star
        if score > 0 then 
            self:doDraw(star,"Cargo Bot:Star Filled")
            -- also draw the score
            local scoreSprite = "profileScoreSprite"..score
            local w,h = Screen.makeTextSprite(scoreSprite,score.."",
                {fontSize=30,font = "Futura-CondensedExtraBold",fill=color(120,56,30,255)})
            local scoreObj = SpriteObj(x+boxSize/2,y+95,w,h)
            self:doDraw(scoreObj,scoreSprite,1)
            scoreObj:setMode(CENTER)
        else 
            self:doDraw(star,"Cargo Bot:Star Empty") 
        end
        
        local isWhite = ( "Player "..profileIndex == CURRENT_USER )
        
        -- bounding box
        local profileBox = Button(x,y,boxSize,boxSize)
        if isWhite then 
            self:doDraw(profileBox,profileBoxSpriteWhite)
            self.selectedBox = profileBox
        else 
            self:doDraw(profileBox,profileBoxSpriteGrey) 
        end
        
        -- put the name at the bottom
        self:makeProfileNameObj( name, isWhite, profileBox )
        
        profileBox.onEnded = function(but,t)
            if self.selectedBox == but then
                -- this box is already selected and the user touched it again
                -- edit the name of this profile
                local nameNow = IO.loadProfileName(profileIndex)
                if nameNow == nil then nameNow = "" end
                print("nameObjY = "..profileBox.nameObj.y)
                self.textbox = Textbox(profileBox.x + 8,profileBox.nameObj.y,
                    profileBox.w - 16,profileBox.nameObj.h)
                self.textbox.profileBox = profileBox
                self.textbox.profileIndex = profileIndex
                self.textbox.text = nameNow
                self.textbox:setFontSize(20)
                self.textbox:activate()
                self:undoDraw(profileBox.nameObj)
                but.active = false
                self:add(self.textbox)
            else
                -- select this user
                -- remove the white name from the old box
                self:undoDraw(self.selectedBox.nameObj)
                -- make a new gray sprite for the name
                self:makeProfileNameObj(self.selectedBox.nameObj.name, false, self.selectedBox )
                -- remove the white box
                self:undoDraw(self.selectedBox)
                -- make a new gray box
                self:doDraw(self.selectedBox, profileBoxSpriteGrey)
                
                IO.saveCurrentUser(profileIndex)
                
                -- now start constructing the white sprites on the newly selected box
                self.selectedBox = but
                -- remove the grey name from the old box
                self:undoDraw(self.selectedBox.nameObj)
                -- make a new white sprite for the name
                self:makeProfileNameObj(self.selectedBox.nameObj.name, true, self.selectedBox )
                -- remove the grey box
                self:undoDraw(self.selectedBox)
                -- make a new white box
                self:doDraw(self.selectedBox, profileBoxSpriteWhite)                    
            end
        end
    end
end

function SettingsScreen:makeProfileNameObj(name,white,profileBox)
    if name == "" then name = " " end
       
    local nameSprite = "profileName" .. name
    local nameFill = color(255,255,255,255)
    
    if not white then 
        nameSprite = nameSprite .. "gray" 
        nameFill = color(78,78,78,255)
    end

    local w,h = Screen.makeTextSprite(nameSprite,name,{fontSize=20,fill=nameFill})
    local nameObj = SpriteObj(profileBox.x+profileBox.w/2-w/2,profileBox.y+30-h/2,w,h)
    self:doDraw(nameObj,nameSprite)
    nameObj.name = name
    -- set the name object on the profile box so we can use it below
    -- we don't want to use the nameObj directly because it might be a different
    -- nameObj later when the user edits the name
    profileBox.nameObj = nameObj 
end

-- makes the settings for turning the music on/off
function SettingsScreen:musicSetting()
    -- setting title
    local settingSprite = "musicSettingSprite"
    local w,h = Screen.makeTextSprite(settingSprite,"Music:",
        {fontSize = 45})
    local settingNameObj = SpriteObj(120,700,w,h)
    self:doDraw(settingNameObj,settingSprite)
    
    -- the box
    local makeBoxF = function()
        pushStyle()
        noSmooth()
        stroke(255, 255, 255, 255)
        strokeWidth(3)
        noFill()
        rect(0,0,40,40)
        popStyle()
    end
    local musicBoxSprite = "musicBoxSprite"
    Screen.makeSprite(musicBoxSprite,makeBoxF,40,40)
    local musicButton = Button(270,707,40,40)
    self:doDraw(musicButton,musicBoxSprite)
    
    -- the red x
    local redXF = function()
        stroke(255, 0, 0, 255)
        strokeWidth(8)
        lineCapMode(SQUARE)
        line(0,0,26,26)
        line(0,26,26,0)
    end
    local musicXSprite = "musicXSprite"
    Screen.makeSprite(musicXSprite,redXF,26,26)
    local musicXObj = SpriteObj(277,714,26,26)
    --self:doDraw(musicXObj,musicXSprite)
    
    -- the green check mark
    local greenCheckF = function()
        stroke(0, 255, 0, 255)
        strokeWidth(8)
        lineCapMode(SQUARE)
        line(0,15,14,0)
        line(10,0,26,26)
    end
    local musicCheckSprite = "musicCheckSprite"
    Screen.makeSprite(musicCheckSprite,greenCheckF,26,26)
    local musicCheckObj = SpriteObj(277,714,26,26)
    --self:doDraw(musicCheckObj,musicCheckSprite)
        
    if GLOBAL_MUTE then self:doDraw(musicXObj,musicXSprite)
    else self:doDraw(musicCheckObj,musicCheckSprite) end
    
    musicButton.onEnded = function(but,t)
        if GLOBAL_MUTE then
            GLOBAL_MUTE = nil
            IO.storeMusicState(true)
            self:undoDraw(musicXObj)
            self:doDraw(musicCheckObj,musicCheckSprite)
        else
            GLOBAL_MUTE = true
            IO.storeMusicState(false)
            self:undoDraw(musicCheckObj)
            self:doDraw(musicXObj,musicXSprite)
        end    
    end
end
