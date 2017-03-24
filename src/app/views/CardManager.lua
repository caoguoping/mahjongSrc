local CURRENT_MODULE_NAME = ...

local dataMgr     = import(".DataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()
local cardNode		= import(".CardNode", CURRENT_MODULE_NAME)
local s_inst = nil
local cardDataMgr = import(".CardDataManager"):getInstance()
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

function CardManager:hideAllCards(  )
    for i=1,4 do
        self.wallNode[i]:setVisible(false)
        self.stndNode[i]:setVisible(false)
        self.outNode[i]:setVisible(true)
        self.pengNode[i]:setVisible(true)
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
    self.stndNodeMeBei:setVisible(false)
end

--自己抓牌后打牌
function CardManager:outDrawCard(sn  )
	local outIndex = sn - cardDataMgr.pengNum[1] * 3    --打出的手牌第几张，去掉了碰  
	local handCount = 13 - cardDataMgr.pengNum[1] * 3    --手牌的张数，去掉了碰等和进的一张牌
	local outValueSave = 0

    self.nodeDachu[1]:setVisible(true)
    --出最后一张
	if sn == 14 then
		outValueSave = self.cardDraw.cardValue
		self.imgBigDachu[1]:loadTexture(outValueSave..".png")
		local delay1 = cc.DelayTime:create(0.4)
    	local delay2 = cc.DelayTime:create(0.4)
        local action = cc.Sequence:create(delay1, 
			delay2,
        	cc.CallFunc:create(
            function ()
            	self.nodeDachu[1]:setVisible(false)
            	cardDataMgr.outNum[1] = cardDataMgr.outNum[1] + 1
            	self.outCell[1][cardDataMgr.outNum[1]]:setVisible(true)
            	self.outCellFace[1][cardDataMgr.outNum[1]]:loadTexture(outValueSave..".png")
   			end)
        )	
        self.nodeDachu[1]:runAction(action)
		self.cardDraw:removeFromParent()
		self.cardDraw = nil

	else
    --打出非最后一张牌		
		outValueSave = cardDataMgr.handValues[outIndex]
		self.imgBigDachu[1]:loadTexture(outValueSave..".png")
		local delay1 = cc.DelayTime:create(0.4)
    	local delay2 = cc.DelayTime:create(0.4)
        local action = cc.Sequence:create(delay1, 
			cc.CallFunc:create(
            function ()
            	for i = outIndex, handCount - 1 do   --打出的节点早已移除，并前移了一位
            		local action = cc.MoveBy:create(0.2, cc.p(-86, 0))

            		self.handCards[i]:runAction(action) 
            		print("\ni   "..i.."  handCards[i] value"..self.handCards[i].cardValue)
            	end
            	local insertIndex = girl.getTableSortIndex(cardDataMgr.handValues, self.cardDraw.cardValue)	
				print("\n###### insert index ######"..insertIndex)

            	for i = insertIndex, handCount - 1 do   --打出的节点早已移除，并前移了一位
            		local action = cc.MoveBy:create(0.2, cc.p(86, 0))

            		self.handCards[i]:runAction(action) 
            	end

            	local action1 = cc.MoveBy:create(0.2, cc.p(0, 113))
            	local action2 = cc.MoveTo:create(0.3, cc.p(girl.posx[insertIndex], 113))
            	local action3 = cc.MoveTo:create(0.3, cc.p(girl.posx[insertIndex], 0))

            	self.cardDraw:runAction(cc.Sequence:create(action1,action2,action3))
            	table.insert(self.handCards,  insertIndex, self.cardDraw)
            	table.insert(cardDataMgr.handValues,  insertIndex, self.cardDraw.cardValue)
            	self.cardDraw = nil
            	print("\ntable size After"..#self.handCards.."  sn  "..sn)
            	for i=1,#self.handCards do
            		print("  "..self.handCards[i].cardValue)
            	end

   			end),
			delay2,
        	cc.CallFunc:create(
            function ()
            	--显示打出牌
            	self.nodeDachu[1]:setVisible(false)
            	cardDataMgr.outNum[1] = cardDataMgr.outNum[1] + 1
            	self.outCell[1][cardDataMgr.outNum[1]]:setVisible(true)
            	self.outCellFace[1][cardDataMgr.outNum[1]]:loadTexture(outValueSave..".png")
   			end)
        )	
        self.nodeDachu[1]:runAction(action)
		self.handCards[outIndex]:removeFromParent()
		table.remove(self.handCards, outIndex)
		table.remove(cardDataMgr.handValues,  outIndex)					
	end
	return outValueSave
end

--自己碰后打牌
function CardManager:outPengCard(sn  )
	local outIndex = sn - cardDataMgr.pengNum[1] * 3    --打出的手牌第几张，去掉了碰  
	local handCount = 14 - cardDataMgr.pengNum[1] * 3    --手牌的张数，去掉碰
	local outValueSave = 0

    self.nodeDachu[1]:setVisible(true)
	--出最后一张
	if sn == 14 then
		outValueSave = self.handCards[handCount].cardValue
		self.imgBigDachu[1]:loadTexture(outValueSave..".png")
		local delay1 = cc.DelayTime:create(0.4)
    	local delay2 = cc.DelayTime:create(0.4)
        local action = cc.Sequence:create(delay1, 
			delay2,
        	cc.CallFunc:create(
            function ()
            	self.nodeDachu[1]:setVisible(false)
            	cardDataMgr.outNum[1] = cardDataMgr.outNum[1] + 1
            	self.outCell[1][cardDataMgr.outNum[1]]:setVisible(true)
            	self.outCellFace[1][cardDataMgr.outNum[1]]:loadTexture(outValueSave..".png")
   			end)
        )	
        self.nodeDachu[1]:runAction(action)
		self.handCards[handCount]:removeFromParent()

	else
	--打出非最后一张牌		
		outValueSave = cardDataMgr.handValues[outIndex]
		self.imgBigDachu[1]:loadTexture(outValueSave..".png")
		local delay1 = cc.DelayTime:create(0.4)
    	local delay2 = cc.DelayTime:create(0.4)
        local action = cc.Sequence:create(delay1, 
    		cc.CallFunc:create(
        	function ()
            	for i = outIndex, handCount - 2 do   --打出的节点早已移除，并前移了一位
            		self.handCards[i]:runAction(cc.MoveBy:create(0.2, cc.p(-86, 0))) 
            	end
            	self.handCards[handCount - 1]:runAction(cc.MoveBy:create(0.2, cc.p(-86-15, 0)))  --最后一位牌
            end),
			delay2,
        	cc.CallFunc:create(
            function ()
            	self.nodeDachu[1]:setVisible(false)
            	cardDataMgr.outNum[1] = cardDataMgr.outNum[1] + 1
            	self.outCell[1][cardDataMgr.outNum[1]]:setVisible(true)
            	self.outCellFace[1][cardDataMgr.outNum[1]]:loadTexture(outValueSave..".png")
   			end)
        )	
        self.nodeDachu[1]:runAction(action)
		self.handCards[outIndex]:removeFromParent()
		table.remove(self.handCards, outIndex)
		table.remove(cardDataMgr.handValues,  outIndex)					
	end
	return outValueSave
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

    self.imgTouchCard:addTouchEventListener(
	--[14]多15
	function (sender, state )
		
		local sn = 0
    	if state == 2 then
    		self.imgTouchCard:setTouchEnabled(false)
    		local touchEndPosX = sender:getTouchEndPosition().x
    		if touchEndPosX < 1247 and touchEndPosX > 1161 then
    			sn = 14
    		else 
    			sn = math.modf((touchEndPosX - 30) / 86) + 1
    		end
    		self.touchSn = sn
    		if sn <= cardDataMgr.pengNum[1] * 3 then
    			return
    		end

			print("\nimgTouchCard posx end"..touchEndPosX.."  sn "..self.touchSn)


			local outValueSave = 0
			if cardDataMgr.outType == 0 then
				outValueSave = self:outDrawCard(sn)
			else
				outValueSave = self:outPengCard(sn)
			end

			--[
			local snd = DataSnd:create(200, 1)
			snd:wrByte(outValueSave)
            snd:sendData(netTb.SocketType.Game)
            snd:release();
			--]]

			print("\ntable size "..#self.handCards.."  sn  "..sn)
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
-- --堆牌
    -- for  i = 1,4 do
    --     for j = 1,36 do
    --         local imgName = "Image"..j
    --         self.wallCell[i][j] =  self.wallNode[i]:getChildByName(imgName)
    --     end
    -- end
    --堆牌
    local sice1 = cardDataMgr.cardSend.bSice1
    local sice2 = cardDataMgr.cardSend.bSice2
	--cgpTest
    sice1 = 3
    sice2 = 4
    local startDir = math.min(sice1, sice2)
    local theSum = sice1 + sice2
    local startIndex = (startDir - 1) * 36 + (theSum - 1) * 2  --相当于0
    for  i = 1,4 do
        for j = 1,36 do
            local imgName = "Image"..j
            local realPos = ((i - 1) * 36 + j - startIndex + 144) % 144
            self.wallCell[realPos] =  self.wallNode[i]:getChildByName(imgName)


            --print(realPos.." ")
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


--抓一张牌
function CardManager:drawCard(cardZhua )
	local svrChair = cardZhua.wCurrentUser
	local clientChair = dataMgr.chair[svrChair + 1]
	if clientChair == 1 then  --自己
		local cardv = cardZhua.cbCardData
		self:createCardDraw(cardv)
	else
		self.stndCell[clientChair][14]:setVisible(true)
	end
	local outNum = cardDataMgr.totalOutNum + 1

	self.wallCell[outNum]:setVisible(false)
	cardDataMgr.totalOutNum = outNum

end

--收到其他玩家出牌
function CardManager:rcvOutCard(outCard )
    local clientChair = dataMgr.chair[outCard.wOutCardUser + 1] --svrChair
    if clientChair == 1 then   --收到字节出牌，直接退出
    	return
    end
    local outValue = outCard.bOutCardData
    self.nodeDachu[clientChair]:setVisible(true)
	self.imgBigDachu[clientChair]:loadTexture(outValue..".png")
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
        	cardDataMgr.outNum[clientChair] = outNum
			end)
    )	
    self.nodeDachu[clientChair]:runAction(action)
end

function CardManager:createCardDraw(cardValue )
	self.cardDraw = cardNode.create(cardValue)
	self.cardDraw:setPositionX(girl.posx[14])
	self.stndNode[1]:addChild(self.cardDraw)
	self.imgTouchCard:setTouchEnabled(true)
	cardDataMgr.outType = 0  --摸牌
end


function CardManager:inithandCards(cardValues, drawCardValue)
	self.handCards = {}    --创建的节点，打出去和碰出去的不算
	--local cardValues = {25, 18, 1, 2, 3, 8, 5, 5, 7, 9, 40, 41, 52, 74}
	table.sort(cardValues)

	for i=1,13 do
		self.handCards[i] = cardNode.create(cardValues[i])
		cardDataMgr.handValues[i] = cardValues[i]
		self.handCards[i]:setPositionX(girl.posx[i])

		self.stndNode[1]:addChild(self.handCards[i])
		--self.stndNode[1]:retain()
		self.handCards[i].sn = i
		self.handCards[i].clickTimes = 0

-- self.handCards[i].btnBg:onClicked(
		-- 	function ()
		-- 		-- self.handCards[i].clickTimes = self.handCards[i].clickTimes + 1
		-- 		-- if self.handCards[i].clickTimes == 1 then
		-- 		-- 	self.handCards[i]:setPositionY(30)
		-- 		-- elseif self.handCards[i].clickTimes == 2 then
		-- 		-- 	--self.handCards[i].clickTimes == 0

	end

	if drawCardValue ~= 0 then
		self:createCardDraw(drawCardValue)	
	else
		self.imgTouchCard:setTouchEnabled(false)
	end

end


return CardManager
