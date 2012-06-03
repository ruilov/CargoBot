-- Screen.lua
-- Represents any one of the game screens
-- Knows how to handle meshes and z-order of it's elems
-- The elems of this class are of type (or subclass) SpriteObj

Screen = class(Panel)
Screen.spriteMap = {} -- for fake sprites

-- creates a fake sprite. func should draw something in the (0,0,w,h) rect
-- this function has no return value
function Screen.makeSprite(name,func,w,h)
    if Screen.spriteMap[name] then return nil end
    
    local img = image(w,h)
    setContext(img)
    func()
    setContext()
    
    Screen.spriteMap[name] = img
end

function Screen.drawTextSprite(str,args,getCoords)
    local fontA = args.font or "Futura-CondensedExtraBold"
    local size = args.fontSize or 80
    local fillA = args.fill or color(255,255,255,255)
    local textModeA = args.textMode or CORNER
    local textWrap = args.textWrapWidth or -1
    local align = args.textAlign or LEFT
    smooth()
    font(fontA)
    fontSize(size)
    fill(fillA)
    textMode(textModeA)
    textWrapWidth(textWrap)
    textAlign(align)
    if not getCoords then text(str,0,0)
    else return textSize(str) end
end

-- returns a function that you can use to make text sprites
function Screen.makeTextSprite(name,str,args)
    local w,h = Screen.drawTextSprite(str,args,true)
    local f = function() Screen.drawTextSprite(str,args) end
    Screen.makeSprite(name,f,w,h)
    return w,h
end

function Screen:init()
    Panel.init(self,0,0)
    
    -- meshData maps z-coords to arrays of meshes
    self.meshData = {}
    self.highlights = {}
    
    if DEV_MODE then
        -- screenMode
        local smSprite = "devScreen"
        local smW,smH = Screen.makeTextSprite(smSprite,"screen",{fontSize=40})
        local screenMode = Button(10,800,smW,smH)
        screenMode.onEnded = function(but,t)
            if displayMode() == FULLSCREEN then displayMode(STANDARD)
            else displayMode(FULLSCREEN) end
         end       
        self:add(screenMode)
        screenMode.alwaysActive = true
        self:doDraw(screenMode,smSprite,1000000)
    end
end

-- low z coordinates are drawn first. Optinonal and defaults to zero
function Screen:doDraw(obj,imgName,z,zShadow)
    assert(imgName~=nil,"Adding obj to screen with nil imgName")
    --print("Screen.doDraw",imgName,z)
    
    -- handle shadow objects, which have a different coord for the shadow
    if zShadow ~= nil then
        self:doDraw(obj,imgName,z)
        self:doDraw(obj.shadow,imgName,zShadow)
        obj.shadow:setTint(color(0,0,0,50))
        obj:positionShadow()
        return nil
    end
    
    -- handle regular objects
    
    -- in case this was object was already drawn with a different sprite, eg the playB
    self:undoDraw(obj)
    
    z = z or 0
    if not self.meshData[z] then self.meshData[z] = {} end
    if not self.meshData[z][imgName] then
        local mesh = mesh()
        if Screen.spriteMap[imgName] then mesh.texture = Screen.spriteMap[imgName]
        else mesh.texture = imgName end
        self.meshData[z][imgName] = {data={mesh=mesh,pool={},imgName=imgName},elems={}}
    end
    
    table.insert(self.meshData[z][imgName].elems,obj)
    obj:setMesh(self.meshData[z][imgName].data)
end

-- creates a copy of this obj in the meshes with a z coord that is higher
function Screen:highlightObj(obj,dz)
    -- we need to go through the zs in decreasing order. Why you ask?
    -- because otherwise we could end up highlighting the highlight itself!
    local zs = {}
    for z,zData in pairs(self.meshData) do table.insert(zs,z) end
    table.sort(zs, function(a,b) return a > b end)
    
    for _,z in ipairs(zs) do
        for imgName,imgData in pairs(self.meshData[z]) do
            for idx,elem in ipairs(imgData.elems) do
                if elem == obj then
                    self:undoDraw(obj)
                    self:doDraw(obj,imgData.data.imgName,z+dz)
                    table.insert(self.highlights,{originalZ=z,imgName=imgName,obj=obj})
                end
            end
        end
    end
end

function Screen:removeHighlights()
    -- need the clone because undoDraw removes stuff from self.highlights
    local highClone = Table.clone(self.highlights)
    for _,elem in ipairs(highClone) do
        local wasThere = self:undoDraw(elem.obj)
        if wasThere then
            self:doDraw(elem.obj,elem.imgName,elem.originalZ) 
        end
    end
    self.highlights = {}
end

function Screen:undoDraw(obj)
    -- handle shadow objects
    if obj.shadow then 
        self:undoDraw(obj.shadow) 
    end
    
    local retVal = false
    for z,zData in pairs(self.meshData) do
        for imgName,imgData in pairs(zData) do
            for idx,elem in ipairs(imgData.elems) do
                if elem == obj then
                    -- first remove from self
                    table.remove(imgData.elems,idx)
                    -- add the index to the pool of unused indices
                    table.insert(imgData.data.pool,obj.meshIdx)
                    -- remove from the mesh
                    imgData.data.mesh:setRect(obj.meshIdx,0,0,0,0,0)
                    
                    assert(not retVal,"found multiple copies of obj in screen meshes")
                    retVal = true
                    
                    -- remove from the highlights
                    for idx,highElem in ipairs(self.highlights) do
                        if highElem.obj == obj then
                            table.remove(self.highlights,idx)
                        end
                    end
                end
            end
        end
    end
    return retVal
end

function Screen:draw()
    -- first sort the z's in increasing order
    local zs = {}
    for z,zData in pairs(self.meshData) do table.insert(zs,z) end
    table.sort(zs, function(a,b) return a < b end)
    
    -- then draw each one
    for _,z in ipairs(zs) do
        for imgName,imgData in pairs(self.meshData[z]) do
            imgData.data.mesh:draw()
        end
    end
end

function Screen:snap(x,y,w,h)
    local img = image(w,h)
    setContext(img)
    pushMatrix()
    translate(-x,-y)
    self:draw()
    popMatrix()
    setContext()
    return img
end

function Screen:touched(t)
    if not self.active then return false end
    
    -- first sort the z's in decreasing order
    local zs = {}
    for z,zData in pairs(self.meshData) do table.insert(zs,z) end
    table.sort(zs, function(a,b) return a > b end)
    
    -- then draw each one
    for _,z in ipairs(zs) do
        for imgName,imgData in pairs(self.meshData[z]) do
            for _,elem in ipairs(imgData.elems) do
                if elem.touched and elem.active then
                    local wasTouched = elem:touched(t)
                    if wasTouched then return nil end -- we're done
                end
            end
        end
    end
    
    -- if none of the drawing elems triggered, see if we trigger non drawing elems
    Panel.touched(self,t)
end
