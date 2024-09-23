-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

d = display
w20 = d.contentWidth * .2
h20 = d.contentHeight * .2 
w40 = d.contentWidth * .4
h40 = d.contentHeight * .4
w60 = d.contentWidth * .6
h60 = d.contentHeight * .6
w80 = d.contentWidth * .8
h80 = d.contentHeight * .8


----DRAW LINES FOR BOARD
local lline = d.newLine(w40,h20,w40,h80 )
lline.strokeWidth = 5

local rline = d.newLine(w60,h20,w60,h80 )
rline.strokeWidth = 5

local bline = d.newLine(w20,h40,w80,h40 )
bline.strokeWidth = 5

local tline = d.newLine(w20,h60,w80,h60 )
tline.strokeWidth = 5


--PLACE BOARD COMPARTMENT DIMENSIONS IN TABLE
board ={

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

-- GAME CONSTANTS
local taps = 0 -- track moves done
local EMPTY, X, O = 0, "X", "O"
local whichTurn = X -- X is starting game
local game_state = "in_progress"

-- FONT CONSTANTS
local FONT = "Arial"
local TEXT_SIZE = 20

-- used for board validation functions
local function dia_map(row_index, col_index)
    -- returns diagonal indices (dia_table key) based on predefined map for row_index and col_index
    local map = {
        [1] = {[1] = {1}, [3] = {2}},
        [2] = {[2] = {1, 2}},
        [3] = {[1] = {2}, [3] = {1}}
    }

    return map[row_index][col_index]
end

-- Check for winner
local function check_for_win (game_board, difficulty)
    win = nil
    if (game_board[1][7] == whichTurn and game_board[2][7] == whichTurn and game_board[3][7] == whichTurn) or
       (game_board[4][7] == whichTurn and game_board[5][7] == whichTurn and game_board[6][7] == whichTurn) or
       (game_board[7][7] == whichTurn and game_board[8][7] == whichTurn and game_board[9][7] == whichTurn) or
       (game_board[1][7] == whichTurn and game_board[4][7] == whichTurn and game_board[7][7] == whichTurn) or
       (game_board[2][7] == whichTurn and game_board[5][7] == whichTurn and game_board[8][7] == whichTurn) or
       (game_board[3][7] == whichTurn and game_board[6][7] == whichTurn and game_board[9][7] == whichTurn) or
       (game_board[1][7] == whichTurn and game_board[5][7] == whichTurn and game_board[9][7] == whichTurn) or
       (game_board[3][7] == whichTurn and game_board[5][7] == whichTurn and game_board[7][7] == whichTurn) then
        win = true
    end
    if win == true then
        if difficulty == "player" then
            print("You Win")
            game_state = "player_won"
        else 
            print("You Lose")
            game_state = "ai_won"
        end
    end
end

-- Play a move
local function play_move (cell_num, difficulty)
    if game_state == "in_progress" then
        local mode = difficulty == "hard" and "HARD COMPUTER" or difficulty == "easy" and "EASY COMPUTER"
                    or difficulty == "player" and "PLAYER"
        board[cell_num][7] = whichTurn -- O
        board[cell_num][8] = d.newText(whichTurn, board[cell_num][3] + w20 / 2, board[cell_num][6] + h20 / 2, FONT, TEXT_SIZE)
        print(mode.." ("..whichTurn..") ".."Cell Number: "..cell_num)
        check_for_win(board, difficulty)
        whichTurn = whichTurn == X and O or X
        taps = taps + 1
    end
end

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


-- [CHECK 1] - If you or your opponent has two in a row*, play on the remaining square. 
local function check_two_ina_row (game_board, curr_turn)
    -- Check if computer or opponent has two in a row*, play on the remaining square.
    -- Prioritises winning over blocking opponent
    
    local EMPTY, X, O = 0, "X", "O" -- constants representing cell states
    local curr = curr_turn -- computer turn's cell state
    local opp = curr_turn == X and O or X -- opponent's cell state
    local block_opp = nil -- to store cell number for blocking an opponent's winning move

    -- Tables to track the cell_states of each row/column/diagonal
    -- Each entry has a count for EMPTY cells and EMPTY cell position, X cells, and O cells
    local rows_table = {
        {[EMPTY]={0, nil}, [X]=0, [O]=0}, 
        {[EMPTY]={0, nil}, [X]=0, [O]=0}, 
        {[EMPTY]={0, nil}, [X]=0, [O]=0}
    }

    local cols_table = {
        {[EMPTY]={0, nil}, [X]=0, [O]=0}, 
        {[EMPTY]={0, nil}, [X]=0, [O]=0}, 
        {[EMPTY]={0, nil}, [X]=0, [O]=0}
    }

    local dia_table = {
        {[EMPTY]={0, nil}, [X]=0, [O]=0}, 
        {[EMPTY]={0, nil}, [X]=0, [O]=0}
    }

    -- Iterate over each cell in the game board
    for cell_num, cell in ipairs(game_board) do
        -- Convert cell index to zero-based index for modulo/floor calculations
        local zero_indexed = cell_num - 1

        -- Calculate one-based row and column indices
        local row_index = math.floor(zero_indexed / 3) + 1
        local col_index = (zero_indexed % 3) + 1

        local diagonal_indices = dia_map(row_index, col_index)
        
        local cell_state = cell[7] -- EMPTY/X/O
        local is_EMPTY = cell_state == EMPTY 

        -- Increment the count for the cell state in row/col table, and dia table (if applicable) 
        -- If the cell is EMPTY, also record its position for future reference
        rows_table[row_index][cell_state] = is_EMPTY and {rows_table[row_index][EMPTY][1] + 1, cell_num} 
                                        or rows_table[row_index][cell_state] + 1

        cols_table[col_index][cell_state] = is_EMPTY and {cols_table[col_index][EMPTY][1] + 1, cell_num} 
                                        or cols_table[col_index][cell_state] + 1

        if diagonal_indices then
            -- for loop used, since current cell may belong to multiple diagonals (e.g., center cell)
            for _, dia_index in ipairs(diagonal_indices) do 
                dia_table[dia_index][cell_state] = is_EMPTY and {dia_table[dia_index][EMPTY][1] + 1, cell_num}
                                                or dia_table[dia_index][cell_state] + 1
            end
        end

        -- Check if the current cell is the last in a row/column/diagonal
        -- and evaluate the respective tables for potential winning or defending moves
        if col_index == 3 then -- last in a column = end of a row
            if rows_table[row_index][EMPTY][1] == 1 and rows_table[row_index][curr] == 2 then
                -- return cell number of empty cell to win
                return rows_table[row_index][EMPTY][2] 

            elseif rows_table[row_index][EMPTY][1] == 1 and rows_table[row_index][opp] == 2 then
                 -- save cell number of empty cell to defend against opponent's two in a row
                block_opp = rows_table[row_index][EMPTY][2] 
            end
        end

        if row_index == 3 then -- last in a row = end of a column
            if cols_table[col_index][EMPTY][1] == 1 and cols_table[col_index][curr] == 2 then
                return cols_table[col_index][EMPTY][2] 

            elseif cols_table[col_index][EMPTY][1] == 1 and cols_table[col_index][opp] == 2 then
                block_opp = cols_table[col_index][EMPTY][2] 
            end
        end

        if row_index == 3 and diagonal_indices then -- last in a column and is on a diagonal = end of a diagonal
            if dia_table[diagonal_indices[1]][EMPTY][1] == 1 and dia_table[diagonal_indices[1]][curr] == 2 then
                return dia_table[diagonal_indices[1]][EMPTY][2] 

            elseif dia_table[diagonal_indices[1]][EMPTY][1] == 1 and dia_table[diagonal_indices[1]][opp] == 2 then
                block_opp = dia_table[diagonal_indices[1]][EMPTY][2] 
            end
        end
        
    end

    return block_opp --return defending move if any was identified, otherwise returns nil
end

-- [CHECK 2] - Otherwise, if there is a move that creates two lines of two in a row, play that move.
function check_create_two_lines (game_board, curr_turn)    
    local EMPTY, X, O = 0, "X", "O" -- constants representing cell states
    local curr = curr_turn -- computer turn's cell state
    local opp = curr_turn == X and O or X -- opponent's cell state
    -- Tables to track the cell_states of each row/column/diagonal
    -- Each entry has a count for EMPTY cells and EMPTY cell position, X cells, and O cells
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

    -- Iterate over each cell in the game board
    for cell_num, cell in ipairs(game_board) do
        -- Convert cell index to zero-based index for modulo/floor calculations
        local zero_indexed = cell_num - 1

        -- Calculate one-based row and column indices
        local row_index = math.floor(zero_indexed / 3) + 1
        local col_index = (zero_indexed % 3) + 1

        local diagonal_indices = dia_map(row_index, col_index)

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
local function check_centre(game_board) 
    local EMPTY = 0
    return game_board[5][7] == EMPTY and game_board[5][2]
end

-- [CHECK 4] - Otherwise, if your opponent has played in a corner, play the opposite corner.
local function check_op_corner (game_board, curr_turn) 
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
local function check_free_corner (game_board) 
    local EMPTY = 0
    return (game_board[1][7] == EMPTY and game_board[1][2]) or 
           (game_board[3][7] == EMPTY and game_board[3][2]) or
           (game_board[7][7] == EMPTY and game_board[7][2]) or 
           (game_board[9][7] == EMPTY and game_board[9][2]) 
end

-- [CHECK 6] - Otherwise, play on any empty square (Also used in easy mode).

local function random_cell ()
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

-- COMPUTER TURN (HARD) 

-- List of check functions involved in hard-mode logic from top to bottom
local hard_checks = {check_two_ina_row, check_create_two_lines, check_centre, check_op_corner, check_free_corner, random_cell}

local function computer_fill_hard ()
    if taps < 9 then
        for _, check_func in ipairs(hard_checks) do
            local check = check_func(board, whichTurn)
            if check then 
                play_move(check, "hard")
                return
            end
        end
    end
end

-- COMPUTER TURN (EASY) - RANDOMLY FILL AN AVAILABLE CELL W/ O
local function computer_fill_easy ()
    if taps < 9 then
        local t = random_cell()
        play_move(t, 'easy')
    end
end


-- PLAYER TURN - FILL COMPARTMENT W/ X WHEN TOUCHED
local function fill (event)
    if event.phase == "began" then
        for t = 1, 9 do
            if event.x > board[t][3] and event.x < board [t][5] then
                if event.y < board[t][4] and event.y > board[t][6] then
                    if board[t][7] == EMPTY then
                        play_move(t, "player")
                        computer_fill_hard()

                            

                    end  
                end
            end
        end     
    end

end
Runtime:addEventListener("touch", fill)