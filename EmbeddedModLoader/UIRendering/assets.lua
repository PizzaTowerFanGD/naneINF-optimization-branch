local loaded = {}

local function requestImage(dir)
    if not loaded[dir] then
        loaded[dir] = love.graphics.newImage(dir)
    end

    return loaded[dir]
end



return {
    logo = requestImage("EmbeddedModLoader/assets/naneinf.png"),
    settings = requestImage("EmbeddedModLoader/assets/settings.png"),
    mods = requestImage("EmbeddedModLoader/assets/extension.png"),

    files = requestImage("EmbeddedModLoader/assets/folder.png"),
    folder_open = requestImage("EmbeddedModLoader/assets/folder_open.png"),

    load = requestImage("EmbeddedModLoader/assets/play.png"),
    loading = requestImage("EmbeddedModLoader/assets/loading_trail.png"),

    delete = requestImage("EmbeddedModLoader/assets/delete.png"),
    copy = requestImage("EmbeddedModLoader/assets/copy.png"),
    newFile = requestImage("EmbeddedModLoader/assets/newfile.png"),

    close = requestImage("EmbeddedModLoader/assets/close.png"),

    on = requestImage("EmbeddedModLoader/assets/on.png"),
    off = requestImage("EmbeddedModLoader/assets/off.png"),

    arrowDown = requestImage("EmbeddedModLoader/assets/arrowDown.png"),
    arrowUp = requestImage("EmbeddedModLoader/assets/arrowUp.png"),


    -- // FILE SYSTEM ICONS // --

    directory = requestImage("EmbeddedModLoader/assets/folder.png"),
    symlink = requestImage("EmbeddedModLoader/assets/link.png"), -- shortcut???

    file = requestImage("EmbeddedModLoader/assets/file.png"),

    png = requestImage("EmbeddedModLoader/assets/image.png"),
    jpg = requestImage("EmbeddedModLoader/assets/image.png"),
    jpeg = requestImage("EmbeddedModLoader/assets/image.png"),
    webp = requestImage("EmbeddedModLoader/assets/image.png"),
    svg = requestImage("EmbeddedModLoader/assets/image.png"),
    gif = requestImage("EmbeddedModLoader/assets/image.png"),
    tiff = requestImage("EmbeddedModLoader/assets/image.png"),
    heif = requestImage("EmbeddedModLoader/assets/image.png"),
    bmp = requestImage("EmbeddedModLoader/assets/image.png"),

    json = requestImage("EmbeddedModLoader/assets/json.png"),
    tsv = requestImage("EmbeddedModLoader/assets/tsv.png"),

    mp3 = requestImage("EmbeddedModLoader/assets/audio.png"),
    ogg = requestImage("EmbeddedModLoader/assets/audio.png"),
    m4a = requestImage("EmbeddedModLoader/assets/audio.png"),
    flac = requestImage("EmbeddedModLoader/assets/audio.png"),
    wav = requestImage("EmbeddedModLoader/assets/audio.png"),
    alac = requestImage("EmbeddedModLoader/assets/audio.png"),
    aiff = requestImage("EmbeddedModLoader/assets/audio.png"),

    zip = requestImage("EmbeddedModLoader/assets/zip.png"),
    rar = requestImage("EmbeddedModLoader/assets/zip.png"),
    ['7z'] = requestImage("EmbeddedModLoader/assets/zip.png"),

    conf = requestImage("EmbeddedModLoader/assets/settings.png"),
    settings = requestImage("EmbeddedModLoader/assets/settings.png"),
    cfg = requestImage("EmbeddedModLoader/assets/settings.png"),
    config = requestImage("EmbeddedModLoader/assets/settings.png"),
    configuration = requestImage("EmbeddedModLoader/assets/settings.png"),

    md = requestImage("EmbeddedModLoader/assets/markdown.png"),

    ttf = requestImage("EmbeddedModLoader/assets/font.png"),
    otf = requestImage("EmbeddedModLoader/assets/font.png"),

    key = requestImage("EmbeddedModLoader/assets/key.png"),

    lua = requestImage("EmbeddedModLoader/assets/lua.png"),
    instructions = requestImage("EmbeddedModLoader/assets/book.png"),

    -- im like 100% sure these will NEVER be in somebodies folder, but i decided to add it for functionality
    js = requestImage("EmbeddedModLoader/assets/javascript.png"),
    html = requestImage("EmbeddedModLoader/assets/html.png"),
    htm = requestImage("EmbeddedModLoader/assets/html.png"),
    php = requestImage("EmbeddedModLoader/assets/php.png"),
    pdf = requestImage("EmbeddedModLoader/assets/php.png"),
    css = requestImage("EmbeddedModLoader/assets/css.png"),



    -- // AUDIO // --

    -- MENU SONGS

    menuTheme = 'EmbeddedModLoader/assets/Theme.ogg', --love.audio.newSource("EmbeddedModLoader/assets/themes.mp4", 'static') caused memory leak
    filesTheme = 'EmbeddedModLoader/assets/Files.ogg', --love.audio.newSource("EmbeddedModLoader/assets/themes.mp4", 'static') caused memory leak
    settingsTheme = 'EmbeddedModLoader/assets/Settings.ogg', --love.audio.newSource("EmbeddedModLoader/assets/themes.mp4", 'static') caused memory leak
    modsTheme = 'EmbeddedModLoader/assets/Mods.ogg', --love.audio.newSource("EmbeddedModLoader/assets/themes.mp4", 'static') caused memory leak
    loadingTheme = 'EmbeddedModLoader/assets/Load.ogg', --love.audio.newSource("EmbeddedModLoader/assets/themes.mp4", 'static') caused memory leak


    -- USER INTERFACE

    buttonClick = 'EmbeddedModLoader/assets/button_click.ogg',
    success = 'EmbeddedModLoader/assets/success.ogg',

    hover = 'EmbeddedModLoader/assets/hover.ogg',
    secret = 'EmbeddedModLoader/assets/secret.ogg',

    open_sound = 'EmbeddedModLoader/assets/open menu.ogg',
    close_sound = 'EmbeddedModLoader/assets/close menu.ogg',

    toggle = 'EmbeddedModLoader/assets/uiSwitch.ogg',

}