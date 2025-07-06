local methods = {}
local json = require("EmbeddedModLoader/libraries/json/json")

function methods.search(directory, modsFolder)
    for name, _ in pairs(modsFolder) do
        if not string.find(name, ".json") then
            goto continue
        end

        local data = json.decode(love.filesystem.read(directory .. "/" .. name))
        if not (data.dependencies or data.conflicts) then
            goto continue
        end

        if data.dependencies then
            data.dependencies = {}
        end

        if data.conflicts then
            data.conflicts = {}
        end


        love.filesystem.write(directory .. "/" .. name, json.encode(data))

        :: continue ::
    end
end









return methods