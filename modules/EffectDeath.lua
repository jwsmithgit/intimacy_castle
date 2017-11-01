local GameObject = require('modules/GameObject')
local EffectDeath = class('EffectDeath', GameObject)

function EffectDeath:initialize( options )
    GameObject.initialize( self, options )

    self.state = 1
    self.state_time = 0.1
    self.timer = self.state_time

    self.image = love.graphics.newImage('sprites/effects.png')
    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 0, 0)
    self.animations = {
        anim8.newAnimation(g(1,1), 0.1),
        anim8.newAnimation(g(2,1), 0.1),
        anim8.newAnimation(g(3,1), 0.1),
        anim8.newAnimation(g(4,1), 0.1),
        anim8.newAnimation(g(5,1), 0.1)
    }
end

function EffectDeath:update( dt )
    self.timer = self.timer - dt
    if self.timer <= 0 then
        self.state = self.state + 1
        self.timer = self.state_time
        if self.state > #self.animations then
            room:removeObject('effect', self)
        end
    end
end

function EffectDeath:draw( )
    self:drawState( )
end

return EffectDeath
