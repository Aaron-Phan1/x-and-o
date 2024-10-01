local composer = require( "composer" )
 
local scene = composer.newScene()
 
local M = require("M")

local widget = require("widget")

local FONT = Arial
local scoreFontSize = 10

local containerHeight = h20 + h2_5
local containerGap = h5
local containerWidth = w80

local containers = {}
local container_objs = {{},{},{}}

local command = nil
local command_event = nil


local prevProfile = nil
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local profiles = M.load_table("profiles.json")
if not profiles then 
    profiles = {}
end

local function reload_scene()
    -- To refresh the scene after a profile is deleted or created
    composer.removeScene("profile_selection")
    composer.gotoScene("profile_selection")
end

-- -----------------------------------------------------------------------------------
----Event handlers

-- Play button press event - starts the game scene with the selected profile
local function play_game(event)
    local options = {
        isModal = true,
        effect = "fade",
        time = 100,
        params = {
            profileNum = event.target.profileNum,
            profileId = profiles[event.target.profileNum].id
        }
    }
    -- Allows the game scene to be reused if the same profile is selected
    if profiles[event.target.profileNum].id ~= prevId then
        composer.removeScene("game_scene")
    end
    composer.gotoScene("game_scene", options)
end

-- Delete or clear button press event - opens the sensitive command overlay
local function sensitive_command (event)
    -- Save the command and event for later use if the user confirms the command
    command = event.target.com
    command_event = event
    local options = {
        isModal = true,
        effect = "fade",
        time = 100,
        params = {type = event.target.type or event.target:getLabel()} -- "Clear" or "Delete"
    }

    composer.showOverlay("sensitive_command_scene", options)
end

-- Clear button press event - clears the score of the selected profile
-- Called when the user confirms the clear command
local function clear_score(event)
    local profileNum = event.target.profileNum
    local mode = event.target.mode
    profiles[profileNum][mode] = { win = 0, loss = 0, draw = 0 }
    M.save_table(profiles, "profiles.json")
    -- Update the text on the screen instead of reloading the scene to save resources
    if mode == "hard" then
        container_objs[profileNum].hWinText.text = profiles[profileNum].hard.win
        container_objs[profileNum].hLossText.text = profiles[profileNum].hard.loss
        container_objs[profileNum].hDrawText.text = profiles[profileNum].hard.draw
    else
        container_objs[profileNum].eWinText.text = profiles[profileNum].easy.win
        container_objs[profileNum].eLossText.text = profiles[profileNum].easy.loss
        container_objs[profileNum].eDrawText.text = profiles[profileNum].easy.draw
    end
end

-- Create button press event - creates a new profile in the selected slot
local function create_profile(event)
    local profileNum = event.target.profileNum
    profiles[profileNum] = {
        name = "Player " .. profileNum,
        hard = { win = 0, loss = 0, draw = 0 },
        easy = { win = 0, loss = 0, draw = 0 },
        id = tostring(math.random(1000000, 9999999))
        -- 7-digit id mainly for game scene reuse if profile is re-selected
    }
    M.save_table(profiles, "profiles.json")
    reload_scene()
end

-- Delete button press event - deletes the selected profile
local function delete_profile(event)
    local profileNum = event.target.profileNum
    profiles[profileNum] = nil
    M.save_table(profiles, "profiles.json")
    reload_scene()
end

-- Change the name of the selected profile
-- Called when the user finishes editing the profile name
local function change_profile_name(name, profileNum)
    profiles[profileNum].name = name
    M.save_table(profiles, "profiles.json")

    -- Remove the text input field and display the new name
    local container_obj = container_objs[profileNum]
    display.remove(container_obj.newName)
    container_obj.newName = nil

    -- Update the profile text and edit button position to fit the new name
    container_obj.profileText.text = name
    container_obj.profileText.isVisible = true
    container_obj.editNameButton.isVisible = true
    container_obj.editNameButton.x = container_obj.profileText.x + container_obj.profileText.width + w2_5 / 2
end

-- Edit profile name - text input field event handler 
local function on_text_input(event)
    if event.phase == "editing" then
        -- Limit the profile name to 18 characters
        event.target.text = event.target.text:sub(1, 18)
    elseif event.phase == "ended" or event.phase == "submitted" then 
        change_profile_name(event.target.text, event.target.profileNum)
    end
end

