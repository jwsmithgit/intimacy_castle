local GameObject = require('modules/GameObject')
local Enemy = class('Enemy', GameObject)

local EffectDeath = require('modules/EffectDeath')
local EffectSpawn = require('modules/EffectSpawn')

function Enemy:initialize( options )
    GameObject.initialize( self, options )

    self.speed = 1
    self.health = 1
    self.state_timer = 0
    self.target = room.players[math.random(#room.players)]

    self.image = love.graphics.newImage('sprites/enemy.png')

    self.hit_sound = love.audio.newSource("sounds/hit.wav", "static")

    room:addObject( 'effect', EffectSpawn:new( {x = self.x, y = self.y} ) )

    self.type = 'enemy'
    self.air = false
    self.filter = function(item, other)
        if other.type == 'player' then return 'slide'
        elseif other.type == 'enemy' and other.air == self.air then return 'slide'
        elseif other.type == 'enemy' then return 'cross'
        elseif other.type == 'swordgood' then return 'cross'
        elseif other.type == 'swordbad' then return 'cross'
        elseif other.type == 'arrow' then return 'cross'
        elseif other.type == 'magicgood' then return 'cross'
        elseif other.type == 'magicbad' then return 'cross'
        else return 'slide' end
    end
end

function Enemy:update( dt )
    if self.dir then
        self.animations[self.state..self.dir]:update(dt)
    else
        self.animations[self.state]:update(dt)
    end
end

function Enemy:draw()
    GameObject.draw( self )
end

function Enemy:changeState( state )
    self.state = state
    if self.bos and self.bos[self.state] then
        self.box = self.bos[state][1]
        self.boy = self.bos[state][2]
    end
    if self.state_times and self.state_times[self.state] then
        self:stateTimerReset()
    end
end

function Enemy:stateTimerReset( )
    if self.state == 'hurt' then
        self.state_timer = self.state_times[self.state]
    else
        self.state_timer = math.random( self.state_times[self.state]/2, self.state_times[self.state] )
    end
end

function Enemy:moveTowardsObject( dt, o )
    local dirx, diry = o:ox() - self:ox(), o:oy() - self:oy()
    local mag = math.sqrt( dirx^2 + diry^2 )
    local uv = 1/mag
    local movex, movey = self.speed*uv*dirx, self.speed*uv*diry

    local x, y, cols, len = world:move(self, self.x + self.box + movex*dt, self.y + self.boy + movey*dt, self.filter )
    self.x = x - self.box
    self.y = y - self.boy

    for i,v in ipairs(cols) do
        if v.other.type == 'player' then
            v.other:collision( self )
        end
    end
end

function Enemy:moveDirection( dt, dirx, diry )
    local mag = math.sqrt( dirx^2 + diry^2 )
    if math.abs(mag) < self.speed*dt then return end
    local uv = 1/mag
    local movex, movey = self.speed*uv*dirx, self.speed*uv*diry

    local x, y, cols, len = world:move(self, self.x + self.box + movex*dt, self.y + self.boy + movey*dt, self.filter )
    self.x = x - self.box
    self.y = y - self.boy

    for i,v in ipairs(cols) do
        if v.other.type == 'player' then
            v.other:collision( self )
        end
    end
end

function Enemy:collision( other )
    if self.state ~= 'hurt' then
        local dirx, diry = self:ox() - other:ox(), self:oy() - other:oy()
        local mag = math.sqrt( dirx^2 + diry^2 )
        local uv = 1/mag
        local movex, movey = 16*uv*dirx, 16*uv*diry

        local x, y, cols, len = world:move(self, self.x + self.box + movex, self.y + self.boy + movey, self.filter )
        self.x = x - self.box
        self.y = y - self.boy

        for i,v in ipairs(cols) do
            if v.other.type == 'enemy' and other.type == 'swordgood' then
                v.other:push(other)
            end
        end

        self.health = self.health - 1
        self:changeState('hurt')
        self.hit_sound:play()
        if self.health <= 0 then
            world:remove(self)
            room:addObject( 'effect', EffectDeath:new( {x = self.x, y = self.y} ) )
        end
    end
end

function Enemy:push( other )
    local dirx, diry = self:ox() - other:ox(), self:oy() - other:oy()
    local mag = math.sqrt( dirx^2 + diry^2 )
    local uv = 1/mag
    local movex, movey = 16*uv*dirx, 16*uv*diry

    local x, y, cols, len = world:move(self, self.x + self.box + movex, self.y + self.boy + movey, self.filter )
    self.x = x - self.box
    self.y = y - self.boy

    for i,v in ipairs(cols) do
        if v.other.type == 'enemy' then
            v.other:push(other)
        end
    end
end

function Enemy:chooseTarget( )
    if #room.players < 1 then
        self.state = 'idle'
        self.state_timer = 0
    else
        self.target = room.players[math.random(#room.players)]
    end
end

return Enemy
