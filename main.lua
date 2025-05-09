-- the new system makes everything easier when it comes to installing themod loader
--[[love.filesystem.setCRequirePath(
        love.filesystem.getCRequirePath() .. ';?.so'
)
print(love.filesystem.getSaveDirectory())
--local succ, func = ffi.load('ssl')
--print(succ, func)
--require('ssl')]]

love.filesystem.write("patched/PreLaunch-logs.txt", "")
love.filesystem.write("patched/PostLaunch-logs.txt", "")

-- makes my life easier
local path = "EmbeddedModLoader/"
local menuPaths = 'EmbeddedModLoader/UIRendering/uiMenus/' -- menus paths

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

-- start internal UI
-- assets
assets = require(path .. "UIRendering/assets")
library = require(path .. 'UIRendering/uiLibrary')
reinject = require(path .. 'injecting/autoDetermineReinjection')
library.load()

-- DEBUG
local currentOS = love.system.getOS()

_G.CurrentLog = "PreLaunch-"
_G.MobileBehavior = currentOS == 'iOS' or currentOS == 'Android' or true --[[debug, disable once mobile is confirmed to work.]]

function writeToFile(...)
    local v = {...}
    local v1 = v[1]

    if not _G.MenuSettings then return end
    if _G.MenuSettings.WriteToLogs.Value then
        love.filesystem.write("patched/".. _G.CurrentLog .. "logs.txt", love.filesystem.read("patched/".. _G.CurrentLog .. "logs.txt") .. "\n" .. tostring(v1))
    end
end


function error(...)
    return forcePrint(...)
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

function love.keypressed(key)
    -- debug
    if key == 'l' then
        _G.MenuSettings.OverwriteAutoReinjection.Value = false
        _G.MenuSettings.LoadUsingIndexedFiles.Value = false
    end
end

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

    if _G.MenuSettings.LoadUsingIndexedFiles.Value then
        _G.MenuSettings.LoadUsingIndexedFiles.Value = not reinject.determineReinjection()
    end

    -- enable the ui's before injecting
    require(menuPaths .. 'loadingGame').screen.visible = true

    -- setup the fake requiring system to load our fake files

    oldRequire = require
    faker = require("EmbeddedModLoader/files/fakeLuaFile")
    fakeRequireMethods = require("EmbeddedModLoader/files/requireFakeFiles")

    -- some really weird issue randomly started happening so im not having any chances of a double module load
    -- causing issues.
    require = fakeRequireMethods.require
    getfenv()['require'] = fakeRequireMethods.require
    _G.require = fakeRequireMethods.require


    -- inject if we have mods enabled
    if _G.MenuSettings.ModsEnabled.Value == true then
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

    -- if we have this enabled we will overwrite love.filesystem entirely
    -- this is a bugfix for many texture packs and mods on iOS.
    if _G.MenuSettings.EnforceInsensitiveFilesystem.Value == true then
        love.filesystem = require(path .. 'injecting/loveOverwrites/filesystem')
    end

    -- everything is ready, lets launch!!!!
    _G.CurrentLog = "PostLaunch-"

    local superRun = require("originalmain")
    love.run()
end