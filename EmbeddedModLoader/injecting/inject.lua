local inject = {}

--local fileManagerThing = require("EmbeddedModLoader/fileManagerHelper/fileManager")
local fileManagerThing = require("EmbeddedModLoader/fileManagerHelper/fileManager")


function sleep(n)
    if n > 0 then os.execute("ping -n " .. tonumber(n+1) .. " localhost > NUL") end
end

inject.completed = 0


local manifests = {}


-- because string.split doesnt exist for some reason
-- exclusive split
local function split(str, splitby)
    local splits = {""}
    local newIndex = 1

    for i = 1, #str - #splitby+1 do
        local pattern = string.sub(str, i, i + #splitby-1)
        local chr = string.sub(str, i, i)

        if pattern == splitby then
            i = i + #splitby
            newIndex = newIndex + 1


            splits[newIndex] = ""
            goto continue
        end

        splits[newIndex] = splits[newIndex] .. chr
        ::continue::
    end

    return splits
end

--[[ okay im going to be honest, im making a HUGE assumption here,
im REALLY not sure how regular father lovely determines what "SMODS" is when
passed a target similar to this:
    '=[SMODS _ "src/card_draw.lua"]'

ive been trying to figure it out and honestly im going to go insane so rather
what im going to do instead is search for the src folder in every mod and then
if it contains the lua file we are looking for we will just return the path to that
file, without overwriting whatever "=[SMODS _" is, i am aware that this is unoptimized
but im gonna go insane im sorry :broken:
]]

local function recursiveSearch(target, path)
    forcePrint(fileManagerThing)

    for _, searched in ipairs(fileManagerThing.exploreFolderWithNameAndPath(path)) do
        forcePrint(tostring(searched))
        forcePrint(tostring(searched.path))

        if not searched then goto continueRecur end
        if string.find(searched.path, target) then
            return searched.path
        end

        if searched.info.type == 'directory' then
            local results = recursiveSearch(target, searched.path)

            -- if it finds something then return it now, otherwise its okay vro keep searching
            if results then
                return results
            end
        end

        ::continueRecur::
    end

    return false
end


local function findModTargetLuaFile(target)
    if not target then return target end
    if string.sub(target, 1, 2) ~= "=[" then
        return target -- shoo
    end

    forcePrint("FOUND FOUND FOUND FOUND TAREGET THING: " .. target)

    local needle = split(target, '"')[2]

    forcePrint(tostring(needle[1]))
    forcePrint(tostring(needle[2]))

    -- search the 'haystack'

    local searchResults = recursiveSearch(needle, 'mods')
    if not searchResults then
        forcePrint("Could not find redirection to mod file")
        return target -- sorry couldnt find it :(
    end

    forcePrint("Found redirection! " .. target .. " TO " .. searchResults)
    return searchResults
end



local function loopInsert(type, list, patches, data, priority)
    local localPriority = 0 -- sorts out priority issues


    for _, patchTypes in pairs(patches) do
        for patchType, patchhh in pairs(patchTypes) do
            if patchType == type then
                localPriority = localPriority + 1
                patchhh.PATCH_TYPE = patchType

                if data then
                    patchhh.__PATH = findModTargetLuaFile(data.manifest.__PATH)--data.manifest.__PATH
                    patchhh.__NAME = data.manifest.__NAME
                end

                patchhh.target = findModTargetLuaFile(patchhh.target) -- condition is in the function
                patchhh.__PRIORITY = priority
                patchhh.__LOCAL_ORDER_PRIORITY = localPriority

                --print("LOOP INSERT LOADING FROM: " .. tostring(data.manifest.__NAME)) disp

                if not list[patchhh.target or patchhh.before] then
                    list[patchhh.target or patchhh.before] = {}
                end

                table.insert(list[patchhh.target or patchhh.before], patchhh)
            end
        end
    end
end

function inject.sort(tomlFiles)
    local list = {}

    for priority, data in ipairs(tomlFiles) do
        forcePrint("IPAIRS: " .. priority .. " : " .. data.manifest.__NAME )

        local patches = data.patches

        -- manifest
        loopInsert('manifest', manifests, patches, nil, priority or -10000)

        if not _G.MenuSettings.LoadUsingIndexedFiles.Value then
            -- pattern
            loopInsert('pattern', list, patches, data,  priority)

            -- regex
            loopInsert('regex', list, patches, data,  priority)

            -- copy
            loopInsert('copy', list, patches, data, priority)
        end

        -- copy
        loopInsert('module', list, patches, data, priority)
    end

    -- fix on 7/5/2025
    -- pattern and regex go at the same time, if the patches priorites are tied then pattern always goes first.

    local loadOrders = {
        manifest = 0,
        pattern = 1,  -- 1
        regex = 1.1,  -- 2
        copy = 3,
        module = 4
    }

    for i, v in pairs(list) do
        for ind, patch in ipairs(v) do
            forcePrint("BEFORESORT: " .. ind .. " : " .. patch.__NAME)
        end
    end

    -- Lovely loads patches in order of their patch type, and then uses priority to load specified patches.
    for i, v in pairs(list) do
        -- now we actually fix the priorities by sorting this list by the priorities
        table.sort(v, function(a, b)
            local test1 = 0;
            local test2 = 0;

            test1 = loadOrders[a.PATCH_TYPE] or 0
            test2 = loadOrders[b.PATCH_TYPE] or 0

            -- now we sort by local/order priorities, which is essential for many mods to load.
            --7/5/25
            --if test1 == test2 then

            if math.floor(test1) == math.floor(test2) then
                if a.__PRIORITY == b.__PRIORITY and test1 ~= test2 then
                    return test1 < test2
                end

                return a.__PRIORITY < b.__PRIORITY -- CHANGE ON 7/5/2025 SEE IF THIS WASTHE FIX,    ORIGINAL: ---- >>>>>        a.__LOCAL_ORDER_PRIORITY < b.__LOCAL_ORDER_PRIORITY
            end

            return test1 < test2--(a.__PRIORITY or -999999) < (b.__PRIORITY or -999999)  --test1 < test2
        end)
    end

    for i, v in pairs(list) do
        for ind, patch in ipairs(v) do
            --forcePrint("AFTERSORT: " .. ind .. " : " .. patch.__NAME)
            forcePrint("AFTERSORT: " .. ind .. " :::  NAME: " .. patch.__NAME .. "   :::  PRIORITY: " .. patch.__PRIORITY .. "\n LOCAL PRIORITY: " .. patch.__LOCAL_ORDER_PRIORITY .. "    :::    TYPE: " ..  loadOrders[patch.PATCH_TYPE])
            forcePrint(" --------------- ")
        end
    end

    return list
end



local function updateScreen()
    love.event.pump()
    love.graphics.clear()

    local trueDT = love.timer.getDelta()
    love.update(1/60)
    love.draw(1/60)

    love.graphics.present()
end

function inject.start(tomlFiles)
    if _G.MenuSettings.LoadUsingIndexedFiles.Value == true then
        --print("RETURN STOP STOP STOP")
        --return
    end

    local sortedTomls = inject.sort(tomlFiles)

    _G.startedInjecting = 0
    _G.finishedInjecting = 0

    -- update this so we can have accurate tracking
    for fileName, filePatches in pairs(sortedTomls) do
        for _, patch in pairs(filePatches) do
            _G.startedInjecting = _G.startedInjecting + 1
        end
    end

    -- multiThreading to significantly increase the speed of injection
    -- this is all necessary because of the bad regex module im using :(

    local filePatchThread = [[
local filePatches, channelName, target, loggingEnabled = ...
local completed = 0

regexInjection = require("EmbeddedModLoader/injecting/patterns/Regex")
moduleInjection = require("EmbeddedModLoader/injecting/patterns/Module")
patternInjection = require("EmbeddedModLoader/injecting/patterns/Pattern")
copyInjection = require("EmbeddedModLoader/injecting/patterns/Copy")

faker = require("EmbeddedModLoader/files/fakeLuaFile")
timer = require("love.timer")

function writeToFile(...)
    local v = {...}
    local v1 = v[1] or ""

    if not loggingEnabled then
        return
    end

    -- fix for missing logs
    love.thread.getChannel(channelName):push({
        inc = completed,
        cmd = "log",
        data = {v1}
    })

    --love.filesystem.write("patched/PreLaunch-logs.txt", love.filesystem.read("patched/PreLaunch-logs.txt") .. "\n" .. tostring(v1))
end

-- forces a print
function forcePrint(str, prefix)
    if not str then
        str = 'nil'
    end

    if not loggingEnabled then
        return
    end

    writeToFile(str)
    io.write(str .. '\n')
    io.flush()  -- Ensures it prints immediately
end

forcePrint("THE TARGET: " .. tostring(target))

file = faker.RequestDynamicFile(target)

if not file then
    forcePrint("THIS IS NTO A TARET: ".. tostring(target))
    love.thread.getChannel(channelName):push({
        inc = (#filePatches or 99)
    })
    return
end



if target == 'functions/common_events.lua' or target == 'functions/common_events' then
    forcePrint("____________________________________________________")
    forcePrint("NEW THREAD STARTED FOR functions/common_events!!!")
    forcePrint("----------------------------------------------------")
end

function rename(from, to)
    love.filesystem.write(to, love.filesystem.read(from))
    love.filesystem.remove(from)
end

local overwrite = false
if target == 'main' or target == 'main.lua' or target == 'originalmain.lua' then
    overwrite = true

    -- if originalmain.lua is not present, we will create it automatically.

    if not love.filesystem.getInfo("originalmain.lua") then
        rename("main.lua", "TEMP.lua")

        love.filesystem.write("originalmain.lua", love.filesystem.read("main.lua"))

        rename("TEMP.lua", "main.lua")
    end

end


for _, patch in ipairs(filePatches) do
    local command = {}

    if (patch.target == 'main.lua' or target == 'main') then -- if overwrite then --
        patch.target = 'originalmain.lua'
    end
    --if (patch.target == '=[SMODS _ "src/utils.lua"].lua') then
        --goto culpritSkip
        --break
    --end

    if patch.target == 'functions/common_events.lua' then
        forcePrint(_ .. " : " .. patch.PATCH_TYPE)
    end

    -- Save the file's current state before applying the patch
    -- local previousSource = file.getSource()

    if patch.__NAME then
        --print("FILE PATCHES PATCHING LOOP LOADING PATCH FROM: " .. patch.__NAME) disp
    end

    if patch.PATCH_TYPE == 'copy' then
        copyInjection:apply(patch.target, patch)
    end

    if patch.PATCH_TYPE == 'pattern' then
        patternInjection:apply(patch.target, patch)
    end

    if patch.PATCH_TYPE == 'regex' then
        regexInjection:apply(patch)
    end

    if patch.PATCH_TYPE == 'module' then
        command = moduleInjection:apply(patch)
    end

    completed = completed + 1
    command.inc = completed

    love.thread.getChannel(channelName):push(command)

        ::culpritSkip::
end

--print("FINISHED INJECTING INTO " .. tostring(target))

-- Ensure the final file write is pushed
love.thread.getChannel(channelName):push({
    inc = completed,
    cmd = "file",
    data = {target, file.getSource()}
})
]]

    local threads = {}
    local finishedThreads = {}
    local threadCompletions = {}
    local currentLogQueue = [[]]

    -- start threads
    for fileName, filePatches in pairs(sortedTomls) do
        if fileName == 'main.lua' then
            fileName = 'originalmain.lua'
        end

        local index = #threads+1
        threads[index] = { love.thread.newThread(filePatchThread), fileName}
        threads[index][1]:start(filePatches, "ch" .. index, fileName, _G.MenuSettings.WriteToLogs.Value)
    end

    -- if this is true then we loop again
    local activeThreads = true

    while activeThreads do -- _G.startedInjecting <= _G.finishedInjecting
        -- yields until injecting is finishd
        -- reset each repeat so it works properly
        _G.finishedInjecting = 0

        -- if this is true then we loop again
        activeThreads = false

        for index, thread in pairs(threads) do
            if not thread[1]:isRunning() and not finishedThreads[thread[2]] then
                --print("LUAVELY FINISHED INJECTING INTO: " .. thread[2])
                finishedThreads[thread[2]] = true
            end

            if thread[1]:getError() then
                error(thread[1]:getError())
            end

            if thread[1]:isRunning() then
                activeThreads = true
            end

            -- we dont continue after a thread ends as there might be more in their channel queue we need to recieve.

            local command = love.thread.getChannel('ch' .. index):pop()

            -- process command
            if command then
                activeThreads = true
            end

            -- a int which is updated each time a thread finishes
            if command and command.inc then
                -- we wont always have these in queue so its important to index them
                threadCompletions[index] = command.inc
                activeThreads = true
            end

            if command and command.cmd then
                local cmd = command.cmd
                local data = command.data

                activeThreads = true

                -- add the lua path to the modules emulation list.
                if cmd == 'moduleEMU' then
                    fakeRequireMethods.modulePaths[data[1]] = data[2]

                    print("EMULATING MODULE PATH: " .. data[1] .. " TO POINT TOWARDS " .. data[2])

                elseif cmd == 'file' then
                    local file = faker.RequestDynamicFile(data[1])

                    file.setSource(data[2])
                    file.dump() -- saves to the disk

                elseif cmd == 'log' then
                    currentLogQueue = currentLogQueue .. data[1] .. '\n'
                end
            end
        end

        -- total them up and display!!!!
        for i, v in pairs(threadCompletions) do
            _G.finishedInjecting = _G.finishedInjecting + v
        end

        -- write the entire log queue to file.

        updateScreen()
    end


    writeToFile(currentLogQueue)
end


return inject