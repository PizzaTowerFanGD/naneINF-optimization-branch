--local faker = require("EmbeddedModLoader/files/fakeLuaFile")

local method = {}

-- literally all this does is append or prepend to the file.
function method:apply(target, patch, file)
    if target == 'main.lua' then
        target = 'originalmain.lua'
    end

    local ogTarget = target
    local file = file or faker.RequestDynamicFile(target)
    local contents = file.getSource()

    for _, target in pairs(patch.sources) do
        target = (patch.__PATH or "Mods/smods/") .. target


        forcePrint("COPY PATCH FUNCTION RUNNED YIPE!! " .. ogTarget .. " : " .. target, "PATCHING")

        -- overwrite main.lua to go to originalmain so we dont overwrite the actual loader

        if patch.position == 'append' then
            contents = contents .. '\n' .. faker.RequestDynamicFile(target).getSource()
        elseif patch.position == 'prepend' then
            contents = faker.RequestDynamicFile(target).getSource() .. '\n' .. contents
        end
    end

    -- i dont believe there are any more types here

    file.setSource(contents)
end




return method