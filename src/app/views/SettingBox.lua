--  设置弹出界面--
local CURRENT_MODULE_NAME = ...
local dataMgr = import(".DataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()
local musicMgr = import(".MusicManager"):getInstance()

local SettingBox = class("SettingBox", display.newLayer)
function SettingBox:ctor()
    local rootNode = cc.CSLoader:createNode("SetBox.csb"):addTo(self)
    self.rootNode = rootNode
    rootNode:setPosition(display.center)
    layerMgr.LoginScene:addChild(self, 10000)
  
	local btnclose = rootNode:getChildByName("Button_close")
	local node1 = rootNode:getChildByName("Node_1")
	local node2 = rootNode:getChildByName("Node_2")
    local btnMusic = node1:getChildByName("Button_music")
    local imgMusicOn = node1:getChildByName("Image_on")
    local imgMusicOff = node1:getChildByName("Image_off")

    local btnEffect = node2:getChildByName("Button_effect")
    local imgEffectOn = node2:getChildByName("Image_effOn")
    local imgEffectOff = node2:getChildByName("Image_effOff")

	btnMusic:onClicked(
	function()
		musicMgr:playEffect("game_button_click.mp3", false)
		if dataMgr.isMusicOn == true then
			imgMusicOn:setVisible(false)
			imgMusicOff:setVisible(true)
			dataMgr.isMusicOn = false
			musicMgr:stopMusic()
			print("On to Off")
		else
			imgMusicOn:setVisible(true)
			imgMusicOff:setVisible(false)
			dataMgr.isMusicOn = true
    		musicMgr:playMusic("bg.mp3", true)
			print("Off to on")
		end
	end)

	btnEffect:onClicked(
	function()
		musicMgr:playEffect("game_button_click.mp3", false)
		if dataMgr.isEffectOn == true then
			imgEffectOn:setVisible(false)
			imgEffectOff:setVisible(true)
			dataMgr.isEffectOn = false
		else
			imgEffectOn:setVisible(true)
			imgEffectOff:setVisible(false)
			dataMgr.isEffectOn = true
		end
	end)

	btnclose:onClicked(
    function (  )
    	musicMgr:playEffect("game_button_click.mp3", false)
        self:removeSelf()
    end)
end



function SettingBox:init(  )
    
end

function SettingBox.create(  )
    return SettingBox.new()
end
return SettingBox
