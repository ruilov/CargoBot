Sounds = class()

function Sounds:init()
    self.sounds = {
        select_level = "ZgJA6gBAQGhEO1QUdkp/PbB+pT6YmjY/WAAAaCVGOw0/FVV4",
        select_tile = "ZgNAOCQaAAAAAAByAAAAAAAAAAAURCA+AAA7ezU7PT8AAFsA",
        drop_tile_smoke = "ZgNAFQBAXFM/Oys5spQ6PisNZT20IOU+QQB7SEBUTlsxBRIG",
        bump_claw = "ZgFAYQABbgJAWx5ZoXmyPTBczj52Sn89XQBHTzRFQEALfBkQ",
        pieces_crash_metal = "ZgFAegABbgJAWx5ZoXmyPTBczj52Sn89XQBHTzRFQEALfBkQ",
        pieces_crash_box = "ZgFAegABbgJAJgdZoXmyPTBczj52Sn89XQBHTzRFQEALXhkQ",
        claw_up = "ZgNATQBFR0VGTTok/BW5PhL23T5Fx88+OgBUWkU5DGBBEShG",
        claw_sideways = "ZgNAXwBAPz9GJigIj8YoPmD2Njydq14+ZQA3fT1dET8/WDRu",
        claw_squeeze_empty = "ZgNAVQBAQCBHRCJ8DzN4PsQMvj0GiFM/cgBNZDVAP0dSLTZS",
        claw_grabs_box = "ZgNADQA9PUJCQAthAAAAALicKz7PfFA+fwBZRkA+QzM+PDtD",
        success = "ZgBAJQBVQEZAQEBAAAAAADuKaz76A+A+QABAf0BAQEBAW0BA",
        drop_tile_register = "ZgNAQAA/QABCAAACXnA6vQSWSz8gLIO8ZABHTjNLP0BAAHM+",
        click_play = "ZgJAQQA/P349GHQWAAAAAKZhYj8AAAAALABvXClAQAxESG4T",
        click_stop = "ZgJAQQA/P349GHQWAAAAAKZhYj8AAAAALABvXClAQAxEXm4T",
        crate_drop = "ZgNAIgBBQEBAZ11AAAAAABei5D1NMsk9VgBAf0BAQEBAQHkS",
        box_crash = "ZgNADQA9PUJCQAthAAAAALicKz7PfFA+fwBZRkA+QzM+PDtD",
        claw_down0 = "ZgNAdgBBQFFLd0ckIPkgNAAAAACG1J++QQBnUj5ADGBBESg5",
        claw_down1 = "ZgNAdgBBQFFLd0ckIPkgNLsRzz2G1J++QQBnUj5ADGBBESg5",
        claw_down2 = "ZgNAdgBBQFFLd0ckIPkgNG/rFD6G1J++QQBnUj5ADGBBESg5",
        claw_down3 = "ZgNAdgBBQFFLd0ckIPkgNOZcdT6G1J++QQBnUj5ADGBBESg5",
        claw_down4 = "ZgNAdgBBQFFLd0ckIPkgNDfimT6G1J++QQBnUj5ADGBBESg5",
        claw_down5 = "ZgNAdgBBQFFLd0ckIPkgNBzxzD6G1J++QQBnUj5ADGBBESg5",
        claw_down6 = "ZgNAdgBBQFFLd0ckIPkgNA01Az+G1J++QQBnUj5ADGBBESg5"
    }
    
    self.nextT = 0
    self.cachingSpeed = 0 -- in seconds
    self.toCache = {}
    for key,value in pairs(self.sounds) do
        table.insert(self.toCache,value)
    end
    self.cachedIdx = 0
    
end

function Sounds:cache()
    -- if we're done caching then do nothing
    if self.cachedIdx >= #self.toCache then return nil end
    
    -- is it time to cache a new sound?
    if ElapsedTime > self.nextT then
        self.cachedIdx = self.cachedIdx + 1
        --print("caching",self.cachedIdx)
        ABCMusic:adjustSoundBufferSize()
        sound(DATA,self.toCache[self.cachedIdx],0)
        self.nextT = self.nextT + self.cachingSpeed
    end
end

-- duration is only passed in for:
-- claw_sideways
-- claw_down
function Sounds:play(type,duration)
    if GLOBAL_MUTE then return nil end
    
    -- play the right length sound for going down
   if type == "claw_down" then
        local soundLength = math.floor(duration*10)
        if soundLength > 6 then soundLength = 6 end
        type = type .. tostring(soundLength)
    end
    assert(self.sounds[type]~=nil,"invalid sound type: "..type)
    sound(DATA,self.sounds[type])
end

-- types are: "crate", "claw", "base", "wall", "ground"
function Sounds:collide(typea,typeb,contact)
    if GLOBAL_MUTE then return nil end
    
    if contact.state == BEGAN then
        if contact.normalImpulse > 2 then
            if typea == "claw" or typeb == "claw" then
                sound(DATA, "ZgFAegABbgJAWx5ZoXmyPTBczj52Sn89XQBHTzRFQEALfBkQ",
                    contact.normalImpulse/20)
            else
                sound(DATA, "ZgNADQA9PUJCQAthAAAAALicKz7PfFA+fwBZRkA+QzM+PDtD",
                   contact.normalImpulse/20)
            end
        end
    end
end
