-- 游戏常量
local COLS = 10
local ROWS = 20
local CELL_SIZE = 30
local PREVIEW_SIZE = 4

-- 游戏状态
local grid = {}
local currentPiece = nil
local nextPiece = nil
local dropInterval = 0.5
local lastDropTime = 0
local score = 0
local highestScore = 0
local gameOver = false

-- 方块形状定义
local SHAPES = {
    {shape = {{1,1,1,1}}, color = {0,1,1}},           -- I
    {shape = {{1,1},{1,1}}, color = {1,1,0}},         -- O
    {shape = {{0,1,0},{1,1,1}}, color = {1,0,1}},     -- T
    {shape = {{1,0,0},{1,1,1}}, color = {1,0.65,0}},  -- L
    {shape = {{0,0,1},{1,1,1}}, color = {0,0,1}},     -- J
    {shape = {{1,1,0},{0,1,1}}, color = {0,1,0}},     -- S
    {shape = {{0,1,1},{1,1,0}}, color = {1,0,0}}      -- Z
}

-- 修改窗口大小，增加右侧预览区域的宽度
function love.load()
    -- 设置窗口标题
    love.window.setTitle("Tetris-of-Color")
    
    -- 设置窗口图标
    local icon = love.image.newImageData("icon.png")
    love.window.setIcon(icon)
    
    -- 设置窗口，增加右侧区域宽度
    love.window.setMode(COLS * CELL_SIZE + 160, ROWS * CELL_SIZE)
    
    -- 初始化游戏
    initGame()
end

function love.update(dt)
    if gameOver then return end
    
    lastDropTime = lastDropTime + dt
    if lastDropTime >= dropInterval then
        moveDown()
        lastDropTime = 0
    end
end

function love.draw()
    -- 绘制游戏区域边框
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 0, 0, COLS * CELL_SIZE, ROWS * CELL_SIZE)
    
    -- 绘制网格
    drawGrid()
    
    -- 绘制当前方块
    if currentPiece then
        drawPiece(currentPiece)
    end
    
    -- 绘制UI
    drawUI()
end

function love.keypressed(key)
    if gameOver then
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
    -- 初始化网格
    for x = 1, COLS do
        grid[x] = {}
        for y = 1, ROWS do
            grid[x][y] = nil
        end
    end
    
    gameOver = false
    score = 0
    currentPiece = createNewPiece()
    nextPiece = createNewPiece()
end

