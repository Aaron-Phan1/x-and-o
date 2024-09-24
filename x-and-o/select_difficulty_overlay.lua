local composer = require( "composer" )
 
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
d = display
w20 = d.contentWidth * .2
h20 = d.contentHeight * .2 
h30 = d.contentHeight * .3
w40 = d.contentWidth * .4
h40 = d.contentHeight * .4
w60 = d.contentWidth * .6
h60 = d.contentHeight * .6
w80 = d.contentWidth * .8
h80 = d.contentHeight * .8
 
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    local selection_window = d.newRect(d.contentWidth/2, d.contentHeight/2, w80, h60)
    selection_window:setFillColor(0.6, 0.4, 0.2)
    selection_window.strokeWidth = 4
    sceneGroup:insert(selection_window)
    local selection_text = d.newText("Select Difficulty", d.contentWidth/2, h30, native.systemFont, 24)
    sceneGroup:insert(selection_text)
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