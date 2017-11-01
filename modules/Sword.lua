local GameObject = require('modules/GameObject')
local Sword = class('Sword', GameObject)

local EffectHit = require('modules/EffectHit')

function Sword:initialize( options )
    GameObject.initialize( self, options )

    self.image = love.graphics.newImage('sprites/player.png')
    local g = nil
    self.owner = options.owner
    self.dir = self.owner.dir
    if self.dir == 'right' then
        self.x = self.x + 16
        self.y = self.y + 3
        self.height = 12
        self.width = 20
        g = anim8.newGrid(20, 12, self.image:getWidth(), self.image:getHeight(), 64, 16)
    elseif self.dir == 'left' then
        self.x = self.x - 20
        self.y = self.y + 3
        self.height = 12
        self.width = 20
        g = anim8.newGrid(20, 12, self.image:getWidth(), self.image:getHeight(), 64, 32)
    elseif self.dir == 'down' then
        self.y = self.y + 16
        self.x = self.x + 2
        self.height = 20
        self.width = 12
        g = anim8.newGrid(12, 20, self.image:getWidth(), self.image:getHeight(), 64, 48)
    elseif self.dir == 'up' then
        self.y = self.y - 20
        self.x = self.x + 1
        self.height = 20
        self.width = 12
        g = anim8.newGrid(12, 20, self.image:getWidth(), self.image:getHeight(), 80, 48)
    end

    self.animation = anim8.newAnimation(g(1,1), 1)
    self.type = 'swordgood'
    self.hit = options.hit or {}

    world:add( self, self.x, self.y, self.width, self.height )
    self.filter = function(item, other) return 'cross' end
end

function Sword:update( dt )
    local actualX, actualY, cols, len = world:check(self, self.x, self.y, self.filter )

    -- sword hit does not negate enemy hit
    for i,v in ipairs(cols) do
        local is_hit = false
        for j,w in ipairs(self.hit) do
            if v.other.type == 'swordbad' then
                if v.other.owner == w then is_hit = true end
            else
                if v.other == w then is_hit = true end
            end
        end
        if is_hit == false then
            if v.other.type == 'swordbad' then
                table.insert( self.hit, v.other.owner )
                self:createEffect()
                self.owner:swordCollision( v.other.owner )
                v.other.owner:swordCollision( self.owner )
            elseif v.other.type == 'enemy' then
                table.insert( self.hit, v.other )
                v.other:collision( self.owner )
            end
        end
    end
    -- sword hit negates enemy hit
    --[[
    local sword_hit = false
    for i,v in ipairs(cols) do
        local is_hit = false
        for j,w in ipairs(self.hit) do
            if v.other.type == 'swordbad' then
                if v.other.owner == w then is_hit = true end
            end
        end
        if is_hit == false and v.other.type == 'swordbad' then
            table.insert( self.hit, v.other.owner )
            self:createEffect()
            self.owner:swordCollision( v.other.owner )
            v.other.owner:swordCollision( self.owner )
        end
    end
    if sword_hit == false then
        for i,v in ipairs(cols) do
            local is_hit = false
            for j,w in ipairs(self.hit) do
                if v.other.type ~= 'swordbad' then
                    if v.other == w then is_hit = true end
                end
            end
            if is_hit == false and v.other.type == 'enemy' then
                table.insert( self.hit, v.other )
                v.other:collision( self.owner )
            end
        end
    end
    ]]
end

function Sword:draw()
    GameObject.draw( self )
end

function Sword:createEffect( )
    se = {}
    if self.dir == 'right' then se.x = self.x+self.frameWidth se.y = self.y+self.frameHeight*0.5
    elseif self.dir == 'left' then se.x = self.x se.y = self.y+self.frameHeight*0.5
    elseif self.dir == 'down' then se.x = self.x+self.frameWidth*0.5 se.y = self.y+self.frameHeight
    elseif self.dir == 'up' then se.x = self.x+self.frameWidth*0.5 se.y = self.y
    end
    room:addObject( 'effect', EffectHit:new( se ))
end

return Sword
