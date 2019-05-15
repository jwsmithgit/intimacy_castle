local modules, objects

function love.load()
    math.randomseed( os.time() )

    class = require 'lib/middleclass'
    anim8 = require 'lib/anim8'
    utils = require 'modules/Utilities'

    _local = {}
    _local.__index = _local
    setmetatable(_G, _local)
    local modules = {
        'Intro',
        'Title',
        'Room',
        'Outro',

        'PlayerKnight',
        'PlayerMage',

        'Bat',
        'Skeleton',
        'Slime',
        'Archer',
        'Knight',
        'Wizard'
    }
    for k,r in ipairs(modules) do
		_local[r] = require ('modules/' .. r)
	end

    game_width = 224
    game_height = 192

    data = {
        'object_default',
        'sound_default',
        'rooms'
    }
    for k,r in ipairs(data) do
		data[r] = require ('data/' .. r)
	end

    local bump = require 'lib/bump'
    world = bump.newWorld()

    canvas = love.graphics.newCanvas( game_width, game_height )
    canvas:setFilter('nearest')
    love.graphics.setDefaultFilter('nearest', 'nearest', 1)
    love.window.setMode( 0, 0, {fullscreen = true} )

    local screen_width = love.graphics.getWidth( )
    local screen_height = love.graphics.getHeight( )
    if( screen_width/game_width < screen_height/game_height ) then
        ratio = screen_width/game_width
    else
        ratio = screen_height/game_height
    end
    ratio = math.floor(ratio)
    offsetx = (screen_width - (game_width*ratio))/2
    offsety = (screen_height - (game_height*ratio))/2

    musicin = love.audio.newSource( 'sounds/intro.wav' )
    musicin:setLooping(true)
    musictitle = love.audio.newSource( 'sounds/title.wav' )
    musictitle:setLooping(true)
    musicdungeon = love.audio.newSource( 'sounds/dungeon.wav' )
    musicdungeon:setLooping(true)

    transition_img = love.graphics.newImage('sprites/transition.png')
    transition_alpha = 0
    transitioning = false
    transition_phase = 1
    transition_speed = 400

    intro = Intro:new( {} )
    title = Title:new( {} )
    room_i = 0
    outro = Outro:new( {} )

    state = 'intro'
    --nextRoom()
    musicin:play()

    players = {}
    joystick_players = {n=0}
    initializeJoysticks( players )
end

function love.update( dt )
    if transitioning == true and transition_phase == 1 then
        if transition_alpha < 255 then transition_alpha = transition_alpha + transition_speed*dt end
        if transition_alpha >= 255 then
            transition_alpha = 255
            transition_phase = 2
            if state == nextstate and state == 'room' then nextRoom() end
            state = nextstate
        end
    elseif transitioning == true and transition_phase == 2 then
        if transition_alpha > 0 then transition_alpha = transition_alpha - transition_speed*dt end
        if transition_alpha <= 0 then
            transition_alpha = 0
            transition_phase = 1
            transitioning = false
        end
    elseif state == 'intro' then
        intro:update( dt )
    elseif state == 'title' then
        title:update( dt )
    elseif state == 'room' then
        room:update( dt )
    elseif state == 'outro' then
        outro:update( dt )
    end
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear( )

    if state == 'intro' then
        intro:draw( )
    elseif state == 'title' then
        title:draw( )
    elseif state == 'room' then
        room:draw()
    elseif state == 'outro' then
        outro:draw()
    end

    if transitioning == true then
        local r,g,b,a = love.graphics.getColor( )
        love.graphics.setColor( r, g, b, transition_alpha )
        love.graphics.draw( transition_img )
        love.graphics.setColor( r, g, b, a )
    end

    love.graphics.setCanvas()
    love.graphics.draw( canvas, offsetx, offsety, 0, ratio, ratio )
end

