local Outro = class('Outro')

function Outro:initialize()
    self.bg = {
        x = -48,
        y = -322,
        image = love.graphics.newImage('sprites/transition.png'),
    }

    self.text = {
        x = 16,
        y = 224,
        string =
        "The last foe falls to your will and weapons\n"..
        "\n"..
        "\n"..
        "It is over\n"..
        "\n"..
        "\n"..
        "You have won\n"..
        "\n"..
        "\n"..
        "With hands trembling and eyes weary from a frantic and survival driven awareness, you both emerge from the depths to bear witness to a world that you had both agreed could not have truly ever existed.\n"..
        "\n"..
        "It had seemed so obvious at the time that it had been just a cruel and poisonous illusion, brought on by the madness inherent in the very stones of the Castle. You had let it all go, and filled the gaps with blood.\n"..
        "\n"..
        "\n"..
        "Your freedom is yours once again, and you have passed the most ancient and foolproof test of a union that is to ever exist.\n"..
        "\n"..
        "\n"..
        "The fog around your mind begins to clear and you embrace as the cool touch of sanity passes through you like a wave.\n"..
        "\n"..
        "\n"..
        "You had almost forgotten what it felt like to feel any certainty about the next moment\n"..
        "\n"..
        "It all seems so amusing now\n"..
        "\n"..
        "You try to laugh about it but only find you have forgotten what it sounds like\n"..
        "\n"..
        "\n"..
        "\n"..
        "Instead you scream\n"..
        "\n"..
        "\n"..
        "\n"..
        "Together\n"..
        "\n"..
        "\n"..
        "\n"..
        "\n"..
        "\n"..
        "Thanks for playing!\n"

    }

    font = love.graphics.newImageFont( 'fonts/Imagefont.png',
        " abcdefghijklmnopqrstuvwxyz" ..
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
        "123456789.,!?-+/():;%&`'*#=[]\"" )

    love.graphics.setFont(font)
    self.timer = 0
end

function Outro:update( dt )
    self.text.y = self.text.y - 16*dt
    if self.text.y < -1400 then
        love.event.quit()
    end
end

function Outro:draw()
    love.graphics.draw( self.bg.image, self.bg.x, self.bg.y )
    love.graphics.printf( self.text.string, self.text.x, self.text.y, game_width - 32, 'left' )
end

return Outro