-- Edit button press event - allows the user to change the profile name
local function edit_profile_name(event)
    local profileNum = event.target.profileNum
    local profile = profiles[profileNum]
    local container = containers[profileNum]
    local profileText = container_objs[profileNum].profileText

    -- Create a text input field to edit the profile name
    local newName = native.newTextField(profileText.x, profileText.y, containerWidth/2, profileText.height)
    
    newName.text = profile.name
    newName.profileNum = profileNum  -- profileNum is referenced in the text input event handler
    newName:addEventListener("userInput", on_text_input)
    newName.anchorX = 0
    newName.anchorY = 0
    container_objs[profileNum].newName = newName

    container:insert(newName)

    -- Hide the profile text and edit button while editing the name
    profileText.isVisible = false
    container_objs[profileNum].editNameButton.isVisible = false
end

-- -----------------------------------------------------------------------------------
-- Create display objects for each profile container
local function make_profile_objects (profileNum , container, profileTable)
    local i = profileNum
    local profile = profileTable

    local container = container
    -- Container object that holds all the display objects
    -- When display objects are inserted into the container, 
    -- their x and y positions are relative to the container,
    -- with x = 0 and y = 0 being the center of the container

    -- Box dimensions for display objects
    local left = -containerWidth / 2
    local right = containerWidth / 2
    local top = -containerHeight / 2
    local bottom = containerHeight / 2
    local containerMargin = containerHeight * 0.08
    local elementGap = containerHeight * 0.05

    local profileText = display.newText({
        text = profile.name,
        x = left + containerMargin, 
        y = top + containerMargin,
        font = FONT,
        fontSize = 16,
    })
    profileText.anchorY = 0 
    profileText.anchorX = 0 
    profileText:setFillColor(1, 1, 1)
    container_objs[i].profileText = profileText

    local easyText = display.newText({
        text = "Easy Mode",
        x = profileText.x,
        y = profileText.y + profileText.height + elementGap,
        font = FONT,
        fontSize = 12,
    })
    easyText.anchorX = 0
    easyText.anchorY = 0
    easyText:setFillColor(unpack(easyColour)) -- set in main.lua
    container_objs[i].easyText = easyText
    
    local eScoreText = display.newText({
        text = "Win:\nLoss:\nDraw:",
        x = easyText.x,
        y = easyText.y + easyText.height,
        font = FONT,
        fontSize = scoreFontSize,
    })
    eScoreText.anchorX = 0
    eScoreText.anchorY = 0
    eScoreText:setFillColor(1, 1, 1)
    container_objs[i].eScoreText = eScoreText

    -- Win, loss, and draw text x positions are relative to the eScoreText making them aligned
    local eWinText = display.newText({
        text = profile.easy.win,
        x = eScoreText.x + eScoreText.width + elementGap,
        y = easyText.y + easyText.height,
        font = FONT,
        fontSize = scoreFontSize,
    })
    eWinText.anchorX = 0
    eWinText.anchorY = 0
    eWinText:setFillColor(0, 1, 0)
    container_objs[i].eWinText = eWinText

    local eLossText = display.newText({
        text = profile.easy.loss,
        x = eScoreText.x + eScoreText.width + elementGap,
        y = eWinText.y + eWinText.height,
        font = FONT,
        fontSize = scoreFontSize,
    })
    eLossText.anchorX = 0
    eLossText.anchorY = 0
    eLossText:setFillColor(1, 0, 0)
    container_objs[i].eLossText = eLossText

    local eDrawText = display.newText({
        text = profile.easy.draw,
        x = eScoreText.x + eScoreText.width + elementGap,
        y = eLossText.y + eLossText.height,
        font = FONT,
        fontSize = scoreFontSize,
    })
    eDrawText.anchorX = 0
    eDrawText.anchorY = 0
    eDrawText:setFillColor(0, 0, 1)
    container_objs[i].eDrawText = eDrawText
    
    local hardText = display.newText({
        text = "Hard Mode",
        -- Adjust x position to align with the furthest right element
        x = math.max(
            easyText.x + easyText.width, 
            eWinText.x + eWinText.width,
            eLossText.x + eLossText.width,
            eDrawText.x + eDrawText.width) + elementGap * 2,
        y = profileText.y + profileText.height + elementGap,
        font = FONT,
        fontSize = 12,
    })
    hardText.anchorX = 0
    hardText.anchorY = 0
    hardText:setFillColor(unpack(hardColour)) -- set in main.lua
    container_objs[i].hardText = hardText

    local hScoreText = display.newText({
        text = "Win:\nLoss:\nDraw:",
        x = hardText.x,
        y = hardText.y + hardText.height,
        font = FONT,
        fontSize = scoreFontSize,
    })
    hScoreText.anchorX = 0
    hScoreText.anchorY = 0
    hScoreText:setFillColor(1, 1, 1)
    container_objs[i].hScoreText = hScoreText

    local hWinText = display.newText({
        text = profile.hard.win,
        x = hScoreText.x + hScoreText.width + elementGap,
        y = hardText.y + hardText.height,
        font = FONT,
        fontSize = scoreFontSize,
    })

    hWinText.anchorX = 0
    hWinText.anchorY = 0
    hWinText:setFillColor(0, 1, 0)
    container_objs[i].hWinText = hWinText

    local hLossText = display.newText({
        text = profile.hard.loss,
        x = hScoreText.x + hScoreText.width + elementGap,
        y = hWinText.y + hWinText.height,
        font = FONT,
        fontSize = scoreFontSize,
    })
    hLossText.anchorX = 0
    hLossText.anchorY = 0
    hLossText:setFillColor(1, 0, 0)
    container_objs[i].hLossText = hLossText

    local hDrawText = display.newText({
        text = profile.hard.draw,
        x = hScoreText.x + hScoreText.width + elementGap,
        y = hLossText.y + hLossText.height,
        font = FONT,
        fontSize = scoreFontSize,
    })
    hDrawText.anchorX = 0
    hDrawText.anchorY = 0
    hDrawText:setFillColor(0, 0, 1)
    container_objs[i].hDrawText = hDrawText

    local deleteButton = widget.newButton({
        label = "X",
        x = right - containerMargin,
        y = top + containerMargin,
        shape = "roundedRect",
        width = w5,
        height = h2_5,
        strokeWidth = 2,
        strokeColor = { default={0.4, 0, 0}, over={0.6, 0, 0} },
        fillColor = { default={0.6, 0, 0}, over={0.8, 0, 0} },
        labelColor = { default={0.8,0.8,0.8}, over={0.8, 0.8, 0.8} },
        font = FONT,
        fontSize = 10,
        onRelease = sensitive_command
    })
    deleteButton.anchorX = 1
    deleteButton.anchorY = 0
    deleteButton.com = delete_profile -- for sensitive_command function parameter
    deleteButton.type = "Delete" -- for sensitive_command function parameter
    container_objs[i].deleteButton = deleteButton

    local clearEasyBtn = widget.newButton({
        label = "Clear",
        x = easyText.x,
        y = eDrawText.y + eDrawText.height + h1_25/4,
        shape = "roundedRect",
        width = w10 + w2_5/2,
        height = h2_5 + h2_5/2,
        cornerRadius = 4,
        strokeWidth = 2,
        strokeColor = { default={0.4, 0, 0}, over={0.6, 0, 0} },
        fillColor = { default={0.6, 0, 0}, over={0.8, 0, 0} },
        labelColor = { default={0.8,0.8,0.8}, over={0.8, 0.8, 0.8} },
        font = FONT,
        fontSize = scoreFontSize,
        onRelease = sensitive_command,

    })
    clearEasyBtn.anchorX = 0
    clearEasyBtn.anchorY = 0
    clearEasyBtn.com = clear_score -- for sensitive_command function parameter
    clearEasyBtn.mode = "easy" -- for clear_score function parameter
    container_objs[i].clearEasyBtn = clearEasyBtn

    local clearHardBtn = widget.newButton({
        label = "Clear",
        x = hardText.x,
        y = hDrawText.y + hDrawText.height,
        shape = "roundedRect",
        width = w10 + w2_5/2,
        height = h2_5 + h2_5/2,
        cornerRadius = 4,
        strokeWidth = 2,
        strokeColor = { default={0.4, 0, 0}, over={0.6, 0, 0} },
        fillColor = { default={0.6, 0, 0}, over={0.8, 0, 0} },
        labelColor = { default={0.8,0.8,0.8}, over={0.8, 0.8, 0.8} },
        font = FONT,
        fontSize = scoreFontSize,
        onRelease = sensitive_command,
    })
    clearHardBtn.anchorX = 0
    clearHardBtn.anchorY = 0
    clearHardBtn.com = clear_score -- for sensitive_command function parameter
    clearHardBtn.mode = "hard" -- for clear_score function
    container_objs[i].clearHardBtn = clearHardBtn

    local editNameButton = widget.newButton({
        label = "Edit",
        x = profileText.x + profileText.width + w2_5/2,
        y = profileText.y + profileText.height / 2,
        shape = "roundedRect",
        width = w5 + w2_5,
        height = h2_5,
        cornerRadius = 5,
        strokeWidth = 2,
        strokeColor = { default={0.4, 0.4, 0.4}, over={0.6, 0.6, 0.6} },
        fillColor = { default={0.6, 0.6, 0.6}, over={0.8, 0.8, 0.8} },
        labelColor = { default={1, 1, 1}, over={1, 1, 1} },
        font = FONT,
        fontSize = 8,
        onRelease = edit_profile_name
    })
    editNameButton.anchorX = 0
    container_objs[i].editNameButton = editNameButton

    local playButton = widget.newButton({
        label = "Play",
        x = right - containerMargin,
        y = clearEasyBtn.y + clearEasyBtn.height,
        shape = "roundedRect",
        width = w20,
        height = h5,
        cornerRadius = 5,
        strokeWidth = 2,
        strokeColor = { default={0, 0.4, 0}, over={0, 0.6, 0} },
        fillColor = { default={0, 0.6, 0}, over={0, 0.8, 0} },
        labelColor = { default={1, 1, 1}, over={1, 1, 1} },
        font = FONT,
        fontSize = 14,
        onRelease = play_game
    })
    playButton.anchorX = 1
    playButton.anchorY = 1
    container_objs[i].playButton = playButton

    -- Attach profileNum and profileName to each display object in container_objs
    for _, obj in pairs(container_objs[i]) do
        obj.profileNum = i
        obj.profileName = profile.name
        container:insert(obj)
    end 
    -- To ensure the outline is behind all other objects
    container_objs[i].containerOutline:toBack()
