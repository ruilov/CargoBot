-- Command.lua
-- Commands are listed below

Command = class(Button)

Command.spriteMap = {
    right = "Cargo Bot:Command Right",
    pickup = "Cargo Bot:Command Grab",
    left = "Cargo Bot:Command Left",
    f1 = "Cargo Bot:Program 1",
    f2 = "Cargo Bot:Program 2",
    f3 = "Cargo Bot:Program 3",
    f4 = "Cargo Bot:Program 4",
    f5 = "Cargo Bot:Program 5",
    blue = "Cargo Bot:Condition Blue",
    green = "Cargo Bot:Condition Green",
    red = "Cargo Bot:Condition Red",
    yellow = "Cargo Bot:Condition Yellow",
    none = "Cargo Bot:Condition None",
    multi = "Cargo Bot:Condition Any",
    unused = "Cargo Bot:Program 5"
}

function Command.type(command)
    if command == "left" or command == "pickup" or command == "right" or
        command:sub(1,1)=="f" then return "command"
    else return "conditional" end
end

function Command:init(command,x,y,w,h)
    Button.init(self,x,y,w,h)
    self.command = command
end
