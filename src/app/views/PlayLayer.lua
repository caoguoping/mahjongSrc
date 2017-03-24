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

    --self:schedule(self,handler(self, self.checkAttackUpdate),2.0)
    --     if self:getPositionX() <= battleManager.hero:getPositionX() then
    --     self:unschedule()
    --     --切换到ui层处理
    --     self:changeParent(battleManager.battleUi,1024)
    --     self:setPosition(cc.p(battleManager.cameraPos.x + self:getPositionX(),battleManager.cameraPos.y + self:getPositionY()))
    --     local moveto = cc.MoveTo:create(1.0,cc.p(self.targetPos.x,self.targetPos.y))
    --     local scale  = cc.ScaleTo:create(1.0,0.5)
    --     local callBack = cc.CallFunc:create(handler(self, self.destroy))
    --     local action = cc.Spawn:create(cc.Sequence:create(moveto,callBack,nil),scale)
    --     self:runAction(action)
    -- else
    --     self:setLocalZOrder(display.height - self:getPositionY())
    -- end

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
    self.txtClock = self.deskBgNode:getChildByName("AtlasLabel_1")
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
    self.txtScore = {}  --金币
    self.imgHead = {}   --头像

    for i=1,4 do
        local strName = "FileNode_"..i
        self.headNode[i] = self.deskUiNode:getChildByName(strName)
        self.txtScore[i] = self.headNode[i]:getChildByName("Text_score")
        self.imgHead[i] = self.headNode[i]:getChildByName("Image_head")
    end

    for i=1,5 do
        local strName = "Button_"..i
        self.btnActions[i] = self.deskUiNode:getChildByName(strName)
    end



    self.txtLeftCard = self.deskUiNode:getChildByName("Text_leftCard")
    self.imgLeftCard = self.deskUiNode:getChildByName("Image_leftCard")
--碰杠听胡过btn
    self.btnActions[1]:onClicked(
        function (  )
            self.btnActions[1]:setVisible(false)
            self.btnActions[5]:setVisible(false)
            local snd = DataSnd:create(200, 3)
            snd:wrByte(1)     --0x01
            snd:wrByte(self.actCard)
            snd:wrByte(self.actCard)
            snd:wrByte(self.actCard)
            snd:sendData(netTb.SocketType.Game)
            snd:release();           
        end
        )

    --杠
    self.btnActions[2]:onClicked(
        function (  )
            self.btnActions[5]:setVisible(false)
            self.btnActions[2]:setVisible(false)
            local snd = DataSnd:create(200, 3)
            snd:wrByte(self.gangSaveValue)     --保存过的
            snd:wrByte(self.actCard)
            snd:wrByte(self.actCard)
            snd:wrByte(self.actCard)
            snd:sendData(netTb.SocketType.Game)
            snd:release();              
        end
        )

    --听
    self.btnActions[3]:onClicked(
        function (  )
            self.btnActions[3]:setVisible(false)
            self.btnActions[5]:setVisible(false)
            local snd = DataSnd:create(200, 2)
            local svrChairId = dataMgr:getServiceChairId(1)
            snd:wrByte(svrChairId)     --任何一个字节
            snd:sendData(netTb.SocketType.Game)
            snd:release();             
        end
        )

    --胡
    self.btnActions[4]:onClicked(
        function (  )
            self.btnActions[4]:setVisible(false)
            self.btnActions[5]:setVisible(false)
            local snd = DataSnd:create(200, 3)
            snd:wrByte(32)      --0x20
            snd:wrByte(self.actCard)
            snd:wrByte(self.actCard)
            snd:wrByte(self.actCard)
            print("\n hu card "..self.actCard)
            snd:sendData(netTb.SocketType.Game)
            snd:release();             
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
            snd:wrByte(self.actCard)
            snd:wrByte(self.actCard)
            snd:wrByte(self.actCard)
            snd:sendData(netTb.SocketType.Game)
            snd:release();             
        end

        )


--invite 邀请好友界面
    self.inviteNode = rootNode:getChildByName("FileNode_invite")
    self.txtRoomNum = self.inviteNode:getChildByName("Text_room")


end
  
function PlayLayer.create()
    return PlayLayer.new()
end

--点击创建按钮
function PlayLayer:refresh( )
    for i=1,4 do
        self.imgLight[i]:setVisible(false)
        self.imgFeng[i]:setVisible(false)
        self.imgNowFeng[i]:setVisible(false)
        self.headNode[i]:setVisible(false)
    end

    cardMgr:hideAllCards()

    for i=1,5 do
        self.btnActions[i]:setVisible(false)
    end
    self.imgLeftCard:setVisible(false)
    self.txtLeftCard:setVisible(false)



end

