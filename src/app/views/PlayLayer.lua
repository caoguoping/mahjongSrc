--  打牌--
local CURRENT_MODULE_NAME = ...
local dataMgr     = import(".DataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()
local cardMgr = import(".CardManager"):getInstance()
local cardDataMgr = import(".CardDataManager"):getInstance()


-- fileNode  1:me,   2:left,    3:up,     4:right



local PlayLayer = class("PlayLayer", display.newLayer)
function PlayLayer:ctor()

--test
--all Node
    local rootNode = cc.CSLoader:createNode("playScene.csb"):addTo(self)
    self.rootNode = rootNode
    cardMgr:initAllNodes(self)
--bg
    self.deskBgNode  = rootNode:getChildByName("FileNode_deskBg")
    self.imgLight= {}
    self.imgFeng = {}
    self.imgNowFeng = {}
    for i=1,4 do
        local imgName = "Image_light_"..i
        local imgName1 = "Image_feng"..i
        local imgName2 = "Image_nowFeng"..i
        self.imgLight[i] = self.deskBgNode:getChildByName(imgName)
        self.imgFeng[i] = self.deskBgNode:getChildByName(imgName1)
        self.imgNowFeng[i] = self.deskBgNode:getChildByName(imgName2)
    end
    self.txtClock = self.deskBgNode:getChildByName("AtlasLabel_clock")
    self.nodeShezi = self.deskBgNode:getChildByName("FileNode_shezi")
    self.imgShezi1 = self.nodeShezi:getChildByName("Image_1")
    self.imgShezi2 = self.nodeShezi:getChildByName("Image_2")
    --self.clock:setString("0"..8)

--ui
    self.deskUiNode  = rootNode:getChildByName("FileNode_deskUi")
    self.btnActions = {}
    local btnClose = self.deskUiNode:getChildByName("Button_Close")
    btnClose:onClicked(
        function ()
        layerMgr:showLayer(layerMgr.layIndex.MainLayer, params)
        TTSocketClient:getInstance():closeMySocket(netTb.SocketType.Game)
        end)

    self.headNode = {}  --头像节点
    self.txtScore = {}  --总积分
    self.txtSvrChair = {}  --服务器椅子ID，测试用
    self.imgHead = {}   --头像

    for i=1,4 do
        local strName = "FileNode_"..i
        self.headNode[i] = self.deskUiNode:getChildByName(strName)
        self.txtScore[i] = self.headNode[i]:getChildByName("Text_score")
        self.txtSvrChair[i] = self.headNode[i]:getChildByName("Text_svrId")
        self.imgHead[i] = self.headNode[i]:getChildByName("Image_head")
        --local svrId = dataMgr:getServiceChairId(i)
        self.imgHead[i]:loadTexture("test"..i..".png")
    end


--剩余牌
    self.txtLeftCard = self.deskUiNode:getChildByName("Text_leftCard")
    self.imgLeftCard = self.deskUiNode:getChildByName("Image_leftCard")

    --花
    self.huaNode = {}
    self.txtHuaNum = {}
    for i=1,4 do
        local strTmp = "FileNode_hua_"..i
        self.huaNode[i] = self.deskUiNode:getChildByName(strTmp)
        self.txtHuaNum[i] = self.huaNode[i]:getChildByName("Text_num")
    end
--碰杠听胡过btn
    for i=1,5 do
        local strName = "Button_"..i
        self.btnActions[i] = self.deskUiNode:getChildByName(strName)
    end
    self.btnActions[1]:onClicked(
        function (  )
            for i=1,5 do
                self.btnActions[i]:setVisible(false)
            end
            local snd = DataSnd:create(200, 3)
            snd:wrByte(1)     --0x01
            snd:wrByte(self.actCard)
            snd:wrByte(self.actCard)
            snd:wrByte(self.actCard)
            snd:sendData(netTb.SocketType.Game)
            snd:release(); 
            self:stopClock()          
        end
        )

    --杠
    self.btnActions[2]:onClicked(
        function (  )
            for i=1,5 do
                self.btnActions[i]:setVisible(false)
            end
            local snd = DataSnd:create(200, 3)
            snd:wrByte(self.gangSaveValue)     --保存过的
            snd:wrByte(self.actCard)
            snd:wrByte(self.actCard)
            snd:wrByte(self.actCard)
            snd:sendData(netTb.SocketType.Game)
            snd:release();
            self:stopClock()              
        end
        )

    --听
    self.btnActions[3]:onClicked(
        function (  )
            for i=1,5 do
                self.btnActions[i]:setVisible(false)
            end
            local snd = DataSnd:create(200, 2)
            local svrChairId = dataMgr:getServiceChairId(1)
            snd:wrByte(svrChairId)     --任何一个字节
            snd:sendData(netTb.SocketType.Game)
            snd:release();  
            self:stopClock()           
        end
        )

    --胡
    self.btnActions[4]:onClicked(
        function (  )

            for i=1,5 do
                self.btnActions[i]:setVisible(false)
            end
            local snd = DataSnd:create(200, 3)
            snd:wrByte(32)      --0x20
            snd:wrByte(self.actCard)
            snd:wrByte(self.actCard)
            snd:wrByte(self.actCard)
            print("\n hu card "..self.actCard)
            snd:sendData(netTb.SocketType.Game)
            snd:release(); 
            self:stopClock()            
        end
        )

    --过
    self.btnActions[5]:onClicked(
        function (  )
            for i=1,5 do
                self.btnActions[i]:setVisible(false)
            end
            self.btnActions[5]:setVisible(false)
            local snd = DataSnd:create(200, 3)
            snd:wrByte(0)    --0x00
            snd:wrByte(0)
            snd:wrByte(0)
            snd:wrByte(0)
            snd:sendData(netTb.SocketType.Game)
            snd:release();
            self:stopClock()             
        end

        )


--invite 邀请好友界面
    self.inviteNode = rootNode:getChildByName("FileNode_invite")
    self.txtRoomNum = self.inviteNode:getChildByName("Text_room")


end
  
function PlayLayer.create()
    return PlayLayer.new()
end

--点击创建按钮,更新界面和数据
function PlayLayer:createRefresh(  )
    for i=1,4 do
        self.imgLight[i]:setVisible(false)
        self.imgFeng[i]:setVisible(false)
        self.imgNowFeng[i]:setVisible(false)
        self.headNode[i]:setVisible(false)
        self.huaNode[i]:setVisible(false)
    end

    cardMgr:hideAllCards()
    cardDataMgr:refresh()

    for i=1,5 do
        self.btnActions[i]:setVisible(false)
    end
    self.imgLeftCard:setVisible(false)
    self.txtLeftCard:setVisible(false)
    cardMgr.imgTouchCard:setTouchEnabled(false)
end

--每局重新开始,更新界面和数据
function PlayLayer:refresh( )
    -- for i=1,4 do
    --     self.imgLight[i]:setVisible(false)
    --     self.imgFeng[i]:setVisible(false)
    --     self.imgNowFeng[i]:setVisible(false)
    --     self.headNode[i]:setVisible(false)
    -- end

    cardMgr:hideAllCards()
    cardMgr:removeHandCards()
    cardDataMgr:refresh()

    for i=1,5 do
        self.btnActions[i]:setVisible(false)
    end
    --self.imgLeftCard:setVisible(false)
    --self.txtLeftCard:setVisible(false)



end

--等待其他人加入，在自己进去之后，收到
function PlayLayer:waitJoin()

    self.nodeShezi:setVisible(false)
    self.inviteNode:setVisible(true)
    
    self.txtRoomNum:setString(string.format("%07d", dataMgr.roomSet.dwRoomNum))

--cgpTest


end

--显示进来人
function PlayLayer:showPlayer(svrChairId )  
    dataMgr.joinPeople = dataMgr.joinPeople + 1
    
    local clientId = dataMgr.chair[svrChairId + 1]
    --print("\n\nclientId   "..clientId)
    self.headNode[clientId]:setVisible(true)

--test for name
    self.txtSvrChair[clientId]:setString(tostring(svrChairId + 1))
    --self.txtScore[clientId]:setString(tostring(svrChairId + 1))
    --self.txtScore[clientId]:setString(tostring(dataMgr.onDeskData[svrChairId].lScore))
   -- self.imgHead[clientId]:loadTexture("headshot_"..clientId..".png")

    if dataMgr.joinPeople == 4 then
        --todo
    end

end

--起牌
function PlayLayer:qiPai()

        local bankClient = 3
        local delay1  = cc.DelayTime:create(0.3)
           
        local action = cc.Sequence:create(delay1 , cc.CallFunc:create(
            function ()
                for i=1, 53 do
                    cardMgr.wallCell[i]:setVisible(false)
                end

                -- cardMgr.wallCell[55]:setVisible(false)
                -- cardMgr.wallCell[54]:setVisible(false)
                for i=1,4 do
                    cardMgr.stndNode[i]:setVisible(true)
                end

                cardDataMgr.totalOutNum = 53


            end))

        self:runAction(action)    
end

--胡牌
function PlayLayer:huPai(gameEndData)
    local jiesuanBox = import(".JiesuanBox",CURRENT_MODULE_NAME).create()
    jiesuanBox:initData(gameEndData)
    layerMgr.boxes[layerMgr.boxIndex.JiesuanBox] = jiesuanBox

    --清理手牌
    self:refresh()
end


--发牌
function PlayLayer:sendCard(drawValue)

   --一开始就禁止触摸
    cardMgr.imgTouchCard:setTouchEnabled(false)
    self.nodeShezi:setVisible(true)
    self.imgShezi1:setVisible(false)
    self.imgShezi2:setVisible(false)
    local timeLineShezi = cc.CSLoader:createTimeline("shezi.csb")
    self:runAction(timeLineShezi)
    timeLineShezi:gotoFrameAndPlay(0, false)
    timeLineShezi:setLastFrameCallFunc(
        function ()
            self.imgShezi1:setVisible(true)
            self.imgShezi2:setVisible(true)
            self.imgShezi1:loadTexture("sezi_value"..cardDataMgr.cardSend.bSice1..".png")
            self.imgShezi2:loadTexture("sezi_value"..cardDataMgr.cardSend.bSice2..".png")
            self:qiPai()    --起牌在掷骰子动画后执行
            local delay = cc.DelayTime:create(1.0)
            local action = cc.Sequence:create(delay, cc.CallFunc:create(
                function (  )
                    self.imgShezi1:setVisible(false)
                    self.imgShezi2:setVisible(false)

                    --补花
                    for i=1,4 do
                        self.huaNode[i]:setVisible(true)
                        self.txtHuaNum[i]:setString(cardDataMgr.huaNum[i])     --补花
                        --总牌
--                        cardDataMgr.totalOutNum = cardDataMgr.totalOutNum + cardDataMgr.huaNum[i]   --总牌加上补花
                    end
                    self.txtLeftCard:setString(tostring(144 - cardDataMgr.totalOutNum))  --剩余牌
                    
                    cardMgr:inithandCards(drawValue)
                    print("\n\n mySvrId  "..(dataMgr:getServiceChairId(1) + 1) )

                end))
            self:runAction(action)
        end
      )

    self.inviteNode:setVisible(false)
    for i=1,4 do
        cardMgr.wallNode[i]:setVisible(true)
    end

-- --堆牌重新赋值
    --堆牌
    local sice1 = cardDataMgr.cardSend.bSice1
    local sice2 = cardDataMgr.cardSend.bSice2
    local startDir = math.min(sice1, sice2)
    local theSum = sice1 + sice2
    local startIndex = (startDir - 1) * 36 + (theSum - 1) * 2  --相当于0
    for  i = 1,4 do
        for j = 1,36 do
            local imgName = "Image"..j
            local realPos = ((i - 1) * 36 + j - startIndex + 144) % 144
            if realPos == 0 then
                realPos = 144
            end
            cardMgr.wallCell[realPos] =  cardMgr.wallNode[i]:getChildByName(imgName)
            --print(realPos.." ")
        end
    end
    for i=1,144 do
        cardMgr.wallCell[i]:setVisible(true)
    end

--剩余牌
    self.imgLeftCard:setVisible(true)
    self.txtLeftCard:setVisible(true)

--东南西北
    for i=1,4 do
        local strTemp = "feng"..dataMgr.direction[i]..".png"
        local strTemp2 = "nowFeng"..dataMgr.direction[i]..".png"
        self.imgFeng[i]:loadTexture(strTemp)
        self.imgFeng[i]:setVisible(true)
        self.imgNowFeng[i]:loadTexture(strTemp2)
    end

    --我是庄家
    if cardDataMgr.bankClient == 1 then
        self:whichTurn(1)
    else
        self:whichTurn(cardDataMgr.currentClient)
    end

    --天胡，暗杠
    local actOption =  girl.getBitTable( cardDataMgr.cardSend.cbUserAction) 
    self.gangSaveValue = 0
    local haveOption = 0  --  1有操作, 0 没有
    if actOption[3] == 1 then   --暗杠
        playlayer.btnActions[2]:setVisible(true)
        playlayer.gangSaveValue = 4
        haveOption = 1
        playlayer.actCard = self:getAGangValue(drawValue)
    end

    if actOption[6] == 1 then   --自摸
        playlayer.btnActions[4]:setVisible(true)
        haveOption = 1
        playlayer.actCard = drawValue
    end

    if haveOption == 1 then
        playlayer.btnActions[5]:setVisible(true) 
        playlayer:whichTurn(1)
    else
    --没有操作，摸牌后打开触摸
        cardDataMgr.outType = 0  --摸牌
        --self.imgTouchCard:setTouchEnabled(true)
        --playlayer:whichTurn(1)
    end

    
end


--轮到谁打
function PlayLayer:whichTurn( clientId )
    for i=1,4 do
        self.imgLight[i]:setVisible(false)
        self.imgNowFeng[i]:setVisible(false)
    end
    self.imgLight[clientId]:setVisible(true)
    self.imgNowFeng[clientId]:setVisible(true)
    dataMgr.timeLeft = 15
    self.txtClock:setString("15")

    local scheduler = cc.Director:getInstance():getScheduler()
    dataMgr.schedulerID = scheduler:scheduleScriptFunc(
        function()
            self:clockShow()
        end,
    1.0,
    false)  

end

function PlayLayer:stopClock(  )
    print("stopClock")
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(dataMgr.schedulerID) 
     --self:unschedule()
end

function PlayLayer:clockShow( )
    dataMgr.timeLeft = dataMgr.timeLeft - 1
    self.txtClock:setString(tostring(dataMgr.timeLeft))
    --自己的时间结束了
    if dataMgr.timeLeft == 0 then
        self:stopClock()
        if cardDataMgr.currentClient == 1 then
            if cardDataMgr.outType == 0 then
                --cardMgr:outDrawCard(14)   --打最后一张牌 
            else
                --cardMgr:outPengCard(14)
            end


            
        end
    end
    --print(" timeLeft "..dataMgr.timeLeft.." currentClient "..cardDataMgr.currentClient)


end



function PlayLayer:optMePeng(clientOpt, clientPro, optCard)
    local pengGangNum = cardDataMgr.pengGangNum[1]
    --碰的牌起始位置
    local startIndex = girl.getTableSortIndex(cardDataMgr.handValues, optCard) 
    print("optMePeng startIndex "..startIndex)
    local handCount = 13 - pengGangNum * 3    --手牌的张数，没去掉要放下的两张
    --碰要放下的牌
    local saveNode1 = cardMgr.handCards[startIndex]
    local saveNode2 = cardMgr.handCards[startIndex + 1]
    --删除table，
    table.remove(cardMgr.handCards, startIndex)
    table.remove(cardDataMgr.handValues,  startIndex)
    table.remove(cardMgr.handCards, startIndex)  --自动前移一位
    table.remove(cardDataMgr.handValues,  startIndex)
    handCount = handCount - 2
    --修改值
    cardDataMgr.pengGangNum[1] = cardDataMgr.pengGangNum[1] + 1
    cardDataMgr.pengNum[1] = cardDataMgr.pengNum[1] + 1
    cardDataMgr.pengValue[1][cardDataMgr.pengNum[1]] = optCard
    cardDataMgr.outType = 1  --碰牌
--放下的两张牌
    local actionOpen1 = cc.Sequence:create(
        cc.MoveBy:create(0.2, cc.p(0, 113)),
        cc.DelayTime:create(0.2),
        --cc.Hide:create(),
        cc.CallFunc:create(
            function ()
                saveNode1:removeFromParent()
            end
        )
    )
    local actionOpen2 = cc.Sequence:create(
        cc.MoveBy:create(0.2, cc.p(0, 113)),
        cc.DelayTime:create(0.2),
        --cc.Hide:create(),
        cc.CallFunc:create(
            function ()
                 saveNode2:removeFromParent()
            end
        )
    )
    saveNode1:runAction(actionOpen1)
    saveNode2:runAction(actionOpen2)
    -- print("\n before runAction(action)")
    -- for i, v in pairs(cardMgr.handCards) do
    --     print(i, v)
    -- end
     --碰的牌放下后，右边右移1(不含最后一张)
    for i = startIndex, handCount - 1 do
        local action = cc.Sequence:create(
            cc.DelayTime:create(0.2), 
            cc.MoveBy:create(0.2, cc.p(86, 0))
            )
        cardMgr.handCards[i]:runAction(action) 
    end

    --最后一张右移一位
    if  handCount >= startIndex then
        local actionLast = cc.Sequence:create(
                cc.DelayTime:create(0.2), 
                cc.MoveBy:create(0.2, cc.p(86 + 15, 0))
                )
        cardMgr.handCards[handCount]:runAction(actionLast) 
    end
    --碰的牌放下后的左边右移3位
    if startIndex > 1 then
        for i=1, startIndex -1 do
            local action = cc.Sequence:create(
                cc.DelayTime:create(0.2), 
                cc.MoveBy:create(0.2, cc.p(86 * 3, 0))
            )
            cardMgr.handCards[i]:runAction(action) 
        end
    end
--0.4秒后显示桌面的碰牌
    local action2 = cc.Sequence:create( 
        cc.DelayTime:create(0.4), 
        cc.CallFunc:create(
            function ()
                --显示碰牌
                for i=1,3 do
                    cardMgr.pengCell[1][pengGangNum + 1][i]:setVisible(true) 
                    cardMgr.pengCellFace[1][pengGangNum + 1][i]:loadTexture(optCard..".png")
                end

                --掩藏被碰家的一张出牌
                local outNum = cardDataMgr.outNum[clientPro]
                cardMgr.outCell[clientPro][outNum]:setVisible(false)
                cardDataMgr.outNum[clientPro] = outNum - 1


                cardMgr.imgTouchCard:setTouchEnabled(true)     --打开触摸，容许出牌
                --0.4秒后开启定时器和触摸
                local playlayer = layerMgr:getLayer(layerMgr.layIndex.PlayLayer)
                playlayer:whichTurn(1)
            end
        )
    )
    self:runAction(action2)



end

function PlayLayer:optMeMGang(clientOpt, clientPro, optCard)
    local pengGangNum = cardDataMgr.pengGangNum[1]
    --碰的牌起始位置
    local startIndex = girl.getTableSortIndex(cardDataMgr.handValues, optCard) 
    local handCount = 13 - pengGangNum * 3    --手牌的张数，去掉了碰杠和进的一张牌

    local action = cc.Sequence:create(
        cc.MoveBy:create(0.2, cc.p(0, 113)),
        cc.DelayTime:create(0.2),
        cc.Hide:create() 
    )
    cardMgr.handCards[startIndex]:runAction(action)
    cardMgr.handCards[startIndex + 1]:runAction(action)
    cardMgr.handCards[startIndex + 2]:runAction(action)

    local action2 = cc.Sequence:create(
        cc.DelayTime:create(0.2), 
        cc.CallFunc:create(
            function ()
            --左边右移3位
                if startIndex > 1 then
                    for i=1, startIndex -1 do
                        cardMgr.handCards[i]:runAction(cc.MoveBy:create(0.2, cc.p(86*3, 0))) 
                    end
                end
            end
        ),
        cc.DelayTime:create(0.2), 
        cc.CallFunc:create(
            function ()
                --显示明杠牌
                for i=1,4 do
                    cardMgr.pengCell[1][pengGangNum + 1][i]:setVisible(true) 
                    cardMgr.pengCellFace[1][pengGangNum + 1][i]:loadTexture(optCard..".png")
                end
            end
        ),
        cc.DelayTime:create(0.1), 
        cc.CallFunc:create(
            function ()
                --删除牌，修改值
                cardMgr.handCards[startIndex]:removeFromParent()
                cardMgr.handCards[startIndex + 1]:removeFromParent()
                cardMgr.handCards[startIndex + 2]:removeFromParent()
                table.remove(cardMgr.handCards, startIndex)
                table.remove(cardMgr.handCards, startIndex)  --自动前移一位
                table.remove(cardMgr.handCards, startIndex)  --自动前移一位
                table.remove(cardDataMgr.handValues,  startIndex)
                table.remove(cardDataMgr.handValues,  startIndex)
                table.remove(cardDataMgr.handValues,  startIndex)
                cardDataMgr.pengGangNum[1] = cardDataMgr.pengGangNum[1] + 1
                cardDataMgr.gangNum[1] = cardDataMgr.gangNum[1] + 1
                cardDataMgr.gangValue[1][cardDataMgr.gangNum[1]] = optCard

            end
        )
    )
    self:runAction(action2)
end

--暗杠
function PlayLayer:optMeAGang(clientOpt, clientPro, optCard)
        --摸完牌才能暗杠， 杠完再摸一张，再打一张牌，
    local pengGangNum = cardDataMgr.pengGangNum[1]
    --暗杠的牌起始位置，  
    local startIndex = girl.getTableSortIndex(cardDataMgr.handValues, optCard) 
    local handCount = 13 - pengGangNum * 3    --手牌的张数，去掉了碰杠和进的一张牌

--1).已有三张， 摸到第四张
    if cardMgr.cardDraw.cardValue == optCard then
        local action = cc.Sequence:create(
            cc.MoveBy:create(0.2, cc.p(0, 113)),
            cc.DelayTime:create(0.2),
            cc.Hide:create() 
        )
        cardMgr.handCards[startIndex]:runAction(action)
        cardMgr.handCards[startIndex + 1]:runAction(action)
        cardMgr.handCards[startIndex + 2]:runAction(action)
        --移除手牌
        cardMgr.cardDraw:removeFromParent()
        cardMgr.cardDraw = nil

        local action2 = cc.Sequence:create(
            cc.DelayTime:create(0.2), 
            cc.CallFunc:create(
                function ()
                --左边右移3位
                    if startIndex > 1 then
                        for i=1, startIndex -1 do
                            cardMgr.handCards[i]:runAction(cc.MoveBy:create(0.2, cc.p(86*3, 0))) 
                        end
                    end
                end
            ),
            cc.DelayTime:create(0.2), 
            cc.CallFunc:create(
                function ()
                    --显示杠牌
                    for i=1,4 do
                        cardMgr.pengCell[1][pengGangNum + 1][i]:setVisible(true) 
                        cardMgr.pengCellFace[1][pengGangNum + 1][i]:loadTexture(optCard..".png")
                    end
                end
            ),
            cc.DelayTime:create(0.1), 
            cc.CallFunc:create(
                function ()
                    --删除牌，修改值
                    cardMgr.handCards[startIndex]:removeFromParent()
                    cardMgr.handCards[startIndex + 1]:removeFromParent()
                    cardMgr.handCards[startIndex + 2]:removeFromParent()
                    table.remove(cardMgr.handCards, startIndex)
                    table.remove(cardMgr.handCards, startIndex)  --自动前移一位
                    table.remove(cardMgr.handCards, startIndex)  --自动前移一位
                    table.remove(cardDataMgr.handValues,  startIndex)
                    table.remove(cardDataMgr.handValues,  startIndex)
                    table.remove(cardDataMgr.handValues,  startIndex)
                    cardDataMgr.pengGangNum[1] = cardDataMgr.pengGangNum[1] + 1
                    cardDataMgr.gangNum[1] = cardDataMgr.gangNum[1] + 1
                    cardDataMgr.gangValue[1][cardDataMgr.gangNum[1]] = optCard

                end
            )
        )
        self:runAction(action2) 
    else
