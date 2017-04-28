local CURRENT_MODULE_NAME = ...

local dataMgr     = import(".DataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()
local musicMgr = import(".MusicManager"):getInstance()
local cardNode		= import(".CardNode", CURRENT_MODULE_NAME)
local s_inst = nil
local cardDataMgr = import(".CardDataManager"):getInstance()
--local actMgr = import(".ActionManager"):getInstance() loopDebug


local CardManager = class("CardManager")


function CardManager:getInstance()
	if not s_inst then
		s_inst = CardManager.new()
		s_inst:inits()
	end
	return s_inst
end

function CardManager:inits( )
	self.handCards = {}

	self.cardDraw = nil    --抓的牌 node
	self.whichTouch = nil
	self.stndMeCnt = nil

end

function CardManager:initAllNodes( param )
    local rootNode = param.rootNode
    self.wallNode = {}
    self.stndNode = {}
    self.outNode = {}
    self.pengNode = {}
    self.wallCell = {}  --1, 144 已按抓牌顺序排好序
    self.stndCell = {}

    self.nodeDachu = {}  --打出牌节点
    self.imgBigDachu = {} --打出牌
    self.deskUiNode  = rootNode:getChildByName("FileNode_deskUi")
    for i=1,4 do
        local strName = "FileNode_dachuBig_"..i
        self.nodeDachu[i] = self.deskUiNode:getChildByName(strName)
        self.nodeDachu[i]:setVisible(false)
        self.imgBigDachu[i] = self.nodeDachu[i]:getChildByName("Image_paiMian")
    end
    self.imgTouchCard = self.deskUiNode:getChildByName("Image_touchCard")
    self.imgTouchOther = self.deskUiNode:getChildByName("Image_touchOther")
    self.touchSn = 0   --点击第几张牌

--getTouchSn
    self.imgTouchCard:setTouchEnabled(false)  --初次创建禁止触摸
    self.imgTouchCard:addTouchEventListener(
    --[14]多15
    function (sender, state )
        
        local sn = 0
        if state == 2 then
            self.imgTouchCard:setTouchEnabled(false)
            local touchEndPosX = sender:getTouchEndPosition().x
            if touchEndPosX < 1280 and touchEndPosX > 1161 then
                sn = 14
            else 
                sn = math.modf((touchEndPosX - 30) / 86) + 1
            end
            self.touchSn = sn
            if sn <= cardDataMgr.pengGangNum[1] * 3 then
                return
            end

            print("\nimgTouchCard posx end"..touchEndPosX.."  sn "..self.touchSn)


            local outValueSave = 0

            print("outType "..cardDataMgr.outType)
            if cardDataMgr.outType == 0 then
                outValueSave = self:outDrawCard(sn)
            else
                outValueSave = self:outPengCard(sn)
            end
            print("\n  outValueSave "..outValueSave)

            musicMgr:playCardValueEffect(dataMgr.myBaseData.cbGender ,dataMgr.myBaseData.young,  outValueSave)

            local snd = DataSnd:create(200, 1)
            snd:wrByte(outValueSave)
            snd:sendData(netTb.SocketType.Game)
            snd:release();
            --print("\ntable size "..#self.handCards.."  sn  "..sn)
        end
    end)



    self.wallNode[1]  = rootNode:getChildByName("FileNode_wallMe")
    self.wallNode[4]  = rootNode:getChildByName("FileNode_wallRight")
    self.wallNode[3]  = rootNode:getChildByName("FileNode_wallUp")
    self.wallNode[2]  = rootNode:getChildByName("FileNode_wallLeft")
    self.stndNode[1]  = rootNode:getChildByName("FileNode_standMe")
--test
    --self.stndNode[1]:setVisible(true)
    self.stndNode[4]  = rootNode:getChildByName("FileNode_standRight")
    self.stndNode[3]  = rootNode:getChildByName("FileNode_standUp")
    self.stndNode[2]  = rootNode:getChildByName("FileNode_standLeft")
    self.outNode[1]  = rootNode:getChildByName("FileNode_dachuMe")
    self.outNode[4]  = rootNode:getChildByName("FileNode_dachuRight")
    self.outNode[3]  = rootNode:getChildByName("FileNode_dachuUp")
    self.outNode[2]  = rootNode:getChildByName("FileNode_dachuLeft")
    self.pengNode[1]  = rootNode:getChildByName("FileNode_pengMe")
    self.pengNode[4]  = rootNode:getChildByName("FileNode_pengRight")
    self.pengNode[3]  = rootNode:getChildByName("FileNode_pengUp")
    self.pengNode[2]  = rootNode:getChildByName("FileNode_pengLeft")
    self.stndNodeMeBei = rootNode:getChildByName("FileNode_standMeBei")


    --pai
    self.outCellFace = {}
    self.outCell = {}
    self.pengCellFace = {}
    self.pengCell = {}
    for i = 1, 4 do
        --self.wallCell[i] = {}
        self.stndCell[i] = {}
        self.outCell[i] = {} --打出牌的底
        self.outCellFace[i] = {}  --打出牌的底的牌面
        self.pengCell[i] = {}
        self.pengCellFace[i] = {}
        for j=1,4 do
            self.pengCell[i][j] = {}
            self.pengCellFace[i][j] = {}
        end
    end


    --碰牌  四个一组,pengCell[1][1][1]，共四组，5,6为13,14张
    for  i = 1,4 do
        self.pengCell[i][5] =  self.pengNode[i]:getChildByName("Image13")
        self.pengCell[i][6] =  self.pengNode[i]:getChildByName("Image14")
        self.pengCellFace[i][5] =  self.pengCell[i][5]:getChildByName("Image_face")
        self.pengCellFace[i][6] =  self.pengCell[i][6]:getChildByName("Image_face")
        for j = 1, 4 do
            local nodeName = "Node_"..j
            local nd =  self.pengNode[i]:getChildByName(nodeName)
            for k = 1, 4 do
                local imgName = "Image"..k
                self.pengCell[i][j][k] = nd:getChildByName(imgName)
                self.pengCellFace[i][j][k] = self.pengCell[i][j][k]:getChildByName("Image_face")
                --self.pengCell[i][j][k]:setVisible(false)
            end
        end
    end

    --打出牌
    for i = 1, 4 do
        for j = 1, 24 do
            local imgName = "Image"..j
            self.outCell[i][j] =  self.outNode[i]:getChildByName(imgName) 
            self.outCellFace [i][j] = self.outCell[i][j]:getChildByName("ImageFace")
        end
    end

    --站着的牌, 自己的站牌动态创建，在CardManager CardNodes
    for i=2,4 do
        for j=1,14 do
            local imgName = "Image"..j
            self.stndCell[i][j] = self.stndNode[i]:getChildByName(imgName)
        end
    end
    --自己的盖下去的牌
    for i=1,14 do
        local imgName = "Image"..i
        self.stndCell[1][i] = self.stndNodeMeBei:getChildByName(imgName)
    end
end


--刷新
function CardManager:hideAllCards(  )
    for i=1,4 do
        self.wallNode[i]:setVisible(false)
        self.stndNode[i]:setVisible(false)
        self.outNode[i]:setVisible(true)
        self.pengNode[i]:setVisible(true)
    --打出的大牌
    	self.nodeDachu[i]:setVisible(false)
    end

    --打出牌
    for i = 1, 4 do
        for j = 1, 24 do
            self.outCell[i][j]:setVisible(false)
        end
    end

    --碰牌
    for  i = 1,4 do
        self.pengCell[i][5]:setVisible(false)
        self.pengCell[i][6]:setVisible(false)
        for j = 1, 4 do
            for k = 1, 4 do
                self.pengCell[i][j][k]:setVisible(false)
            end
        end
    end

    --结算后，更新时禁止触摸
    self.stndNodeMeBei:setVisible(false)
    self.imgTouchCard:setTouchEnabled(false)
end

--胡牌后删除手牌和抓的牌
function CardManager:removeHandCards( )
    for i=1,#self.handCards do
        self.handCards[i]:removeFromParent()
    end
    self.handCards = {}
    if  self.cardDraw  then
        self.cardDraw:removeFromParent()
        self.cardDraw = nil
    end

end

--自己抓牌后打牌
function CardManager:outDrawCard(sn  )
     local playlayer = layerMgr:getLayer(layerMgr.layIndex.PlayLayer)

	local outValueSave = 0

    self.nodeDachu[1]:setVisible(true)
    --打出最后一张
	if sn == 14 then
		outValueSave = self.cardDraw.cardValue
		self.imgBigDachu[1]:loadTexture(outValueSave..".png")
        self.cardDraw:removeFromParent()
        self.cardDraw = nil
        local action = cc.Sequence:create(cc.DelayTime:create(0.8), 
        	cc.CallFunc:create(
            function ()
            	self.nodeDachu[1]:setVisible(false)    --打出的打牌
            	cardDataMgr.outNum[1] = cardDataMgr.outNum[1] + 1
            	self.outCell[1][cardDataMgr.outNum[1]]:setVisible(true)
            	self.outCellFace[1][cardDataMgr.outNum[1]]:loadTexture(outValueSave..".png")
                --箭头指向
                playlayer:playJianTou(1, self.outCell[1][cardDataMgr.outNum[1]]:getPositionX(), 
                self.outCell[1][cardDataMgr.outNum[1]]:getPositionY() - 5)
   			end)
        )	
        self.nodeDachu[1]:runAction(action)

	else
    --打出非最后一张牌	

        local outIndex = sn - cardDataMgr.pengGangNum[1] * 3    --打出的是第几张手牌，去掉了碰 
		outValueSave = cardDataMgr.handValues[outIndex]
		self.imgBigDachu[1]:loadTexture(outValueSave..".png")

        --删除打出牌
        self.handCards[outIndex]:removeFromParent()
        table.remove(self.handCards, outIndex)
        table.remove(cardDataMgr.handValues,  outIndex) 
 
        --local handCount = 13 - cardDataMgr.pengGangNum[1] * 3    --手牌的张数，去掉了碰等和进的一张牌    
        local handCount = #self.handCards    --剩余手牌的张数，去掉了碰等和抓的一张牌以及打出的一张牌 
        local insertIndex = nil

        --打出节点的右边节点左移一位，不包括抓的牌
        for i = outIndex, handCount do   
            local actions = cc.Sequence:create(
                cc.DelayTime:create(0.4), 
                cc.MoveBy:create(0.2, cc.p(-86, 0))
                )
            self.handCards[i]:runAction(actions) 
        end

        --抓的牌进行插入操作
        local insertIndex = girl.getTableSortIndex(cardDataMgr.handValues, self.cardDraw.cardValue) 
        print("\n###### insert index ######"..insertIndex)

        for i = insertIndex, handCount do   --待插入节点的右边（含）右移一位
            local actions = cc.Sequence:create(
                cc.DelayTime:create(0.4), 
                cc.MoveBy:create(0.2, cc.p(86, 0))
                )
            self.handCards[i]:runAction(actions) 
        end

        --抓的牌
        local action1 = cc.MoveBy:create(0.2, cc.p(0, 113))
        local action2 = cc.MoveTo:create(0.3, cc.p(girl.posx[insertIndex + cardDataMgr.pengGangNum[1] * 3], 113))
        local action3 = cc.MoveTo:create(0.3, cc.p(girl.posx[insertIndex + cardDataMgr.pengGangNum[1] * 3], 0))
        self.cardDraw:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.4),
            action1,
            action2,
            action3))


        --打出的大牌节点
        local actionDachu = cc.Sequence:create(
            cc.DelayTime:create(0.8), 
            cc.CallFunc:create(
                function ()
                    self.nodeDachu[1]:setVisible(false)    --打出的大牌
                    cardDataMgr.outNum[1] = cardDataMgr.outNum[1] + 1
                    self.outCell[1][cardDataMgr.outNum[1]]:setVisible(true)
                    self.outCellFace[1][cardDataMgr.outNum[1]]:loadTexture(outValueSave..".png")


                    --箭头指向
                    playlayer:playJianTou(1, self.outCell[1][cardDataMgr.outNum[1]]:getPositionX(), 
                    self.outCell[1][cardDataMgr.outNum[1]]:getPositionY() - 5)
                end)
            )
        self.nodeDachu[1]:runAction(actionDachu)

        local action = cc.Sequence:create(
            cc.DelayTime:create(1.0), 
            cc.CallFunc:create(
                function ()
                    table.insert(self.handCards,  insertIndex, self.cardDraw)
                    table.insert(cardDataMgr.handValues,  insertIndex, self.cardDraw.cardValue)
                    self.cardDraw = nil 
                end)
        )
        layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params).deskBgNode:runAction(action)    
	end
	return outValueSave
