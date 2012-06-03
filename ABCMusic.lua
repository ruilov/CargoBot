--ABCMusic class by Fred Bogg
-- v 0.4.2.2 beta
-- optimised cache size

ABCMusic = class()
      
function ABCMusic:init(_ABCTune,LOOP,DEBUG,DUMP)

    --watch("currentMusic.soundTablePointer")
    self.time = 0
    self.timerSeconds = 0
    self.code = "x=1"
    
    self.DEBUG = DEBUG
    if self.DEBUG == nil then self.DEBUG = false end
    if DUMP == nil then DUMP = false end
    if _ABCTune == nil then
        print("No tune provided. Use ABCMusic(tunename)")
    end    
    self.LOOP = LOOP
    
    nextT = 0
    cachingSpeed = 0 -- in seconds
    cachedIdx = 0
    
  
    noteNo = 1
    bufferTable = {}
    gnFrequency = 0
    gnMasterVolume = 0.5 -- this is the default setting, will be altered for fades
    gnFadeCountup = 0
    gnFadeSecondsTarget = 0
    gnMasterVolumeModifier = 0
    
    self.barAccidentals = ""
    y=0
    self.remainingTupletNotes =0
    
    self.soundTablePointer=1
    
    self.soundTable = {}
    
    self.timeElapsedSinceLastNote = 0

    self.duration = 1
    gnDurationSeconds = 0
    gnNoteVolume = 1
    --tempDuration = 1
    self.tempo = 240 -- if no tempo is specified in the file, use this
    self.noteLength = (1/8) -- if no default note length is specified in the file, use this
    
    -- This is the cycle of fifths.  It helps us figure out which accidentals to use
    -- for a given key.
    cycleOfFifths = {"Cb","Gb","Db","Ab","Eb","Bb","F",
    "C","G","D","A","E","B","F#","C#","G#","D#","A#"}
      
    -- This is the amount you need to multiply a note value by to get the next highest one.
    -- Don't ask me why it's not in hertz, it hurts.
    multiplier = 1.0296
    
     --1.0296 works for parameter tables, but the loss of precision using the encoded sound means this is out of tune.
    pitchTable = {1} -- This table will be filled with the note values
    pitch = pitchTable[1]
    self.semitoneModifier = 0
    
    gsNoteOrder = "CDEFGABcdefgab"
    gsTonalSystem = "22122212212221" -- compared with the noteOrder, this shows the no of 
                                  --  semitones between each note, like the black and white keys.
   
    -- There are 88 keys on a piano, so we will start from our highest note and go down.
    -- We calculate the notes ourselves and put them in a table. 
    for i = 88, 1, -1 do
        pitch = pitch / multiplier
        table.insert(pitchTable,1,pitch)
    end
    --print(table.concat(pitchTable,"\n"))
        
    -- These are the 'Guitar chords' and the notes making up each one.
    -- Further work needed to expand the range of chords known.
    chordList = {
    ["C"]={"C","E","G"},
    ["C7"]={"C","E","G","^A"},
    ["D"]={"D","^F","A"},
    ["D7"]={"D","^F","A","c"},
    ["Dm"]={"D","F","A"},
    ["Dm7"]={"D","F","A","c"},
    ["E"]={"E","^G","B"},
    ["Em"]={"E","G","B"},
    ["F"]={"F","A","c"},
    ["G"]={"G","B","D"},
    ["G7"]={"G","B","D","F"},
    ["A"]={"A","^C","E"},
    ["Am"]={"A","C","E"},
    ["Am7"]={"A","C","E","G"},
    ["Bb"]={"_B","D","F"},
    ["Bm"]={"B","D","^F"}}

    -- Print the raw ABC tune for debugging
    if DEBUG then print(_ABCtune) end
    
    -- This is a table of patterns that we use to match against the ABC tune.
    -- We use these to find the next, biggest meaningful bit of the tune.
    -- Lua patterns is like RegEx, in that we can specify parts of the match to be captured with
    -- sets of parentheses.
    -- Not all tokens have been implemented yet, but at least we understand
    -- musically what is going on.
    tokenList = {
        TOKEN_REFERENCE = "^X:%s?(.-)\n",
        TOKEN_TITLE = "^T:%s?(.-)\n",
        TOKEN_COMMENT = "%%.-\n",
        TOKEN_KEY = "%[?K:%s?(%a[b#]?)%s?(%a*)[%]\n]", -- matches optional inline [K:...]
        TOKEN_METRE = "%[?M:%s?(.-)[%]\n]",
        TOKEN_DEFAULT_NOTE_LENGTH = "%[?L:%s?(%d-)%/(%d-)[%]\n]",
        TOKEN_TEMPO = "%[?Q:%s?(%d*%/?%d*)%s?=?%s?(%d*)[%]\n]", -- matches deprecated, see standard
        TOKEN_CHORD_DURATION = '%[([%^_=]?[a-gA-G][,\']?[,\']?[,\']?%d*/?%d?.-)%]',
        TOKEN_GUITAR_CHORD = '"(%a+%d?)"',
       --[[ TOKEN_START_REPEAT = '|:',
        TOKEN_END_REPEAT = ':|',
        TOKEN_END_REPEAT_START = ":|?:",
        TOKEN_NUMBERED_REPEAT_START = "[|%[]%d",
        --]]
        TOKEN_NOTE_DURATION = '([%^_=]?[a-gA-GzZ][,\']?[,\']?[,\']?)(%d*%.?%d?/?%d?)',
      --[[  TOKEN_PREV_DOTTED_NEXT_HALVED = ">",
        TOKEN_PREV_HALVED_NEXT_DOTTED = "<",
        TOKEN_SPACE = "%s",--]]
        TOKEN_BARLINE = "|",
      --[[  TOKEN_DOUBLE_BARLINE = "||",
        TOKEN_THIN_THICK_BARLINE = "|%]",
        TOKEN_NEWLINE = "\n",
        --TOKEN_DOUBLE_FLAT = "__",
        --TOKEN_DOUBLE_SHARP = "%^^", --]]
        TOKEN_ACCIDENTAL = "([_=\^])",
        --[[TOKEN_REST_DURATION = "(z)(%d?/?%d?)",
        TOKEN_REST_MULTIMEASURE = "(Z)(%d?)",
        TOKEN_TRILL = "~",
        TOKEN_START_SLUR = "%(",
        TOKEN_END_SLUR = "%)",
        TOKEN_STACATO = "%.",--]]
     --   TOKEN_TUPLET = "%(([1-9])([%^_=]?[a-gA-G][,']?[,\']?[,\']?[%^_=]?[a-gA-G]?[,']?[,\']?[,\']?[%^_=]?[a-gA-G]?[,']?[,\']?[,\']?)",
        TOKEN_TUPLET_INDICATOR = "%([1-9]:?([1-9]?):?([1-9]?)",
        TOKEN_TIE = "([%^_=]?[a-gA-G][,\']?[,\']?[,\']?)%d?/?%d?%-^[%]]-(%1%d?/?%d?%-?)", -- greedy?
        TOKEN_DYNAMIC = "!([pmf]-)!",
        TOKEN_MISC_FIELD = "^[(ABCDEFGHIJNOPRSUVWYZmrsw)]:([^|]-)\n"} -- no overlap with 
                                                -- already specified fields like METRE or KEY
                                                
    self:parseTune(_ABCTune)
    self:createSoundTable()
    self:preCache()
    
    if DUMP then
        dump(self.soundTable) -- for debugging
    end