--等待其他人加入，在自己进去之后，收到
function PlayLayer:waitJoin()

    self.nodeShezi:setVisible(false)
    self.inviteNode:setVisible(true)
    
    --self.txtRoomNum:setString(tostring(dataMgr.roomSet.dwRoomNum))
    self.txtRoomNum:setString(string.format("%07d", dataMgr.roomSet.dwRoomNum))

--cgpTest


end

--显示进来人
function PlayLayer:showPlayer(svrChairId )  
    dataMgr.joinPeople = dataMgr.joinPeople + 1
    
    local clientId = dataMgr.chair[svrChairId + 1]
    print("\n\nclientId   "..clientId)
    self.headNode[clientId]:setVisible(true)
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

--发牌
function PlayLayer:sendCard(drawValue)
--test start

   --  local testCard = {9,6, 5,   2, 1, 21,  23, 25,39,   23, 25, 25, 17, 8}
   --  local testHuaCard = {75, 74, 72}

   --  cardDataMgr.cardSend.wBankerUser    = 2               --庄家用户
   --  cardDataMgr.cardSend.wCurrentUser   = 2               --当前用户
   --  cardDataMgr.cardSend.wReplaceUser   = 2               --补牌用户
   --  cardDataMgr.cardSend.bLianZhuangCount = 1 
   --  cardDataMgr.cardSend.bHuaCount = 3
   --  cardDataMgr.cardSend.bSice1         = 2   
   --  cardDataMgr.cardSend.bSice2         = 3
   --  cardDataMgr.cardSend.cbUserAction   = 0               --用户动作

   --  local clientBankId = dataMgr.chair[cardDataMgr.cardSend.wBankerUser + 1]
   --  cardDataMgr.bankClient = clientBankId

   --  for i=1, 13 do
   --      cardDataMgr.cardSend.cbCardData[i] = testCard[i]
   --      print("cardValues "..cardDataMgr.cardSend.cbCardData[i])
   --  end

   -- -- local drawCardValue
   -- -- if clientBankId == 1 then
   --    local  drawCardValue = testCard[14]
   --  -- else
   --  --     drawCardValue = 0
   --  -- end

   --  for i=1,cardDataMgr.cardSend.bHuaCount do
   --      cardDataMgr.cardSend.cbHuaCardData[i] = testHuaCard[i]
   --      print("HuaValues "..cardDataMgr.cardSend.cbHuaCardData[i])
   --  end


--test end
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
            self:qiPai()
            local delay = cc.DelayTime:create(1.0)
            local action = cc.Sequence:create(delay, cc.CallFunc:create(
                function (  )
                    self.imgShezi1:setVisible(false)
                    self.imgShezi2:setVisible(false)



                end))
            self:runAction(action)
        end
      )

    self.inviteNode:setVisible(false)
    for i=1,4 do
        cardMgr.wallNode[i]:setVisible(true)
    end
    cardMgr:inithandCards(cardDataMgr.cardSend.cbCardData, drawValue)
end

--[[
    button 碰杠听胡过（1- 5）
    8         7          6          5          4          3         2          1  tableValue 
    7         6          5          4          3          2         1          0
    no       hu         ting       pgang       agang     mgang     peng       no    
    #define WIK_NULL                    0x00                                //没有类型
    #define WIK_PENG                    0x01                                //碰牌类型
    #define WIK_MGANG                   0x02                                //明杠牌类型
    #define WIK_AGANG                   0x04                                //暗杠牌类型
    #define WIK_PGANG                   0x08                                //碰杠牌类型
    #define WIK_LISTEN                  0x10                                //听牌类型
    #define WIK_CHI_HU                  0x20                                /胡类型
    ]]

function PlayLayer:waitOption(options, card   )


    self.actCard = card   --操作的牌值
    self.gangSaveValue = 0
    local actOption =  girl.getBitTable( options ) 

    print("\noptions  "..options.."    \n")
    for i=1,8 do
        print(" "..actOption[i])
    end

    if actOption[1] == 1 then   --peng
        self.btnActions[1]:setVisible(true)
    end
    if actOption[2] == 1 then   --mgang
         self.btnActions[2]:setVisible(true)
         self.gangSaveValue = 2
    end
    if actOption[3] == 1 then   --agang
         self.btnActions[2]:setVisible(true)
         self.gangSaveValue = 4
    end
    if actOption[4] == 1 then    --pgang
         self.btnActions[2]:setVisible(true)
         self.gangSaveValue = 8
    end


    if actOption[6] == 1 then   --hu
        self.btnActions[4]:setVisible(true)
    end

    self.btnActions[5]:setVisible(true) 

end

