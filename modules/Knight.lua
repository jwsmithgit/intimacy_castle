local Enemy = require('modules/Enemy')
local Knight = class('Knight', Enemy)

local SwordBad = require('modules/SwordBad')

function Knight:initialize( options )
    Enemy.initialize( self, options )

    self.health = 3
    self.speed = 40

    self.dir = 'right'
    self.sword = SwordBad:new( {x=self.x, y=self.y, owner=self} )

    self.state = 'idle'
    self.state_times = {
        idle = 1,
        walk = 4,
        hurt = 0.4
    }
    self.box = 1
    self.boy = 1

    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 0, 64)
    self.animations = {
        idleright = anim8.newAnimation(g(1,1), 1),
        idleleft = anim8.newAnimation(g(1,2), 1),
        idledown = anim8.newAnimation(g(1,3), 1),
        idleup = anim8.newAnimation(g(1,4), 1),

        walkright = anim8.newAnimation(g('1-2',1), 0.1),
        walkleft = anim8.newAnimation(g('1-2',2), 0.1),
        walkdown = anim8.newAnimation(g('1-2',3), 0.1),
        walkup = anim8.newAnimation(g('1-2',4), 0.1),

        hurtright = anim8.newAnimation(g(5,1, 1,1), 0.1),
        hurtleft = anim8.newAnimation(g(5,2, 1,2), 0.1),
        hurtdown = anim8.newAnimation(g(5,3, 1,3), 0.1),
        hurtup = anim8.newAnimation(g(5,4, 1,4), 0.1),
    }

    self:changeState(self.state)
    self:worldAdd()
end

function Knight:update( dt )
    Enemy.update(self, dt)

    world:remove(self.sword)
    self.sword = SwordBad:new( {x=self.x, y=self.y, owner=self} )

    self:changeDirection()

    --state dependent
    if self.state == 'idle' then
    elseif self.state == 'walk' then
        self:moveTowardsObject( dt, self.target )
    elseif self.state == 'hurt' then
    end

    --state independent
    if self.state_timer > 0 then
        self.state_timer = self.state_timer - dt
        if self.state_timer <= 0 then
            if self.state == 'idle' then
                self:changeState('walk')
            elseif self.state == 'walk' then
                self:changeState('idle')
            elseif self.state == 'hurt' then
                if self.health <= 0 then
                    world:remove(self.sword)
                    room:removeObject( 'enemy', self )
                end
                self:changeState('walk')
            end
        end
    end
end

function Knight:draw( )
    if self.dir == 'up' then self.sword:draw() end

    self:drawStateDir( )

    if self.dir ~= 'up' then self.sword:draw() end
end

function Knight:swordCollision( other )
    if self.state ~= 'hurt' and self.health > 0 then
        local dirx = self:ox() - other:ox()
        local diry = self:oy() - other:oy()
        local mag = math.sqrt( dirx^2 + diry^2 )
        local uv = 1/mag

        local x, y, cols, len = world:move(self, self.x+self.box+(16*uv*dirx), self.y+self.boy+(16*uv*diry), self.filter )
        self.x = x - self.box
        self.y = y - self.boy
    end
end

function Knight:changeDirection()
    local dx, dy = self.target.x - self.x, self.target.y - self.y
    if math.abs(dx) > math.abs(dy) then
        if dx < 0 then
            self.dir = 'left'
        else
            self.dir = 'right'
        end
    else
        if dy < 0 then
            self.dir = 'up'
        else
            self.dir = 'down'
        end
    end
end

return Knight
