-- Textbox.lua
-- for receiving keyboard input

Textbox = class(Button)

function Textbox:init(x,y,w)
    Button.init(self,x,y,w,0) -- we don't know the height yet
    
    self.text = ""
    
    -- in font properties you can set fill,font,fontSize
    self.fontProperties = {font="Futura-CondensedExtraBold",fill=color(255,255,255)} 
    self:setFontSize(30)
    
    -- internal state
    self.active = false
    self.cursorPos = 0  -- 0 means before the first letter, 1 after the first, so on
end

function Textbox:setFontSize(x)
    self.fontProperties.fontSize = x
    -- calculate the height based on font properties
    pushStyle()
    self:applyTextProperties()
    local w,h = textSize("dummy")
    popStyle()
    self.h = h
end

-- call back for when a key is pressed
function Textbox:keyboard(key)
    -- if not active, ignore
    if not self.active then return nil end
    
    if key == BACKSPACE then
        -- note if we're already at the start, nothing to do
        if self.cursorPos > 0 then
            local prefix = self.text:sub(1,self.cursorPos-1)
            local posfix = self.text:sub(self.cursorPos+1,self.text:len())
            self.text = prefix..posfix
            self.cursorPos = self.cursorPos - 1
        end
    else
        local prefix = self.text:sub(1,self.cursorPos)
        local posfix = self.text:sub(self.cursorPos+1,self.text:len())
        local proposedText = prefix..key..posfix
        pushStyle()
        self:applyTextProperties()
        local proposedW = textSize(proposedText)
        popStyle()
        if proposedW <= self:maxX() then
            -- we can add the new char
            self.text = proposedText
            self.cursorPos = self.cursorPos + 1
        end
    end
end

function Textbox:applyTextProperties()
    textMode(CORNER)
    font(self.fontProperties.font)
    fontSize(self.fontProperties.fontSize)
    fill(self.fontProperties.fill)
end

-- when the text box is active, the keyboard shows up (and coursor and other elements too)
function Textbox:activate()
    self.active = true
    -- move the cursor to the end
    self.cursorPos = self.text:len()
    showKeyboard()
end

function Textbox:inactivate()
    self.active = false
    hideKeyboard()
end

function Textbox:maxX()
    return self.w - 10
end

function Textbox:draw()
    pushStyle()
    noSmooth()
    
    -- draw the text
    self:applyTextProperties()
    local textW = textSize(self.text)
    local textX = self.x + (self.w - textW)/2
    text(self.text,textX,self.y)

    if not self.active then
        popStyle()
        return nil
    end

    -- draw the cursor
    if math.floor(ElapsedTime*4)%2 == 0 then
        stroke(206, 206, 206, 255)
        strokeWidth(2)
        local prefix = self.text:sub(1,self.cursorPos)
        local len = textSize(prefix)
        line(textX+len,self.y,textX+len,self.y+self.h)
    end

     popStyle()
end

function Textbox:onEnded(touch)
    if not self.active then self:activate() end
end

-- moves the cursor to the x coordinate of the touch
function Textbox:onTouched(touch)
    if not self.active then return nil end
    
    self.cursorPos = 0
    local touchX = touch.x - self.x
    pushStyle()
    self:applyTextProperties()
    for idx = 1,self.text:len() do
        local len = textSize(self.text:sub(1,idx))
        if len > touchX then break end
        self.cursorPos = self.cursorPos + 1
    end
    popStyle()
end
