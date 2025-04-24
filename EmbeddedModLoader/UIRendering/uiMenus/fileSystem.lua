local mainMenu = {}



mainMenu.instances = {} -- i add to this if i need to edit something from a different window

mainMenu.screen = nil

local fileHandler
local fileDownloader

local success, err = pcall(function()
    fileHandler = require("EmbeddedModLoader/fileManagerHelper/fileManager")
    fileDownloader = nil -- not implemented yet require("EmbeddedModLoader/files/downloadZip")
end)

print(err)

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


local function addPathButton(text, icon, x, y, height, add)
    -- // ADD BUTTONS
    local textSize = love.graphics.getHeight()/1440 * 48
    local textObject = love.graphics.newText(love.graphics.newFont("resources/fonts/m6x11plus.ttf", textSize), text)

    forcePrint(add)

    local button = library:addButton({
        x = x + textObject:getWidth()/2560 + add,
        y = y,

        anchorPointY = 0,
        anchorPointX = 1,

        width = textObject:getWidth()/2560 + toScaleFromPixels(30, 2560),
        height = height,

        bgColor = {rgb(60, 130, 102)},
        parent = mainMenu.screen
    })

    --forcePrint(textObject:getWidth())


    library:addImage({
        x = 0.115,
        y = 0.5,

        width = 0.75,
        height = 0.75,

        image = icon,
        bgColor = {1,1,1},

        anchorPointX = 0,
        anchorPointY = 0,

        onDraw = function(properties, deltaTime)
        end,

        uniform = 'y',

        parent = button
    })

    library:addNormalText(text, {
        x = toScaleFromPixels(10, textObject:getWidth()),
        y = 0.6,

        width = 1,
        height = 1,

        image = icon,
        bgColor = {1, 0.94, 0.94},

        anchorPointX = 0,
        anchorPointY = 0.5,

        onDraw = function(properties, deltaTime)
        end,

        uniform = 'y',

        parent = button
    })


    button.hidden_data = textObject:getWidth()/2560 + add + toScaleFromPixels(40, 2560)

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


