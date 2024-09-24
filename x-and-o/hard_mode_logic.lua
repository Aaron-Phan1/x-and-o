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
local hard_mode_logic = {}

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
    local EMPTY, X, O = 0, "X", "O"
    -- Tables to track the cell_states of each row/column/diagonal
    -- Each entry has a count for EMPTY cells, X cells, and O cells
    -- EMPTY key also has a table that can be used flexibly e.g., to store cell numbers
    local rows_table = {
        {[EMPTY]={0, {}}, [X]={0}, [O]={0}}, 
        {[EMPTY]={0, {}}, [X]={0}, [O]={0}},
        {[EMPTY]={0, {}}, [X]={0}, [O]={0}}
    }

    local cols_table = {
        {[EMPTY]={0, {}}, [X]={0}, [O]={0}}, 
        {[EMPTY]={0, {}}, [X]={0}, [O]={0}},
        {[EMPTY]={0, {}}, [X]={0}, [O]={0}}
    }

    local dia_table = {
        {[EMPTY]={0, {}}, [X]={0}, [O]={0}}, 
        {[EMPTY]={0, {}}, [X]={0}, [O]={0}}
    }

    return rows_table, cols_table, dia_table
end

-- [CHECK 1] - If you or your opponent has two in a row*, play on the remaining square. 
function hard_mode_logic:check_two_ina_row (game_board, curr_turn)
    -- Prioritises winning over blocking opponent
    -- variables are declared here to make the function easier to test
    local EMPTY, X, O = 0, "X", "O"
    local curr = curr_turn
    local opp = curr_turn == X and O or X
    local block_opp = false -- to store cell number for blocking an opponent's winning move
    local rows_table, cols_table, dia_table = hard_mode_logic:initialise_tables()

    -- Iterate over each cell in the game board
    for cell_num, cell in ipairs(game_board) do
        -- Convert cell index to zero-based index for modulo/floor calculations
        local zero_indexed = cell_num - 1

        -- Calculate one-based row and column indices
        local row_index = math.floor(zero_indexed / 3) + 1
        local col_index = (zero_indexed % 3) + 1

        local diagonal_indices = hard_mode_logic:dia_map(row_index, col_index)
        
        local cell_state = cell[7] -- EMPTY/X/O
        local is_EMPTY = cell_state == EMPTY 

        -- Increment the count for the cell state in row/col table, and dia table (if applicable) 
        -- If the cell is EMPTY, also record its position for future reference
        rows_table[row_index][cell_state][1] = rows_table[row_index][cell_state][1] + 1

        cols_table[col_index][cell_state][1] = cols_table[col_index][cell_state][1] + 1

        if is_EMPTY then
            table.insert(rows_table[row_index][EMPTY][2], cell_num)
            table.insert(cols_table[col_index][EMPTY][2], cell_num)
        end

        if diagonal_indices then
            -- for loop used, since current cell may belong to multiple diagonals (e.g., center cell)
            for _, dia_index in ipairs(diagonal_indices) do 
                dia_table[dia_index][cell_state][1] = dia_table[dia_index][cell_state][1] + 1
                if is_EMPTY then 
                    table.insert(dia_table[dia_index][EMPTY][2], cell_num) 
                end
            end
        end

        -- Check if the current cell is the last in a row/column/diagonal
        -- and evaluate the respective tables for potential winning or defending moves
        if col_index == 3 then -- last in a column = end of a row
            if rows_table[row_index][EMPTY][1] == 1 and rows_table[row_index][curr][1] == 2 then
                -- return cell number of empty cell to win
                return rows_table[row_index][EMPTY][2][1]

            elseif rows_table[row_index][EMPTY][1] == 1 and rows_table[row_index][opp][1] == 2 then
                 -- save cell number of empty cell to defend against opponent's two in a row
                block_opp = rows_table[row_index][EMPTY][2][1]
            end
        end

        if row_index == 3 then -- last in a row = end of a column
            if cols_table[col_index][EMPTY][1] == 1 and cols_table[col_index][curr][1] == 2 then
                return cols_table[col_index][EMPTY][2][1]

            elseif cols_table[col_index][EMPTY][1] == 1 and cols_table[col_index][opp][1] == 2 then
                block_opp = cols_table[col_index][EMPTY][2][1]
            end
        end

        if row_index == 3 and diagonal_indices then -- last in a column and is on a diagonal = end of a diagonal
            if dia_table[diagonal_indices[1]][EMPTY][1] == 1 and dia_table[diagonal_indices[1]][curr][1] == 2 then
                return dia_table[diagonal_indices[1]][EMPTY][2][1]

            elseif dia_table[diagonal_indices[1]][EMPTY][1] == 1 and dia_table[diagonal_indices[1]][opp][1] == 2 then
                block_opp = dia_table[diagonal_indices[1]][EMPTY][2][1]
            end
        end
        
    end

    return block_opp --return defending move if any was identified, otherwise returns nil
end

