local mainMenu = {}

mainMenu.instances = {} -- i add to this if i need to edit something from a different window
mainMenu.screen = nil

local function addIconButton(text, icon, x, y, width, height, color, uO)
    -- // ADD BUTTONS
    local button = library:addButton({
        x = x,
        y = y,

        anchorPointY = 0,
        anchorPointX = 1,

        width = width,
        height = height,

        bgColor = color,
    })

    library:addImage({
        x = 0.115,
        y = 0.5,

        width = uO or 0.75,
        height = uO or 0.75,

        image = icon,
        bgColor = {1,1,1},

        anchorPointX = 0,
        anchorPointY = 0,

        onDraw = function(properties, deltaTime)
        end,

        uniform = 'y',

        parent = button
    })

    local textInstance = library:addNormalText(text, {
        x = 0.2,
        y = 0.5,

        width = 1,
        height = 1,

        image = icon,
        bgColor = {1, 0.94, 0.94},

        anchorPointX = 0,
        anchorPointY = 0.18,

        onDraw = function(properties, deltaTime)
        end,

        uniform = 'y',

        parent = button
    })


    button.textInstance = textInstance

    return button
end

-- // IMPORTANT // --

local path = {
    "E:/",

} -- stemming from savedir unless explicitly mentioned.

local pathObjects = {}
local fileButtons = {}
local selectedFiles = {} -- path, true

-- for scrolling
local scrollingIndexOffset = 0
local selectedCount = 0


function mainMenu:setup(library)
    self.screen = library.screen()
    self.screen.visible = false

    library.defaultParent = self.screen

    -- version
    library:addNormalText('Files Manager', {
        x = toScaleFromPixels(25, 1920),
        y = toScaleFromPixels(25, 1080),

        width = 1,
        height = 1,

        bgColor = {1, 1, 1},

        anchorPointY = 0,
        anchorPointX = 0,
    })

    -- // CLOSE BUTTON
    do
        local btn = library:addButton({
            x = toScaleFromPixels(1920-(25+48), 1920),
            y = toScaleFromPixels(25, 1080),

            width = toScaleFromPixels(48, 1920),
            height = toScaleFromPixels(48, 1080),

            bgColor = {rgb(203, 20, 23)},

            anchorPointY = 0,
            anchorPointX = 1,

            callback = function()
                playSFX("close_sound", 2)
                self.screen.visible = false
                musicManager.updateSong(1)
                require('EmbeddedModLoader/UIRendering/uiMenus/mainMenu').screen.visible = true
            end
        })

        library:addImage({
            x = 0.5,
            y = 0.5,

            width = 0.75,
            height = 0.75,

            image = assets.close,
            bgColor = {1, 1, 1},

            anchorPointX = 0,
            anchorPointY = 0,

            onDraw = function(properties, deltaTime)
            end,

            uniform = 'y',

            parent = btn
        })
    end

    -- update the position for the texts for the download button and add the description text

    -- scrolling
    -- UP BUTTON
    local scrollUpButton
    local scrollDownButton

    do
        scrollDownButton = library:addButton({
            x = toScaleFromPixels(2560-250, 2560),
            y = toScaleFromPixels(1440-250, 1440),

            anchorPointY = 0,
            anchorPointX = 0,

            width = toScaleFromPixels(200, 2560),
            height = toScaleFromPixels(200, 1440),

            callback = function()
                -- get the amount of touches on the screen and scroll by that amount
                -- nice hidden feature on mobile for fast scrolling

                local touches = (#love.touch.getTouches())
                local ctrlAdd = love.keyboard.isDown("lctrl") and 5 or 0

                scrollingIndexOffset = scrollingIndexOffset + (touches > 0 and touches or 1) + ctrlAdd
                updateFilesList()
            end,

            bgColor = {rgb(73, 77, 70)},
            parent = mainMenu.screen
        })

        library:addImage({
            x = 0.5,
            y = 0.5,

            width = 0.75,
            height = 0.75,

            image = assets.arrowDown,
            bgColor = {1, 1, 1},

            anchorPointX = .0,
            anchorPointY = .0,

            uniform = 'y',

            parent = scrollDownButton
        })
    end


    -- // SCROLL UP BUTTON
    do
        scrollUpButton = library:addButton({
            x = toScaleFromPixels(2560-500, 2560),
            y = toScaleFromPixels(1440-250, 1440),

            anchorPointY = 0,
            anchorPointX = 0,

            width = toScaleFromPixels(200, 2560),
            height = toScaleFromPixels(200, 1440),

            callback = function()
                -- get the amount of touches on the screen and scroll by that amount
                -- nice hidden feature on mobile for fast scrolling

                local touches = (#love.touch.getTouches())
                local ctrlAdd = love.keyboard.isDown("lctrl") and 5 or 0

                scrollingIndexOffset = scrollingIndexOffset - (touches > 0 and touches or 1) - ctrlAdd
                updateFilesList()
            end,

            bgColor = {rgb(73, 77, 70)},
            parent = mainMenu.screen
        })

        library:addImage({
            x = 0.5,
            y = 0.5,

            width = 0.75,
            height = 0.75,

            image = assets.arrowUp,
            bgColor = {1, 1, 1},

            anchorPointX = .0,
            anchorPointY = .0,

            uniform = 'y',

            parent = scrollUpButton
        })
    end

    -- // delete files // --
    deleteButton.callback = function()
        local pressed = promptUser("Are you sure you want to delete these files? They may become unrecoverable once deleted.",
            'NO', 'YES'
        )

        local newSelected = {}

        -- nested code, basically delete every file and warn if it could not be deleted, and allow the user to retry the deletion or skip
        if pressed == 2 then
            for i, v in pairs(selectedFiles) do
                local success = false
                while success == false do
                    success = love.filesystem.remove(i)

                    if not success then
                        local pushed = promptUser('File "' .. i .. '" failed to delete. Verify that the file exists and is not currently open in any other programs.', "SKIP", "RETRY")

                        if pushed == 1 then
                            success = true
                        end
                    end
                end
            end
        end

        updateFilesList()
    end

    -- // LIST

    updateFilesList()
end


-- this is TERRIBLE practice but im sleepy and i dont really midn it right npw si ill ptrobably fix it later
function mainMenu.wheelmoved(x, y)
    if not mainMenu.screen.visible then
        return
    end

    local ctrlAdd = love.keyboard.isDown("lshift") and 5 or 1

    scrollingIndexOffset = scrollingIndexOffset - (y > 0 and ctrlAdd or y == 0 and 0 or y < 0 and -ctrlAdd)
    updateFilesList()
end









return mainMenu