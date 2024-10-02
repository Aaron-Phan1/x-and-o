hard_mode_logic = {
    EMPTY = 0,
    X = "X",
    O = "O"
}

function hard_mode_logic:new (o, game_board, curr_turn, taps)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.game_board = game_board
    self.curr = curr_turn
    self.opp = curr_turn == "X" and "O" or "X"
    self.taps = taps
    return o
end

function hard_mode_logic:dia_map(row_index, col_index)
    -- returns diagonal indices (dia_table key) based on predefined map for row_index and col_index
    local map = {
        [1] = {[1] = {1}, [3] = {2}},
        [2] = {[2] = {1, 2}},
        [3] = {[1] = {2}, [3] = {1}}
    }

    return map[row_index][col_index]
end

-- tables used in hard-logic check 1 & 2
function hard_mode_logic:initialise_tables()
    -- Tables to track the cell_states of each row/column/diagonal
    -- Each entry has a count for EMPTY cells, X cells, and O cells
    -- EMPTY key also has a table that can be used flexibly e.g., to store cell numbers
    local rows_table = {
        {[self.EMPTY]={0, {}}, [self.X]={0}, [self.O]={0}}, 
        {[self.EMPTY]={0, {}}, [self.X]={0}, [self.O]={0}},
        {[self.EMPTY]={0, {}}, [self.X]={0}, [self.O]={0}}
    }

    local cols_table = {
        {[self.EMPTY]={0, {}}, [self.X]={0}, [self.O]={0}}, 
        {[self.EMPTY]={0, {}}, [self.X]={0}, [self.O]={0}},
        {[self.EMPTY]={0, {}}, [self.X]={0}, [self.O]={0}}
    }

    local dia_table = {
        {[self.EMPTY]={0, {}}, [self.X]={0}, [self.O]={0}}, 
        {[self.EMPTY]={0, {}}, [self.X]={0}, [self.O]={0}}
    }

    return rows_table, cols_table, dia_table
end

-- [CHECK 1] - If you or your opponent has two in a row*, play on the remaining square. 
function hard_mode_logic:check_two_ina_row ()
    -- Prioritises winning over blocking opponent
    local block_opp = false -- to store cell number for blocking an opponent's winning move
    local rows_table, cols_table, dia_table = self:initialise_tables()

    -- Iterate over each cell in the game board
    for cell_num, cell in ipairs(self.game_board) do
        -- Convert cell index to zero-based index for modulo/floor calculations
        local zero_indexed = cell_num - 1

        -- Calculate one-based row and column indices
        local row_index = math.floor(zero_indexed / 3) + 1
        local col_index = (zero_indexed % 3) + 1

        local diagonal_indices = self:dia_map(row_index, col_index)
        
        local cell_state = cell[7] -- EMPTY/X/O
        local is_EMPTY = cell_state == self.EMPTY 

        -- Increment the count for the cell state in row/col table, and dia table (if applicable) 
        -- If the cell is EMPTY, also record its position for future reference
        rows_table[row_index][cell_state][1] = rows_table[row_index][cell_state][1] + 1

        cols_table[col_index][cell_state][1] = cols_table[col_index][cell_state][1] + 1

        if is_EMPTY then
            table.insert(rows_table[row_index][self.EMPTY][2], cell_num)
            table.insert(cols_table[col_index][self.EMPTY][2], cell_num)
        end

        if diagonal_indices then
            -- for loop used, since current cell may belong to multiple diagonals (e.g., center cell)
            for _, dia_index in ipairs(diagonal_indices) do 
                dia_table[dia_index][cell_state][1] = dia_table[dia_index][cell_state][1] + 1
                if is_EMPTY then 
                    table.insert(dia_table[dia_index][self.EMPTY][2], cell_num) 
                end
            end
        end

        -- Check if the current cell is the last in a row/column/diagonal
        -- and evaluate the respective tables for potential winning or defending moves
        if col_index == 3 then -- last in a column = end of a row
            if rows_table[row_index][self.EMPTY][1] == 1 and rows_table[row_index][self.curr][1] == 2 then
                -- return cell number of empty cell to win
                return rows_table[row_index][self.EMPTY][2][1]

            elseif rows_table[row_index][self.EMPTY][1] == 1 and rows_table[row_index][self.opp][1] == 2 then
                 -- save cell number of empty cell to defend against opponent's two in a row
                block_opp = rows_table[row_index][self.EMPTY][2][1]
            end
        end

        if row_index == 3 then -- last in a row = end of a column
            if cols_table[col_index][self.EMPTY][1] == 1 and cols_table[col_index][self.curr][1] == 2 then
                return cols_table[col_index][self.EMPTY][2][1]

            elseif cols_table[col_index][self.EMPTY][1] == 1 and cols_table[col_index][self.opp][1] == 2 then
                block_opp = cols_table[col_index][self.EMPTY][2][1]
            end
        end

        if row_index == 3 and diagonal_indices then -- last in a column and is on a diagonal = end of a diagonal
            if dia_table[diagonal_indices[1]][self.EMPTY][1] == 1 and dia_table[diagonal_indices[1]][self.curr][1] == 2 then
                return dia_table[diagonal_indices[1]][self.EMPTY][2][1]

            elseif dia_table[diagonal_indices[1]][self.EMPTY][1] == 1 and dia_table[diagonal_indices[1]][self.opp][1] == 2 then
                block_opp = dia_table[diagonal_indices[1]][self.EMPTY][2][1]
            end
        end
        
    end

    return block_opp --return defending move if any was identified, otherwise returns nil
