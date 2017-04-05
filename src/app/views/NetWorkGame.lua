

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
   -- print("NetWorkGame:inits OK")
    local listener = cc.EventListenerCustom:create("rcvDataGame", handler(self, self.handleEventGame))
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
end

function NetWorkGame:handleEventGame( event)
    local rcv = DataRcv:create(event)
    local wMainCmd = rcv:readWORD()
    local wSubCmd = rcv:readWORD()
    --print("Game:Main "..wMainCmd..", Sub "..wSubCmd)
    
    if wMainCmd == 0 then
    --心跳
        if wSubCmd == 1 then
            local snd = DataSnd:create(0, 1)
            snd:sendData(netTb.SocketType.Game)
            snd:release()
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
        --加入时房间验证失败
        elseif wSubCmd == 103 then
            self:joinRoomFail(rcv) 
        --创建房间成功与否
        elseif wSubCmd == 104 then
            self:createRoom(rcv) 
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

            --[[ 碰杠(胡)操作的响应] ]]
            elseif wSubCmd == 105 then
                self:optionResult(rcv  )

            elseif wSubCmd == 106 then
                self:huPai(rcv)
    --补花的个数，发完牌后发一次，4家 ，  num1, num2, num3, num4,  cardv[1] = {}, cardv2= {}，。。。
            elseif wSubCmd == 111 then  
                self:getAllBuhua(rcv)
            elseif wSubCmd == 112 then
                self:getRoomConfig(rcv)
        end 


    --
    end
end

--获取房间配置
function NetWorkGame:getRoomConfig( rcv )
    
end

function NetWorkGame:joinRoomFail( rcv )
    TTSocketClient:getInstance():closeMySocket(netTb.SocketType.Game)
    
    local popupbox =  import(".popUpBox",CURRENT_MODULE_NAME).create() 
    popupbox:setInfo(Strings.roomNotExist)
    local btnOk, btnCancel  = popupbox:getBtns()
    btnOk:onClicked(function (  )
        popupbox:remove()
        layerMgr.boxes[LayerManager.boxIndex.JoinRoomBox]:reputRoomNum()
    end)
    btnCancel:onClicked(function (  )
        layerMgr.boxes[LayerManager.boxIndex.JoinRoomBox]:reputRoomNum()
        popupbox:remove()
    end)

    
    print("joinRoomFail(rcv)")
end


--补花个数
function NetWorkGame:getAllBuhua( rcv )
    for i=1,4 do
        cardDataMgr.huaNum[dataMgr.chair[i]]  =  rcv:readByte()
       -- print("getAllBuhua "..cardDataMgr.huaNum[dataMgr.chair[i]])
    end
end

--胡牌数据（200， 106）
function NetWorkGame:huPai( rcv )
    local gameEndData = {}
    --所有玩家按照服务器ID，0,1,2,3发送
    gameEndData.lGameScore = {}
    gameEndData.dwChiHuKind = {}  --4 个       0,没胡，  
    gameEndData.dwChiHuRight = {}  --4*3个   翻型
    gameEndData.cbHuaCardCount = {}         
    gameEndData.wFanCount = {}         
    gameEndData.cbCardCount = {}         
    gameEndData.cbCardData = {}
    gameEndData.cbCardPeng = {}--碰
    gameEndData.cbCardGang = {} --杠
    --start
    gameEndData.lGameTax = rcv:readUInt64()   --税收
    for i=1,4 do
        gameEndData.lGameScore[i] = rcv:readUInt64()    --积分
        --print(" score "..gameEndData.lGameScore[i])  
    end
    for i=1,4 do
        gameEndData.dwChiHuKind[i] = rcv:readDWORD()
        --print("i"..i..",dwChiHuKind"..gameEndData.dwChiHuKind[i])
    end
    for i=1,4 do
        gameEndData.dwChiHuRight[i] = {}
        for j =1, 3 do
            gameEndData.dwChiHuRight[i][j] = rcv:readDWORD()
            --print("i "..i..",j "..j..", dwChiHuRight "..gameEndData.dwChiHuRight[i][j])
        end
    end
    for i=1,4 do
        gameEndData.cbHuaCardCount[i] = rcv:readByte()     --花牌个数
        --print("huapai 个数 "..gameEndData.cbHuaCardCount[i])
    end
    for i=1,4 do
           gameEndData.wFanCount[i] = rcv:readWORD()       --翻数 
            --print("wFanCount "..gameEndData.wFanCount[i])   
    end
    for i=1,4 do
        gameEndData.cbCardCount[i] = rcv:readByte()      --4家的手牌个数
        --print("cbCardCount "..gameEndData.cbCardCount[i])   

    end
    for i=1,4 do
        gameEndData.cbCardData[i] = {} 
        for j=1,14 do
            gameEndData.cbCardData[i][j] = rcv:readByte()     --4家的手牌值
            --print(" i "..i.." j "..j.." cbCardData "..gameEndData.cbCardData[i][j])   

        end 
    end
    for i=1,4 do
        gameEndData.cbCardPeng[i] = {}
        for j=1,4 do
            gameEndData.cbCardPeng[i][j] = rcv:readByte()
            --print(" i "..i.." j "..j.." cbCardPeng "..gameEndData.cbCardPeng[i][j])   
        end
    end
    for i=1,4 do
        gameEndData.cbCardGang[i] = {}
        for j=1,4 do
            gameEndData.cbCardGang[i][j] = rcv:readByte()
            --print(" i "..i.." j "..j.." cbCardGang "..gameEndData.cbCardGang[i][j])   
        end
    end
    gameEndData.wProvideUser = rcv:readWORD()
    gameEndData.cbProvideCard = rcv:readByte()
    dataMgr.playerStatus = 2    --游戏结束
    local playLayer = layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params)
    playLayer:huPai(gameEndData)

