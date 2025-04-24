return {
    logo = love.graphics.newImage("EmbeddedModLoader/assets/naneinf.png"),
    settings = love.graphics.newImage("EmbeddedModLoader/assets/settings.png"),
    mods = love.graphics.newImage("EmbeddedModLoader/assets/extension.png"),

    files = love.graphics.newImage("EmbeddedModLoader/assets/folder.png"),
    folder_open = love.graphics.newImage("EmbeddedModLoader/assets/folder_open.png"),

    load = love.graphics.newImage("EmbeddedModLoader/assets/play.png"),
    loading = love.graphics.newImage("EmbeddedModLoader/assets/loading_trail.png"),

    delete = love.graphics.newImage("EmbeddedModLoader/assets/delete.png"),
    copy = love.graphics.newImage("EmbeddedModLoader/assets/copy.png"),
    newFile = love.graphics.newImage("EmbeddedModLoader/assets/newfile.png"),

    close = love.graphics.newImage("EmbeddedModLoader/assets/close.png"),


    -- // AUDIO // --

    menuTheme = 'EmbeddedModLoader/assets/themes.flac', --love.audio.newSource("EmbeddedModLoader/assets/themes.mp4", 'static') caused memory leak
    buttonClick = 'EmbeddedModLoader/assets/button_click.ogg'

}