local piece = {}

piece.SHAPES = {
    {shape = {{1,1,1,1}}, color = {0,1,1}},           -- I
    {shape = {{1,1},{1,1}}, color = {1,1,0}},         -- O
    {shape = {{0,1,0},{1,1,1}}, color = {1,0,1}},     -- T
    {shape = {{1,0,0},{1,1,1}}, color = {1,0.65,0}},  -- L
    {shape = {{0,0,1},{1,1,1}}, color = {0,0,1}},     -- J
    {shape = {{1,1,0},{0,1,1}}, color = {0,1,0}},     -- S
    {shape = {{0,1,1},{1,1,0}}, color = {1,0,0}}      -- Z
}

function piece.createNew(COLS)
    local pieceType = piece.SHAPES[love.math.random(#piece.SHAPES)]
    return {
        shape = pieceType.shape,
        color = pieceType.color,
        x = math.floor(COLS/2) - math.floor(#pieceType.shape[1]/2) + 1,
        y = 1
    }
end

function piece.rotate(currentPiece)
    local oldShape = currentPiece.shape
    local newShape = {}
    
    for y = 1, #oldShape[1] do
        newShape[y] = {}
        for x = 1, #oldShape do
            newShape[y][x] = oldShape[#oldShape - x + 1][y]
        end
    end
    
    return newShape
end

function piece.draw(piece, CELL_SIZE)
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

return piece