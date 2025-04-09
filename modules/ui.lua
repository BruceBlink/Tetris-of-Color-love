local ui = {}

function ui.drawScore(score, highestScore, COLS, CELL_SIZE)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, COLS * CELL_SIZE + 20, 10)
    love.graphics.print("High Score: " .. highestScore, COLS * CELL_SIZE + 20, 30)
end

function ui.drawPreview(nextPiece, COLS, CELL_SIZE, PREVIEW_SIZE)
    -- 绘制预览标题
    love.graphics.print("Next:", COLS * CELL_SIZE + 20, 40)
    
    local previewBoxX = COLS * CELL_SIZE + 20
    local previewBoxY = 60
    
    -- 绘制预览框
    love.graphics.rectangle("line", 
        previewBoxX, 
        previewBoxY, 
        PREVIEW_SIZE * CELL_SIZE, 
        PREVIEW_SIZE * CELL_SIZE
    )
    
    -- 计算预览方块位置
    local previewCenterX = previewBoxX + (PREVIEW_SIZE * CELL_SIZE) / 2
    local previewCenterY = previewBoxY + (PREVIEW_SIZE * CELL_SIZE) / 2
    
    local pieceWidth = #nextPiece.shape[1] * CELL_SIZE
    local pieceHeight = #nextPiece.shape * CELL_SIZE
    
    return {
        shape = nextPiece.shape,
        color = nextPiece.color,
        x = math.floor((previewCenterX - pieceWidth/2) / CELL_SIZE) + 1,
        y = math.floor((previewCenterY - pieceHeight/2) / CELL_SIZE) + 1
    }
end

function ui.drawGameOver(COLS, ROWS, CELL_SIZE)
    love.graphics.setColor(1, 0, 0)
    love.graphics.print(
        "Game Over!\nPress R to restart",
        COLS * CELL_SIZE + 20, 
        ROWS * CELL_SIZE - 100
    )
end

return ui