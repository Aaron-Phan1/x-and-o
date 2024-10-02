module(..., package.seeall)  -- need this to make things visible

-- User is "X", computer is "O"
local EMPTY = 0
local X = "X"
local O = "O"

-- Boards

-- Blocking scenarios (X to win)
---- Blocking "X" from winning with three horizontally
local board_block_X_horiz_1 ={

	{"tl", 1, w20, h40, w40, h20,"X", nil},
	{"tm",2, w40,h40,w60,h20,"X", nil},
	{"tr",3, w60,h40,w80,h20,0, nil}, -- Empty, should be filled to block "X" from winning 
	
	{"ml", 4, w20, h60, w40, h40,0, nil},
	{"mm",5, w40,h60,w60,h40,0, nil},
	{"mr",6, w60,h60,w80,h40,"O", nil},
	
	{"bl", 7, w20, h80, w40, h60,0, nil},
	{"bm",8, w40,h80,w60,h60,0, nil},
	{"br",9, w60,h80,w80,h60,0, nil}
}

local board_block_X_horiz_2 ={

	{"tl", 1, w20, h40, w40, h20,0, nil},
	{"tm",2, w40,h40,w60,h20,0, nil},
	{"tr",3, w60,h40,w80,h20,0, nil},
	
	{"ml", 4, w20, h60, w40, h40,"X", nil},
	{"mm",5, w40,h60,w60,h40,0, nil}, -- Empty, should be filled to block "X" from winning 
	{"mr",6, w60,h60,w80,h40,"X", nil},
	
	{"bl", 7, w20, h80, w40, h60,0, nil},
	{"bm",8, w40,h80,w60,h60,"O", nil},
	{"br",9, w60,h80,w80,h60,0, nil}
}

local board_block_X_horiz_3 = {

	{"tl", 1, w20, h40, w40, h20,0, nil},
	{"tm",2, w40,h40,w60,h20,0, nil},
	{"tr",3, w60,h40,w80,h20,0, nil},

	{"ml", 4, w20, h60, w40, h40,0, nil},
	{"mm",5, w40,h60,w60,h40,"O", nil},
	{"mr",6, w60,h60,w80,h40,0, nil},

	{"bl", 7, w20, h80, w40, h60,0, nil}, -- Empty, should be filled to block "X" from winning 
	{"bm",8, w40,h80,w60,h60,'X', nil},
	{"br",9, w60,h80,w80,h60,'X', nil}
}

---- Blocking "X" from winning with three vertically
local board_block_X_vert_1 = {

    {"tl", 1, w20, h40, w40, h20, "X", nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil},
    {"tr", 3, w60, h40, w80, h20, "O", nil},

    {"ml", 4, w20, h60, w40, h40, "X", nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil},
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},  -- Should be filled to block "X"
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_block_X_vert_2 = {

    {"tl", 1, w20, h40, w40, h20, 0, nil},
    {"tm", 2, w40, h40, w60, h20, "X", nil},
    {"tr", 3, w60, h40, w80, h20, "O", nil},

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, -- Should be filled to block "X"
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, "X", nil}, 
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_block_X_vert_3 = {

    {"tl", 1, w20, h40, w40, h20, 0, nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil},
    {"tr", 3, w60, h40, w80, h20, "X", nil},

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil},
    {"mr", 6, w60, h60, w80, h40, "X", nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, "O", nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}  -- Should be filled to block "X"
}

---- Blocking "X" from winning with three diagonally
local board_block_X_diag_1 = {

    {"tl", 1, w20, h40, w40, h20, "X", nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil},
    {"tr", 3, w60, h40, w80, h20, 0, nil},

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, "X", nil},
    {"mr", 6, w60, h60, w80, h40, "O", nil},
	
    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}  -- Should be filled to block "X"
}

