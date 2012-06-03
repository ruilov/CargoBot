-- IO.lua
-- Handles saving the solution data and scores

IO = class()

-- init loads the user array to know who the default user is for figuring out
-- solution file names
function IO.init()
    -- the file names for the default user don't append the username to their name
    DEFAULT_USER = "Player 1"
    CURRENT_USER = IO.loadCurrentUser()
end

function IO.clearAll()
    clearLocalData()
end

function IO.printAllSolutions()
    for _,data in ipairs(levels) do
        IO.printSolution(data.name)
    end
end

-- prints the solution for level = namae
function IO.printSolution(name)
    local sol = IO.readSolution(name)
    if sol then
        print(name)
        print(sol)
    end
end
    
-- where we store the user solutions
function IO.solutionName(levelName)
    if CURRENT_USER == DEFAULT_USER then 
        return "level"..levelName.."solution"
    else 
        return CURRENT_USER.."level"..levelName.."solution"
    end    
end

function IO.saveSolution(levelName,solutionStr)
    local filename = IO.solutionName(levelName)
    saveLocalData(filename,solutionStr)
end

function IO.readSolution(levelName)
    local solution = readLocalData(IO.solutionName(levelName))
    return solution
end

-- where we store the max number of stars earned for this level
function IO.topScoreFilename(levelName)
    if CURRENT_USER == DEFAULT_USER then 
        return "level"..levelName.."topScore"
    else 
        return CURRENT_USER.."level"..levelName.."topScore"
    end
end

-- loads the maximum number of stars that we've earned for this level
function IO.levelTopScore(levelName)
    local numStars = 0
    local score = readLocalData(IO.topScoreFilename(levelName))
    if score then numStars = score end
    return numStars
end

-- saves the maximum number of stars that we've earned for this level
function IO.saveScore(score,levelName)
    score = math.min(score,4)
    local top = IO.levelTopScore(levelName)
    if score > top then
        local filename = IO.topScoreFilename(levelName)
        saveLocalData(filename,score)
    end
end

-- total score for this level pack
function IO.packScore(packName)
    local score = 0
    for _,pack in ipairs(packs) do
        if pack.name == packName then
            for i,level in ipairs(pack.levels) do
                score = score + math.min(IO.levelTopScore(level),3)
            end
        end
    end
    return score
end

-- calculates the total maximum number of stars across all levels
function IO.totalScore()
    local score = 0
    for _,levelData in ipairs(levels) do
        score = score + math.min(IO.levelTopScore(levelData.name),3)
    end
    return score
end

-- functions to deal with the music setting
function IO.storeMusicState(onOff)  -- on is true, off is false
    saveLocalData("musicSetting",onOff)
end

function IO.readMusicState()
    return readLocalData("musicSetting")
end

-- functions to deal with profiles
function IO.loadProfileName(profileIndex)
    local name = readLocalData("profileName"..profileIndex)
    if name == nil then name = "Player " .. profileIndex end
    return name
end

function IO.saveProfileName(profileIndex,profileName)
    saveLocalData("profileName"..profileIndex,profileName)
end

function IO.loadCurrentUser()
    local currentUser = readLocalData("currentUser")
    if currentUser == nil then
        currentUser = DEFAULT_USER
        saveLocalData("currentUser",currentUser)
    end
    return currentUser
end

function IO.saveCurrentUser(profileIndex)
    CURRENT_USER = "Player "..profileIndex
    saveLocalData("currentUser", CURRENT_USER)
end
