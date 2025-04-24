local module = {}

local regex = require("EmbeddedModLoader/dataHandling/LuaRegex/Regexp")

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

local oldprintreal = print
local oldprint = function(...)
    --writeToConsole(...)
    return forcePrint(...)
end

local function print(...)
    --print(...)
end

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
                goto continue
            end

            -- write to recording thing
            activeRecording.name = activeRecording.name .. chr
            recordingLength = recordingLength + 1 -- yay it actually is a group request


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




function module:apply(patch)
    -- regex for finding the pattern
    local newRe = regex(patch.pattern, "m")


    -- the matchall function does not work as intended and does not return any other capture other than the first capture
    -- that is found, so to replace this we have to continue to iterate until we have reached patch.times or until we cant find another capture.

    local file = faker.RequestDynamicFile(patch.target)
    local captureTimes = patch.times or math.huge---1
    local iter = 0

    if not file then
        return
    end

    -- the content we replace in the pattern, $0 means the first group aka the whole thing
    local root_capture = patch.root_capture or "0"--"$0"
    local offset = 0
    local offset2 = 0

    local history = ""

    while true do
        if iter > captureTimes then
            break
        end

        iter = iter + 1

        -- find the match for the pattern in the script.
        local source = file.getSource()
        local sourceToSearch = string.sub(source, offset, #source)

        local exec = newRe:exec(sourceToSearch)

        -- no more patches left
        if not exec or iter > captureTimes then
            if iter == 1 then
                oldprint("REGEX: NO MATCHES FOUND FOR: " .. patch.pattern .. "       IN    " .. patch.target .. "   !!!!!!!!!")
            end
            break
        end


        -- main span, this is the whole pattern that we found
        local target = exec.get_group(0):extract()

        -- line prepend, just adds stuff before every line
        -- patch.line_prepend and exec.get_group(string.sub(patch.line_prepend, 2)).getValue() or ""
        local prepend = exec.get_group(string.sub(patch.line_prepend or "$indent", 2)).getValue() or ""


        -- find the span of the location we want to replace. if the rootcapture is 0 that means we are straight up editting the pattern we found.
        -- which happens most of the time we use regex, so just use the targetSpan if the RC is 0

        if string.sub(root_capture, 1, 1) == "$" then
            root_capture = string.sub(root_capture, 2)
        end

        local rootGroup = exec.get_group(root_capture):extract()

        if root_capture == "a" then
            print("ROOTCAPTURE IS A:    ")
            print(#prepend)
            print(exec.n)
            --print(string.sub(patch.line_prepend, 2))
            --print(patch.line_prepend, 2)
            print(exec.match:group())
            print(rootGroup.value)
            exploreAndLog("", rootGroup)
        end

        --print(root_capture)
        local replaceSpan = root_capture == "0" and target.span or rootGroup.span --spanOf(target.value, rootGroup.value, prepend, target.span.start) -- dont search the prepend, it can cause inaccurate results.
        if root_capture == "a" then
            print("SPANN: " .. string.sub(sourceToSearch, replaceSpan.start+2, replaceSpan['end']+2))
            print("SPANN: " .. replaceSpan.start .. ", " .. replaceSpan['end'])
            exploreAndLog("", replaceSpan)
        end

        -- now that we have the range to replace all we have to do is set some group indication things (EX: $restcond, $rest, etc..) to their
        -- grouped values.

        local payload = findAndReplaceGroupRequests(patch.payload, patch, exec)
        findAndReplaceGroupRequests(payload)

        --
        if isAlphabeticCharacter(string.sub(payload, 1, 1)) then
            if patch.tagged then
                --forcePrint(patch.tagged .. "1ST TAGGED PATCH " .. payload .. "DETECTED THE FIRST LETTER AS ALPHA NUMERIC")
            end

            --local checkLoc = patch.position == 'after' and target.span['end'] or target.span.start
            local checkLoc = (patch.position == 'after' and replaceSpan['end'] or replaceSpan.start) + offset

            if isAlphabeticCharacter(string.sub(source, checkLoc, checkLoc)) then
                if patch.tagged then
                    --forcePrint(patch.tagged .. "1ST TAGGED PATCH " .. payload .. " OFFSET THE PAYLOAD BY ONE SPACE.")
                    --forcePrint(patch.tagged .. "1ST TAGGED PATCH CHARACTERS " .. string.sub(source, checkLoc, checkLoc) .. " : " .. string.sub(payload, 1, 1))
                end

                payload = ' ' .. payload
            end
        end

        -- NOTE TO SELF: offsetting code change worked really well with smods but is NOT working well with anything else. REVERT OR FIX!!

        if isAlphabeticCharacter(string.sub(payload, #payload, #payload)) then
            if patch.tagged then
                --forcePrint(patch.tagged .. "2ND TAGGED PATCH " .. payload .. "DETECTED THE FIRST LETTER AS ALPHA NUMERIC")
            end

            local checkLoc = (patch.position == 'before' and replaceSpan.start or replaceSpan['end']) + offset

            if isAlphabeticCharacter(string.sub(source, checkLoc, checkLoc)) then
                if patch.tagged then
                    --forcePrint(patch.tagged .. "2ND TAGGED PATCH " .. payload .. "DETECTED THE FIRST LETTER AS ALPHA NUMERIC")
                end
                payload = payload .. ' '
            end
        end

        -- yipe kai yay okay its time to inject it
        local sub1 = 1 --#root_capture --(root_capture == '0' and 1 or #root_capture-exec.n+1)--1 -- -2      --  #root_capture-exec.n)
        local sub2 = 1 --(root_capture == '0' and 1 or #root_capture+exec.n-1)--1 -- +2      --  #root_capture-exec.n)

        -- spagetti code
        if patch.position == 'at' then
            history = history .. 'at '
            payload = payload .. '--[=======[' .. tostring(offset) .. ' ' .. history .. ' ]=======]'

            source = string.sub(source, 1, replaceSpan.start - sub1 + offset - offset2)--2)
                    .. payload
                    .. string.sub(source, replaceSpan['end'] + sub2 + offset - offset2)

            offset = replaceSpan['end'] + sub2 + offset + #payload -- offset2/2 + #payload
            --offset2 = offset2 + 1
            offset2 = 1
            if offset2 > 2 then
                offset2 = 1
            end
            --offset = replaceSpan['end'] + sub2 + offset --+ #payload - (1*iter) -- - 1
        elseif patch.position == 'before' then
            history = history .. 'before '
            payload = payload .. '--[=======[' .. tostring(offset) .. ' ' .. history .. ' ]=======]'

            source = string.sub(source, 1, replaceSpan.start - sub1 + offset)
                    .. payload
                    .. string.sub(source, replaceSpan.start + offset)

            offset = replaceSpan['end'] + offset + #payload + sub1
        elseif patch.position == 'after' then
            history = history .. 'after '
            payload = payload .. '--[=======[' .. tostring(offset) .. ' ' .. history .. ' ]=======]'

            source = string.sub(source, 1, replaceSpan['end'] + offset)
                    .. payload
                    .. string.sub(source, replaceSpan['end'] + 1 + offset)

            offset = replaceSpan['end'] + 1 + offset + #payload + 1 -- - 1
            --offset = offset - 1
        end

        --offset = replaceSpan['end'] + sub2 + offset--replaceSpan['end']

        file.setSource(source)
    end
end


return module
