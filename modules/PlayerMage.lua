local Player = require('modules/Player')
local PlayerMage = class('Player', Player)

local Magic = require('modules/MagicAirBend')

function PlayerMage:initialize( options )
    Player.initialize( self, options )

    self.attack = nil
    self.attack_sound = love.audio.newSource("sounds/magic.wav", "static")
    self.attack_cooldown = 0.3
    self.attack_timer = 0

    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.image:getWidth(), self.image:getHeight(), 0, 80)
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

function PlayerMage:update( dt )
    Player.update( self, dt )
end

function PlayerMage:draw( )
    self:drawStateDir( )
end

function PlayerMage:endAttack( )
    for i,v in ipairs(self.input_table) do if v == 'attack' then table.remove( self.input_table, i ) end end
    self:deduceState()
end

function PlayerMage:deduceState( )
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
        if self.attack ~= nil then
            self:endAttack()
        else
            self.state = 'attack'
            self.attack = Magic:new( {x=self.x, y=self.y, owner=self} )
            room:addObject( 'projectile', self.attack )
            self.attack_timer = self.attack_cooldown
        end
    end
end

return PlayerMage
