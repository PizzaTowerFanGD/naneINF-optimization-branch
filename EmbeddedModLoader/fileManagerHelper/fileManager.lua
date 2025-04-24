local methods = {}

-- 3xpl here





-- tell it what method to use
function methods.exploreFolder(path, method, dontIncludePath)
    local contents = {}

    if not method then
        print("Could not explore " .. path .. ", No method was ever provided (L, I).")
        print("Method L: love.filesystem")
        print("Method I: io...")
        print([[Research the documentation of the diferences between the two if you are a mod creator and you are unaware
        Of the difference between both systems.]])
        return contents -- say no contents were found
    end

    -- im really not sure why, but this method is working despite the fact that it gets called before
    -- any love methods (especially love.run AND love.load) even run, we should be getting an error here for using love.filesystem early right??

    -- love.filesysten
    if method == 'L' then
        local dirItems = love.filesystem.getDirectoryItems(path)

        for i, fileName in pairs(dirItems) do
            local filePath = (not dontIncludePath and path .. "/" or "") .. fileName
            --print(filePath)

            table.insert(contents, filePath)
        end
    end


    return contents
end


-- i know you love my method names

function methods.exploreFolderWithNameAndPath(path)
    forcePrint("Called exploreFolderWithNameAndPath " .. tostring(path))

    local contents = {}

    --[[ legacy when i thought we were ever gonna use io (we dont besides for writing to the console)
    if not method then
        print("Could not explore " .. path .. ", No method was ever provided (L, I).")
        print("Method L: love.filesystem")
        print("Method I: io...")
        print([[Research the documentation of the diferences between the two if you are a mod creator and you are unaware
        Of the difference between both systems.] ])
        return contents -- say no contents were found
    end]]



    local dirItems = love.filesystem.getDirectoryItems(path)

    for i, fileName in pairs(dirItems) do
        local filePath = path .. "/" .. fileName
        --print(filePath)

        table.insert(contents, {
            path = filePath,
            name = fileName,
            info = methods.getFileInfo(filePath),
        })
    end


    return contents
end


function methods.getFileInfo(path)
    --if method == "L" then
    return love.filesystem.getInfo(path)
    --end

    --print("Incorrect or missing method given to the getFileInfo")
    --return nil
end

function methods.read(path, method)
    if method == "L" then
        return love.filesystem.read(path)

    elseif method == "I" then
        return io.open(path, "r")
    end

end


return methods