-- create the gui on the home screen for managing mods
-- feel free to edit these files if you are a lurker or whatever
modLoader = {}
modLoader.UIElements = {}
modLoader.PrioritizedUIElements = {}
modLoader.Buttons = {}

-- loaded fonts
local loadedFonts = {}

function modLoader.createModLoaderButtons()

end

local function tableFind(haystack, needle)
    for i, v in pairs(haystack) do
        if v == needle then
            return i
        end
    end

    return -1
end


function modLoader.screen()
    local sX, sY, sW, sH = love.window.getSafeArea()

    local screen = {
        isScreen = true,

        x = sX,
        y = sY,

        visible = true,
        rendering = true, -- similar to visible but it works off of the parent hierarchy

        width = sW,--love.graphics.getWidth(),
        height = sH, --love.graphics.getHeight()
    }

    function screen.draw()
        screen.update()
    end

    function screen.update()
        -- re-fetch safe area, i dont think this can ever change but it doesnt hurt to be safe

        local sX, sY, sW, sH = love.window.getSafeArea()
        screen.x = sX
        screen.y = sY
        screen.width = sW
        screen.height = sH


        screen.renderWidth = sW--love.graphics.getWidth()
        screen.renderHeight = sH--love.graphics.getHeight()
        screen.renderX = screen.x
        screen.renderY = screen.y
    end

    function screen.parentOF()
        return screen.parent
    end

    screen.update()

    table.insert(modLoader.UIElements, screen)

    return screen
end


-- the button system is killing me so im gonna make my own :broken heart:

function modLoader:addButton(properties, dontAddToButtonsList)
    local lastHover = false -- for sound playing
    local button = {
        x = 0,
        y = 0,
        width = 0,
        height = 0,

        anchorPointX = 0,
        anchorPointY = 0,

        priority = 0,

        bgColor = {1, 1, 1},
        highlightBgColor = {
            --1, 1, 1
        },
        alpha = 1,
        text = "",

        rounding = 0,
        callback = nil, -- function to run on click

        type = 1, -- button

        -- used for size scaling and making sure all children wont render if the parent does not render.
        parent = modLoader.defaultParent,

        visible = true,
        rendering = true,
        isHovered = false,
        lastHover = false
    }

    if properties then
        for i, v in pairs(properties) do
            button[i] = v
        end
    end

    -- props
    function button.draw()
        -- intentionally avoid ternary
        if not button.parent.rendering or not button.parent.visible then
            button.rendering = false
        else
            button.rendering = true
        end

        button.update() -- so we can make sure all elements are scaled properly
        if not button.visible or not button.rendering then return end

        if button.log then -- debug
            print(
                    button.renderX,
                    button.renderY,
                    button.renderWidth,
                    button.renderHeight
            )
        end

        local bgR = button.bgColor[1]
        local bgG = button.bgColor[2]
        local bgB = button.bgColor[3]

        if button.isHovered and button.isHovered ~= button.lastHover then
            local source = love.audio.newSource('EmbeddedModLoader/assets/hover.ogg', 'static')
            source:setVolume(0.3)  -- Sets volume to 30% (if you intended '3' as a volume setting)
            source:play()

            properties.bgColor = {0, 0, 0}
            --love.sound.play(source)
        end

        button.lastHover = button.isHovered

        if button.isHovered then
            bgR = button.highlightBgColor[1] or math.abs(bgR - 0.1); -- becomes lighter if the color is too dark
            bgG = button.highlightBgColor[2] or math.abs(bgG - 0.1); -- becomes lighter if the color is too dark
            bgB = button.highlightBgColor[3] or math.abs(bgB - 0.1); -- becomes lighter if the color is too dark
        end

        love.graphics.setColor(bgR, bgG, bgB, button.alpha)
        love.graphics.rectangle("fill",
                button.renderX,
                button.renderY,
                button.renderWidth,
                button.renderHeight,
                0.5,
                0
        )
    end

    function button.parentOF()
        return button.parent
    end

    function button.update()
        lastHover = properties.isHovered

        local parent = button.parentOF
        if parent then
            parent = button.parentOF()
        end

        local containerWidth = parent.renderWidth
        local containerHeight = parent.renderHeight

        button.renderWidth = (containerWidth * button.width) + (button.isHovered and 10 or 0)
        button.renderHeight = (containerHeight * button.height) + (button.isHovered and 10 or 0)

        button.renderX = (parent.renderX + button.x*containerWidth) - (button.renderWidth*button.anchorPointX) + (button.isHovered and 10 * (button.anchorPointX-0.5) or 0) -- (button.isHovered and toScaleFromPixels(25, 1920) or 1)/2
        button.renderY = (parent.renderY + button.y*containerHeight) - (button.renderHeight*button.anchorPointY) + (button.isHovered and 10 * (button.anchorPointY-0.5) or 0) -- (button.isHovered and toScaleFromPixels(25, 1080) or 1)/2
    end

    function button.setBackgroundColor(r, g, b)
        if not g and not b then
            g = r
            b = r
        end

        button.bgColor = {r/255, g/255, b/255}
    end

    -- clean from memory
    function button.dispose()
        for i, v in pairs(properties) do
            properties[i] = nil
        end
        properties = nil

        table.remove(self.UIElements, tableFind(self.UIElements, button))
        table.remove(self.Buttons, tableFind(self.Buttons, button))

        for i, v in pairs(button) do
            button[i] = nil
        end
    end



    table.insert(self.UIElements, button)

    if not dontAddToButtonsList then
        table.insert(self.Buttons, button)
    end

    return button
