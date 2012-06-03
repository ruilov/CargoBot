-- SpriteObj.lua
-- Everything that is drawn on the screen is a SpriteObj. At creation time a SpriteObj
-- doesn't have a mesh yet. setMesh needs to be called on it before any other properties.
-- This is usually accomplished by adding the object to a Screen, which knows how to 
-- handle meshes
    
-- If you'd like to draw things that are not sprites, first make a fake sprite with
-- Screen.makeSprite
    
-- A number of getters and setters are defined

SpriteObj = class(RectObj)

function SpriteObj:init(x,y,w,h)
    RectObj.init(self,x,y,w,h)
    self.tint = color(255,255,255,255)
end

-- meshData has
-- .mesh: the mesh itself
-- .pool: a pool of unused indices in this mesh
function SpriteObj:setMesh(meshData)
    self.meshData = meshData
    
    if #self.meshData.pool > 0 then
        -- reuse from the pool
        self.meshIdx = self.meshData.pool[1]
        table.remove(self.meshData.pool,1)
        self:updateMesh()
    else
        -- create a new one
        if self.mode == CORNER then
            self.meshIdx = self.meshData.mesh:addRect(self.x+self.w/2,self.y+self.h/2,
                self.w,self.h,self.angle)
        else
            assert(self.mode==CENTER,"invalide mode")
            self.meshIdx = self.meshData.mesh:addRect(self.x,self.y,
                self.w,self.h,self.angle)
        end
    end
    
    self.meshData.mesh:setRectColor(self.meshIdx,self.tint)
end

-- internal method that is called whenever the visual properties of this obj change
function SpriteObj:updateMesh()
    if not self.meshIdx then return nil end
    if self.mode == CORNER then
        self.meshData.mesh:setRect(self.meshIdx,self.x+self.w/2,
            self.y+self.h/2,self.w,self.h,self.angle)
    else
        assert(self.mode==CENTER,"invalide mode")
        self.meshData.mesh:setRect(self.meshIdx,self.x,
            self.y,self.w,self.h,self.angle)
    end
end

---------------------- SETTERS -----------------------
function SpriteObj:setMode(mode)
    RectObj.setMode(self,mode)
    self:updateMesh()
end

function SpriteObj:setSize(w,h)
    RectObj.setSize(self,w,h)
    self:updateMesh()
end

function SpriteObj:translate(dx,dy)
    RectObj.translate(self,dx,dy)
    self:updateMesh()
end

-- ang in degrees
function SpriteObj:rotate(ang)
    RectObj.rotate(self,ang)
    self:updateMesh()
end

function SpriteObj:setAngle(ang)
    RectObj.setAngle(self,ang)
    self:updateMesh()
end

function SpriteObj:setTint(tint)
    self.tint = tint
    self.meshData.mesh:setRectColor(self.meshIdx,self.tint)
end

-- w,y,w,h are in the 0-1 range
function SpriteObj:setRectTex(x,y,w,h)
    self.meshData.mesh:setRectTex(self.meshIdx,x,y,w,h)
end
