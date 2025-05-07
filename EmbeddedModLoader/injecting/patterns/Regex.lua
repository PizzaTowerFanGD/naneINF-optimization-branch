local module = {}

local regex = require("EmbeddedModLoader/dataHandling/LuaRegex/init")

--local faker = require("EmbeddedModLoader/files/fakeLuaFile")



local check = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"
local function isAlphabeticCharacter(chr)
    for i = 1, #check do
        if chr == string.sub(check, i, i) then
            return true
        end
    end

    return false
end

--[[function forcePrint(...)
    return print(...)
end]]

local oldprintreal = print
local oldprint = function(...)
    --writeToConsole(...)
    return forcePrint(...)
end

--local function print(...)
--return print(...)
--end

local function spanOf(inside, find, ignore, offset)
    local findLen = #find
    --print(findLen)

    for i = #ignore, #inside do
        --print(string.sub(inside, i, i + findLen-1))

        if string.sub(inside, i, i + findLen-1) == find then
            return {
                start = offset + i,-- + 2,
                ['end'] = offset + i + findLen -1 --  + 2
            }
        end
    end

    return {}
end


-- NOTE TO THOSE WHO MAY BE LURKING
-- im not using string.gsub here because for some reason love has a tendancy to hang randomly whenever i use string.gsub.
-- i genuinely dont know why but unfortunately that means i have to write code like how i did here.
-- i guess you could say, it *loves* to hang hahahahha

-- jk i used ghsub


