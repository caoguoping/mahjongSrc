

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
    print("Game:Main "..wMainCmd..", Sub "..wSubCmd)
    
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
            self:connectGameFail(rcv) 
        --加入时房间验证失败
        elseif wSubCmd == 103 then
            self:joinRoomFail(rcv) 
        
        --创建房间成功
        elseif wSubCmd == 104 then
            self:createRoom(rcv) 
        end

    elseif wMainCmd == 3 then
        --坐下
        if wSubCmd == 102 then
            self:changeState(rcv)
        --来人
        elseif wSubCmd == 100 then
            self:playerCome(rcv) 
        --房主， 在第一个3， 100之后
        elseif wSubCmd == 107 then
            self:whoIsFangzhu(rcv) 
        --房间配置
        elseif wSubCmd == 108 then
            self:getroomSet(rcv)
             print("\n\n getroomSet \n\n")

        elseif wSubCmd == 351 then
            self:propChange(rcv)
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
            elseif wSubCmd == 113 then
                self:moneyChange(rcv) 
            elseif wSubCmd == 114 then
            -----游戏结束后，获取游戏结束状态标志,游戏开始前需要将GameOverState置0
                dataMgr.GameOverState = rcv:readByte() 
            elseif wSubCmd == 115 then
                cardDataMgr.cardSend.isBiXiaHu      = rcv:readByte()               --1：比下胡  
        end 

        --114 ,byte  1,正常v,    2， 游戏中退出，    3， 结算退出

    --
    end
end

function NetWorkGame:propChange( rcv )
    local userId = rcv:readDWORD()
    local wIndex = rcv:readWORD()   --  //道具ID
    local wCount = rcv:readWORD()   --  //道具数量
    local wFlag = rcv:readWORD()   --      //1-增加 2 - 减少
    if wFlag == 1 then   --退房卡时已经断开socket， 收不到了
        -- dataMgr.prop[wIndex] = dataMgr.prop[wIndex] + wCount
        -- print("wIndex", wIndex, wCount, wFlag)
    elseif wFlag == 2 then   
        dataMgr.prop[wIndex] = dataMgr.prop[wIndex] - wCount
        print("wIndex", wIndex, wCount, wFlag)
    end
    
end

--杠牌或罚分等金钱变化
function NetWorkGame:moneyChange(rcv)
    local playLayer = layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params)
    local score = {}
    for i=1,4 do
        score[i] = rcv:readUInt64()
        print("\nscore  "..score[i].." i "..i)
        if score[i] > 0 then
            playLayer:createScoreChange(i, 1, score[i])
        elseif score[i] < 0 then 
            playLayer:createScoreChange(i, 0, score[i])
        end
    end
end


