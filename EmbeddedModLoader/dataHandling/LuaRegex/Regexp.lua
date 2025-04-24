

local RegEx = require("EmbeddedModLoader/dataHandling/LuaRegex/RegEx/init")

--LuaRegex.RegEx.init()

local RegExp = {}
local RegExpMetatable = {
    __index = RegExp,
    __tostring = function(self)
        --[[if not self then
            --print(self._innerRegEx)
        end]]
        return tostring(self._innerRegEx)
    end,
}

local function stringSplit(str, split)
    local list = {}
    local c = ""

    --print(str)

    for i = 1, #str do
        local chr = string.sub(str, i, i)
        if chr == split then
            table.insert(list, c)
            table.insert(list, split)
            c = ""
        end

        c = c .. split
    end
end

local function tableFind(haystack, needle)
    for i, v in pairs(haystack) do
        if v == needle then
            return i
        end
    end
end



local function correctSpan(index1, index2, pattern, contents)
    if contents:sub(index1, index2) == pattern then
        return index1, index2
    end

    -- ok searcg

    local patternLength = #pattern
    local searchRange = #contents - #pattern


    --return string.find(contents, pattern)

    for i = 1, searchRange do
        local search = string.sub(contents, i, i + patternLength - 1)


        if search == pattern then
            -- SPAN FIX JMP
            --print("correctSpanFound!!")
            return i, i + patternLength - 1  -- i, i + patternLength
        end
    end
end



function RegExp:exec(str, numFber)
    ----print("EXEC 1")
    local match = self._innerRegEx:match(str, number) -- NUMBER IS OPTIONAL. match(str, number)
    --print("MATCH CALLED")
    --print(match)
    if not match then
        return nil
    end

    ----print("EXEC 2")

    local index1, index2 = match:span() ----print("EXEC 3")
    local groups = match:grouparr() ----print("EXEC 4")

    index1, index2 = correctSpan(index1, index2, match:group(), str)
    --print(str:sub(index1, index2))

    ----print(groups)
    --[[for i, v in pairs(groups) do
        --print(v)
    end]]

    -- NOTE TO ME TOMMOROW
    -- the issue lies in the spans, they're USUALLY slightly offset either a couple ahead or behind the actual group.
    -- im sure we remember the issue, but the plan is to redefine the span by searching for the group manually (string.find doesnt exist in regular lua), and then getting the
    -- index of the starting and ending character found in the string. which will fix our issue.
    -- i do have concerns about repeatting patterns and time efficency, but i believe we will be okay. try and remember why im not worried about it, im sure you got this buddy
    -- im gonna go back to watching severance, but good morning or afternoon 3xpl depending on if you work on this in school!!!

    -- also we have decided that if porting doesnt work out that it would be super easy to just write the lovely script on our own.
    -- so try and remember why we thought that, i seriuously wanna go back to watching

    -- thanks
    -- 		3XPL 11:53 PM 2/25/2025

    -- another note, we can check if this process is necessary by substringing it first with the original span and comparing it to group 0
    -- if the strings match then we know if we need to do anything or not.

    local matches = { groups[1] }
    for i = 1, groups.n do
        matches[i + 1] = groups[i]
    end

    local cachedSpans = {}

    matches.n = groups.n + 1
    matches.index = index
    matches.input = str
    matches.groups = groups
    matches.re = self._innerRegEx
    matches.match = match

    match.get_group_index_by_name = function(name)
        return tableFind(match:grouparr(), match:groupdict()[name])
    end

    matches.get_group_by_name = function(name)
        return matches.get_group(tableFind(match:grouparr(), match:groupdict()[name]))--match:groupdict()[name]
    end

    matches.get_group = function(index)
        local methods = {}
        local gId = tonumber(index)

        --print(index)
        --print("get_group: " .. groups[gId])

        if type(index) == 'string' and not tonumber(index) then
            return matches.get_group_by_name(index)
        end

        function methods.span()
            local start, end_ = match:span(gId)--stringSplit(match:span(gId), "")

            --print(gId)
            if gId == nil then
                print("this is super cool but weird, idk why GID is nil LOL ok uur gonna go to default as 0 lil kid lmao")
                gId = 0
            end

            local start, end_ = correctSpan(start, end_, groups[gId], str)
            --[[if string.sub(str, 1, 1) == " " and not match:groupdict()['indent'] then
                start = start + 1
                end_ = end_ + 1
            end]]

            return {
                start = start,
                ['end'] = end_
            }
        end

        function methods.getValue()
            return groups[gId]
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


    return matches
end

function RegExp:test(str)
    return self:exec(str) ~= nil
end

local function new(_self, pattern, flags)
    flags = flags or ""
    local innerRegEx = RegEx.new(pattern, flags)
    local object = {
        source = pattern,
        ignoreCase = (flags):find("i") ~= nil,
        global = (flags):find("g") ~= nil,
        multiline = (flags):find("m") ~= nil,
        _innerRegEx = innerRegEx
    }

    return setmetatable(object, RegExpMetatable)
end

-- FIXME: Capture this as a local variable before returning, else a luau bug
-- prevents __call from being understood: https://jira.rbx.com/browse/CLI-40294
local interface = setmetatable(RegExp, {
    __call = new,
})

return interface
