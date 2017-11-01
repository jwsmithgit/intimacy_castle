local Enemy = require('modules/Enemy')
local Skeleton = class('Skeleton', Enemy)

function Skeleton:initialize( options )
    Enemy.initialize( self, options )

    self.health = 3
    self.speed = 30

    self.state = 'move'
    self.state_times = {
        hurt = 0.4
    }
    self.box = 1
    self.boy = 1

    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 0, 16)
    self.animations = {
        idle = anim8.newAnimation(g(1,1), 1),
        move = anim8.newAnimation(g('1-2',1), 0.1),
        hurt = anim8.newAnimation(g(3,1, 1,1), 0.1)
    }

    self:changeState(self.state)
    self:worldAdd()
end

function Skeleton:update( dt )
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

function Skeleton:draw()
    self:drawState( )
end

return Skeleton
