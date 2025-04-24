local track = 0 -- specifies which location the song should play at
local module = {}


-- i am extremely aware that this method for the audio switching isnt good but it will work just fine unless you are on a device from like 2008 and in that case im surprised you can even install and run abalatro
-- also this is necessary because malleo never told me the time stamps between each song :broken:

local currentlyAudible = 1
local songs = {
    love.audio.newSource(assets.menuTheme, 'static'),
    love.audio.newSource(assets.settingsTheme, 'static'),
    love.audio.newSource(assets.filesTheme, 'static'),
    love.audio.newSource(assets.modsTheme, 'static'),
    love.audio.newSource(assets.loadingTheme, 'static'),
}


for i, v in ipairs(songs) do
    v:setVolume(0)
    v:play()
end
songs[currentlyAudible]:setVolume(0.65)

-- used in loading
_G.malleoMusicOmg = songs

-- what are these time position function names bro

function module.check()
    -- note to self: tell is the song length
    if songs[currentlyAudible]:tell() >= songs[currentlyAudible]:getDuration() then
        for i, v in ipairs(songs) do
            v:stop()
            v:seek(0)
            v:play()
        end
    end
end

--[[local function clamp(num, min, max)
    if num < min then
        return min
    elseif num > max then
        return max
    else
        return num
    end
end]]

-- seamlessly transitions between the tracks
function module.updateSong(newTrack)
    songs[currentlyAudible]:setVolume(0)
    songs[newTrack]:setVolume(0.65)

    currentlyAudible = newTrack
end


return module