-- Levels.lua

-- Level are organized in packs, each pack consists of 6 levels.
-- - Level definitions include;
-- - name: shows in the level chooser screen as well at at the top of the level. Also used to
--     save solutions and score
-- - claw: the starting position of the claw (the pile number where it starts)
-- - stars: an array of two elems. The first is the max number of instructions allowed for 2
--     starts and the second, the max number of instructions allowed for 3 stars
-- - funcs: specifies the number of progs and the lenght of progs allowed in that level
-- - toolbox: specifies the tools available in that level
-- - stage/goal: specifies which crates are in which piles. By convention the first crate in each
--     pile is the lowest crate in that pile
-- - hint: the hint string

packs = {
    {
        name = "Tutorial",
        levels = {"Cargo 101","Transporter","Re-Curses","Inverter","From Beneath","Go Left"}
    },
    {
        name = "Easy",
        levels = {"Double Flip","Go Left 2","Shuffle Sort","Go the Distance","Color Sort","Walking Piles"}
    },
    {
        name = "Medium",
        levels = {"Repeat Inverter","Double Sort","Mirror","Lay it out","The Stacker","Clarity"}
    },
    {
        name = "Hard",
        levels = {"Come Together","Come Together 2","Up The Greens","Fill The Blanks","Count The Blues","Multi Sort"}
    },
    {
        name = "Crazy",
        levels = {"Divide by two","The Merger","Even the Odds",
            "Genetic Code","Multi Sort 2","The Swap"}
    },
    {
        name = "Impossible",
        levels = {"Restoring Order","Changing  Places",
            "Palette Swap","Mirror 2","Changing Places 2",
            "Vertical Sort"}
    }
}

