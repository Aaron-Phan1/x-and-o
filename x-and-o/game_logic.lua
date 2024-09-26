local game = {
    EMPTY = 0,
    X = "X",
    O = "O",
}

function game:new(o, difficulty, player_order, moveHistory)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.board = board or {

        {"tl", 1, w20, h40, w40, h20,0, nil},
        {"tm",2, w40,h40,w60,h20,0, nil},
        {"tr",3, w60,h40,w80,h20,0, nil},
        
        {"ml", 4, w20, h60, w40, h40,0, nil},
        {"mm",5, w40,h60,w60,h40,0, nil},
        {"mr",6, w60,h60,w80,h40,0, nil},
        
        {"bl", 7, w20, h80, w40, h60,0, nil},
        {"bm",8, w40,h80,w60,h60,0, nil},
        {"br",9, w60,h80,w80,h60,0, nil}
    }
    self.difficulty = difficulty
    self.playerTurn = playerTurn
    self.computerTurn = computerTurn
    self.moveHistory = moveHistory or {}
    return o
end

function game:execute_command(command)
    self.board = command:execute(self.board)
    table.insert(self.moveHistory, command)
end

function game:undo()
    local command = table.remove(self.moveHistory)
    self.board = command:undo(self.board)
end

function game:get_board()
    return self.board
end

local play_move_command = {
    EMPTY = 0,
    X = "X",
    O = "O",
    cell_num = nil,
    curr_turn = nil
}

function play_move_command:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function play_move_command:execute(game_board)
    -- Set cell state to X or O
    local board = game_board
    board[self.cell_num][7] = self.curr_turn 

    -- Draw X or O in cell
    board[self.cell_num][8] = d.newText(self.curr_turn, board[self.cell_num][3] + w20 / 2, board[self.cell_num][6] + h20 / 2, FONT, TEXT_SIZE)

    -- Add text to scene group
    scene.view:insert(board[self.cell_num][8])
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

return game