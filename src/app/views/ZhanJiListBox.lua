--  创建房间弹出界面--
local CURRENT_MODULE_NAME = ...
local dataMgr = import(".DataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()

local ZhanJiListBox = class("ZhanJiListBox", display.newLayer)
function ZhanJiListBox:ctor()
    local rootNode = cc.CSLoader:createNode("ZhanJiListBox.csb"):addTo(self)
    self.rootNode = rootNode
    rootNode:setPosition(display.center)
    layerMgr.LoginScene:addChild(self, 10000)
  
    --关闭按钮、背景图片、数据列表
    local btnclose = rootNode:getChildByName("Button_close")
	---
	local Image_bg = rootNode:getChildByName("Image_21")
	local ListView_liushui = rootNode:getChildByName("ListView_liushui")
	
    ---读一场游戏结算数据
      --检测是否有数据
	  print("dataMgr.HistroyRecords.ItemCount",dataMgr.HistroyRecords.ItemCount)
	if dataMgr.HistroyRecords.ItemCount == 0 then--没有数据
		Image_bg:setPosition(cc.p(3000, 2000))
		ListView_liushui:setPosition(cc.p(3000, 2000))      
	else
		Image_bg:setPosition(cc.p(0, -30))
		ListView_liushui:setPosition(cc.p(-462.00, -276.00))
		--历史记录流水
		local itemHeigth = 66
		local itemWidth = 925
		for i=1,dataMgr.HistroyRecords.ItemCount do
			local oneNode = cc.CSLoader:createNode("ZhanJiInfolist.csb")
			local Image_btn = oneNode:getChildByName("Image_1")
			local Text_date = oneNode:getChildByName("Text_date")
			local Text_moshi = oneNode:getChildByName("Text_moshi")
			local Text_fangjianhao = oneNode:getChildByName("Text_fangjianhao")
			local Text_jifen = oneNode:getChildByName("Text_jifen")
				---解析房间号
			Text_date:setString(os.date("%Y/%m/%d %H:%M",dataMgr.HistroyRecords[i].wData))
			
			Text_fangjianhao:setString(dataMgr.HistroyRecords[i].wTableID)
				---获取积分
			Text_jifen:setString(dataMgr.HistroyRecords[i].lScore)
				--判断模式
			if dataMgr.HistroyRecords[i].cbType == 1 then
				Text_moshi:setString("进园子")
			else
				Text_moshi:setString("敞开怀")
			end
			local oneLayout = ccui.Layout:create()
            oneLayout:addChild(oneNode)
            oneNode:setPosition(cc.p(itemWidth * 0.5, -itemHeigth * 0.5))
            ListView_liushui:setItemsMargin(itemHeigth + 6)
            ListView_liushui:pushBackCustomItem(oneLayout)
		    --ListView_liushui:pushBackCustomItem(ccui.Layout:create())  --bugs fake
			Image_btn:onClicked(--根据对应KEY值查询详细信息				
			function()
				print("onClicked")
			    ---赋索引Key值
				dataMgr.IndexRecords = i
				print("dataMgr.IndexRecords",dataMgr.IndexRecords)
				---根据索引，检索该场数据是否存在
				if dataMgr.HistroyRecords[dataMgr.IndexRecords].Records == nil then
				dataMgr.HistroyRecords[dataMgr.IndexRecords].Records = {}
				end
				
				local Hcount = 0  
				for k,v in ipairs(dataMgr.HistroyRecords[dataMgr.IndexRecords].Records) do  
				Hcount = Hcount + 1 
				end
				print("Hcount",Hcount)
				---Hcount== 0 数据不存在，向服务器发送获取数据请求
				if Hcount == 0 then
					---打开详细信息界面
					local snd = DataSnd:create(1, 9)
					snd:wrInt32(dataMgr.HistroyRecords[i].wTableID)
					snd:wrInt32(dataMgr.HistroyRecords[i].wData)
					snd:wrInt32(dataMgr.myBaseData.dwUserID)
					snd:wrByte(0)
					snd:wrByte(0)   --坐下
					snd:wrByte(0)   --坐下
					snd:wrByte(0)
					snd:sendData(netTb.SocketType.Login)
					snd:release()
					print("DataSnd")
				end
				---打开详细信息界面
				layerMgr.boxes[layerMgr.boxIndex.ZhanJiListRecordsBox] = import(".ZhanJiListRecordsBox",CURRENT_MODULE_NAME).create()

			end)
		end
		ListView_liushui:pushBackCustomItem(ccui.Layout:create())  --bugs fake
	end
print("isclosed?1")
        --dataMgr.HistroyRecords[i].dwUserID
	btnclose:onClicked(
	function (  )
			--TTSocketClient:getInstance():closeMySocket(netTb.SocketType.Game)
		self:removeSelf()
	end)
end



function ZhanJiListBox:init(  )
    -- body
end

function ZhanJiListBox.create(  )
    return ZhanJiListBox.new()
end
return ZhanJiListBox