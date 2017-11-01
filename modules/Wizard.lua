local Enemy = require('modules/Enemy')
local Wizard = class('Wizard', Enemy)

local Magic = require('modules/Magic')

function Wizard:initialize( options )
    Enemy.initialize( self, options )

    self.dir = 'right'
    self.health = 2

    self.alpha = 255
    self.fadein_speed = 400
    self.fadeout_speed = -200

    self.magic = nil

    self.state_times = {
        idle = 2,
        invisible = 3,
        hurt = 0.4
    }
    self.bos = { {1,1} }

    local g = anim8.newGrid(self.frameWidth, self.frameWidth, self.image:getWidth(), self.image:getHeight(), 0, 128)
    self.animations = {
        idleright = anim8.newAnimation(g(1,1), 1),
        idleleft = anim8.newAnimation(g(1,2), 1),
        idledown = anim8.newAnimation(g(1,3), 1),
        idleup = anim8.newAnimation(g(1,4), 1),

        invisibleright = anim8.newAnimation(g(1,1), 0.1),
        invisibleleft = anim8.newAnimation(g(1,2), 0.1),
        invisibledown = anim8.newAnimation(g(1,3), 0.1),
        invisibleup = anim8.newAnimation(g(1,4), 0.1),

        hurtright = anim8.newAnimation(g(3,1, 1,1), 0.1),
        hurtleft = anim8.newAnimation(g(3,2, 1,2), 0.1),
        hurtdown = anim8.newAnimation(g(3,3, 1,3), 0.1),
        hurtup = anim8.newAnimation(g(3,4, 1,4), 0.1),
    }

    self:changeState('invisible')
end

function Wizard:update( dt )
    Enemy.update(self, dt)

    --state dependent
    if self.state == 'invisible' then
        if self.alpha > 0 then
            self.alpha = self.alpha + self.fadeout_speed*dt
            if self.alpha < 0 then self.alpha = 0 end
        end
    elseif self.state == 'idle' then
        if self.alpha < 255 then
            self.alpha = self.alpha + self.fadein_speed*dt
            if self.alpha > 255 then
                 self.alpha = 255
            end
            if self.alpha == 255 and self.magic == nil then
                self.magic = Magic:new( {x=self.x, y=self.y, owner=self} )
                room:addObject( 'projectile', self.magic )
            end
        end
    elseif self.state == 'hurt' then
    end

    --state independent
    if self.state_timer > 0 then
        self.state_timer = self.state_timer - dt
        if self.state_timer <= 0 then
            if self.state == 'invisible' then
                self:changeState('idle')
                self:chooseLocation()
                self:worldAdd()

            elseif self.state == 'idle' then
                self.magic = nil
                self:changeState('invisible')
                world:remove( self )

            elseif self.state == 'hurt' then
                if self.health <= 0 then
                    room:removeObject( 'enemy', self )
                else
                    world:remove( self )
                end
                self.magic = nil
                self:changeState('invisible')
            end
        end
    end
end

function Wizard:draw()
    local r,g,b,a = love.graphics.getColor( )
    love.graphics.setColor( r, g, b, self.alpha )
    self:drawStateDir( )
    love.graphics.setColor( r, g, b, a )
end

function Wizard:chooseLocation()
    local leftx = {room.minx, self.target.x-self.frameWidth}
    local rightx = {self.target.x+self.frameWidth, room.maxx-self.frameWidth}
    local upy = {room.miny, self.target.y-self.frameHeight}
    local downy = {self.target.y+self.frameHeight, room.maxy-self.frameHeight}

    local choices = {}
    for i=leftx[1],leftx[2] do table.insert(choices, {i, self.target.y}) end
    for i=rightx[1],rightx[2] do table.insert(choices, {i, self.target.y}) end
    for i=upy[1],upy[2] do table.insert(choices, {self.target.x, i}) end
    for i=downy[1],downy[2] do table.insert(choices, {self.target.x, i}) end

    local choice = choices[math.random(#choices)]
    self.x = choice[1]
    self.y = choice[2]

    if self.x < self.target.x then self.dir = 'right'
    elseif self.x > self.target.x then self.dir = 'left'
    elseif self.y < self.target.y then self.dir = 'down'
    elseif self.y > self.target.y then self.dir = 'up'
    end
end

return Wizard
