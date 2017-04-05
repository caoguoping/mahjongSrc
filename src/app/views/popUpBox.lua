--  弹出界面--
local CURRENT_MODULE_NAME = ...
local dataMgr     = import(".DataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()


local popUpBox = class("popUpBox", display.newLayer)
function popUpBox:ctor(str)
--all Node
    local rootNode = cc.CSLoader:createNode("popUpBox.csb"):addTo(self)
    self.rootNode = rootNode
    rootNode:setPosition(display.center)
    layerMgr.LoginScene:addChild(self, 10000)
    self.txtInfo = rootNode:getChildByName("Text_info")
    self.btnCancel = rootNode:getChildByName("Button_cancel")
    self.btnOk = rootNode:getChildByName("Button_Ok")
end
function popUpBox.create(str)
    return popUpBox.new(str)
end
function popUpBox:getBtns()
    return self.btnOk, self.btnCancel
end
function popUpBox:remove(  )
    self:removeSelf()
end
function popUpBox:setInfo( str )
    self.txtInfo:setString(str)
end
return popUpBox