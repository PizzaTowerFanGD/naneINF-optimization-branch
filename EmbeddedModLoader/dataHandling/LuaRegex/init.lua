local Regex = {}
local RegModule = require("EmbeddedModLoader/dataHandling/LuaRegex/RegEx/init")

local function tableFind(haystack, needle)
    for i, v in pairs(haystack) do
        if v == needle then
            return i
        end
    end
end

function Regex.new(patternStr, flags, source)

    print("NEWREGEX: ", patternStr, flags)

    local pattern = RegModule.new(patternStr, flags)

    local matchesFound = {}
    local allMatches = pattern:matchall(source)

    -- because of how matchall works, it doesnt actually tell you the length of the match, all you can do is call a function
    -- to get the next match until you run into nil

    while (true) do
        local match = {}
        local nextMatch = allMatches()
        --print(nextMatch)

        -- no more matches left
        if not nextMatch then
            break
        end

        local groupsArr = nextMatch:grouparr()

        match.n = groupsArr.n
        match.index = nil
        match.input = source
        match.groups = groupsArr
        match.re = pattern
        match.match = nextMatch

        -- i dont believe this is ever used.
        match.get_group_index_by_name = function(name)
            return tableFind(match.match:grouparr(), match.match:groupdict()[name])
        end

        match.get_group_by_name = function(name)
            return match.get_group(tableFind(match.match:grouparr(), match.match:groupdict()[name]))--match:groupdict()[name]
        end

        match.get_group = function(index)
            local methods = {}
            local gId = tonumber(index)

            --print(index)
            --print("get_group: " .. groudps[gId])

            if type(index) == 'string' and not tonumber(index) then
                return match.get_group_by_name(index)
            end

            function methods.span()
                -- fix for regex, turns out weve been needing to use utf8 this whole time to get the actual spans
                -- but ive just been using sub on its own :broken:

                --[[local function utf8_sub(self, i, j)
                    j = utf8.offset(self, j);
                    return string.sub(self, utf8.offset(self, i), j and j - 1);
                end]]

                local start, end_ = match.match:span(gId)--stringSplit(match:span(gId), "")
                local j = utf8.offset(source, end_)

                return {
                    start = start,
                    ['end'] = end_,

                    start_ = utf8.offset(source, start),
                    end_ = j--(j and j - 1)
                }
            end

            function methods.getValue()
                return groupsArr[gId]
            end


            -- gets all the info we need
            function methods:extract()
                return {
                    value = self.getValue(),
                    span = self.span()
                }
            end


            function methods.unwrap_or(num)
                --[[local split = string.split(match:span(gId), "")

                return {
                    start = tonumber(split[1]),
                    ['end'] = tonumber(split[3])
                }]]
            end

            return methods
        end

        table.insert(matchesFound, match)
    end


    -- reverse the sorting to greatest to least so we can just inject from the findings

    local reversedFound = {}

    for i = 1, #matchesFound do
        reversedFound[#matchesFound - i + 1] = matchesFound[i]
    end

    return reversedFound
end



return Regex