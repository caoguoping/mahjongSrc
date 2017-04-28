--  结算弹出界面--
local CURRENT_MODULE_NAME = ...
local dataMgr     = import(".DataManager"):getInstance()
local cardDataMgr     = import(".CardDataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()
local musicMgr = import(".MusicManager"):getInstance()



local JiesuanBox = class("JiesuanBox", display.newLayer)
function JiesuanBox:ctor()
    local rootNode = cc.CSLoader:createNode("jiesuan.csb"):addTo(self)
    self.rootNode = rootNode
    rootNode:setPosition(display.center)
    layerMgr.LoginScene:addChild(self, 10000)
  
    --返回按钮、继续游戏按钮、分享按钮
    local btnBack = rootNode:getChildByName("Button_back")
    self.btnContiue = rootNode:getChildByName("Button_contiue")
    local btnShare = rootNode:getChildByName("Button_share")

    --返回按钮、
    btnBack:onClicked(
    function()
        musicMgr:playEffect("game_button_click.mp3", false)
        local mainlayer = layerMgr:getLayer(layerMgr.layIndex.MainLayer)
        mainlayer:btnCreateOrBack(true)

        dataMgr.isNormalEnd = true
--        musicMgr:playMusic("bg.mp3", true)
        layerMgr:showLayer(layerMgr.layIndex.MainLayer, params)
        TTSocketClient:getInstance():closeMySocket(netTb.SocketType.Game)
        self:removeSelf()
    end)

    --继续游戏按钮
    self.btnContiue:onClicked(
    function()
        musicMgr:playEffect("game_button_click.mp3", false)
        dataMgr.isNormalEnd = true
        print("btnContiue") 
        local snd = DataSnd:create(100, 2)
        snd:sendData(netTb.SocketType.Game)
        snd:release();
        dataMgr.playerStatus = 0    --回到游戏前状态
        self:removeSelf()

        --显示剩余钱
        local playlayer = layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params)
        for i=1,4 do
            local svrId = dataMgr:getServiceChairId(i)
            playlayer.txtScore[i]:setString(dataMgr.onDeskData[svrId].LeftMoney)
        end



    end)

    --、分享按钮
    btnShare:onClicked(
    function()
        -- musicMgr:playEffect("game_button_click.mp3", false)
        -- dataMgr.isNormalEnd = true
        -- print("btnShare") 
        -- self:removeSelf()
    end)

    --顶部自摸、流局、点胡()
    local topNode= rootNode:getChildByName("TopNode")
    
    self.topImgs = {}   -- 1-5
    self.topImgs[1]  = topNode:getChildByName("win_dianhu") --本家是赢家显示
    self.topImgs[2]    = topNode:getChildByName("win_zimo") --
    self.topImgs[3] = topNode:getChildByName("lost_dianhu") --点胡  --本家为输家显示
    self.topImgs[4]   = topNode:getChildByName("lost_zimo")   --自摸
    self.topImgs[5]      = topNode:getChildByName("liuju")--流局
     --翻型下拉
    self.listFanXing = rootNode:getChildByName("ListView_fanxing")

    --只有我赢了才显示
    self.nodeIsMeWin = rootNode:getChildByName("Node_isMeWin")

    local nodeHead = {}   --3家头像节点, clientId 1,2,3,4去掉赢的人
    self.imgHead = {} 
    self.txtName = {}
    self.txtScore = {}
    self.imgClient = {}  --本家，上，对，下
    self.imgIsBaopai = {}


    --下标为下排三个头像，从左到右1,2,3
    for i=1,3 do
        local tempName = "FileNode_head_"..i
        nodeHead[i] = rootNode:getChildByName(tempName) 
        self.imgHead[i] = nodeHead[i]:getChildByName("Image_head")  --头像
        self.imgClient[i] = nodeHead[i]:getChildByName("img_myself")
        self.imgIsBaopai[i] = nodeHead[i]:getChildByName("img_baopai")
        self.imgIsBaopai[i]:setVisible(false)
        self.txtName[i] = nodeHead[i]:getChildByName("name_Text")
        self.txtScore[i] = nodeHead[i]:getChildByName("fen_Text")
    end

    --赢家
    self.imgHeadWin = rootNode:getChildByName("Image_headWin")
    self.imgBenjia = rootNode:getChildByName("img_myself")
    self.txtNameWin = rootNode:getChildByName("Text_myName")


  --在Node_isMeWin节点下,大写的分数，只有我赢了才显示
    self.txtScoreWin = self.nodeIsMeWin:getChildByName("AtlasLabel_bigScore") 
    self.nodePengMe = rootNode:getChildByName("FileNode_pengMe")
        --碰牌  四个一组,pengCell[1][1][1]，共四组，5,6为13,14张

    self.pengCell = {}
    self.pengCellFace = {}
    self.pengCell[5] =  self.nodePengMe:getChildByName("Image13")
    self.pengCell[6] =  self.nodePengMe:getChildByName("Image14")
    self.pengCellFace[5] =  self.pengCell[5]:getChildByName("Image_face")
    self.pengCellFace[6] =  self.pengCell[6]:getChildByName("Image_face")
    for j = 1, 4 do
        local nodeName = "Node_"..j
        local nd =  self.nodePengMe:getChildByName(nodeName)
        self.pengCell[j] = {}
        self.pengCellFace[j] = {}

        for k = 1, 4 do
            local imgName = "Image"..k
            self.pengCell[j][k] = nd:getChildByName(imgName)
            self.pengCellFace[j][k] = self.pengCell[j][k]:getChildByName("Image_face")
            --self.pengCell[i][j][k]:setVisible(false)
        end
    end

