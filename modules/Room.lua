local Room = class('Room')

local Sound = require('modules/Sound')

function Room:initialize( options )
    self.tile_size = 16
    self.width = game_width/self.tile_size --14
    self.height = game_height/self.tile_size --12

    self.minx = 1*self.tile_size
    self.maxx = self.width*self.tile_size - 1*self.tile_size
    self.miny = 1*self.tile_size
    self.maxy = self.height*self.tile_size - 3*self.tile_size

    self.image = love.graphics.newImage('sprites/tiles.png')
    local g = anim8.newGrid(self.tile_size, self.tile_size, self.image:getWidth(), self.image:getHeight())

    self.door_sound = love.audio.newSource('sounds/door.wav', 'static')

    self.tiles = {
        1,2,2,2,2,10,5,5,30,2,2,2,2,3,
        4,5,5,5,5,5,5,5,5,5,5,5,5,6,
        4,5,5,5,5,5,5,5,5,5,5,5,5,6,
        4,5,5,5,5,5,5,5,5,5,5,5,5,6,
        4,5,5,5,5,5,5,5,5,5,5,5,5,6,
        4,5,5,5,5,5,5,5,5,5,5,5,5,6,
        4,5,5,5,5,5,5,5,5,5,5,5,5,6,
        4,5,5,5,5,5,5,5,5,5,5,5,5,6,
        4,5,5,5,5,5,5,5,5,5,5,5,5,6,
        4,5,5,5,5,5,5,5,5,5,5,5,5,6,
        7,8,8,8,8,70,5,5,90,8,8,8,8,9,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    }

    self.to_enemies = options.enemies
    self.enemy_ps = {}
    for k,v in pairs(self.to_enemies) do
        self.enemy_ps[self.width*(v.y) + v.x+1] = 1
    end

    self:generateRocks()
    self:generateDirt()

    self.tile_images = {
        anim8.newAnimation(g(1,1), 1),
        anim8.newAnimation(g(2,1), 1),
        anim8.newAnimation(g(3,1), 1),
        anim8.newAnimation(g(1,2), 1),
        anim8.newAnimation(g(2,2), 1),
        anim8.newAnimation(g(3,2), 1),
        anim8.newAnimation(g(1,3), 1),
        anim8.newAnimation(g(2,3), 1),
        anim8.newAnimation(g(3,3), 1),
        [10] = anim8.newAnimation(g(4,1), 1),
        [30] = anim8.newAnimation(g(5,1), 1),
        [70] = anim8.newAnimation(g(4,2), 1),
        [90] = anim8.newAnimation(g(5,2), 1),
        [50] = anim8.newAnimation(g(1,4), 1),
        [51] = anim8.newAnimation(g(2,4), 1),
    }

    for i,v in ipairs(self.tiles) do
        if v ~= 5 and v~= 50 then
            world:add({type = 'tile', value = v}, self.tile_size*((i-1)%self.width), self.tile_size*(math.floor((i-1)/self.width)), self.tile_size, self.tile_size )
        end
    end

    local g = anim8.newGrid(self.tile_size*2, self.tile_size, self.image:getWidth(), self.image:getHeight(), 48, 32)
    self.doortop = {
        image = anim8.newAnimation(g('1-2',1), 1),
        x = self.tile_size*self.width/2-self.tile_size,
        y = 0,
        state = 'active',
        type = 'tile'
    }
    self.doorbottom = {
        image = anim8.newAnimation(g('1-2',2), 1),
        x = self.tile_size*self.width/2-self.tile_size,
        y = self.tile_size*self.height - self.tile_size*2,
        state = 'inactive',
        type = 'tile'
    }

    world:add( self.doortop, self.doortop.x, self.doortop.y, 2*self.tile_size, self.tile_size )

    world:add( 'top', -self.tile_size, -self.tile_size, self.tile_size*2 + self.tile_size*self.width, self.tile_size )
    world:add( 'bottom', -self.tile_size, self.tile_size*self.height + self.tile_size, self.tile_size*2 + self.tile_size*self.width, self.tile_size )

    self.players = {}
    self.enemies = {}
    self.projectiles = {}
    self.effects = {}

    self.spawned = false
    self.to_enemies = options.enemies

    self.done = false

end

function Room:update( dt )
    for k,v in pairs( self.players ) do v:update(dt) end
    for k,v in pairs( self.enemies ) do v:update(dt) end
    for k,v in pairs( self.projectiles ) do v:update(dt) end
    for k,v in pairs( self.effects ) do v:update(dt) end

    if self.spawned == false then
        local pin = {}
        for k,v in pairs( self.players ) do
            if v.y + v.frameHeight < self.tile_size*self.height - self.tile_size*2 then pin[k] = true else pin[k] = false end
        end

        local atrue = true
        for k,v in pairs(pin) do if v == false then atrue = false end end

        if atrue == true then
            for k,v in pairs(self.to_enemies) do
                self:addObject( 'enemy', _G[v.class]:new({x = v.x*self.tile_size, y = v.y*self.tile_size}) )
            end
            self.doorbottom.state = 'active'
            self.door_sound:play()
            world:add( self.doorbottom, self.doorbottom.x, self.doorbottom.y, 2*self.tile_size, self.tile_size )
            self.spawned = true
        end
    end

    if self.spawned == true and #self.enemies == 0 and self.done == false then
        self.doortop.state = 'inactive'
        self.door_sound:play()
        world:remove( self.doortop )

        world:add( 'exit', self.tile_size*self.width/2-self.tile_size, 0, 2*self.tile_size, 2 )
        self.done = true
    end

    if self.done == true then
        local x, y, cols, len = world:check( 'exit' )
        if #cols > 0 and cols[1].other.type == 'player' then
            --[[world:remove('top')
            world:remove('bottom')
            world:remove(self.doorbottom)
            world:remove('exit')
            for i,v in ipairs(self.tiles) do
                if v ~= 5 then
                    world:remove('tile'..i)
                end
            end]]
            for k,v in pairs(world.rects) do world:remove(k) end
            nextRoom()
        end
    end