levels = {
    {
        name = "Cargo 101",
        claw = 1,
        stars = {3,3,3},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4"},
        stage = {{"yellow"},{}},
        goal = {{},{"yellow"}},
        hint = "Down, Right, Down",
    },
    
    {
        name = "Transporter",
        claw = 1,
        stars = {5,5,4},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4"},
        stage = {{"yellow"},{},{},{}},
        goal = {{},{},{},{"yellow"}},
        hint = "Reuse the solution from level 1 and loop through it.\n\nThe shortest solution uses 4 registers."
    },
    
    {
        name = "Re-Curses",
        claw = 1,
        stars = {10,5,5},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4"},
        stage = {{"yellow","yellow","yellow","yellow"},{}},
        goal = {{},{"yellow","yellow","yellow","yellow"}},
        hint = "Move one crate to the right, go back to the original position, and then loop.\n\nThe shortest solution uses 5 registers."
    },
    
    {
        name = "Inverter",
        claw = 1,
        stars = {15,10,10},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4"},
        stage = {{"blue","red","green","yellow"},{},{},{},{},{}},
        goal = {{},{},{},{},{},{"yellow","green","red","blue"}},
        hint = "Move all four blocks one spot to the right, and repeat.\n\nThe shortest solution uses 10 registers.",
    },

    {
        name = "From Beneath",
        claw = 1,
        stars = {8,6,5},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","blue","yellow","none","multi"},
        stage = {{"yellow","blue","blue","blue","blue"},{},{}},
        goal = {{},{"blue","blue","blue","blue"},{"yellow"}},
        hint = "Go right once if holding blue, twice if holding yellow, and left if holding none. Repeat.\n\nThe shortest solution uses 5 registers.",
    },
    
    {
        name = "Go Left",
        claw = 1,
        stars = {15,9,9},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4"},
        stage = {{},{"red","red","red"},{"green","green","green"},{"blue","blue","blue"}},
        goal = {{"red","red","red"},{"green","green","green"},{"blue","blue","blue"},{}},
        hint = "Move each pile to the left. Repeat.\n\nThe shortest solution uses 9 registers.",
    },
    
    {
        name = "Double Flip",
        claw = 1,
        stars = {12,6,5},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","blue","red","green","yellow",
            "none","multi"},
        stage = {{"blue","red","green","yellow"},{},{}},
        goal = {{},{},{"blue","red","green","yellow"}},
        hint = "Go right once if holding any, twice if holding blue, and left if holding none. Repeat.\n\nThe shortest solution uses 5 registers.",
    },
    
    {
        name = "Go Left 2",
        claw = 1,
        stars = {8,6,4},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","blue","red","green",
            "none","multi"},
        stage = {{},{"red","red","red"},{"blue","blue","blue"},{"green","green","green"}},
        goal = {{"red","red","red"},{"blue","blue","blue"},{"green","green","green"},{}},
        hint = "Go right if holding none, and left if holding any. Repeat.\n\nThe shortest solution uses 4 registers.",
    },

    {
        name = "Shuffle Sort",
        claw = 2,
        stars = {15,10,9},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4"},
        stage = {{},{"blue","yellow","blue","yellow","blue","yellow"},{}},
        goal = {{"blue","blue","blue"},{},{"yellow","yellow","yellow"}},
        hint = "Alternate left and right, and make sure to use F2 to shorten your solution.\n\nThe shortest solution uses 9 registers.",
    },
    
    {
        name = "Go the Distance",
        claw = 1,
        stars = {12,6,4},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","red","yellow","none","multi"},
        stage = {{"yellow"},{"yellow"},{"yellow"},{"yellow"},{"yellow"},{"yellow"},{},
            {"red","red","red","red"}},
        goal = {{"yellow"},{"yellow"},{"yellow"},{"yellow"},{"yellow"},{"yellow"},
            {"red","red","red","red"},{}},
        hint = "Go right if holding none, and left if holding red. Repeat.\n\nThe shortest solution uses 4 registers.",
    },
    
    {
        name = "Color Sort",
        claw = 2,
        stars = {14,10,8},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","red","green","none","multi"},
        stage = {{},{"green","green","red","green","red","red"},{}},
        goal = {{"red","red","red"},{},{"green","green","green"}},
        hint = "Go over each of the 3 piles and drop or pick up based on the color. When over the left pile drop if red, when over the right pile drop if green.\n\nThe shortest known solution uses 8 registers, all in F1.",
    },
    
    {
        name = "Walking Piles",
        claw = 1,
        stars = {13,11,9},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","blue","none"},
        stage = {{"blue","blue","blue","blue"},{"blue","blue","blue","blue"},
            {"blue","blue","blue","blue"},{},{},{},{}},
        goal = {{},{},{},{},{"blue","blue","blue","blue"},{"blue","blue","blue","blue"},
            {"blue","blue","blue","blue"}},
        hint = "For a 3 star solution, move each pile 3 slots to the right, and then repeat. This method can be implemented with 10 registers.\n\nThe shortest known solution uses 9 registers (with an approach that is very specific to this configuration)"
    },
    
    {
        name = "Repeat Inverter",
        claw = 1,
        stars = {9,7,5},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","blue","red","green","yellow",
            "none","multi"},
        stage = {{"yellow","red","green","blue"},{},{"yellow","red","green","blue"},{},
            {"yellow","red","green","blue"},{}},
        goal = {{},{"blue","green","red","yellow"},{},{"blue","green","red","yellow"},{},
            {"blue","green","red","yellow"}},
        hint = "It can be done with the usual 5 instructions and clever usage of conditional modifiers. Solutions with up to 7 instructions earn 3 stars.",
    },
    
    {
        name = "Double Sort",
        claw = 2,
        stars = {20,14,11},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","blue","yellow","none","multi"},
        stage = {{},{"blue","blue","yellow","yellow"},{"yellow","blue","yellow","blue"},{}},
        goal = {{"blue","blue","blue","blue"},{},{},{"yellow","yellow","yellow","yellow"}},
        hint = "Sort, go right, sort, go left. Repeat. Use at most 14 instructions for 3 stars.\n\nThe shortest known solution uses 11 registers.",
    },
    
    {
        name = "Mirror",
        claw = 1,
        stars = {9,7,6},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","green","yellow","none","multi"},
        stage = {{"yellow","yellow","yellow","yellow"},{"green","green"},{"green"},{"green"},
            {"green","green"},{}},
        goal = {{},{"green","green"},{"green"},{"green"},{"green","green"},
            {"yellow","yellow","yellow","yellow"}},
        hint = "Use at most 7 registers for 3 stars. There are various known solutions with 6 registers in F1, but no known solution with only 5.",
    },
    
    {
        name = "Lay it out",
        claw = 1,
        stars = {13,9,7},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","green","none"},
        stage = {{"green","green","green","green","green","green"},{},{},{},{},{}},
        goal = {{"green"},{"green"},{"green"},{"green"},{"green"},{"green"}},
        hint = "Move the pile one slot to the right and bring one crate back to the left.\n\nThe shortest known solution uses 7 registers.",
    },

    {
        name = "The Stacker",
        claw = 5,
        stars = {12,10,8},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","yellow","none"},
        stage = {{},{"yellow"},{"yellow"},{"yellow"},{"yellow"},{"yellow"},{"yellow"},{}},
        goal = {{},{},{},{},{},{},{},{"yellow","yellow","yellow","yellow","yellow","yellow"}},
        hint = "Go left until you find an empty slot, and then move the last yellow crate one slot to the right. Repeat.\n\nThe shortest known solution uses 8 registers.",
    },
    
    {
        name = "Clarity",
        claw = 1,
        stars = {9,7,6},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","red","green","none","multi"},
        stage = {{"green","red","green"},{"green","green","green","red","green"},
            {"red","green","red","green"},{"red","green","green"},{}},
        goal = {{"green","red"},{"green","green","green","red"},{"red","green","red"},{"red"},
            {"green","green","green","green","green"}},
        hint = "A disguised version of Mirror",
    },
    
    {
        name = "Come Together",
        claw = 1,
        stars = {15,9,7},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","yellow","none"},
        stage = {{},{},{"yellow","yellow","yellow"},{"yellow"},{},{},{"yellow","yellow"}},
        goal = {{"yellow","yellow","yellow","yellow","yellow","yellow"},{},{},{},{},{},{}},
        hint = "You can go right and find a yellow crate, but when bringing it back how do you know when to stop so that you don't crash into the wall?\n\nIn F2 use the programming stack to count the number of times you have to go right until you find a yellow crate, then go back left that same number of times. Another way to look at it: F2 is a recursive function that goes right until it finds a crate, and then it goes back to the original position. It can be implemented with 4 registers.\n\nThe shortest known solution uses a total of 7 registers.",
    },
    
    {
        name = "Come Together 2",
        claw = 1,
        stars = {12,10,8},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","green","yellow","none","multi"},
        stage = {{},{"yellow"},{"yellow","green","green"},{"yellow"},{"yellow","green"},{"yellow"},{"green","green","green","green"}},
        goal = {{"green","green","green","green","green","green","green"},{"yellow"},{"yellow"},{"yellow"},{"yellow"},{"yellow"},{}},
        hint = "Another stack puzzle. Re-use the solution from the previous level with a small modification.\n\nThe shortest known solution uses 8 registers.",
    },
    
    {
        name = "Up The Greens",
        claw = 1,
        stars = {12,9,7},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","blue","green","none","multi"},
        stage = {{"green"},{"blue","blue"},{"green"},{},{"blue","blue","blue"},{"green"},
            {"blue","blue"},{"blue","blue"}},
        goal = {{"green","blue","blue"},{},{"green","blue","blue","blue"},{},{},
            {"green","blue","blue","blue","blue"},{},{}},
        hint = "Very similar to the previous two levels but let the stack unwind and reset when you find a green. To do this only go left if holding a blue.\n\nThe shortest known solution uses 7 registers.",
    },

    {
        name = "Fill The Blanks",
        claw = 1,
        stars = {20,14,11},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","red","green","none","multi"},
        stage = {{"green","green","green","green"},{"red"},{},{"red"},{},{},{"red"},{}},
        goal = {{},{"red"},{"green"},{"red"},{"green"},{"green"},{"red"},{"green"}},
        hint = "As in the \"Lay It Out\" level, move the entire pile one slot to the right and bring one crate back to the left, except in the first iteration.\n\nThe shortest known solution uses 11 registers.",
    },
    
    {
        name = "Count The Blues",
        claw = 1,
        stars = {15,12,9},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","blue","yellow","none","multi"},
        stage = {{"yellow","blue","blue"},{},{},{},{"yellow","blue"},{},{}},
        goal = {{},{"blue","blue"},{},{"yellow"},{},{"blue"},{"yellow"}},
        hint = "Another stack puzzle. The number of blues indicates how many times to go right with the yellow.\n\nThe shortest known solution uses 9 registers.",
    },
    
    {
        name = "Multi Sort",
        claw = 1,
        stars = {16,11,11},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","blue","yellow","none","multi"},
        stage = {{},{"blue","yellow"},{},{"yellow","yellow","blue"},{"yellow","blue","yellow","blue"},{"blue","yellow"},{"blue"},{}},
        goal = {{"yellow","yellow","yellow","yellow","yellow","yellow"},{},{},{},{},{},{},{"blue","blue","blue","blue","blue","blue"}},
        hint = "Come Together for yellows, The Stacker for blues. Go forward until you find a crate. If blue, move it one slot further and come all the way back (using the stack) empty handed. If yellow, bring it back and drop it. Repeat.\n\nThe shortest known solution uses 11 registers."
    },
    
    {
        name = "Divide by two",
        claw = 1,
        stars = {20,14,12},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","blue","none"},
        stage = {{"blue","blue","blue","blue"},{},{"blue","blue"},{},
            {"blue","blue","blue","blue","blue","blue"},{},{"blue","blue","blue","blue"},{}},
        goal = {{"blue","blue"},{"blue","blue"},{"blue"},{"blue"},{"blue","blue","blue"},
            {"blue","blue","blue"},{"blue","blue"},{"blue","blue"}},
        hint = "Wind up the stack for every two crates. Move one crate back each time it unwinds.\n\nThe shortest known solution uses 12 registers."
    },
    
    {
        name = "The Merger",
        claw = 1,
        stars = {9,7,6},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","blue","red","none","multi"},
        stage = {{"blue","blue","blue"},{},{"red","red","red"}},
        goal = {{},{"blue","red","blue","red","blue","red"},{}},
        hint = "Use the stack once in each blue, and unwind it in each red.\n\nThe shortest known solution uses 6 registers.",
    },

    {
        name = "Even the Odds",
        claw = 1,
        stars = {13,11,10},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","blue","red","green","yellow",
            "none","multi"},
        stage = {{"green","green","green","green","green"},{},{"red","red"},{},
            {"blue","blue","blue"},{},{"yellow","yellow","yellow","yellow"},{}},
        goal = {{"green"},{"green","green","green","green"},{},{"red","red"},{"blue"},
            {"blue","blue"},{},{"yellow","yellow","yellow","yellow"}},
        hint = "If the pile has an odd number of crates, leave one crate behind, otherwise move all of them. Use a sequence of moves that undoes itself when repeated to move the crates right, and make sure to execute it an even number of times.\n\nThe shortest known solution uses 10 registers.",
    },
    
    {
        name = "Genetic Code",
        claw = 1,
        stars = {29,20,17},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","green","yellow","none","multi"},
        stage = {{"green","yellow","yellow","green","yellow","green"},{},
            {"yellow","yellow","yellow"},{},{"green","green","green"}},
        goal = {{},{"green","yellow","green","yellow","yellow","green"},{},
            {"green","yellow","yellow","green","yellow","green"},{}},
        hint = "The left pile gives instructions for how to construct the right pile. Wind up the entire stack on the left and unwind on the right.\n\nThe shortest known solution uses 17 registers.",
    },
    
    {
        name = "Multi Sort 2",
        claw = 1,
        stars = {25,17,17},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","blue","red","green","yellow","none","multi"},
        stage = {{},{"blue","yellow","red","green","yellow"},{},{"red","blue","blue","green","green","yellow"},{},{"red","green","yellow","red","blue"},{}},
        goal = {{"blue","blue","blue","blue"},{},{"red","red","red","red"},{},{"green","green","green","green"},{},{"yellow","yellow","yellow","yellow"}},
        hint = "Go over each pile and either pick up conditional on none if over the even slots, or drop conditional on the corresponding color if over the odd slots.\n\nThe shortest known solution uses 17 registers."
    },
    
    {
        name = "The Swap",
        claw = 2,
        stars = {15,12,10},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","red","green","none","multi"},
        stage = {{"red","red","red"},{},{"green","green","green"}},
        goal = {{"green","green","green"},{},{"red","red","red"}},
        hint = "Merge the piles in the middle, change parity, and unmerge.\n\nThe shortest known solution uses 10 registers.",
    },
    
    {
        name = "Restoring Order",
        claw = 1,
        stars = {29,20,16},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","blue","red","none","multi"},
        stage = {{},{"blue","red","blue","blue"},{"red","blue","red","blue"},
            {"blue","blue","blue"},{"red"},{"red","blue"},{"blue"},{}},
        goal = {{},{"blue","blue","blue"},{"blue","blue"},{"blue","blue","blue"},{},{"blue"},
            {"blue"},{"red","red","red","red","red"}},
        hint = "For each pile move the reds one slot to the right and the blues one slot to the left, but make sure to wind up a stack for the blues so that you can put them back afterwards. Repeat for each pile.\n\nThe shortest known solution uses 16 registers.",
    },
    
    {
        name = "Changing  Places",
        claw = 1,
        stars = {20,18,17},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","red","green","none","multi"},
        stage = {{"red"},{"red","red","red"},{"green","green","green"},{},
            {"red","red","red","red"},{"red","red"},
            {"green","green","green","green"},{"green"}},
        goal = {{"red","red","red"},{"red"},{},{"green","green","green"},
        {"red","red"},{"red","red","red","red"},
        {"green"},{"green","green","green","green"}},
        hint = "Switch each pair of piles, in place. First move the left pile to the right, winding up the stack. Then move all crates to the left slot. Finally, unwind the stack moving a crate to the right each time.\n\nThe shortest known solution uses 17 registers."
    },
    
    {
    name = "Palette Swap",
        claw = 2,
        stars = {29,18,15},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","blue","red","none","multi"},
        stage = {{},{"red","blue"},{"blue","red","blue","red"},{"blue","red"},
            {"blue","red","blue","red"},{},{"blue","red","blue","red","blue","red"},{}},
        goal = {{},{"blue","red"},{"red","blue","red","blue"},{"red","blue"},
            {"red","blue","red","blue"},{},{"red","blue","red","blue","red","blue"},{}},
        hint = "Go left and go right. Each time you do so, wind up the stack. When no more crates are left, unwind the stack going left and going right. Repeat. \n\nThe shortest known solution uses 15 registers.",
    },
    
    {
        name = "Mirror 2",
        claw = 1,
        stars = {20,15,12},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","yellow","none"},
        stage = {{"yellow","yellow","yellow"},{"yellow","yellow"},{"yellow"},{}},
        goal = {{},{"yellow"},{"yellow","yellow"},{"yellow","yellow","yellow"}},
        hint = "Move the top crate of the 2nd pile one slot to the right, and bring the left pile all the way to the right.\n\nThe shortest known solution uses 12 registers.",
    },
    
    {
        name = "Changing Places 2",
        claw = 1,
        stars = {25,19,16},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","red","none"},
        stage = {{"red",},{"red","red","red"},{"red"},{"red","red","red","red","red"},{},{"red","red"},{"red","red","red","red"},{"red","red","red"}},
        goal = {{"red","red","red"},{"red"},{"red","red","red","red","red"},{},{"red","red"},{"red","red","red","red"},{"red","red","red"},{"red"}},
        hint = "As in Changing Places, swap piles. Do that once for each pair of consecutive piles and you're done.\n\nThe shortest known solution uses 16 registers."
    },
    
    {
        name = "Vertical Sort",
        claw = 2,
        stars = {29,29,20},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","blue","green","none","multi"},
        stage = {{},{"green","blue","green","blue","blue"},
        {"blue","green","blue"},{"green","blue","blue","green"},{"blue","green"},{"blue","green","green","green","blue"},{}},
        goal = {{},{"green","green","blue","blue","blue"},{"green","blue","blue"},{"green","green","blue","blue"},{"green","blue"},{"green","green","green","blue","blue"},{}},
        hint = "Draw on ideas from previous sort levels."
    },
    
    {
        name = "Count in Binary",
        claw = 1,
        stars = {29,23,17},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","f5","green","none"},
        stage = {{"green","green","green","green","green","green"},{},{},{},{},{},{},},
        --goal = {{"green",},{"green"},{"green"},{},{"green"},{"green"},{"green"}},
        goal = {{"green","green"},{},{"green"},{"green"},{"green"},{},{"green"}},
        hint = "Count up all the numbers in binary: 1, 10, 11, 100,..."
    },
    
    {
        name = "Equalizer",
        claw = 1,
        stars = {40,40,40},
        funcs = {10,10,10,10,6},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","f5","blue","red","none","multi"},
        stage = {{},{"blue","blue"},{"blue"},{"blue","blue","blue","blue","blue"},{},{"blue","blue"},{"blue","blue","blue","blue"},{"red"}},
        goal = {{"blue","blue"},{"blue","blue"},{"blue","blue"},{"blue","blue"},{"blue","blue"},{"blue","blue"},{"blue","blue"},{"red"}},
    },
    
    {
        name = "Parting the Sea",
        claw = 1,
        stars = {17,17,17},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","blue","none"},
        stage = {{},{"blue","blue"},{"blue","blue"},{"blue","blue"},{"blue","blue"},{"blue","blue"},{}},
        goal = {{"blue","blue","blue","blue","blue"},{},{},{},{},{},
            {"blue","blue","blue","blue","blue"}},
    },
         
    {
        name = "The Trick",
        claw = 2,
        stars = {20,14,11},
        funcs = {8,8,8,5},
        toolbox = {"right","pickup","left","f1","f2","f3","f4","red","yellow","none","multi"},
        stage = {{"yellow","red"},{},{"red","yellow"}},
        goal = {{"red","yellow"},{},{"yellow","red"}},
        hint = "Bring the right pile to the middle, then the left pile to the middle. Finally unmerge the piles to their respective sides. \n\nThe shortest known solution uses 11 registers.",
    },
}