end

function ABCMusic:convertStringFraction(s)
    if string.sub(s,1,1) == "/" then
            s = "1"..s               
    end
        if s == "1/" then
            s = "1/2"
        end
                        
    if string.find(s, "/") ~= nil then
          
        local numerator = tonumber(string.sub(s,1,string.find(s,"/")-1))
        local denominator = tonumber(string.sub(s,string.find(s,"/")+1))            
        s = numerator / denominator
    end
    return s
end

function ABCMusic:parseTune(destructableABCtune)
    
    self.destructableABCtune = destructableABCtune
    if self.DEBUG then  print(self.destructableABCtune.."\n") end
    
    -- Go through the tune looking for ties and replace them with a single note of longer duration
    local searchStartIndex
    
    -- find the first match beyond the key sig and index it
    local startTieIndex
    local endTieIndex 
    local tieCapture1
    local tieCapture2
    local originalTieDurationLength
    local endKeySigIndex 
    _, endKeySigIndex = string.find(self.destructableABCtune, tokenList["TOKEN_KEY"],searchStartIndex)
    
    searchStartIndex = endKeySigIndex 
    --
    repeat 
    startTieIndex, endTieIndex, tieCapture1, tieCapture2 = string.find(self.destructableABCtune, tokenList["TOKEN_NOTE_DURATION"].."-",searchStartIndex)
    
    -- determine if the start tie was in a chord or not
    local startedInTie
    local startChord, _ = string.find(self.destructableABCtune, "[",endTieIndex,true)
    local endChord, _ = string.find(self.destructableABCtune, "]",endTieIndex,true)
   -- print(endChord)
    --print(startChord)
    if (endChord == nil and startChord == nil) or endChord == nil then 
        startedInTie = false
    else
        if startChord == nil then
            startedInTie = true     
        else
            if endChord > startChord then
                startedInTie = false
            else
                startedInTie = true
            end     
        end
    end
     
    local originalEndTieIndex =  endTieIndex
    
    if tieCapture2 == nil or tieCapture2 == "" then
        originalTieDurationLength = 0
        tieCapture2 = 1
    else
        originalTieDurationLength = #tieCapture2
    end
    
    if startTieIndex ~= nil then
        if self.DEBUG then print("Tie start, end and 1 & 2: "..startTieIndex, endTieIndex, tieCapture1, tieCapture2) end
        -- find the next match
        local startNextTieIndex
        local endNextTieIndex
        local tieNextCapture1
        local tieNextCapture2
        local possHyphen
        
        local totalTieDuration = ABCMusic:convertStringFraction(tieCapture2)
        if totalTieDuration == "" then 
            totalTieDuration = 1 
        end
        
        while true do
            -- the end tie index will expand and contract depending on what the pattern match was.
            startNextTieIndex, endNextTieIndex, tieNextCapture1, tieNextCapture2, possHyphen =
             string.find(self.destructableABCtune, "("..tieCapture1..")(%d*/?%d?)([^,\'])",endTieIndex)
            
            if startNextTieIndex == nil then 
                if self.DEBUG then print("Unresolved tie at ".. endTieIndex) end
                break
            end
            
            if self.DEBUG then print("next start, end, 1 & 2 and ph: "..startNextTieIndex, endNextTieIndex, tieNextCapture1, tieNextCapture2, possHyphen) end
            
    
            if tieNextCapture2 == "" or tieNextCapture2 == nil then 
                tieNextDurationLength = 0
                tieNextCapture2 = "1"    
            else
                tieNextDurationLength = #tieNextCapture2
            end
            
           -- print("capture 2 ".. tieNextCapture2)
            totalTieDuration = totalTieDuration + ABCMusic:convertStringFraction(tieNextCapture2)
            
            -- if the next match also has a - (tie) then iterate again.  after the duartion
            -- delete the all but the orginal tie
            
           -- print(string.sub(self.destructableABCtune,endNextTieIndex+1,endNextTieIndex+1))