end

--等待操作，碰杠胡
function NetWorkGame:waitOption( rcv )
    rcv:readWORD()
    local bActionMask = rcv:readByte()
    local bActionCard = rcv:readByte()
    print("mySvrId "..(dataMgr:getServiceChairId(1) + 1))
    print(" waitOption "..bActionMask.."  "..bActionCard)
    layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params):waitOption(bActionMask, bActionCard)
end


--操作返回，碰杠胡
function NetWorkGame:optionResult(rcv  )
    local optResult = {}
    optResult.wOperateUser  = rcv:readWORD()
    optResult.wProvideUser  = rcv:readWORD()
    optResult.cbOperateCode = rcv:readByte()
    optResult.cbOperateCard = rcv:readByte()
    layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params):optionResult(optResult)
    
end


--房间连接成功创建，
function NetWorkGame:connectSuccessCreate( rcv )
    -- local mainLayer = layerMgr:getLayer(layerMgr.layIndex.MainLayer)
    -- mainLayer:showCreateRoom()
    layerMgr.boxes[layerMgr.boxIndex.CreateRoomBox]:sendCreateRoom()
    print("\n\n connectSuccessCreate OK!")
    --layerMgr.boxes[layerMgr.boxIndex.CreateRoomBox] = import(".CreateRoomBox",CURRENT_MODULE_NAME).create()

end

--房间连接成功 加入
function NetWorkGame:connectSuccessJoin( rcv )
    
    rcv:destroys()
 
end

--创建房间成功(1, 104)    如果wTable = 0xFFFF, 创建失败
function NetWorkGame:createRoom( rcv )
    local wTableId = rcv:readWORD()
    local wChairId = rcv:readWORD()
    rcv:destroys()
    dataMgr.roomSet.wChair = wChairId
    dataMgr.roomSet.wTable = wTableId
    dataMgr.roomSet.dwRoomNum = wChairId * 65536 + wTableId

    if wTableId == 65535 then
        TTSocketClient:getInstance():closeMySocket(netTb.SocketType.Game)
        layerMgr:removeBoxes(layerMgr.boxIndex.CreateRoomBox)
    else
       --print("\n\n\nwChairID  "..wChairId.."wTableId  "..wTableId)
        layerMgr:removeBoxes(layerMgr.boxIndex.CreateRoomBox)
        layerMgr:showLayer(layerMgr.layIndex.PlayLayer, params)
        
        layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params):waitJoin()
    end




end




--解散房间，发送 3, 12,   （4个2 ，发准备，状态2变1（走掉一个），  
--创建房间者  1个字节    （出来 1，  进去 2）    发送 3，13，   


--状态变化   1:起立，  2， 坐下，   3， 准备，   