--已有四张，摸牌时  
        local action = cc.Sequence:create(
            cc.MoveBy:create(0.2, cc.p(0, 113)),
            cc.DelayTime:create(0.2),
            cc.Hide:create() 
        )
        cardMgr.handCards[startIndex]:runAction(action)
        cardMgr.handCards[startIndex + 1]:runAction(action)
        cardMgr.handCards[startIndex + 2]:runAction(action)
        cardMgr.handCards[startIndex + 3]:runAction(action)

        --顺序插进手牌
        cardMgr.cardDraw:removeFromParent()
        cardMgr.cardDraw = nil


        local action2 = cc.Sequence:create(
            cc.DelayTime:create(0.2), 
            cc.CallFunc:create(
                function ()
                --左边右移4位
                    if startIndex > 1 then
                        for i=1, startIndex -1 do
                            cardMgr.handCards[i]:runAction(cc.MoveBy:create(0.2, cc.p(86*4, 0))) 
                        end
                    end
                end
            ),
            cc.DelayTime:create(0.2), 
            cc.CallFunc:create(
                function ()
                    --显示杠牌
                    for i=1,4 do
                        cardMgr.pengCell[1][pengGangNum + 1][i]:setVisible(true) 
                        cardMgr.pengCellFace[1][pengGangNum + 1][i]:loadTexture(optCard..".png")
                    end
                end
            ),
            cc.DelayTime:create(0.1), 
            cc.CallFunc:create(
                function ()
                    --删除牌，修改值
                    cardMgr.handCards[startIndex]:removeFromParent()
                    cardMgr.handCards[startIndex + 1]:removeFromParent()
                    cardMgr.handCards[startIndex + 2]:removeFromParent()
                    cardMgr.handCards[startIndex + 3]:removeFromParent()
                    table.remove(cardMgr.handCards, startIndex)
                    table.remove(cardMgr.handCards, startIndex)  --自动前移一位
                    table.remove(cardMgr.handCards, startIndex)  --自动前移一位
                    table.remove(cardMgr.handCards, startIndex)  --自动前移一位
                    table.remove(cardDataMgr.handValues,  startIndex)
                    table.remove(cardDataMgr.handValues,  startIndex)
                    table.remove(cardDataMgr.handValues,  startIndex)
                    table.remove(cardDataMgr.handValues,  startIndex)
                    cardDataMgr.pengGangNum[1] = cardDataMgr.pengGangNum[1] + 1
                    cardDataMgr.gangNum[1] = cardDataMgr.gangNum[1] + 1
                    cardDataMgr.gangValue[1][cardDataMgr.gangNum[1]] = optCard

                end
            )
        )
        self:runAction(action2)          
    end
