local GameObject = require('modules/GameObject')
local Health = class('Health', GameObject)

function Health:initialize( options )
    GameObject.initialize( self, options )

    self.player = options.player
    if self.player == 1 then
        self.x = game_width/2 - 48
    elseif self.player == 2 then
        self.x = game_width/2
    end
    self.y = game_height - 16
    self.health = 6

    self.image = love.graphics.newImage('sprites/player.png')
    local gh = anim8.newGrid(self.frameWidth/2, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 0, 0)
    self.hearts = {
        anim8.newAnimation(gh(1,1), 1),
        anim8.newAnimation(gh(2,1), 1),
        anim8.newAnimation(gh(3,1), 1),
    }

    local ga = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 32, 0)
    self.avatar = {
        anim8.newAnimation(ga(1,1), 1),
        anim8.newAnimation(ga(2,1), 1),
    }
end

function Health:update( dt )
end

function Health:draw( )
    self.avatar[self.player]:draw(self.image, math.floor(self.x), math.floor(self.y))
    for i=1,3 do
        if i*2-1 == self.health then
            self.hearts[2]:draw(self.image, math.floor(self.x + 16 + 8*(i-1)), math.floor(self.y))
        elseif i*2-1 < self.health then
            self.hearts[1]:draw(self.image, math.floor(self.x + 16 + 8*(i-1)), math.floor(self.y))
        elseif i*2-1 > self.health then
            self.hearts[3]:draw(self.image, math.floor(self.x + 16 + 8*(i-1)), math.floor(self.y))
        end

    end
end

function Health:hurt( )
    self.health = self.health - 1
end

return Health
