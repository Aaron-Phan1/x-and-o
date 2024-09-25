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
local element_gap = h2_5
local buttonHeight = h10
local top_of_window = d.contentCenterY - (h30 + element_gap) / 2
-- font constants
local FONT = "Arial"
local baseFontSize = 24
local adjustedSize = baseFontSize * display.contentHeight / 480
local selectedButton = nil

-- Save the selected difficulty before hiding the overlay
local function handle_button_event(event)
    selectedButton = event.target.order
    composer.hideOverlay("slideRight", 200)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    -- Create a window for the difficulty selection

    
    -- Create text for selecting difficulty

    -- Create buttons for selecting difficulty
    local goFirstButton = widget.newButton(
        {
            label = "Go 1st (X)",
            onRelease = handle_button_event,
            -- Properties for a rounded rectangle button
            labelColor = { default={0,0,0}, over={0,0,0} },

            shape = "roundedRect",
            width = w40,
            height = h10,
            x = display.contentCenterX,
            y = top_of_window + buttonHeight,
            cornerRadius = 2,
            fillColor = { default={0.3,0.3,1,1}, over={0.5,0.5,1,1} },
            strokeColor = { default={0,0,0.5,1}, over={0.3,0.3,0.8,1} },
            strokeWidth = 4,


        }
    )
    goFirstButton.order = "first" -- Add a custom property to the button object

    local goSecondButton = widget.newButton(
        {
            label = "Go 2nd (O)",
            onRelease = handle_button_event,
            -- Properties for a rounded rectangle button
            labelColor = { default={0,0,0}, over={0,0,0} },
            shape = "roundedRect",
            width = w40,
            height = h10,
            x = display.contentCenterX,
            y = goFirstButton.y + buttonHeight + element_gap,
            cornerRadius = 2,
            fillColor = { default={1,0,0,1}, over={1,0.5,0.5,1} },
            strokeColor = { default={0.5,0,0,1}, over={0.8,0.3,0.3,1} },
            strokeWidth = 4,

        }
    )
    goSecondButton.order = "second"

    -- Add the display objects to the scene group

    sceneGroup:insert(goFirstButton)
    sceneGroup:insert(goSecondButton)  

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
        parent:post_order_selection(selectedButton)
        
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