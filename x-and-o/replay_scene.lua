local composer = require( "composer" )
 
local scene = composer.newScene()
 
local widget = require("widget")
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- content positioning constants
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

-- GAME CONSTANTS
local EMPTY, X, O = 0, "X", "O" -- Cell states

-- FONT CONSTANTS
local FONT = "Arial"
local TEXT_SIZE = 40
local BTN_TEXT_SIZE = 40

-- display object position constants
local game_over_y = h10 + h2_5
local buttonWidth = w20 + w2_5
local buttonHeight = h10
local buttonY = h90

-- Display objects
local difficultyText = nil
local buttonObjects = {}
local undoButton = nil
local resultText = nil
local winStrikethrough = nil
local replayText = nil

-- Variables to hold gameInstance data
local moveHistory = {}
local gameInstance = nil
local difficulty = nil
local player_order = nil
local result = nil
local pointer = 0

local playerTurn = nil
local computerTurn = nil

-- Import modules required to replay moves
local game = require("game_logic")
local play_move_command = require("play_move_logic")

local function new_game()
    composer.gotoScene("game_scene")
end

local function replay_move()
    local sceneGroup = scene.view
    if pointer < #moveHistory then
        -- pointer increments at start so that undo can be called on the correct command
        pointer = pointer + 1 
    
        local command = moveHistory[pointer]
        replayInstance:execute_command(command)
    end

    -- Display game result if last move is replayed
    if pointer == #moveHistory then
        resultText.isVisible = true
        if winStrikethrough then winStrikethrough.isVisible = true end
    end
end

local function undo_move()
    -- Only show game result and strikethrough on the last move
    if resultText.isVisible then resultText.isVisible = false end
    if winStrikethrough and winStrikethrough.isVisible then 
        winStrikethrough.isVisible = false
    end

    if pointer > 0 then
        replayInstance:undo()
        pointer = pointer - 1
    end
end

local function make_buttons (group)
    local backButton = widget.newButton(
        {
            label = "<",
            onRelease = undo_move,
            shape = "roundedRect",
            x = w20,
            y = h90,
            width = buttonWidth,
            height = buttonHeight,
            fontSize = BTN_TEXT_SIZE,
            font = FONT,
            labelColor = { default={0, 0, 0}, over={0, 0, 0} }
        }
    )
    group:insert(backButton)
    local forwardButton = widget.newButton(
        {
            label = ">",
            onRelease = replay_move,
            shape = "roundedRect",
            x = w80,
            y = h90,
            width = buttonWidth,
            height = buttonHeight,
            fontSize = BTN_TEXT_SIZE,
            font = FONT,
            labelColor = { default={0, 0, 0}, over={0, 0, 0} }
        }
    )
    group:insert(forwardButton)

    local returnButton = widget.newButton(
        {
            label = "Return",
            onRelease = new_game,
            shape = "roundedRect",
            x = w50,
            y = h90,
            width = buttonWidth,
            height = buttonHeight,
            fontSize = 16,
            font = FONT,
            labelColor = { default={0, 0, 0}, over={0, 0, 0} }
        }
    )
    group:insert(returnButton)
end

-- Initialise replay scene with game instance data
local function initialise_replay(params, group)
    -- get finished game instance variables from params
    moveHistory = params.gameInstance.moveHistory
    difficulty = params.gameInstance.difficulty
    playerOrder = params.gameInstance.player_order
    result = params.gameInstance.result
    winLineInfo = params.winLineInfo
    gameOverTextInfo = params.gameOverTextInfo
    
    playerTurn = player_order == "first" and X or O
    computerTurn = player_order == "first" and O or X

    -- Create and display the replay text
    replayText = d.newText("Replay", w2_5, h5, FONT, 12)
    replayText.anchorX = 0
    replayText:setFillColor(1, 0.5, 0) -- Set text color to orange
    group:insert(replayText)

    -- Create and display the difficulty text
    difficultyText = d.newText("Difficulty: "..difficulty:upper(), w10 - (w2_5/2), buttonY + (buttonHeight/2) + h2_5, FONT, 12)
    if difficulty == "easy" then
        difficultyText:setFillColor(0, 1, 0) -- Set text color to green
    elseif difficulty == "hard" then
        difficultyText:setFillColor(1, 0, 0) -- Set text color to red
    end
    difficultyText.anchorX = 0
    group:insert(difficultyText)

    -- create display objects for game result and hide them until last move is replayed
    resultText = d.newText(gameOverTextInfo.options)
    resultText:setFillColor(unpack(gameOverTextInfo.color))
    resultText.isVisible = false
    group:insert(resultText)

    if winLineInfo then
        -- Create strikethrough line for winning line
        winStrikethrough = d.newLine(winLineInfo.x1, winLineInfo.y1, winLineInfo.x2, winLineInfo.y2)
        winStrikethrough.strokeWidth = winLineInfo.strokeWidth
        winStrikethrough.alpha = winLineInfo.alpha
        winStrikethrough:setStrokeColor(winLineInfo.r, winLineInfo.g, winLineInfo.b)
        winStrikethrough.isVisible = false
        group:insert(winStrikethrough)
    end
    -- create game instance for replay
    replayInstance = game:new(nil, difficulty, player_order, group)
    
end




-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
     -- Code here runs when the scene is first created but has not yet appeared on screen

    local sceneGroup = self.view
    local params = event.params

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
    initialise_replay(params, sceneGroup)
    make_buttons(sceneGroup)

end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        -- Show difficulty selection overlay when scene is initially shown 

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