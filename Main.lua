-- Main.lua
supportedOrientations(PORTRAIT_ANY)
DEV_MODE = false
NO_MUSIC = false

function setup()
    --IO.clearAll()
    --IO.printSolution("Mirror 3")
    displayMode(FULLSCREEN)
    if not DEV_MODE then displayMode(FULLSCREEN_NO_BUTTONS) end
    watch("dt")
    elapsedTimes = {}
    
    sounds = Sounds()
    checkLevelOrder()
end

function draw()
    dt = DeltaTime*100
    -- estimate DeltaTime based on last few observations to pass to sound library
    table.insert(elapsedTimes,ElapsedTime)
    while #elapsedTimes > 50 do table.remove(elapsedTimes,1) end
    MY_DELTA_TIME = (elapsedTimes[#elapsedTimes] - elapsedTimes[1]) / (#elapsedTimes - 1)
    
    background()
    
    if not currentScreen then
        currentScreen = SplashScreen()
        --currentScreen = Level(levels[38])
        --currentScreen:addTutorial()
        currentScreen:bind()
        transitionScreen = TransitionScreen() -- global variable
    end
    
    currentScreen:draw()
    currentScreen:tick()
    Tweener.run()
    --ShakeDetector.check() -- do we want to keep this?

    if currentMusic then currentMusic:play() end
end

function touched(t)
    if currentScreen and currentScreen.touched then currentScreen:touched(t) end
end

function collide(contact)
    if currentScreen and currentScreen.collide then currentScreen:collide(contact) end
end

function printout(msg,x,y)
    fill(255,255,255,255)
    fontSize(40)
    textMode(CORNER)
    text(msg,x,y)
end

function checkLevelOrder()
    for p = 1,6 do
        local pack = packs[p]
        for i = 1,6 do
            local level = levels[(p-1)*6+i]
            local n1 = level.name
            local n2 = pack.levels[i]
            assert(n1==n2,"level order is wrong "..p.." "..i..
                "\n-"..n1.."-\n-"..n2.."-")
        end
    end
end