end

function modLoader:addFrame(properties)
    local frame = self:addButton(properties, true)
    frame.type = 0;

    return frame
end


function modLoader:addSquareFrame(properties)
    local frame = self:addButton(properties)
    frame.type = 0;

    local superUpdate = frame.update

    return frame
end



-- // IMAGES // --

function modLoader:addImage(properties)
    local frame = self:addButton(properties, true)
    frame.type = 3
    frame.image = properties.image -- wont render without a image
    frame.visible = true
    frame.rotation = frame.rotation or 0

    function frame.draw(deltaTime)
        -- intentionally avoid ternary
        if frame.parent.rendering == false or not frame.parent.visible then
            frame.rendering = false
        else
            frame.rendering = true
        end

        if not frame.visible or (not frame.parent.visible or not frame.rendering) or not frame.image then
            return
        end

        frame.update() -- keeps everything aligned

        local bgR, bgG, bgB = unpack(frame.bgColor)

        if frame.isHovered then
            bgR = frame.highlightBgColor[1] or math.min(bgR + 0.1, 1)
            bgG = frame.highlightBgColor[2] or math.min(bgG + 0.1, 1)
            bgB = frame.highlightBgColor[3] or math.min(bgB + 0.1, 1)
        end

        love.graphics.setColor(bgR, bgG, bgB, frame.alpha)

        local img = frame.image
        local originX = img:getWidth() / 2
        local originY = img:getHeight() / 2

        -- Compute the correct position to draw the rotated image around its center
        local drawX = frame.renderX + frame.renderWidth * frame.anchorPointX
        local drawY = frame.renderY + frame.renderHeight * frame.anchorPointY

        local scaleX = frame.uniform == 'y' and frame.renderHeight / img:getHeight() or frame.renderWidth / img:getWidth()
        local scaleY = frame.uniform == 'x' and frame.renderWidth / img:getWidth() or frame.renderHeight / img:getHeight()

        love.graphics.draw(
                img,
                drawX + frame.renderWidth  * frame.anchorPointX,
                drawY + frame.renderHeight * frame.anchorPointY,
                math.rad(frame.rotation),
                scaleX,
                scaleY,
                originX,
                originY
        )
    end

    function frame.parentOF()
        return frame.parent
    end

    function frame.update()
        local parent = frame.parentOF()
        if not parent then return end

        frame.renderWidth = parent.renderWidth * frame.width
        frame.renderHeight = parent.renderHeight * frame.height

        frame.renderX = parent.renderX + (frame.x * parent.renderWidth) - (frame.renderWidth * frame.anchorPointX)
        frame.renderY = parent.renderY + (frame.y * parent.renderHeight) - (frame.renderHeight * frame.anchorPointY)
    end

    return frame