end

local function create_containers(group)
    for i = 1, 3 do
        local container = display.newContainer(containerWidth, containerHeight)
        container:translate(display.contentCenterX, h10 + h2_5 + (i - 1) * (containerGap + containerHeight) + containerGap + (containerHeight / 2))
        table.insert(containers, container)
        container.anchorChildren = true

        local containerOutline = display.newRoundedRect(0, 0, containerWidth - 6, containerHeight - 6, 10)
        containerOutline.strokeWidth = 3
        containerOutline:setStrokeColor(0.2, 0.2, 0.2)
        containerOutline.fill = {
            type = "gradient",
            color1 = { 0.5, 0.5, 0.5 },
            color2 = { 0.3, 0.3, 0.3 },
            direction = "down"
        }
        container:insert(containerOutline)
        group:insert(container)
        container_objs[i].containerOutline = containerOutline
    end

    for i = 1, 3 do
        local container = containers[i]
        local containerOutline = container_objs[i].containerOutline
        local profile = profiles[i]


        if profile then
            containerOutline:setStrokeColor(0.3, 0.15, 0.05)
            containerOutline.fill = {
                type = "gradient",
                color1 = { 0.6, 0.3, 0.1 },
                color2 = { 0.4, 0.2, 0.1 },
                direction = "down"
            }

            make_profile_objects(i, container, profile)
        else
            local createButton = widget.newButton({
                label = "Create",
                x = 0,
                y = 0,
                shape = "roundedRect",
                width = w20,
                height = h5,
                cornerRadius = 5,
                strokeWidth = 2,
                strokeColor = { default={0, 0.4, 0}, over={0, 0.6, 0} },
                fillColor = { default={0, 0.6, 0}, over={0, 0.8, 0} },
                labelColor = { default={1, 1, 1}, over={1, 1, 1} },
                font = FONT,
                fontSize = 14,
                onRelease = create_profile
            })
            createButton.profileNum = i
            container:insert(createButton)
            container_objs[i].createButton = createButton   
        end
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
function scene:post_sensitive_overlay(choice)
    if choice == "YES" then
        command(command_event)
    end
    command = nil
    command_event = nil
end
-- create()
function scene:create( event )
 
    local sceneGroup = self.view

    if event.params then
        prevId = event.params.previousId
    end
    -- Code here runs when the scene is first created but has not yet appeared on screen
    create_containers(sceneGroup)
    local header = d.newText("Profile Selection", display.contentCenterX, h10, native.systemFont, 30)
    sceneGroup:insert(header)
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