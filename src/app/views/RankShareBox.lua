--  创建房间弹出界面--
local CURRENT_MODULE_NAME = ...
local dataMgr = import(".DataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()

local RankShareBox = class("RankShareBox", display.newLayer)
function RankShareBox:ctor()
    local rootNode = cc.CSLoader:createNode("RankShare.csb"):addTo(self)
    self.rootNode = rootNode
    rootNode:setPosition(display.center)
    layerMgr.LoginScene:addChild(self, 10000)
  
    --流水按钮、总分按钮、规则按钮、分享按钮、关闭按钮
	local btnclose = rootNode:getChildByName("Button_close")
	local ShareToWX = rootNode:getChildByName("Button_wx")
	local ShareToFriends = rootNode:getChildByName("Button_pyq")

	---一场总数据的排名
    local RankData = rootNode:getChildByName("Node_chang")
    local firstUserName = RankData:getChildByName("FileNode_1"):getChildByName("name_Text")
    local secondUserName = RankData:getChildByName("FileNode_2"):getChildByName("name_Text")
	local threeUserName = RankData:getChildByName("FileNode_3"):getChildByName("name_Text")
	local fourUserName = RankData:getChildByName("FileNode_4"):getChildByName("name_Text")
	local firstUserdj = RankData:getChildByName("Text_dj_1")
    local secondUserdj = RankData:getChildByName("Text_dj_2")
	local threeUserdj = RankData:getChildByName("Text_dj_3")
	local fourUserdj = RankData:getChildByName("Text_dj_4")
	local firstUserfen = RankData:getChildByName("Text_1")
    local secondUserfen = RankData:getChildByName("Text_2")
	local threeUserfen = RankData:getChildByName("Text_3")
	local fourUserfen = RankData:getChildByName("Text_4")
	local cangkaihuai = RankData:getChildByName("Image_5_ckh")
	local jinyuanzi = RankData:getChildByName("Image_5_jyz")






-----
	local AllNum = {} ---统计玩家的总分表
	for i=1,4 do
        AllNum[i] = {}
		AllNum[i].name = "as"
		AllNum[i].dwUserID = 0
		AllNum[i].lScore = 0
		AllNum[i].winnum = 0     
    end
	print("dataMgr.RankShareIdex::::",dataMgr.RankShareIdex)
	
	----检索该表的数据条数
	local Hcount = 0  
	for k,v in ipairs(dataMgr.HistroyRecords[dataMgr.RankShareIdex].Records) do  
	Hcount = Hcount + 1
	end
	----进园子1 敞开怀2
	local cbType = dataMgr.HistroyRecords[dataMgr.RankShareIdex].cbType

	for i=1,Hcount do		---对AllNum{}进行赋值
		if dataMgr.HistroyRecords[dataMgr.RankShareIdex].Records[i].lScore1 > 0 then
			AllNum[1].winnum = AllNum[1].winnum + 1
		end
		AllNum[1].name = dataMgr.HistroyRecords[dataMgr.RankShareIdex].Records[i].username1
		AllNum[1].dwUserID = dataMgr.HistroyRecords[dataMgr.RankShareIdex].Records[i].dwUserID1
		AllNum[1].lScore = AllNum[1].lScore + dataMgr.HistroyRecords[dataMgr.RankShareIdex].Records[i].lScore1
		if dataMgr.HistroyRecords[dataMgr.RankShareIdex].Records[i].lScore2 > 0 then
			AllNum[2].winnum = AllNum[2].winnum + 1
		end
		AllNum[2].name = dataMgr.HistroyRecords[dataMgr.RankShareIdex].Records[i].username2
		AllNum[2].dwUserID = dataMgr.HistroyRecords[dataMgr.RankShareIdex].Records[i].dwUserID2
		AllNum[2].lScore = AllNum[2].lScore + dataMgr.HistroyRecords[dataMgr.RankShareIdex].Records[i].lScore2
		if dataMgr.HistroyRecords[dataMgr.RankShareIdex].Records[i].lScore3 > 0 then
			AllNum[3].winnum = AllNum[3].winnum + 1
		end
		AllNum[3].name = dataMgr.HistroyRecords[dataMgr.RankShareIdex].Records[i].username3
		AllNum[3].dwUserID = dataMgr.HistroyRecords[dataMgr.RankShareIdex].Records[i].dwUserID3
		AllNum[3].lScore = AllNum[3].lScore + dataMgr.HistroyRecords[dataMgr.RankShareIdex].Records[i].lScore3
		if dataMgr.HistroyRecords[dataMgr.RankShareIdex].Records[i].lScore4 > 0 then
			AllNum[4].winnum = AllNum[4].winnum + 1
		end
		AllNum[4].name = dataMgr.HistroyRecords[dataMgr.RankShareIdex].Records[i].username4
		AllNum[4].dwUserID = dataMgr.HistroyRecords[dataMgr.RankShareIdex].Records[i].dwUserID4
		AllNum[4].lScore = AllNum[4].lScore + dataMgr.HistroyRecords[dataMgr.RankShareIdex].Records[i].lScore4	
	end
		----------------总分排行榜的显示
		----对AllNum重新排序
	for i1 = 1,4 do
		local min = AllNum[i1].lScore
		for j = 1,3 do --重新排序，根据总分从大到小
			if min >= AllNum[j].lScore then
			local atnum = AllNum[i1]
			AllNum[i1] = AllNum[j]
			AllNum[j] = atnum
			end
		end
	end
    firstUserName:setString(AllNum[1].name)
    secondUserName:setString(AllNum[2].name)
	threeUserName:setString(AllNum[3].name)
	fourUserName:setString(AllNum[4].name)
	firstUserdj:setString(AllNum[1].winnum)
    secondUserdj:setString(AllNum[2].winnum)
	threeUserdj:setString(AllNum[3].winnum)
	fourUserdj:setString(AllNum[4].winnum)
	firstUserfen:setString(AllNum[1].lScore)
    secondUserfen:setString(AllNum[2].lScore)
	threeUserfen:setString(AllNum[3].lScore)
	fourUserfen:setString(AllNum[4].lScore)


	--头像   added by caoguoping
	self.imgHead = {}  --按从上到下的顺序，1,2,3,4
	for i=1,4 do
		self.imgHead[i] = RankData:getChildByName("FileNode_"..i):getChildByName("Image_head")
		local svrId = dataMgr:getSvrIdByUserId(AllNum[i].dwUserID)
		local clientId = dataMgr.chair[svrId]
		local HeadPath =  cc.FileUtils:getInstance():getWritablePath().."headImage_"..clientId..".png"
        local headSize = self.imgHead[i]:getContentSize()
        local sp2 = display.createCircleSprite(HeadPath, "headshot_example.png"):addTo(self.imgHead[i])
        sp2:setPosition(headSize.width * 0.5, headSize.height * 0.5)

	end




	if cbType ==1 then
	jinyuanzi:setVisible(true)
	cangkaihuai:setVisible(false)
	elseif cbType ==2 then
	jinyuanzi:setVisible(false)
	cangkaihuai:setVisible(true)
	end

-------
	ShareToFriends:onClicked(
	function()
	
	end)
	ShareToWX:onClicked(
	function()
	
	end)
	btnclose:onClicked(
	function (  )
		TTSocketClient:getInstance():closeMySocket(netTb.SocketType.Game)
		self:removeSelf()
		 --清理手牌
		local playLayer = layerMgr:getLayer(layerMgr.layIndex.PlayLayer, params)
        playLayer:refresh()
        layerMgr:showLayer(layerMgr.layIndex.MainLayer, params)

	end)
end



function RankShareBox:init(  )
    -- body
end

function RankShareBox.create(  )
    return RankShareBox.new()
end
return RankShareBox