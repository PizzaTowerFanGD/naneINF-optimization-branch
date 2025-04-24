local methods = {}
local currentlyLoaded = {}

function removeLuaExtension(path)
    return path:gsub(".lua", "")
end

function debugPrint(...)
    if false then
        return
    end

    return print(...)
end

function methods.RequestDynamicFile(path)
    --print(love.filesystem.getSaveDirectory())

    -- we should only ever be using these on lua files. this is a safe assumption.
    --print(string.sub(path, #path - 3, #path))
    if string.sub(path, #path - 3, #path) ~= ".lua" then
        path = path .. '.lua'
    end

    if currentlyLoaded[path] then
        return currentlyLoaded[path]
    end

    local fileInfo = love.filesystem.getInfo(path)
    if not fileInfo or not fileInfo.type == 'file' then
        debugPrint("No File at " .. path)
        return false
    end

    -- // fake file creation
    local fileMethods = {}
    fileMethods.path = path
    fileMethods.source = ""


    -- // fake editting

    function fileMethods.setSource(newSource)
        --debugPrint("WRITE")
        if _G.MenuSettings and _G.MenuSettings.LoadUsingIndexedFiles.Value then
            -- this shouldnt ever be possible???
            return
        end

        fileMethods.source = newSource
    end

    function fileMethods.getSource(newSource)
        return fileMethods.source
    end


    -- // used in loading from indexed files AND for debugging broken injections

    function fileMethods.dump()
        local filename = string.gsub(path .. ".lua", "/", "_")
        local dir = "patched"

        -- Ensure the patched directory exists in LÖVE's save directory
        if not love.filesystem.getInfo(dir) then
            love.filesystem.createDirectory(dir)
        end

        -- Write the file using LÖVE's filesystem write function
        local success, message = love.filesystem.write(dir .. "/" .. filename, fileMethods.source)
        if success then
            debugPrint("DUMPED: " .. path)
        else
            debugPrint("COULDNT DUMP PATCHED FILE " .. path .. ", REASON: " .. message)
        end
    end


    local loadedPath = path
    debugPrint("setting on")
    debugPrint(_G.MenuSettings, _G.MenuSettings and _G.MenuSettings.LoadUsingIndexedFiles.Value)

    if _G.MenuSettings and _G.MenuSettings.LoadUsingIndexedFiles.Value == true then
        loadedPath = "patched/" .. string.gsub(loadedPath .. '.lua', "/", "_")

        debugPrint("REDIRECT: " .. loadedPath)

        if not love.filesystem.getInfo(loadedPath) then
            debugPrint('didnt find redirect')
            loadedPath = path
        end
    end

    fileMethods.source = love.filesystem.read(loadedPath)

    --[[if math.random(1, 3) == 3 then
        fileMethods.source = "print('oops')"
    end]]

    -- add to the file cache
    currentlyLoaded[path] = fileMethods
    --print("read file (".. path .. ") and added it to the loading cache.")

    return fileMethods
end

return methods