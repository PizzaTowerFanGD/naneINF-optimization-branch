local mainMenu = {}
mainMenu.instances = {} -- i add to this if i need to edit something from a different window

mainMenu.screen = nil

-- bad resolution fix for ios
pcall(function()
    love.window.updateMode({
        highdpi = true
    })
end)

-- Menus
local settingsMenu = require('EmbeddedModLoader/UIRendering/uiMenus/settings')
local fileSystemMenu = require('EmbeddedModLoader/UIRendering/uiMenus/fileSystem')
local modManagerMenu = require('EmbeddedModLoader/UIRendering/uiMenus/modManager')
local https = {
    moduleType = 'not implemented'
}--require("EmbeddedModLoader/libraries/https/https")



local sounds = {}

function playSFX(name, volume, useCache)
    print(name)
    local sound = not useCache and sounds[name]  or love.audio.newSource(assets[name], 'static')
    sound:setVolume(volume or 0.65)
    sound:play()

    if not sounds[name] then
        sounds[name] = sound
    end
end

--love.window.setMode(900, 900, {fullscreen = false, resizable  = true})

function mainMenu:setup(library)
    self.screen = library.screen()
    self.screen.visible = true

    library.defaultParent = self.screen

    -- logo
    library:addImage({
        x = 0.5,
        y = 0.25,

        width = 0.5,
        height = 0.5,

        image = assets.logo,
        bgColor = {1,1,1},

        anchorPointX = 0,
        anchorPointY = 0,

        onDraw = function(properties)
            properties.width = 0.5 + math.cos(os.clock()/0.5)/100
            properties.height = 0.5 + math.cos(os.clock()/0.5)/100
        end
    })


    -- version
    local version = fileSystemMenu.version
    library:addText('version: '.. version, {
        x = 0.25,
        y = 0.48,

        width = 1,
        height = 0.3,

        bgColor = {rgb(55, 55, 52)},

        anchorPointY = 0,
        anchorPointX = 0,

        alignment = 'center'
    })

    local bgColor
    if tostring(https.moduleType) == 'NONE' then
        bgColor = { rgb(252, 3, 78) }
    else
        bgColor = { rgb(33, 33, 31) }
    end

    library:addNormalText('https: '.. tostring(https.moduleType), {
        x = 0.025,
        y = 0.962,

        width = 1,
        height = 1,

        bgColor = bgColor,

        anchorPointY = 0,
        anchorPointX = 0,

        alignment = 'center'
    })

    -- create the list of buttons in the menu

    local buttons = {
        'load', 'files', 'mods', 'settings'
    }

    -- config so i can change these quick
    local btnHeight = 325
    local btnDistance = 10

    for i, text in pairs(buttons) do
        local button = library:addButton({
            x = toScaleFromPixels(1920/2 - ((btnHeight+btnDistance) * i-(#buttons)*btnHeight/1.5), 1920),
            y = 0.6, --(1080/2 - ((btnHeight+btnDistance) * i-(#buttons)*btnHeight/1.5), 1080),
            width = toScaleFromPixels(325, 1920),
            height = toScaleFromPixels(325, 1080),

            bgColor = {rgb(35, 36, 34)},
            highlightBgColor = {rgb(45, 48, 44)},

            anchorPointX = 0.5,
            anchorPointY = 0.5,

            callback = function()
                playSFX("open_sound", 2)

                if text == 'load' then
                    if _G.MenuSettings.AlwaysPromptModsEnabled.Value then
                        local easterEgg = math.random(1, 1000) == 1 and "NO 👿👿👿🎂👀💥💥🤯💣" or "No."
                        local pressed = promptUser("Would you like to load with mods enabled?", "Yes!", easterEgg)

                        _G.MenuSettings.ModsEnabled.Value = not (pressed == 2)
                    end

                    musicManager.updateSong(5)
                    _G.LoadGame()
                end

                if text == 'mods' then
                    self.screen.visible = false
                    modManagerMenu.screen.visible = true
                    musicManager.updateSong(4)
                end

                if text == 'settings' then
                    self.screen.visible = false
                    settingsMenu.screen.visible = true
                    musicManager.updateSong(2)
                end

                if text == 'files' then
                    --fileDownloader.download("https://codeload.github.com/MathIsFun0/Cryptid/zip/refs/heads/main", '')
                    --_G.iosTest = not _G.iosTest

                    self.screen.visible = false
                    fileSystemMenu.screen.visible = true
                    musicManager.updateSong(3)
                end
            end
        })

        library:addText(text, {
            x = 0,
            y = 0.4,
            width = 1,
            height = 1,

            bgColor = {rgb(255, 255, 255)},

            anchorPointX = 0,
            anchorPointY = 0,

            parent = button,
        })

        -- iamge

        --[[library:addImage({
            image = assets[text],
            x = 0.5,
            y = 0.5,

            anchorPointY = 0.5,
            anchorPointX = 0.5,

            parent = button
        })]]

        library:addImage({
            x = 0.5,
            y = 0.45,

            width = 0.75,
            height = 0.75,

            image = assets[text],
            bgColor = {1,1,1},

            anchorPointX = 0,
            anchorPointY = 0,

            onDraw = function(properties, deltaTime)
                if text == 'settings' then
                    properties.width = 0.7
                    properties.height = 0.7

                    if not properties.DATA_ then
                        properties.DATA_ = 0
                    end

                    properties.DATA_ = properties.DATA_ + (deltaTime*2)

                    properties.rotation = properties.rotation + math.sin(properties.DATA_)*math.sin(properties.DATA_)/((3 - (properties.parent.isHovered and 2 or 0)))--4


                elseif text == 'mods' then
                    local speed = 1 + (properties.parent.isHovered and 2 or 0)
                    properties.width = 0.75 + math.cos(os.clock()/0.5 * speed)/25
                    properties.height = 0.75 + math.cos(os.clock()/0.5 * speed)/25

                elseif text == 'files' then
                    properties.image = properties.parent.isHovered and assets['folder_open'] or assets['files']

                    local speed = 1 + (properties.parent.isHovered and 2 or 0)
                    properties.width = 0.75 + math.cos(os.clock()/0.5 * speed)/25
                    properties.height = 0.75 + math.cos(os.clock()/0.5 * speed)/25

                elseif text == 'load' then
                    local enlargen = 0 + (properties.parent.isHovered and 0.1 or 0)
                    properties.width = 0.5 + enlargen
                    properties.height = 0.5 + enlargen

                end
            end,

            parent = button
        })

        if text == 'load' then
            library:addImage({
                x = 0.5,
                y = 0.45,

                width = 0.75,
                height = 0.75,

                image = assets['loading'],
                bgColor = {1,1,1},

                anchorPointX = 0,
                anchorPointY = 0,

                onDraw = function(properties, deltaTime)
                    local speed = 5 * (properties.parent.isHovered and 2 or 1)

                    properties.rotation = properties.rotation + deltaTime * speed*20
                    properties.width = 0.75 + math.cos(os.clock()/0.5 * (speed-2.5)/2.5)/25
                    properties.height = 0.75 + math.cos(os.clock()/0.5 * (speed-2.5)/2.5)/25
                end,

                parent = button
            })
        end
    end
end

-- pass the event to both menus who need this
function love.wheelmoved(...)
    modManagerMenu.wheelmoved(...)
    fileSystemMenu.wheelmoved(...)
end





return mainMenu