-- [CHECK 2] - Otherwise, if there is a move that creates two lines of two in a row, play that move.
function hard_mode_logic:check_create_two_lines (game_board, curr_turn)    
    local EMPTY, X, O = 0, "X", "O"
    local curr = curr_turn
    local opp = curr_turn == X and O or X
    local rows_table, cols_table, dia_table = hard_mode_logic:initialise_tables()
    -- Iterate over each cell in the game board
    for cell_num, cell in ipairs(game_board) do
        -- Convert cell index to zero-based index for modulo/floor calculations
        local zero_indexed = cell_num - 1

        -- Calculate one-based row and column indices
        local row_index = math.floor(zero_indexed / 3) + 1
        local col_index = (zero_indexed % 3) + 1

        local diagonal_indices = hard_mode_logic:dia_map(row_index, col_index)

        local cell_state = cell[7] -- EMPTY/X/O
        local is_EMPTY = cell_state == EMPTY 

        -- Increment the count for the cell state in row/col table, and dia table (if applicable) 
        -- If the cell is EMPTY, also record its position for future reference

        rows_table[row_index][cell_state][1] = rows_table[row_index][cell_state][1] + 1
        cols_table[col_index][cell_state][1] = cols_table[col_index][cell_state][1] + 1

        if is_EMPTY then 
            table.insert(rows_table[row_index][EMPTY][2], {cell_number=cell_num, row=row_index, col=col_index})
        end

        if diagonal_indices then
            -- for loop used, since current cell may belong to multiple diagonals (e.g., center cell)
            for _, dia_index in ipairs(diagonal_indices) do 
                dia_table[dia_index][cell_state][1] = dia_table[dia_index][cell_state][1] + 1
                if is_EMPTY then 
                    table.insert(dia_table[dia_index][EMPTY][2], {cell_number=cell_num, row=row_index, col=col_index}) 
                end
            end
        end
    end

    for _, row in ipairs(rows_table) do
        if row[EMPTY][1] == 2 and row[curr][1] == 1 then
            for _, empty_row_cell in ipairs(row[EMPTY][2]) do
                if cols_table[empty_row_cell.col][EMPTY][1] == 2 and cols_table[empty_row_cell.col][curr][1] == 1 then
                    return empty_row_cell.cell_number
                end
            end
        end
    end
    
    for _, dia in ipairs(dia_table) do
        if dia[EMPTY][1] == 2 and dia[curr][1] == 1 then
            for _, empty_dia_cell in ipairs(dia[EMPTY][2]) do
                if rows_table[empty_dia_cell.row][EMPTY][1] == 2 and rows_table[empty_dia_cell.row][curr][1] == 1 then
                    return empty_dia_cell.cell_number
                end
                if cols_table[empty_dia_cell.col][EMPTY][1] == 2 and cols_table[empty_dia_cell.col][curr][1] == 1 then
                    return empty_dia_cell.cell_number
                end
            end
        end
    end
    return false
end

-- [CHECK 3] - Otherwise, if the centre is free, play there.
function hard_mode_logic:check_centre(game_board) 
    local EMPTY = 0
    return game_board[5][7] == EMPTY and game_board[5][2]
end

-- [CHECK 4] - Otherwise, if your opponent has played in a corner, play the opposite corner.
function hard_mode_logic:check_op_corner (game_board, curr_turn) 
    local EMPTY, X, O = 0, "X", "O"
    local opp = curr_turn == X and O or X
    if game_board[1][7] == EMPTY and game_board[9][7] == opp then
        return game_board[1][2]
    elseif game_board[3][7] == EMPTY and game_board[7][7] == opp then
        return game_board[3][2]
    elseif game_board[7][7] == EMPTY and game_board[3][7] == opp then
        return game_board[7][2]
    elseif game_board[9][7] == EMPTY and game_board[1][7] == opp then
        return game_board[9][2]
    end
end

-- [CHECK 5] - Otherwise, if there is a free corner, play there.
function hard_mode_logic:check_free_corner (game_board) 
    local EMPTY = 0
    return (game_board[1][7] == EMPTY and game_board[1][2]) or 
           (game_board[3][7] == EMPTY and game_board[3][2]) or
           (game_board[7][7] == EMPTY and game_board[7][2]) or 
           (game_board[9][7] == EMPTY and game_board[9][2]) 
end

-- [CHECK 6] - Otherwise, play on any empty square (Also used in easy mode).

function hard_mode_logic:random_cell ()
    local choice = math.random(9 - taps) -- select nth cell from available cells
    local t = 0
    repeat -- find nth available cell
        t = t + 1
        if board[t][7] == EMPTY then
            choice = choice - 1
        end
    until choice == 0
    return t
end

hard_mode_logic.checks = {
    hard_mode_logic.check_two_ina_row,
    hard_mode_logic.check_create_two_lines,
    hard_mode_logic.check_centre,
    hard_mode_logic.check_op_corner,
    hard_mode_logic.check_free_corner,
    hard_mode_logic.random_cell
}

return hard_mode_logic