--local possHyphen = string.sub(self.destructableABCtune,endNextTieIndex+1,endNextTieIndex+1)
        
    if possHyphen ~= "-" then
                
                local firstPart = string.sub(self.destructableABCtune,1,startNextTieIndex-1)
                local secondPart = string.sub(self.destructableABCtune,endNextTieIndex)
                self.destructableABCtune = firstPart..secondPart
                --print("no more ties combining ".. firstPart.." with ".. secondPart)
                break
            else
                 -- we found a hyphen
                local firstPart = string.sub(self.destructableABCtune,1,startNextTieIndex-1)
                local secondPart = string.sub(self.destructableABCtune,endNextTieIndex+(1))
                --print("endnextTieIndex is "
 --       ..string.sub(self.destructableABCtune,endNextTieIndex,endNextTieIndex))
                self.destructableABCtune = firstPart..secondPart
                --print("another attached tie, combining ".. firstPart.." with ".. secondPart)
                
            end 
            endTieIndex = endNextTieIndex  
            --print(self.destructableABCtune)
        
        end
        
        if self.DEBUG then print("total tie duration "..totalTieDuration ) end
        --print("originalEndTieIndex is "
       -- ..string.sub(self.destructableABCtune,originalEndTieIndex,originalEndTieIndex))
    
        -- if the initial tie was in a chord, we need to add a rest with the original duration
        -- otherwise we won't move on from the chord in time.
        
            
        local firstPart = string.sub(self.destructableABCtune,1,originalEndTieIndex-(1+originalTieDurationLength))
        local secondPart =  string.sub(self.destructableABCtune,originalEndTieIndex+(1))
        local searchStartAddition
        
        if startedInTie == true then 
            local middleBit = totalTieDuration.."z".. tieCapture2
            self.destructableABCtune = firstPart.. middleBit .. secondPart
           -- print("started in tie, added "..middleBit)
            searchStartAddition = #middleBit
            
        else
            local createdChord = "["..tieCapture1..totalTieDuration .. "z"..tieCapture2.."]"
            self.destructableABCtune = string.sub(self.destructableABCtune,1,startTieIndex-1)
            .. createdChord .. secondPart
            searchStartAddition = #createdChord + 1
           -- string.sub(self.destructableABCtune,1,originalEndTieIndex)
         --   .. "["..tieCapture1..totalTieDuration.."]"..secondPart
          -- .. "z"..tieCapture2.."]"..secondPart)
           
           -- print("did not start in tie, added "..createdChord .. " and searching from " ..searchStartIndex)
        
        end
        
      --  print("originalTieDurationLength is "..originalTieDurationLength)
          
       --   print("finished ".. firstPart.." with ".. totalTieDuration.. " and "..secondPart)    
        -- inch forward to start the next search
        searchStartIndex = searchStartIndex + searchStartAddition
    end
    until originalEndTieIndex == nil
        
    if self.DEBUG then print(self.destructableABCtune) end
    ------
    -- Go through each token and find the first match in the tune.  Use the biggest lowest
    -- starting index and then discard the characters that matched.
    
    local lastLongest = 0
    self.parsedTune = {}
    
    -- We create a copy of the tune to whittle away at.
    --destructableABCtune = ABCtune
    local lastToken
    local lastTokenMatch
    local captureFinal1
    local captureFinal2
    
    -- Iterate through the tune until none left
    while true do
        
        -- Loop through all tokens to see which one matches the start of the whittled tune.
        for key, value in pairs(tokenList) do
            
            local token = value
            -- Find the start and end index of the token match, plus record what was in the 
            -- pattern capture parentheses.  I pulled out a max two captures for each match, which
            -- seemed adequate.
            local startIndex
            local endIndex
            local capture1
            local capture2
           
            
            startIndex, endIndex, capture1, capture2 = string.find(self.destructableABCtune, token)
            if startIndex == nil then startIndex = 0 end
            if endIndex == nil then endIndex = 0 end
            -- Get the actual match from the tune
            local tokenMatch = string.sub(self.destructableABCtune,startIndex, endIndex)
           -- if self.DEBUG and tokenMatch ~= "" then print(key.." token in first pass: ".. tokenMatch) end
        
            -- Take the one that matches the start of the whittled tune.
            if startIndex == 1 then
                
                -- In case there are two possible matches, then take the biggest one.    
                -- This shouldn't happen if the token patterns are right.
               if endIndex > lastLongest then
                 
                    lastLongest = endIndex
                    lastToken = key
                    lastTokenMatch = tokenMatch
                    captureFinal1 = capture1
                    captureFinal2 = capture2
                end
                
            end
        end
        
        if lastTokenMatch == "" then
            if self.DEBUG then 
                print("No match found for character ".. string.sub(self.destructableABCtune,1,1) )
                print("Remaining characters: ".. #self.destructableABCtune)
            end
            -- set the whittler to trim the strange character away
            lastLongest = 1
        else
            -- Build a table containing the parsed tune.
            -- Due to iterative delays in the print function needed for debugging, we will use
            -- a 4-strided list for quicker printing it later with table.concat().
            table.insert(self.parsedTune,lastToken)
            table.insert(self.parsedTune,lastTokenMatch)
            
            -- Where no captures occurred, we will just fill the table item with 1,
            -- which will be the default duration of a note that has no length modifier.
            if captureFinal1 == "" or captureFinal1 == nil then captureFinal1 = 1 end
            if captureFinal2 == "" or captureFinal2 == nil then captureFinal2 = 1 end
            
            table.insert(self.parsedTune,captureFinal1)
            table.insert(self.parsedTune,captureFinal2)
        end
        
        -- Whittle off the match
        self.destructableABCtune = string.sub(self.destructableABCtune, lastLongest + 1)
        
        -- Stop the loop once we have no tune left to parse
        if string.len(self.destructableABCtune) == 0 then
            break
        end
         
        -- Clear the variables       
        lastLongest = 0
        lastToken = ""
        lastTokenMatch = ""
    end
    
    -- For debugging purposes, print the whole parsed tune.
    if self.DEBUG then print(table.concat(self.parsedTune,"\n")) end
end

function ABCMusic:createSoundTable()
    -- Here we interpret the parsed tune into a table of notes to play and for how long.
    -- The upside of an intermediate process is that there will be no parsing delays to lag
    -- things if we are playing music in the middle of a game.  It is also easier to debug!
    -- On the other hand, ABC format allows for inline tempo or metre changes. To comply
    -- we would need to either switch duration to seconds rather than beats, or implement another
    -- parsing thing during playback...
    
    local duration
    local tempChord={}
    local parsedTunePointer = 1
    while true do
        
        if self.parsedTune[parsedTunePointer] == nil then break end
        
        -- Break out our 4-strided list into the token, what it actually matched, and the
        -- two captured values.
        token = self.parsedTune[parsedTunePointer]
        rawMatch = self.parsedTune[parsedTunePointer + 1]
        value1 = self.parsedTune[parsedTunePointer + 2]
        value2 = self.parsedTune[parsedTunePointer + 3]
    
        -- setting the key sig
        if token == "TOKEN_KEY" then
            
            if value2 == 1 then
                self.mode = "major"
            else
                self.mode = value2
            end
            
            -- search cycle for marching tonic.
            for i = 1, #cycleOfFifths do
           
                if cycleOfFifths[i] == value1 then
                    cycleOfFifthsIndex = i
                    break
                end
            
            end
            
            if self.DEBUG then print("index of key of cycle is "..cycleOfFifthsIndex) end
            if self.DEBUG then print("mode is "..self.mode) end
            
            self.accidentals = ""
            
            if cycleOfFifthsIndex~= nil then
                
                if self.mode == "minor" then 
                    cycleOfFifthsIndex = cycleOfFifthsIndex - 3 
                end
                    
                    if cycleOfFifthsIndex > 8 then -- if on the right hand side of circle
                        for x = 7, (cycleOfFifthsIndex - 2) do
                            self.accidentals = self.accidentals .. cycleOfFifths[x]
                        end 
                    end
                    -- if the key is C major or A minor, the centre of the cycle, 
                    -- no accidentals are needed.
                    if cycleOfFifthsIndex < 8 then -- if on the left hand side of circle
                        for x = 6, (cycleOfFifthsIndex - 1), -1 do
                            self.accidentals = self.accidentals .. cycleOfFifths[x]
                        end 
                    end
             
                if self.DEBUG then print("Looking for these sharps: " .. self.accidentals) end
            end
        end
    
        if token == "TOKEN_TEMPO" then
            if string.find(value1,"/") then
                self.tempo = tonumber(value2)
            else
                self.tempo = tonumber(value1)
                self.tempoIsSingleFigure = true -- This is deprecated in the ABC standard
            end
            if self.DEBUG then print("Tempo found at: " .. self.tempo) end 
          -- iparameter("ptempo", 40, 480, self.tempo)
        end
        
        if token == "TOKEN_DEFAULT_NOTE_LENGTH" then
            noteLength = value2
            -- Set the tempo, eg if you wanted one quarter note or crotchet per second
            -- you would set Q:60 and L:1/4
            if self.tempoIsSingleFigure == true then         
                self.tempo = self.tempo * (noteLength/4)
            end
            if self.DEBUG then print("internal Tempo is " .. self.tempo) end
        end
        
        if token == "TOKEN_DYNAMIC" then
            local dynamic = value1
            
            -- Changed from ABC standard suggested range from 0 to 127
            if dynamic == "pppp" then gnNoteVolume = 5/127 end
            if dynamic == "ppp" then gnNoteVolume = 20/127 end
            if dynamic == "pp" then gnNoteVolume = 35/127 end
            if dynamic == "p" then gnNoteVolume = 50/127 end
            if dynamic == "mp" then gnNoteVolume = 65/127 end
            if dynamic == "mf" then gnNoteVolume = 80/127 end
            if dynamic == "f" then gnNoteVolume = 95/127 end
            if dynamic == "ff" then gnNoteVolume = 110/127 end
            if dynamic == "fff" then gnNoteVolume = 125/127 end
            if dynamic == "ffff" then gnNoteVolume = 127/127 end
                
            if self.DEBUG then print("dynamic is " .. dynamic) end
        end
        
        if token == "TOKEN_BARLINE" then
            -- reset bar accidentals
            self.barAccidentals = ""
        end
    
        if token == "TOKEN_NOTE_DURATION" then
            if self.remainingTupletNotes > 0 then
                self.remainingTupletNotes = self.remainingTupletNotes - 1
            else
                self.tupletMultiplier = 1
            end
            
            duration = value2
            -- because the ABC standard allows /4 to mean 1/4, we fix that here
            if string.sub(duration,1,1) == "/" then
                duration = "1"..duration 
                
            end
            if duration == "1/" then
                duration = "1/2"
            end
                        
            if string.find(duration, "/") ~= nil then
                duration = ABCMusic:convertStringFraction(duration) 
            end

              -- Apply key signature and accidentals
            
                firstChar = string.upper(string.sub(value1,1,1))
                
                -- a plain note has arisen
                if firstChar ~= "^" and firstChar ~= "_" and firstChar ~= "=" then
                    -- see if it is an active accidental from this bar
                    local index, _ = string.find(self.barAccidentals,firstChar)
                    if index ~= nil then 
                        if self.DEBUG then print ("found bar accid") end
                        -- put the accidental on
                        value1 = string.sub(self.barAccidentals,index-1,index-1)..value1
                    else
                        -- see if it is one of the notes in the key signature
                        if string.find(self.accidentals,firstChar) ~= nil then 
                            if cycleOfFifthsIndex > 8 then
                                value1 = "^" .. value1
                            end
                            if cycleOfFifthsIndex < 8 then
                                value1 = "_" .. value1
                            end
                        end
                    end
                else
                    -- an accidental or natural has appeared. Remember it for the rest of the bar.
                    self.barAccidentals = self.barAccidentals .. string.upper(value1)
                    if self.DEBUG then print("adding bar acci ".. value1) end
                end
            
            if firstChar == "=" then
                value1 = string.sub(value1,2)  
            end
            
             -- If there are chords to play at the same time, they will be in the tempChord table.      
            if value1~="z" then
                table.insert(tempChord,{ABCMusic:convertNoteToPitch(value1), ABCMusic:convertDurationToSeconds(duration,self.tempo)* self.tupletMultiplier,gnNoteVolume})
            else
                table.insert(tempChord,{"z", ABCMusic:convertDurationToSeconds(duration* self.tupletMultiplier,self.tempo),0})
            end
            table.insert(self.soundTable,tempChord)
            tempChord = {}
        end 
        
        if token == "TOKEN_REST_DURATION" then
            duration = value2
            if string.sub(duration,1,1) == "/" then
                duration = "1"..duration 
            end
            
            if string.find(duration, "/") ~= nil then
                duration = ABCMusic:convertStringFraction(duration)
            end
            
            duration = tonumber(duration)
    table.insert(self.soundTable,{{"z", ABCMusic:convertDurationToSeconds(duration,self.tempo),gnNoteVolume}})
        end 
        
        if token == "TOKEN_TIE" then
            value1, duration1 = string.match(value1,tokenList["TOKEN_NOTE_DURATION"])
            value2, duration2 = string.match(value2,tokenList["TOKEN_NOTE_DURATION"])
            
           if self.DEBUG then print("val1 " .. value1.. " value2 ".. value2) end
            
            if string.sub(duration1,1,1) == "/" then
                duration1 = "1"..duration1 
             
            end
       
            if string.find(duration1, "/") ~= nil then
                duration1 = ABCMusic:convertStringFraction(duration1)
            end
            
            if string.sub(duration2,1,1) == "/" then
                duration2 = "1"..duration2 
           
            end
     
            if string.find(duration2, "/") ~= nil then
                duration2 = ABCMusic:convertStringFraction(duration2)
            end

            if duration1 == nil or duration1 == "" then duration1 = 1 end
            if duration2 == nil or duration2 == "" then duration2 = 1 end
            
            if self.DEBUG then print("dur1 ".. duration1 .. "dur2 ".. duration2) end

            duration = tonumber(duration1) + tonumber(duration2)
            table.insert(self.soundTable,{{ABCMusic:convertNoteToPitch(value1), ABCMusic:convertDurationToSeconds(duration,self.tempo),gnNoteVolume}})
        end
        
        if token == "TOKEN_METRE" then
            self.metre = value1
        end
        
        if token == "TOKEN_TUPLET_INDICATOR" then
            if self.DEBUG then print("tuplet was "..rawMatch) end
            self.p = tonumber(string.sub(rawMatch,2,2))
            if value1 == 1 then
                if self.p == 3 then self.p = 2 end
                if self.p == 2 then self.p = 3 end
                if self.p == 4 then self.p = 3 end
                if self.p == 5 or self.p == 7 or self.p == 9 then 
                    if string.sub(self.metre,-1,-1) == 8 then
                        self.p = 3
                    else 
                        self.p = 2
                    end 
                end
                if self.p == 6 then self.p = 2 end
                if self.p == 8 then self.p = 3 end
            else 
                self.q = value1
            end
            
            if value2 == 1 then
                self.remainingTupletNotes = self.p
            else
                self.remainingTupletNotes = tonumber(value2)
            end
            
            -- 'put p notes into the time of q for the next r notes'. ABC Standard.
            -- If q is not given, it defaults as above. If r is not given, it defaults to p.
            self.tupletMultiplier = self.q/self.p
            if self.DEBUG then print("p "..self.p .." q ".. self.q .." r ".. self.remainingTupletNotes) end
            
            
        end
        
        if token == "TOKEN_GUITAR_CHORD" then
            -- The ABC standard leaves it up to the software how to interpret guitar chords,
            -- but they should precede notes in the ABC tune.  I'm just going with a vamp.
            duration = 1
            self.tempChord = {}
            if chordList[value1] == nil then
               print("Chord ".. value1.. " not found in chord table.")
            else
                for key, value in pairs(chordList[value1]) do
                    -- This places the notes of the chord into a temporary table which will
                    -- be appended to by the next non-chord note.
                    table.insert(self.tempChord,{ABCMusic:convertNoteToPitch(value1), ABCMusic:convertDurationToSeconds(duration, self.tempo),gnNoteVolume})
                end        
            end         
        end
        
        if token == "TOKEN_CHORD_DURATION" then
            -- These are arbitrary notes sounded simultaneously. 
            if self.remainingTupletNotes > 0 then
                self.remainingTupletNotes = self.remainingTupletNotes - 1
            else
                self.tupletMultiplier = 1
            end
            
            while true do
                -- Do this loop unless we have already whittled away the chord into notes.
                if string.len(rawMatch) <= 1 then
                    break
                end
   
                -- Reprocess the chord into notes and durations.
                startIndex, endIndex, note, noteDuration =
                    string.find(rawMatch,tokenList["TOKEN_NOTE_DURATION"])
            
                if noteDuration == "" or noteDuration == nil then 
                    noteDuration = 1 
                else
                     noteDuration = ABCMusic:convertStringFraction(noteDuration)
                end
                
                if note == nil then break end
                
                -- hack for key signature
                --print("note is ".. note)
                firstChar = string.upper(string.sub(note,1,1))
                if firstChar ~= "^" and firstChar ~= "_" then
                    if string.find(self.accidentals,firstChar) ~= nil then 
                        if cycleOfFifthsIndex > 8 then
                            note = "^" .. note
                            --print("added sharp to "..note)
                        end
                        if cycleOfFifthsIndex < 8 then
                            note = "_" .. note
                           -- print("added flat to "..note)
                        end
                    
                    end
                end
                
                if firstChar == "=" then
                    note = string.sub(note,2)
                end
                
                -- This places the notes of the chord into a temporary table which will
                -- be appended to the sound table at the end of the chord.
                
                if note ~= "z" then
                    table.insert(tempChord,{ABCMusic:convertNoteToPitch(note), ABCMusic:convertDurationToSeconds(noteDuration, self.tempo)*self.tupletMultiplier,gnNoteVolume})
                else
                    table.insert(tempChord,{"z", ABCMusic:convertDurationToSeconds(noteDuration, self.tempo)*self.tupletMultiplier,0})
                end
                -- Whittle away the chord
                rawMatch = string.sub(rawMatch, endIndex + 1) 
            end
            
            
            -- Append chord to sound table.
            table.insert(self.soundTable,tempChord)
            tempChord = {}
        end       
        -- Move to the next token in our strided list of 4.
        parsedTunePointer = parsedTunePointer + 4
    end
    
   -- print(self.dataName)
    --saveProjectData(self.dataName, self.soundTable)
end

function ABCMusic:fromTheTop()
   self.soundTablePointer = 1
end

function ABCMusic:fade(targetVolume, seconds)
    -- targetVolume is a value from 0 to 1, over duration seconds, giving a linear fade
    if gnMasterVolume == nil then gnMasterVolume = 0.5 end
    gnFadeSecondsTarget = seconds
    gnFadeCountup = 0
    gnFadeAmount = targetVolume - gnMasterVolume 

  --  print("Fading over " .. gnFadeSecondsTarget)
  --  print("len music.next is "..#Music.next)

end

function ABCMusic:play()
    -- Step through the parsed tune and decide whether to play the next bit yet.
   ABCMusic:timer(0,"x=2")
    -- This normalises the tempo to smooth out lag between cumlative frames.  Meant to be the
    -- same idea for smoothing out animation under variable processing loads.
    self.timeElapsedSinceLastNote = self.timeElapsedSinceLastNote + DeltaTime
    
    -- If there is still a tune and it's time for the next set of notes
    if gnDurationSeconds <= self.timeElapsedSinceLastNote 
        and self.soundTablePointer <= #self.soundTable then
        
        -- Step through the set of notes nested in the sound table, finding each note and
        -- its duration.  If we had volume, we would also want to record it in the most nested
        -- table.
        -- The operator # gives us the number of elements in a table until a blank one - see Lua 
        -- documentation.
        -- Luckily our table will never have holes in it, or the notes would fall through.
        -- The sound table looks like:
        -- 1:    1:    1:    44 -- 44th key of piano is A 440 hz
        --             2:    0.5            -- seconds duration
        --       2:    1:    46 -- 46th key is B
        --             2:    0.75
        -- 2: etc...
        
        oldTempDuration=0
        tempDuration = 0
        
        if gnFadeCountup < gnFadeSecondsTarget then
            
            gnFadeCountup = gnFadeCountup + self.timeElapsedSinceLastNote
            gnMasterVolumeModifier = ((gnFadeCountup/gnFadeSecondsTarget) * gnFadeAmount)

            if (gnMasterVolume + gnMasterVolumeModifier) < 0 or (gnMasterVolume + gnMasterVolumeModifier) > 1
            then gnMasterVolumeModifier = gnFadeAmount 
            end
        end
        --if gnMasterVolumeModifier == gnFadeAmount then print("fade done") end
        
        for i = 1, #self.soundTable[self.soundTablePointer] do 
            oldTempDuration = tempDuration
            -- This bit plays the note currently being pointed to.  If it is part of a set
            -- to be played at once, this will loop around without delay.
            
           gnPitchBeingPlayed = self.soundTable[self.soundTablePointer][i][1]
        
            gnDurationSeconds = ( tonumber(self.soundTable[self.soundTablePointer][i][2]))
            
            tempDuration = gnDurationSeconds
            
            gnNoteVolume = ( tonumber(self.soundTable[self.soundTablePointer][i][3]))
            -- we will multiply this by gnMasterVolume in the sound() call
            
            if gnPitchBeingPlayed ~= "z" then 
                -- look up based on key of noteNo and the length of note
                local soundTable = {Waveform = 2, StartFrequency = gnPitchBeingPlayed, SustainTime = 0.6*(math.sqrt(gnDurationSeconds))}
                    
                sound(DATA, sound( ENCODE, soundTable ),gnNoteVolume*(gnMasterVolume+gnMasterVolumeModifier))
            
            end
                       
            if self.DEBUG then 
                y = y + 20
                if y > HEIGHT then y=0 end
                background(0, 0, 0, 255)
                text(gnPitchBeingPlayed .." " ..gnDurationSeconds, WIDTH/2, HEIGHT - y)
            end
            
            self.semitoneModifier = 0
            
            -- Keep the shortest note duration of the set of notes to be played together,
            -- to be used as one of the inputs for the delay until the next note.  
           if oldTempDuration ~= 0 and oldTempDuration < tempDuration then
              -- print("overtook " .. tempDuration)
                tempDuration = oldTempDuration
            
            end
        end
      -- print("shortest was " .. tempDuration)
        gnDurationSeconds = tempDuration
    
        if self.LOOP ~= nil and self.soundTablePointer == #self.soundTable then 
            self.soundTablePointer = 1
        else
            -- Increment the pointer in our sound table.
            self.soundTablePointer = self.soundTablePointer + 1
        end
        
        -- Reset counters rather than going to infinity and beyond.
        self.timeElapsedSinceLastNote = 0
    end
    
end

function ABCMusic:noteBeingPlayed()
    return gsNoteBeingPlayed
end

function ABCMusic:convertNoteToPitch(n)
    self.semitoneModifier = 0
                gsNoteBeingPlayed = n
            for j = 1, #gsNoteBeingPlayed do
                local currentChar = string.sub(gsNoteBeingPlayed,j,j)
                
                if currentChar == "_" then 
                    self.semitoneModifier = self.semitoneModifier - 1
                end
                
                if currentChar == "\^" then 
                    self.semitoneModifier = self.semitoneModifier + 1
                    currentChar = "%^"
                end
                -- NB need to implement naturals =
                
                
                -- if the current char is a note
                if string.find("abcdefg",string.lower(currentChar)) ~= nil then
                    
                    -- modify octave
                    -- search through the next characters for , and '
                    local nextCharIndex = 1
                    local nextChar = string.sub(gsNoteBeingPlayed,j+nextCharIndex,j+nextCharIndex)
                    if nextChar == "," then 
                        self.semitoneModifier = self.semitoneModifier - 12
                    end
                    if nextChar == "'" then 
                        self.semitoneModifier = self.semitoneModifier + 12
                    end
                    
                    pos = string.find(gsNoteOrder,currentChar)
                    local tonalModifier = string.sub(gsTonalSystem, 1, pos - 1)
                    
                    for i = 1, #tonalModifier do
        self.semitoneModifier = self.semitoneModifier + tonumber(string.sub(tonalModifier,i,i))
                    end
                    
                end
                            
            end
            
            pos = self.semitoneModifier + 44
        
            pitch = pitchTable[pos]
            
    return pitch
end

function ABCMusic:convertDurationToSeconds(d,t)
    tempDuration = d
    soundDuration = (tempDuration/2)*(60/t)
    return soundDuration
end

function ABCMusic:adjustSoundBufferSize()
    
    local sb
    local used
    
    sb,used =  soundBufferSize()
    --print(sb,used)
    
    -- extend the cache if getting full
    if used > (sb * 0.9) then
        soundBufferSize(sb + (sb * 0.1))
    end
    
end

-- A user function to see if an element exists in a table    
function table.contains(table, element)
    for _, value in pairs(table) do
        if value[1] == element[1] and value[2] == element[2] then
            return true
        end
    end
    
    return false
end
    
function ABCMusic:preCache()
    -- this function create the soundbuffer for all the unique sounds.
    -- better this delay comes all at once at the beginning than during the performance.
    -- cover it with a loading screen.

    if gPreCacheSoundTable == nil then 
        gPreCacheSoundTable = {}
    end
    -- If the table already exists it means this is another round of loading, so we
    -- have already played the sounds in the table.  To save us from playing them again, 
    -- we match any sounds and don't add them.  Then we delete the earlier sounds.
    local originalTableLength = #gPreCacheSoundTable
  --  print("orig tab length ".. originalTableLength)
    -- flatten sound table
    for i=1,#self.soundTable do
        for j=1, #self.soundTable[i] do
            local data = {self.soundTable[i][j][1], self.soundTable[i][j][2]} 
             -- if not already in there 
           
                
                if table.contains(gPreCacheSoundTable, data) == false and data[1] ~="z" then
                    table.insert(gPreCacheSoundTable, data)
                    --print("added unique sound "..data[1].." "..data[2])
                else
                   -- print("skipped dupe sound"..data[1].." "..data[2])
                end
           -- end
        end
    end

end

function ABCMusic:preCachePlay()
    -- play it all! this runs in main:draw() and should trigger whenever new sounds are added
    
    -- if we're done caching then do nothing
    if cachedIdx == nil then return true end
    if cachedIdx >= #gPreCacheSoundTable then return true end
    
    -- is it time to cache a new sound?
    if ElapsedTime > nextT then
        cachedIdx = cachedIdx + 1
        --print("caching",self.cachedIdx)
        ABCMusic:adjustSoundBufferSize()
        
        nextT = nextT + cachingSpeed

        gnPitchBeingPlayed = gPreCacheSoundTable[cachedIdx][1]
        gnDurationSeconds = ( tonumber(gPreCacheSoundTable[cachedIdx][2]))
        gnNoteVolume = 0 -- silent, otherwise: cacophony!    
                
            local soundTable = {Waveform = 2, StartFrequency = gnPitchBeingPlayed, SustainTime = 0.6*(math.sqrt(gnDurationSeconds))}
                
            ABCMusic:adjustSoundBufferSize()
            sound(DATA, sound( ENCODE, soundTable ),gnNoteVolume)
     
     end      
    
   if self.DEBUG then 
        print(soundBufferSize())
        print("that was " .. gnPitchBeingPlayed.." "..gnDurationSeconds)
     end
    
end

function ABCMusic:timer(seconds, code)
    
        if seconds == 0 then
            
          if self.timerSeconds ~= nil then  
            -- being called as part of draw(), check the time
            if self.time > self.timerSeconds and self.timerSeconds > 0 then
                -- execute code as timer is up
                loadstring(self.code)()
                self.time = 0
                self.timerSeconds = 0
                print("executed :", self.code)
            end
           end
            
        else
            -- got some code, start the timer
            self.code = code
            self.timerSeconds = seconds
            self.time = 0
            
            print("got code: ", self.code)
        end
        
        if self.timerSeconds ~= nil then  
            self.time = self.time + DeltaTime
        end
end

-- Handy function from Pixel to only use for debugging and if the ABCtube is a line long,
-- 'cos it is slow.
-- print contents of a table, with keys sorted. 
-- second parameter is optional, used for indenting subtables

function dump(t,indent)
    local names = {}
    if not indent then indent = "" end
    for n,g in pairs(t) do
        table.insert(names,n)
    end
    table.sort(names)
    for i,n in pairs(names) do
        local v = t[n]
        if type(v) == "table" then
            if(v==t) then -- prevent endless loop if table contains reference to itself
                print(indent..tostring(n)..": <-")
            else
                print(indent..tostring(n)..":")
                dump(v,indent.."   ")
            end
        else
            if type(v) == "function" then
                print(indent..tostring(n).."()")
            else
                print(indent..tostring(n)..": "..tostring(v))
            end
        end
    end
end
