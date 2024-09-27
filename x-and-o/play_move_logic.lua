local FONT = "Arial"
local baseFontSize = 48
local adjustedSize = baseFontSize * display.contentHeight / 480

local play_move_command = {
    EMPTY = 0,
    X = "X",
    O = "O",
    cell_num = nil,
    curr_turn = nil,
}

function play_move_command:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function play_move_command:execute(game_board, group)
    -- Set cell state to X or O
    local board = game_board
    board[self.cell_num][7] = self.curr_turn 
    -- Draw X or O in cell
    board[self.cell_num][8] = d.newText(self.curr_turn, board[self.cell_num][3] + w20 / 2, board[self.cell_num][6] + h20 / 2, FONT, adjustedSize)
    board[self.cell_num][8]:setFillColor(self.curr_turn == self.O and 1 or 0, 0, self.curr_turn == self.X and 1 or 0)
    -- Add text to scene group
    group:insert(board[self.cell_num][8])
    return board
end

function play_move_command:undo(game_board)
    -- Set cell state to EMPTY
    local board = game_board
    board[self.cell_num][7] = self.EMPTY

    -- Remove X or O display object from cell
    display.remove(board[self.cell_num][8])
    board[self.cell_num][8] = nil
    return board

end

function play_move_command:get_curr_turn()
    return self.curr_turn
end

return play_move_command