end

-- [CHECK 2] - Otherwise, if there is a move that creates two lines of two in a row, play that move.
function hard_mode_logic:check_create_two_lines()    
    local rows_table, cols_table, dia_table = self:initialise_tables()
    -- Iterate over each cell in the game board
    for cell_num, cell in ipairs(self.game_board) do
        -- Convert cell index to zero-based index for modulo/floor calculations
        local zero_indexed = cell_num - 1

        -- Calculate one-based row and column indices
        local row_index = math.floor(zero_indexed / 3) + 1
        local col_index = (zero_indexed % 3) + 1

        local diagonal_indices = self:dia_map(row_index, col_index)

        local cell_state = cell[7] -- EMPTY/X/O
        local is_EMPTY = cell_state == self.EMPTY 

        -- Increment the count for the cell state in row/col table, and dia table (if applicable) 
        -- If the cell is EMPTY, also record its position for future reference

        rows_table[row_index][cell_state][1] = rows_table[row_index][cell_state][1] + 1
        cols_table[col_index][cell_state][1] = cols_table[col_index][cell_state][1] + 1

        if is_EMPTY then 
            table.insert(rows_table[row_index][self.EMPTY][2], {cell_number=cell_num, row=row_index, col=col_index})
        end

        if diagonal_indices then
            -- for loop used, since current cell may belong to multiple diagonals (e.g., center cell)
            for _, dia_index in ipairs(diagonal_indices) do 
                dia_table[dia_index][cell_state][1] = dia_table[dia_index][cell_state][1] + 1
                if is_EMPTY then 
                    table.insert(dia_table[dia_index][self.EMPTY][2], {cell_number=cell_num, row=row_index, col=col_index}) 
                end
            end
        end
    end

    for _, row in ipairs(rows_table) do
        if row[self.EMPTY][1] == 2 and row[self.curr][1] == 1 then
            for _, empty_row_cell in ipairs(row[self.EMPTY][2]) do
                if cols_table[empty_row_cell.col][self.EMPTY][1] == 2 and cols_table[empty_row_cell.col][self.curr][1] == 1 then
                    return empty_row_cell.cell_number
                end
            end
        end
    end
    
    for _, dia in ipairs(dia_table) do
        if dia[self.EMPTY][1] == 2 and dia[self.curr][1] == 1 then
            for _, empty_dia_cell in ipairs(dia[self.EMPTY][2]) do
                if rows_table[empty_dia_cell.row][self.EMPTY][1] == 2 and rows_table[empty_dia_cell.row][self.curr][1] == 1 then
                    return empty_dia_cell.cell_number
                end
                if cols_table[empty_dia_cell.col][self.EMPTY][1] == 2 and cols_table[empty_dia_cell.col][self.curr][1] == 1 then
                    return empty_dia_cell.cell_number
                end
            end
        end
    end
    return false
