local Projectile = require('modules/Projectile')
local Magic = class('Magic', Projectile)

function Magic:initialize( options )
    Projectile.initialize( self, options )

    self.type = 'magicbad'

    self.speed = 120
    self.magic_sound = love.audio.newSource("sounds/magic.wav", "static")
    self.magic_sound:play()

    if self.dir == 'right' then
        self.x = self.x + 4
        self.y = self.y + 3
    elseif self.dir == 'left' then
        self.x = self.x - 4
        self.y = self.y + 3
    elseif self.dir == 'down' then
        self.x = self.x + 2
        self.y = self.y + 4
    elseif self.dir == 'up' then
        self.x = self.x + 2
        self.y = self.y - 4
    end

    self.frameWidth = 12
    self.frameHeight = 12

    local g = nil
    if self.dir == 'right' then
        g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 16, 128)
    elseif self.dir == 'left' then
        g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 16, 144)
    elseif self.dir == 'down' then
        g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 16, 160)
    elseif self.dir == 'up' then
        g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 16, 176)
    end
    self.animation = anim8.newAnimation(g(1,1), 1)

    world:add( self, self.x, self.y, self.frameWidth, self.frameHeight )
end

function Magic:update( dt )
    Projectile.update( self, dt )
end

function Magic:draw( )
    Projectile.draw( self )
end

return Magic
