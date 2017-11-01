local GameObject = require('modules/GameObject')
local SwordBad = class('SwordBad', GameObject)

local EffectHit = require('modules/EffectHit')

function SwordBad:initialize( options )
    GameObject.initialize( self, options )

    self.type = 'swordbad'
    self.owner = options.owner
    self.dir = self.owner.dir

    if self.dir == 'right' then
        self.x = self.x + 12
        self.y = self.y + 9
    elseif self.dir == 'left' then
        self.x = self.x - 12
        self.y = self.y + 9
    elseif self.dir == 'down' then
        self.x = self.x + 9
        self.y = self.y + 12
    elseif self.dir == 'up' then
        self.x = self.x + 1
        self.y = self.y - 12
    end

    if self.dir == 'right' or self.dir == 'left' then
        self.frameWidth = 16
        self.frameHeight = 6
    elseif self.dir == 'down' or self.dir == 'up' then
        self.frameWidth = 6
        self.framHeight = 16
    end

    self.image = love.graphics.newImage('sprites/enemy.png')
    local g = nil
    if self.dir == 'right' then
        g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 32, 64)
    elseif self.dir == 'left' then
        g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 32, 80)
    elseif self.dir == 'down' then
        g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 32, 96)
    elseif self.dir == 'up' then
        g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 32, 112)
    end
    self.animation = anim8.newAnimation(g(1,1), 1)

    world:add( self, self.x, self.y, self.frameWidth, self.frameHeight )
    self.filter = function(item, other) return 'cross' end

    local actualX, actualY, cols, len = world:check(self, self.x, self.y, self.filter )
    for i,v in ipairs(cols) do

        if v.other.type == 'player' then
            v.other:collision( self.owner )
        end
    end
end

function SwordBad:update( dt )
end

function SwordBad:draw()
    GameObject.draw( self )
end

function SwordBad:update()

end

function SwordBad:createEffect( )
    se = {}
    if self.dir == 'right' then se.x = self.x+self.frameWidth se.y = self.y+self.frameHeight*0.5
    elseif self.dir == 'left' then se.x = self.x se.y = self.y+self.frameHeight*0.5
    elseif self.dir == 'down' then se.x = self.x+self.frameWidth*0.5 se.y = self.y+self.frameHeight
    elseif self.dir == 'up' then se.x = self.x+self.frameWidth*0.5 se.y = self.y
    end
    room:addObject( 'effect', EffectHit:new( se ))
end

return SwordBad