-- like the name says it finds and replaces named captures in the payload with the matched data.
-- im really not sure what to call these
local function findAndReplaceGroupRequests(payload, patch, matches)
    -- searches each char for $index and then gets the span and name of the group.

    local recording = false
    local recordingLength = 0

    local activeRecording = {}
    local savedRecordingData = {}

    for i = 1, #payload do
        local chr = string.sub(payload, i, i)

        if recording then
            -- save and stop recoridng
            if not isAlphabeticCharacter(chr) or (i == #payload) then
                recording = false
                --activeRecording.span['end'] = i
                if i == #payload and isAlphabeticCharacter(chr) then
                    activeRecording.name = activeRecording.name .. chr
                end

                -- sometimes we actually use $ for things which arent captures, like the for the money symbol in a string LOL

                if recordingLength > 0 then
                    table.insert(savedRecordingData, activeRecording)
                end

                activeRecording = {}
                --goto continue
                goto continue
            end

            -- write to recording thing
            activeRecording.name = activeRecording.name .. chr
            recordingLength = recordingLength + 1 -- yay it actually is a group request


            --goto continue
            goto continue
        end

        -- not recording yet
        if chr == "$" then
            recordingLength = 0

            recording = true
            activeRecording = {
                --span = i + 1,
                name = ""
            }
        end


        ::continue::
    end

    -- inject the group requests (??? WHAT ARE THEY CALLED!??!?) to the payload :D
    for _, data in pairs(savedRecordingData) do
        payload = string.gsub(payload, "$" .. data.name, matches.get_group(data.name).getValue())
    end

    --sleep(0.0000000000000001)

    return payload
end

--[[local faker = {
    RequestDynamicFile = function(...)
        local source = require(script.Parent.Source)


        return {
            getSource = function()
                return source
            end,

            setSource = function(new)
                source = new
            end,
        }
    end
}]]




function module:apply(patch)
    local file = faker.RequestDynamicFile(patch.target)
    local source = file.getSource()

    -- regex for finding the pattern
    forcePrint(patch.pattern)
    forcePrint("m")

    local newRe = regex.new(patch.pattern, "m", source) --.. (patch.verbose and 'x' or '')

    if #newRe <= 0 then
        oldprint("REGEX: NO MATCHES FOUND FOR: " .. patch.pattern .. "       IN    " .. patch.target .. "   !!!!!!!!!")
        return
    end

    -- the matchall function does not work as intended and does not return any other capture other than the first capture
    -- that is found, so to replace this we have to continue to iterate until we have reached patch.times or until we cant find another capture.

    local captureTimes = patch.times or math.huge---1
    local offset = 0
    local offset2 = 0

    if not file then
        return
    end

    -- the content we replace in the pattern, $0 means the first group aka the whole thing
    local root_capture = patch.root_capture or "0"--"$0"

    for i, exec in ipairs(newRe) do
        -- prevents too many captures from being made, weird method but it does the same thing
        if i > captureTimes then
            print("Capture index over! " .. i)
            goto continue
        end

        print("1")

        --iter = iter + 1

        -- find the match for the pattern in the script.
        local sourceToSearch = string.sub(source, 0, #source)
        local target = exec.get_group(0):extract() 		-- main span, this is the whole pattern that we found

        -- line prepend, just adds stuff before every line
        -- patch.line_prepend and exec.get_group(string.sub(patch.line_prepend, 2)).getValue() or ""
        local prepend = exec.get_group(string.sub(patch.line_prepend or "$indent", 2)).getValue() or ""


        -- find the span of the location we want to replace. if the rootcapture is 0 that means we are straight up editting the pattern we found.
        -- which happens most of the time we use regex, so just use the targetSpan if the RC is 0

        if string.sub(root_capture, 1, 1) == "$" then
            root_capture = string.sub(root_capture, 2)
        end

        local rootGroup = exec.get_group(root_capture):extract()
        local replaceSpan = root_capture == "0" and target.span or rootGroup.span

        -- now that we have the range to replace all we have to do is set some group indication things (EX: $restcond, $rest, etc..) to their
        -- grouped values.

        print("2")
        local payload = findAndReplaceGroupRequests(patch.payload, patch, exec)
        --findAndReplaceGroupRequests(payload)

        --
        if isAlphabeticCharacter(string.sub(payload, 1, 1)) then
            print('ADD SPACING 1')
            local checkLoc = (patch.position == 'after' and replaceSpan['end'] or replaceSpan.start) - 1

            if isAlphabeticCharacter(string.sub(source, checkLoc, checkLoc)) then
                payload = ' ' .. payload
            end
        end

        -- NOTE TO SELF: offsetting code change worked really well with smods but is NOT working well with anything else. REVERT OR FIX!!

        if isAlphabeticCharacter(string.sub(payload, #payload, #payload)) then
            print('ADD SPACING 2')
            local checkLoc = (patch.position == 'before' and replaceSpan.start or replaceSpan['end']) + 1

            if isAlphabeticCharacter(string.sub(source, checkLoc, checkLoc)) then
                payload = payload .. ' '
            end
        end

        -- yipe kai yay okay its time to inject it
        --local sub1 = 1 --#root_capture --(root_capture == '0' and 1 or #root_capture-exec.n+1)--1 -- -2      --  #root_capture-exec.n)
        --local sub2 = 1 --(root_capture == '0' and 1 or #root_capture+exec.n-1)--1 -- +2      --  #root_capture-exec.n)

        print("3")

        -- spagetti code
        if patch.position == 'at' then
            source = string.sub(source, 1, replaceSpan.start_ - 1)--2)
                    .. payload
                    .. string.sub(source, replaceSpan.end_ + 1)

        elseif patch.position == 'before' then
            source = string.sub(source, 1, replaceSpan.start_)
                    .. payload
                    .. string.sub(source, replaceSpan.start_ + 1)

        elseif patch.position == 'after' then
            source = string.sub(source, 1, replaceSpan.end_ + offset)
                    .. payload
                    .. string.sub(source, replaceSpan.end_ + 1)

            --offset = replaceSpan['end'] + 1 + offset + #payload + 1 -- - 1
            --offset = offset - 1
        end

        print("4")

        --offset = replaceSpan['end'] + sub2 + offset--replaceSpan['end']
        --print('setsource')
        file.setSource(source)

        ::continue::
    end


    --print(newRe)
    --print({file.getSource()})
end




return module