end

--自己碰后打牌
function CardManager:outPengCard(sn  )

    local playlayer = layerMgr:getLayer(layerMgr.layIndex.PlayLayer)

	local outIndex = sn - cardDataMgr.pengGangNum[1] * 3    --打出的手牌第几张，去掉了碰  
	local handCount = 14 - cardDataMgr.pengGangNum[1] * 3    --手牌的张数，去掉碰
	local outValueSave = 0


    self.nodeDachu[1]:setVisible(true)
	--打出最后一张
	if sn == 14 then
		outValueSave = self.handCards[handCount].cardValue
		self.imgBigDachu[1]:loadTexture(outValueSave..".png")

        --删除最后一张手牌
        self.handCards[handCount]:removeFromParent()
        table.remove(self.handCards, handCount)
        table.remove(cardDataMgr.handValues,  handCount) 

        --打出大牌和底牌
        local action = cc.Sequence:create( 
			cc.DelayTime:create(0.8),
        	cc.CallFunc:create(
            function ()
            	self.nodeDachu[1]:setVisible(false)
            	cardDataMgr.outNum[1] = cardDataMgr.outNum[1] + 1
            	self.outCell[1][cardDataMgr.outNum[1]]:setVisible(true)
            	self.outCellFace[1][cardDataMgr.outNum[1]]:loadTexture(outValueSave..".png")
                --箭头指向
                playlayer:playJianTou(1, self.outCell[1][cardDataMgr.outNum[1]]:getPositionX(), 
                self.outCell[1][cardDataMgr.outNum[1]]:getPositionY() - 5)
   			end)
        )	
        self.nodeDachu[1]:runAction(action)

	else
	--打出非最后一张牌		
		
        outValueSave = cardDataMgr.handValues[outIndex]
		self.imgBigDachu[1]:loadTexture(outValueSave..".png")

        --删除打出牌
        self.handCards[outIndex]:removeFromParent()
        table.remove(self.handCards, outIndex)
        table.remove(cardDataMgr.handValues,  outIndex) 
        handCount = handCount - 1    --手牌减一

        --打出节点的右边节点左移一位，不包括最后一张牌
        for i = outIndex, handCount - 1 do   
            local actions = cc.Sequence:create(
                cc.DelayTime:create(0.4), 
                cc.MoveBy:create(0.2, cc.p(-86, 0))
                )
            self.handCards[i]:runAction(actions) 
        end

        --最后一张牌左移
        local actionLast = cc.Sequence:create(
                cc.DelayTime:create(0.4), 
                cc.MoveBy:create(0.2, cc.p(-86-15, 0))
                )
        -- print("\n pairs handCount "..handCount)
        -- for k, v in pairs(self.handCards) do
        --     print(k, v)
        --     print(v.cardValue)
        -- end
        self.handCards[handCount]:runAction(actionLast)

        local action = cc.Sequence:create( 
			cc.DelayTime:create(0.8),
        	cc.CallFunc:create(
                function ()
                	self.nodeDachu[1]:setVisible(false)
                	cardDataMgr.outNum[1] = cardDataMgr.outNum[1] + 1
                	self.outCell[1][cardDataMgr.outNum[1]]:setVisible(true)
                	self.outCellFace[1][cardDataMgr.outNum[1]]:loadTexture(outValueSave..".png")

                    --箭头指向
                    playlayer:playJianTou(1, self.outCell[1][cardDataMgr.outNum[1]]:getPositionX(), 
                    self.outCell[1][cardDataMgr.outNum[1]]:getPositionY() - 5)
       			end)
        )   

        self.nodeDachu[1]:runAction(action)
				
	end
	return outValueSave
