local composer = require( "composer" )
 
local scene = composer.newScene()
local widget = require("widget")   
 

-- display object constants
local element_gap = h5
local buttonHeight = h10
local buttonWidth = w30

-- font constants
local FONT = "Arial"
local TEXT_SIZE = 12
local BTN_TEXT_SIZE = 18
local selectedButton = nil

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function handle_button_event(event)
    selectedButton = event.target.mode
    composer.hideOverlay()
end

local function make_buttons (group, type)
    local command_type = type
    local selection_window = d.newRect(d.contentCenterX, d.contentCenterY, w90, h20 + h2_5)
    selection_window:setFillColor(1,1,1)
    selection_window.strokeWidth = 4
    selection_window:setStrokeColor(0.5,0.5,0.5)

    
    -- Create text for selecting difficulty
    local text = ""
    if type == "Delete" then
        text = "Are you sure you want to delete this profile?"
    elseif type == "Clear" then
        text = "Are you sure you want to clear the score?"
    end
    local selection_text = d.newText(text, d.contentWidth/2, d.contentCenterY - h5 - h2_5, FONT, TEXT_SIZE)
    selection_text:setFillColor(0,0,0)
    -- Create buttons for selecting difficulty
    
    local hardButton = widget.newButton(
        {
            label = "Cancel",
            onRelease = handle_button_event,
            -- Properties for a rounded rectangle button
            labelColor = { default={0,0,0}, over={0,0,0} },
            shape = "roundedRect",
            x = display.contentCenterX - buttonWidth/2 - w2_5,
            y = selection_text.y + buttonHeight/2 + element_gap,
            width = buttonWidth,
            height = buttonHeight,
            cornerRadius = 2,
            fillColor = { default={0.5,0.5,0.5,1}, over={0.7,0.7,0.7,1} },
            strokeColor = { default={0.3,0.3,0.3,1}, over={0.5,0.5,0.5,1} },
            strokeWidth = 4,
            fontSize = BTN_TEXT_SIZE
        }
    )
    hardButton.mode = "NO"

    local easyButton = widget.newButton(
        {
            label = command_type,
            onRelease = handle_button_event,
            -- Properties for a rounded rectangle button
            labelColor = { default={0,0,0}, over={0,0,0} },
            shape = "roundedRect",
            x =  display.contentCenterX + buttonWidth/2 + w2_5,
            y = hardButton.y,
            width = buttonWidth,
            height = buttonHeight,
            cornerRadius = 2,
            fillColor = { default={1,0,0,1}, over={1,0.5,0.5,1} },
            strokeColor = { default={0.5,0,0,1}, over={0.8,0.3,0.3,1} },
            strokeWidth = 4,
            fontSize = BTN_TEXT_SIZE
        }
    )
    easyButton.mode = "YES"

    -- Add the display objects to the scene group
    group:insert(selection_window)
    group:insert(selection_text)
    group:insert(easyButton)
    group:insert(hardButton)  
end
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    local command_type = event.params.type
    make_buttons(sceneGroup, command_type)
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
 
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
    local parent = event.parent
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        parent:post_sensitive_overlay(selectedButton)
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