---一场游戏结束后，向HistroyRecords[]表插入记录
function NetWorkGame:GameOverInsterData()
    print("GAME OVER INSTER MY DATA",dataMgr.ThisTableRecords)
        local AllNum = {} ---计算玩家的总分
        for i=1,4 do
            AllNum[i] = {}
            AllNum[i].dwUserID = 0
            AllNum[i].lScore = 0   
        end
        ---获取数据条数，即是多少局
        local Hcount = 0
		for k,v in ipairs(dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records) do  
		Hcount = Hcount + 1
		end
       -- print("GAME OVER INSTER MY DATA",Hcount)
        ---将Records表里面的数据导入到AllNum{},并且对积分累加，算总
        for i=1,Hcount do
            local hhhcount = 0
		    for k,v in ipairs(dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[i]) do  
		    hhhcount = hhhcount + 1
		    end
           -- print("hhhcount::::::::::",hhhcount)
            AllNum[1].dwUserID = dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[i].dwUserID1
            AllNum[1].lScore = AllNum[1].lScore + dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[i].lScore1         
            AllNum[2].dwUserID = dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[i].dwUserID2
            AllNum[2].lScore = AllNum[2].lScore + dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[i].lScore2          
            AllNum[3].dwUserID = dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[i].dwUserID3
            AllNum[3].lScore = AllNum[3].lScore + dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[i].lScore3           
            AllNum[4].dwUserID = dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[i].dwUserID4
            AllNum[4].lScore = AllNum[4].lScore + dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[i].lScore4
        end
        --- 根据本人的userid_        dataMgr.myBaseData.dwUserID，获取该场次本人游戏的总积分
        local MyAllScore = 0
        for i = 1,4 do
            if AllNum[i].dwUserID == dataMgr.myBaseData.dwUserID then
                -- print("i:",i)
                -- print("dwUserID:",AllNum[i].dwUserID)
                -- print("myBaseData.dwUserID:",dataMgr.myBaseData.dwUserID)
                MyAllScore = AllNum[i].lScore
                --print("myBaseData.MyAllScore:",AllNum[i].lScore)
            end
        end
        
        ---获取结束时间
        dataMgr.HistroyRecords[dataMgr.ThisTableRecords].wData = os.time()
        --print("myBaseData.wData:",dataMgr.HistroyRecords[dataMgr.ThisTableRecords].wData)
        ---获取房间号
        dataMgr.HistroyRecords[dataMgr.ThisTableRecords].wTableID = dataMgr.roomSet.dwRoomNum
       -- print("myBaseData.wTableID:",dataMgr.HistroyRecords[dataMgr.ThisTableRecords].wTableID)
        ---获取模式1、进园子2、敞开怀
        dataMgr.HistroyRecords[dataMgr.ThisTableRecords].cbType = dataMgr.roomSet.bIsJinyunzi
       -- print("myBaseData.cbType:",dataMgr.HistroyRecords[dataMgr.ThisTableRecords].cbType)
        ---获取客户端玩家的总分
        dataMgr.HistroyRecords[dataMgr.ThisTableRecords].lScore = MyAllScore
       -- print("myBaseData.lScore:",dataMgr.HistroyRecords[dataMgr.ThisTableRecords].lScore)
         ---一场游戏结束后，代表HistroyRecords表增加一条新的记录，ThisTableRecords=0重置，下局开始之前无数据
        dataMgr.ThisTableRecords = 0
        dataMgr.HistroyRecords.ItemCount = dataMgr.HistroyRecords.ItemCount + 1
       -- print("dataMgr.HistroyRecords.ItemCount",dataMgr.HistroyRecords.ItemCount)
       -- print("OVER INSTER MY DATA",dataMgr.ThisTableRecords)
end
--谁是房主
function NetWorkGame:whoIsFangzhu( rcv )
    local userId = rcv:readDWORD()
    dataMgr.fangzhuSvr = dataMgr:getSvrIdByUserId(userId)
    print("who is Fangzhu "..dataMgr.fangzhuSvr)
    rcv:destroys()

    local fangzhuClient = dataMgr.chair[dataMgr.fangzhuSvr] 
    local playLayer = layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params)
    playLayer.imgFangzhu[fangzhuClient]:setVisible(true)   --显示房主


    if  dataMgr.chair[dataMgr.fangzhuSvr] == 1  then    --我是是房主
        playLayer.btnDisRoom:setVisible(true)
    else
        playLayer.btnDisRoom:setVisible(false)
    end

end

--获取房间配置,  房主不发
function NetWorkGame:getroomSet( rcv )
    dataMgr.roomSet.wScore = rcv:readWORD()   --100\200\300\400 


    dataMgr.roomSet.wJieSuanLimit = rcv:readWORD()  --0无限制、100\200\300
    dataMgr.roomSet.wBiXiaHu = rcv:readWORD()      ---比下胡
    dataMgr.roomSet.bGangHouKaiHua = rcv:readByte()  --0翻倍\1加200花
    dataMgr.roomSet.bZaEr = rcv:readByte()    --0不砸2、1砸二
    dataMgr.roomSet.bFaFeng = rcv:readByte()  --0不罚、1罚-
    dataMgr.roomSet.bYaJue = rcv:readByte()    --0不压绝、1压
    dataMgr.roomSet.bJuShu = rcv:readByte()     --1:1圈、2:2圈、4:4圈 
    dataMgr.roomSet.bIsJinyunzi = rcv:readByte() --1：进园子、2：敞开怀
    print("getroomSet "..dataMgr.roomSet.wScore.."  "..dataMgr.roomSet.bJuShu.."  "..dataMgr.roomSet.bIsJinyunzi)

    -- for i=1,4 do
    --     dataMgr.onDeskData[i].LeftMoney = dataMgr.roomSet.wScore       --剩余钱
    -- end
    local playLayer = layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params)
    playLayer:showJushuAndJinyunzi()



