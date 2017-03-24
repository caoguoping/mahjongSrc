--大厅界面

local CURRENT_MODULE_NAME = ...

local dataMgr     = import(".DataManager"):getInstance()
local layerMgr= import(".LayerManager"):getInstance()

local MainLayer = class("MainLayer", display.newLayer)


function MainLayer:ctor()
    local rootNode = cc.CSLoader:createNode("NewLobby.csb"):addTo(self)
    self.rootNode = rootNode
    local btnCreate = rootNode:getChildByName("Button_create")
    local btnJoin = rootNode:getChildByName("Button_join")
    btnCreate:onClicked(
    function ()
    --cgpTest
    --[[
        startGame (1,1),连接游戏服务器成功(1,100)后弹出设置界面,(1,4)创建房间，1,104成功后显示房间
    ]]
                
        dataMgr.roomSet.bIsCreate = 1
        dataMgr.joinPeople = 0
        self:startGame(netTb.ip, netTb.port.game, netTb.SocketType.Game)  
        local playLayer = layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params)
        playLayer:refresh()
        playLayer:setVisible(false)
        --layerMgr:showLayer(layerMgr.layIndex.PlayLayer, params)
        --self:showCreateRoom()
        --dataMgr.roomSet.bIsCreate = 1
        --layerMgr.boxes[layerMgr.boxIndex.CreateRoomBox] = import(".CreateRoomBox",CURRENT_MODULE_NAME).create()
        --layerMgr:showLayer(layerMgr.layIndex.PlayLayer, params)
    end
    ) 

    btnJoin:onClicked(
    function ()
--cgpTest
    --[[
        弹出界面，写完直接发(1, 1)
    ]]
        dataMgr.roomSet.bIsCreate = 0
        dataMgr.joinPeople = 0
        layerMgr.boxes[layerMgr.boxIndex.JoinRoomBox] = import(".JoinRoomBox",CURRENT_MODULE_NAME).create()
        local playLayer = layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params)
        playLayer:refresh()
        playLayer:setVisible(false)
    end
    )    

end

function MainLayer:refresh()
    -- body
end

function MainLayer:showCreateRoom(  )
    --local  createRoomBox = import(".CreateRoomBox",CURRENT_MODULE_NAME).create()

end

function MainLayer.creator( )
   return MainLayer.new()
end

function MainLayer:refresh(params)
    -- body
end

function MainLayer:startGame(ip, port)
    TTSocketClient:getInstance():startSocket(ip, port, netTb.SocketType.Game)

    local snd = DataSnd:create(1, 1)
    local uid = dataMgr.myBaseData.uid
    local dwPlazaVersion = 65536
    local dwFrameVersion = 65536
    local dwProcessVersion = 65536
    local szPassword = uid
    local szMachineID = uid
    local wKindID = 3
    local wTable = 65535
    local wChair = 65535       
    --为密码，实际总的tableId为：wChair * 65536 + wTable
    --创建房间发满的，加入房间发实际的

    snd:wrDWORD(dwPlazaVersion)
    snd:wrDWORD(dwFrameVersion)
    snd:wrDWORD(dwProcessVersion)
    snd:wrDWORD(dataMgr.myBaseData.dwUserID)
    snd:wrString(szPassword, 66) 
    snd:wrString(szMachineID, 66) 
    snd:wrWORD(wKindID) 

    snd:wrWORD(wTable)  
    snd:wrWORD(wChair) 
    snd:sendData(netTb.SocketType.Game)
    snd:release();
end

return MainLayer
