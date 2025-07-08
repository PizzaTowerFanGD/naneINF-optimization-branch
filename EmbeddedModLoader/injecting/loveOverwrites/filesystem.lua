-- love.filesystem on every other platform (Android, Windows, MacOS, Switch, ETC...) all use a case insensitive filesystem.
-- but for some reason, file names are case sensitive on iOS ONLY. (atleast, on the BMM iOS version of balatro they are.)
-- so this script overwrites every necessary love.filesystem method and messes around with their paths before sending
-- the corrected version of the path (insensitive -> sensitive) to the original love.filesystem method.

local originalFS = love.filesystem

-- clone of love.filesystem
local FILESYSTEM = {}

for i, v in pairs(love.filesystem) do
    FILESYSTEM[i] = v
end


local function split(str)
    local tab = {""}
    local placement = 1
    local fs = "/"
    local backs = "\\"

    for i = 1, #str do
        local chr = string.sub(str, i, i)

        if chr == fs or chr == backs or i == #str then
            if i == #str then
                tab[placement] = tab[placement] .. chr
            end

            placement = placement + 1
            tab[placement] = ""
        else
            tab[placement] = tab[placement] .. chr
        end
    end

    tab[placement] = nil

    return tab
end

-- a very unfortunate method

local function Exists(path, target)
    for _, name in ipairs(FILESYSTEM.getDirectoryItems(path)) do
        if string.lower(name) == target then
            return name
        end
    end

    return nil
end


-- get UpperCase LowerCase Path
local function getULPath(path, offset)
    if path == nil then --[[print("NIL RECIEVED!!!!!!!!!!!!!!!!!!!!")]] return false end
    --print("UPPER_LOWER: " .. path)

    local pathStrings = split(path)
    local currentPath = ""
    local offset = offset or 0

    for i, name in ipairs(pathStrings) do
        if i == #pathStrings - offset + 1 then
            break
        end

        -- case sensitive takes precedence
        local check = currentPath .. (i == 1 and "" or "/")
        if Exists(check) then
            currentPath = check .. name
            goto continue
        end

        local lowered = string.lower(name)
        local lowPath = currentPath .. (i == 1 and "" or "/")
        local nonCaseSensitive = Exists(lowPath, lowered)

        if nonCaseSensitive then
            currentPath = lowPath .. nonCaseSensitive
            goto continue
        else
            --print("FAILED!!")
            return path --lowPath .. name
        end

        -- stop here, we will return false because we couldnt get a upper or lower name
        :: continue ::
    end

    --print("FINISHED AS: " .. currentPath)

    return currentPath
end

function love.filesystem.exists(name)
    local uPath = getULPath(name)

    if not uPath then
        return false
    end

    -- seems redundant, but uPath can also be a string which makes this extremely necessary
    return uPath and true or false
end

function love.filesystem.append(name, ...)
    local uPath = getULPath(name)
    if not uPath then return false, "Didnt exist" end

    return FILESYSTEM.append(uPath)
end

function love.filesystem.createDirectory(name, ...)
    local uPath = getULPath(name, -1)
    if not uPath then return false, "Didnt exist" end

    return FILESYSTEM.createDirectory(uPath .. "/" .. name, ...)
end

function love.filesystem.getDirectoryItems(name, ...)
    local uPath = getULPath(name)
    if not uPath then return {} end

    return FILESYSTEM.getDirectoryItems(uPath, ...)
end

function love.filesystem.getInfo(name, ...)
    local uPath = getULPath(name)
    if not uPath then return nil end

    return FILESYSTEM.getInfo(uPath, ...)
end

function love.filesystem.getLastModified(name, ...)
    local uPath = getULPath(name)
    if not uPath then return nil end

    return FILESYSTEM.getLastModified(uPath, ...)
end

function love.filesystem.getRealDirectory(name, ...)
    local uPath = getULPath(name)

    return FILESYSTEM.getRealDirectory(uPath, ...)
end

-- NOTE: remove once balatro goes to love 12 (if it ever does get released)
function love.filesystem.getSize(name, ...)
    local uPath = getULPath(name)

    return FILESYSTEM.getSize(uPath, ...)
end

function love.filesystem.isDirectory(name, ...)
    local uPath = getULPath(name)

    return FILESYSTEM.isDirectory(uPath, ...)
end

function love.filesystem.isFile(name, ...)
    local uPath = getULPath(name)

    return FILESYSTEM.isFile(uPath, ...)
end

function love.filesystem.isFused()
    return FILESYSTEM.isFused()
end

function love.filesystem.isSymlink(name, ...)
    local uPath = getULPath(name)

    return FILESYSTEM.isSymlink(uPath, ...)
end

function love.filesystem.lines(name, ...)
    local uPath = getULPath(name)

    return FILESYSTEM.lines(uPath, ...)
end

function love.filesystem.load(name, ...)
    local uPath = getULPath(name)
    if not uPath then return nil, "Didnt exist LOAD" end

    return FILESYSTEM.load(uPath, ...)
end

function love.filesystem.mount(name, ...)
    local uPath = getULPath(name)

    return FILESYSTEM.mount(uPath, ...)
end

function love.filesystem.newFile(name, ...)
    local uPath = getULPath(name)
    --if not uPath then return nil, "Didnt exist" end

    return FILESYSTEM.newFile(uPath, ...)
end

function love.filesystem.newFileData(contents, name)
    if not name then
        -- alternative
        local uPath = getULPath(contents)
        if not uPath then return nil, "Didnt exist NEWFILEDATA 1" end

        return FILESYSTEM.newFileData(uPath)
    end

    --local uPath = getULPath(name, -1)
    --if not uPath then return nil, "Didnt exist NEWFILEDATA" end

    return FILESYSTEM.newFileData(contents, name)
end

function love.filesystem.read(name, ...)
    local uPath = getULPath(name)
    if not uPath then return false, "Didnt exist READ" end

    return FILESYSTEM.read(uPath, ...)
end

function love.filesystem.remove(name, ...)
    local uPath = getULPath(name)
    if not uPath then return false, "Didnt exist REMOVE" end

    return FILESYSTEM.remove(uPath, ...)
end

-- maybe implement setCRequirePath??

function love.filesystem.setRequirePath(name, ...)
    local uPath = getULPath(name)

    return FILESYSTEM.setRequirePath(uPath, ...)
end

function love.filesystem.unmount(name, ...)
    local uPath = getULPath(name)

    return FILESYSTEM.unmount(uPath, ...)
end

function love.filesystem.write(name, ...)
    local uPath = getULPath(name)
    --if not uPath then return nil, "Didnt exist WRITE" end

    return FILESYSTEM.write(uPath, ...)
end

return love.filesystem