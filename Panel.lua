-- Panel.lua
-- A panel is a container for other panels or objects that can be drawn. Used to form a 
-- hierarchical representation of what's in the screen.
-- - The leaves of the hierarchy are typically SpriteObjs
-- - Handles binding and unbinding of events
-- - Forwards things like touched and collided to its elements

Panel = class(PositionObj)

function Panel:init(x,y)
    PositionObj.init(self,x,y)
    self.active = true -- if not active, touch events are not handled
    self.elems = {}
end

-- object should have coordinates relative to this one
function Panel:add(obj)
    Table.map(function(x) assert(x~=obj,"adding duplicate obj") end,self.elems)
    obj:translate(self.x,self.y)
    table.insert(self.elems,obj)
end

function Panel:translate(dx,dy)
    PositionObj.translate(self,dx,dy)
    Table.map(function(x) x:translate(dx,dy) end,self.elems)
end

function Panel:flipX()
    Table.map(function(x) if x.flipX then x:flipX() end end, self.elems)
end

function Panel:setTint(c)
    Table.map(function(x) if x.setTint then x:setTint(c) end end, self.elems)
end

-- called in every frame update
function Panel:tick()
    Table.map(function(x) if x.tick then x:tick() end end, self.elems)
end

function Panel:highlight(screen,dz)
    screen:highlightObj(self,dz)
    Table.map(function(x) 
        if x.highlight then x:highlight(screen,dz) 
        else screen:highlightObj(x,dz) end 
    end, self.elems)
end

function Panel:remove(obj)
    Table.remove(self.elems,obj)
end

function Panel:removeAll()
    self.elems = {}
end

-- undraws this and elems recursively from the screen
function Panel:undraw(screen)
    screen:undoDraw(self)
    Table.map(function(x) 
        if x.undraw then x:undraw(screen)
        else screen:undoDraw(x) end
    end, self.elems)
end

function Panel:touched(t)
    if not self.active then return nil end
    
    local elemsClone = Table.clone(self.elems)
    Table.map(function(x) if x.touched and x.active then x:touched(t) end end,elemsClone)
end

function Panel:setActive(val)
    self.active = val
    Table.map(function(x)
        if not x.alwaysActive then
            if x.setActive then x:setActive(val)
            else x.active = val end
        end
    end, self.elems)
end

function Panel:unbind()
    Events.unbind(self)
    Table.map(function(x)
        if x.unbind then x:unbind()
        else Events.unbind(x) end
    end,self.elems)
end

function Panel:bind()
    if self.bindEvents then self:bindEvents() end
    Table.map(function(x)
        if x.bind then x:bind()
        elseif x.bindEvents then x:bindEvents() end
    end,self.elems)
end
