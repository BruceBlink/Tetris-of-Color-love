local game = {
    score = 0,
    highestScore = 0,
    gameOver = false,
    lastDropTime = 0
}

function game.calculateScore(rowsCleared)
    if rowsCleared > 0 then
        return (rowsCleared * 100) * rowsCleared
    end
    return 0
end

function game.updateHighScore()
    if game.score > game.highestScore then
        game.highestScore = game.score
    end
end

return game