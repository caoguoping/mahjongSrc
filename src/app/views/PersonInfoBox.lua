--  个人信息弹出界面--
local CURRENT_MODULE_NAME = ...
local dataMgr = import(".DataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()
local musicMgr = import(".MusicManager"):getInstance()

local PersonInfoBox = class("PersonInfoBox", display.newLayer)
function PersonInfoBox:ctor()
    local rootNode = cc.CSLoader:createNode("personInfo.csb"):addTo(self)
    self.rootNode = rootNode
    rootNode:setPosition(display.center)
    layerMgr.LoginScene:addChild(self, 10001)
  
  	self.txtId = rootNode:getChildByName("Text_id")
  	self.txtName = rootNode:getChildByName("Text_name")
  	self.txtRoomCard = rootNode:getChildByName("Text_roomCard")
  	self.imgHead = rootNode:getChildByName("Image_head")

end



function PersonInfoBox:init( clientId ,posx, posy)
	if clientId == 1 then   --自己
	    self.txtId:setString(dataMgr.myBaseData.dwUserID)
	    self.txtName:setString(dataMgr.myBaseData.szNickName)
	    self.txtRoomCard:setString(dataMgr.prop[10])
	else
	    local svrId = dataMgr:getServiceChairId(clientId)
	    self.txtId:setString(dataMgr.onDeskData[svrId].dwUserID)
	    self.txtName:setString(dataMgr.onDeskData[svrId].szNickName)
	    self.txtRoomCard:setString(dataMgr.onDeskData[svrId].roomCard)
	end
    --头像
    --裁剪头像
    local headPath = cc.FileUtils:getInstance():getWritablePath().."headImage_"..clientId..".png"
    local headSize = self.imgHead:getContentSize()
    local sp = display.createCircleSprite(headPath, "headshot_example.png"):addTo(self.imgHead)
    sp:setPosition(headSize.width * 0.5, headSize.height * 0.5)	


    self:setPosition(cc.p(posx - 0.5 * display.width + 301 * 0.5, posy - 0.5 * display.height + 127 * 0.5))

end

function PersonInfoBox.create(  )
    return PersonInfoBox.new()
end
return PersonInfoBox