end

function NetWorkGame:connectGameFail( rcv )
    TTSocketClient:getInstance():closeMySocket(netTb.SocketType.Game)
    local popupbox =  import(".popUpBox",CURRENT_MODULE_NAME).create() 
    popupbox:setInfo(Strings.connectGameFail)
    local btnOk, btnCancel  = popupbox:getBtns()
    btnOk:onClicked(function (  )
    popupbox:remove()
    end)
    btnCancel:onClicked(function (  )
    popupbox:remove()
    end)
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

    rcv:destroys()
    print("joinRoomFail(rcv)")
end


--补花个数
function NetWorkGame:getAllBuhua( rcv )
    for i=1,4 do
        cardDataMgr.huaNum[dataMgr.chair[i]]  =  rcv:readByte()
       -- print("getAllBuhua "..cardDataMgr.huaNum[dataMgr.chair[i]])
    end
    rcv:destroys()
end

--胡牌数据（200， 106）
function NetWorkGame:huPai( rcv )
     --1     小局结束
     -------------GameOverState=2，游戏正常结束，弹出总结算界面
     -------------GameOverState=3，游戏进行中，玩家逃跑，弹出总计界面
    if dataMgr.GameOverState == 2 or  dataMgr.GameOverState == 3 then
         dataMgr.isNormalEnd = false
    end

     local gameEndData = {}
     print("dataMgr.GameOverState:::::",dataMgr.GameOverState)
    ----------GameOverState=3,游戏结算时，玩家退出游戏，此时，不用再接取数据
    if  dataMgr.GameOverState == 1 or dataMgr.GameOverState == 2 or dataMgr.GameOverState == 3 then
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
            dataMgr.onDeskData[i].LeftMoney = dataMgr.onDeskData[i].LeftMoney + gameEndData.lGameScore[i]   --总的剩余钱
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
            --print("huapai count "..gameEndData.cbHuaCardCount[i])
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
               -- print(" "..gameEndData.cbCardData[i][j])   

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
               -- print(" i "..i.." j "..j.." cbCardGang "..gameEndData.cbCardGang[i][j])   
            end
        end
        gameEndData.wProvideUser = rcv:readWORD()
        gameEndData.cbProvideCard = rcv:readByte()
        dataMgr.playerStatus = 2    --游戏结束


        ----一局游戏结算后，将结算数据存入对应战绩表-----------
        ---------获取的值存入HistroyRecords.Records{}中
        dataMgr.ThisTableRecords = dataMgr.HistroyRecords.ItemCount + 1
       -- print("star inster a data",dataMgr.ThisTableRecords)
        if dataMgr.HistroyRecords[dataMgr.ThisTableRecords] == nil then
            dataMgr.HistroyRecords[dataMgr.ThisTableRecords] = {}
        end
        if dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records == nil then
                dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records = {}
        end
        ------检查该表是否有数据
		local Hcount = 0
		for k,v in ipairs(dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records) do  
		Hcount = Hcount + 1
		end
        --print("Hcount",Hcount)
        if dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[Hcount + 1] == nil then
                dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[Hcount + 1] = {}
        end   
        -----根据服务器ID：0123，获取 onDeskData{}中对应玩家的userid、username      
        dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[Hcount + 1].username1 = dataMgr.onDeskData[1].szNickName
        dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[Hcount + 1].dwUserID1 = dataMgr.onDeskData[1].dwUserID
        dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[Hcount + 1].username2 = dataMgr.onDeskData[2].szNickName
        dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[Hcount + 1].dwUserID2 = dataMgr.onDeskData[2].dwUserID
        dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[Hcount + 1].username3 = dataMgr.onDeskData[3].szNickName
        dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[Hcount + 1].dwUserID3 = dataMgr.onDeskData[3].dwUserID
        dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[Hcount + 1].username4 = dataMgr.onDeskData[4].szNickName
        dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[Hcount + 1].dwUserID4 = dataMgr.onDeskData[4].dwUserID
        ---------------------获取积分
        dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[Hcount + 1].lScore1 = gameEndData.lGameScore[1]
        dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[Hcount + 1].lScore2 = gameEndData.lGameScore[2]
        dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[Hcount + 1].lScore3 = gameEndData.lGameScore[3]
        dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[Hcount + 1].lScore4 = gameEndData.lGameScore[4]
        -- print("HistroyRecords.Records.name",dataMgr.HistroyRecords[dataMgr.ThisTableRecords].Records[Hcount + 1].username1)
        -- print(dataMgr.onDeskData[1].szNickName)
        -- print(dataMgr.onDeskData[1].dwUserID)
        -- print(dataMgr.onDeskData[2].szNickName)
        -- print(dataMgr.onDeskData[2].dwUserID)
        -- print(dataMgr.onDeskData[3].szNickName)
        -- print(dataMgr.onDeskData[3].dwUserID)
        -- print(dataMgr.onDeskData[4].szNickName)
        -- print(dataMgr.onDeskData[4].dwUserID)
        -- ---------------------获取积分
        --  print(gameEndData.lGameScore[1])
        --  print(gameEndData.lGameScore[2])
        --  print(gameEndData.lGameScore[3])
        --  print(gameEndData.lGameScore[4])
        --  print("over inster a data")
        ---------------------
    end
