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

-- FONT CONSTANTS
local FONT = "Arial"
local TEXT_SIZE = 20

-- RANDOMLY SELECT AN AVAILABLE CELL
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

-- COMPUTER TURN (EASY) - RANDOMLY FILL AN AVAILABLE CELL W/ O
local function computer_fill_easy ()
    if taps < 9 then
        local t = random_cell()
        board[t][7] = whichTurn -- O
        board[t][8] = d.newText(whichTurn, board[t][3] + w20 / 2, board[t][6] + h20 / 2, FONT, TEXT_SIZE)
        print("EASY COMPUTER ("..whichTurn..") Cell Number: "..board[t][2])
        whichTurn = whichTurn == X and O or X
        taps = taps + 1
    end
end

---- COMPUTER TURN (HARD) - Check functions

--If you or your opponent has two in a row*, play on the remaining square.
-- *”row” in this context means row, column or diagonal.
local function dia_map(row_index, col_index)
    -- returns diagonal indices (dia_table key) based on predefined map for row_index and col_index
    local map = {
        [1] = {[1] = {1}, [3] = {2}},
        [2] = {[2] = {1, 2}},
        [3] = {[1] = {2}, [3] = {1}}
    }

    return map[row_index][col_index]
end

local function check_two_ina_row (game_board)
    -- Check if computer or opponent has two in a row*, play on the remaining square.
    -- Prioritises winning over blocking opponent
    
    local EMPTY, X, O = 0, "X", "O" -- constants representing cell states
    local block_opp = nil -- to store cell number for blocking an opponent's winning move

    -- Tables to track the cell_states of each row/column/diagonal
    -- Each entry has a count for EMPTY cells and EMPTY cell position, X cells, and O cells
    local rows_table = {
        {[EMPTY]={0, nil}, X=0, O=0}, 
        {[EMPTY]={0, nil}, X=0, O=0}, 
        {[EMPTY]={0, nil}, X=0, O=0}
    }

    local cols_table = {
        {[EMPTY]={0, nil}, X=0, O=0}, 
        {[EMPTY]={0, nil}, X=0, O=0}, 
        {[EMPTY]={0, nil}, X=0, O=0}
    }

    local dia_table = {
        {[EMPTY]={0, nil}, X=0, O=0}, 
        {[EMPTY]={0, nil}, X=0, O=0}
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
            if rows_table[row_index][EMPTY][1] == 1 and rows_table[row_index][O] == 2 then
                -- return cell number of empty cell to win
                return rows_table[row_index][EMPTY][2] 

            elseif rows_table[row_index][EMPTY][1] == 1 and rows_table[row_index][X] == 2 then
                 -- save cell number of empty cell to defend against opponent's two in a row
                block_opp = rows_table[row_index][EMPTY][2] 
            end
        end

        if row_index == 3 then -- last in a row = end of a column
            if cols_table[col_index][EMPTY][1] == 1 and cols_table[col_index][O] == 2 then
                return cols_table[col_index][EMPTY][2] 

            elseif cols_table[col_index][EMPTY][1] == 1 and cols_table[col_index][X] == 2 then
                block_opp = cols_table[col_index][EMPTY][2] 
            end
        end

        if row_index == 3 and diagonal_indices then -- last in a column and is on a diagonal = end of a diagonal
            if dia_table[diagonal_indices[1]][EMPTY][1] == 1 and dia_table[diagonal_indices[1]][O] == 2 then
                return dia_table[diagonal_indices[1]][EMPTY][2] 

            elseif dia_table[diagonal_indices[1]][EMPTY][1] == 1 and dia_table[diagonal_indices[1]][X] == 2 then
                block_opp = dia_table[diagonal_indices[1]][EMPTY][2] 
            end
        end
        
    end

    return block_opp --return defending move if any was identified, otherwise returns nil
end


-- Otherwise, if there is a move that creates two lines of two in a row, play that move.
-- Otherwise, if the centre is free, play there.
local function check_centre(game_board) 
    local EMPTY = 0
    return game_board[5][7] == EMPTY and game_board[5][2]
end

-- Otherwise, if your opponent has played in a corner, play the opposite corner.
local function check_op_corner (game_board) 
    local EMPTY, X, O = 0, "X", "O" 
    local op_corner_pairs = {{game_board[1], game_board[9]}, {game_board[3], game_board[7]}}

    local dia_table = {
        {[EMPTY]={0, nil}, X=0, O=0}, 
        {[EMPTY]={0, nil}, X=0, O=0}
    }

    for dia_index, corner_pair in ipairs(op_corner_pairs) do
        for i, cell in ipairs(corner_pair) do
            local cell_num = cell[2]
            local cell_state = cell[7] -- EMPTY/X/O
            local is_EMPTY = cell_state == EMPTY 
            
            dia_table[dia_index][cell_state] = is_EMPTY and {dia_table[dia_index][EMPTY][1] + 1, cell_num} 
                                                or dia_table[dia_index][cell_state] + 1
            if i == 2 then
                if dia_table[dia_index][EMPTY][1] == 1 and dia_table[dia_index][X] == 1 then
                    return dia_table[dia_index][EMPTY][2] 
                end
            end
        end
    end
    return false
end

-- Otherwise, if there is a free corner, play there.
local function check_free_corner (game_board) 
    local EMPTY = 0

    local c1_is_EMPTY = game_board[1][7] == EMPTY
    local c3_is_EMPTY = game_board[3][7] == EMPTY
    local c6_is_EMPTY = game_board[7][7] == EMPTY
    local c9_is_EMPTY = game_board[9][7] == EMPTY

    return (c1_is_EMPTY and game_board[1][2]) or (c3_is_EMPTY and game_board[3][2]) or 
           (c6_is_EMPTY and game_board[7][2]) or (c9_is_EMPTY and game_board[9][2]) 
end

-- Otherwise, play on any empty square.








local function computer_fill_hard ()
    if taps < 9 then

    end
end

-- PLAYER TURN - FILL COMPARTMENT W/ X WHEN TOUCHED
local function fill (event)
    if event.phase == "began" then

        for t = 1, 9 do
            if event.x > board[t][3] and event.x < board [t][5] then
                if event.y < board[t][4] and event.y > board[t][6] then
                    if board[t][7] == EMPTY then

                        board[t][7] = whichTurn -- X 
                        board[t][8] = d.newText(whichTurn, board[t][3] + w20 / 2, board[t][6] + h20 / 2, FONT, TEXT_SIZE)
                        print("Player ("..whichTurn..") Cell Number: "..board[t][2])

                        taps = taps + 1
                        whichTurn = whichTurn == X and O or X

                    end
                end
            end
        end     
    end

end
Runtime:addEventListener("touch", fill)