local mainMenu = {}
mainMenu.instances = {} -- i add to this if i need to edit something from a different window

mainMenu.screen = nil

-- // IMPORTANT // --

local path = {
   --[[ "E:/",
    "Mods",
    "Example",
    "Yay",
    'party leaked',
    'party leaked',
    'party leaked',
    'party leaked',
    'party leaked',
    'party leaked',]]
}


function mainMenu:setup(library)
    self.screen = library.screen()
    self.screen.visible = false

    library.defaultParent = self.screen

    -- // skib

    -- backdrop for the progress bar
    library:addFrame({
        x = 0.5, -- toScaleFromPixels(5, 1920),
        y = 0.8, -- toScaleFromPixels(7.5, 1080),

        width = 0.8 + toScaleFromPixels(20, 1920),
        height = toScaleFromPixels(150, 1080) + toScaleFromPixels(20, 1080),

        bgColor = {rgb(47, 52, 48)},

        anchorPointY = .5,
        anchorPointX = .5,
    })

    -- progress bar
    progressBar = library:addFrame({
        x = 0.1,
        y = 0.8,

        width = 0.8,
        height = toScaleFromPixels(150, 1080),

        bgColor = {rgb(20, 203, 23)},

        anchorPointY = .5,
        anchorPointX = 0,
    })

    progressBar.onDraw = function(deltatime)
        if not _G.finishedInjecting then
            _G.finishedInjecting = 0
            _G.startedInjecting = 0
        end

        progressBar.width = 0.8 * _G.finishedInjecting/_G.startedInjecting
    end
end








return mainMenu