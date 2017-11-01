local Enemy = require('modules/Enemy')
local Archer = class('Archer', Enemy)

local Arrow = require('modules/Arrow')

function Archer:initialize( options )
    Enemy.initialize( self, options )

    self.health = 2
    self.speed = 40

    self.arrow = nil

    self.state = 'walk'
    self.dir = 'right'
    self.state_times = {
        idle = 1.5,
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

function Archer:update( dt )
    Enemy.update(self, dt)

    --state dependent
    if self.state == 'idle' then
    elseif self.state == 'walk' then
        self:parallelWalk(dt)
    elseif self.state == 'hurt' then
    end

    --state independent
    if self.state_timer > 0 then
        self.state_timer = self.state_timer - dt
        if self.state_timer <= 0 then

            if self.state == 'idle' then
                self:changeState('walk')
            elseif self.state == 'hurt' then
                if self.health <= 0 then
                    room:removeObject( 'enemy', self )
                end
                self:changeState('walk')
            end

        end
    end
end

function Archer:draw()
    self:drawStateDir()
end

function Archer:parallelWalk( dt )
    local horizontal = self.target.x - self.x
    local vertical = self.target.y - self.y

    if math.abs(horizontal) < self.speed*dt then
        if self.target.y > self.y then
            self.dir = 'down'
        else
            self.dir = 'up'
        end
        self.arrow = Arrow:new({x=self.x, y=self.y, owner=self})
        room:addObject( 'projectile', self.arrow )
        self:changeState('idle')
    elseif math.abs(vertical) < self.speed*dt then
        if self.target.x > self.x then
            self.dir = 'right'
        else
            self.dir = 'left'
        end
        self.arrow = Arrow:new({x=self.x, y=self.y, owner=self})
        room:addObject( 'projectile', self.arrow )
        self:changeState('idle')
    elseif math.abs(horizontal) < math.abs(vertical) then
        if self.target.x > self.x then
            self.dir = 'right'
        else
            self.dir = 'left'
        end
        self:moveDirection( dt, horizontal, 0 )
    else
        if self.target.y > self.y then
            self.dir = 'down'
        else
            self.dir = 'up'
        end
        self:moveDirection( dt, 0, vertical )
    end
end

return Archer
