local composer = require( "composer" )
 
local scene = composer.newScene()
 
local widget = require("widget")
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
d = display
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

-- display object constants
local game_over_y = h10 + h2_5
local buttonWidth = w20 + w2_5
local buttonHeight = h10
local buttonGap = w5 + w2_5
local buttonY = h90
--PLACE BOARD COMPARTMENT DIMENSIONS IN TABLE



-- GAME CONSTANTS
local taps = 0 -- track moves done
local EMPTY, X, O = 0, "X", "O" -- Cell states
local whichTurn = X -- X is starting game
local game_state = "in_progress"

-- forward declaration so that the function can be called before it is defined
local computer_fill_hard
local computer_fill_easy

-- FONT CONSTANTS
local FONT = "Arial"
local TEXT_SIZE = 20

-- Fill function for computer based on difficulty
local current_difficulty = nil
local player_order = nil
local computer_fill = nil 
-- OVERLAY FUNCTIONS
startup = true


local game = {
    EMPTY = 0,
    X = "X",
    O = "O",
}

function game:new(o, difficulty, play_order, history)
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
    self.playerTurn = playerTurn
    self.computerTurn = computerTurn
    self.history = history or {}
    return o
end

function game:execute_command(command)
    self.board = command:execute(self.board)
    table.insert(self.history, command)
end

function game:undo()
    local command = table.remove(self.history)
    self.board = command:undo(self.board)
end

function game:get_board()
    return self.board
end

local play_move_command = {
    board = nil
}

function play_move_command:new(o, cell_num, curr_turn)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.cell_num = cell_num
    self.curr_turn = curr_turn
    return o
end

function play_move_command:execute(game_board)
    -- Set cell state to X or O
    local board = game_board
    board[self.cell_num][7] = self.curr_turn 

    -- Draw X or O in cell
    board[self.cell_num][8] = d.newText(self.curr_turn, board[self.cell_num][3] + w20 / 2, board[self.cell_num][6] + h20 / 2, FONT, TEXT_SIZE)

    -- Add text to scene group
    scene.view:insert(board[self.cell_num][8])
    return board
end

function play_move_command:undo()
    -- Set cell state to EMPTY
    self.board[self.cell_num][7] = EMPTY

    -- Remove X or O from cell
    display.remove(self.board[self.cell_num][8])
    self.board[self.cell_num][8] = nil
end

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

local function create_undo_button()
    local sceneGroup = scene.view
    local undoButton = widget.newButton(
        {
            label = "Undo",
            onRelease = nil,
            shape = "roundedRect",
            width = buttonWidth,
            height = buttonHeight,
            x = w80,
            y = buttonY,
            fontSize = 16
        }
    )
    sceneGroup:insert(undoButton)
end
local function display_difficulty()

    if difficultyText then
        display.remove(difficultyText)
    end

    local difficultyText = nil

    local sceneGroup = scene.view
    difficultyText = d.newText("Difficulty: "..current_difficulty:upper(), w20, buttonY + (buttonHeight/2) + h2_5, FONT, 12)
    if current_difficulty == "easy" then
        difficultyText:setFillColor(0, 1, 0) -- Set text color to green
    elseif current_difficulty == "hard" then
        difficultyText:setFillColor(1, 0, 0) -- Set text color to red
    end
    sceneGroup:insert(difficultyText)
end

local function change_difficulty(event)
    current_difficulty = current_difficulty == "hard" and "easy" or "hard"
    computer_fill = computer_fill == computer_fill_hard and computer_fill_easy or computer_fill_hard
    display_difficulty()
end
local buttonObjects = {}
-- Game Over function
local function play_again()
    local sceneGroup = scene.view

    -- Reset board state
    for i = 1, 9 do
        display.remove(gameInstance.board[i][8])
        gameInstance.board[i][8] = nil
    end
    -- Remove game over text and buttons
    for _, button in ipairs(buttonObjects) do
        display.remove(button)
        button = nil
    end

    display.remove(gameOverText)
    gameOverText = nil

    -- Reset game states
    taps = 0
    whichTurn = X
    game_state = "in_progress"

    select_order()

end

