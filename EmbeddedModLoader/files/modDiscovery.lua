--// REQUIRES
local methods = {}

local fileHandler = require("EmbeddedModLoader/fileManagerHelper/fileManager")


-- search the mods in all possible mod directories

-- searches in these folders for mods.
--
function script_path() -- doens towkr
    local str = debug.getinfo(1, "S").source:sub(1)
    return str:match("(.*/)")
end

local modDirectories = {}

local saveDirectory = love.filesystem.getSaveDirectory()
local hardWrittenMods = "mods"

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

local saveDirModsFolder = love.filesystem.getInfo(saveDirectory .. "/mods")

-- no mods folder exists, make one
if saveDirModsFolder == nil then
    local success, err = pcall(function()
        love.filesystem.createDirectory(saveDirectory .. "/mods")
        table.insert(modDirectories, {"L", saveDirectory})
    end)

    print("No mods folder in the save directory (" .. saveDirectory .. "/mods) was found. ")
    if not success then
        print("Attempt to create a mods folder in the save directory failed. Reason: " .. err)
    else
        print("Successfully created a mods folder in your save directory!")
    end
else
    table.insert(modDirectories, {"L", saveDirectory})
end



-- loop through these folders, and find the mod directories
local mods = {}
local texturePacks = {}



-- "L" : love.filesystem, "I" : io
for _, directory in pairs(modDirectories) do
    local method = directory[1]
    local path = directory[2]

    for _, mod in pairs(fileHandler.exploreFolder(path, method) ) do
        table.insert(mods, {method, mod})
    end
end


methods.mods = mods

return methods