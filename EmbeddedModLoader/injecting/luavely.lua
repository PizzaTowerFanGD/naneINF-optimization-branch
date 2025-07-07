-- search the mods in all possible mod directories
local luavely = {}

local mods = modDiscovery.mods
local fileManager = require("EmbeddedModLoader/fileManagerHelper/fileManager")
local toml = require("EmbeddedModLoader/dataHandling/TOML/tinytoml")

local lovelyTomlFiles = {}

local function readAndParseTOML(lovelyFile, type)
    local fileContents = fileManager.read(lovelyFile, type)
    local parsedTomlFile = toml.parse(fileContents, {load_from_string = true})

    -- add if its missing
    --[[if not lovelyTomlFiles[lovelyFile] then
        lovelyTomlFiles[lovelyFile] = {}
    end]]

    -- there is a chance where the file might not have a manifest, so provide a dummy manifest
    if lovelyFile == 'Mods/Talisman/lovely.toml' then
        forcePrint("LOVELY FILE TALISMAN MANIFSEST: " .. tostring(parsedTomlFile.manifest))
    end
    parsedTomlFile.manifest = parsedTomlFile.manifest or {
        version = "1.0.0",
        dump_lua = true, -- does nothing LOL
        priority = 0,
    }

    local manifest = parsedTomlFile.manifest

    -- used in copy.lua
    -- iterates through each character until the mod path has been spelt out.
    -- this is what happens when a man is forbidden his string.split
    local rootPath = ""
    local cutoff = false

    --[[if lovelyFile == 'mods/Talisman/lovely.toml' then
        forcePrint("LOVELY FILE IS TALISMAN LOVETOML")
    end]]

    for i = 0, #lovelyFile do
        local chr = string.sub(lovelyFile, i, i)
        rootPath = rootPath .. chr

        if cutoff and chr == '/' then
            break
        end

        if not cutoff and rootPath == 'Mods/' then
            cutoff = true
        end
    end

    --[[if lovelyFile == 'mods/Talisman/lovely.toml' then
        forcePrint("TALISMAN PATH " .. rootPath)
    end]]

    forcePrint("manifest PATH " .. rootPath)

    parsedTomlFile.manifest.__PATH = rootPath
    parsedTomlFile.manifest.__NAME = lovelyFile

    -- add the parsed toml file data to the table in order by priority.
    --print(tonumber(manifest.priority * -1))
    table.insert(lovelyTomlFiles, tonumber(manifest.priority), parsedTomlFile)
    --print(#lovelyTomlFiles)
end

-- finds the toml files and adds to lovelyTomlFiles
for _, modInfo in ipairs(mods) do
    local path, type = modInfo[2], "L"--modInfo[1]

    -- check if the mod has a lovely folder
    local lovelyFolder = path .. "/lovely"
    local hasLovelyPath = fileManager.getFileInfo(lovelyFolder, type)
    local hasLovelyRootToml = fileManager.getFileInfo(path .. '/lovely.toml', type) -- lovely.toml file in the mod root

    if hasLovelyRootToml then
        forcePrint(path .. " HAS LOVELY ROOT TOML. " .. type)
        readAndParseTOML(path .. '/lovely.toml', type)
        forcePrint(path .. " READ AND PARSED ROOT LOVELY TOML LOVELY ROOT TOML. " .. type)
    end
    if not hasLovelyPath and not hasLovelyRootToml then
        goto continue
    end

    -- if we have a lovely folder read all the files inside of it and add to the list
    for _, lovelyFile in ipairs(fileManager.exploreFolder(lovelyFolder, type)) do
        if string.find(lovelyFile, ".lua") then
            goto continue2
        end

        readAndParseTOML(lovelyFile, type)

        ::continue2::
    end

    ::continue::
end

local len = 0
for i, v in pairs(lovelyTomlFiles) do
    len = len + 1

    forcePrint(v.manifest.__NAME)
end

forcePrint("the true length of tomlFileList is: " .. len)

-- offset the priorites by the lowest found priority so we can actually read EVERY file
local lowestOffset = math.huge

-- start script injecting
-- multithreading is now forced (absolutely no reason to not use it)
local injecting = require("EmbeddedModLoader/injecting/inject") --(_G.MenuSettings.LoadUsingMultiThreading.Value and '/WIP_threading' or '') .. "/inject")
local injectingSlowLow = require("EmbeddedModLoader/injecting/injectLowPerf") --(_G.MenuSettings.LoadUsingMultiThreading.Value and '/WIP_threading' or '') .. "/inject")



local function sort(table_)
    local sorted = {}
    local placement = 1

    local continuing = true

    while continuing do
        local index = -math.huge
        local value = math.huge

        for i, v in pairs(table_) do
            if v.manifest.priority < value then
                value = v.manifest.priority
                index = i
            end
        end

        if index == -math.huge then
            break
        end

        sorted[placement] = table_[index]
        table_[index] = nil -- remove from the table
        placement = placement + 1
    end

    return sorted
end



-- we MUST use ipairs here, which stops at the first nil value which ALSO means it could skip some files, so we sort and change the priorities to be linear
-- table.sort doesnt work when we have negative values, heres my inefficent selection sort

lovelyTomlFiles = sort(lovelyTomlFiles)

-- change priorities
--[[for i, v in pairs(lovelyTomlFiles) do
    v.priority = i
end]]

-- now that these are fixed it should be safe to inject

luavely.lovelyTomlFiles = lovelyTomlFiles

-- TODO: Refactor the code so that these arent two copies of the same file with a minute difference
if _G.MenuSettings.LowPerformanceMode.Value then
    injectingSlowLow.start(lovelyTomlFiles)
else
    injecting.start(lovelyTomlFiles)
end


return luavely