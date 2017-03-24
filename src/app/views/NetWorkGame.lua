

local CURRENT_MODULE_NAME = ...
local dataMgr     = import(".DataManager"):getInstance()
local cardDataMgr     = import(".CardDataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()
local cardMgr = import(".CardManager"):getInstance()

local s_inst = nil
local NetWorkGame = class("NetWorkGame", display.newNode)

function NetWorkGame:getInstance()
    if nil == s_inst then
        s_inst = NetWorkGame.new()
        s_inst:retain()
        s_inst:inits()    
    end
    return s_inst
end

function NetWorkGame:inits()
    print("NetWorkGame:inits OK")
    local listener = cc.EventListenerCustom:create("rcvDataGame", handler(self, self.handleEventGame))
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
end

function NetWorkGame:handleEventGame( event)
    local rcv = DataRcv:create(event)
    local wMainCmd = rcv:readWORD()
    local wSubCmd = rcv:readWORD()
    print("Game:Main "..wMainCmd..", Sub "..wSubCmd)
    
    if wMainCmd == 0 then
    --心跳
        if wSubCmd == 1 then
            local snd = DataSnd:create(0, 1)
            snd:sendData(netTb.SocketType.Game)
            snd:release();
        end

    elseif wMainCmd == 1 then
        if wSubCmd == 102 then
            --连接成功
            if dataMgr.roomSet.bIsCreate == 1 then
                self:connectSuccessCreate(rcv)
            elseif dataMgr.roomSet.bIsCreate == 0 then
                self:connectSuccessJoin(rcv)
            end
        --连接失败
        elseif wSubCmd == 101 then
            TTSocketClient:getInstance():closeMySocket(netTb.SocketType.Game)

        --创建成功
        elseif wSubCmd == 104 then
            self:createSuccess(rcv) 
        end

    elseif wMainCmd == 3 then
        --坐下
        if wSubCmd == 102 then
            self:sitDown(rcv)
        --来人
        elseif wSubCmd == 100 then
            self:playerCome(rcv) 
        end

        --200,1 出牌，一个byte
    elseif wMainCmd == 200 then
            if wSubCmd == 100 then --发牌
                self:sendCard(rcv)
            elseif wSubCmd == 101 then --出牌
                self:rcvOutCard(rcv)
            elseif wSubCmd == 102 then --抓牌（含花牌）
                self:drawCard(rcv)  
            elseif wSubCmd == 103 then
                --todo 发给所有人听牌了
            

            --[[只发给自己，显示碰杠胡]]
            elseif wSubCmd == 104 then
                self:waitOption(rcv) 

            --[[ 碰杠胡操作的响应] ]]
            elseif wSubCmd == 105 then
                self:optionResult(rcv  )
            end    
    --
    end
end

--[[   200,104
    struct CMD_S_OperateNotify
    {
        WORD                            wResumeUser;                        //还原用户
        BYTE                            cbActionMask;                       //动作掩码
        BYTE                            cbActionCard;                       //动作扑克
    };
    ]]


    --[[
      200, 3,  send  
    //操作命令
    struct CMD_C_OperateCard
    {
        BYTE                            cbOperateCode;                      //操作代码
        BYTE                            cbOperateCard[3];                   //操作扑克
    };

    200, 2听
    ]]

--等待操作，碰杠胡
function NetWorkGame:waitOption( rcv )
    rcv:readWORD()
    local bActionMask = rcv:readByte()
    local bActionCard = rcv:readByte()
    layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params):waitOption(bActionMask, bActionCard)
end


--[[操作命令  200,105
    struct CMD_S_OperateResult
    {
        WORD                            wOperateUser;                       //操作用户
        WORD                            wProvideUser;                       //供应用户
        BYTE                            cbOperateCode;                      //操作代码
        BYTE                            cbOperateCard[3];                   //操作扑克
    };]]
--操作返回，碰杠胡
function NetWorkGame:optionResult(rcv  )
    local optResult = {}
    optResult.wOperateUser  = rcv:readWORD()
    optResult.wProvideUser  = rcv:readWORD()
    optResult.cbOperateCode = rcv:readByte()
    optResult.cbOperateCard = rcv:readByte()
    layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params):optionResult(optResult)
    
end


--房间连接成功创建
function NetWorkGame:connectSuccessCreate( rcv )
    -- local mainLayer = layerMgr:getLayer(layerMgr.layIndex.MainLayer)
    -- mainLayer:showCreateRoom()
    print("\n\n connectSuccessCreate OK!")
    layerMgr.boxes[layerMgr.boxIndex.CreateRoomBox] = import(".CreateRoomBox",CURRENT_MODULE_NAME).create()

end

