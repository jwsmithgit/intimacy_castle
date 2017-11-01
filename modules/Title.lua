local Title = class('Title')

function Title:initialize()
    self.title = {
        x = 0,
        y = 0,
        image = love.graphics.newImage( 'sprites/title.png' )
    }
    self.start = {
        x = 0,
        y = game_height*0.75,
        string = 'press button to start',
        visible = 1
    }

    font = love.graphics.newImageFont( 'fonts/Imagefont.png',
        " abcdefghijklmnopqrstuvwxyz" ..
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
        "123456789.,!?-+/():;%&`'*#=[]\"" )

    love.graphics.setFont(font)
    self.show_time = 0.8
    self.show_timer = self.show_time


end

function Title:update( dt )
    if self.show_timer > 0 then self.show_timer = self.show_timer - dt end
    if self.show_timer <= 0 then
        self.show_timer = 1
        self.start.visible = (self.start.visible + 1 ) % 2
    end
end

function Title:draw()
    love.graphics.draw( self.title.image, self.title.x, self.title.y )
    if self.start.visible == 1 then love.graphics.printf( self.start.string, self.start.x, self.start.y, game_width, 'center'  ) end
end

return Title