end

--获取手牌的暗杠牌值 
function CardManager:getAGangValue(cardValue)   --cardValue  抓的牌

    local tbCardNum = {} --下标为牌值， 值为个数
    for i=1,75  do
        tbCardNum[i] = 0
    end
    for i=1,#cardDataMgr.handValues do
        tbCardNum[cardDataMgr.handValues[i]] = tbCardNum[cardDataMgr.handValues[i]] + 1
    end
    tbCardNum[cardValue] = tbCardNum[cardValue] + 1

    for i=1, 75 do
        if tbCardNum[i] == 4 then

            return i
        end

    end
end

--获取碰杠的牌值
function CardManager:getPGangValue(cardValue )
    local pengNum =  cardDataMgr.pengNum[1]
    for i=1,pengNum do
        for j=1, #cardDataMgr.handValues do
            if cardDataMgr.pengValue[1][i] == cardDataMgr.handValues[j] then   --手牌
                 return cardDataMgr.handValues[j]
            end 
            if cardValue == cardDataMgr.pengValue[1][i] then  --抓的一张
                return cardValue
            end
        end
    end
end

--抓一张牌(含暗杠，碰杠，自摸消息通知)
function CardManager:drawCard(cardZhua )
	local svrChair = cardZhua.wCurrentUser
	local clientChair = dataMgr.chair[svrChair + 1]
	cardDataMgr.currentClient = clientChair

    local playlayer = layerMgr:getLayer(layerMgr.layIndex.PlayLayer)
    --补花
	cardDataMgr.huaNum[clientChair] = cardDataMgr.huaNum[clientChair] + cardZhua.cbHuaCount
   


	for i=1,cardZhua.cbHuaCount do
		table.insert(cardDataMgr.huaValue[clientChair],  cardZhua.cbHuaCardData[i])
	end
	playlayer.txtHuaNum[clientChair]:setString(cardDataMgr.huaNum[clientChair])
	
    --牌堆
    cardDataMgr.totalOutNum = cardDataMgr.totalOutNum + 1
	self.wallCell[cardDataMgr.totalOutNum]:setVisible(false)

    --cardDataMgr.totalOutNum = cardDataMgr.totalOutNum + cardZhua.cbHuaCount + 1  --总牌加上补花 + 1
    playlayer.txtLeftCard:setString(tostring(144 - cardDataMgr.totalOutNum))  --剩余牌

    if clientChair == 1 then  --自己
        local cardv = cardZhua.cbCardData  --牌值
        self:createCardDraw(cardv)
        print("\n drawcard option")
        local actOption =  girl.getBitTable( cardZhua.cbActionMask ) 
        for i=1,8 do
            print(" "..actOption[i])
        end

        local haveOption = 0  --  1有操作, 0 没有
        if actOption[3] == 1 then   --暗杠
            playlayer.btnActions[2]:setVisible(true)
            playlayer.gangSaveValue = 4
            haveOption = 1
            print(" drawCard "..cardv)
            print(" handCardsLenth "..#cardDataMgr.handValues)
            playlayer.actCard = self:getAGangValue(cardv)
            print("\nanGang value "..playlayer.actCard)
        end
        if actOption[4] == 1 then    --碰杠
            playlayer.btnActions[2]:setVisible(true)
            playlayer.gangSaveValue = 8
            haveOption = 1
            playlayer.actCard = self:getPGangValue(cardv)
            print("\n\n\nPGang value "..playlayer.actCard)
        end

        if actOption[6] == 1 then   --自摸
            playlayer.btnActions[4]:setVisible(true)
            haveOption = 1
            playlayer.huCard = cardv
        end

        if haveOption == 1 then
            playlayer.btnActions[5]:setVisible(true) 
            playlayer:whichTurn(1)
        else
        --没有操作，摸牌后打开触摸
            cardDataMgr.outType = 0  --摸牌
            self.imgTouchCard:setTouchEnabled(true)
            playlayer:whichTurn(1)
        end
    else      --其他人显示14张可见
        self.stndCell[clientChair][14]:setVisible(true)
        playlayer:whichTurn(clientChair)  --轮到谁打，开定时器
    end
end

--收到玩家出牌
function CardManager:rcvOutCard(outCard )
    local clientChair = dataMgr.chair[outCard.wOutCardUser + 1] --svrChair
    --关闭定时器
    local playlayer = layerMgr:getLayer(layerMgr.layIndex.PlayLayer)
	playlayer:stopClock()

    if clientChair == 1 then   --收到自己出牌，直接退出
    	return
    end
    local outValue = outCard.bOutCardData
    self.nodeDachu[clientChair]:setVisible(true)
	self.imgBigDachu[clientChair]:loadTexture(outValue..".png")

    musicMgr:playCardValueEffect(dataMgr.onDeskData[outCard.wOutCardUser + 1].cbGender ,dataMgr.onDeskData[outCard.wOutCardUser + 1].young,  outValue)
	
    self.stndCell[clientChair][14]:setVisible(false)
	
    local delay1 = cc.DelayTime:create(0.4)
	local delay2 = cc.DelayTime:create(0.4)
    local action = cc.Sequence:create(delay1, 
		delay2,
    	cc.CallFunc:create(
        function ()
        	self.nodeDachu[clientChair]:setVisible(false)
        	local outNum = cardDataMgr.outNum[clientChair] + 1
        	self.outCell[clientChair][outNum]:setVisible(true)
        	self.outCellFace[clientChair][outNum]:loadTexture(outValue..".png")
            musicMgr:playEffect("cardTodesk.mp3", false)
            --箭头指向
           
            playlayer:playJianTou(clientChair, self.outCell[clientChair][outNum]:getPositionX(), 
                self.outCell[clientChair][outNum]:getPositionY() -5)

        	cardDataMgr.outNum[clientChair] = outNum
			end)
    )	
    self.nodeDachu[clientChair]:runAction(action)
end

function CardManager:createCardDraw(cardValue )
	self.cardDraw = cardNode.create(cardValue)
	self.cardDraw:setPositionX(girl.posx[14])
	self.stndNode[1]:addChild(self.cardDraw)
    print(cardValue)
    print("cardDraw "..self.cardDraw.cardValue)

end


function CardManager:inithandCards(drawCardValue)
	self.handCards = {}    --创建的节点，打出去和碰出去的不算
	--local cardValues = {25, 18, 1, 2, 3, 8, 5, 5, 7, 9, 40, 41, 52, 74}
	table.sort(cardDataMgr.handValues)

	for i=1,13 do
		self.handCards[i] = cardNode.create(cardDataMgr.handValues[i])
		self.handCards[i]:setPositionX(girl.posx[i])

		self.stndNode[1]:addChild(self.handCards[i])
        --self.stndNode[1]:retain()   
--added by caoguoping
		--self.stndNode[1]:retain()
		self.handCards[i].sn = i
		self.handCards[i].clickTimes = 0


	end

	if drawCardValue ~= 0 then
        self.imgTouchCard:setTouchEnabled(true)  --庄家开启触摸
		self:createCardDraw(drawCardValue)	
	-- else
	-- 	self.imgTouchCard:setTouchEnabled(false)  --不是庄家禁止触摸
	end

end


return CardManager