end


--获取碰杠牌的index，1， 2， 3， 4
function PlayLayer:getPGangIndex(clientId, pGangValue )
    
    for i=1,#cardDataMgr.pengValue[clientId] do
        if cardDataMgr.pengValue[clientId][i] == pGangValue   then
            return i
        end
    end
end


--自己碰杠操作
function PlayLayer:optMePGang(clientOpt, clientPro, optCard)
    --摸完牌才能碰杠， 杠完再摸一张，再打一张牌，
    --local pengGangNum = cardDataMgr.pengGangNum[1]
    --暗杠的牌起始位置，  
    --local handCount = 13 - pengGangNum * 3    --手牌的张数，去掉了碰杠和进的一张牌
    --删除要杠的牌，  补的一张牌就在后面的一个消息里
--抓的牌就是碰杠的牌
    if cardMgr.cardDraw.cardValue == optCard then
        print("cardMgr.cardDraw.cardValue == optCard "..cardMgr.cardDraw.cardValue.."  "..optCard)
        cardMgr.cardDraw:removeFromParent()
        --显示碰杠的牌，。。。cgpTest
        local pIndex = self:getPGangIndex(1, optCard)
        cardMgr.pengCell[1][pIndex][4]:setVisible(true)
        cardMgr.pengCellFace[1][pIndex][4]:loadTexture(optCard..".png")
    else      --有碰杠没有杠，下次抓牌时,非抓牌的碰杠
        print("cardMgr.cardDraw.cardValue ~= optCard")
        for i=1,#cardMgr.handCards do
            if cardMgr.handCards[i].cardValue == optCard then    --要碰杠的值
                cardMgr.handCards[i]:removeFromParent()
                table.remove(cardMgr.handCards, i ) 
                --右边的左移
                for j=i,#cardMgr.handCards do   --已经删除了一个，
                   cardMgr.handCards[j]:runAction(cc.MoveBy:create(0.2, cc.p(-86, 0))) 
                end
                --抓的牌左移
                cardMgr.cardDraw:runAction(cc.MoveBy:create(0.2, cc.p(-86 - 15, 0)))
                --抓的牌成为手牌
                table.insert(cardMgr.handCards, cardMgr.cardDraw)

                --显示碰杠的牌，。。。cgpTest
                local pIndex = self:getPGangIndex(1, optCard)
                cardMgr.pengCell[1][pIndex][4]:setVisible(true)
                cardMgr.pengCellFace[1][pIndex][4]:loadTexture(optCard..".png")
                break
            end
        end
    end 
