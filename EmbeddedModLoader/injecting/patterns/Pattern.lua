local methods = {}

-- // PATTERNS PATCHING SCRIPT V2



-- exclsuvbe split

local shouldTrim = {
    ['\t'] = 1,
    [' '] = 2,
}


-- thank you luaJIT for STILL not having a string.split function

local function print(...)
    return forcePrint(...)
end

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

--forcePrint(split("ab cd ef g  h   ijklmn  op", " "))


local function linesTrimmed(patch, keepTabs)
    local lines = split(patch, '\n')

    local linesWithData = {}


    -- trim the left entirely

    for i, lineStr in ipairs(lines) do
        local newLineString = lineStr
        local indentCount = 0
        local whitespace = ""


        -- trim left
        if not keepTabs then
            for i = 1, #newLineString do
                if not shouldTrim[string.sub(newLineString, 1, 1)] then
                    --print('stop cutting off at ' .. i)
                    break
                end

                indentCount = indentCount + 1
                whitespace = whitespace .. string.sub(newLineString, 1, 1)
                newLineString = string.sub(newLineString, 2)
            end


            -- trim right side (fixes issues with matches missing because of random spaces)
            for i = 1, #newLineString do
                if not shouldTrim[string.sub(newLineString, #newLineString, #newLineString)] then
                    break
                end

                --indentCount = indentCount + 1
                newLineString = string.sub(newLineString, 1, #newLineString - 1)
            end
        end


        -- offset, indentCount
        linesWithData[i] = {indentCount, newLineString, whitespace}
    end


    -- clear potential accidental empty line.
    if linesWithData[#linesWithData][1] == 0 and linesWithData[#linesWithData][2] == "" then
        linesWithData[#linesWithData] = nil
    end


    return linesWithData
end


-- debug log config
local logIfPercentageFound = 0.5


-- i would just normally do ==, but wildcards make this necessary.
local function compareStrings(pattern, line, hasTag)
    --print(pattern, line)

    -- optimization
    local patternLength = #pattern

    if pattern == '' then return true end
    if patternLength ~= #line and string.sub(pattern, patternLength, patternLength) ~= '*' then
        -- no chance to match.
        if hasTag then
            forcePrint("-----------------------------\n[LUAVELY]: PATTERN TAG DBG, PATTERN: " .. pattern .. " :: WITH TAG " .. hasTag .. ":: HAS NO CHANCE TO MATCH.\n" ..
                    "LENGTH OF PATTERN: " .. patternLength .. "   LENGTH OF LINE: " .. #line .. "\n\n")
        end

        return false
    end


    -- check each char in the lines and see if they match (wildcards :D)
    for i = 1, patternLength do
        local patternChr = string.sub(pattern, i, i)

        -- initiating a wildcard, must be a match.
        if patternChr == "?" then goto compareContinue end
        if patternChr == "*" and i == patternLength then
            return true
        end


        --actual checking
        local lineChr = string.sub(line, i, i)

        if patternChr ~= lineChr then
            if hasTag and i/patternLength >= logIfPercentageFound then
                forcePrint("-----------------------------\n" ..
                        "[LUAVELY]: PATTERN TAG DBG, LETTER MISMATCH ON: " .. pattern .. " :: WITH TAG " .. hasTag .. ":: ON INDEX " .. i .. "/" .. patternLength .. "\n"
                .. "FOUND: " .. lineChr .. ",    LOOKING FOR: " .. patternChr .. "\n\n"
                )
            end

            return false
        end

        ::compareContinue::
    end

    -- successfully matched?
    -- TODO investigate posibility to move so it can be a heavy optimization

    return patternLength == #line--true
end




-- patterns.match will only match the whole line that it searches,
-- originally i checked EVERY SINGLE CHARACTER, but thankfully we dont need to do that anymore yipe!!!


local function match(lines, times, patternLines)
    local currentLine = 1
    local matches = {}

    -- start searching
    for i, line in ipairs(lines) do
        --print(currentLine)
        --print(patternLines)
        local patternLine = patternLines[currentLine][2]

        -- just assume these are a match and continue
        if patternLine == '' then
            currentLine = currentLine + 1
            goto matchingContinue
        end

        -- was not a match with wildcard or regular :(
        if not compareStrings(patternLine, line[2]) then
            --print('fail')
            currentLine = 1
            goto matchingContinue
        end

        --print('success')

        -- match found
        if currentLine >= #patternLines then
            table.insert(matches, {
                start = i - (currentLine-1),
                ['end'] = i
            })

            currentLine = 1
        else

            currentLine = currentLine + 1
        end

        ::matchingContinue::
    end

    -- warns
    local truncatedMatches = {}

    if #matches > (times or 1) then --(times or math.huge)
        forcePrint('[LuaVELY]: Matches exceeds the set times limit, All Extra matches have been truncated in order from greatest -> least (truncated greatest first.')

        for i, v in ipairs(matches) do
            if i > times then
                break
            end

            truncatedMatches[i] = v
        end
    else
        truncatedMatches = matches
    end

    -- to avoid issues with offsets when injecting, we flip this array backwards (it is already sorted)
    local length = #truncatedMatches
    local flippedMatches = {}

    for i = 1, length do
        flippedMatches[length - i + 1] = truncatedMatches[i]
    end

    --[[table.sort(truncatedMatches, function(a, b)
        return a['end'] > b['end']
    end)]]


    return flippedMatches
end





function methods:apply(target, patch)
    -- // important

    local file = faker.RequestDynamicFile(target)
    if not file then forcePrint("No file target found.") return end


    local lines = linesTrimmed(file.getSource())
    local linesOriginal = linesTrimmed(file.getSource(), true)
    local patternDeconst = linesTrimmed(patch.pattern)

    -- // patch info

    local pattern = patch.pattern
    local payload = patch.payload
    local position = patch.position -- position to inject the new stuff at
    local times = patch.times or math.huge--1

    -- this genuinely doesnt even seem to do anything!!!
    local match_indent = patch.match_indent


    -- start searching
    local matches = match(lines, times, patternDeconst, patch.tag)

    --print(matches)

    -- // Warns

    -- improving professionality :broken_heart:
    if #matches == 0 then
        forcePrint("[LuaVELY]: No Matches Found For: \"\"\"" .. pattern .. "\"\"\"  in Source: " .. tostring(target) .. ".")
        return
    end

    -- seperate lines for the patch and start injecting the lines.
    local payloadLines = linesTrimmed(payload, true)
    local payloadLinesRev = {}

    if payloadLines[#payloadLines] ~= '' then
        --table.insert(payloadLines, {-1, ''})
    end

    -- required because we insert by shifting and if we dont rev then our patch will be in the very wrong order
    for i, v in ipairs(payloadLines) do
        payloadLinesRev[#payloadLines - i + 1] = v
    end

    -- restore to a version with all of the spaces and tabs back alive
    --lines = linesOriginal

    for _, match in ipairs(matches) do
        local start = match.start
        local ending = match['end']

        -- add the tabs back

        if position == 'at' then
            local whitespacePrepend = lines[start][3] -- string.sub(linesOriginal[start][2], 1, lines[start][1])

            -- clear old lines and insert at the starting location
            local clearLines = (match['end'] - match.start) + 1

            for _ = 1, clearLines do
                table.remove(linesOriginal, start)
            end

            for _, v in ipairs(payloadLinesRev) do
                v[2] = whitespacePrepend .. v[2]
                table.insert(linesOriginal, start, v)
            end

        elseif position == 'before' then
            local whitespacePrepend = lines[start][3] -- string.sub(linesOriginal[start][2], 1, lines[start][1])

            -- inserts at the index of start (before everything fr fr)
            for _, v in ipairs(payloadLinesRev) do
                v[2] = whitespacePrepend .. v[2]
                table.insert(linesOriginal, start, v)
            end

        elseif position == 'after' then
            local whitespacePrepend = lines[start][3] -- string.sub(linesOriginal[start][2], 1, lines[start][1])

            for _, v in ipairs(payloadLinesRev) do
                v[2] = whitespacePrepend .. v[2]
                table.insert(linesOriginal, ending + 1, v)
            end
        end

    end

    -- apply script changes!!!
    local source = ""

    for i, v in ipairs(linesOriginal) do
        source = source .. v[2]

        if i ~= #linesOriginal then
            source = source .. "\n"
        end
    end

    file.setSource(source)
end



return methods
