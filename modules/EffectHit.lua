local GameObject = require('modules/GameObject')
local EffectHit = class('EffectHit', GameObject)

function EffectHit:initialize( options )
    GameObject.initialize( self, options )

    self.x = self.x - 8
    self.y = self.y - 8

    self.state = 1
    self.state_time = 0.1
    self.timer = self.state_time

    self.image = love.graphics.newImage('sprites/effects.png')
    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 0, 0)
    self.animations = {
        anim8.newAnimation(g(3,1), 0.1),
        anim8.newAnimation(g(4,1), 0.1),
        anim8.newAnimation(g(5,1), 0.1)
    }
end

function EffectHit:update( dt )
    self.timer = self.timer - dt
    if self.timer <= 0 then
        self.state = self.state + 1
        self.timer = self.state_time
        if self.state > #self.animations then
            room:removeObject('effect', self)
        end
    end
end

function EffectHit:draw( )
    self:drawState( )
end

return EffectHit
