-- uses fake files when possible
local faker = require("EmbeddedModLoader/files/fakeLuaFile")

local loadedRequires = {}
local methods = {}
local fileHandler = require("EmbeddedModLoader/fileManagerHelper/fileManager")

methods.modulePaths = {}


-- make sure we have a mods folder
pcall(function()
    if not love.filesystem.getInfo('mods') then
        love.filesystem.createDirectory('mods')
    end
end)



oldRequire = require
function methods.require(path)
    local luaFile = faker.RequestDynamicFile(path)

    -- allows for the emulation of modules,
    -- ex: require "SMODS.version"
    print(path)
    if methods.modulePaths[path] then
        return oldRequire(methods.modulePaths[path])
    end

    -- require has been loaded, return that instead.
    if path == 'lovely' then
        return {
            version = 'luavely beta 0.9',
            mod_dir = "mods"--love.filesystem.getSaveDirectory()
        }
    end


    --print(path)
    if loadedRequires[path] then
        return loadedRequires[path]
    end

    local luaFile = faker.RequestDynamicFile(path .. ".lua") -- add the extension cuz we need itr to find the file

    -- file with that path was not found, it is possible that it is a require like "ffi" or "utf8", so default to oldRequire
    if not luaFile then
        print("file with the name: " .. path .. " was not found. resorting to the old require")
        return oldRequire(path)
    end

    -- load the code and run it
    local chunk, error_
    local succ, err = pcall(function()
        chunk, error_ = load(luaFile.getSource(), path)()
    end)

    if not succ or error_ then
        forcePrint("Error loading: " .. tostring(path) .. ", Fallback to default script.")
        forcePrint("Reason: " .. err .. "  " .. tostring(error_))
        forcePrint(error_)
        forcePrint(err)
        --error(error_ or err)

        forcePrint(error_ or err)
        loadedRequires[path] = oldRequire(path)
    end

    loadedRequires[path] = chunk
    return loadedRequires[path]
end


return methods