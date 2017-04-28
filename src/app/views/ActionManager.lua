--特效管理

local dataMgr     = import(".DataManager"):getInstance()
local cardDataMgr     = import(".CardDataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()

local CURRENT_MODULE_NAME = ...

local s_inst = nil
local ActionManager = class("ActionManager")

function ActionManager:getInstance()
    if nil == s_inst then
        s_inst = ActionManager.new()
        s_inst:init()
    end
    return s_inst
end

function ActionManager:init()
    local playLayer = layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params)    --定时器运行 在deskBg层
    self.nodeAction = playLayer.rootNode:getChildByName("FileNode_action")   --特效节点
    --self.nodeUi = playLayer.rootNode:getChildByName("FileNode_deskUi")    

    self.outNode = {}
    self.outNode[1]  =  playLayer.rootNode:getChildByName("FileNode_dachuMe")    --打出牌节点，上面运行箭头特效
    self.outNode[2]  =  playLayer.rootNode:getChildByName("FileNode_dachuLeft")
    self.outNode[3]  =  playLayer.rootNode:getChildByName("FileNode_dachuUp")
    self.outNode[4]  =  playLayer.rootNode:getChildByName("FileNode_dachuRight")



    self.actNode = {}  --[1,7] 补花，碰，杠，胡，杠开， 天胡，地胡
    for i=1,7 do
        self.actNode[i] = self.nodeAction:getChildByName("FileNode_"..i)
        self.actNode[i]:setVisible(false)
    end
    self.timeLine = {}

    self.timeLine[1] = cc.CSLoader:createTimeline("actBuhua.csb")
    self.timeLine[2] = cc.CSLoader:createTimeline("actPeng.csb")
    self.timeLine[3] = cc.CSLoader:createTimeline("actGang.csb")
    self.timeLine[4] = cc.CSLoader:createTimeline("actHupai.csb")
    self.timeLine[5] = cc.CSLoader:createTimeline("actGanghoukaihua.csb")
    self.timeLine[6] = cc.CSLoader:createTimeline("actTianhu.csb")
    self.timeLine[7] = cc.CSLoader:createTimeline("actDihu.csb")

    for i=1,7 do
        self.nodeAction:runAction(self.timeLine[i])
        self.timeLine[i]:setLastFrameCallFunc(
        function ()
            self.actNode[i]:setVisible(false)
        end
        )
    end

     --箭头
    self.jianTouNodes = {}
    self.jianTouTimeLines = {}
    for i=1,4 do
        self.jianTouNodes[i] = cc.CSLoader:createNode("jianTou.csb"):addTo(self.outNode[i])
        self.jianTouTimeLines[i] = cc.CSLoader:createTimeline("jianTou.csb")
        self.outNode[i]:runAction( self.jianTouTimeLines[i])
        self.jianTouNodes[i]:setVisible(false)
    end



end

function ActionManager:playAction(actIndex, clientId)
    self.actNode[actIndex]:setVisible(true)
    self.timeLine[actIndex]:gotoFrameAndPlay(0, false)
    self.nodeAction:setPositionX(girl.effPosX[clientId])
    self.nodeAction:setPositionY(girl.effPosY[clientId])
end

--clientId ==0时
function ActionManager:playJianTou(clientId, posx, posy)
    for i=1,4 do
        self.jianTouNodes[i]:setVisible(false)
    end
    if clientId ~= 0 then
        self.jianTouNodes[clientId]:setVisible(true)
        self.jianTouTimeLines[clientId]:gotoFrameAndPlay(0, true)
        self.jianTouNodes[clientId]:setPosition(posx, posy + 30)
    end
end



return ActionManager