local board_block_X_diag_2 = {
	
    {"tl", 1, w20, h40, w40, h20, 0, nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil},
    {"tr", 3, w60, h40, w80, h20, "X", nil},

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, "X", nil},
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},  -- Should be filled to block "X"
    {"bm", 8, w40, h80, w60, h60, "O", nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

-- Winning scenarios ("O" to win)
---- "O" to Win with Three in a Row
local board_O_win_horiz_1 = {
	
    {"tl", 1, w20, h40, w40, h20, 0, nil}, -- Should be filled for "O" to win
    {"tm", 2, w40, h40, w60, h20, "O", nil},
    {"tr", 3, w60, h40, w80, h20, "O", nil},  

    {"ml", 4, w20, h60, w40, h40, "X", nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil},
    {"mr", 6, w60, h60, w80, h40, 0, nil},
	
    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_O_win_horiz_2 = {

    {"tl", 1, w20, h40, w40, h20, 0, nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil},
    {"tr", 3, w60, h40, w80, h20, "X", nil},

    {"ml", 4, w20, h60, w40, h40, "O", nil},
    {"mm", 5, w40, h60, w60, h40, "O", nil},
    {"mr", 6, w60, h60, w80, h40, 0, nil},  -- Should be filled for "O" to win

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_O_win_horiz_3 = {

    {"tl", 1, w20, h40, w40, h20, 0, nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil},
    {"tr", 3, w60, h40, w80, h20, 0, nil},

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, "X", nil},
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, "O", nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil}, -- Should be filled for "O" to win
    {"br", 9, w60, h80, w80, h60, "O", nil}  
}

---- "O" to Win with three Vertically
local board_O_win_vert_1 = {

    {"tl", 1, w20, h40, w40, h20, "O", nil},
    {"tm", 2, w40, h40, w60, h20, "X", nil},
    {"tr", 3, w60, h40, w80, h20, 0, nil},

    {"ml", 4, w20, h60, w40, h40, 0, nil}, -- Should be filled for "O" to win
    {"mm", 5, w40, h60, w60, h40, 0, nil},
    {"mr", 6, w60, h60, w80, h40, "X", nil},

    {"bl", 7, w20, h80, w40, h60, "O", nil},  
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_O_win_vert_2 = {

    {"tl", 1, w20, h40, w40, h20, "X", nil},
    {"tm", 2, w40, h40, w60, h20, "O", nil},
    {"tr", 3, w60, h40, w80, h20, 0, nil},

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, "O", nil},
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, "X", nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},  -- Should be filled for "O" to win
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_O_win_vert_3 = {

    {"tl", 1, w20, h40, w40, h20, 0, nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil},
    {"tr", 3, w60, h40, w80, h20, 0, nil}, -- Should be filled for "O" to win

    {"ml", 4, w20, h60, w40, h40, "X", nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil},
    {"mr", 6, w60, h60, w80, h40, "O", nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, "X", nil},  
    {"br", 9, w60, h80, w80, h60, "O", nil} 
}

---- "O" to Win with three Diagonally
local board_O_win_diag_1 = {

    {"tl", 1, w20, h40, w40, h20, 0, nil}, -- Should be filled for "O" to win
    {"tm", 2, w40, h40, w60, h20, 0, nil},
    {"tr", 3, w60, h40, w80, h20, "X", nil},

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, "O", nil},
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, "X", nil},  
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, "O", nil} 
}

