local composer = require( "composer" )
 
local scene = composer.newScene()

local widget = require("widget")

local M = require("M")
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- GAME CONSTANTS
local taps = 0 -- track moves done
local EMPTY, X, O = 0, "X", "O" -- Cell states
local whichTurn = X -- X is starting game

-- Game state variables
local gameState = nil
local winningCells = nil
local winDirection = nil
local gameOverTextInfo = {}
local winLineInfo = nil
local playerTurn = nil
local difficulty = nil
local computer_fill = nil 

-- Variables to handle transitions between game scene and replay, and game scene and profile selection
local initial_load = true
local renew_replay = false

-- FONT CONSTANTS
local FONT = "Arial"
local TEXT_SIZE = 40
local BTN_TEXT_SIZE = 16
local SCORE_TEXT_SIZE = 12

-- display object constants
local gameOverY = h10 + h2_5
local buttonWidth = w20 + w2_5
local buttonHeight = h10
local buttonGap = w5 + w2_5
local buttonY = h90

-- Display objects
local easyText = nil
local hardText = nil
local buttonObjects = {}
local undoButton = nil
local gameOverText = nil
local winStrikethrough = nil

-- Profile display objects
local profileText = nil
local profileNum = nil
local profileId = nil
local easyTextObjects = {}
local hardTextObjects = {}

-- forward declaration so that function order doesn't matter
local computer_fill_hard
local computer_fill_easy
local select_difficulty
local select_order
local display_difficulty
local change_difficulty
local create_undo_button
local enable_undo
local disable_undo
local drawWinLine
local undo_last_player_move
local play_again
local watch_replay
local display_game_over_objects
local initialise_game
local game_over
local check_game_state
local play_move
local computer_fill_hard
local computer_fill_easy
local record_result
local display_score
local display_profile
local change_profile_btn
local change_profile
local recalculate_score_pos
local get_latest_profile_data
local fill

-- Import modules required for making and display moves 
-- using command pattern to support undo
local game = require("game_instance")
local play_move_command = require("play_move_logic") 

-- Import modules required for computer moves
local hard_mode_logic = require("hard_mode_logic") 
local easy_mode_logic = require("easy_mode_logic") 
-- -----------------------------------------------------------------------------------
---- Overlay scene transitions
-- Show overlay to select difficulty
function select_difficulty(event)
    local options = {
        effect = "fromLeft",
        time = 500,
        isModal = true
    }
    composer.showOverlay("select_difficulty_overlay", options)
end

-- Show overlay to choose whether to go first or second
-- Order selection is called right before initialising the game
function select_order(event)
    local options = {
        effect = "fromLeft",
        time = 200,
        isModal = true
    }
    composer.showOverlay("select_order_overlay", options)
end

-- -----------------------------------------------------------------------------------
---- Display object creation functions
-- Display profile name top left of screen
function display_profile_name (group)
    local profiles = M.load_table("profiles.json")
    local profile = profiles[profileNum]
    profileText = d.newText(profile.name, w2_5, h5 + h2_5/2, FONT, 16)
    profileText:setFillColor(0.8, 0.5, 0.3)
    profileText.anchorX = 0
    group:insert(profileText)
end

-- Change profile button to go back to profile selection - beneath profile name
function change_profile_btn (group)
    local changeProfileBtn = widget.newButton(
        {
            label = "Change",
            labelColor = { default={0.8, 0.8, 0.8}, over={1, 1, 1} },
            onRelease = change_profile,
            shape = "roundedRect",
            width = w10 + w2_5,
            height = h2_5 + h2_5/2,
            x = w2_5,
            y = profileText.y + profileText.height + h2_5/3,
            strokeWidth = 2,
            strokeColor = {default = {0.3,0.15, 0.05}, over = {0.5, 0.25, 0.1}},
            fillColor = {default = {0.6, 0.3, 0.1}, over = {0.8, 0.4, 0.2}},
            fontSize = 9,
            onRelease = change_profile
        }
    )
    changeProfileBtn.anchorX = 0

    group:insert(changeProfileBtn)
end