--3, 102
function NetWorkGame:sitDown( rcv )
    local dwUserId = rcv:readDWORD()
    local wTableId = rcv:readWORD()
    local wChairId = rcv:readWORD()
    local cbUserStatus = rcv:readByte()
    rcv:destroys()
    if dataMgr.playerStatus == 0 then
        if dataMgr.myBaseData.dwUserID == dwUserId and cbUserStatus == 2 then
            --me sitdown ,fresh data
            --加入房间时，显示房间
            if dataMgr.roomSet.bIsCreate == 0 then
                layerMgr:removeBoxes(layerMgr.boxIndex.JoinRoomBox)
                layerMgr:showLayer(layerMgr.layIndex.PlayLayer, params)
                layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params):waitJoin() 
            end
             
            --发送准备
            local snd = DataSnd:create(100, 2)
            print("\n  ^^^^^^^^^^^^^^^^^^^^^ zhunbei , 100, 2")
            snd:sendData(netTb.SocketType.Game)
            snd:release()
        end
    end

end

function NetWorkGame:playerCome( rcv )
--readData and 赋值
    local dwGameID      = rcv:readDWORD()
    local dwUserID      = rcv:readDWORD()
    local dwGroupID     = rcv:readDWORD()
    local wFaceID       = rcv:readWORD()
    local dwCustomID    = rcv:readDWORD()
    local cbGender      = rcv:readByte()
    local cbMemberOrder = rcv:readByte()
    local cbMasterOrder = rcv:readByte()
    local cbUserStatus  = rcv:readByte()
    local wTableID      = rcv:readWORD()
    local wChairID      = rcv:readWORD()        --0,3
    local lScore        = rcv:readUInt64()
    local lGrade        = rcv:readUInt64()
    local lInsure       = rcv:readUInt64()
    local dwWinCount    = rcv:readDWORD()
    local dwLostCount   = rcv:readDWORD()
    local dwDrawCount   = rcv:readDWORD()
    local dwFleeCount   = rcv:readDWORD()
    local dwUserMedal   = rcv:readDWORD()
    local dwExperience  = rcv:readDWORD()
    local lLoveLiness   = rcv:readDWORD()
    local nick1         = rcv:readWORD()  
    local nick2         = rcv:readWORD()
    local szNickName    = rcv:readString(nick1)
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

        -- for i=1,4 do
        --     print("\n\nchairId "..dataMgr.chair[i])
        -- end
        -- print("\nwChairId   "..wChairID)
    end

    layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params):showPlayer(wChairID)

end

--发牌
function NetWorkGame:sendCard( rcv )
    cardDataMgr.cardSend.wBankerUser    = rcv:readWORD()               --庄家用户
    cardDataMgr.cardSend.wCurrentUser   = rcv:readWORD()               --当前用户
    cardDataMgr.cardSend.wReplaceUser   = rcv:readWORD()               --补牌用户
    cardDataMgr.cardSend.bLianZhuangCount = rcv:readByte()             --连庄
    cardDataMgr.huaNum[1]      = rcv:readByte()
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
    cardDataMgr.currentClient = dataMgr.chair[cardDataMgr.cardSend.wCurrentUser + 1]

    --所有人都发14字节，非庄家14字节无效
    for i=1, 13 do
        cardDataMgr.handValues[i] = rcv:readByte()
       -- print("cardValues "..handValues[i])
    end

    local drawValue = rcv:readByte()
    if clientBankId ~= 1 then
        drawValue = 0
    end

    for i=1, cardDataMgr.huaNum[1] do
        cardDataMgr.huaValue[1][i] = rcv:readByte()
        --print("HuaValues "..cardDataMgr.cardSend.cbHuaCardData[i])
    end
   

   --获取东南西北（1， 2， 3， 4),下标为客户端ID
    dataMgr.direction[clientBankId] = 1
    local index = clientBankId
    for i=2,4 do
        index = index - 1
        if index < 1 then
            index = 4
        end
        dataMgr.direction[index] = i
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
    cardZhua.wCurrentUser = rcv:readWORD()  
    cardZhua.wReplaceUser = rcv:readWORD()
    cardZhua.wSendCardUser= rcv:readWORD()
    cardZhua.cbCardData   = rcv:readByte()
    cardZhua.cbActionMask = rcv:readByte()
    cardZhua.cbHuaCount   = rcv:readByte()

    cardZhua.cbHuaCardData = {}
    for i=1, cardZhua.cbHuaCount do
        cardZhua.cbHuaCardData[i] = rcv:readByte()
    end

    rcv:destroys()
    cardMgr:drawCard(cardZhua)
end

return NetWorkGame