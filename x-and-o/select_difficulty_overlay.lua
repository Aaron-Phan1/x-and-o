local composer = require( "composer" )
 
local scene = composer.newScene()

local widget = require("widget")
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
d = display
w20 = d.contentWidth * .2
w40 = d.contentWidth * .4
w60 = d.contentWidth * .6
w80 = d.contentWidth * .8

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
element_gap = h2_5
buttonHeight = h10

-- font constants
local FONT = "Arial"
local TEXT_SIZE = 24
local BTN_TEXT_SIZE = 18
local selectedButton = nil

-- Save the selected difficulty before hiding the overlay
local function handle_button_event(event)
    selectedButton = event.target.difficulty
    composer.hideOverlay("slideRight", 500)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    -- Create a window for the difficulty selection
    local selection_window = d.newRect(d.contentCenterX, d.contentCenterY, w80, h40)
    selection_window:setFillColor(0.6, 0.4, 0.2)
    selection_window.strokeWidth = 4
    
    -- Create text for selecting difficulty
    local selection_text = d.newText("Select Difficulty", d.contentWidth/2, h30 + h5, FONT, TEXT_SIZE)
  
    -- Create buttons for selecting difficulty
    local easyButton = widget.newButton(
        {
            label = "Easy",
            onRelease = handle_button_event,
            -- Properties for a rounded rectangle button
            labelColor = { default={0,0,0}, over={0,0,0} },
            shape = "roundedRect",
            width = w60,
            height = h10,
            x = display.contentCenterX,
            y = selection_text.y + buttonHeight + element_gap,
            cornerRadius = 2,
            fillColor = { default={0,1,0,1}, over={0.5,1,0.5,1} },
            strokeColor = { default={0,0.5,0,1}, over={0.3,0.8,0.3,1} },
            strokeWidth = 4,
            fontSize = BTN_TEXT_SIZE
        }
    )
    easyButton.difficulty = "easy" -- Add a custom property to the button object

    local hardButton = widget.newButton(
        {
            label = "Hard",
            onRelease = handle_button_event,
            -- Properties for a rounded rectangle button
            labelColor = { default={0,0,0}, over={0,0,0} },
            shape = "roundedRect",
            width = w60,
            height = h10,
            x = display.contentCenterX,
            y = easyButton.y + buttonHeight + element_gap,
            cornerRadius = 2,
            fillColor = { default={1,0,0,1}, over={1,0.5,0.5,1} },
            strokeColor = { default={0.5,0,0,1}, over={0.8,0.3,0.3,1} },
            strokeWidth = 4,
            fontSize = BTN_TEXT_SIZE
        }
    )
    hardButton.difficulty = "hard"

    -- Add the display objects to the scene group
    sceneGroup:insert(selection_window)
    sceneGroup:insert(selection_text)
    sceneGroup:insert(easyButton)
    sceneGroup:insert(hardButton)  

end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
    end
end
 
 
-- hide()
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    -- Get the parent scene
    local parent = event.parent

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

        -- Pass the selected difficulty back to the parent scene
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        parent:post_difficulty_selection(selectedButton)
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
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