local board_O_win_diag_2 = {

    {"tl", 1, w20, h40, w40, h20, "X", nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil},
    {"tr", 3, w60, h40, w80, h20, "O", nil},

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, "O", nil},
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil}, -- Should be filled for "O" to win
    {"bm", 8, w40, h80, w60, h60, "X", nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

-- Prioritising "O" to Win Instead of Blocking "X" (3 Cases for Each Direction)
local board_prioritise_O_horiz_1 = {

    {"tl", 1, w20, h40, w40, h20, "O", nil},
    {"tm", 2, w40, h40, w60, h20, "O", nil},
    {"tr", 3, w60, h40, w80, h20, 0, nil},  -- Fill to win, not block "X" elsewhere

    {"ml", 4, w20, h60, w40, h40, "X", nil},
    {"mm", 5, w40, h60, w60, h40, "X", nil},
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}
local board_prioritise_O_horiz_2 = {

    {"tl", 1, w20, h40, w40, h20, "X", nil},
    {"tm", 2, w40, h40, w60, h20, "X", nil},
    {"tr", 3, w60, h40, w80, h20, 0, nil},

    {"ml", 4, w20, h60, w40, h40, "O", nil},
    {"mm", 5, w40, h60, w60, h40, "O", nil},
    {"mr", 6, w60, h60, w80, h40, 0, nil},  -- Fill to win, not block "X" elsewhere

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_prioritise_O_horiz_3 = {

    {"tl", 1, w20, h40, w40, h20, "X", nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil},
    {"tr", 3, w60, h40, w80, h20, "X", nil},

    {"ml", 4, w20, h60, w40, h40, "X", nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil},
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, "O", nil},
    {"bm", 8, w40, h80, w60, h60, "O", nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}  -- Fill to win, not block "X" elsewhere
}

local board_prioritise_O_vert_1 = {

    {"tl", 1, w20, h40, w40, h20, "O", nil},
    {"tm", 2, w40, h40, w60, h20, "X", nil},
    {"tr", 3, w60, h40, w80, h20, 0, nil},

    {"ml", 4, w20, h60, w40, h40, "O", nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil},
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},  -- Fill to win, not block "X" elsewhere
    {"bm", 8, w40, h80, w60, h60, "X", nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_prioritise_O_vert_2 = {

    {"tl", 1, w20, h40, w40, h20, "X", nil},
    {"tm", 2, w40, h40, w60, h20, "O", nil},
    {"tr", 3, w60, h40, w80, h20, 0, nil},

    {"ml", 4, w20, h60, w40, h40, "X", nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, -- Fill to win, not block "X" elsewhere
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, "O", nil},  
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_prioritise_O_vert_3 = {

    {"tl", 1, w20, h40, w40, h20, "X", nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil}, -- Fill to win, not block "X" elsewhere
    {"tr", 3, w60, h40, w80, h20, 0, nil},  

    {"ml", 4, w20, h60, w40, h40, "X", nil},
    {"mm", 5, w40, h60, w60, h40, "O", nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, "O", nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

-- Boards with no winning opportunities or threats

local board_no_threat_1 = {

    {"tl", 1, w20, h40, w40, h20, 0, nil},
    {"tm", 2, w40, h40, w60, h20, "O", nil},
    {"tr", 3, w60, h40, w80, h20, "X", nil},

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, "X", nil},
    {"mr", 6, w60, h60, w80, h40, "O", nil},

    {"bl", 7, w20, h80, w40, h60, "X", nil},
    {"bm", 8, w40, h80, w60, h60, "O", nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_no_threat_2 = {

    {"tl", 1, w20, h40, w40, h20, "O", nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil},
    {"tr", 3, w60, h40, w80, h20, "X", nil},

    {"ml", 4, w20, h60, w40, h40, "X", nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil},
    {"mr", 6, w60, h60, w80, h40, "O", nil},

    {"bl", 7, w20, h80, w40, h60, "O", nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, "X", nil}
}

local board_no_threat_3 = {
    {"tl", 1, w20, h40, w40, h20, "X", nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil},
    {"tr", 3, w60, h40, w80, h20, "O", nil},

    {"ml", 4, w20, h60, w40, h40, "O", nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil},
    {"mr", 6, w60, h60, w80, h40, "X", nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, "O", nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_no_threat_4 = {
    {"tl", 1, w20, h40, w40, h20, "X", nil},
    {"tm", 2, w40, h40, w60, h20, "X", nil},
    {"tr", 3, w60, h40, w80, h20, "O", nil},

    {"ml", 4, w20, h60, w40, h40, "O", nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil},
    {"mr", 6, w60, h60, w80, h40, "X", nil},

    {"bl", 7, w20, h80, w40, h60, "X", nil},
    {"bm", 8, w40, h80, w60, h60, "O", nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_two_move_1 = {
    {"tl", 1, w20, h40, w40, h20, 0, nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil},
    {"tr", 3, w60, h40, w80, h20, 0, nil},

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, "X", nil},
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_two_move_2 = {
    {"tl", 1, w20, h40, w40, h20, 0, nil},
    {"tm", 2, w40, h40, w60, h20, "X", nil},
    {"tr", 3, w60, h40, w80, h20, 0, nil},

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil},
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_two_move_3 = {
    {"tl", 1, w20, h40, w40, h20, 0, nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil},
    {"tr", 3, w60, h40, w80, h20, 0, nil},

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil},
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, "X", nil}
}



-- Testing
function test_check2inrow_block_horiz()
	-- Test Blocking "X" from winning horizontally
    a = hard_mode_logic:new(nil, board_block_X_horiz_1, O, 3)
    assert_equal(a:check_two_ina_row(), 3)
    a = hard_mode_logic:new(nil, board_block_X_horiz_2, O, 3)
    assert_equal(a:check_two_ina_row(), 5)
    a = hard_mode_logic:new(nil, board_block_X_horiz_3, O, 3)
    assert_equal(a:check_two_ina_row(), 7)
end 

function test_check2inrow_block_vert()
    -- Test Blocking "X" from winning vertically
    a = hard_mode_logic:new(nil, board_block_X_vert_1, O, 3)
    assert_equal(a:check_two_ina_row(), 7)
    a = hard_mode_logic:new(nil, board_block_X_vert_2, O, 3)
    assert_equal(a:check_two_ina_row(), 5)
    a = hard_mode_logic:new(nil, board_block_X_vert_3, O, 3)
    assert_equal(a:check_two_ina_row(), 9)
end 

function test_check2inrow_block_diag()
    -- Test Blocking "X" from winning diagonally
    a = hard_mode_logic:new(nil, board_block_X_diag_1, O, 3)
    assert_equal(a:check_two_ina_row(), 9)
    a = hard_mode_logic:new(nil, board_block_X_diag_2, O, 3)
    assert_equal(a:check_two_ina_row(), 7)
end 

function test_check2inrow_win_horiz()
    -- Test "O" winning horizontally
    a = hard_mode_logic:new(nil, board_O_win_horiz_1, O, 3)
    assert_equal(a:check_two_ina_row(), 1)
    a = hard_mode_logic:new(nil, board_O_win_horiz_2, O, 3)
    assert_equal(a:check_two_ina_row(), 6)
    a = hard_mode_logic:new(nil, board_O_win_horiz_3, O, 3)
    assert_equal(a:check_two_ina_row(), 8)
end 

function test_check2inrow_win_vert()
    -- Test "O" winning vertically
    a = hard_mode_logic:new(nil, board_O_win_vert_1, O, 4)
    assert_equal(a:check_two_ina_row(), 4)
    a = hard_mode_logic:new(nil, board_O_win_vert_2, O, 4)
    assert_equal(a:check_two_ina_row(), 8)
    a = hard_mode_logic:new(nil, board_O_win_vert_3, O, 4)
    assert_equal(a:check_two_ina_row(), 3)
end 

function test_check2inrow_win_diag()
    -- Test "O" winning diagonally
    a = hard_mode_logic:new(nil, board_O_win_diag_1, O, 4)
    assert_equal(a:check_two_ina_row(), 1)
    a = hard_mode_logic:new(nil, board_O_win_diag_2, O, 4)
    assert_equal(a:check_two_ina_row(), 7)
end 

function test_check2inrow_prio_win_horiz()
    -- Test prioritising "O" to win horizontally
    a = hard_mode_logic:new(nil, board_prioritise_O_horiz_1, O, 4)
    assert_equal(a:check_two_ina_row(), 3)
    a = hard_mode_logic:new(nil, board_prioritise_O_horiz_2, O, 4)
    assert_equal(a:check_two_ina_row(), 6)
    a = hard_mode_logic:new(nil, board_prioritise_O_horiz_3, O, 5)
    assert_equal(a:check_two_ina_row(), 9)
end 

function test_check2inrow_prio_win_vert()
    -- Test prioritising "O" to win vertically
    a = hard_mode_logic:new(nil, board_prioritise_O_vert_1, O, 4)
    assert_equal(a:check_two_ina_row(), 7)
    a = hard_mode_logic:new(nil, board_prioritise_O_vert_2, O, 4)
    assert_equal(a:check_two_ina_row(), 5)
    a = hard_mode_logic:new(nil, board_prioritise_O_vert_3, O, 4)
    assert_equal(a:check_two_ina_row(), 2)
end 

function test_check2inrow_no_threat()
    -- Test cases where no immediate threats or opportunities are present
    a = hard_mode_logic:new(nil, board_no_threat_1, O, 6)
    assert_false(a:check_two_ina_row())
    a = hard_mode_logic:new(nil, board_no_threat_2, O, 6)
    assert_false(a:check_two_ina_row())
    a = hard_mode_logic:new(nil, board_no_threat_3, O, 5)
    assert_false(a:check_two_ina_row())
    a = hard_mode_logic:new(nil, board_no_threat_4, O, 7)
    assert_false(a:check_two_ina_row())
end 

function test_check2inrow_no_threat_2move()
    -- Test cases with no winning opportunities but multiple empty spaces
    a = hard_mode_logic:new(nil, board_two_move_1, O, 1)
    assert_false(a:check_two_ina_row())
    a = hard_mode_logic:new(nil, board_two_move_2, O, 1)
    assert_false(a:check_two_ina_row())
    a = hard_mode_logic:new(nil, board_two_move_3, O, 1)
    assert_false(a:check_two_ina_row())
end 


-- Check for moves that will create two lines of two

local board_twoL_zero_dia_1 = {

    {"tl", 1, w20, h40, w40, h20, 0, nil}, 
    {"tm", 2, w40, h40, w60, h20, "O", nil}, 
    {"tr", 3, w60, h40, w80, h20, 0, nil},  --O should fill

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, "X", nil}, 
    {"mr", 6, w60, h60, w80, h40, "O", nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil} 
}

local board_twoL_zero_dia_2 = {

    {"tl", 1, w20, h40, w40, h20, 0, nil}, 
    {"tm", 2, w40, h40, w60, h20, "O", nil}, 
    {"tr", 3, w60, h40, w80, h20, "X", nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil},  -- O
    {"mr", 6, w60, h60, w80, h40, "O", nil}, 

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil} 
}

local board_twoL_one_dia_1 = {

    {"tl", 1, w20, h40, w40, h20, "O", nil}, 
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, 0, nil},  -- O

    {"ml", 4, w20, h60, w40, h40, "X", nil},
    {"mm", 5, w40, h60, w60, h40, "X", nil}, 
    {"mr", 6, w60, h60, w80, h40, "O", nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil} 
}

local board_twoL_one_dia_2 = {

    {"tl", 1, w20, h40, w40, h20, "O", nil}, 
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, "X", nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil}, -- O
    {"mm", 5, w40, h60, w60, h40, 0, nil}, 
    {"mr", 6, w60, h60, w80, h40, "O", nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, "X", nil} 
}

local board_twoL_one_dia_3 = {

    {"tl", 1, w20, h40, w40, h20, "O", nil}, 
    {"tm", 2, w40, h40, w60, h20, "X", nil}, 
    {"tr", 3, w60, h40, w80, h20, 0, nil},  

    {"ml", 4, w20, h60, w40, h40, "X", nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, 
    {"mr", 6, w60, h60, w80, h40, "O", nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil} -- O 
}

local board_twoL_one_dia_4  = {

    {"tl", 1, w20, h40, w40, h20, "O", nil}, 
    {"tm", 2, w40, h40, w60, h20, "X", nil}, 
    {"tr", 3, w60, h40, w80, h20, 0, nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, -- O
    {"mr", 6, w60, h60, w80, h40, "O", nil},

    {"bl", 7, w20, h80, w40, h60, "X", nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil} 
}

local board_twoL_two_dia_1 = {

    {"tl", 1, w20, h40, w40, h20, "O", nil}, 
    {"tm", 2, w40, h40, w60, h20, "X", nil}, 
    {"tr", 3, w60, h40, w80, h20, "O", nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, -- O
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil} -- O
}

local board_twoL_two_dia_2 = {

    {"tl", 1, w20, h40, w40, h20, "O", nil}, 
    {"tm", 2, w40, h40, w60, h20, "X", nil}, 
    {"tr", 3, w60, h40, w80, h20, "O", nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil}, -- O
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, "X", nil} 
}

local board_twoL_two_dia_3 = {

    {"tl", 1, w20, h40, w40, h20, "O", nil}, 
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, 0, nil},  -- O

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, "X", nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil}, -- O
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, "O", nil} 
}

function test_twoL_zero_dia()
    a = hard_mode_logic:new(nil, board_twoL_zero_dia_1, O, 3)  
    assert_equal(a:check_create_two_lines(), 3)
    a = hard_mode_logic:new(nil, board_twoL_zero_dia_2, O, 3)  
    assert_equal(a:check_create_two_lines(), 5)
end 

function test_twoL_one_dia()
    a = hard_mode_logic:new(nil, board_twoL_one_dia_1, O, 4)
    assert_equal(a:check_create_two_lines(), 3)
    a = hard_mode_logic:new(nil, board_twoL_one_dia_2, O, 4)
    assert_equal(a:check_create_two_lines(), 4)
    a = hard_mode_logic:new(nil, board_twoL_one_dia_3, O, 4)
    assert_equal(a:check_create_two_lines(), 9)
    a = hard_mode_logic:new(nil, board_twoL_one_dia_4, O, 4)
    assert_equal(a:check_create_two_lines(), 5)
end 

function test_twoL_two_dia()
    a = hard_mode_logic:new(nil, board_twoL_two_dia_1, O, 3)
    assert_equal(a:check_create_two_lines(), 9)
    a = hard_mode_logic:new(nil, board_twoL_two_dia_2, O, 4)
    assert_equal(a:check_create_two_lines(), 7)
    a = hard_mode_logic:new(nil, board_twoL_two_dia_3, O, 3)
    assert_equal(a:check_create_two_lines(), 3)
end 


-- check centre
local board_centre_O = {

    {"tl", 1, w20, h40, w40, h20, 0, nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, 0, nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, "O", nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_centre_X = {

    {"tl", 1, w20, h40, w40, h20, 0, nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, 0, nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, "X", nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_centre_EMPTY = {

    {"tl", 1, w20, h40, w40, h20, 0, nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, 0, nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, -- should be filled with "O"
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}



function test_check_centre_X()
    a = hard_mode_logic:new(nil, board_centre_X, O, 1)
    assert_false(a:check_centre())
end 

function test_check_centre_O()
    a = hard_mode_logic:new(nil, board_centre_O, O, 1)
    assert_false(a:check_centre())
end 

function test_check_centre_EMPTY()
    a = hard_mode_logic:new(nil, board_centre_EMPTY, O, 0)
    assert_equal(a:check_centre(), 5)
end 


-- check opposite corners
-- "Otherwise, if your opponent has played in a corner, play the opposite corner."

local board_op_corner_X_1 = {

    {"tl", 1, w20, h40, w40, h20, "X", nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, 0, nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil} -- Should be filled with "O"
}


local board_op_corner_X_2 = {

    {"tl", 1, w20, h40, w40, h20, 0, nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, "X", nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil}, -- Should be filled with "O"
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_op_corner_X_3 = {

    {"tl", 1, w20, h40, w40, h20, 0, nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, 0, nil},  -- Should be filled with "O"

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, "X", nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_op_corner_X_4 = {

    {"tl", 1, w20, h40, w40, h20, 0, nil}, -- Should be filled with "O"
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, 0, nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, "X", nil}
}

local board_op_corner_X_5 = {

    {"tl", 1, w20, h40, w40, h20, 0, nil}, -- Should be filled with "O"
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, "O", nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, "O", nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, "X", nil}
}

local board_op_corner_O_1 = {

    {"tl", 1, w20, h40, w40, h20, "O", nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, 0, nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_op_corner_O_2 = {

    {"tl", 1, w20, h40, w40, h20, 0, nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, 0, nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, "O", nil}
}

local board_op_corner_O_3 = {

    {"tl", 1, w20, h40, w40, h20, 0, nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, "O", nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

local board_op_corner_O_4 = {

    {"tl", 1, w20, h40, w40, h20, 0, nil},
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, 0, nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, "O", nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil}
}

function test_op_corner_X()
    a = hard_mode_logic:new(nil, board_op_corner_X_1, O, 1)
    assert_equal(a:check_op_corner(), 9)
    a = hard_mode_logic:new(nil, board_op_corner_X_2, O, 1)
    assert_equal(a:check_op_corner(), 7)
    a = hard_mode_logic:new(nil, board_op_corner_X_3, O, 1)
    assert_equal(a:check_op_corner(), 3)
    a = hard_mode_logic:new(nil, board_op_corner_X_4, O, 1)
    assert_equal(a:check_op_corner(), 1)
    a = hard_mode_logic:new(nil, board_op_corner_X_5, O, 3)
    assert_equal(a:check_op_corner(), 1)
end 

function test_op_corner_O()
    a = hard_mode_logic:new(nil, board_op_corner_O_1, O, 1)
    assert_false(a:check_op_corner())
    a = hard_mode_logic:new(nil, board_op_corner_O_2, O, 1)
    assert_false(a:check_op_corner())
    a = hard_mode_logic:new(nil, board_op_corner_O_3, O, 1)
    assert_false(a:check_op_corner())
    a = hard_mode_logic:new(nil, board_op_corner_O_4, O, 1)
end 

-- check any free corner
-- "Otherwise, if there is a free corner, play there."

local board_free_corner_1 = {

    {"tl", 1, w20, h40, w40, h20, 0, nil}, -- Should be filled with "O"
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, "X", nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, "O", nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, "X", nil}
}

local board_free_corner_2 = {

    {"tl", 1, w20, h40, w40, h20, "O", nil}, 
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, 0, nil},  -- Should be filled with "O"

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, "O", nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, "X", nil}
}

local board_free_corner_3 = {

    {"tl", 1, w20, h40, w40, h20, "X", nil}, 
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, "X", nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil}, -- Should be filled with "O"
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, "X", nil}
}

local board_free_corner_4 = {

    {"tl", 1, w20, h40, w40, h20, "X", nil}, 
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, "X", nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, "O", nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, 0, nil} -- Should be filled with "O"
}

local board_free_corner_nil = {

    {"tl", 1, w20, h40, w40, h20, "X", nil}, 
    {"tm", 2, w40, h40, w60, h20, 0, nil}, 
    {"tr", 3, w60, h40, w80, h20, "O", nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil},
    {"mm", 5, w40, h60, w60, h40, 0, nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil},

    {"bl", 7, w20, h80, w40, h60, "X", nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil},
    {"br", 9, w60, h80, w80, h60, "O", nil} 
}


function test_free_corner()
    a = hard_mode_logic:new(nil, board_free_corner_1, O, 3)
    assert_equal(a:check_free_corner(), 1)
    a = hard_mode_logic:new(nil, board_free_corner_2, O, 3) 
    assert_equal(a:check_free_corner(), 3)
    a = hard_mode_logic:new(nil, board_free_corner_3, O, 3)
    assert_equal(a:check_free_corner(), 7)
    a = hard_mode_logic:new(nil, board_free_corner_4, O, 3)
    assert_equal(a:check_free_corner(), 9)
end 

function test_free_corner_nil()
    a = hard_mode_logic:new(nil, board_free_corner_nil, O, 4)
    assert_false(a:check_free_corner())
end 