function PlayLayer:optMePeng(clientOpt, clientPro, optCard)
    local pengNum = cardDataMgr.pengNum[1]
    --碰的牌起始位置
    local startIndex = girl.getTableSortIndex(cardDataMgr.handValues, optCard) 
    local handCount = 13 - pengNum * 3    --手牌的张数，去掉了碰等和进的一张牌

    local action = cc.Sequence:create(
        cc.MoveBy:create(0.2, cc.p(0, 113)),
        cc.DelayTime:create(0.2),
        cc.Hide:create() 
    )
    cardMgr.handCards[startIndex]:runAction(action)
    cardMgr.handCards[startIndex + 1]:runAction(action)

    local action2 = cc.Sequence:create( 
        cc.DelayTime:create(0.2), 
        cc.CallFunc:create(
            function ()
                --右边右移1
                -- for i = startIndex + 2, handCount - 1 do
                --     local action = cc.MoveBy:create(0.2, cc.p(86, 0))
                --     cardMgr.handCards[i]:runAction(action) 
                -- end
                -- cardMgr.handCards[handCount]:runAction(cc.MoveBy:create(0.2, cc.p(86 + 15, 0)))
                --右边右移1
                for i = startIndex + 2, handCount - 1 do
                    local action = cc.MoveBy:create(0.2, cc.p(86, 0))
                    cardMgr.handCards[i]:runAction(action) 
                end
                cardMgr.handCards[handCount]:runAction(cc.MoveBy:create(0.2, cc.p(86 + 15, 0)))
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
                --显示碰牌
                for i=1,3 do
                    cardMgr.pengCell[1][pengNum + 1][i]:setVisible(true) 
                    cardMgr.pengCellFace[1][pengNum + 1][i]:loadTexture(optCard..".png")
                end
            end
        ),
        cc.DelayTime:create(0.1), 
        cc.CallFunc:create(
            function ()
                --删除牌，修改值
                cardMgr.handCards[startIndex]:removeFromParent()
                cardMgr.handCards[startIndex + 1]:removeFromParent()
                table.remove(cardMgr.handCards, startIndex)
                table.remove(cardMgr.handCards, startIndex)  --自动前移一位
                table.remove(cardDataMgr.handValues,  startIndex)
                table.remove(cardDataMgr.handValues,  startIndex)
                cardDataMgr.pengNum[1] = cardDataMgr.pengNum[1] + 1
                cardDataMgr.outType = 1  --碰牌
                cardMgr.imgTouchCard:setTouchEnabled(true)     --打开触摸，容许出牌


                print("\nhandvalue after delete")
                for i=1,#cardDataMgr.handValues do
                    print(" "..cardDataMgr.handValues[i])
                end
            end
        )
    )
    self:runAction(action2)
end

function PlayLayer:optMeMGang(clientOpt, clientPro, optCard)
    local pengNum = cardDataMgr.pengNum[1]
    --碰的牌起始位置
    local startIndex = girl.getTableSortIndex(cardDataMgr.handValues, optCard) 
    local handCount = 13 - pengNum * 3    --手牌的张数，去掉了碰等和进的一张牌

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
                    cardMgr.pengCell[1][pengNum + 1][i]:setVisible(true) 
                    cardMgr.pengCellFace[1][pengNum + 1][i]:loadTexture(optCard..".png")
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
                cardDataMgr.pengNum[1] = cardDataMgr.pengNum[1] + 1
            end
        )
    )
    self:runAction(action2)
end

function PlayLayer:optMeAGang(clientOpt, clientPro, optCard)

end

function PlayLayer:optMePGang(clientOpt, clientPro, optCard)

end

function PlayLayer:optionResult( optResult)
    local actOption =  girl.getBitTable(optResult.cbOperateCode)  --操作码
    local clientOpt = dataMgr.chair[optResult.wOperateUser + 1]  --操作者的客户端椅子Id 
    local clientPro = dataMgr.chair[optResult.wOperateUser + 1]  --提供者的客户端椅子Id 
    local optCard = optResult.cbOperateCard  --操作的牌值

    if clientOpt == 1 then --自己
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

        if actOption[6] == 1 then   --hu
            --self.btnActions[4]:setVisible(true)
        end
    else
        -- if actOption[1] == 1 then   --peng
        --     self.btnActions[1]:setVisible(true)
        -- end

        -- if actOption[2] == 1 then   --mgang
        --      self.btnActions[2]:setVisible(true)
        --      self.gangSaveValue = 2
        -- end

        -- if actOption[3] == 1 then   --agang
        --      self.btnActions[2]:setVisible(true)
        --      self.gangSaveValue = 4
        -- end

        -- if actOption[4] == 1 then    --pgang
        --      self.btnActions[2]:setVisible(true)
        --      self.gangSaveValue = 8
        -- end

        -- if actOption[6] == 1 then   --hu
        --     self.btnActions[4]:setVisible(true)
        -- end
    end
end



return PlayLayer