end

function JiesuanBox:initData( gameEndData )

    local mySvrId = dataMgr:getServiceChairId(1)  --已转 我 1，到4

    local winClient = 1   --要显示的赢家的客户端ID,默认是自己
    local winSvr = mySvrId     
    local fanSave = gameEndData.wFanCount[winSvr]

    for i=2,4 do  --i 为客户端id
        local tempWinSvr = dataMgr:getServiceChairId(i)
        
        if gameEndData.wFanCount[tempWinSvr] > fanSave then
            winSvr = tempWinSvr
            winClient = i
            fanSave = gameEndData.wFanCount[tempWinSvr]
        end
       -- print("\n\n\ntempWinSvr "..tempWinSvr.." fanSave "..fanSave.."  i  "..i.." winClient "..winClient)
    end

--流局
    if fanSave == 0 then  --流局
        self:setTopImg(5)
        self.nodeIsMeWin:setVisible(false)
        self.nodePengMe:setVisible(false)
        return
    end


    local pengGangNum = 0
    --杠
    for i=1,4 do
        if girl.isCardValue(gameEndData.cbCardGang[winSvr][i]) then
            pengGangNum = pengGangNum + 1
            for j=1,4 do
                self.pengCell[pengGangNum][j]:setVisible(true)
                self.pengCellFace[pengGangNum][j]:setVisible(true)
                self.pengCellFace[pengGangNum][j]:loadTexture(gameEndData.cbCardGang[winSvr][i]..".png")
            end
        else
           break
        end
    end

    --碰
    for i=1,4 do
        if girl.isCardValue(gameEndData.cbCardPeng[winSvr][i]) then
            pengGangNum = pengGangNum + 1
            for j=1,3 do
                --self.pengCellFace[pengGangNum][j]:setVisible(true)
                self.pengCellFace[pengGangNum][j]:loadTexture(gameEndData.cbCardPeng[winSvr][i]..".png")
            end
        else
           break
        end
    end

    --手牌
    local winHandCount = gameEndData.cbCardCount[winSvr]
    self.pengCellFace[5]:loadTexture(gameEndData.cbCardData[winSvr][winHandCount  - 1]..".png")  --第13张
    self.pengCellFace[6]:loadTexture(gameEndData.cbCardData[winSvr][winHandCount]..".png")          --第14张
  
   -- local leftDui = (winHandCount - 2) / 3     --剩下的堆
   
    pengGangNum = pengGangNum + 1  --接着的节点显示 ,已碰 + 1
    for i=pengGangNum, 4 do    
        for j=1,3 do
            self.pengCellFace[i][j]:loadTexture(gameEndData.cbCardData[winSvr][(i - pengGangNum)* 3 + j]..".png")  
        end
    end

