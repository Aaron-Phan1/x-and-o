
-- This file is used to store the logic for the easy mode of the game.
-- "easy = computer plays randomly" - From assignment brief

local easy_mode_logic = {
    EMPTY = 0,
    X = "X",
    O = "O"
}


function easy_mode_logic:new(o, game_board, taps)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.game_board = game_board
    self.taps = taps
    return o
end

function easy_mode_logic:get_best_move()
    -- Check if there are any available cells
    if self.taps == 9 then
        return false
    end

    local choice = math.random(9 - self.taps) -- select nth cell from available cells
    local t = 0
    repeat -- find nth available cell
        t = t + 1
        if self.game_board[t][7] == self.EMPTY then
            choice = choice - 1
        end
    until choice == 0
    return t

end

return easy_mode_logic