local function createPathButtons()
    local add = 0
        
    for i, v in pairs(path) do
        --print(v .. "NEW BUTTON!!!!")
        local button = addPathButton(
                v,
                assets.folder,

                toScaleFromPixels(40, 1920),
                toScaleFromPixels(90, 1080),

                toScaleFromPixels(50, 1080),
                add
        )

        button.callback = function()
            local click = love.audio.newSource(assets.buttonClick, 'static')
            click:setVolume(0.1)
            click:play()

            -- new path
            local newPath = {}
            for index, val in pairs(path) do
                if index > i then
                    break
                end

                newPath[index] = val
            end

            path = newPath
            ---createPathButtons()
            updateFilesList()
        end

        button.bgColor = {
            button.bgColor[1] * 0.8 + (i/#path*0.3),
            button.bgColor[2] * 0.8 + (i/#path*0.3),
            button.bgColor[3] * 0.8 + (i/#path*0.3),
        }

        table.insert(pathObjects, i, button)
        add = button.hidden_data
    end

    local frame = library:addFrame({

        x = add + toScaleFromPixels(10, 1920),
        y = toScaleFromPixels(150, 1080),

        anchorPointY = 0,
        anchorPointX = 1,

        width = add,
        height = toScaleFromPixels(5, 1080),

        bgColor = {rgb(20*2.5, 20*2.5, 19*2.5)},
        parent = mainMenu.screen
    })

    table.insert(pathObjects, frame)
end


-- colors
local fileTypeColors = {
    directory = rgb(222, 155, 38),
    symlink = rgb(83, 89, 88),
}



-- // UPDATES THE FILES LIST !!!! // --
-- // UPDATES THE FILES LIST !!!! // --
-- // UPDATES THE FILES LIST !!!! // --
-- // UPDATES THE FILES LIST !!!! // --
-- // UPDATES THE FILES LIST !!!! // --
-- // UPDATES THE FILES LIST !!!! // --
-- // UPDATES THE FILES LIST !!!! // --
-- // UPDATES THE FILES LIST !!!! // --
-- // UPDATES THE FILES LIST !!!! // --
-- // UPDATES THE FILES LIST !!!! // --

function openFolder(fileName)
    scrollingIndexOffset = 0
    table.insert(path, string.sub(fileName, 2, #fileName))
    updateFilesList()
end


function updateFilesList()
    -- clear all old ones
    for _, v in pairs(pathObjects) do
        v.dispose() -- inherited by all ui objects
    end

    pathObjects = {}

    createPathButtons()

    local pathStr = ''
    for i, v in pairs(path) do
        if i ~= 1 then
            pathStr = pathStr .. v .. (i ~= #path and "/" or "")
        end
    end

    local buttonSize = 55--48
    local folderContents = fileHandler.exploreFolder(pathStr, 'L', true)

    -- math.clamp doesnt eixxt :(
    if scrollingIndexOffset < 0 then
        scrollingIndexOffset = 0 -- 5
    elseif #folderContents <= scrollingIndexOffset then
        scrollingIndexOffset = #folderContents - 1
    end

    for index, fileName in pairs(folderContents) do
        if index <= scrollingIndexOffset then
            goto skipIndex
        end

        local fileName = '/' .. fileName
        local filePath = pathStr .. fileName
        local fileInfo = fileHandler.getFileInfo(filePath, "L")
        local type = fileInfo and fileInfo.type-- or 'missing'

        if type ~= 'directory' and type ~= 'symlink' then
            local rec = false
            local ext = ''
            for i = 1, #fileName do
                local chr = string.sub(fileName, i, i)

                if rec then
                    ext = ext .. chr
                end
                if chr == "." then
                    rec = true
                end
            end

            ext = string.lower(ext)
            type = assets[ext] and ext or 'file'
        end

        local subIndex = index - scrollingIndexOffset

        -- slight variations when selected
        --local xOffset = toScaleFromPixels()

        local btn
        btn = library:addButton({
            x = toScaleFromPixels(30, 1920),
            y = toScaleFromPixels(100 + (subIndex*(buttonSize+20)), 1080),

            width = toScaleFromPixels(1000, 1920),
            height = toScaleFromPixels(buttonSize, 1080),

            bgColor = {rgb(47, 54, 51)},

            anchorPointY = 0,
            anchorPointX = 0,

            parent = mainMenu.screen,

            -- customs
            animProg = 0,
            lastClick = 0,

            onHovered = function(button, x, y)
                if not love.keyboard.isDown("lctrl") or isHoveringButton then
                    return
                end

                -- easter egg
                if love.mouse.isDown(1) and love.mouse.isDown(2) then
                    --playSFX('secret', 2, true)
                    --return
                end

                if love.mouse.isDown(1) or #love.touch.getTouches() == 2 then
                    selectedFiles[filePath] = true
                end

                if love.mouse.isDown(2) or #love.touch.getTouches() == 3 then
                    selectedFiles[filePath] = false
                end
            end,

            onDraw = function(self, dt)
                local progress = self.animProg
                dt = dt * 12

                if selectedFiles[filePath] then
                    self.bgColor = {rgb(48, 99, 209)}
                    if progress >= 1 then
                        return
                    end

                    self.animProg = progress + dt
                    if progress > 1 then
                        self.animProg = 1 -- clamp
                    end

                    self.x = toScaleFromPixels(30 + math.sin(progress*math.pi/2)*15, 1920)
                else
                    self.bgColor = {rgb(47, 54, 51)}
                    if progress == 0 then
                        --self.x = toScaleFromPixels(30, 1920)
                        return
                    end

                    self.animProg = progress - dt
                    if progress < 0 then
                        self.animProg = 0 -- clamp
                    end

                    self.x = toScaleFromPixels(30 + math.sin(progress*math.pi/2)*15, 1920)
                end
            end,

            callback = function(x, y, self)
                playSFX("hover", 2, true)


                local OS = love.system.getOS()

                local onPC = (OS == 'Windows' or OS == 'Linux' or OS == 'OS X')
                local controlDown = love.keyboard.isDown("lctrl") --or not onPC

                local isSelected = selectedFiles[filePath]

                -- behavior changes to make the file system more like windows when on pc
                if not controlDown and onPC then
                    if isSelected and selectedCount >= 2 then
                        isSelected = not isSelected
                    end

                    selectedCount = 0
                    selectedFiles = {}
                end

                selectedCount = selectedCount + (not isSelected and 1 or -1)
                selectedFiles[filePath] = not isSelected

                -- double click to open folder
                if os.clock() - self.lastClick < (onPC and 0.5 or 1) and selectedCount <= 1 then
                    if controlDown and onPC then return end
                    openFolder(fileName)
                end

                self.lastClick = os.clock()
                
                -- maybe make this use last touch inputs rather than OS
                --[[local OS = love.system.getOS()
                if OS == 'Windows' or OS == 'Linux' or OS == 'OS X' then
                    openFolder(fileName)
                end]]

                --updateFilesList()
            end
        })

        local image = library:addImage({
            x = 0.035,
            y = 0.5,

            width = 0.8,
            height = 0.8,

            image = (assets[type] and assets[type]) or assets.missing,
            bgColor = {1,1,1},

            anchorPointX = 0,
            anchorPointY = 0,

            onDraw = function(properties, deltaTime)
            end,

            uniform = 'y',

            parent = btn
        })

        library:addNormalText(fileName, {
            x = 0.065,
            y = 0.575,

            width = 1,
            height = 1,

            bgColor = {1, 0.94, 0.94},

            anchorPointX = 0,
            anchorPointY = 0.42,

            onDraw = function(properties, deltaTime)
            end,

            uniform = 'y',

            parent = btn
        })

        table.insert(pathObjects, btn)
        table.insert(fileButtons, btn)

        :: skipIndex ::
    end
end














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



    -- main

    -- // ADD BUTTONS

    deleteButton = addIconButton(
            'Delete File',
            assets.delete,

            toScaleFromPixels(1920 - 50, 1920),
            toScaleFromPixels(100, 1080),
            toScaleFromPixels(400, 1920),
            toScaleFromPixels(100, 1080),

            {rgb(203, 20, 23)}, 0.68
    )

    copyButton = addIconButton(
            'Copy File',
            assets.copy,

            toScaleFromPixels(1920 - 50, 1920),
            toScaleFromPixels(225, 1080),
            toScaleFromPixels(400, 1920),
            toScaleFromPixels(100, 1080),

            {rgb(50, 58, 168)}, 0.5 -- 54, 55, 69
    )

    newFileButton = addIconButton(
            'Create New',
            assets.newFile,

            toScaleFromPixels(1920 - 50, 1920),
            toScaleFromPixels(350, 1080),
            toScaleFromPixels(400, 1920),
            toScaleFromPixels(100, 1080),

            {rgb(204, 79, 2)}, 0.5 -- 54, 55, 69
    )

    importButton = addIconButton(
            'Download Zip',
            assets.newFile,

            toScaleFromPixels(1920 - 50, 1920),
            toScaleFromPixels(475, 1080),
            toScaleFromPixels(400, 1920),
            toScaleFromPixels(100, 1080),

            {rgb(73, 80, 140)}, 0.5 -- 54, 55, 69
    )

    -- update the position for the texts for the download button and add the description text

    importButton.textInstance.y = importButton.textInstance.y - 0.11
    library:addNormalText("(downloads from the link in your clipboard!)", {
        rawTextSize = 24,

        x = 0.2,
        y = 0.71,--0.85,

        width = 1,
        height = 1,

        anchorPointX = 0,
        anchorPointY = 0.18,

        uniform = 'y',

        parent = importButton

    }).updateFont()


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
        print(pressed)

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

    copyButton.callback = function()
        for i, v in pairs(selectedFiles) do
            local success = false
            while success == false do
                local newPath = i .. " [copy " .. math.random(0, 99999999) .. ']'
                success = love.filesystem.write(newPath, love.filesystem.read(i))

                if not success then
                    local pushed = promptUser('File "' .. i .. '" failed to delete. Verify that the file exists and is not currently open in any other programs.', "SKIP", "RETRY")

                    if pushed == 1 then
                        success = true
                    end
                end
            end
        end

        updateFilesList()
        playSFX("success", nil, true)
    end





    --
    importButton.callback = function()
        local URL = love.system.getClipboardText()

        if not fileDownloader then
            local prompt = promptUser("the HTTPS downloaded failed to initalize, this feature will not work.", "OK", "WRITE TO LOGS")

            if prompt == '2' then
                -- switch real quick nobody will notice
                local originalSettingValue = _G.MenuSettings.WriteToLogs.Value

                _G.MenuSettings.WriteToLogs.Value = true
                forcePrint(err)
                promptUser("The error code has been written to your log.txt file, it is located at patched/logs.txt", "OK", "WRITE TO LOGS")
                _G.MenuSettings.WriteToLogs.Value = originalSettingValue
            end

            return
        end

        local returned, fileName = fileDownloader.download(URL, 'mods/')
        love.system.vibrate(0.5)

        if not returned.Error then
            local promptRes = promptUser("Successfully downloaded " .. tostring(fileName) .. "!", 'Okay', 'Open Path')

            if promptRes == 2 then
                path = { "E:/", 'mods' }
                scrollingIndexOffset = 0
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


mainMenu.version = love.filesystem.read('EmbeddedModLoader/version.txt')








return mainMenu