end

function Room:draw()
    for i,v in ipairs(self.tiles) do
        if v ~= 0 then
            self.tile_images[v]:draw(self.image, self.tile_size*((i-1)%self.width), self.tile_size*(math.floor((i-1)/self.width)) )
        end
    end

    local visibles = self:sortVisibles()
    for k,v in pairs( visibles ) do v:draw() end

    if self.doortop.state == 'active' then self.doortop.image:draw(self.image, self.doortop.x, self.doortop.y ) end
    if self.doorbottom.state == 'active' then self.doorbottom.image:draw(self.image, self.doorbottom.x, self.doorbottom.y ) end

    for k,v in pairs( self.effects ) do v:draw() end
end

function Room:sortVisibles( )
    local visibles = {}
    local tground, tair = {}, {}

    for k,v in pairs(self.players) do table.insert(tground, v) end
    for k,v in pairs(self.enemies) do
        if v.air then table.insert(tair, v)
        else table.insert(tground, v)
        end
    end
    for k,v in pairs(self.projectiles) do table.insert(tground, v) end

    table.sort(tground, function(a,b) return a.y<b.y end)
    table.sort(tair, function(a,b) return a.y<b.y end)

    for k,v in pairs(tground) do table.insert( visibles, v ) end
    for k,v in pairs(tair) do table.insert( visibles, v ) end
    return visibles
end

function Room:addObject( type, object )
    local table_name = self:getTable( type )
    table.insert( table_name, object )
end

function Room:removeObject( type, object )
    local table_name = self:getTable( type )
    for i,v in ipairs( table_name ) do if v == object then table.remove( table_name, i ) end end
end

function Room:getTable( type )
    if type == 'player' then
        return self.players
    elseif type == 'enemy' then
        return self.enemies
    elseif type == 'effect' then
        return self.effects
    elseif type == 'projectile' then
        return self. projectiles
    end
end

function Room:playerDead( )
    for k,v in pairs(self.enemies) do
        v:chooseTarget()
    end
end

function Room:generateRocks( )
    for i,v in ipairs( self.tiles ) do
        if v == 5 and i > self.width and i < #self.tiles - 2*self.width and i ~= 21 and i ~= 22 and i ~= 133 and i ~= 134 and self.enemy_ps[i] ~= 1 then
            if math.random(100) <= 10 then
                self.tiles[i] = 51
            end
        end
    end
    local temp_tiles = {}
    for i,v in ipairs( self.tiles ) do
        if v == 5 and i > self.width and i < #self.tiles - 2*self.width and i ~= 21 and i ~= 22 and i ~= 133 and i ~= 134 and self.enemy_ps[i] ~= 1 then
            local chance = 0
            if self.tiles[i-1] == 51 then chance = chance + 50 end
            if self.tiles[i+1] == 51 then chance = chance + 50 end
            if self.tiles[i-self.width] == 51 then chance = chance + 50 end
            if self.tiles[i+self.width] == 51 then chance = chance + 50 end

            if math.random(100) <= chance then
                temp_tiles[i] = 51
            end
        end
    end
    for i,v in ipairs( temp_tiles ) do self.tiles[i] = v end
end

function Room:generateDirt( )
    local temp_tiles = {}
    for i,v in ipairs( self.tiles ) do
        if v == 5 then
            local chance = 0
            if self.tiles[i-1] == 51 then chance = chance + 80 end
            if self.tiles[i+1] == 51 then chance = chance + 80 end
            if self.tiles[i-self.width] == 51 then chance = chance + 80 end
            if self.tiles[i+self.width] == 51 then chance = chance + 80 end

            if math.random(100) <= chance then
                temp_tiles[i] = 50
            end
        end
    end

    --add randoms
    for i,v in ipairs( self.tiles ) do
        if v == 5 then
            if math.random(100) <= 20 then
                self.tiles[i] = 50
            end
        end
    end
    local temp_tiles = {}
    for i,v in ipairs( self.tiles ) do
        if v == 5 then
            local chance = 0
            if self.tiles[i-1] == 50 then chance = chance + 50 end
            if self.tiles[i+1] == 50 then chance = chance + 50 end
            if self.tiles[i-self.width] == 50 then chance = chance + 50 end
            if self.tiles[i+self.width] == 50 then chance = chance + 50 end

            if math.random(100) <= chance then
                temp_tiles[i] = 50
            end
        end
    end
    for i,v in ipairs( temp_tiles ) do self.tiles[i] = v end
end

return Room
