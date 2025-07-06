--[["rewrite" of the nativefs module so it will work on mobile devices]]--
-- original by megagrump@pm.me

-- module("nativefs", package.seeall)

local File = {
    getBuffer = function(self) return self._bufferMode, self._bufferSize end,
    getFilename = function(self) return self._name end,
    getMode = function(self) return self._mode end,
    isOpen = function(self) return self._mode ~= 'c' and self._handle ~= nil end,
}

local nativefs = {}

local conf = {
    workingDir = _G.MobileBehavior and love.filesystem.getSaveDirectory() or ""
}



love.filesystem.write("patched/logs.txt", "")
local originalPRINT = print
function print(...)
    local v = {...}
    local v1 = v[1]

    --[[if love.filesystem.getInfo("patched/logs.txt") == nil then
        love.filesystem.write("patched/logs.txt", love.filesystem.read("patched/logs.txt") .. "\n" .. v1)
    end]]

    if not _G.MenuSettings.WriteToLogs.Value then
        return
    end

    love.filesystem.write("patched/".. _G.CurrentLog .. "logs.txt", love.filesystem.read("patched/".. _G.CurrentLog .. "logs.txt") .. "\n" .. tostring(v1))

    return originalPRINT(...)
end

--[[function writeToFile(...)
    local v = {...}
    local v1 = v[1]

    --[[if love.filesystem.getInfo("patched/logs.txt") == nil then
        love.filesystem.write("patched/logs.txt", love.filesystem.read("patched/logs.txt") .. "\n" .. v1)
    end ] ]

    love.filesystem.write("patched/logs.txt", love.filesystem.read("patched/logs.txt") .. "\n" .. tostring(v1))
end]]


local function pathToName(dir)
    local path = ''

    for i = 1, #dir do
        local chr = string.sub(dir, (i - #dir + 1), (i - #dir + 1))
        if chr == "\n" then
            break
        end

        path = chr .. path
    end

    return path
end


-- we change the behavior of how NFS works if the user is on mobile to try and make sure
-- the filesystem works properly.



-- dir to write at
function nativefs.setWorkingDirectory(directory)
    -- debugging for while i work on the modloader, this shouldnt run for anybody who isnt me
    -- remove path so we dont explode
    -- love.filesystem.setIdentity("Balatro")

    print("setWorkingDirectory: " .. tostring(directory))

    print("Save Die: " .. tostring(love.filesystem.getSaveDirectory()))


    directory = string.gsub(directory, love.filesystem.getSaveDirectory(), "")


    print("setcheck1: " .. tostring(#directory >= #love.filesystem.getSaveDirectory())
    )

    print("setcheck2: " .. string.sub(directory, 1, #love.filesystem.getSaveDirectory()))

    if #directory >= #love.filesystem.getSaveDirectory() and string.sub(directory, 1, #love.filesystem.getSaveDirectory()) ==  love.filesystem.getSaveDirectory() then
        directory = string.sub(#love.filesystem.getSaveDirectory()+1, #directory)

        print("SUBSTRING FIX METHOD")

    end


    --"SET DIRECTORY: " .. directory
    conf.workingDir = directory -- directory
end

function nativefs.getWorkingDirectory()
    print('getWorkingDirectory Called.')
    print("Returning: " .. conf.workingDir)
    return conf.workingDir
end

function nativefs.getInfo(path)
    print(nativefs.getWorkingDirectory() .. path)
    local data = love.filesystem.getInfo(path) --  love.filesystem.getInfo(nativefs.getWorkingDirectory() .. path)

    if not data then
        return nil--{type = "NONE."}
    end

    return {
        type = data.type,
        filename = pathToName(path)
    }
end

function nativefs.newFileData(...)
    print("NFS NEW FILE DATA: ".. tostring(...))
    return love.filesystem.newFileData(...)
end

function nativefs.read(path, bypassWorkingDirectory)
    if path == "Mods/smods/localization/default.lua" then
        path = "Mods/smods/localization/en-us.lua"
    end

    return love.filesystem.read((bypassWorkingDirectory and "" or nativefs.getWorkingDirectory()) .. path)
end

function nativefs.write(path, contents)
    return love.filesystem.write(nativefs.getWorkingDirectory() .. path, contents)
end

function nativefs.remove(...)
    return love.filesystem.remove(...)
end


-- NOTES TO SELF!!!
-- love.filesystem.getDirectoryItems() reads both the .love and the save directory!!!
-- we wont need to explicitly define anything.



-- IM MAKING A CUSTOM NATIVEFS MODULE.
function nativefs.getDirectoryItems(path)
    local files = {}

    --print("[NATIVEFS] PATH PROVIDED: " .. nativefs.getWorkingDirectory() .. path)
    for i, v in pairs(love.filesystem.getDirectoryItems(nativefs.getWorkingDirectory() .. path)) do
        table.insert(files, v)
        --print("FOUND: " .. v)
    end

    --print("FOUND A TOTAL OF " .. #files .. " FILES.")

    return files
end

function nativefs.getDirectoryItemsInfo(path)
    local fileNames = nativefs.getDirectoryItems(path)
    local returnTable = {}

    for i, v in fileNames do
        table.insert(returnTable, nativefs.getInfo(path .. '/' .. v))
    end
end



function nativefs.createDirectory(path)
    return love.filesystem.createDirectory(nativefs.getWorkingDirectory() .. path )
end


-- loading
-- this is used by tailsman!
-- returns a function and a string with an error message (or nil if we didnt encounter an error loading the file)
function nativefs.load(name)
    local loadedCode
    local success, err = pcall(function()
        loadedCode = load(nativefs.read(name, true))
    end)

    return loadedCode, err
end





return nativefs
