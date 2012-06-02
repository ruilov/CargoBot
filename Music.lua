Music = class()

Music.loadProgress = 0
function ABCMusic:percentageCached()
    return cachedIdx / #gPreCacheSoundTable
end

-- THESE FUNCTIONS ARE THE PUBLIC API --

-- called when we are switching to a new screen
-- return true if we should show the loading message because the transition will take a while
function Music.startLoading(type,name)
    --print("music",type,name)
    Music.isLoading = true
    local retVal = false
    if type == "StartScreen" then retVal = Music.startScreen()
    elseif type == "PackSelect" then retVal = Music.packSelect()
    elseif type == "LevelSelect" then retVal = Music.levelSelect(name) -- name is the name of the pack
    elseif type == "Level" then retVal = Music.level(name) -- name is the name of the level
    elseif type == "WinScreen" then retVal = Music.winScreen(name) -- name is the name of the level
    else
        assert(false,"invalid music type: "..type)
    end
    --Music.soundTablePointer = 1
    return retVal
end

-- called every draw() cycle while we're loading. When done loading it should trigger a 
-- musicLoaded event once
--
-- tick will be called at least once after each startLoading call, and will only stop once
-- a musicLoaded event is triggered - with one exception: when the cut scene is skipped (eg 
-- left or right arrow in the level select screens) then tick is called only once.
function Music.tick()
    sounds:cache()
    if Music.map and Table.size(Music.map) ~= Table.size(Music.tuneMap) then
        for k,v in pairs(Music.tuneMap) do
            if Music.map[k] == nil then
                --if k == "Easy" then Music.map[k] = Music.map["Tutorial"] return nil end
                --if k == "Hard" then Music.map[k] = Music.map["Medium"] return nil end
               -- if k == "Impossble" then Music.map[k] = Music.map["Crazy"] return nil end
                --print("loading "..k)
                Music.map[k] = ABCMusic(v,1)
               -- print("loading "..k)
                Music.loadProgress = Music.loadProgress + .3 / Table.size(Music.tuneMap)
                return nil
            end
        end
    end
    
    local doneCaching = true
    if not NO_MUSIC then 
        doneCaching = ABCMusic:preCachePlay()
        -- 30% of the time is spent parsing the tunes
        Music.loadProgress = .3 + ABCMusic:percentageCached()*.7
    end

    if  doneCaching and Music.isLoading then
        Events.trigger("musicLoaded")
        currentMusic = Music.map[Music.next]
        --print("music change",Music.next,currentMusic==nil)
        Music.isLoading = false
    end
end

function Music.switch(type)
    if Music.map then currentMusic = Music.map[type] end
    if currentMusic then currentMusic.soundTablePointer = 1 end
end

-- THESE ARE INTERNAL FUNCTIONS --
function Music.startScreen()
    Music.loadProgress = 0
    sampleMusic()
    if not Music.map then
        Music.map = {}
        Music.tuneMap = {}
        if not NO_MUSIC then
            Music.tuneMap = {
                Start = startTune,
                Win = winTune,
                Tutorial = tutorialTune,
                --Easy = tutorialTune
            }
        end
        Sounds:init()
        Music.next = "Start"
        return true
    end
    return false
end

function Music.packSelect()
    Music.next = "Start"
    return false
end

function Music.levelSelect(name) -- name is the name of the level pack
    Music.next = "Start"
    return false
end

function Music.level(name)
    Music.next = "Tutorial"
    return false
    
    --[[
    -- find which pack this level belongs to
    local pack = "Impossible"
    for _,p in ipairs(packs) do
        if Table.contains(p.levels,name) then
            pack = p.name
        end
    end
    
    local val = Music.isPackCached(pack)
    if not val then
        Music.loadProgress = 0
        currentMusic = nil 
    end
    Music.next = pack
    return not val
    --]]
end

function Music.winScreen(name) 
    ABCMusic:fade(0,1)
    local t = Tweener(1,nil,function() ABCMusic:fade(0.5,0.1) currentMusic = Music.map["Win"] currentMusic.soundTablePointer = 1 end)
    Tweener.add(t)
   -- Music.next = "Win"
    return false 
end

function Music.isPackCached(name)
    if Music.map[name] ~= nil then return true end
    
    local tune
    if name == "Tutorial" then tune = tutorialTune
   -- elseif name == "Easy" then tune = tutorialTune
    --elseif name == "Medium" then tune = mediumTune
   -- elseif name == "Hard" then tune = mediumTune
    --elseif name == "Crazy" then tune = crazyTune
    --elseif name == "Impossible" then tune = crazyTune
    else assert(false,"Invalid pack name: "..name) end
    
    Music.tuneMap[name] = tune
    return false
end
