-- Smoke.lua

Smoke = class(Panel)

function Smoke:init(x,y,screen)
    Panel.init(self,x,y)
    self.screen = screen

    self.life = 0
    self.maxLife = 0.3
    
    self.particles = {}
    for i = 1,5 do
        local scl = math.random()+1
        local obj = SpriteObj(
            math.random(-10,10),    -- x
            math.random(-10,10),    -- y
            scl * 28,               -- w
            scl * 29)               -- h
        self.screen:doDraw(obj,"Cargo Bot:Smoke Particle",10)
        self:add(obj)
        table.insert(self.particles,obj)
        
        local c = v 
        obj:rotate(math.random(0,360))
        obj.velocity = vec2(0,1):rotate(math.random(math.pi*2))*150
    end
end

function Smoke:tick()
    self.life = self.life + DeltaTime
    local l = self.life/self.maxLife
    local alpha = 1
    local startFade = 0.75
    if l > startFade then
        alpha = 1 - (l - startFade)*(1/startFade)
    end
    
    if alpha > 0 then
        for _,obj in ipairs(self.particles) do
            obj:setSize(obj:getW()+50*DeltaTime,obj:getH()+50*DeltaTime)
            local dpos = obj.velocity * DeltaTime
            obj:translate(dpos.x,dpos.y)
            obj:setAngle(obj:getAngle()+180*DeltaTime)
            obj:setTint(color(255,255,255,alpha*255))
        end
    else
        for _,obj in ipairs(self.particles) do
            self:remove(obj)
            self.screen:undoDraw(obj)
        end
        self.particles = {}
    end
end
