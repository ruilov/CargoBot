Popover = class()

function Popover:init(x,y,w,h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.visible = false
    self.icons = {}
end

-- if dir is "left" or "right", coord is height of the arrow from the bottom of the popover
-- if dir is "up" or "down", coord is dist of the arrow from the left edge of the popover
function Popover:arrow(dir,coord)
    self.arrowData = {dir=dir,coord=coord}
end

function Popover:show()
    self.visible = true
end

function Popover:hide()
    self.visible = false
end

function Popover:setText(text,fontSize)
    self.text = text
    self.fontSize = fontSize
end

function Popover:pack()
    if self.text then
        pushStyle()
        font("Futura-CondensedExtraBold")
        textWrapWidth(500)
        fontSize(self.fontSize)
        local w,h = textSize(self.text)
        self.w,self.h = w + 20, h + 12
        popStyle()
    end
end

function Popover:addIcon(imgName,x,y,w,h)
    table.insert(self.icons,{imgName=imgName,x=x,y=y,w=w,h=h})
end

function Popover:draw()
    if not self.visible then return nil end
    
    pushMatrix()
    pushStyle()
    translate(self.x,self.y)
    
    rectMode(CORNER)
    stroke(0, 0, 0, 255)
    fill(0, 138, 255, 255)
    strokeWidth(5)
    rect(0,0,self.w,self.h)
    
    if self.arrowData then
        spriteMode(CORNER)
        local arrw,arrh = 22,25
        local arrx,arry,arrang,shax
        if self.arrowData.dir == "right" then
            arrx = self.w-6
            shax = arrx+1
            arry = self.arrowData.coord
            arrang = 0
        elseif self.arrowData.dir == "left" then
            arrx = -6
            shax = arrx+2
            arry = self.arrowData.coord - arrh
            arrang = 180
        elseif self.arrowData.dir == "up" then
            arrx = self.h-6
            shax = arrx+1
            arry = -self.arrowData.coord - arrh
            arrang = 90
        elseif self.arrowData.dir == "down" then
            arrx = -6
            shax = arrx+1
            arry = self.arrowData.coord
            arrang = -90
        end
        pushMatrix()
        rotate(arrang)
        tint(0, 0, 0, 255)
        sprite("Cargo Bot:Play Solution Icon",shax,arry-3,arrw+5,arrh+6)
        tint(0,138,255,255)
        sprite("Cargo Bot:Play Solution Icon",arrx,arry,arrw,arrh)
        popMatrix()
    end
    
    if self.text then
        fill(255, 255, 255, 255)
        font("Futura-CondensedExtraBold")
        textWrapWidth(self.w-15)
        textMode(CORNER)
        fontSize(self.fontSize)
        local w,h = textSize(self.text)
        text(self.text,10,self.h - h - 5)
    end
     
    noTint()
    spriteMode(CORNER)
    for _,icon in ipairs(self.icons) do
        sprite(icon.imgName,icon.x,icon.y,icon.w,icon.h)
    end

    popStyle()
    popMatrix()
end