function nextRoom( )
    room_i = room_i + 1
    if room_i > #data.rooms then
        musicdungeon:stop()
        musictitle:play()
        transitioning = true
        nextstate =  'outro'
    else
        room = Room:new( {enemies=data.rooms[room_i].enemies} )

        --if #players < 1 then table.insert( players, PlayerKnight:new({ p = 1, x = game_width/2 - 16, y = game_height - 32}) ) end
        --if #players < 2 then table.insert( players, PlayerMage:new({ p = 2, x = game_width/2, y = game_height - 32}) ) end
        --players[1].x, players[1].y = game_width/2 - 16, game_height - 32
        --players[2].x, players[2].y = game_width/2, game_height - 32

        players[1] = PlayerKnight:new({ p = 1, x = game_width/2 - 16, y = game_height - 32 })
        players[2] = PlayerMage:new({ p = 2, x = game_width/2, y = game_height - 32 })

        room:addObject( 'player', players[1] )
        room:addObject( 'effect', players[1].health )

        room:addObject( 'player', players[2] )
        room:addObject( 'effect', players[2].health )

        if room_i == 1 then
            musicdungeon:play()
        elseif room_i == 3 then
        elseif room_i == 5 then
        end
    end

end

function love.keypressed(key)
    if state == 'room' and transitioning == false then
        if key == '0' then
            room_i = room_i
            for k,v in pairs(world.rects) do world:remove(k) end
            --nextRoom()
            transitioning = true
        elseif key == 'space' then
            room_i = room_i - 1
            for k,v in pairs(world.rects) do world:remove(k) end
            --nextRoom()
            transitioning = true
        end
        if joystick_players.n <= 1 and room.players[1] then room.players[1]:keyPressed( key ) end
        if joystick_players.n == 0 and room.players[2] then room.players[2]:keyPressed( key ) end
    end
    if key == 'escape' then
        love.event.quit()
    end
end

function love.keyreleased(key)
    if transitioning == false then
        if state == 'intro' then
            musicin:stop()
            musictitle:play()
            transitioning = true
            nextstate =  'title'
        elseif state == 'title' then
            musictitle:stop()
            nextRoom()
            transitioning = true
            nextstate = 'room'
        elseif state == 'room' then
            if #room.players == 0 then
                room_i = room_i - 1
                for k,v in pairs(world.rects) do world:remove(k) end
                --nextRoom()
                transitioning = true
            end
            if joystick_players.n <= 1 and room.players[1] then room.players[1]:keyReleased( key ) end
            if joystick_players.n == 0 and room.players[2] then room.players[2]:keyReleased( key ) end
        end
    end
end

function love.gamepadpressed( joystick, button )
    if state == 'room' and transitioning == false then
        players[joystick_players[joystick]]:joystickPressed(button)
    end
end

function love.gamepadreleased( joystick, button )
    if transitioning == false then
        if state == 'intro' then
            musicin:stop()
            musictitle:play()
            transitioning = true
            nextstate =  'title'
        elseif state == 'title' then
            musictitle:stop()
            nextRoom()
            transitioning = true
            nextstate = 'room'
        elseif state == 'room' then
            if #room.players == 0 then
                room_i = room_i - 1
                for k,v in pairs(world.rects) do world:remove(k) end
                --nextRoom()
                transitioning = true
            end
            players[joystick_players[joystick]]:joystickReleased(button)
        end
    end
end

function initializeJoysticks( players )
    joysticks = love.joystick.getJoysticks()
    for i, joystick in ipairs(joysticks) do
        createJoystickMap( joystick )
        if i == 2 then
            joystick_players[joystick] = 1
            joystick_players.n = 2
        elseif i == 1 then
            joystick_players[joystick] = 2
            joystick_players.n = 1
        else
            break
        end
    end
end

function createJoystickMap( joystick )
    print( joystick:getName() )
    love.joystick.setGamepadMapping( joystick:getGUID( ), 'a', 'button', 2, nil )
    love.joystick.setGamepadMapping( joystick:getGUID( ), 'dpright', 'hat', 1, 'r' )
    love.joystick.setGamepadMapping( joystick:getGUID( ), 'dpleft', 'hat', 1, 'l' )
    love.joystick.setGamepadMapping( joystick:getGUID( ), 'dpup', 'hat', 1, 'u' )
    love.joystick.setGamepadMapping( joystick:getGUID( ), 'dpdown', 'hat', 1, 'd' )
end

function deepcopy(t, cache)
    if type(t) ~= 'table' then
        return t
    end

    cache = cache or {}
    if cache[t] then
        return cache[t]
    end

    local new = {}

    cache[t] = new

    for key, value in pairs(t) do
        new[deepcopy(key, cache)] = deepcopy(value, cache)
    end

    return new
end

function generateRooms( )
    local rooms = 50
    rooms = {}
    for i=1,rooms do
        local room = {}

    end
end