-- Difficulty text bottom left of screen
function display_difficulty(group)
    easyText = d.newText("EASY", w2_5, buttonY + (buttonHeight/2) + h2_5, FONT, SCORE_TEXT_SIZE)
    easyText:setFillColor(unpack(easyColour)) -- Set text colour to green
    easyText.anchorX = 0
    easyText.isVisible = difficulty == "easy"
    group:insert(easyText)
    table.insert(easyTextObjects, easyText)

    hardText = d.newText("HARD", w2_5, buttonY + (buttonHeight/2) + h2_5, FONT, SCORE_TEXT_SIZE)
    hardText:setFillColor(unpack(hardColour)) -- Set text colour to red
    hardText.anchorX = 0
    hardText.isVisible = difficulty == "hard"
    group:insert(hardText)
    table.insert(hardTextObjects, hardText)
end


-- The score for selected difficulty - appears to the right of difficulty text
function display_score (group)
    local profiles = M.load_table("profiles.json")
    local profile = profiles[profileNum]
    local textTypes = {"win", "loss", "draw"}
    local colours = {
        win = {0, 1, 0}, -- Green for wins
        loss = {1, 0, 0}, -- Red for losses
        draw = {0, 0, 1} -- Blue for draws
    }

    -- To aid in positioning score text objects to the right of the difficulty text
    -- Hard text is used since it is longer than easy text
    local previousHardText = hardText
    local previousEasyText = hardText

    -- Create text objects for each score type - W: L: D:
    for i, textType in ipairs(textTypes) do
        local hardText = d.newText(string.upper(textType:sub(1, 1)) .. ": " .. profile.hard[textType], previousHardText.x + previousHardText.width + w2_5, hardText.y, FONT, SCORE_TEXT_SIZE)
        hardText:setFillColor(unpack(colours[textType]))
        hardText.anchorX = 0
        hardText.isVisible = difficulty == "hard"
        group:insert(hardText)
        table.insert(hardTextObjects, hardText)
        previousHardText = hardText

        local easyText = d.newText(string.upper(textType:sub(1, 1)) .. ": " .. profile.easy[textType], previousEasyText.x + previousEasyText.width + w2_5, easyText.y, FONT, SCORE_TEXT_SIZE)
        easyText:setFillColor(unpack(colours[textType]))
        easyText.anchorX = 0
        easyText.isVisible = difficulty == "easy"
        group:insert(easyText)
        table.insert(easyTextObjects, easyText)
        previousEasyText = easyText
    end
end

-- Undo button is displayed when game is in progress
function create_undo_button()
    local sceneGroup = scene.view
    undoButton = widget.newButton(
        {
            label = "Undo",
            labelColor = { default={0,0,0,1 }},
            onRelease = undo_last_player_move,
            shape = "roundedRect",
            width = buttonWidth,
            height = buttonHeight,
            strokeWidth = 3,
            strokeColor = {default = {0.3,0.3,0}, over = {0.3,0.3,0}},
            x = w80,
            y = buttonY,
            fontSize = BTN_TEXT_SIZE
        }
    )
    -- Colour is darker when button is disabled
    undoButton:setFillColor(0.5, 0.5, 0)
    undoButton:setEnabled(false)
    sceneGroup:insert(undoButton)
end

-- Line is drawn through winning cells (if any) when game is over
function drawWinLine (group)
    local x1, y1, x2, y2
    winLineInfo = {}

    -- Calculate line coordinates based on winning cells and direction
    if winDirection == "diagonal" then
        if winningCells[1] == 1 then
            x1, y1 = gameInstance.board[1][3], gameInstance.board[1][6]
            x2, y2 = gameInstance.board[9][5], gameInstance.board[9][4]
        else
            x1, y1 = gameInstance.board[3][5], gameInstance.board[3][6]
            x2, y2 = gameInstance.board[7][3], gameInstance.board[7][4]
        end
    elseif winDirection == "horizontal" then
        y1 = (gameInstance.board[winningCells[1]][4] + gameInstance.board[winningCells[1]][6]) / 2
        y2 = y1
        x1, x2 = gameInstance.board[winningCells[1]][3], gameInstance.board[winningCells[3]][5]
    elseif winDirection == "vertical" then
        x1 = (gameInstance.board[winningCells[1]][3] + gameInstance.board[winningCells[1]][5]) / 2
        x2 = x1
        y1, y2 = gameInstance.board[winningCells[1]][6], gameInstance.board[winningCells[3]][4]
    end

    winStrikethrough = d.newLine(x1, y1, x2, y2)
    winStrikethrough.strokeWidth = 5
    winStrikethrough.alpha = 0.8

    -- Set line colour based on X or O winning
    local winningCellsType = gameInstance.board[winningCells[1]][7]
    local r, g, b = winningCellsType == X and 0 or 1, 0, winningCellsType == X and 1 or 0

    winStrikethrough:setStrokeColor(r, g, b)

    group:insert(winStrikethrough)

    -- Record line info to recreate in replay scene
    winLineInfo.x1, winLineInfo.y1, winLineInfo.x2, winLineInfo.y2 = x1, y1, x2, y2
    winLineInfo.strokeWidth = 5  
    winLineInfo.alpha = 0.8
    winLineInfo.r, winLineInfo.g, winLineInfo.b = r, g, b  