--房间连接成功加入
function NetWorkGame:connectSuccessJoin( rcv )
    rcv:destroys()
    local wTable = dataMgr.roomSet.dwRoomNum % 65536
    local wChair = (dataMgr.roomSet.dwRoomNum - wTable)/ 65536 


   -- local delay = cc.DelayTime:create(1.0)
    --local action = cc.Sequence:create(delay, cc.CallFunc:create(
    --    function (  )
            layerMgr:removeBoxes(layerMgr.boxIndex.JoinRoomBox)
            layerMgr:showLayer(layerMgr.layIndex.PlayLayer, params)
            layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params):waitJoin()  
    --    end)
   -- )
    --self:runAction(action)
end

--创建房间成功
function NetWorkGame:createSuccess( rcv )
    local wTableId = rcv:readWORD()
    local wChairId = rcv:readWORD()
    rcv:destroys()
    dataMgr.roomSet.wChair = wChairId
    dataMgr.roomSet.wTable = wTableId
    dataMgr.roomSet.dwRoomNum = wChairId * 65536 + wTableId
    print("\n\n\nwChairID  "..wChairId.."wTableId  "..wTableId)
    layerMgr:removeBoxes(layerMgr.boxIndex.CreateRoomBox)
    layerMgr:showLayer(layerMgr.layIndex.PlayLayer, params)
    layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params):waitJoin()

--cgpTest
--     cardDataMgr.cardSend.wBankerUser    =  2              --庄家用户
--     cardDataMgr.cardSend.wCurrentUser   =  2              --当前用户
--     cardDataMgr.cardSend.wReplaceUser   =  2              --补牌用户
--     cardDataMgr.cardSend.bSice1         =  3  
--     cardDataMgr.cardSend.bSice2         =  4
--     cardDataMgr.cardSend.cbUserAction   =  2              --用户动作
--   --连庄计数

-- --cgpTest
--     layerMgr:getLayer(layerMgr.layIndex.PlayLayer):sendCard()



end

function NetWorkGame:sitDown( rcv )
    local dwUserId = rcv:readDWORD()
    local wTableId = rcv:readWORD()
    local wChairId = rcv:readWORD()
    local cbUserStatus = rcv:readByte()
    rcv:destroys()
    if dataMgr.myBaseData.dwUserID == dwUserId and cbUserStatus == 2 then
        --me sitdown ,fresh data
        local snd = DataSnd:create(100, 2)
        snd:sendData(netTb.SocketType.Game)
        snd:release();
    end
end

function NetWorkGame:playerCome( rcv )
--readData and 赋值
    local dwGameID      = rcv:readDWORD();
    local dwUserID      = rcv:readDWORD();
    local dwGroupID     = rcv:readDWORD();
    local wFaceID       = rcv:readWORD();
    local dwCustomID    = rcv:readDWORD();
    local cbGender      = rcv:readByte();
    local cbMemberOrder = rcv:readByte();
    local cbMasterOrder = rcv:readByte();
    local cbUserStatus  = rcv:readByte();
    local wTableID      = rcv:readWORD();
    local wChairID      = rcv:readWORD();         --0,3
    local lScore        = rcv:readUInt64();
    local lGrade        = rcv:readUInt64();
    local lInsure       = rcv:readUInt64();
    local dwWinCount    = rcv:readDWORD();
    local dwLostCount   = rcv:readDWORD();
    local dwDrawCount   = rcv:readDWORD();
    local dwFleeCount   = rcv:readDWORD();
    local dwUserMedal   = rcv:readDWORD();
    local dwExperience  = rcv:readDWORD();
    local lLoveLiness   = rcv:readDWORD();
    local nick1         = rcv:readWORD();  
    local nick2         = rcv:readWORD();
    local szNickName    = rcv:readString(nick1);
    rcv:destroys()

    local svrChair = wChairID + 1
    if svrChair > 4 or svrChair < 1 then
        print("error: wChairID out of range !")
        return
    end

    dataMgr.onDeskData[svrChair].dwGameID      = dwGameID     
    dataMgr.onDeskData[svrChair].dwUserID      = dwUserID     
    dataMgr.onDeskData[svrChair].dwGroupID     = dwGroupID    
    dataMgr.onDeskData[svrChair].wFaceID       = wFaceID      
    dataMgr.onDeskData[svrChair].dwCustomID    = dwCustomID   
    dataMgr.onDeskData[svrChair].cbGender      = cbGender     
    dataMgr.onDeskData[svrChair].cbMemberOrder = cbMemberOrder
    dataMgr.onDeskData[svrChair].cbMasterOrder = cbMasterOrder
    dataMgr.onDeskData[svrChair].cbUserStatus  = cbUserStatus 
    dataMgr.onDeskData[svrChair].wTableID      = wTableID     
    dataMgr.onDeskData[svrChair].wChairID      = wChairID     
    dataMgr.onDeskData[svrChair].lScore        = lScore       
    dataMgr.onDeskData[svrChair].lGrade        = lGrade       
    dataMgr.onDeskData[svrChair].lInsure       = lInsure      
    dataMgr.onDeskData[svrChair].dwWinCount    = dwWinCount   
    dataMgr.onDeskData[svrChair].dwLostCount   = dwLostCount  
    dataMgr.onDeskData[svrChair].dwDrawCount   = dwDrawCount  
    dataMgr.onDeskData[svrChair].dwFleeCount   = dwFleeCount  
    dataMgr.onDeskData[svrChair].dwUserMedal   = dwUserMedal  
    dataMgr.onDeskData[svrChair].dwExperience  = dwExperience 
    dataMgr.onDeskData[svrChair].lLoveLiness   = lLoveLiness  
    dataMgr.onDeskData[svrChair].nick1         = nick1        
    dataMgr.onDeskData[svrChair].nick2         = nick2        
    dataMgr.onDeskData[svrChair].szNickName    = szNickName   
