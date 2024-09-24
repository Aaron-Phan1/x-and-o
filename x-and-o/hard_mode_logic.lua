--[[ 
COMPUTER HARD MODE Logic
Pseudocode Strategy for Win (at best) or Draw (at worst):**
    [CHECK 1] - If you or your opponent has two in a row*, play on the remaining square. 
    [CHECK 2] - Otherwise, if there is a move that creates two lines of two in a row, play that move.
    [CHECK 3] - Otherwise, if the centre is free, play there.
    [CHECK 4] - Otherwise, if your opponent has played in a corner, play the opposite corner.
    [CHECK 5] - Otherwise, if there is a free corner, play there.
    [CHECK 6] - Otherwise, play on any empty square.

*”row” in this context means row, column or diagonal.

**Taken from Assignment Brief
--]]

local hard_mode_logic = {
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


return hard_mode_logic