end




function modLoader:addText(text, properties)
    local frame = self:addFrame()
    frame.text = text
    frame.type = 2

    frame.rawTextSize = 48
    frame.textSize = love.graphics.getHeight()/1440 * frame.rawTextSize -- 48

    frame.alignment = frame.alignment or 'center'

    if properties then
        for i, v in pairs(properties) do
            frame[i] = v
        end
    end

    frame.loadedFont = love.graphics.newFont("resources/fonts/m6x11plus.ttf", frame.textSize)

    -- add functions

    function frame.updateFont()
        -- TODO: add checks to see if updating the text is necessary

        frame.textSize = love.graphics.getHeight()/1440 * frame.rawTextSize -- 48
        frame.loadedFont = love.graphics.newFont("resources/fonts/m6x11plus.ttf", frame.textSize)
    end

    function frame.draw()
        -- intentionally avoid ternary
        if frame.parent.rendering == false or not frame.parent.visible then
            frame.rendering = false
        else
            frame.rendering = true
        end

        if not frame.visible or (not frame.parent.visible or not frame.rendering) then return end
        frame.update() -- so we can make sure all elements are scaled properly

        local bgR = frame.bgColor[1]
        local bgG = frame.bgColor[2]
        local bgB = frame.bgColor[3]

        local scaleX = frame.scaleX or 1
        local scaleY = frame.scaleY or 1

        local currentFont = frame.loadedFont
        love.graphics.setFont(currentFont)

        love.graphics.setColor(bgR, bgG, bgB, frame.alpha)

        love.graphics.printf(frame.text, frame.renderX, frame.parent.renderHeight/2 + frame.parent.renderY - frame.textSize/2 + frame.parent.renderHeight*frame.y, frame.parent.renderWidth, 'center', 0, scaleX, scaleY)
    end

    function frame.parentOF()
        return frame.parent
    end

    function frame.update()
        local parent = frame.parentOF
        if parent then
            parent = frame.parentOF()
        end

        local containerWidth = parent.renderWidth
        local containerHeight = parent.renderHeight

        frame.renderWidth = (containerWidth * frame.width)
        frame.renderHeight = (containerHeight * frame.height)

        frame.renderX = (parent.renderX + frame.x*containerWidth) - (frame.renderWidth*frame.anchorPointX)
        frame.renderY = (parent.renderY + frame.y*containerHeight) - (frame.renderHeight*frame.anchorPointY)

        -- keep the text size consistent
        --frame.textSize = love.graphics.getHeight()/1440 * frame.rawTextSize -- 48
    end

    return frame
end


function modLoader:addNormalText(text, properties)
    local frame = self:addText(text, properties)

    -- add functions

    function frame.draw()
        -- intentionally avoid ternary
        if frame.parent.rendering == false or not frame.parent.visible then
            frame.rendering = false
        else
            frame.rendering = true
        end

        if not frame.visible or (not frame.parent.visible or not frame.rendering) then return end
        frame.update() -- so we can make sure all elements are scaled properly

        local bgR = frame.bgColor[1]
        local bgG = frame.bgColor[2]
        local bgB = frame.bgColor[3]

        local scaleX = frame.scaleX or 1
        local scaleY = frame.scaleY or 1

        local currentFont = frame.loadedFont
        love.graphics.setFont(currentFont)

        love.graphics.setColor(bgR, bgG, bgB, frame.alpha)

        love.graphics.print(frame.text, frame.renderX, frame.renderY, 0, frame.width, frame.height)
    end

    function frame.parentOF()
        return frame.parent
    end

    function frame.update()
        local parent = frame.parentOF
        if parent then
            parent = frame.parentOF()
        end

        local containerWidth = parent.renderWidth
        local containerHeight = parent.renderHeight

        frame.renderWidth = (containerWidth * frame.width)
        frame.renderHeight = (containerHeight * frame.height)

        frame.renderX = (parent.renderX + frame.x*containerWidth) - (frame.renderWidth*frame.anchorPointX)
        frame.renderY = (parent.renderY + frame.y*containerHeight) - (frame.renderHeight*frame.anchorPointY)

        -- keep the text size consistent
        --frame.textSize = love.graphics.getHeight()/1440 * frame.rawTextSize -- 48
    end

    return frame
