local GameObject = class('GameObject')

function GameObject:initialize( options )
    self.initial = deepcopy(data.object_default)
    for k,v in pairs( options ) do self.initial[k] = v end

    local meta = getmetatable(self)
    setmetatable(self.initial, meta)
    setmetatable( self, {__index=self.initial})
    local state = self.state
    if state ~= nil then
        setmetatable(self[state], {__index=self.initial})
        setmetatable(self, {__index=self[state]})
    end

    self.image = love.graphics.newImage( self.sprite )
end

function GameObject:update( dt )
end

function GameObject:draw( )
    self.animation:draw(self.image, math.floor(self.x), math.floor(self.y))
end

function GameObject:drawState( )
    self.animations[self.state]:draw(self.image, math.floor(self.x), math.floor(self.y) )
end

function GameObject:drawStateDir( )
    self.animations[self.state..self.dir]:draw(self.image, math.floor(self.x), math.floor(self.y) )
end

function GameObject:ox( )
    return self.x + self.frameWidth*self.alignx
end

function GameObject:oy( )
    return self.y + self.frameHeight*self.aligny
end

function GameObject:worldAdd()
    world:add( self, self.x+self.box, self.y+self.boy, 16-self.box*2, 16-self.boy*2 )
end

return GameObject