end

--其他玩家碰
function PlayLayer:optOtherPeng( clientOpt, clientPro, optCard )

    --开启定时器
    local playlayer = layerMgr:getLayer(layerMgr.layIndex.PlayLayer)
    playlayer:whichTurn(clientOpt)


    local  pengGangNum = cardDataMgr.pengGangNum[clientOpt]   
    cardMgr.stndCell[clientOpt][14]:setVisible(true)
    local startDown = pengGangNum * 3
    for i=startDown + 1, startDown + 3 do
        cardMgr.stndCell[clientOpt][i]:setVisible(false)
    end
    for i=1,3 do
        cardMgr.pengCell[clientOpt][pengGangNum + 1][i]:setVisible(true)
        cardMgr.pengCellFace[clientOpt][pengGangNum + 1][i]:loadTexture(optCard..".png")
    end
    cardDataMgr.pengGangNum[clientOpt] = pengGangNum + 1
    cardDataMgr.pengNum[clientOpt] = cardDataMgr.pengNum[clientOpt] + 1
    cardDataMgr.pengValue[clientOpt][cardDataMgr.pengNum[clientOpt]] = optCard
end
--其他玩家明杠
function PlayLayer:optOtherMGang( clientOpt, clientPro, optCard )
    local  pengGangNum = cardDataMgr.pengGangNum[clientOpt]  
    local gangNum =  cardDataMgr.gangNum[clientOpt]
    --cardMgr.stndCell[clientOpt][14]:setVisible(true)
    local startDown = pengGangNum * 3
    for i=startDown + 1, startDown + 3 do
        cardMgr.stndCell[clientOpt][i]:setVisible(false)
    end
    for i=1,4 do
        cardMgr.pengCell[clientOpt][pengGangNum + 1][i]:setVisible(true)
        cardMgr.pengCellFace[clientOpt][pengGangNum + 1][i]:loadTexture(optCard..".png")
    end
    cardDataMgr.pengGangNum[clientOpt] = pengGangNum + 1
    cardDataMgr.gangNum[clientOpt] = gangNum + 1
    cardDataMgr.gangValue[clientOpt][gangNum + 1] = optCard
