local Enemy = require('modules/Enemy')
local SlimeTiny = class('SlimeTiny', Enemy)

function SlimeTiny:initialize( options )
    Enemy.initialize( self, options )

    self.health = 1
    self.speed = math.random(10,50)

    self.state = 'move'
    self.state_times = {
        hurt = 0.4
    }
    self.box = 4
    self.boy = 4

    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 0, 48)
    self.animations = {
        idle = anim8.newAnimation(g(1,1), 1),
        move = anim8.newAnimation(g('1-2',1), 0.1),
        hurt = anim8.newAnimation(g(3,1, 1,1), 0.1)
    }

    self:changeState(self.state)
    self:worldAdd()
end

function SlimeTiny:update( dt )
    Enemy.update(self, dt)

    --state dependent
    if self.state == 'move' then
        self:moveTowardsObject( dt, self.target )
    elseif self.state == 'hurt' then
    end

    --state independent
    if self.state_timer > 0 then
        self.state_timer = self.state_timer - dt
        if self.state_timer <= 0 then

            if self.state == 'hurt' then
                if self.health <= 0 then
                    room:removeObject( 'enemy', self )
                end
                self:changeState('move')
            end

        end
    end
end

function SlimeTiny:draw()
    self:drawState( )
end

return SlimeTiny
