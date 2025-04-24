local mainMenu = {}
mainMenu.instances = {} -- i add to this if i need to edit something from a different window

mainMenu.screen = nil

local imgs = {}
local num = 0

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

    local text = library:addNormalText(text, {
        x = 0.2,
        y = 0.5,

        width = 1,
        height = 1,

        image = icon,
        bgColor = {1, 0.94, 0.94},

        anchorPointX = 0,
        anchorPointY = 0.18,

        onDraw = function(properties, deltaTime)
            properties.x = (180/(button.renderWidth or 1920))
        end,

        uniform = 'y',

        parent = button
    })

    local img = library:addImage({
        x = 0.115,
        y = 0.5,

        width = uO or 0.75,
        height = uO or 0.75,

        image =  assets.on,
        bgColor = {1,1,1},

        anchorPointX = 0,
        anchorPointY = 0,

        visible = false,

        onDraw = function(properties, deltaTime)
            properties.x = (80/(button.renderWidth or 1920))
        end,

        uniform = 'y',

        parent = button
    })


    function button.setValue(value)
        img.image = value and assets.on or assets.off
    end


    return button
end




-- // IMPORTANT // --

local defaultSettings = {
    LoadUsingIndexedFiles = {
        Name = "Load Using Indexed Files",
        Category = "Optimization",
        Value = true
    },

    -- no longer in use as LoadUsingMultiThreading is now forced
    --[[LoadUsingMultiThreading = {
        Name = "Load Using Multi-Threading [WIP]",
        Category = "Optimization",
        Value = true
    },]]

    DisplayDebugInjectionInfo = {
        Name = "Display Debug Injection Info [NW]",
        Category = "Debug",
        Value = true
    },

    WriteToLogs = {
        Name = "Write To Logs File patched/logs.txt (in save directory) WILL CAUSE MAJOR PERFORMANCE HITS",
        Category = "Debug",
        Value = false
    },

    AlwaysPromptModsEnabled = {
        Name = "Ask Before Loading Mods",
        Category = "General",
        Value = true
    },

    ModsEnabled = {
        Name = "Mods Enabled",
        Category = "General",
        Value = true
    },
}

-- todo, change to load and use settings
_G.MenuSettings = defaultSettings


local pathObjects = {}

function mainMenu:setup(library)
    self.screen = library.screen()
    self.screen.visible = false

    library.defaultParent = self.screen

    -- version
    library:addNormalText('Settings', {
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

    -- booleans

    local index = 0
    for i, v in pairs(defaultSettings) do
        index = index + 1
        local boolButton = addIconButton(
                v.Name,
                assets.delete,

                toScaleFromPixels(1920/2, 1920),
                toScaleFromPixels(100 + (index*125), 1080),
                toScaleFromPixels(1920 - 100, 1920),
                toScaleFromPixels(100, 1080),

                {rgb(52, 56, 49)}, 0.68
        )

        boolButton.anchorPointX = 0.5
        boolButton.anchorPointY = 0

        boolButton.setValue(v.Value)

        boolButton.callback = function()
            v.Value = not v.Value

            boolButton.setValue(v.Value)

            --_G.MenuSettings[i].Value = v.Value

            playSFX("toggle", nil, true)
        end
    end

    -- // LIST
end








return mainMenu