end
--其他玩家暗杠
function PlayLayer:optOtherAGang(clientOpt, clientPro, optCard)
    local  pengGangNum = cardDataMgr.pengGangNum[clientOpt]   
    local gangNum =  cardDataMgr.gangNum[clientOpt]
    --cardMgr.stndCell[clientOpt][14]:setVisible(true)
    local startDown = pengGangNum * 3     --放下牌的起始位置，放下四张牌
    for i=startDown + 1, startDown + 4 do  
        cardMgr.stndCell[clientOpt][i]:setVisible(false)
    end
    for i=1,4 do
        cardMgr.pengCell[clientOpt][pengGangNum + 1][i]:setVisible(true)
        cardMgr.pengCellFace[clientOpt][pengGangNum + 1][i]:loadTexture(optCard..".png")
    end
    cardDataMgr.pengGangNum[clientOpt] = pengGangNum + 1
    cardDataMgr.gangNum[clientOpt] = gangNum + 1
    cardDataMgr.gangValue[clientOpt][gangNum + 1] = optCard
end
--其他玩家碰杠
function PlayLayer:optOtherPGang(clientOpt, clientPro, optCard)
    --显示碰杠的牌，。。。cgpTest
    local pIndex = self:getPGangIndex(clientOpt, optCard)
    cardMgr.pengCell[clientOpt][pIndex][4]:setVisible(true)
    cardMgr.pengCellFace[clientOpt][pIndex][4]:loadTexture(optCard..".png")
