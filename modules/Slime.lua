local Enemy = require('modules/Enemy')
local Slime = class('Slime', Enemy)

local SlimeTiny = require('modules/SlimeTiny')

function Slime:initialize( options )
    Enemy.initialize( self, options )

    self.health = 1
    self.speed = 40

    self.state = 'move'
    self.state_times = {
        hurt = 0.4
    }
    self.box = 2
    self.boy = 1

    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 0, 32)
    self.animations = {
        idle = anim8.newAnimation(g(1,1), 1),
        move = anim8.newAnimation(g('1-2',1), 0.1),
        hurt = anim8.newAnimation(g(3,1, 1,1), 0.1)
    }

    self:changeState(self.state)
    self:worldAdd()
end

function Slime:update( dt )
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
                    for i=1,3 do
                        local tsxy = self:chooseLocation( 24 )
                        local tsx = math.max(room.minx, math.min(room.maxx, self.x+tsxy[1]))
                        local tsy = math.max(room.miny, math.min(room.maxy, self.y+tsxy[2]))
                        room:addObject( 'enemy', SlimeTiny:new( {x=tsx, y=tsy} ) )
                    end

                    room:removeObject( 'enemy', self )
                end
                self:changeState('move')
            end

        end
    end
end

function Slime:draw( )
    self:drawState( )
end

function Slime:chooseLocation( radius )
    local r, t = math.random(0, radius), math.random(0, 3.14)
    return { r * math.cos(t), r * math.sin(t) }
end

return Slime
