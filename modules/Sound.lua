local Sound = class('sound')

function Sound:initialize( options )
    if type(options) == 'string' then options = {sound = s} end

    local defaults = dofile('data/sound_default.lua')
    for k,v in pairs( defaults ) do self[k] = v end
    for k,v in pairs( options ) do self[k] = v end

    self.source = love.audio.newSource(self.sound)

    self.source:setLooping( self.loop )
    if self.loop_delay > 0 then self.source:setLooping( false ) end

    self.timer = 0
    if self.delay > 0 then
        self.timer = self.delay
    else
        self.source:play()
    end
end

function Sound:update( dt )
    if self.loop_delay > 0 and self.source:isPlaying() == false and self.timer <= 0 then
        self.timer = self.loop_delay
    end

    if self.timer > 0 then self.timer = self.timer - dt end
    if self.timer <= 0 then
        self.timer = 0
        self.source:play()
    end
end

function Sound:draw( )
end

return Sound