end


--[[
    button 碰杠听胡过（1- 5）
    8         7          6          5          4          3         2          1  tableValue 
              no        hu         ting       pgang       agang     mgang     peng        
    #define WIK_NULL                    0x00                                //没有类型
    #define WIK_PENG                    0x01                                //碰牌类型
    #define WIK_MGANG                   0x02                                //明杠牌类型
    #define WIK_AGANG                   0x04                                //暗杠牌类型
    #define WIK_PGANG                   0x08                                //碰杠牌类型
    #define WIK_LISTEN                  0x10                                //听牌类型
    #define WIK_CHI_HU                  0x20                                /胡类型
    ]]


--只发给自己（其他人打的牌，等待自己操作）
function PlayLayer:waitOption(options, card   )

    print("\nWait options  "..options.."    \n")
    local actOption =  girl.getBitTable( options ) 
   
    for i=1,8 do
        print(" "..actOption[i])
    end
    --timer
    self:whichTurn(1)

    self.actCard = card   --操作的牌值

    print("\n################### card  "..card)
    self.gangSaveValue = 0

    if actOption[1] == 1 then   --peng
        self.btnActions[1]:setVisible(true)
    end
    if actOption[2] == 1 then   --mgang
         self.btnActions[2]:setVisible(true)
         self.gangSaveValue = 2
    end

    if actOption[6] == 1 then   --吃胡
        self.btnActions[4]:setVisible(true)
    end
    self.btnActions[5]:setVisible(true) 