--客户端chairId赋值

    print("\nmyBaseData.dwUserID  "..dataMgr.myBaseData.dwUserID)
    print("\ndwUserId  "..dataMgr.myBaseData.dwUserID)
    if dataMgr.myBaseData.dwUserID == dwUserID then
        local svrChairId = wChairID + 1    --从1开始, 1, 4
        dataMgr.chair[svrChairId] = 1
        local index = svrChairId
        for i=2,4 do
            index = index + 1
            if index > 4 then
                index = 1
            end
            dataMgr.chair[index] = i
        end

        for i=1,4 do
            print("\n\nchairId "..dataMgr.chair[i])
        end
        print("\nwChairId   "..wChairID)
    end

    layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params):showPlayer(wChairID)

end

--发牌
function NetWorkGame:sendCard( rcv )
    cardDataMgr.cardSend.wBankerUser    = rcv:readWORD()               --庄家用户
    cardDataMgr.cardSend.wCurrentUser   = rcv:readWORD()               --当前用户
    cardDataMgr.cardSend.wReplaceUser   = rcv:readWORD()               --补牌用户
    cardDataMgr.cardSend.bLianZhuangCount = rcv:readByte()             --连庄
    cardDataMgr.cardSend.bHuaCount      = rcv:readByte()
    cardDataMgr.cardSend.bSice1         = rcv:readByte()   
    cardDataMgr.cardSend.bSice2         = rcv:readByte()
    cardDataMgr.cardSend.cbUserAction   = rcv:readByte()               --用户动作
    print("cardDataMgr.cardSend.wBankerUser   "..cardDataMgr.cardSend.wBankerUser )
    print("cardDataMgr.cardSend.wCurrentUser  "..cardDataMgr.cardSend.wCurrentUser)
    print("cardDataMgr.cardSend.wReplaceUser  "..cardDataMgr.cardSend.wReplaceUser)
    print("cardDataMgr.cardSend.bSice1        "..cardDataMgr.cardSend.bSice1      )
    print("cardDataMgr.cardSend.bSice2        "..cardDataMgr.cardSend.bSice2      )
    print("cardDataMgr.cardSend.cbUserAction  "..cardDataMgr.cardSend.cbUserAction)

    local clientBankId = dataMgr.chair[cardDataMgr.cardSend.wBankerUser + 1]
    cardDataMgr.bankClient = clientBankId

    --所有人都发14字节，非庄家14字节无效
    for i=1, 13 do
        cardDataMgr.cardSend.cbCardData[i] = rcv:readByte()
       -- print("cardValues "..cardDataMgr.cardSend.cbCardData[i])
    end

    local drawValue = rcv:readByte()
    if clientBankId ~= 1 then
        drawValue = 0
    end

    for i=1, cardDataMgr.cardSend.bHuaCount do
        cardDataMgr.cardSend.cbHuaCardData[i] = rcv:readByte()
        --print("HuaValues "..cardDataMgr.cardSend.cbHuaCardData[i])
    end
   
   -- print("cardDataMgr.cardSend.bLianZhuangCount  "..cardDataMgr.cardSend.bLianZhuangCount)                       --连庄计数
    layerMgr:getLayer(layerMgr.layIndex.PlayLayer):sendCard(drawValue)
    rcv:destroys()
end

--收到用户出牌
function NetWorkGame:rcvOutCard( rcv )
    local outCard = {}
    outCard.wOutCardUser = rcv:readWORD() --svrChair
    outCard.bOutCardData = rcv:readByte()
    rcv:destroys()
    cardMgr:rcvOutCard(outCard)
end

--抓牌
function NetWorkGame:drawCard( rcv )
    local cardZhua = {}
    cardZhua.cbHuaCardData = {}
    cardZhua.wCurrentUser = rcv:readWORD()  
    cardZhua.wReplaceUser = rcv:readWORD()
    cardZhua.wSendCardUser= rcv:readWORD()
    cardZhua.cbCardData   = rcv:readByte()
    cardZhua.cbHuaCount   = rcv:readByte()
    cardZhua.cbActionMask = rcv:readByte()
    for i=1, cardZhua.cbHuaCount do
        cardZhua.cbHuaCardData = rcv:readByte()
        --print("HuaValues "..cardDataMgr.cardSend.cbHuaCardData[i])
    end

    rcv:destroys()
    cardMgr:drawCard(cardZhua)
end

return NetWorkGame