end

-- Display game over text and buttons for changing difficulty, playing again, and watching replay
function display_game_over_objects(group)
    -- Change difficulty button is a shortcut to the difficulty selection overlay
    local buttonOptions = {
        {label = "Change\nDifficulty", onRelease = change_difficulty}, 
        {label = "Play\nAgain", onRelease = play_again},
        {label = "Watch\nReplay", onRelease = watch_replay}
    }

    local buttonX = w20
    for i, buttonConfig in ipairs(buttonOptions) do
        local button = widget.newButton(
            {
                label = buttonConfig.label,
                labelColor = { default={0,0,0}, over={0,0,0} },
                shape = "roundedRect",
                width = buttonWidth,
                height = buttonHeight,
                onRelease = buttonConfig.onRelease,
                strokeWidth = 3,
                strokeColor = {default = {0.5,0.5,0.5}, over = {0.7,0.7,0.7}},
                fillColor = {default = {0.95, 0.95, 0.95}, over = {1, 1, 1}},
                x = buttonX,
                y = buttonY,
                fontSize = BTN_TEXT_SIZE
            }
        )
        group:insert(button)
        table.insert(buttonObjects, button)
        buttonX = buttonX + buttonWidth + buttonGap -- based off x and y being the center of the button
    end

    -- Display game over text
    local textOptions = {
        player_won = {text = "You Win", colour = {0, 1, 0}},
        ai_won = {text = "You Lose", colour = {1, 0, 0}},
        draw = {text = "Draw", colour = {0, 0, 1}}
    }

    local options = textOptions[gameState]
    gameOverText = d.newText(options.text, d.contentCenterX, gameOverY, FONT, TEXT_SIZE)
    gameOverText:setFillColor(unpack(options.colour))

    group:insert(gameOverText)

    -- Record game over text info to recreate in replay scene
    gameOverTextInfo.options = {text = options.text, x = d.contentCenterX, y = gameOverY, font = FONT, fontSize = TEXT_SIZE}
    gameOverTextInfo.color = options.colour
end

---- End of display object creation functions
-- -----------------------------------------------------------------------------------
---- Button event handlers

-- Change profile button handler - available at all times in game scene
function change_profile(event)
    local options = {
        effect = "fade",
        time = 100,
        params = {previousId = profileId}
    }
    composer.removeScene("profile_selection")
    composer.gotoScene("profile_selection", options)
end


