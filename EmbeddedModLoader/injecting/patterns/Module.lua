--local faker = require("EmbeddedModLoader/files/fakeLuaFile")

local method = {}

-- this doesnt actually insert, we just add a path to fake require to emulate the system for dlls and modules being added.

function method:apply(patch, file)
    -- set redirect
    print( patch.__PATH)
    --local tomlPath = patch.__PATH

    print(patch.source)
    print(patch.name)

    patch.source = string.gsub(patch.source, ".lua", "") -- remove '.lua' extension.

    -- redirect to the editted nativefs version i made for mobile compat
    if patch.source == 'libs/nativefs/nativefs' then
        print(patch.source)
        print("^^^^^^^^ LAALAALALALALLAA")
        patch.source = 'EmbeddedModLoader/libraryOverwrite/nativefs/nativefs'
    else
        patch.source = patch.__PATH .. "/" .. patch.source --'mods/smods/' .. patch.source
    end

    --fakeRequireMethods.modulePaths[patch.name] = patch.source

    return {
        cmd = "moduleEMU",
        data = {patch.name, patch.source}
    }
end




return method