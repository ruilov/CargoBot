-- IO.lua
-- Handles saving the solution data and scores

IO = class()

function IO.clearAll()
    clearLocalData()
end

function IO.printAllSolutions()
    for _,data in ipairs(levels) do
        IO.printSolution(data.name)
    end
end

function IO.printSolution(name)
    local sol = IO.readSolution(name)
    if sol then
        print(name)
        print(sol)
    end
end
    
-- where we store the user solutions
function IO.solutionName(levelName)
    return "level"..levelName.."solution"
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
    return "level"..levelName.."topScore"
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