end




function toScaleFromPixels(num1, scale, mode2)
    if (mode2) then
        return (num1 + scale)/scale
    end
    return num1/scale
end




-- mod menu ui setup



-- add my custom code into the Love functions so we wont need people installing the loader to install multiple files
function modLoader.load(...)
    font = love.graphics.newFont(48) -- Load the font once
    love.graphics.setFont(font) -- Set the font
end


-- allows us to draw on top of the game
function modLoader.draw(...)
    local screenSizeX = love.graphics.getWidth()
    local screenSizeY = love.graphics.getWidth()

    -- draw the original game first before drawing our own UI elements
    --super.draw(...)

    -- draw our own ui elements
    for i, uiElement in ipairs(modLoader.UIElements) do
        -- draw if it has a method for it
        uiElement.draw(...)
    end

    -- draw our own ui elements
    for i, uiElement in ipairs(modLoader.PrioritizedUIElements) do
        -- draw if it has a method for it
        local succ, err = pcall(function(...)
            uiElement.draw(...)
        end, ...)
    end
end


-- button handling and such
function modLoader.update( dt )
    local mouseX = love.mouse.getX();
    local mouseY = love.mouse.getY();

    if not mouseX or not mouseY then
        return
    end

    for i, uiElement in ipairs(modLoader.UIElements) do
        -- draw if it has a method for it
        if uiElement.onDraw then
            uiElement.onDraw(uiElement, dt)
        end
    end

    -- check for button bounds
    for i, button in ipairs(modLoader.Buttons) do
        button.isHovered = false

        if not button.renderX then
            goto hoverloop
        end

        if modLoader.blacklistEnabled and not button.whitelisted then
            goto hoverloop
        end

        if mouseX > button.renderX and mouseX < button.renderX + button.renderWidth then
            if mouseY > button.renderY and mouseY < button.renderY + button.renderHeight then
                button.isHovered = true
                if button.onHovered then
                    button.onHovered(mouseX, mouseY, button)
                end
            end
        end

        ::hoverloop::
    end

    -- original update
    --super.update(dt)
end

isHoveringButton = false

function modLoader.mousepressed(x, y, ...)
    local mouseX = x
    local mouseY = y

    local btnToCall
    local currentPriority = -99999
    local btnObject
    isHoveringButton = false

    -- check if we pushed a button
    for i, button in ipairs(modLoader.Buttons) do
        if button.whitelisted == true then
            print('canrun')
        end
        if modLoader.blacklistEnabled and not button.whitelisted then
            goto continue
        end

        if not mouseX or not button.renderX then
            goto continue
        end
        if not button.visible or not button.rendering then
            goto continue
        end

        if mouseX > button.renderX and mouseX < button.renderX + button.renderWidth then
            if mouseY > button.renderY and mouseY < button.renderY + button.renderHeight then
                isHoveringButton = true
                button.callback(x, y, button)
            end
        end

        ::continue::
    end

    -- disable all inputs from the game if the mod menu tells us to
    if modLoader.disableInputs then
        return
    end

    --return super.mousepressed(x, y, ...)
end



return modLoader