--  商城弹出界面--
local CURRENT_MODULE_NAME = ...
local dataMgr     = import(".DataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()
local musicMgr = import(".MusicManager"):getInstance()



local ShoppingBox = class("ShoppingBox", display.newLayer)
function ShoppingBox:ctor()
--all Node
    local rootNode = cc.CSLoader:createNode("shopping.csb"):addTo(self)
    self.rootNode = rootNode
    rootNode:setPosition(display.center)
    layerMgr.LoginScene:addChild(self, 10000)


    local btnClose = rootNode:getChildByName("Button_close")
        btnClose:onClicked(
        function (  )
            musicMgr:playEffect("game_button_click.mp3", false)
            local mainlayer = layerMgr:getLayer(layerMgr.layIndex.MainLayer)
            mainlayer:refresh()
            self:removeSelf()
        end)

    local cardMoney = {3, 5, 15, 50, 100, 520}
    local btns = {}
    for i=1,6 do
        local tmpStr = "Button__"..i     --两个“-”
        btns[i] = rootNode:getChildByName(tmpStr)
        btns[i]:onClicked(
        function (  )
            print("buyCount")
            musicMgr:playEffect("game_button_click.mp3", false)
                local snd = DataSnd:create(3, 504)
                local dwUserId = dataMgr.myBaseData.dwUserID
                local buyCount = cardMoney[i]
                local kindId = 10
                snd:wrDWORD(dwUserId)
                snd:wrWORD(buyCount)
                snd:wrWORD(kindId)
                snd:sendData(netTb.SocketType.Login)
                snd:release();
        end
        )
    end
end

function ShoppingBox.create(  )
    return ShoppingBox.new()
end

return ShoppingBox
