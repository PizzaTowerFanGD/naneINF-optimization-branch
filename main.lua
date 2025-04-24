-- the new system makes everything easier when it comes to installing themod loader

-- start internal UI
love.filesystem.setCRequirePath(
        love.filesystem.getCRequirePath() .. ';?.so'
)

--local succ, func = ffi.load('ssl')
--print(succ, func)
--require('ssl')

-- makes my life easier
local path = "EmbeddedModLoader/"
function rgb(r,g,b,a)
    return r/255, g/255, b/255, (a and a/255 or 1)
end


--require('ssl')

function toScaleFromPixels(num1, scale, mode2)
    if mode2 then
        return num1*scale/scale
    end
    return num1/scale
end

function toDeg(rad)
    return rad * math.pi/180
end

-- assets
assets = require(path .. "UIRendering/assets")
library = require(path .. 'UIRendering/uiLibrary')

-- menus paths
local menuPaths = 'EmbeddedModLoader/UIRendering/uiMenus/'

library.load()

-- DEBUG
local currentOS = love.system.getOS()
_G.MobileBehavior = currentOS == 'iOS' or currentOS == 'Android' or true --[[debug, disable once mobile is confirmed to work.]]


function writeToFile(...)
    local v = {...}
    local v1 = v[1]

    --[[if love.filesystem.getInfo("patched/logs.txt") == nil then
        love.filesystem.write("patched/logs.txt", love.filesystem.read("patched/logs.txt") .. "\n" .. v1)
    end]]

    if not _G.MenuSettings then return end
    if _G.MenuSettings.WriteToLogs.Value then
        love.filesystem.write("patched/logs.txt", love.filesystem.read("patched/logs.txt") .. "\n" .. tostring(v1))
    end
end


-- forces a print
function forcePrint(str)
    if not str then
        str = 'nil'
    end

    if not _G.MenuSettings.WriteToLogs.Value then
        return
    end

    writeToFile(str)
    io.write(tostring(str) .. '\n')
    io.flush()  -- Ensures it prints immediately
end


-- temporarily will be hooked into these funcs
function love.draw(...)
    love.graphics.setBackgroundColor(rgb(20, 20, 19))

    love.graphics.setColor(1, 1, 1)
    --love.graphics.draw(assets.logo, 0.5, 0.5, 0, 0.25, 0.25, 0.5, 0.5)

    library.draw(...)
end

-- music path
musicManager = require(path .. 'menuScripts/runMusic')

function love.mousepressed(...)
    library.mousepressed(...)
end

function love.update(...)
    musicManager.check()
    library.update(...)
end

love.window.setMode(1000, 1000, {
    fullscreen = false,
    resizable = true
})

-- setup each GUI before loading them in
require(menuPaths .. 'mainMenu'):setup(library)
require(menuPaths .. 'fileSystem'):setup(library)
require(menuPaths .. 'loadingGame'):setup(library)
require(menuPaths .. 'settings'):setup(library)
require(menuPaths .. 'modManager'):setup(library)

require(menuPaths .. 'messagePrompt'):setup(library)

if true then
    --return
end

--[[local button = library:addButton({
    x = 0.5,
    y = 0.5,
    width = toScaleFromPixels(325, 1920),
    height = toScaleFromPixels(75, 1080),

    bgColor = {rgb(35, 36, 34)},
    highlightBgColor = {rgb(45, 48, 44)},

    anchorPointX = 0.5,
    anchorPointY = 0.5
})]]

-- used to start the injection.
local started = false

function _G.LoadGame()
    if started then
        print("Already injecting!") -- debounce
        return
    end

    -- enable the ui's before injecting
    require(menuPaths .. 'loadingGame').screen.visible = true




    oldRequire = require

    faker = require("EmbeddedModLoader/files/fakeLuaFile")

    fakeRequireMethods = require("EmbeddedModLoader/files/requireFakeFiles")

    -- some really weird issue randomly started happening so im not having any chances of a double module load
    -- causing issues.
    require = fakeRequireMethods.require
    getfenv()['require'] = fakeRequireMethods.require
    _G.require = fakeRequireMethods.require


    if _G.MenuSettings.ModsEnabled.Value then
        modDiscovery = require("EmbeddedModLoader/files/modDiscovery")
        luavely = require("EmbeddedModLoader/injecting/luavely")

        -- load this last, this causes the whole game to run.
        -- we want to make sure all the mods have loaded first before we actually load the game.

        forcePrint("run orginal")
    end

    -- stop the lobby music before the game loads so we dont get a bleeding issue
    for i, v in ipairs(_G.malleoMusicOmg) do
        v:stop()
    end

    local superRun = require("originalmain")
    love.run()
    --local smods = require('mods/smods/src/core')
end