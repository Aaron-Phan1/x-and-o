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

--PLACE BOARD COMPARTMENT DIMENSIONS IN TABLE



-- GAME CONSTANTS
local taps = 0 -- track moves done
local EMPTY, X, O = 0, "X", "O" -- Cell states
local whichTurn = X -- X is starting game
local gameState = nil
local winningCells = nil


-- FONT CONSTANTS
local FONT = "Arial"
local TEXT_SIZE = 40
local BTN_TEXT_SIZE = 16

-- display object constants
local game_over_y = h10 + h2_5
local buttonWidth = w20 + w2_5
local buttonHeight = h10
local buttonGap = w5 + w2_5
local buttonY = h90

-- Fill function for computer based on difficulty
local current_difficulty = nil
local playerOrder = nil
local playerTurn = nil
local computerTurn = nil
local computer_fill = nil 

-- Display objects
local difficultyText = nil
local buttonObjects = {}
local undoButton = nil
local gameOverText = nil
local winStrikethrough = nil
-- OVERLAY FUNCTIONS

-- forward declaration so that the function can be called before it is defined
local computer_fill_hard
local computer_fill_easy


local game = require("game_logic")
local play_move_command = require("play_move_logic")
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

local function display_difficulty()

    display.remove(difficultyText)
    difficultyText = nil

    local sceneGroup = scene.view
    difficultyText = d.newText("Difficulty: "..current_difficulty:upper(), w10 - (w2_5/2), buttonY + (buttonHeight/2) + h2_5, FONT, 12)
    if current_difficulty == "easy" then
        difficultyText:setFillColor(0, 1, 0) -- Set text color to green
    elseif current_difficulty == "hard" then
        difficultyText:setFillColor(1, 0, 0) -- Set text color to red
    end
    difficultyText.anchorX = 0
    sceneGroup:insert(difficultyText)
end

local function change_difficulty(event)
    current_difficulty = current_difficulty == "hard" and "easy" or "hard"
    difficultyText.text = "Difficulty: "..current_difficulty:upper()
    difficultyText:setFillColor(current_difficulty == "easy" and 0 or 1, current_difficulty == "hard" and 0 or 1, 0)
end

local function create_undo_button()
    local sceneGroup = scene.view
    undoButton = widget.newButton(
        {
            label = "Undo",
            labelColor = { default={0,0,0,1 }},
            onRelease = undo_last_player_move,
            shape = "roundedRect",
            width = buttonWidth,
            height = buttonHeight,
            x = w80,
            y = buttonY,
            fontSize = BTN_TEXT_SIZE
        }
    )

    undoButton:setFillColor(0.5, 0.5, 0)
    undoButton:setEnabled(false)
    sceneGroup:insert(undoButton)
end

local function enable_undo ()
    undoButton:setEnabled(true)

    undoButton:setFillColor(1, 1, 0)
end

local function disable_undo ()
    undoButton:setEnabled(false)

    undoButton:setFillColor(0.5, 0.5, 0)
end