local function game_over(game_state)
    local sceneGroup = scene.view
    if game_state == "player_won" then
        gameOverText = d.newText("You Win", d.contentCenterX, game_over_y, FONT, 40)
        gameOverText:setFillColor(0, 1, 0) -- Set text color to green
    elseif game_state == "ai_won" then
        gameOverText = d.newText("You Lose", d.contentCenterX, game_over_y, FONT, 40)
        gameOverText:setFillColor(1, 0, 0) -- Set text color to red
    elseif game_state == "draw" then
        gameOverText = d.newText("Draw", d.contentCenterX, game_over_y, FONT, 40)
        gameOverText:setFillColor(0, 0, 1) -- Set text color to blue
    end
    sceneGroup:insert(gameOverText)
    
    local buttons = {
        {label = "Change\nDifficulty", onRelease = change_difficulty},
        {label = "Play\nAgain", onRelease = play_again},
        {label = "Watch\nReplay"}
    }

    local buttonX = w20
    for i, buttonConfig in ipairs(buttons) do
        local button = widget.newButton(
            {
                label = buttonConfig.label,
                labelColor = { default={0,0,0}, over={0,0,0} },
                shape = "roundedRect",
                width = buttonWidth,
                height = buttonHeight,
                onRelease = buttonConfig.onRelease,
                x = buttonX,
                y = buttonY,
                fontSize = 16
            }
        )
        sceneGroup:insert(button)
        table.insert(buttonObjects, button)
        buttonX = buttonX + buttonWidth + buttonGap
    end
end

-- Game State functions

-- Game Logic
---- Check for winner
local function check_game_state (game_board, difficulty, curr_turn, taps)
    -- Check for horizontal, vertical, and diagonal wins
    win = nil
    if (game_board[1][7] == curr_turn and game_board[2][7] == curr_turn and game_board[3][7] == curr_turn) or
       (game_board[4][7] == curr_turn and game_board[5][7] == curr_turn and game_board[6][7] == curr_turn) or
       (game_board[7][7] == curr_turn and game_board[8][7] == curr_turn and game_board[9][7] == curr_turn) or
       (game_board[1][7] == curr_turn and game_board[4][7] == curr_turn and game_board[7][7] == curr_turn) or
       (game_board[2][7] == curr_turn and game_board[5][7] == curr_turn and game_board[8][7] == curr_turn) or
       (game_board[3][7] == curr_turn and game_board[6][7] == curr_turn and game_board[9][7] == curr_turn) or
       (game_board[1][7] == curr_turn and game_board[5][7] == curr_turn and game_board[9][7] == curr_turn) or
       (game_board[3][7] == curr_turn and game_board[5][7] == curr_turn and game_board[7][7] == curr_turn) then
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
        game_over(game_state)
    end

    if taps == 9 and win == nil then
        print("It's a draw")
        game_state = "draw"
        game_over(game_state)
    end
end

---- Play a move
local function play_move (cell_num, difficulty)
    local mode = difficulty == "hard" and "HARD COMPUTER" or difficulty == "easy" and "EASY COMPUTER"
                or difficulty == "player" and "PLAYER"
    gameInstance:execute_command(play_move_command:new(nil, cell_num, whichTurn))
    -- Add text to scene group

    print(mode.." ("..whichTurn..") ".."Cell Number: "..cell_num)
    taps = taps + 1 -- Increment tap counter to account for current move before checking game state 
    check_game_state(gameInstance:get_board(), difficulty, whichTurn, taps)
    -- Switch turns after checking game state so that the winner is displayed correctly
    whichTurn = whichTurn == X and O or X
end

-- Computer fill functions
---- COMPUTER TURN (HARD) 


local hard_mode_logic = require("hard_mode_logic") -- Import hard mode logic module
function computer_fill_hard (event)
    if game_state == "in_progress" then
        local hardModeInstance = hard_mode_logic:new(nil, gameInstance:get_board(), whichTurn, taps)
        local best_move = hardModeInstance:get_best_move()
        if best_move then
            play_move(best_move, 'hard')
        end
    end
end

---- COMPUTER TURN (EASY) - RANDOMLY FILL AN AVAILABLE CELL W/ O
local easy_mode_logic = require("easy_mode_logic") -- Import easy mode logic module
function computer_fill_easy ()
    if game_state == "in_progress" then
        local easyModeInstance = easy_mode_logic:new(nil, gameInstance:get_board(), taps)
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
            if event.x > gameInstance:get_board()[t][3] and event.x < gameInstance:get_board() [t][5] then
                if event.y < gameInstance:get_board()[t][4] and event.y > gameInstance:get_board()[t][6] then
                    if gameInstance:get_board()[t][7] == EMPTY then
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
    if startup then
        select_order()
        startup = false
    end
    current_difficulty = difficulty
    display_difficulty()
end

function scene:post_order_selection(order)
    gameInstance = game:new(nil, current_difficulty, order, nil)
    if order == "second" then
        computer_fill()
    end 
    create_undo_button()
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
        select_difficulty()
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












