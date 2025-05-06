local module = {}

local modsListCachePath = 'patched/injectionCache/lastMods.lua'


local function writeNewestChanges(mods)
    local str = "return {"

    -- ensure patched and injectionCache folders both exist.
    if not love.filesystem.getInfo('patched') then
        love.filesystem.createDirectory('patched')
    end

    if not love.filesystem.getInfo('patched/injectionCache') then
        love.filesystem.createDirectory('patched/injectionCache')
    end


    for i, v in pairs(mods) do
        if i == "__NumberOfMods" then
            goto continue
        end

        str = str .. '[ [[' .. i .. "]] ] = true, "
        :: continue ::
    end

    str = string.sub(str, 1, #str-2) .. "}"

    love.filesystem.write(modsListCachePath, str)
end


local function fetchLastLoadedMods()
    local mods

    local succ, err = pcall(function()
        mods, err = load(love.filesystem.read(modsListCachePath))()
    end)

    if not succ then
        forcePrint("[nanEINF]: Failed to view previous mod list. Error: " .. err)
    end

    local count = 0
    for i, v in pairs(mods) do
        count = count + 1
    end

    mods.__NumberOfMods = count

    return mods
end


local function collectMods()
    local returnTable = {}
    local modCount = 0

    for _, folderName in pairs(love.filesystem.getDirectoryItems('mods')) do
        local modPath = 'mods/' .. folderName
        local nameToReturn = modPath

        local dirInfo = (love.filesystem.getInfo(modPath) or {})

        if love.filesystem.getInfo(modPath .. '/' .. 'version.lua') then
            local succ, err = pcall(function()
                version, error = load(love.filesystem.read(modPath .. '/' .. 'version.lua'))()
            end)

            if succ then
                nameToReturn = version
            end
        end


        -- append the lastModified date to the end of every file
        nameToReturn = nameToReturn .. " ::  " .. tostring(love.filesystem.getInfo(modPath).modtime)
        modCount = modCount + 1

        returnTable[nameToReturn] = true
    end


    returnTable.__NumberOfMods = modCount

    return returnTable
end


-- // [[
function module.determineReinjection()
    if not love.filesystem.getInfo(modsListCachePath) or not _G.MenuSettings.OverwriteAutoReinjection.Value then
        writeNewestChanges(collectMods())
        return true
    end

    local currentlyInstalledMods = collectMods()
    local lastLoadAttemptMods = fetchLastLoadedMods()

    -- quick check
    if currentlyInstalledMods.__NumberOfMods ~= lastLoadAttemptMods.__NumberOfMods then
        writeNewestChanges(currentlyInstalledMods)
        return true
    end

    -- check both ways
    for i, v in pairs(currentlyInstalledMods) do
        if not lastLoadAttemptMods[i] then
            writeNewestChanges(currentlyInstalledMods)
            return true
        end
    end

    for i, v in pairs(lastLoadAttemptMods) do
        if not currentlyInstalledMods[i] then
            writeNewestChanges(currentlyInstalledMods)
            return true
        end
    end

    -- no reinjection needed.

    return false
end



return module