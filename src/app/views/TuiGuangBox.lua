--  创建房间弹出界面--
local CURRENT_MODULE_NAME = ...
local dataMgr = import(".DataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()
local musicMgr = import(".MusicManager"):getInstance()

local TuiGuangBox = class("TuiGuangBox", display.newLayer)
function TuiGuangBox:ctor()
    local rootNode = cc.CSLoader:createNode("TuiGuangBox.csb"):addTo(self)
    self.rootNode = rootNode
    rootNode:setPosition(display.center)
    layerMgr.LoginScene:addChild(self, 10000)
  
    --流水按钮、总分按钮、规则按钮、分享按钮、关闭按钮
	local btnclose = rootNode:getChildByName("Button_close")
    local btn1 = rootNode:getChildByName("Node_1"):getChildByName("Button_1")
    local btn2 = rootNode:getChildByName("Node_2"):getChildByName("Button_2")
    local btn_bangding = rootNode:getChildByName("Node_3"):getChildByName("Button_8")
    local TextField_1 = rootNode:getChildByName("Node_3"):getChildByName("TextField_1")

	rootNode:getChildByName("Node_1"):getChildByName("Image_1"):setVisible(true)
	rootNode:getChildByName("Node_1"):getChildByName("Image_2"):setVisible(false)
	rootNode:getChildByName("Node_2"):getChildByName("Image_1"):setVisible(false)
	rootNode:getChildByName("Node_2"):getChildByName("Image_2"):setVisible(true)

	rootNode:getChildByName("Node_3"):setVisible(true)
	rootNode:getChildByName("Node_4"):setVisible(false)

		btn1:onClicked(
		function()
			musicMgr:playEffect("game_button_click.mp3", false)
		rootNode:getChildByName("Node_1"):getChildByName("Image_1"):setVisible(true)
		rootNode:getChildByName("Node_1"):getChildByName("Image_2"):setVisible(false)
		rootNode:getChildByName("Node_2"):getChildByName("Image_1"):setVisible(false)
		rootNode:getChildByName("Node_2"):getChildByName("Image_2"):setVisible(true)

		rootNode:getChildByName("Node_3"):setVisible(true)
		rootNode:getChildByName("Node_4"):setVisible(false)


		end)

		btn2:onClicked(
		function()
			musicMgr:playEffect("game_button_click.mp3", false)
		rootNode:getChildByName("Node_1"):getChildByName("Image_1"):setVisible(false)
		rootNode:getChildByName("Node_1"):getChildByName("Image_2"):setVisible(true)
		rootNode:getChildByName("Node_2"):getChildByName("Image_1"):setVisible(true)
		rootNode:getChildByName("Node_2"):getChildByName("Image_2"):setVisible(false)

		rootNode:getChildByName("Node_3"):setVisible(false)
		rootNode:getChildByName("Node_4"):setVisible(true)

		end)

		btn_bangding:onClicked(
		function()


		end)

		btnclose:onClicked(
        function (  )
        	musicMgr:playEffect("game_button_click.mp3", false)
             --TTSocketClient:getInstance():closeMySocket(netTb.SocketType.Game)
            self:removeSelf()
        end)
end



function TuiGuangBox:init(  )
    -- body
end

function TuiGuangBox.create(  )
    return TuiGuangBox.new()
end
return TuiGuangBox
