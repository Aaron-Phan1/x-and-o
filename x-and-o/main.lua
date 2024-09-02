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

-- COMPUTER TURN (HARD)
--[[
---If you or your opponent has two in a row*, play on the remaining square.
Otherwise, if there is a move that creates two lines of two in a row, play that move.
Otherwise, if the centre is free, play there.
Otherwise, if your opponent has played in a corner, play the opposite corner.
Otherwise, if there is a free corner, play there.
Otherwise, play on any empty square.

*”row” in this context means row, column or diagonal.
--]]
local function dia_map(row_index, col_index)

    local map = {
        [1] = {[1] = {1}, [3] = {2}},
        [2] = {[2] = {1, 2}},
        [3] = {[1] = {2}, [3] = {1}}
    }

    return map[row_index][col_index]
end

local function check_two_ina_row (game_board)
    local EMPTY, X, O = 0, "X", "O"
    local rows_table = {{[EMPTY]={0, 0}, X=0, O=0}, {[EMPTY]={0, 0}, X=0, O=0}, {[EMPTY]={0, 0}, X=0, O=0}}
    local cols_table = {{[EMPTY]={0, 0}, X=0, O=0}, {[EMPTY]={0, 0}, X=0, O=0}, {[EMPTY]={0, 0}, X=0, O=0}}
    local dia_table = {{[EMPTY]={0, 0}, X=0, O=0}, {[EMPTY]={0, 0}, X=0, O=0}}
    local block_opp = nil

    for cell_num, cell in ipairs(game_board) do

        local zero_indexed = cell_num - 1
        local row_index = math.floor(zero_indexed / 3) + 1
        local col_index = (zero_indexed % 3) + 1
        local diagonal_indices = dia_map(row_index, col_index)
        
        local key = cell[7] -- EMPTY/X/O
        local is_EMPTY = key == EMPTY 

        rows_table[row_index][key] = is_EMPTY and {rows_table[row_index][EMPTY][1] + 1, cell_num} 
                                        or rows_table[row_index][key] + 1

        cols_table[col_index][key] = is_EMPTY and {cols_table[col_index][EMPTY][1] + 1, cell_num} 
                                        or cols_table[col_index][key] + 1

        if diagonal_indices then
            for _, dia_index in ipairs(diagonal_indices) do
                dia_table[dia_index][key] = is_EMPTY and {dia_table[dia_index][EMPTY][1] + 1, cell_num}
                                                or dia_table[dia_index][key] + 1
            end
        end

        if col_index == 3 then
            if rows_table[row_index][EMPTY][1] == 1 and rows_table[row_index][O] == 2 then
                -- return cell number of empty cell to win
                return rows_table[row_index][EMPTY][2] 
            elseif rows_table[row_index][EMPTY][1] == 1 and rows_table[row_index][X] == 2 then
                 -- save cell number of empty cell to defend against opponent's two in a row
                block_opp = rows_table[row_index][EMPTY][2] 
            end
        end

        if row_index == 3 then
            if cols_table[col_index][EMPTY][1] == 1 and cols_table[col_index][O] == 2 then
                -- return cell number of empty cell to win
                return cols_table[col_index][EMPTY][2] 
            elseif cols_table[col_index][EMPTY][1] == 1 and cols_table[col_index][X] == 2 then
                 -- save cell number of empty cell to defend against opponent's two in a row
                block_opp = cols_table[col_index][EMPTY][2] 
            end
        end

        if row_index == 3 and diagonal_indices then
            if dia_table[diagonal_indices[1]][EMPTY][1] == 1 and dia_table[diagonal_indices[1]][O] == 2 then
                -- return cell number of empty cell to win
                return dia_table[diagonal_indices[1]][EMPTY][2] 
            elseif dia_table[diagonal_indices[1]][EMPTY][1] == 1 and dia_table[diagonal_indices[1]][X] == 2 then
                 -- save cell number of empty cell to defend against opponent's two in a row
                block_opp = dia_table[diagonal_indices[1]][EMPTY][2] 
            end
        end
        
    end
    -- return defending move if any
    return block_opp

end

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
                        whichTurn = whichTurn == X and O or X
                        taps = taps + 1
                        hi = check_two_ina_row(board)

                    end
                end
            end
        end     
    end

end
Runtime:addEventListener("touch", fill)