-- 修改 createNewPiece 函数
function createNewPiece()
    local pieceType = SHAPES[love.math.random(#SHAPES)]
    return {
        shape = pieceType.shape,
        color = pieceType.color,
        -- 修正初始位置计算
        x = math.floor(COLS/2) - math.floor(#pieceType.shape[1]/2) + 1,
        y = 1  -- 确保从顶部开始
    }
end

function moveHorizontal(dx)
    currentPiece.x = currentPiece.x + dx
    if checkCollision() then
        currentPiece.x = currentPiece.x - dx
    end
end

-- 修改 moveDown 函数
function moveDown()
    currentPiece.y = currentPiece.y + 1
    if checkCollision() then
        currentPiece.y = currentPiece.y - 1
        mergePiece()
        clearFullRows()
        currentPiece = nextPiece
        nextPiece = createNewPiece()
        -- 只有新方块一出现就发生碰撞时才结束游戏
        if currentPiece.y == 1 and checkCollision() then
            gameOver = true
            if score > highestScore then
                highestScore = score
            end
        end
    end
end

function hardDrop()
    while not checkCollision() do
        currentPiece.y = currentPiece.y + 1
    end
    currentPiece.y = currentPiece.y - 1
    moveDown()
end

function rotatePiece()
    local oldShape = currentPiece.shape
    local newShape = {}
    
    for y = 1, #oldShape[1] do
        newShape[y] = {}
        for x = 1, #oldShape do
            newShape[y][x] = oldShape[#oldShape - x + 1][y]
        end
    end
    
    currentPiece.shape = newShape
    if checkCollision() then
        currentPiece.shape = oldShape
    end
end

-- 修改 checkCollision 函数
function checkCollision()
    for y = 1, #currentPiece.shape do
        for x = 1, #currentPiece.shape[y] do
            if currentPiece.shape[y][x] == 1 then
                local worldX = currentPiece.x + x - 1
                local worldY = currentPiece.y + y - 1
                
                -- 检查边界和碰撞
                if worldX < 1 or worldX > COLS or
                   worldY < 1 or worldY > ROWS then
                    return true
                end
                
                -- 检查与其他方块的碰撞
                if worldY >= 1 and grid[worldX][worldY] then
                    return true
                end
            end
        end
    end
    return false
end

function mergePiece()
    for y = 1, #currentPiece.shape do
        for x = 1, #currentPiece.shape[y] do
            if currentPiece.shape[y][x] == 1 then
                local worldX = currentPiece.x + x - 1
                local worldY = currentPiece.y + y - 1
                grid[worldX][worldY] = currentPiece.color
            end
        end
    end
end

function clearFullRows()
    local rowsCleared = 0
    
    for y = ROWS, 1, -1 do
        local full = true
        for x = 1, COLS do
            if not grid[x][y] then
                full = false
                break
            end
        end
        
        if full then
            -- 移动上方行下来
            for moveY = y, 2, -1 do
                for x = 1, COLS do
                    grid[x][moveY] = grid[x][moveY-1]
                end
            end
            -- 清空顶行
            for x = 1, COLS do
                grid[x][1] = nil
            end
            rowsCleared = rowsCleared + 1
            y = y + 1  -- 重新检查当前行
        end
    end
    
    -- 计算分数
    if rowsCleared > 0 then
        score = score + (rowsCleared * 100) * rowsCleared  -- 连消奖励
    end
end

function drawGrid()
    for x = 1, COLS do
        for y = 1, ROWS do
            if grid[x][y] then
                love.graphics.setColor(grid[x][y])
                love.graphics.rectangle("fill", 
                    (x-1) * CELL_SIZE, 
                    (y-1) * CELL_SIZE, 
                    CELL_SIZE - 1, 
                    CELL_SIZE - 1)
            end
        end
    end
end

function drawPiece(piece)
    love.graphics.setColor(piece.color)
    for y = 1, #piece.shape do
        for x = 1, #piece.shape[y] do
            if piece.shape[y][x] == 1 then
                love.graphics.rectangle("fill",
                    (piece.x + x - 2) * CELL_SIZE,
                    (piece.y + y - 2) * CELL_SIZE,
                    CELL_SIZE - 1,
                    CELL_SIZE - 1)
            end
        end
    end
end

-- 修改 drawUI 函数
function drawUI()
    -- 绘制分数
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, COLS * CELL_SIZE + 20, 10)
    love.graphics.print("High Score: " .. highestScore, COLS * CELL_SIZE + 20, 30)
    
    -- 绘制下一个方块预览标题
    love.graphics.print("Next:", COLS * CELL_SIZE + 20, 40)
    
    -- 绘制下一个方块预览区域边框
    local previewBoxX = COLS * CELL_SIZE + 20
    local previewBoxY = 60
    
    love.graphics.rectangle("line", 
        previewBoxX, 
        previewBoxY, 
        PREVIEW_SIZE * CELL_SIZE, 
        PREVIEW_SIZE * CELL_SIZE
    )
    
    -- 计算预览方块的居中位置
    local previewCenterX = previewBoxX + (PREVIEW_SIZE * CELL_SIZE) / 2
    local previewCenterY = previewBoxY + (PREVIEW_SIZE * CELL_SIZE) / 2
    
    -- 根据方块大小计算偏移量
    local pieceWidth = #nextPiece.shape[1] * CELL_SIZE
    local pieceHeight = #nextPiece.shape * CELL_SIZE
    
    -- 计算最终位置（将方块绘制位置转换为网格坐标）
    local previewX = math.floor((previewCenterX - pieceWidth/2) / CELL_SIZE) + 1
    local previewY = math.floor((previewCenterY - pieceHeight/2) / CELL_SIZE) + 1
    
    -- 绘制预览方块
    local previewPiece = {
        shape = nextPiece.shape,
        color = nextPiece.color,
        x = previewX,
        y = previewY
    }
    drawPiece(previewPiece)
    
    -- 游戏结束提示
    if gameOver then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print(
            "Game Over!\nPress R to restart",
            COLS * CELL_SIZE + 20, 
            ROWS * CELL_SIZE - 100
        )
    end
end