end


--操作返回结果
function PlayLayer:optionResult( optResult)
    local actOption =  girl.getBitTable(optResult.cbOperateCode)  --操作码
    local clientOpt = dataMgr.chair[optResult.wOperateUser + 1]  --操作者的客户端椅子Id 
    local clientPro = dataMgr.chair[optResult.wProvideUser + 1]  --提供者的客户端椅子Id 
    local optCard = optResult.cbOperateCard  --操作的牌值

    printf("clientOpt %d, actOption %02X, optCard %d", clientOpt, optResult.cbOperateCode, optCard)
    if clientOpt == 1 then --自己
        --关闭定时器
        self:stopClock()  --close timer

        if actOption[1] == 1 then   --peng
            print("optMePeng")
            self:optMePeng(clientOpt, clientPro, optCard)
        end

        if actOption[2] == 1 then   --mgang
            print("optMeGang")
             self:optMeMGang(clientOpt, clientPro, optCard)
        end

        if actOption[3] == 1 then   --agang
            print("optAGang")

            self:optMeAGang(clientOpt, clientPro, optCard)
        end

        if actOption[4] == 1 then    --pgang
            print("optPGang")

            self:optMePGang(clientOpt, clientPro, optCard)
        end

        --自己点击了过，并且是自己提供的，（自己摸牌后，杠胡点过)
        if optResult.cbOperateCode == 0 and clientPro == 1   then
            --杠胡不点，点过后打开触摸
            cardDataMgr.outType = 0  
            cardMgr.imgTouchCard:setTouchEnabled(true)
            self:whichTurn(1) 
        end



        --其他人碰杠操作
    else
        if actOption[1] == 1 then   --peng
            self:optOtherPeng(clientOpt, clientPro, optCard)
            return

        elseif actOption[2] == 1 then   --mgang
             self:optOtherMGang(clientOpt, clientPro, optCard) 
             return 

        elseif actOption[3] == 1 then   --agang
            self:optOtherAGang(clientOpt, clientPro, optCard)
            return

        elseif actOption[4] == 1 then    --pgang
            self:optOtherPGang(clientOpt, clientPro, optCard)
            return
        end

    end
end



return PlayLayer