----------------------弹出一局游戏结算 与总结算界面的判断
    -- print("::::::::::::::All Games is over ::::::::::::::::::::",dataMgr.isNormalEnd)
    --print(type(dataMgr.isNormalEnd))
   -- print("aaaabbbb")
   -- print(dataMgr.isNormalEnd)
    if not dataMgr.isNormalEnd then
        --弹出总结算界面
        ---调用一场游戏结束后，向HistroyRecords[]表插入记录的函数
        print("stepInto isNormalEnd not allGame")
        self:GameOverInsterData()
        dataMgr.RankShareIdex = dataMgr.HistroyRecords.ItemCount

        -- local delay1  = cc.DelayTime:create(3.0)
        -- local action = cc.Sequence:create(delay1 , cc.CallFunc:create(
        --     function ()
        --         if(layerMgr.boxes[layerMgr.boxIndex.JiesuanBox] ~= nil) then
        --             layerMgr.boxes[layerMgr.boxIndex.JiesuanBox]:removeFromParent()
        --             layerMgr.boxes[layerMgr.boxIndex.JiesuanBox] = nil
        --         end
        --         layerMgr.boxes[layerMgr.boxIndex.RankShareBox] = import(".RankShareBox",CURRENT_MODULE_NAME).create() 
        --     end))
        -- self:runAction(action) 

        layerMgr.boxes[layerMgr.boxIndex.RankShareBox] = import(".RankShareBox",CURRENT_MODULE_NAME).create() 
    else
    ------弹出一局游戏结算
        print("stepInto one game")
        local playLayer = layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params)
        playLayer:huPai(gameEndData)
    end
    rcv:destroys()  

end

--等待操作，碰杠胡
function NetWorkGame:waitOption( rcv )
    rcv:readWORD()
    local bActionMask = rcv:readByte()
    local bActionCard = rcv:readByte()
    rcv:destroys()

    --print(" waitOption "..bActionMask.."  "..bActionCard)
    layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params):waitOption(bActionMask, bActionCard)
end