--显示名称
    --赢家
    self.txtNameWin:setString(dataMgr.onDeskData[winSvr].szNickName)
    
    --赢家头像
    local winHeadPath =  cc.FileUtils:getInstance():getWritablePath().."headImage_"..winClient..".png"
    local headSize = self.imgHeadWin:getContentSize()
    local sp = display.createCircleSprite(winHeadPath, "headshot_example.png"):addTo(self.imgHeadWin)
    sp:setPosition(headSize.width * 0.5, headSize.height * 0.5)
    
    if mySvrId == winSvr then
        self.imgBenjia:setVisible(true)
    else
        self.imgBenjia:setVisible(false)
    end

    local leftSvr = {}  --下标为1,2,3, 值为服务器Id(剔除了赢家)
    local svrIndex = 1
    for i=1,4 do
        if i ~= winSvr then
            leftSvr[svrIndex] = i
            svrIndex = svrIndex + 1
        end
    end
    for i=1,3 do  --下标为1,2,3(对应图形）,   值为服务器ID（对应数据）
        local svrIndex = leftSvr[i]
        local clientId = dataMgr.chair[svrIndex]  --客户端id
        --显示名称
        self.txtName[i]:setString(dataMgr.onDeskData[svrIndex].szNickName)
        --显示分数
        self.txtScore[i]:setString(tostring(gameEndData.lGameScore[svrIndex]))
        self.imgClient[i]:setVisible(false)   --本家

        --剩余三家头像，
        local HeadPath =  cc.FileUtils:getInstance():getWritablePath().."headImage_"..clientId..".png"
        local headSize = self.imgHead[i]:getContentSize()
        local sp2 = display.createCircleSprite(HeadPath, "headshot_example.png"):addTo(self.imgHead[i])
        sp2:setPosition(headSize.width * 0.5, headSize.height * 0.5)

        --自己
        if svrIndex == mySvrId then
            self.imgClient[i]:setVisible(true)    --本家
        end
    end

--一定有赢家
    local isMeWin = 0   --自己是否胡牌， 1，胡牌

   -- print("gameEndData.dwChiHuKind[mySvrId] "..gameEndData.dwChiHuKind[mySvrId])
    if gameEndData.dwChiHuKind[mySvrId] ~= 0 then
       isMeWin = 1
    else
        self.nodeIsMeWin:setVisible(false)  --输了
    end

    --赢家翻型掩码
    local winMask = gameEndData.dwChiHuRight[winSvr][1]
    local fanxingTb = girl.getDWORDTable(winMask)
    local isZimo = 0  -- 0 点胡，  1， 自摸
    if fanxingTb[1] == 1 then   --第一位自摸
        isZimo = 1
    end

    --显示顶部
    if isMeWin == 0 then  --lose
        self:setTopImg(2 + isZimo + 1)
        self.nodeIsMeWin:setVisible(false)
        musicMgr:playEffect("lose.mp3", false)
    else
        --赢了
        musicMgr:playEffect("win.mp3", false)
        self:setTopImg(isZimo + 1)
        self.txtScoreWin:setString(tostring(gameEndData.lGameScore[winSvr])  ) 
    end

    --self.listFanXing
    local itemHeigth = 50
    local itemWidth = 663
    self.listFanXing:setItemsMargin(itemHeigth + 6)

    local funcFanxing = function (fangxingName,  fangxingValue)
        local oneNode = cc.CSLoader:createNode("jiesuanFanxing.csb")
        local txtFangxin = oneNode:getChildByName("Text_string")
        local txtNum     = oneNode:getChildByName("Text_num")
        txtFangxin:setString(fangxingName)
        txtNum:setString(fangxingValue)
        local oneLayout = ccui.Layout:create()
        oneLayout:addChild(oneNode)
        oneNode:setPosition(cc.p(itemWidth * 0.5, -itemHeigth * 0.5))
        self.listFanXing:pushBackCustomItem(oneLayout)
    end

--胡牌10翻
    -- local oneNode = cc.CSLoader:createNode("jiesuanFanxing.csb")
    -- local txtFangxin = oneNode:getChildByName("Text_string")
    -- local txtNum     = oneNode:getChildByName("Text_num")
    -- if true then   --有相应的翻型
    --     txtFangxin:setString(fxString[1])
    --     txtNum:setString(fxValue[1])
    --     local oneLayout = ccui.Layout:create()
    --     oneLayout:addChild(oneNode)
    --     oneNode:setPosition(cc.p(itemWidth * 0.5, -itemHeigth * 0.5))
    --     self.listFanXing:setItemsMargin(itemHeigth + 6)
    --     self.listFanXing:pushBackCustomItem(oneLayout)
-- end

    for i=4,17 do  --对对胡，到门清

        if fanxingTb[i] == 1 then   --有相应的翻型
            funcFanxing(fxString[i], fxValue[i])
        end
    end

    --胡牌10翻
    funcFanxing(fxString[1], fxValue[1])

    for i=18,25 do  --压档等小翻
        if fanxingTb[i] == 1 then   --有相应的翻型
            funcFanxing(fxString[i], fxValue[i])
        end
    end

    --花牌个数
    if dataMgr.roomSet.bZaEr == 1 then
        funcFanxing(fxString[31], "+ "..cardDataMgr.huaNum[dataMgr.chair[winSvr]] * 2)
    else
        funcFanxing(fxString[30], "+ "..cardDataMgr.huaNum[dataMgr.chair[winSvr]])
    end

    --比下胡
    if cardDataMgr.cardSend.isBiXiaHu == 1 then
        funcFanxing(fxString[32], fxValue[32])
    end

    --cocos bugs fack
    self.listFanXing:pushBackCustomItem(ccui.Layout:create())  --bugs fake

end

function JiesuanBox.create(  )
    return JiesuanBox.new()
end

function JiesuanBox:setTopImg( index )  --1, 5, winDian ,winMo, loseDian, loseMo, liuju
   -- print("setTopImg index "..index)
    for i=1,5 do
         self.topImgs[i]:setVisible(false)
    end
    self.topImgs[index]:setVisible(true)
end

return JiesuanBox
