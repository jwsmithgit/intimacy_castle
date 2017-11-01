local Intro = class('Intro')

function Intro:initialize()
    self.bg = {
        x = -48,
        y = -322,
        image = love.graphics.newImage('sprites/pixel_castle.png'),
    }

    self.text = {
        x = 16,
        y = 224,
        string =
        "You\n"..
        "\n"..
        "You did this\n"..
        "\n"..
        "You CHOSE this\n"..
        "\n"..
        "\n"..
        "\n"..
        "All that time\n"..
        "\n"..
        "All that planning\n"..
        "\n"..
        "You were so naive...\n"..
        "\n"..
        "\n"..
        "\n"..
        "Foolish\n"..
        "\n"..
        "\n"..
        "\n"..
        "Foolish little people.\n"..
        "\n"..
        "\n"..
        "\n"..
        "But how could you have known?\n"..
        "\n"..
        "\n"..
        "\n"..
        "You both really thought Pete just wanted you to see if that cloth smelled like chloroform, didn't you?\n"..
        "\n"..
        "How embarrassing\n"..
        "\n"..
        "\n"..
        "\n"..
        "\n"..
        "\n"..
        'Many a time have you heard the parables and folklore meant to serve as illustrations for how "Marriage is the true test".\n'..
        "\n"..
        "But only now, as you awaken below Int'Imacy Castle, do you realize that the trials they spoke of were far less figurative a thing.\n"..
        "\n"..
        "This structure, and the blood-soaked cobblestone and brain-smattered walls that lie beneath it, has stood for eons as the proving grounds of true commitment.\n"..
        "\n"..
        "Budgets? Bah.\n"..
        "\n"..
        "Chore wheels? Poppycock!\n"..
        "\n"..
        "Deciding who is to battle invading arachnids? PLEASE!\n"..
        "\n"..
        "They all pale in comparison when held against this place...\n"..
        "\n"..
        "Even the concept of a honeymoon is but a wicked strand in the Castles sinister design, for the idea itself is merely a red herring to cover for the newlyweds' deadly foray into the bowels of this damned place.\n"..
        "\n"..
        "\n"..
        "\n"..
        "But perhaps you are now hoping that this fate shall not befall you, hmm?\n"..
        "\n"..
        "That if you wait long enough\n"..
        "\n"..
        "And remain silent\n"..
        "\n"..
        "And hang on every word\n"..
        "\n"..
        "That I'll slip up\n"..
        "\n"..
        "And you'll slip out\n"..
        "\n"..
        "And your new life will begin with a charming little footnote of a daring escape and danger subverted\n"..
        "\n"..
        "No\n"..
        "\n"..
        "No\n"..
        "\n"..
        "I think not\n"..
        "\n"..
        "\n"..
        "\n"..
        "Julian of Stacey, First of his Name...\n"..
        "\n"..
        "The Jamie previously known as Goyman...\n"..
        "\n"..
        "Brave these depths of such cunning and virulent madness that only together will you keep your sanity...\n"..
        "\n"..
        "\n"..
        "\n"..
        "And your lives.\n"..
        "\n"..
        "\n"..
        "\n"..
        "\n"..
        "\n"..
        "Till death do us part indeed, my friends...\n"..
        "\n"..
        "\n"..
        "\n"..
        "Till death do us part..."
    }

    font = love.graphics.newImageFont( 'fonts/Imagefont.png',
        " abcdefghijklmnopqrstuvwxyz" ..
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
        "123456789.,!?-+/():;%&`'*#=[]\"" )

    love.graphics.setFont(font)
    self.timer = 0
end

function Intro:update( dt )
    if self.bg.y < -112 then
        self.bg.y = self.bg.y + 3*dt
    end

    if self.text.y > -2700 then
        self.text.y = self.text.y - 31*dt
        self.timer = self.timer + dt
    else
        musicin:stop()
        musictitle:play()
        transitioning = true
        nextstate =  'title'
    end
end

function Intro:draw()
    love.graphics.draw( self.bg.image, self.bg.x, self.bg.y )
    love.graphics.printf( self.text.string, self.text.x, self.text.y, game_width - 32, 'left' )
end

return Intro