--操作返回，碰杠胡
function NetWorkGame:optionResult(rcv  )
    local optResult = {}
    optResult.wOperateUser  = rcv:readWORD()
    optResult.wProvideUser  = rcv:readWORD()
    optResult.cbOperateCode = rcv:readByte()
    optResult.cbOperateCard = rcv:readByte()
    rcv:destroys()

    layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params):optionResult(optResult)
    
end


--房间连接成功创建，
function NetWorkGame:connectSuccessCreate( rcv )
    -- local mainLayer = layerMgr:getLayer(layerMgr.layIndex.MainLayer)
    -- mainLayer:showCreateRoom()
    layerMgr.boxes[layerMgr.boxIndex.CreateRoomBox]:sendCreateRoom()
    --print("\n\n connectSuccessCreate OK!")
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
        layerMgr:removeBoxes(layerMgr.boxIndex.CreateRoomBox)
        layerMgr:showLayer(layerMgr.layIndex.PlayLayer, params)
        local playLayer = layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params)
        playLayer:showJushuAndJinyunzi()
        playLayer:JoinInit()
    end




end




--解散房间，发送 3, 12,   （4个2 ，发准备，状态2变1（走掉一个），  
--创建房间者  1个字节    （出来 1，  进去 2）    发送 3，13，   


--状态变化   1:起立，  2， 坐下，   3， 准备，   
--3, 102,   桌子号为0xFFFF,房间解散
function NetWorkGame:changeState( rcv )
    local dwUserId = rcv:readDWORD()
    local wTableId = rcv:readWORD()
    local wChairId = rcv:readWORD()   --椅子ID 0 - 3
    local cbUserStatus = rcv:readByte()
    rcv:destroys()

    print("dwUserID "..dwUserId.." wTableID "..wTableId.." wChair "..wChairId.." status "..cbUserStatus)

    if dataMgr.playerStatus == 0 then
        local playlayer = layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params)
        if dataMgr.myBaseData.dwUserID == dwUserId and cbUserStatus == 2 then
            --me changeState ,fresh data
            --加入房间时，显示房间
            if dataMgr.roomSet.bIsCreate == 0 then

                layerMgr:removeBoxes(layerMgr.boxIndex.JoinRoomBox)
                layerMgr:showLayer(layerMgr.layIndex.PlayLayer, params)
               
                playlayer:JoinInit() 
            end
        end

        if cbUserStatus == 3 then   --准备状态
            local clientId =  dataMgr.chair[wChairId + 1]
            playlayer.imgReady[clientId]:setVisible(true)
        end
        

        --退出房间与加入房间相反，每个人的退出都会群发，
        if wTableId == 65535 then    --有人退出
            if dataMgr.myBaseData.dwUserID == dwUserId then     --自己退出
                TTSocketClient:getInstance():closeMySocket(netTb.SocketType.Game) 
                layerMgr:showLayer(layerMgr.layIndex.MainLayer, params)
--                musicMgr:playMusic("bg.mp3", true)
            else   --其他人退出
                local svrChairId = dataMgr:getSvrIdByUserId(dwUserId)   --[1,4]
                playlayer:showPlayer(svrChairId, false)
                dataMgr.onDeskData[svrChairId].dwUserID = 0
            end

        else   --房主暂时返回房间
            --房主起立了
            if cbUserStatus == 1 then
               -- print()
                playlayer:showPlayer(wChairId + 1, false)
            end 
            --房主回来了
            if cbUserStatus == 2  and  dataMgr.onDeskData[wChairId + 1].dwUserID ~= 0  then
                playlayer:showPlayer(wChairId + 1, true)
            end


        end


    end

end