-- Undo button handler - available during game in progress
-- Uses command pattern functionality in play_move_logic and game_instance modules
function undo_last_player_move ()
    -- Undo move if the last move was made by the computer
    if gameInstance.moveHistory[#gameInstance.moveHistory]:get_curr_turn() ~= playerTurn then
        gameInstance:undo()
        taps = taps - 1
    end

    -- Undo the player's last move
    gameInstance:undo()
    taps = taps - 1
    disable_undo() -- Disable undo since the player's last move has been undone
end

function disable_undo ()
    undoButton:setEnabled(false)
    undoButton:setFillColor(0.5, 0.5, 0)
end

-- Change difficulty shortcut button handler -- available after game over
function change_difficulty(event)
    difficulty = difficulty == "easy" and "hard" or "easy"
    local showObjects, hideObjects = difficulty == "easy" and easyTextObjects or hardTextObjects, difficulty == "easy" and hardTextObjects or easyTextObjects
    for _, textObject in ipairs(showObjects) do
        textObject.isVisible = true
    end
    for _, textObject in ipairs(hideObjects) do
        textObject.isVisible = false
    end
end

-- Play again button handler - available after game over
function play_again ()
    local sceneGroup = scene.view

    -- cleanup game_over objects
    display.remove(gameOverText)
    gameOverText = nil

    display.remove(winStrikethrough)
    winStrikethrough = nil

    -- Reset board state
    for i = 1, 9 do
        display.remove(gameInstance.board[i][8])
        gameInstance.board[i][8] = nil
    end
    -- Remove game over text and buttons
    for btn_index, button in ipairs(buttonObjects) do
        display.remove(button)
        buttonObjects[btn_index] = nil
    end

    -- go to order selection before initialising new game
    select_order()

end

-- Watch replay button handler - available after game over
function watch_replay ()
    local sceneGroup = scene.view
    local options = {
        effect = "fade",
        time = 100,
        params = {
            -- Pass gameInstance data to replay scene
            -- Pass winLineInfo and gameOverTextInfo to recreate display objects in replay scene
            gameInstance = gameInstance, 
            winLineInfo = winLineInfo, 
            gameOverTextInfo = gameOverTextInfo
        }
    }
    -- Remove replay scene of previous game
    if renew_replay then 
        renew_replay = false
        composer.removeScene("replay_scene")
    end

    composer.gotoScene("replay_scene", options)
end

---- End of button event handlers
-- -----------------------------------------------------------------------------------
---- Game State functions
-- Initialise game state variables and game board
-- Called after order selection (go first or second)
function initialise_game (group)
    -- Reset game state variables
    taps = 0
    whichTurn = X
    gameState = "in_progress"
    winningCells = nil
    winDirection = nil
    winLineInfo = nil
    gameOverTextInfo = {}
    renew_replay = true

    if difficulty == "hard" then
        computer_fill = computer_fill_hard
    elseif difficulty == "easy" then
        computer_fill = computer_fill_easy
    end

    gameInstance = game:new(nil, difficulty, group)
    
    -- playerTurn is set in select_order
    if playerTurn == O then
        computer_fill()
    end 

    create_undo_button()

end

---Check for win/draw - called after each move
function check_game_state (game_board, difficulty, curr_turn, taps)
    -- Check for horizontal, vertical, and diagonal wins
    local win = nil
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
            
            -- Record winning cells and direction for drawing line through winning cells
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
    -- taps == 9 means all cells are filled
    if taps == 9 and win == nil then
        print("It's a draw")
        gameState = "draw"
        game_over(gameState)
    end
end

-- Game over function - called when game is won or drawn
function game_over(gameState)
    -- Update profile record (win/loss/draw) with game result
    record_result(gameState, gameInstance.difficulty)

    -- Update profile display objects with latest score
    get_latest_profile_data()

    -- Remove display object from previous game state
    display.remove(undoButton)
    undoButton = nil

    -- Bind the game result to the game instance object
    gameInstance.result = gameState
    
    local sceneGroup = scene.view
    -- Draw line through winning cells
    if winningCells then
        drawWinLine(sceneGroup)
    end

    -- Display game over text and change difficulty, play again, and watch replay buttons
    display_game_over_objects(sceneGroup, gameState)
end

---- End of game state functions
-- -----------------------------------------------------------------------------------
---- Game Logic functions
-- Used to play moves for player and computer
function play_move (cell_num, player_type)
    -- Command pattern to support undo
    gameInstance:execute_command(play_move_command:new({cell_num = cell_num, curr_turn = whichTurn}))

    -- Enable undo button after player's move
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

-- Enable undo button after player's move
function enable_undo ()
    undoButton:setEnabled(true)
    undoButton:setFillColor(1, 1, 0)
end

---- Computer move logic
-- COMPUTER TURN (HARD) 
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
function computer_fill_easy ()
    if gameState == "in_progress" then
        local easyModeInstance = easy_mode_logic:new(nil, gameInstance:get_board(), taps)
        local best_move = easyModeInstance:get_best_move()
        if best_move then
            play_move(best_move, 'easy')
        end
    end
end
---- End of game logic functions
-- -----------------------------------------------------------------------------------
---- Data persistence functions
-- Save game result to file
function record_result (gameState, gameDifficulty)
    local profiles = M.load_table("profiles.json")
    local diff = gameDifficulty
    -- Update profile's respective record
    if profiles and profileNum then
        local profile = profiles[profileNum]
        if profile then
            if gameState == "player_won" then
                profile[diff].win = profile[diff].win + 1
            elseif gameState == "ai_won" then
                profile[diff].loss = profile[diff].loss + 1
            elseif gameState == "draw" then
                profile[diff].draw = profile[diff].draw + 1
            end
            M.save_table(profiles, "profiles.json")
        end
    end
end
-- -----------------------------------------------------------------------------------
-- Profile display update functions
-- Recalculate positions of score text objects
function recalculate_score_pos ()
    -- Recalculate positions
    local hardWinText, hardLossText, hardDrawText = hardTextObjects[2], hardTextObjects[3], hardTextObjects[4]
    local easyWinText, easyLossText, easyDrawText = easyTextObjects[2], easyTextObjects[3], easyTextObjects[4]

    hardLossText.x = hardWinText.x + hardWinText.width + w2_5

    hardDrawText.x = hardLossText.x + hardLossText.width + w2_5

    easyLossText.x = easyWinText.x + easyWinText.width + w2_5

    easyDrawText.x = easyLossText.x + easyLossText.width + w2_5
end

-- Update profile display objects with latest data
function get_latest_profile_data ()
    local profiles = M.load_table("profiles.json")
    local profile = profiles[profileNum]

    local hardWinText, hardLossText, hardDrawText = hardTextObjects[2], hardTextObjects[3], hardTextObjects[4]
    local easyWinText, easyLossText, easyDrawText = easyTextObjects[2], easyTextObjects[3], easyTextObjects[4]

    hardWinText.text = "W: " .. profile["hard"].win
    hardLossText.text = "L: " .. profile["hard"].loss
    hardDrawText.text = "D: " .. profile["hard"].draw
    easyWinText.text = "W: " .. profile["easy"].win
    easyLossText.text = "L: " .. profile["easy"].loss
    easyDrawText.text = "D: " .. profile["easy"].draw

    profileText.text = profile.name

    recalculate_score_pos()

end
-- -----------------------------------------------------------------------------------
-- Runtime touch event handler
function fill (event)
    if event.phase == "began" and gameState == "in_progress" then
        for t = 1, 9 do -- Check which tile was touched
            if event.x > gameInstance:get_board()[t][3] and event.x < gameInstance:get_board() [t][5] then
                if event.y < gameInstance:get_board()[t][4] and event.y > gameInstance:get_board()[t][6] then
                    if gameInstance:get_board()[t][7] == EMPTY then
                        play_move(t, "player") -- Player move
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
-- Handle parameter passed from difficulty selection overlay
function scene:post_difficulty_selection(selected_difficulty)
    local sceneGroup = scene.view
    -- initial difficulty selection when scene is created
    difficulty = selected_difficulty
    display_difficulty(sceneGroup)
    display_score(sceneGroup)
    select_order()
end

-- Handle parameter passed from order selection overlay
function scene:post_order_selection(order)
    local sceneGroup = scene.view
    playerTurn = order == "first" and X or O 
    initialise_game(sceneGroup)
end

-- create()
function scene:create( event )
    local sceneGroup = self.view
    local params = event.params
    -- Set profile number and id from parameters passed from profile selection scene
    profileNum = params.profileNum
    profileId = params.profileId

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

    -- Display profile name and change profile button
    display_profile_name (sceneGroup)
    change_profile_btn(sceneGroup)
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

        -- Show difficulty selection overlay when scene is initially created and shown 
        if initial_load then
            select_difficulty()
            initial_load = false
        else
            -- Update profile display objects with latest data
            -- in the case of returning to the game scene after clearing scores
            get_latest_profile_data()
        end
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
    -- Code here runs prior to the removal of scene's view

    Runtime:removeEventListener("touch", fill)
 
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