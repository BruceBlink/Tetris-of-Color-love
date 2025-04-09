-- 导入模块
local constants = require 'modules.constants'
local piece = require 'modules.piece'
local grid = require 'modules.grid'
local game = require 'modules.game'
local ui = require 'modules.ui'

-- 游戏状态
local gameGrid = {}
local currentPiece = nil
local nextPiece = nil

function love.load()
    -- 设置窗口
    love.window.setTitle("Tetris-of-Color")
    local icon = love.image.newImageData("icon.png")
    love.window.setIcon(icon)
    love.window.setMode(
        constants.COLS * constants.CELL_SIZE + 200, 
        constants.ROWS * constants.CELL_SIZE
    )
    
    initGame()
end

function love.update(dt)
    if game.gameOver then return end
    
    game.lastDropTime = game.lastDropTime + dt
    if game.lastDropTime >= constants.DROP_INTERVAL then
        moveDown()
        game.lastDropTime = 0
    end
end

function love.draw()
    -- 绘制游戏区域边框
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 0, 0, 
        constants.COLS * constants.CELL_SIZE, 
        constants.ROWS * constants.CELL_SIZE
    )
    
    -- 绘制网格和方块
    grid.draw(gameGrid, constants.COLS, constants.ROWS, constants.CELL_SIZE)
    if currentPiece then
        piece.draw(currentPiece, constants.CELL_SIZE)
    end
    
    -- 绘制UI
    ui.drawScore(game.score, game.highestScore, constants.COLS, constants.CELL_SIZE)
    local previewPiece = ui.drawPreview(nextPiece, constants.COLS, constants.CELL_SIZE, constants.PREVIEW_SIZE)
    piece.draw(previewPiece, constants.CELL_SIZE)
    
    if game.gameOver then
        ui.drawGameOver(constants.COLS, constants.ROWS, constants.CELL_SIZE)
    end
end

function love.keypressed(key)
    if game.gameOver then
        if key == "r" then
            initGame()
            return
        end
    end
    
    if key == "left" then
        moveHorizontal(-1)
    elseif key == "right" then
        moveHorizontal(1)
    elseif key == "down" then
        moveDown()
    elseif key == "up" then
        rotatePiece()
    elseif key == "space" then
        hardDrop()
    end
end

function initGame()
    gameGrid = grid.create(constants.COLS, constants.ROWS)
    game.gameOver = false
    game.score = 0
    currentPiece = piece.createNew(constants.COLS)
    nextPiece = piece.createNew(constants.COLS)
end

function moveHorizontal(dx)
    currentPiece.x = currentPiece.x + dx
    if grid.checkCollision(currentPiece, gameGrid, constants.COLS, constants.ROWS) then
        currentPiece.x = currentPiece.x - dx
    end
end

function moveDown()
    currentPiece.y = currentPiece.y + 1
    if grid.checkCollision(currentPiece, gameGrid, constants.COLS, constants.ROWS) then
        currentPiece.y = currentPiece.y - 1
        grid.mergePiece(currentPiece, gameGrid)
        local rowsCleared = grid.clearFullRows(gameGrid, constants.COLS, constants.ROWS)
        game.score = game.score + game.calculateScore(rowsCleared)
        game.updateHighScore()
        
        currentPiece = nextPiece
        nextPiece = piece.createNew(constants.COLS)
        
        if grid.checkCollision(currentPiece, gameGrid, constants.COLS, constants.ROWS) then
            game.gameOver = true
        end
    end
end

function hardDrop()
    while not grid.checkCollision(currentPiece, gameGrid, constants.COLS, constants.ROWS) do
        currentPiece.y = currentPiece.y + 1
    end
    currentPiece.y = currentPiece.y - 1
    moveDown()
end

function rotatePiece()
    local newShape = piece.rotate(currentPiece)
    local oldShape = currentPiece.shape
    currentPiece.shape = newShape
    
    if grid.checkCollision(currentPiece, gameGrid, constants.COLS, constants.ROWS) then
        currentPiece.shape = oldShape
    end
end