function undo_last_player_move ()
    -- Undo moves until the last player move
    while gameInstance.moveHistory[#gameInstance.moveHistory]:get_curr_turn() ~= playerTurn do
        gameInstance:undo()
        taps = taps - 1
    end
    -- Undo the player's last move
    gameInstance:undo()
    taps = taps - 1
    disable_undo()
end


-- Game Over function
local function play_again ()
    local sceneGroup = scene.view

    -- cleanup game_over objects
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

    display.remove(winStrikethrough)
    winStrikethrough = nil

    -- go to order selection before initialising new game
    select_order()

end

local function watch_replay ()
    local sceneGroup = scene.view

    -- go to replay scene
    composer.gotoScene("replay_scene", {params = {gameInstance = gameInstance, winStrikethrough = winStrikethrough}})
end

local function initialise_game (group)
    taps = 0
    whichTurn = X
    gameState = "in_progress"
    winningCells = nil
    winDirection = nil
    
    if current_difficulty == "hard" then
        computer_fill = computer_fill_hard
    elseif current_difficulty == "easy" then
        computer_fill = computer_fill_easy
    end

    gameInstance = game:new(nil, current_difficulty, playerOrder, group)
    
    if playerOrder == "second" then
        computer_fill()
    end 

    create_undo_button()

end

local function game_over(gameState)
    -- Remove display objects from previous game state
    display.remove(undoButton)
    undoButton = nil

    gameInstance.result = gameState
    local sceneGroup = scene.view
    if gameState == "player_won" then
        gameOverText = d.newText("You Win", d.contentCenterX, game_over_y, FONT, TEXT_SIZE)
        gameOverText:setFillColor(0, 1, 0) -- Set text color to green
    elseif gameState == "ai_won" then
        gameOverText = d.newText("You Lose", d.contentCenterX, game_over_y, FONT, TEXT_SIZE)
        gameOverText:setFillColor(1, 0, 0) -- Set text color to red
    elseif gameState == "draw" then
        gameOverText = d.newText("Draw", d.contentCenterX, game_over_y, FONT, TEXT_SIZE)
        gameOverText:setFillColor(0, 0, 1) -- Set text color to blue
    end
    sceneGroup:insert(gameOverText)
    
    -- Draw line through winning cells
    if winningCells then
        if winDirection == "diagonal" then
            if winningCells[1] == 1 then
                winStrikethrough = d.newLine(gameInstance.board[winningCells[1]][3], gameInstance.board[winningCells[1]][6], gameInstance.board[winningCells[3]][5], gameInstance.board[winningCells[3]][4])
            elseif winningCells[1] == 3 then
                winStrikethrough = d.newLine(gameInstance.board[winningCells[1]][5], gameInstance.board[winningCells[1]][6], gameInstance.board[winningCells[3]][3], gameInstance.board[winningCells[3]][4])
            end
        elseif winDirection == "horizontal" then
            local halfwayY = (gameInstance.board[winningCells[1]][4] + gameInstance.board[winningCells[1]][6]) / 2
            winStrikethrough = d.newLine(gameInstance.board[winningCells[1]][3], halfwayY, gameInstance.board[winningCells[3]][5], halfwayY)
        elseif winDirection == "vertical" then
            local halfwayX = (gameInstance.board[winningCells[1]][3] + gameInstance.board[winningCells[1]][5]) / 2
            winStrikethrough = d.newLine(halfwayX, gameInstance.board[winningCells[1]][6], halfwayX, gameInstance.board[winningCells[3]][4])
        end
        winStrikethrough.strokeWidth = 5
        winStrikethrough.alpha = 0.8
        local winningCellsType = gameInstance.board[winningCells[1]][7]
        winStrikethrough:setStrokeColor(winningCellsType == X and 0 or 1, 0, winningCellsType == X and 1 or 0)
        sceneGroup:insert(winStrikethrough)
    end


    local buttons = {
        {label = "Change\nDifficulty", onRelease = change_difficulty},
        {label = "Play\nAgain", onRelease = play_again},
        {label = "Watch\nReplay", onRelease = watch_replay}
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
                fontSize = BTN_TEXT_SIZE
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
    local winning_combinations = {
        -- Horizontal wins
        {1, 2, 3, direction = "horizontal"}, 
        {4, 5, 6, direction = "horizontal"}, 
        {7, 8, 9, direction = "horizontal"}, 
        -- Vertical wins
        {1, 4, 7, direction = "vertical"}, 
        {2, 5, 8, direction = "vertical"}, 
        {3, 6, 9, direction = "vertical"},
        -- Diagonal wins
        {1, 5, 9, direction = "diagonal"}, 
        {3, 5, 7, direction = "diagonal"} 
    }

    for _, combination in ipairs(winning_combinations) do
        if game_board[combination[1]][7] == curr_turn and
           game_board[combination[2]][7] == curr_turn and
           game_board[combination[3]][7] == curr_turn then
            win = true
            winningCells = combination
            winDirection = combination.direction
            break
        end
    end

    if win == true then
        if difficulty == "player" then
            print("You Win")
            gameState = "player_won"
        else 
            print("You Lose")
            gameState = "ai_won"
        end
        game_over(gameState)
    end

    if taps == 9 and win == nil then
        print("It's a draw")
        gameState = "draw"
        game_over(gameState)
    end
end

---- Play a move
local function play_move (cell_num, player_type)

    gameInstance:execute_command(play_move_command:new({cell_num = cell_num, curr_turn = whichTurn}))
    if player_type == "player" then
        enable_undo()
    end

    local player_lookup = {
        hard = "HARD COMPUTER",
        easy = "EASY COMPUTER",
        player = "PLAYER"
    }

    print(string.format("%s (%s) Cell Number: %d", player_lookup[player_type], whichTurn, cell_num))
    taps = taps + 1 -- Increment tap counter to account for current move before checking game state 
    check_game_state(gameInstance:get_board(), player_type, whichTurn, taps)

    -- Switch turns after checking game state so that the winner is called correctly in check_game_state
    whichTurn = whichTurn == X and O or X


end

-- Computer fill functions
---- COMPUTER TURN (HARD) 


local hard_mode_logic = require("hard_mode_logic") -- Import hard mode logic module
function computer_fill_hard (event)
    if gameState == "in_progress" then
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
    if gameState == "in_progress" then
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
    if event.phase == "began" and gameState == "in_progress" then
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
    -- initial difficulty selection when scene shows
    current_difficulty = difficulty
    display_difficulty()
    select_order()
end

function scene:post_order_selection(order)
    local sceneGroup = scene.view
    playerOrder = order
    playerTurn = playerOrder == "first" and X or O 
    computerTurn = playerOrder == "first" and O or X
    initialise_game(sceneGroup)
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