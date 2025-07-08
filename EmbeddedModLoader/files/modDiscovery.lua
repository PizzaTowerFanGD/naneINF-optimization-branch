--// REQUIRES
local methods = {}

local fileHandler = require("EmbeddedModLoader/fileManagerHelper/fileManager")
local configPatcher = require("EmbeddedModLoader/injecting/configPatching/configPatcher")
local shaderPatcher = require("EmbeddedModLoader/injecting/shaders/shaderPatch")

-- search the mods in all possible mod directories

-- searches in these folders for mods.
--
function script_path() -- doens towkr
    local str = debug.getinfo(1, "S").source:sub(1)
    return str:match("(.*/)")
end

local modDirectories = {}

local saveDirectory = love.filesystem.getSaveDirectory()
local hardWrittenMods = "Mods"

-- check OS and insert directories
local osName = love.system.getOS()

-- these operating systems allow us to explore using io
if (osName == 'Windows' or osName == "Linux" or osName == "OS X") then
    -- ill add these once

    local path = script_path()
    --print(path)
end

-- all platforms support this.
table.insert(modDirectories, {"L", hardWrittenMods}) -- bundled inside the exe/.love

-- check if there is a mods folder in the save directory, if not we will in the future attempt to create one
-- and prompt the user to make one if it fails.

local saveDirModsFolder = love.filesystem.getInfo(saveDirectory .. "/Mods")

-- no mods folder exists, make one
if saveDirModsFolder == nil then
    local success, err = pcall(function()
        love.filesystem.createDirectory(saveDirectory .. "/Mods")
        table.insert(modDirectories, {"L", saveDirectory})
    end)

    print("No mods folder in the save directory (" .. saveDirectory .. "/Mods) was found. ")
    if not success then
        print("Attempt to create a Mods folder in the save directory failed. Reason: " .. err)
    else
        print("Successfully created a Mods folder in your save directory!")
    end
else
    table.insert(modDirectories, {"L", saveDirectory})
end



-- loop through these folders, and find the mod directories
local mods = {}
local texturePacks = {}



local function patchShaders(path)
    if not _G.MenuSettings.ShaderPatchingEnabled.Value then
        return
    end

    local modsContents = fileHandler.exploreFolderForNames(path, "L")
    if not modsContents['assets'] then
        for i, v in pairs(modsContents) do
            print(i)
        end

        return
    end

    local assetsContents = fileHandler.exploreFolderForNames(path .. "/assets", "L")
    if not assetsContents['shaders'] then
        return
    end

    -- shaders exist, get all shaders in the folder and run the patcher.
    local shadersInFolder = fileHandler.exploreFolderForNames(path .. "/assets/shaders", "L")

    -- patch them all.
    for i, v in pairs(shadersInFolder) do
        shaderPatcher.convert(path .. "/assets/shaders/" .. i)
    end
end



-- "L" : love.filesystem, "I" : io
for _, directory in pairs(modDirectories) do
    local method = directory[1]
    local path = directory[2]

    local modsFolder = fileHandler.exploreFolder(path, method)


    -- json patching
    --TODO: REMASTER SETTINGS GUI AND REINTRODUCE THIS SETTING
    --if _G.MenuSettings.ConfigPatching.Value == true then
        --configPatcher.search(directory, modsFolder)
    --end

    for _, mod in pairs( fileHandler.exploreFolder(path, method) ) do
        if love.filesystem.getInfo(mod .. "/" .. '.lovelyignore') then
            print("SKIP MOD")
            goto skipMod
        end

        table.insert(mods, {method, mod})

        if _G.MenuSettings.ConfigPatching.Value == true then
            configPatcher.search(mod)
        end

        patchShaders(mod, modsFolder)

        :: skipMod ::
    end
end

methods.mods = mods

return methods