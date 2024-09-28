local composer = require( "composer" )
 
local scene = composer.newScene()
 
local M = require("M")

local widget = require("widget")

local containerHeight = h20 + h2_5
local containerGap = h5
local containerWidth = w80

local containers = {}
local container_objs = {{},{},{}}

local command = nil
local command_event = nil
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local profiles = M.load_table("profiles.json")
if not profiles then 
    profiles = {}
    for i = 1, 3 do
        profiles[i] = {
            name = "Player " .. i,
            hard = { win = 0, loss = 0, draw = 0 },
            easy = { win = 0, loss = 0, draw = 0 },
            active = false
        }
    end
end

local function reload_scene()
    composer.removeScene("profile_selection")
    composer.gotoScene("profile_selection")
end

local function play_game(event)
    composer.gotoScene("game_scene", {params = {profileNum = event.target.profileNum}})
end

local function sensitive_command (event)

    command = event.target.com
    command_event = event
    print(event.target.type, "hi")
    composer.showOverlay("sensitive_command_scene", {isModal = true, effect = "fade", time = 100, params = {type = event.target.type}})
end

local function clear_score(event)
    local profileNum = event.target.profileNum
    local mode = event.target.mode
    profiles[profileNum][mode] = { win = 0, loss = 0, draw = 0 }
    M.save_table(profiles, "profiles.json")
    if mode == "hard" then
        container_objs[profileNum].hardModeText.text = "Hard Mode\nWin: 0\nLoss: 0\nDraw: 0"
    else
        container_objs[profileNum].easyModeText.text = "Easy Mode\nWin: 0\nLoss: 0\nDraw: 0"
    end
end

local function create_profile(event)
    local profileNum = event.target.profileNum
    profiles[profileNum] = {
        name = "Player " .. profileNum,
        hard = { win = 0, loss = 0, draw = 0 },
        easy = { win = 0, loss = 0, draw = 0 },
        active = true
    }
    M.save_table(profiles, "profiles.json")
    reload_scene()
end
local function delete_profile(event)
    local profileNum = event.target.profileNum
    profiles[profileNum] = {
        name = "Player " .. profileNum,
        hard = { win = 0, loss = 0, draw = 0 },
        easy = { win = 0, loss = 0, draw = 0 },
        active = false
    }
    M.save_table(profiles, "profiles.json")
    reload_scene()
end

local function change_profile_name(name, profileNum)
    profiles[profileNum].name = name
    M.save_table(profiles, "profiles.json")

    local container_obj = container_objs[profileNum]
    display.remove(container_obj.newName)
    container_obj.newName = nil

    container_obj.profileText.text = name
    container_obj.profileText.isVisible = true
    container_obj.editNameButton.isVisible = true
    container_obj.editNameButton.x = container_obj.profileText.x + container_obj.profileText.width + w2_5 / 2
end

local function on_text_input(event)
    if event.phase == "editing" then
        event.target.text = event.target.text:sub(1, 16)
    elseif event.phase == "ended" or event.phase == "submitted" then 
        change_profile_name(event.target.text, event.target.profileNum)
        
    end
end

local function edit_profile_name(event)
    local profileNum = event.target.profileNum
    local profile = profiles[profileNum]
    local container = containers[profileNum]
    local profileText = container_objs[profileNum].profileText

    local newName = native.newTextField(profileText.x, profileText.y, containerWidth/2, profileText.height)
    newName.text = profile.name
    newName.profileNum = profileNum
    newName:addEventListener("userInput", on_text_input)
    newName.anchorX = 0
    container_objs[profileNum].newName = newName

    container:insert(newName)
    profileText.isVisible = false
    container_objs[profileNum].editNameButton.isVisible = false
end


