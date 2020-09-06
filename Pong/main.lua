Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200



function love.load()
    
    math.randomseed(os.time())

    love.window.setTitle('Pong')

    love.graphics.setDefaultFilter('nearest', 'nearest')
    
    smallfont = love.graphics.newFont('font.ttf', 8)
    scorefont = love.graphics.newFont('font.ttf', 32)

    sounds  = {
        ['paddle'] = love.audio.newSource('paddlesound.wav', 'static'),
        ['point'] = love.audio.newSource('point.wav', 'static'),
        ['start'] = love.audio.newSource('start.wav', 'static'),
        ['win'] = love.audio.newSource('win.wav', 'static') 
    }

    sounds['start']:play()
    player1Score = 0
    player2Score = 0

    servingPlayer = math.random(2) == 1 and 1 or 2

    winningPlayer = 0


    paddle1 = Paddle(30, 20, 5, 20)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    ball = Ball(VIRTUAL_WIDTH /2 -2, VIRTUAL_HEIGHT /2 - 2, 5, 5)

    gameState = 'start'




    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)

    if gameState == 'play' then

        if ball.x <= 0 then
            sounds['point']:play()
            player2Score = player2Score + 1
            servingPlayer = 1
            ball:reset()

            if player2Score >= 5 then
                sounds['win']:play()
                gameState = 'victory'
                winningPlayer = 2
                player1Score = 0
                player2Score = 0
            else
            ball.dx = 100
            gameState = 'serve'
            end
        end

        if ball.x >= VIRTUAL_WIDTH - 4 then
            sounds['point']:play()
            player1Score = player1Score + 1
            servingPlayer = 2
            ball:reset()

            if player1Score >= 5 then
                sounds['win']:play()
                gameState = 'victory'
                winningPlayer = 1
                player1Score = 0
                player2Score = 0
            else
            ball.dx = -100
            gameState = 'serve'
            end
        end
    end

    paddle1:update(dt)
    paddle2:update(dt)

    if ball:collides(paddle1) then
        ball.dx = -ball.dx * 1.06
        ball.x = paddle1.x + 5

        -- keep velocity going in the same direction, but randomize it
        if ball.dy < 0 then
            ball.dy = -math.random(10, 150)
        else
            ball.dy = math.random(10, 150)
        end

        sounds['paddle']:play()
    end

    if ball:collides(paddle2) then
        ball.dx = -ball.dx * 1.06
        ball.x = paddle2.x + - 4

        -- keep velocity going in the same direction, but randomize it
        if ball.dy < 0 then
            ball.dy = -math.random(10, 150)
        else
            ball.dy = math.random(10, 150)
        end

        sounds['paddle']:play()
    end

    if ball.y <= 0 then
        ball.dy = -ball.dy
        ball.y = 0
        sounds['paddle']:play()
    end

    if ball.y >= VIRTUAL_HEIGHT  - 4 then
        ball.dy = -ball.dy
        ball.y = VIRTUAL_HEIGHT - 4
        sounds['paddle']:play()
    end


    if love.keyboard.isDown('w') then
        paddle1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        paddle1.dy = PADDLE_SPEED
    else 
        paddle1.dy = 0
    end
    if love.keyboard.isDown('up') then
        paddle2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        paddle2.dy = PADDLE_SPEED
    else 
        paddle2.dy = 0
    end

    if gameState == 'play' then
       ball:update(dt) 
    end

end


function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        elseif gameState == 'victory' then
            gameState = 'start'
        elseif gameState == 'serve' then
            gameState = 'play'
        end
    end
end

function love.draw()
    push:apply('start')

    -- color scheme background
    love.graphics.clear(40 /255, 45 / 255, 52 / 255, 255 / 255)
    
    love.graphics.setFont(smallfont)

    

    if gameState == 'start' then
        love.graphics.setFont(smallfont)
        love.graphics.printf('Lets play some Pong, motherfucker!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press "enter" to play', 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallfont)
        love.graphics.printf("In your face! Player " .. tostring(servingPlayer) .. "'s turn!", 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(smallfont)
        love.graphics.printf("Player " .. tostring(winningPlayer) .. "wins!! Booyah!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallfont)
        love.graphics.printf('Press "enter" to play again or "escape" to quit', 0, 32, VIRTUAL_WIDTH, 'center')
    end

    -- score
    love.graphics.setFont(scorefont)
    love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3 )
    love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3 )

    paddle1:render()
    paddle2:render()
    ball:render()

    displayFPS()

     push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 1, 1)
    love.graphics.setFont(smallfont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)
end

