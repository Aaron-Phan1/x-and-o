module(..., package.seeall)  -- need this to make things visible

local display = display.newGroup()

local a = game:new(nil, "hard", display)

-- Move 1
function test_play_move_1()
    a:execute_command(play_move_command:new({cell_num = 2, curr_turn = "X"}))
    assert_equal(a.board[2][7], "X") -- check that the cell state has been updated
    assert_equal(a.board[2][8].text, "X") -- check that the X or O has been displayed
end

-- Move 2
function test_play_move_2()
    a:execute_command(play_move_command:new({cell_num = 5, curr_turn = "O"}))
    assert_equal(a.board[5][7], "O") -- check that the cell state has been updated
    assert_equal(a.board[5][8].text, "O") -- check that the X or O has been displayed
end

-- Move 3
function test_play_move_3()
    a:execute_command(play_move_command:new({cell_num = 9, curr_turn = "X"}))
    assert_equal(a.board[9][7], "X") -- check that the cell state has been updated
    assert_equal(a.board[9][8].text, "X") -- check that the X or O has been displayed
end

-- Out of bounds move
function test_invalid_move()
    a:execute_command(play_move_command:new({cell_num = 10, curr_turn = "X"})) -- invalid cell number
    assert_equal(a.board[10], nil) -- check that there is no cell 10
    a:execute_command(play_move_command:new({cell_num = 2, curr_turn = "O"})) -- 2 is already taken
    assert_equal(a.board[2][7], "X") -- check that the cell state is unchanged
    assert_equal(a.board[2][8].text, "X") -- Check that the display text is unchanged
end 