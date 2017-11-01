local Projectile = require('modules/Projectile')
local MagicAirBend = class('MagicAirBend', Projectile)

function MagicAirBend:initialize( options )
    Projectile.initialize( self, options )

    self.type = 'magicgood'

    self.speed = 120
    self.bend_accel = 3
    self.bend_speed = 0
    self.magic_sound = love.audio.newSource("sounds/magic.wav", "static")
    self.magic_sound:play()

    self:FindTarget()

    if self.dir == 'right' then
        self.x = self.x + 4
        self.y = self.y + 4
    elseif self.dir == 'left' then
        self.x = self.x - 4
        self.y = self.y + 4
    elseif self.dir == 'down' then
        self.x = self.x + 4
        self.y = self.y + 4
    elseif self.dir == 'up' then
        self.x = self.x + 2
        self.y = self.y - 4
    end

    self.frameWidth = 10
    self.frameHeight = 10

    self.image = love.graphics.newImage('sprites/player.png')
    g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 64, 80)
    self.animation = anim8.newAnimation(g(1,'1-2'), 0.1)

    world:add( self, self.x, self.y, self.frameWidth, self.frameHeight )
end

function MagicAirBend:update( dt )
    self.animation:update(dt)

    if self.target ~= nil then
        self:moveTowardsObject( dt, self.target )
    end
    Projectile.update( self, dt )

end

function MagicAirBend:draw( )
    Projectile.draw( self )
end

function MagicAirBend:FindTarget()
    local heur = {}
    for k,v in pairs( room.enemies ) do
        if self.dir == 'right' and v:ox() > self.owner:ox() then
            --print(math.abs(math.atan( (v:oy()-self.owner:oy()) / (v:ox()-self.owner:ox()) )) *180/math.pi)
            if math.abs(math.atan( (v:oy()-self.owner:oy()) / (v:ox()-self.owner:ox()) )) *180/math.pi < 30 then
                table.insert( heur, v )
            end
        elseif self.dir == 'left' and v:ox() < self.owner:ox() then
            --print(math.abs(math.atan( (v:oy()-self.owner:oy()) / (v:ox()-self.owner:ox()) )) *180/math.pi)
            if math.abs(math.atan( (v:oy()-self.owner:oy()) / (v:ox()-self.owner:ox()) )) *180/math.pi < 30 then
                table.insert( heur, v )
            end
        elseif self.dir == 'down' and v:oy() > self.owner:oy() then
            --print(math.abs(math.atan( (v:ox()-self.owner:ox()) / (v:oy()-self.owner:oy()) )) *180/math.pi)
            if math.abs(math.atan( (v:ox()-self.owner:ox()) / (v:oy()-self.owner:oy()) )) *180/math.pi < 30 then
                table.insert( heur, v )
            end
        elseif self.dir == 'up' and v:oy() < self.owner:oy() then
            --print(math.abs(math.atan( (v:ox()-self.owner:ox()) / (v:oy()-self.owner:oy()) )) *180/math.pi)
            if math.abs(math.atan( (v:ox()-self.owner:ox()) / (v:oy()-self.owner:oy()) )) *180/math.pi < 30 then
                table.insert( heur, v )
            end
        end
    end

    if #heur > 0 then
        comparex = function(a,b) return a.x < b.x end
        comparey = function(a,b) return a.y < b.y end
        if self.dir == 'right' or self.dir == 'left' then
            table.sort( heur, comparex )
        elseif self.dir == 'down' or self.dir == 'up' then
            table.sort( heur, comparey )
        end
        self.target = heur[1]
    else
        self.target = nil
    end
end

function MagicAirBend:moveTowardsObject( dt, o )
    local dirx, diry = o:ox() - self:ox(), o:oy() - self:oy()
    local movex, movey = 0, 0
    if self.dir == 'down' or self.dir == 'up' then
        movex = 1
        if dirx > 0 then self.bend_speed = self.bend_speed + self.bend_accel
        elseif dirx < 0 then self.bend_speed = self.bend_speed - self.bend_accel
        end
    elseif self.dir == 'right' or self.dir == 'left' then
        movey = 1
        if diry > 0 then self.bend_speed = self.bend_speed + self.bend_accel
        elseif diry < 0 then self.bend_speed = self.bend_speed - self.bend_accel
        end
    end

    local x, y, cols, len = world:move(self, self.x + self.box + (movex*self.bend_speed)*dt, self.y + self.boy + (movey*self.bend_speed)*dt, self.filter )
    self.x = x - self.box
    self.y = y - self.boy
end

return MagicAirBend