end

-- [CHECK 3] - Otherwise, if the centre is free, play there.
function hard_mode_logic:check_centre() 
    return self.game_board[5][7] == self.EMPTY and self.game_board[5][2]
end

-- [CHECK 4] - Otherwise, if your opponent has played in a corner, play the opposite corner.
function hard_mode_logic:check_op_corner() 
    if self.game_board[1][7] == self.EMPTY and self.game_board[9][7] == self.opp then
        return self.game_board[1][2]
    elseif self.game_board[3][7] == self.EMPTY and self.game_board[7][7] == self.opp then
        return self.game_board[3][2]
    elseif self.game_board[7][7] == self.EMPTY and self.game_board[3][7] == self.opp then
        return self.game_board[7][2]
    elseif self.game_board[9][7] == self.EMPTY and self.game_board[1][7] == self.opp then
        return self.game_board[9][2]
    end
end

-- [CHECK 5] - Otherwise, if there is a free corner, play there.
function hard_mode_logic:check_free_corner() 
    return (self.game_board[1][7] == self.EMPTY and self.game_board[1][2]) or 
           (self.game_board[3][7] == self.EMPTY and self.game_board[3][2]) or
           (self.game_board[7][7] == self.EMPTY and self.game_board[7][2]) or 
           (self.game_board[9][7] == self.EMPTY and self.game_board[9][2]) 
end

-- [CHECK 6] - Otherwise, play on any empty square (Also used in easy mode).
function hard_mode_logic:random_cell()
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

function hard_mode_logic:get_best_move ()
    local check_list = {
        self.check_two_ina_row,
        self.check_create_two_lines,
        self.check_centre,
        self.check_op_corner,
        self.check_free_corner,
        self.random_cell
    }

    if self.taps == 9 then
        return false
    end

    for _, check_func in ipairs(check_list) do 
        local check = check_func(self)
        if check then
            return check
        end
    end
end


-- ------------------------------------------------
easy_mode_logic = {
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

game = {
    EMPTY = 0,
    X = "X",
    O = "O",
}

function game:new(o, difficulty, group)
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
    self.sceneGroup = group
    self.moveHistory = moveHistory or {}
    self.result = nil

    return o
end

function game:execute_command(command)
    self.board = command:execute(self.board, self.sceneGroup)
    table.insert(self.moveHistory, command)
end

function game:undo()
    local command = table.remove(self.moveHistory)
    self.board = command:undo(self.board)
end

function game:get_board()
    return self.board
end



local FONT = "Arial"
local baseFontSize = 48
local adjustedSize = baseFontSize * display.contentHeight / 480
d = display
w1_25 = d.contentWidth * .0125
w2_5 = d.contentWidth * .025
w5 = d.contentWidth * .05
w10 = d.contentWidth * .1
w20 = d.contentWidth * .2
w30 = d.contentWidth * .3
w40 = d.contentWidth * .4
w50 = d.contentWidth * .5
w60 = d.contentWidth * .6
w70 = d.contentWidth * .7
w80 = d.contentWidth * .8
w90 = d.contentWidth * .9

h1_25 = d.contentHeight * .0125
h2_5 = d.contentHeight * .025
h5 = d.contentHeight * .05
h10 = d.contentHeight * .1
h20 = d.contentHeight * .2 
h30 = d.contentHeight * .3
h40 = d.contentHeight * .4
h50 = d.contentHeight * .5
h60 = d.contentHeight * .6
h70 = d.contentHeight * .7
h80 = d.contentHeight * .8
h90 = d.contentHeight * .9

play_move_command = {
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
    if not board[self.cell_num] or board[self.cell_num][7] ~= self.EMPTY then
        return board
    end
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