--3, 100,  
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

    dataMgr.onDeskData[svrChair].lScore        = rcv:readUInt64()
    dataMgr.onDeskData[svrChair].lGrade        = rcv:readUInt64()
    dataMgr.onDeskData[svrChair].lInsure       = rcv:readUInt64()
    dataMgr.onDeskData[svrChair].dwWinCount    = rcv:readDWORD()
    dataMgr.onDeskData[svrChair].dwLostCount   = rcv:readDWORD()
    dataMgr.onDeskData[svrChair].dwDrawCount   = rcv:readDWORD()
    dataMgr.onDeskData[svrChair].dwFleeCount   = rcv:readDWORD()
    dataMgr.onDeskData[svrChair].dwUserMedal   = rcv:readDWORD()
    dataMgr.onDeskData[svrChair].dwExperience  = rcv:readDWORD()
    dataMgr.onDeskData[svrChair].lLoveLiness   = rcv:readDWORD()
    dataMgr.onDeskData[svrChair].nick1         = rcv:readWORD()  
    dataMgr.onDeskData[svrChair].nick2         = rcv:readWORD()
    dataMgr.onDeskData[svrChair].szNickName    = rcv:readString(dataMgr.onDeskData[svrChair].nick1)
   -- print("\n\n"..dataMgr.onDeskData[svrChair].szNickName)
    local nick3       = rcv:readWORD()  
    local nick4          = rcv:readWORD()   
    dataMgr.onDeskData[svrChair].szImgUrl    = rcv:readString(nick3)
    -- print(nick3)
    -- print(nick4)
    -- print(dataMgr.onDeskData[svrChair].szImgUrl)

    rcv:destroys()

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
            --print("dataMgr.chair "..dataMgr.chair[index])
        end
    end

    --下载头像，显示来人
    local xmlHttpReq = cc.XMLHttpRequest:new()
    dataMgr:getUrlImgByClientId(xmlHttpReq, dataMgr.chair[svrChair], dataMgr.onDeskData[svrChair].szImgUrl,
    function ()
        if xmlHttpReq.readyState == 4 and (xmlHttpReq.status >= 200 and xmlHttpReq.status < 207) then
            local fileData = xmlHttpReq.response
            local fullFileName = cc.FileUtils:getInstance():getWritablePath()..xmlHttpReq._urlFileName
            --print("LUA-print"..fullFileName)
            local file = io.open(fullFileName,"wb")
            file:write(fileData)
            file:close()
            layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params):showPlayer(svrChair, true)
        end
    end
    )
    --dataMgr:getUrlImgByClientId(dataMgr.chair[svrChair], dataMgr.onDeskData[svrChair].szImgUrl)



end

--发牌
function NetWorkGame:sendCard( rcv )

    dataMgr.isNormalEnd = true   --t弹小聚结算界面

    cardDataMgr.cardSend.wBankerUser    = rcv:readWORD()               --庄家用户
    cardDataMgr.cardSend.wCurrentUser   = rcv:readWORD()               --当前用户
    cardDataMgr.cardSend.wReplaceUser   = rcv:readWORD()               --补牌用户
    cardDataMgr.cardSend.bLianZhuangCount = rcv:readByte()             --连庄
    cardDataMgr.huaNum[1]      = rcv:readByte()
    cardDataMgr.cardSend.bSice1         = rcv:readByte()   
    cardDataMgr.cardSend.bSice2         = rcv:readByte()
    cardDataMgr.cardSend.cbUserAction   = rcv:readByte()               --用户动作
    -- print("cardDataMgr.cardSend.wBankerUser   "..cardDataMgr.cardSend.wBankerUser )
    -- print("cardDataMgr.cardSend.wCurrentUser  "..cardDataMgr.cardSend.wCurrentUser)
    -- print("cardDataMgr.cardSend.wReplaceUser  "..cardDataMgr.cardSend.wReplaceUser)
    -- print("cardDataMgr.cardSend.bSice1        "..cardDataMgr.cardSend.bSice1      )
    -- print("cardDataMgr.cardSend.bSice2        "..cardDataMgr.cardSend.bSice2      )
    -- print("cardDataMgr.cardSend.cbUserAction  "..cardDataMgr.cardSend.cbUserAction)

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

    print("----------------------------------------------\n\n")
    print("------------------------- new -------------------------")
    print("-------------------------------------------------------")



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