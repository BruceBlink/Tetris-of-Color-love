local grid = {}

function grid.create(COLS, ROWS)
    local newGrid = {}
    for x = 1, COLS do
        newGrid[x] = {}
        for y = 1, ROWS do
            newGrid[x][y] = nil
        end
    end
    return newGrid
end

function grid.checkCollision(piece, gameGrid, COLS, ROWS)
    for y = 1, #piece.shape do
        for x = 1, #piece.shape[y] do
            if piece.shape[y][x] == 1 then
                local worldX = piece.x + x - 1
                local worldY = piece.y + y - 1
                
                if worldX < 1 or worldX > COLS or
                   worldY < 1 or worldY > ROWS or
                   (worldY >= 1 and gameGrid[worldX][worldY]) then
                    return true
                end
            end
        end
    end
    return false
end

function grid.mergePiece(piece, gameGrid)
    for y = 1, #piece.shape do
        for x = 1, #piece.shape[y] do
            if piece.shape[y][x] == 1 then
                local worldX = piece.x + x - 1
                local worldY = piece.y + y - 1
                gameGrid[worldX][worldY] = piece.color
            end
        end
    end
end

function grid.clearFullRows(gameGrid, COLS, ROWS)
    local rowsCleared = 0
    
    for y = ROWS, 1, -1 do
        local full = true
        for x = 1, COLS do
            if not gameGrid[x][y] then
                full = false
                break
            end
        end
        
        if full then
            for moveY = y, 2, -1 do
                for x = 1, COLS do
                    gameGrid[x][moveY] = gameGrid[x][moveY-1]
                end
            end
            for x = 1, COLS do
                gameGrid[x][1] = nil
            end
            rowsCleared = rowsCleared + 1
            y = y + 1
        end
    end
    
    return rowsCleared
end

function grid.draw(gameGrid, COLS, ROWS, CELL_SIZE)
    for x = 1, COLS do
        for y = 1, ROWS do
            if gameGrid[x][y] then
                love.graphics.setColor(gameGrid[x][y])
                love.graphics.rectangle("fill", 
                    (x-1) * CELL_SIZE, 
                    (y-1) * CELL_SIZE, 
                    CELL_SIZE - 1, 
                    CELL_SIZE - 1)
            end
        end
    end
end

return grid