local Enemy = require('modules/Enemy')
local Bat = class('Bat', Enemy)

function Bat:initialize( options )
    Enemy.initialize( self, options )

    self.health = 1
    self.speed = 40

    self.state = 'idle'
    self.state_times = {
        idle = 1,
        move = 4,
        hurt = 0.4
    }
    self.bos = {
        idle = {4,3},
        move = {4,3},
        hurt = {4,3},
    }

    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 0, 0)
    self.animations = {
        idle = anim8.newAnimation(g(1,1), 1),
        move = anim8.newAnimation(g('1-2',1), 0.1),
        hurt = anim8.newAnimation(g(3,1, 1,1), 0.1)
    }

    self:changeState(self.state)
    self:worldAdd()
end

function Bat:update( dt )
    Enemy.update(self, dt)

    --state dependent
    if self.state == 'idle' then

    elseif self.state == 'move' then
        self:moveTowardsObject( dt, self.target )
    elseif self.state == 'hurt' then
    end

    --state independent
    if self.state_timer > 0 then
        self.state_timer = self.state_timer - dt
        if self.state_timer <= 0 then

            if self.state == 'idle' then
                self:changeState( 'move' )
                self.air = true
            elseif self.state == 'move' then
                local x, y, cols, len = world:check(self, self.x + self.box, self.y + self.boy, self.filter )
                if #cols > 0 then
                    self.state_timer = self.state_timer + dt
                else
                    self:changeState( 'idle' )
                    self.air = false
                end
            elseif self.state == 'hurt' then
                if self.health <= 0 then
                    room:removeObject( 'enemy', self )
                end
                self:changeState( 'move' )
                self.air = true
            end

        end
    end
end

function Bat:draw( )
    self:drawState( )
end

function Bat:moveTowardsObject( dt, o )
    local dirx, diry = o:ox() - self:ox(), o:oy() - self:oy()
    local mag = math.sqrt( dirx^2 + diry^2 )
    local uv = 1/mag
    local movex, movey = self.speed*uv*dirx, self.speed*uv*diry
    local x, y, cols, len = world:move(self, self.x + self.box + movex*dt + math.random(-2,2), self.y + self.boy + movey*dt + math.random(-2,2), self.filter )
    self.x = x - self.box
    self.y = y - self.boy
    for i,v in ipairs(cols) do
        if v.other.type == 'player' then
            v.other:collision( self )
        end
    end
end

return Bat
