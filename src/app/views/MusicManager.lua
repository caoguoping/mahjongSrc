local CURRENT_MODULE_NAME = ...



local s_inst = nil
local MusicManager = class("MusicManager")

function MusicManager:getInstance()
    if nil == s_inst then
        s_inst = MusicManager.new()
        s_inst:init()
    end
    return s_inst
end

function MusicManager:init()

    self.isMusicOn = true
    self.isEffectOn = true

end

function MusicManager:playMusic(fileName , loop)
    if self.isMusicOn then
        cc.SimpleAudioEngine:getInstance():playMusic(fileName, loop)
    end
end

function MusicManager:playEffect(fileName, loop)

    if self.isEffectOn then
         cc.SimpleAudioEngine:getInstance():playEffect(fileName, loop)
    end

end

--1,男，  2，女
function MusicManager:playCardValueEffect( sex,  young, cardValue)
    print("sex "..sex.."  young "..young.."  cardCalue "..cardValue)
    print("soundCnt into ")
    if sex == 0 then
        sex = 2
    end
    local maxNum = soundCnt[sex][young][cardValue]
    local randNum = math.random(maxNum)
    local strSoundName
    if sex == 1 then
        strSoundName = "nan_" 
    elseif sex == 2 then
        strSoundName = "nv_" 
    end
    strSoundName = strSoundName..cardValue.."_"..young.."_"..randNum..".mp3"
    print("strSoundName")
    print(strSoundName)
    self:playEffect(strSoundName, false)
 end

function MusicManager:stopMusic( )
    if self.isMusicOn then
         cc.SimpleAudioEngine:getInstance():stopMusic(true)
    end
end

function MusicManager:halfMusicVolume()
    local engine = cc.SimpleAudioEngine:getInstance()
    engine:setMusicVolume(0.2)
    print("Music half"..engine:getMusicVolume())
end

function MusicManager:FullMusicVolume()
    local engine = cc.SimpleAudioEngine:getInstance()
    engine:setMusicVolume(1.0)
    print("Music half"..engine:getMusicVolume())
end

return MusicManager
