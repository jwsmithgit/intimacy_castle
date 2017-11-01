local GameObject = require('modules/GameObject')
local Projectile = class('Projectile', GameObject)

local EffectHit = require('modules/EffectHit')

function Projectile:initialize( options )
    GameObject.initialize( self, options )

    self.owner = options.owner
    self.dir = self.owner.dir

    self.image = love.graphics.newImage('sprites/enemy.png')

    self.filter = function(item, other) return 'cross' end
end

function Projectile:update( dt )
    local movex, movey = 0, 0
    if self.dir == 'right' then movex = 1 end
    if self.dir == 'left' then movex = -1 end
    if self.dir == 'down' then movey = 1 end
    if self.dir == 'up' then movey = -1 end

    local x, y, cols, len = world:move(self, self.x + (self.speed * movex * dt), self.y + (self.speed * movey * dt), self.filter )
    for i,v in ipairs(cols) do
        if v.other.type == 'player' and self.type ~= 'magicgood' then
            self:createEffect()
            v.other:collision( self )

            room:removeObject( 'projectile', self )
            world:remove( self )
            self.owner.attack = nil
            return
        elseif v.other.type == 'enemy' and self.type == 'magicgood' then
            self:createEffect()
            v.other:collision( self )

            room:removeObject( 'projectile', self )
            world:remove( self )
            self.owner.attack = nil
            return
        elseif v.other.type == 'tile' then
            self:createEffect()

            room:removeObject( 'projectile', self )
            world:remove( self )
            self.owner.attack = nil
            return
        elseif v.other.type == nil then
            room:removeObject( 'projectile', self )
            world:remove( self )
            self.owner.attack = nil
            return
        end
    end

    self.x = x
    self.y = y
end

function Projectile:draw()
    GameObject.draw( self )
end

function Projectile:createEffect( )
    se = {}
    if self.dir == 'right' then se.x = self.x+self.frameWidth se.y = self.y+self.frameHeight*0.5
    elseif self.dir == 'left' then se.x = self.x se.y = self.y+self.frameHeight*0.5
    elseif self.dir == 'down' then se.x = self.x+self.frameWidth*0.5 se.y = self.y+self.frameHeight
    elseif self.dir == 'up' then se.x = self.x+self.frameWidth*0.5 se.y = self.y
    end
    room:addObject( 'effect', EffectHit:new( se ))
end

return Projectile
