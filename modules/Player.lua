local GameObject = require('modules/GameObject')
local Player = class('Player', GameObject)

local Sword = require('modules/Sword')
local EffectDeath = require('modules/EffectDeath')

local Health = require('modules/Health')

function Player:initialize( options )
    GameObject.initialize( self, options )

    self.type = 'player'
    self.player = options.p
    self.state = 'stand'
    self.dir = 'up'

    self.speed = 60
    self.health = Health:new( {player = self.player} )

    self.hurt_cooldown = 0.2
    self.hurt_timer = 0

    self.hit_sound = love.audio.newSource("sounds/hit.wav", "static")
    self.death_sound = love.audio.newSource('sounds/dead.wav', 'static')

    self.box = 1
    self.boy = 1

    self.image = love.graphics.newImage('sprites/player.png')

    self.joystick_map = {
        dpright = 'right',
        dpleft = 'left',
        dpdown = 'down',
        dpup = 'up',
        a = 'attack'
    }
    self.keyboard_map = {
        d = 'right',
        a = 'left',
        s = 'down',
        w = 'up',
        j = 'attack'
    }
    self.input_table = {}

    world:add( self, self.x+self.box, self.y+self.boy, 16-self.box*2, 16-self.boy*2 )
    self.filter = function(item, other)
        if other.type == 'player' then return 'slide'
        elseif other.type == 'enemy' then return 'slide'
        elseif other.type == 'swordgood' then return 'cross'
        elseif other.type == 'swordbad' then return 'cross'
        elseif other.type == 'arrow' then return 'cross'
        elseif other.type == 'magicgood' then return 'cross'
        elseif other.type == 'magicbad' then return 'cross'
        elseif other == 'exit' then return 'cross'
        else return 'slide' end
    end
end

function Player:update( dt )
    self.animations[self.state..self.dir]:update(dt)

    if self.state == 'walk' then
        local movex, movey = 0, 0
        if self.dir == 'right' then
            movex = 1
            if self.input_table[ #self.input_table-1 ] == 'down' then movex = 0.7 movey = 0.7 end
            if self.input_table[ #self.input_table-1 ] == 'up' then movex = 0.7 movey = -0.7 end
        end
        if self.dir == 'left' then
            movex = -1
            if self.input_table[ #self.input_table-1 ] == 'down' then movex = -0.7 movey = 0.7 end
            if self.input_table[ #self.input_table-1 ] == 'up' then movex = -0.7 movey = -0.7 end
        end
        if self.dir == 'down' then
            movey = 1
            if self.input_table[ #self.input_table-1 ] == 'right' then movex = 0.7 movey = 0.7 end
            if self.input_table[ #self.input_table-1 ] == 'left' then movex = -0.7 movey = 0.7 end
        end
        if self.dir == 'up' then
            movey = -1
            if self.input_table[ #self.input_table-1 ] == 'right' then movex = 0.7 movey = -0.7 end
            if self.input_table[ #self.input_table-1 ] == 'left' then movex = -0.7 movey = -0.7 end
        end
        local x, y, cols, len = world:move(self, self.x+self.box+(self.speed*movex)*dt, self.y+self.boy+(self.speed*movey)*dt, self.filter )
        self.x = x - self.box
        self.y = y - self.boy

    elseif self.state == 'attack' then
        self.attack_timer = self.attack_timer - dt
        if self.attack_timer <= 0 then
            self:endAttack()
        end

    elseif self.state == 'hurt' then
        self.hurt_timer = self.hurt_timer - dt
        if self.hurt_timer <= 0 then
            if self.health.health <= 0 then
                self.death_sound:play()
                if self.attack ~= nil then endattack() end
                room:removeObject( 'player', self )
                world:remove( self )
                room:playerDead()
            end
            self:deduceState()
        end
    end
end

function Player:draw( )
    self:drawStateDir( )
end

function Player:keyPressed( button )
    self:parsePressed( self.keyboard_map[button] )
end

function Player:keyReleased( button )
    self:parseReleased( self.keyboard_map[button] )
end

function Player:joystickPressed( button )
    self:parsePressed( self.joystick_map[button] )
end

function Player:joystickReleased( button )
    self:parseReleased( self.joystick_map[button] )
end

function Player:parsePressed( input )
    if not input then return end
    for i,v in ipairs(self.input_table) do if v == input then table.remove( self.input_table, i ) end end
    table.insert( self.input_table, input )
    if self.state ~= 'attack' and self.state ~= 'hurt' then self:deduceState() end
end

function Player:parseReleased( input )
    if not input or input == 'attack' then return end
    for i,v in ipairs(self.input_table) do if v == input then table.remove( self.input_table, i ) end end
    if self.state ~= 'attack' and self.state ~= 'hurt' then self:deduceState() end
end

function Player:deduceState( )
    if #self.input_table == 0 then self.state = 'stand' return end

    local input = self.input_table[ #self.input_table ]
    if input == 'up' then
        self.state = 'walk'
        self.dir = 'up'
    elseif input == 'down' then
        self.state = 'walk'
        self.dir = 'down'
    elseif input == 'left' then
        self.state = 'walk'
        self.dir = 'left'
    elseif input == 'right' then
        self.state = 'walk'
        self.dir = 'right'
    elseif input == 'attack' then
        self.state = 'attack'
        self.attack = Attack:new( {x=self.x, y=self.y, dir=self.dir, owner=self} )
        self.attack_timer = self.attack_cooldown
    end
end

function Player:collision( other )
    if self.state ~= 'hurt' then
        local dirx = self:ox() - other:ox()
        local diry = self:oy() - other:oy()
        local mag = math.sqrt( dirx^2 + diry^2 )
        local uv = 1/mag
        local x, y, cols, len = world:move(self, self.x+self.box+(16*uv*dirx), self.y+self.boy+(16*uv*diry), self.filter )
        self.x = x - self.box
        self.y = y - self.boy

        if self.state == 'attack' then self:endAttack()
        else for i,v in ipairs(self.input_table) do if v == 'attack' then table.remove( self.input_table, i ) end end
        end

        self.state = 'hurt'
        self.hurt_timer = self.hurt_cooldown

        self.health:hurt()
        self.hit_sound:play()
        if self.health.health <= 0 then
            room:addObject( 'effect', EffectDeath:new( {x = self.x, y = self.y} ) )
        end
    end
end

function Player:swordCollision( other )
    local dirx = self:ox() - other:ox()
    local diry = self:oy() - other:oy()
    local mag = math.sqrjjt( dirx^2 + diry^2 )
    local uv = 1/mag
    local x, y, cols, len = world:move(self, self.x+self.box+(16*uv*dirx), self.y+self.boy+(16*uv*diry), self.filter )
    self.x = x - self.box
    self.y = y - self.boy

    if self.state == 'attack' then self:endAttack()
    else for i,v in ipairs(self.input_table) do if v == 'attack' then table.remove( self.input_table, i ) end end
    end
    self.attack_sound:play()
    self.state = 'attack'
    self.attack = Sword:new( {x=self.x, y=self.y, owner=self} )
    self.attack_timer = self.attack_cooldown
end

return Player
