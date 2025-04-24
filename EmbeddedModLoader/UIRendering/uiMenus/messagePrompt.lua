local mainMenu = {}
mainMenu.instances = {} -- i add to this if i need to edit something from a different window

mainMenu.screen = nil

-- // IMPORTANT // --

local path = {
    "E:/",
    "Mods",
    "Example",
    "Yay",
    'Skibidi',
    'Penis',
    'party leaked',
    'party leaked',
    'party leaked',
    'party leaked',
    'party leaked',
    'party leaked',

}
local info
local btnText1
local btnText2

local btn1
local btn2


local function tableFind(haystack, needle)
    for i, v in pairs(haystack) do
        if v == needle then
            return i
        end
    end

    return -1
end


-- returns 1 or 2
function promptUser(text, button1, button2)
    library.blacklistEnabled = true
    mainMenu.screen.visible = true

    btnText1.text = button1
    btnText2.text = button2
    info.text = text

    local ret = 0

    OKButton.callback = function()
        ret = 1
    end

    CANCELButton.callback = function()
        ret = 2
    end

    --[[CANCELButton.dispose()
    OKButton.dispose()
    backdrop.dispose()
    prompt.dispose()
    btnText1.dispose()
    btnText2.dispose()]]


    while ret == 0 do
        love.event.pump()
        love.graphics.clear()

        local trueDT = love.timer.getDelta()
        love.update(1/60)
        love.draw(1/60)

        if love.mouse.isDown(1) then
            modLoader.mousepressed(love.mouse.getX(), love.mouse.getY())
        end

        love.graphics.present()

        --forcePrint(ret)
    end

    library.blacklistEnabled = false
    mainMenu.screen.visible = false

    return ret
end


function mainMenu:setup(library)
    self.screen = library.screen()
    self.screen.visible = false

    library.defaultParent = self.screen

    -- // skib

    -- progress bar
    backdrop = library:addFrame({
        x = 0.5,
        y = 0.5,

        width = 1,
        height = 1,

        bgColor = {rgb(0, 0, 0)},
        alpha = 200/255,

        anchorPointY = .5,
        anchorPointX = .5,

        name = 'backdrop',
    })

    -- backdrop for the progress bar
    prompt = library:addFrame({
        x = 0.5, -- toScaleFromPixels(5, 1920),
        y = 0.5, -- toScaleFromPixels(7.5, 1080),

        width = toScaleFromPixels(600, 1920),
        height = toScaleFromPixels(400, 1080),

        bgColor = {rgb(47, 52, 48)},

        anchorPointY = .5,
        anchorPointX = .5,

        name = 'prompt',
    })

    -- yes/OK/confirm button
    OKButton = library:addButton({
        x = toScaleFromPixels(20, 600),
        y = toScaleFromPixels(380, 400),

        width = toScaleFromPixels(275, 600),
        height = toScaleFromPixels(50, 400),

        bgColor = {rgb(56, 184, 51)},

        parent = prompt,

        whitelisted = true,

        anchorPointY = 1,
        anchorPointX = 0,

        name = 'OKButton',
    })

    btnText1 = library:addText("txt", {
        x = 0.5,
        y = 0,--0.5,

        width = 1,
        height = 1,

        anchorPointX = 0.5,
        anchorPointY = 0.5,

        rawTextSize = 24,

        parent = OKButton,

        name = 'btnText1',
    })

    -- no/CANCEL/abort button
    CANCELButton = library:addButton({
        x = toScaleFromPixels(575, 600),
        y = toScaleFromPixels(380, 400),

        width = toScaleFromPixels(275, 600),
        height = toScaleFromPixels(50, 400),

        parent = prompt,
        bgColor = {rgb(209, 13, 55)},

        whitelisted = true,

        anchorPointY = 1,
        anchorPointX = 1,

        name = 'CANCELButton',
    })

    btnText2 = library:addText("txt", {
        x = 0.5,
        y = 0,--0.5,

        width = 1,
        height = 1,

        anchorPointX = 0.5,
        anchorPointY = 0.5,

        rawTextSize = 24,

        parent = CANCELButton,

        name = 'btnText2',
    })



    info = library:addText("balkalalallaa", {
        x = 0,
        y = -0.3,--0.5,

        width = 1,
        height = 1,

        anchorPointX = 0,
        anchorPointY = 0,

        rawTextSize = 15,

        parent = prompt,

        name = 'info',
    })

    table.remove(modLoader.UIElements, tableFind(modLoader.UIElements, info))
    table.remove(modLoader.UIElements, tableFind(modLoader.UIElements, btnText2))
    table.remove(modLoader.UIElements, tableFind(modLoader.UIElements, CANCELButton))
    table.remove(modLoader.UIElements, tableFind(modLoader.UIElements, btnText1))
    table.remove(modLoader.UIElements, tableFind(modLoader.UIElements, OKButton))
    table.remove(modLoader.UIElements, tableFind(modLoader.UIElements, prompt))
    table.remove(modLoader.UIElements, tableFind(modLoader.UIElements, backdrop))

    table.insert(modLoader.PrioritizedUIElements, backdrop)
    table.insert(modLoader.PrioritizedUIElements, prompt)
    table.insert(modLoader.PrioritizedUIElements, OKButton)
    table.insert(modLoader.PrioritizedUIElements, CANCELButton)
    table.insert(modLoader.PrioritizedUIElements, info)
    table.insert(modLoader.PrioritizedUIElements, btnText2)
    table.insert(modLoader.PrioritizedUIElements, btnText1)




    --[[promptUser([[Arguments
table buttons
    Table containing indices of mouse buttons to check.
    table button
        The index of a button to check. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependant.
    number ...
        Additional button indices to check.
Returns
boolean down
    True if any specified button is down.]-], "YES", "NO")]]
    --mainMenu.screen.visible = true
end




return mainMenu