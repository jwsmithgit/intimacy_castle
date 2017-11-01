local Player = require('modules/Player')
local PlayerKnight = class('PlayerKnight', Player)

local Attack = require('modules/Sword')

function PlayerKnight:initialize( options )
    Player.initialize( self, options )

    self.attack = nil
    self.attack_sound = love.audio.newSource("sounds/sword.wav", "static")
    self.attack_cooldown = 0.4
    self.attack_timer = 0

    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 0, 16)
    self.animations = {
        standright = anim8.newAnimation(g(1,1), 1),
        standleft = anim8.newAnimation(g(1,2), 1),
        standdown = anim8.newAnimation(g(1,3), 1),
        standup = anim8.newAnimation(g(1,4), 1),

        walkright = anim8.newAnimation(g('1-2',1), 0.1),
        walkleft = anim8.newAnimation(g('1-2',2), 0.1),
        walkdown = anim8.newAnimation(g('1-2',3), 0.1),
        walkup = anim8.newAnimation(g('1-2',4), 0.1),

        attackright = anim8.newAnimation(g(3,1), 1),
        attackleft = anim8.newAnimation(g(3,2), 1),
        attackdown = anim8.newAnimation(g(3,3), 1),
        attackup = anim8.newAnimation(g(3,4), 1),

        hurtright = anim8.newAnimation(g(4,1, 1,1), 0.1),
        hurtleft = anim8.newAnimation(g(4,2, 1,2), 0.1),
        hurtdown = anim8.newAnimation(g(4,3, 1,3), 0.1),
        hurtup = anim8.newAnimation(g(4,4, 1,4), 0.1),
    }

end

function PlayerKnight:update( dt )
    Player.update( self, dt )
    if self.attack then self.attack:update( dt ) end

end

function PlayerKnight:draw( )
    if self.state == 'attack' and self.dir == 'up' then self.attack:draw( ) end

    self:drawStateDir( )

    if self.state == 'attack' and self.dir ~= 'up' then self.attack:draw( ) end
end

function PlayerKnight:deduceState( )
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
        self.attack = Attack:new( {x=self.x, y=self.y, owner=self} )
        self.attack_timer = self.attack_cooldown
    end
end

function PlayerKnight:endAttack( )
    --todo
    world:remove( self.attack )
    self.attack = nil

    for i,v in ipairs(self.input_table) do if v == 'attack' then table.remove( self.input_table, i ) end end
    self:deduceState()
end

function PlayerKnight:swordCollision( other )
    if self.state ~= 'hurt' and self.health.health > 0 then
        local dirx = self:ox() - other:ox()
        local diry = self:oy() - other:oy()
        local mag = math.sqrt( dirx^2 + diry^2 )
        local uv = 1/mag
        local x, y, cols, len = world:move(self, self.x+self.box+(16*uv*dirx), self.y+self.boy+(16*uv*diry), self.filter )
        self.x = x - self.box
        self.y = y - self.boy

        local hit = self.attack.hit
        if self.state == 'attack' then self:endAttack()
        else for i,v in ipairs(self.input_table) do if v == 'attack' then table.remove( self.input_table, i ) end end
        end
        self.attack_sound:play()
        self.state = 'attack'
        self.attack = Attack:new( {x=self.x, y=self.y, owner=self, hit = hit } )
        self.attack_timer = self.attack_cooldown/2
    end
end

return PlayerKnight
