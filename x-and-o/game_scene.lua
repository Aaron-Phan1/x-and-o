local composer = require( "composer" )
 
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
d = display
w20 = d.contentWidth * .2
h20 = d.contentHeight * .2 
w40 = d.contentWidth * .4
h40 = d.contentHeight * .4
w60 = d.contentWidth * .6
h60 = d.contentHeight * .6
w80 = d.contentWidth * .8
h80 = d.contentHeight * .8
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
local EMPTY, X, O = 0, "X", "O" -- Cell states
local whichTurn = X -- X is starting game
local game_state = "in_progress"

-- FONT CONSTANTS
local FONT = "Arial"
local TEXT_SIZE = 20

-- Fill function for computer based on difficulty
local computer_fill = nil 

-- Show overlay to select difficulty
local function select_difficulty(event)
    local options = {
        effect = "fromLeft",
        time = 500,
        isModal = true
    }
    composer.showOverlay("select_difficulty_overlay", options)
end

-- Show overlay to choose whether to go first or second

local function select_order(event)
    local options = {
        effect = "fromLeft",
        time = 200,
        isModal = true
    }
    composer.showOverlay("select_order_overlay", options)
end


-- Game State functions

-- Game Logic
---- Check for winner
local function check_for_win (game_board, difficulty)
    -- Check for horizontal, vertical, and diagonal wins
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

---- Play a move
local function play_move (cell_num, difficulty)
    local sceneGroup = scene.view

    local mode = difficulty == "hard" and "HARD COMPUTER" or difficulty == "easy" and "EASY COMPUTER"
                or difficulty == "player" and "PLAYER"

    -- Set cell state to X or O
    board[cell_num][7] = whichTurn 

    -- Draw X or O in cell
    board[cell_num][8] = d.newText(whichTurn, board[cell_num][3] + w20 / 2, board[cell_num][6] + h20 / 2, FONT, TEXT_SIZE)

    -- Add text to scene group
    sceneGroup:insert(board[cell_num][8])

    print(mode.." ("..whichTurn..") ".."Cell Number: "..cell_num)
    check_for_win(board, difficulty)

    -- Switch turns and increment tap counter
    whichTurn = whichTurn == X and O or X
    taps = taps + 1
end
-- Computer fill functions
---- COMPUTER TURN (HARD) 


local hard_mode_logic = require("hard_mode_logic") -- Import hard mode logic module
local function computer_fill_hard (event)
    if game_state == "in_progress" then
        local hardModeInstance = hard_mode_logic:new(nil, board, whichTurn, taps)
        local best_move = hardModeInstance:get_best_move()
        if best_move then
            play_move(best_move, 'hard')
        end
    end
end

---- COMPUTER TURN (EASY) - RANDOMLY FILL AN AVAILABLE CELL W/ O
local easy_mode_logic = require("easy_mode_logic") -- Import easy mode logic module
local function computer_fill_easy ()
    if game_state == "in_progress" then
        local easyModeInstance = easy_mode_logic:new(nil, board, taps)
        local best_move = easyModeInstance:get_best_move()
        if best_move then
            play_move(best_move, 'easy')
        end
    end
end
-- -----------------------------------------------------------------------------------

-- PLAYER TURN - FILL COMPARTMENT W/ X WHEN TOUCHED
local function fill (event)
    if event.phase == "began" and game_state == "in_progress" then
        for t = 1, 9 do -- Check which tile was touched
            if event.x > board[t][3] and event.x < board [t][5] then
                if event.y < board[t][4] and event.y > board[t][6] then
                    if board[t][7] == EMPTY then
                        play_move(t, "player")
                        computer_fill()

                            

                    end  
                end
            end
        end     
    end

end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:post_difficulty_selection(difficulty)
    if difficulty == "hard" then
        computer_fill = computer_fill_hard
    elseif difficulty == "easy" then
        computer_fill = computer_fill_easy
    end 
    select_order()
end

function scene:post_order_selection(order)
    if order == "first" then
    elseif order == "second" then
        computer_fill()
    end 
end
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    ----DRAW LINES FOR BOARD
    local lline = d.newLine(w40, h20, w40, h80)
    lline.strokeWidth = 5

    local rline = d.newLine(w60, h20, w60, h80)
    rline.strokeWidth = 5

    local bline = d.newLine(w20, h40, w80, h40)
    bline.strokeWidth = 5
    local tline = d.newLine(w20, h60, w80, h60)
    tline.strokeWidth = 5

    -- Add board lines to scene group
    sceneGroup:insert(lline)
    sceneGroup:insert(rline)
    sceneGroup:insert(bline)
    sceneGroup:insert(tline)

    -- Code here runs when the scene is first created but has not yet appeared on screen
 
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

        Runtime:addEventListener("touch", fill)

        -- Show difficulty selection overlay when scene is initially shown 
        timer.performWithDelay(100, select_difficulty) 
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
 
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    Runtime:removeEventListener("touch", fill)
    -- Code here runs prior to the removal of scene's view
 
end
 

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene












