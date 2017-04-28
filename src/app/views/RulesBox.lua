--  创建房间弹出界面--
local CURRENT_MODULE_NAME = ...
local dataMgr = import(".DataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()

local RulesBox = class("RulesBox", display.newLayer)
function RulesBox:ctor()
    local rootNode = cc.CSLoader:createNode("RulesBox.csb"):addTo(self)
    self.rootNode = rootNode
    rootNode:setPosition(display.center)
    layerMgr.LoginScene:addChild(self, 10000)
  
    local btnClose = rootNode:getChildByName("Button_close")
    local btn1 = rootNode:getChildByName("Node_1"):getChildByName("Button_1")
    local btn2 = rootNode:getChildByName("Node_2"):getChildByName("Button_2")
    local btn3 = rootNode:getChildByName("Node_3"):getChildByName("Button_3")
    local btn4 = rootNode:getChildByName("Node_4"):getChildByName("Button_4")
    ---设置初始显示值
    rootNode:getChildByName("Node_1"):getChildByName("Image_1"):setVisible(true)
    rootNode:getChildByName("Node_1"):getChildByName("Image_2"):setVisible(false)

    rootNode:getChildByName("Node_2"):getChildByName("Image_1"):setVisible(false)
    rootNode:getChildByName("Node_2"):getChildByName("Image_2"):setVisible(true)

    rootNode:getChildByName("Node_3"):getChildByName("Image_1"):setVisible(false)
    rootNode:getChildByName("Node_3"):getChildByName("Image_2"):setVisible(true)

    rootNode:getChildByName("Node_4"):getChildByName("Image_1"):setVisible(false)
    rootNode:getChildByName("Node_4"):getChildByName("Image_2"):setVisible(true)

    rootNode:getChildByName("ListView_1"):setVisible(true)
    rootNode:getChildByName("ListView_2"):setVisible(false)
    rootNode:getChildByName("ListView_3"):setVisible(false)
    rootNode:getChildByName("ListView_4"):setVisible(false)
    --------基本规则
    btn1:onClicked(
        function (  )
            rootNode:getChildByName("Node_1"):getChildByName("Image_1"):setVisible(true)
            rootNode:getChildByName("Node_1"):getChildByName("Image_2"):setVisible(false)

            rootNode:getChildByName("Node_2"):getChildByName("Image_1"):setVisible(false)
            rootNode:getChildByName("Node_2"):getChildByName("Image_2"):setVisible(true)

            rootNode:getChildByName("Node_3"):getChildByName("Image_1"):setVisible(false)
            rootNode:getChildByName("Node_3"):getChildByName("Image_2"):setVisible(true)

            rootNode:getChildByName("Node_4"):getChildByName("Image_1"):setVisible(false)
            rootNode:getChildByName("Node_4"):getChildByName("Image_2"):setVisible(true)
            rootNode:getChildByName("ListView_1"):setVisible(true)
            rootNode:getChildByName("ListView_2"):setVisible(false)
            rootNode:getChildByName("ListView_3"):setVisible(false)
            rootNode:getChildByName("ListView_4"):setVisible(false)
        end)
    ------翻型与算分
    btn2:onClicked(
        function (  )
            rootNode:getChildByName("Node_1"):getChildByName("Image_1"):setVisible(false)
            rootNode:getChildByName("Node_1"):getChildByName("Image_2"):setVisible(true)

            rootNode:getChildByName("Node_2"):getChildByName("Image_1"):setVisible(true)
            rootNode:getChildByName("Node_2"):getChildByName("Image_2"):setVisible(false)

            rootNode:getChildByName("Node_3"):getChildByName("Image_1"):setVisible(false)
            rootNode:getChildByName("Node_3"):getChildByName("Image_2"):setVisible(true)

            rootNode:getChildByName("Node_4"):getChildByName("Image_1"):setVisible(false)
            rootNode:getChildByName("Node_4"):getChildByName("Image_2"):setVisible(true)
            rootNode:getChildByName("ListView_1"):setVisible(false)
            rootNode:getChildByName("ListView_2"):setVisible(true)
            rootNode:getChildByName("ListView_3"):setVisible(false)
            rootNode:getChildByName("ListView_4"):setVisible(false)
    end)
    -------特殊规则
    btn3:onClicked(
        function (  )
            rootNode:getChildByName("Node_1"):getChildByName("Image_1"):setVisible(false)
            rootNode:getChildByName("Node_1"):getChildByName("Image_2"):setVisible(true)

            rootNode:getChildByName("Node_2"):getChildByName("Image_1"):setVisible(false)
            rootNode:getChildByName("Node_2"):getChildByName("Image_2"):setVisible(true)

            rootNode:getChildByName("Node_3"):getChildByName("Image_1"):setVisible(true)
            rootNode:getChildByName("Node_3"):getChildByName("Image_2"):setVisible(false)

            rootNode:getChildByName("Node_4"):getChildByName("Image_1"):setVisible(false)
            rootNode:getChildByName("Node_4"):getChildByName("Image_2"):setVisible(true)
            rootNode:getChildByName("ListView_1"):setVisible(false)
            rootNode:getChildByName("ListView_2"):setVisible(false)
            rootNode:getChildByName("ListView_3"):setVisible(true)
            rootNode:getChildByName("ListView_4"):setVisible(false) 
    end)
    -------结算
    btn4:onClicked(
        function (  )
            rootNode:getChildByName("Node_1"):getChildByName("Image_1"):setVisible(false)
            rootNode:getChildByName("Node_1"):getChildByName("Image_2"):setVisible(true)

            rootNode:getChildByName("Node_2"):getChildByName("Image_1"):setVisible(false)
            rootNode:getChildByName("Node_2"):getChildByName("Image_2"):setVisible(true)

            rootNode:getChildByName("Node_3"):getChildByName("Image_1"):setVisible(false)
            rootNode:getChildByName("Node_3"):getChildByName("Image_2"):setVisible(true)

            rootNode:getChildByName("Node_4"):getChildByName("Image_1"):setVisible(true)
            rootNode:getChildByName("Node_4"):getChildByName("Image_2"):setVisible(false)
            rootNode:getChildByName("ListView_1"):setVisible(false)
            rootNode:getChildByName("ListView_2"):setVisible(false)
            rootNode:getChildByName("ListView_3"):setVisible(false)
            rootNode:getChildByName("ListView_4"):setVisible(true)
    end)

        --dataMgr.HistroyRecords[i].dwUserID
    btnClose:onClicked(
    function (  )
            --TTSocketClient:getInstance():closeMySocket(netTb.SocketType.Game)
        self:removeSelf()
    end)
end



function RulesBox:init(  )
    -- body
end

function RulesBox.create(  )
    return RulesBox.new()
end
return RulesBox