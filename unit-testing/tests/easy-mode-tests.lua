module(..., package.seeall)  -- need this to make things visible

-- Easy mode logic unit tests
-- Return a random empty cell 
local board_easy_valid_1 = {

    {"tl", 1, w20, h40, w40, h20, "O", nil}, 
    {"tm", 2, w40, h40, w60, h20, 0, nil}, -- valid
    {"tr", 3, w60, h40, w80, h20, "O", nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil}, -- valid
    {"mm", 5, w40, h60, w60, h40, "X", nil}, 
    {"mr", 6, w60, h60, w80, h40, "O", nil},

    {"bl", 7, w20, h80, w40, h60, "X", nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil}, -- valid
    {"br", 9, w60, h80, w80, h60, "X", nil} 
}

local board_easy_valid_2 = {

    {"tl", 1, w20, h40, w40, h20, "O", nil}, 
    {"tm", 2, w40, h40, w60, h20, "X", nil}, 
    {"tr", 3, w60, h40, w80, h20, "O", nil},  

    {"ml", 4, w20, h60, w40, h40, "X", nil},
    {"mm", 5, w40, h60, w60, h40, "O", nil}, 
    {"mr", 6, w60, h60, w80, h40, "X", nil},

    {"bl", 7, w20, h80, w40, h60, 0, nil}, -- valid
    {"bm", 8, w40, h80, w60, h60, 0, nil}, -- valid
    {"br", 9, w60, h80, w80, h60, 0, nil}  -- valid
}

local board_easy_valid_3 = {

    {"tl", 1, w20, h40, w40, h20, "O", nil}, 
    {"tm", 2, w40, h40, w60, h20, 0, nil},  -- valid
    {"tr", 3, w60, h40, w80, h20, "O", nil},  

    {"ml", 4, w20, h60, w40, h40, 0, nil}, -- valid
    {"mm", 5, w40, h60, w60, h40, "X", nil}, 
    {"mr", 6, w60, h60, w80, h40, 0, nil}, -- valid

    {"bl", 7, w20, h80, w40, h60, "O", nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil}, -- valid
    {"br", 9, w60, h80, w80, h60, "O", nil} 
}

local board_easy_valid_4 = {

    {"tl", 1, w20, h40, w40, h20, "O", nil}, 
    {"tm", 2, w40, h40, w60, h20, "X", nil}, 
    {"tr", 3, w60, h40, w80, h20, "O", nil},  

    {"ml", 4, w20, h60, w40, h40, "X", nil},
    {"mm", 5, w40, h60, w60, h40, "O", nil}, 
    {"mr", 6, w60, h60, w80, h40, "X", nil},

    {"bl", 7, w20, h80, w40, h60, "O", nil},
    {"bm", 8, w40, h80, w60, h60, 0, nil}, -- valid
    {"br", 9, w60, h80, w80, h60, "O", nil} 
}

-- No valid moves, should return false
local board_easy_invalid_1 = {

    {"tl", 1, w20, h40, w40, h20, "X", nil}, 
    {"tm", 2, w40, h40, w60, h20, "O", nil}, 
    {"tr", 3, w60, h40, w80, h20, "X", nil},  

    {"ml", 4, w20, h60, w40, h40, "O", nil},
    {"mm", 5, w40, h60, w60, h40, "X", nil}, 
    {"mr", 6, w60, h60, w80, h40, "O", nil},

    {"bl", 7, w20, h80, w40, h60, "X", nil},
    {"bm", 8, w40, h80, w60, h60, "O", nil},
    {"br", 9, w60, h80, w80, h60, "X", nil} 
}

local cell 
function test_easy_valid()
    a = easy_mode_logic:new(nil, board_easy_valid_1, 6)
    cell = a:get_best_move()
    assert_equal(a.game_board[cell][7], 0)
    a = easy_mode_logic:new(nil, board_easy_valid_2, 6)
    cell = a:get_best_move()
    assert_equal(a.game_board[cell][7], 0)
    a = easy_mode_logic:new(nil, board_easy_valid_3, 5)
    cell = a:get_best_move()
    assert_equal(a.game_board[cell][7], 0)
    a = easy_mode_logic:new(nil, board_easy_valid_4, 8)
    cell = a:get_best_move()
    assert_equal(a.game_board[cell][7], 0)

end

function test_easy_invalid()
    a = easy_mode_logic:new(nil, board_easy_invalid_1, 9)
    cell = a:get_best_move()
    assert_false(cell)
end