local Projectile = require('modules/Projectile')
local Arrow = class('Arrow', Projectile)

function Arrow:initialize( options )
    Projectile.initialize( self, options )

    self.type = 'arrow'

    self.speed = 120
    self.arrow_sound = love.audio.newSource("sounds/arrow.wav", "static")
    self.arrow_sound:play()

    if self.dir == 'right' then
        self.x = self.x + 4
        self.y = self.y + 7
    elseif self.dir == 'left' then
        self.x = self.x - 4
        self.y = self.y + 7
    elseif self.dir == 'down' then
        self.x = self.x + 7
        self.y = self.y + 4
    elseif self.dir == 'up' then
        self.x = self.x + 1
        self.y = self.y - 4
    end
    self.x = self.x
    self.y = self.y

    if self.dir == 'right' or self.dir == 'left' then
        self.frameWidth = 16
        self.frameHeight = 8
    elseif self.dir == 'down' or self.dir == 'up' then
        self.frameWidth = 8
        self.framHeight = 16
    end

    local g = nil
    if self.dir == 'right' then
        g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 48, 64)
    elseif self.dir == 'left' then
        g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 48, 80)
    elseif self.dir == 'down' then
        g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 48, 96)
    elseif self.dir == 'up' then
        g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 48, 112)
    end
    self.animation = anim8.newAnimation(g(1,1), 1)

    world:add( self, self.x, self.y, self.frameWidth, self.frameHeight )
end

function Arrow:update( dt )
    Projectile.update( self, dt )
end

function Arrow:draw()
    Projectile.draw( self )
end

return Arrow
