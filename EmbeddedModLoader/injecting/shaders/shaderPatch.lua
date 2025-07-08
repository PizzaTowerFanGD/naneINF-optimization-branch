local numbers = {
    ["0"] = true,
    ["1"] = true,
    ["2"] = true,
    ["3"] = true,
    ["4"] = true,
    ["5"] = true,
    ["6"] = true,
    ["7"] = true,
    ["8"] = true,
    ["9"] = true,
    ["."] = true,
}

local operators = {
    ["*"] = true,
    ["/"] = true,
    ["-"] = true,
    ["+"] = true,
    ["<"] = true,
    [">"] = true,
    ["="] = true,
    [" "] = true,
    ["("] = true,
    [")"] = true,
}

local module = {}


function module.convert(name)
    -- added for testing
    local CFG_IntVarToNumber = true



    local file = love.filesystem.read(name)
    local newFile = ""

    local recordingNum = false
    local isFloat = false
    local lock = false

    for c = 1, #file do
        local chr = string.sub(file, c, c)
        local lastChr
        local nextChr = c == #file and nil or string.sub(file, c + 1, c + 1)

        if (c == 1) then
            lastChr = nil
        else
            lastChr = string.sub(file, c-1, c-1)
        end


        newFile = newFile .. chr

        if lock then
            if operators[chr] then
                lock = false
            else
                recordingNum = false
                goto continue
            end
        end

        --[[print('---------')
        print(chr)
        print(lastChr)
        print(c)]]

        if not recordingNum then
            if lastChr and numbers[chr] and not numbers[lastChr] and not operators[lastChr] then
                lock = true

                --[[print("LOCK   " ..
                        tostring(lastChr ~= nil) ..
                        tostring(not numbers[lastChr]) ..
                        tostring(not operators[lastChr])
                )]]

                goto continue
            end


            if numbers[chr] then
                recordingNum = true
            end
        end

        if recordingNum then
            if chr == "." then
                isFloat = true
            end

            if (nextChr == " " or nextChr == "\t" or nextChr == "\n" or nextChr == nil) and not isFloat then
                newFile = newFile .. "."
                isFloat = true
            end

            if not numbers[chr] then
                recordingNum = false
                isFloat = false
            end
        end

        ::continue::
    end

    if CFG_IntVarToNumber then
        -- elegant code btw
        newFile = string.gsub(newFile, " int ", " number ")
        newFile = string.gsub(newFile, "int ", "number ")
    end

    newFile = string.gsub(newFile, "__VERSION__ > 100.", "__VERSION__ > 100")

    -- TODO: make this load from a cached version rather than overwriting the actual file
    print(name)
    love.filesystem.write(name, newFile)
end


return module