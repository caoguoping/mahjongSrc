--  创建房间弹出界面--
local CURRENT_MODULE_NAME = ...
local dataMgr = import(".DataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()

local ZhanJiBox = class("ZhanJiBox", display.newLayer)
function ZhanJiBox:ctor()
    local rootNode = cc.CSLoader:createNode("ZhanJiBox.csb"):addTo(self)
    self.rootNode = rootNode
    rootNode:setPosition(display.center)
    layerMgr.LoginScene:addChild(self, 10000)
  
    --流水按钮、总分按钮、规则按钮、分享按钮、关闭按钮
	local btnclose = rootNode:getChildByName("Button_close")
    local btnliushui = rootNode:getChildByName("Node_liushui"):getChildByName("Button_liushui")
    local btnzongfen = rootNode:getChildByName("Node_zongfen"):getChildByName("Button_zongfen")
    local btnguizhe = rootNode:getChildByName("Node_guizhe"):getChildByName("Button_guizhe")
    local ListView_liushui = rootNode:getChildByName("ListView_liushui")
	local Image_zongfen = rootNode:getChildByName("Image_zongfen")
	local Image_guize = rootNode:getChildByName("Image_guize")

	local AllNum = {} ---计算玩家的总分
	for i=1,4 do
        AllNum[i] = {}
		AllNum[i].name = "as"
		AllNum[i].dwUserID = 0
		AllNum[i].lScore = 0
		AllNum[i].winnum = 0     
     end
    ---读一场游戏结算数据
    --获取本场游戏记录的KEY值，即HistroyRecords的最后一条数据，游戏一局结算后插入该值，0、没有开局
    local count = dataMgr.ThisTableRecords
	print("....................."..count)
	if count == 0 then--没有数据
		rootNode:getChildByName("Node_liushui"):getChildByName("Image_1"):setVisible(true)
		rootNode:getChildByName("Node_liushui"):getChildByName("Image_2"):setVisible(false)
		rootNode:getChildByName("Node_zongfen"):getChildByName("Image_1"):setVisible(false)
		rootNode:getChildByName("Node_zongfen"):getChildByName("Image_2"):setVisible(true)
		rootNode:getChildByName("Node_guizhe"):getChildByName("Image_1"):setVisible(false)
		rootNode:getChildByName("Node_guizhe"):getChildByName("Image_2"):setVisible(true)
		rootNode:getChildByName("ListView_liushui"):setPosition(cc.p(3000, 2000))
		rootNode:getChildByName("Image_zongfen"):setPosition(cc.p(3000, 2000))
		rootNode:getChildByName("Image_guize"):setPosition(cc.p(3000, 2000))       
	else
	--有数据
		rootNode:getChildByName("Text_57"):setVisible(false)
		rootNode:getChildByName("Node_liushui"):getChildByName("Image_1"):setVisible(true)
		rootNode:getChildByName("Node_liushui"):getChildByName("Image_2"):setVisible(false)
		rootNode:getChildByName("Node_zongfen"):getChildByName("Image_1"):setVisible(false)
		rootNode:getChildByName("Node_zongfen"):getChildByName("Image_2"):setVisible(true)
		rootNode:getChildByName("Node_guizhe"):getChildByName("Image_1"):setVisible(false)
		rootNode:getChildByName("Node_guizhe"):getChildByName("Image_2"):setVisible(true)
		rootNode:getChildByName("ListView_liushui"):setPosition(cc.p(-467.00, -293.00))
		rootNode:getChildByName("Image_zongfen"):setPosition(cc.p(3000, 2000))
		rootNode:getChildByName("Image_guize"):setPosition(cc.p(3000, 2000))
		
		local Hcount = 0  
		for k,v in ipairs(dataMgr.HistroyRecords[count].Records) do  
		Hcount = Hcount + 1
		end
		--流水
		local itemHeigth = 108
		local itemWidth = 934
		for i=1,Hcount do  --
			local oneNode = cc.CSLoader:createNode("ZhanjiHeadList.csb")
			local num = oneNode:getChildByName("Text_9")
			local txtfen1 = oneNode:getChildByName("fen_1")
			local txtfen2 = oneNode:getChildByName("fen_2")
			local txtfen3 = oneNode:getChildByName("fen_3")
			local txtfen4 = oneNode:getChildByName("fen_4")
			local headimg1 = oneNode:getChildByName("FileNode_1"):getChildByName("Image_head")
			local headimg2 = oneNode:getChildByName("FileNode_2"):getChildByName("Image_head")
			local headimg3 = oneNode:getChildByName("FileNode_3"):getChildByName("Image_head")
			local headimg4 = oneNode:getChildByName("FileNode_4"):getChildByName("Image_head")
			local name1 = oneNode:getChildByName("FileNode_1"):getChildByName("name_Text")
			local name2 = oneNode:getChildByName("FileNode_2"):getChildByName("name_Text")
			local name3 = oneNode:getChildByName("FileNode_3"):getChildByName("name_Text")
			local name4 = oneNode:getChildByName("FileNode_4"):getChildByName("name_Text")
			num:setString(i)
				local hhhcount = 0
				for k,v in ipairs(dataMgr.HistroyRecords[count].Records[i]) do  
				hhhcount = hhhcount + 1
				end
				print("hhhcount:::::",hhhcount)
				txtfen1:setString(dataMgr.HistroyRecords[count].Records[i].lScore1)
				print("lScore1"..dataMgr.HistroyRecords[count].Records[i].lScore1)
				--headimg1:setString(self.zhangJiData)
				name1:setString(dataMgr.HistroyRecords[count].Records[i].username1)
				print("username1"..dataMgr.HistroyRecords[count].Records[i].username1)
				if dataMgr.HistroyRecords[count].Records[i].lScore1 > 0 then
					AllNum[1].winnum = AllNum[1].winnum + 1
				end
				AllNum[1].name = dataMgr.HistroyRecords[count].Records[i].username1
				AllNum[1].dwUserID = dataMgr.HistroyRecords[count].Records[i].dwUserID1
				AllNum[1].lScore = AllNum[1].lScore + dataMgr.HistroyRecords[count].Records[i].lScore1
				---
				txtfen2:setString(dataMgr.HistroyRecords[count].Records[i].lScore2)
				name2:setString(dataMgr.HistroyRecords[count].Records[i].username2)
				if dataMgr.HistroyRecords[count].Records[i].lScore2 > 0 then
					AllNum[2].winnum = AllNum[2].winnum + 1
				end
				AllNum[2].name = dataMgr.HistroyRecords[count].Records[i].username2
				AllNum[2].dwUserID = dataMgr.HistroyRecords[count].Records[i].dwUserID2
				AllNum[2].lScore = AllNum[2].lScore + dataMgr.HistroyRecords[count].Records[i].lScore2
				------
				txtfen3:setString(dataMgr.HistroyRecords[count].Records[i].lScore3)
				name3:setString(dataMgr.HistroyRecords[count].Records[i].username3)
				if dataMgr.HistroyRecords[count].Records[i].lScore3 > 0 then
					AllNum[3].winnum = AllNum[3].winnum + 1
				end
				AllNum[3].name = dataMgr.HistroyRecords[count].Records[i].username3
				AllNum[3].dwUserID = dataMgr.HistroyRecords[count].Records[i].dwUserID3
				AllNum[3].lScore = AllNum[3].lScore + dataMgr.HistroyRecords[count].Records[i].lScore3
				-----
				txtfen4:setString(dataMgr.HistroyRecords[count].Records[i].lScore4)
				name4:setString(dataMgr.HistroyRecords[count].Records[i].username4)
				if dataMgr.HistroyRecords[count].Records[i].lScore4 > 0 then
					AllNum[4].winnum = AllNum[4].winnum + 1
				end
				AllNum[4].name = dataMgr.HistroyRecords[count].Records[i].username4
				AllNum[4].dwUserID = dataMgr.HistroyRecords[count].Records[i].dwUserID4
				AllNum[4].lScore = AllNum[4].lScore + dataMgr.HistroyRecords[count].Records[i].lScore4
		
			local oneLayout = ccui.Layout:create()
            oneLayout:addChild(oneNode)
            oneNode:setPosition(cc.p(itemWidth * 0.5, -itemHeigth * 0.5))
            ListView_liushui:setItemsMargin(itemHeigth + 6)
            ListView_liushui:pushBackCustomItem(oneLayout)
		    --ListView_liushui:pushBackCustomItem(ccui.Layout:create())  --bugs fake
		end
		ListView_liushui:pushBackCustomItem(ccui.Layout:create())  --bugs fake
		----------------总分排行榜的显示
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
			--显示重新排序后的数据
			Image_zongfen:getChildByName("Text_num_1"):setString(AllNum[1].winnum)
			Image_zongfen:getChildByName("Text_fen_1"):setString(AllNum[1].lScore)
			Image_zongfen:getChildByName("FileNode_6"):getChildByName("name_Text"):setString(AllNum[1].name)
			--Image_zongfen:getChildByName("FileNode_6"):getChildByName("Image_head")
			Image_zongfen:getChildByName("Text_num_2"):setString(AllNum[2].winnum)
			Image_zongfen:getChildByName("Text_fen_2"):setString(AllNum[2].lScore)
			Image_zongfen:getChildByName("FileNode_6_0"):getChildByName("name_Text"):setString(AllNum[2].name)

			Image_zongfen:getChildByName("Text_num_3"):setString(AllNum[3].winnum)
			Image_zongfen:getChildByName("Text_fen_3"):setString(AllNum[3].lScore)
			Image_zongfen:getChildByName("FileNode_6_1"):getChildByName("name_Text"):setString(AllNum[3].name)

			Image_zongfen:getChildByName("Text_num_4"):setString(AllNum[4].winnum)
			Image_zongfen:getChildByName("Text_fen_4"):setString(AllNum[4].lScore)
			Image_zongfen:getChildByName("FileNode_6_2"):getChildByName("name_Text"):setString(AllNum[4].name)
		
	end



		btnliushui:onClicked(
		function()
		if count == 0 then
			rootNode:getChildByName("Node_liushui"):getChildByName("Image_1"):setVisible(true)
			rootNode:getChildByName("Node_liushui"):getChildByName("Image_2"):setVisible(false)
			rootNode:getChildByName("Node_zongfen"):getChildByName("Image_1"):setVisible(false)
			rootNode:getChildByName("Node_zongfen"):getChildByName("Image_2"):setVisible(true)
			rootNode:getChildByName("Node_guizhe"):getChildByName("Image_1"):setVisible(false)
			rootNode:getChildByName("Node_guizhe"):getChildByName("Image_2"):setVisible(true)
			rootNode:getChildByName("Text_57"):setVisible(true)
			rootNode:getChildByName("Image_guize"):setPosition(cc.p(3000, 2000))
		else
			rootNode:getChildByName("Node_liushui"):getChildByName("Image_1"):setVisible(true)
			rootNode:getChildByName("Node_liushui"):getChildByName("Image_2"):setVisible(false)
			rootNode:getChildByName("Node_zongfen"):getChildByName("Image_1"):setVisible(false)
			rootNode:getChildByName("Node_zongfen"):getChildByName("Image_2"):setVisible(true)
			rootNode:getChildByName("Node_guizhe"):getChildByName("Image_1"):setVisible(false)
			rootNode:getChildByName("Node_guizhe"):getChildByName("Image_2"):setVisible(true)

			rootNode:getChildByName("ListView_liushui"):setPosition(cc.p(-467.00, -293.00))
			rootNode:getChildByName("Image_zongfen"):setPosition(cc.p(3000, 2000))
			rootNode:getChildByName("Image_guize"):setPosition(cc.p(3000, 2000))
		end
		end)

		btnzongfen:onClicked(
		function()
		if count == 0 then
			rootNode:getChildByName("Node_liushui"):getChildByName("Image_1"):setVisible(false)
			rootNode:getChildByName("Node_liushui"):getChildByName("Image_2"):setVisible(true)
			rootNode:getChildByName("Node_zongfen"):getChildByName("Image_1"):setVisible(true)
			rootNode:getChildByName("Node_zongfen"):getChildByName("Image_2"):setVisible(false)
			rootNode:getChildByName("Node_guizhe"):getChildByName("Image_1"):setVisible(false)
			rootNode:getChildByName("Node_guizhe"):getChildByName("Image_2"):setVisible(true)
			rootNode:getChildByName("Text_57"):setVisible(true)
			rootNode:getChildByName("Image_guize"):setPosition(cc.p(3000, 2000))
		else
			rootNode:getChildByName("Node_liushui"):getChildByName("Image_1"):setVisible(false)
			rootNode:getChildByName("Node_liushui"):getChildByName("Image_2"):setVisible(true)
			rootNode:getChildByName("Node_zongfen"):getChildByName("Image_1"):setVisible(true)
			rootNode:getChildByName("Node_zongfen"):getChildByName("Image_2"):setVisible(false)
			rootNode:getChildByName("Node_guizhe"):getChildByName("Image_1"):setVisible(false)
			rootNode:getChildByName("Node_guizhe"):getChildByName("Image_2"):setVisible(true)

			rootNode:getChildByName("ListView_liushui"):setPosition(cc.p(3000, 2000))
			rootNode:getChildByName("Image_zongfen"):setPosition(cc.p(0, -70.00))
			rootNode:getChildByName("Image_guize"):setPosition(cc.p(3000, 2000))
		end
		end)

		btnguizhe:onClicked(
		function()
		rootNode:getChildByName("Text_57"):setVisible(false)
		rootNode:getChildByName("Node_liushui"):getChildByName("Image_1"):setVisible(false)
		rootNode:getChildByName("Node_liushui"):getChildByName("Image_2"):setVisible(true)
		rootNode:getChildByName("Node_zongfen"):getChildByName("Image_1"):setVisible(false)
		rootNode:getChildByName("Node_zongfen"):getChildByName("Image_2"):setVisible(true)
		rootNode:getChildByName("Node_guizhe"):getChildByName("Image_1"):setVisible(true)
		rootNode:getChildByName("Node_guizhe"):getChildByName("Image_2"):setVisible(false)

		rootNode:getChildByName("ListView_liushui"):setPosition(cc.p(3000, 2000))
		rootNode:getChildByName("Image_zongfen"):setPosition(cc.p(3000, 2000))
		rootNode:getChildByName("Image_guize"):setPosition(cc.p(0, -70.00))
		end)
		btnclose:onClicked(
        function (  )
             --TTSocketClient:getInstance():closeMySocket(netTb.SocketType.Game)
            self:removeSelf()
        end)
end



function ZhanJiBox:init(  )
    -- body
end

function ZhanJiBox.create(  )
    return ZhanJiBox.new()
end
return ZhanJiBox
