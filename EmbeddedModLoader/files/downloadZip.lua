local module = {}

-- can zip and unzip files!!!
local inflate = require("EmbeddedModLoader/libraries/lua-inflate/inflate")
--local http = require("EmbeddedModLoader/libraries/https/https") -- require("https") works in love2d 12.0 (we are on 11.5) PLANNED

-- note to self
-- https://love2d.org/wiki/lua-https

function module.download(url, path)
    --[[for i, v in pairs(http) do
        forcePrint(i)
    end]]

    local downloadUrl = url --or "https://github.com/MathIsFun0/Cryptid/archive/refs/heads/main.zip"

    if not downloadUrl then
        return {
            Error = true,
            Message = 'No Download URL provided!!!'
        }
    end

    print('has url!! url: ' .. url)

    local status, archiveContents, headers = http.request(downloadUrl, {
        method = 'GET'
    })

    --[[{
    --        method = 'GET',
    --    })]]

    print('get request, status ' .. tostring(status))

    -- error code
    if not archiveContents or status ~= 200 then
        -- TODO: prompt the user that we had an error.
        print("errored :(")

        return {
            Error = true,
            Message = 'Error code: ' .. status
        }
    end

    print("Downloaded the archive from " .. url .. "!")
    print("Extracting to /mods...")

    local stream = inflate.new(archiveContents)
    local fileName

    for name, offset, size, packed, crc in stream:files() do
        -- You can identify sub directories by checking if it's name ends with "/"
        if name:sub(-1) == '/' then
            fileName = name
            love.filesystem.createDirectory(path .. name)
        else
            local content
            if packed then
                -- perform checksum verification
                content = stream:inflate(offset, crc)
            else
                content = stream:extract(offset, size)
            end
            love.filesystem.write(path .. name, content)
        end
    end
    print('Done.')

    local song = love.audio.newSource(assets.success, 'static')
    song:setVolume(0.65)
    song:play()

    return {
        Error = false,
        Message = 'Successfully Downloaded and Imported!!!'
    }, fileName
end

return module