local function make_profile_objects (index , container, profile)
    local i = index
    local container = container
    local profile = profile

    local profileText = display.newText({
        text = profile.name,
        x = -containerWidth / 2 + w5,
        y = -h5 - h2_5,
        font = native.systemFont,
        fontSize = 16,
    })
    profileText.anchorX = 0
    profileText:setFillColor(1, 1, 1)
    container:insert(profileText)
    container_objs[i].profileText = profileText

    local easyModeText = display.newText({
        text = "Easy Mode\nWin: " .. profile.easy.win .. "\nLoss: " .. profile.easy.loss .. "\nDraw: " .. profile.easy.draw,
        x = 0,
        y = 0,
        width = containerWidth - w10,
        font = native.systemFont,
        fontSize = 10,
        align = "left"
    })
    easyModeText:setFillColor(1, 1, 1)
    container:insert(easyModeText)
    container_objs[i].easyModeText = easyModeText

    local hardModeText = display.newText({
        text = "Hard Mode\nWin: " .. profile.hard.win .. "\nLoss: " .. profile.hard.loss .. "\nDraw: " .. profile.hard.draw,
        x = w20 + w5,
        y = 0,
        width = containerWidth - w10,
        font = native.systemFont,
        fontSize = 10,
        align = "left"
    })
    hardModeText:setFillColor(1, 1, 1)
    container:insert(hardModeText)
    container_objs[i].hardModeText = hardModeText

    local playButton = widget.newButton({
        label = "Play",
        x = containerWidth / 2 - w10 - w5,
        y = h2_5,
        shape = "roundedRect",
        width = w20,
        height = h5,
        cornerRadius = 5,
        strokeWidth = 2,
        strokeColor = { default={0, 0.4, 0.6}, over={0, 0.6, 0.8} },
        fillColor = { default={0.2, 0.6, 0.8}, over={0.3, 0.7, 0.9} },
        labelColor = { default={1, 1, 1}, over={1, 1, 1} },
        fontSize = 14,
        onRelease = play_game
    })
    playButton.profileNum = i
    container:insert(playButton)
    container_objs[i].playButton = playButton

    local deleteButton = widget.newButton({
        label = "X",
        x = containerWidth / 2 - w5 - w2_5,
        y = -h5 - h2_5,
        shape = "roundedRect",
        width = w5,
        height = h2_5,
        strokeWidth = 2,
        strokeColor = { default={0.4, 0, 0}, over={0.6, 0, 0} },
        fillColor = { default={0.6, 0, 0}, over={0.8, 0, 0} },
        labelColor = { default={0.8,0.8,0.8}, over={0.8, 0.8, 0.8} },
        fontSize = 10,
        onRelease = sensitive_command
    })
    deleteButton.com = delete_profile
    deleteButton.type = "Delete"
    deleteButton.profileNum = i
    container:insert(deleteButton)
    container_objs[i].deleteButton = deleteButton

    local clearEasyBtn = widget.newButton({
        label = "Clear",
        x = -containerWidth / 2 + w5,
        y = h10 - h2_5,
        shape = "roundedRect",
        width = w10 + w2_5/2,
        height = h2_5 + h2_5/2,
        cornerRadius = 4,
        strokeWidth = 2,
        strokeColor = { default={0.4, 0, 0}, over={0.6, 0, 0} },
        fillColor = { default={0.6, 0, 0}, over={0.8, 0, 0} },
        labelColor = { default={0.8,0.8,0.8}, over={0.8, 0.8, 0.8} },
        fontSize = 10,
        onRelease = sensitive_command,

    })
    clearEasyBtn.com = clear_score
    clearEasyBtn.type = "Clear"
    clearEasyBtn.mode = "easy"
    clearEasyBtn.anchorX = 0
    clearEasyBtn.profileNum = i
    container:insert(clearEasyBtn)
    container_objs[i].clearEasyBtn = clearEasyBtn

    local clearHardBtn = widget.newButton({
        label = "Clear",
        x = -containerWidth / 2 + w5 + hardModeText.x,
        y = h10 - h2_5,
        shape = "roundedRect",
        width = w10 + w2_5/2,
        height = h2_5 + h2_5/2,
        cornerRadius = 4,
        strokeWidth = 2,
        strokeColor = { default={0.4, 0, 0}, over={0.6, 0, 0} },
        fillColor = { default={0.6, 0, 0}, over={0.8, 0, 0} },
        labelColor = { default={0.8,0.8,0.8}, over={0.8, 0.8, 0.8} },
        fontSize = 10,
        onRelease = sensitive_command,
    })
    clearHardBtn.com = clear_score
    clearHardBtn.type = "Clear"
    clearHardBtn.mode = "hard"
    clearHardBtn.anchorX = 0
    clearHardBtn.profileNum = i
    container:insert(clearHardBtn)
    container_objs[i].clearHardBtn = clearHardBtn

    local editNameButton = widget.newButton({
        label = "Edit",
        x = profileText.x + profileText.width + w2_5/2,
        y = profileText.y,
        shape = "roundedRect",
        width = w5 + w2_5,
        height = h2_5,
        cornerRadius = 5,
        strokeWidth = 2,
        strokeColor = { default={0.4, 0.4, 0.4}, over={0.6, 0.6, 0.6} },
        fillColor = { default={0.6, 0.6, 0.6}, over={0.8, 0.8, 0.8} },
        labelColor = { default={1, 1, 1}, over={1, 1, 1} },
        fontSize = 8,
        onRelease = edit_profile_name
    })
    editNameButton.profileNum = i
    editNameButton.anchorX = 0
    container:insert(editNameButton)
    container_objs[i].editNameButton = editNameButton
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


        if profile.active then
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
                x = containerWidth / 2 - w10 - w5,
                y = h2_5,
                shape = "roundedRect",
                width = w20,
                height = h5,
                cornerRadius = 5,
                fillColor = { default={0, 0.6, 0}, over={0, 0.8, 0} },
                labelColor = { default={1, 1, 1}, over={1, 1, 1} },
                fontSize = 14,
                onRelease = create_profile
            })
            createButton.profileNum = i
            container:insert(createButton)
            container_objs[i].createButton = createButton   
        end
    end
end




-- local defaultField = native.newTextField(0, 0, w40, h2_5)
-- defaultField.isVisible = false
-- container1:insert(defaultField)

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