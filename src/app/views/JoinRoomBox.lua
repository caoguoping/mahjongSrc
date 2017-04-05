--  创建房间弹出界面--
local CURRENT_MODULE_NAME = ...
local dataMgr     = import(".DataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()


local JoinRoomBox = class("JoinRoomBox", display.newLayer)
function JoinRoomBox:ctor()
--all Node
    local rootNode = cc.CSLoader:createNode("joinRoom.csb"):addTo(self)
    self.rootNode = rootNode
    rootNode:setPosition(display.center)
    layerMgr.LoginScene:addChild(self, 10000)

--test
    local txUid = rootNode:getChildByName("TextField_uid")

--test end



    local btnClose = rootNode:getChildByName("Button_close")
    local imgMask = rootNode:getChildByName("Image_mask")
    imgMask:onClicked(
        function (  )
            self:removeSelf()
        end
        )
    btnClose:onClicked(
        function (  )
            self:removeSelf()
        end)

    self.txts = {}
    self.roomNum = {}  --7位数
    self.nowNum = 0  --已输入的房间位数
    for i=1,7 do
        local tmpStr = "Text_"..i
        self.txts[i] = rootNode:getChildByName(tmpStr)
    end

    local btns = {}
    for i=1,10 do
        local tmpStr = "Button_"..i
        btns[i] = rootNode:getChildByName(tmpStr)
        btns[i]:onClicked(
        function (  )
            self.nowNum = self.nowNum + 1;
            self.txts[self.nowNum]:setString(tostring(i - 1))
            self.txts[self.nowNum]:setVisible(true)
            self.roomNum[8 - self.nowNum] = i - 1
            
--cgpTest   实际上是进入成功1,102后执行，这边只执行连接游戏
            if self.nowNum == 7 then
                self.readRoomNum = girl.getAllDicimalValue(self.roomNum, 7)
                dataMgr.roomSet.dwRoomNum = self.readRoomNum

                self:startGame(netTb.ip, netTb.port.game, netTb.SocketType.Game)  


            end
        end
        )
    end

    local btnReput = rootNode:getChildByName("Button_re")
    btnReput:onClicked(
        function (  )
            self:reputRoomNum()
        end
        )

    local btnDelete = rootNode:getChildByName("Button_delete")
    btnDelete:onClicked(
        function (  )
            if self.nowNum < 1 then
               return
            else

                self.txts[self.nowNum]:setVisible(false)
                self.nowNum = self.nowNum - 1;
            end

        end
        )

    local btnOk = rootNode:getChildByName("Button_Ok")
    btnOk:onClicked(
        function (  )

            local strUid = txUid:getString()
            if #strUid < 7 then
                return
            else
                dataMgr.roomSet.dwRoomNum = tonumber(strUid)
                self.readRoomNum = dataMgr.roomSet.dwRoomNum 
                self:startGame(netTb.ip, netTb.port.game, netTb.SocketType.Game) 
            end
 

        end
        )

--关闭点击按钮
--test
    --dataMgr.roomSet.dwRoomNum = 0
    --self:startGame(netTb.ip, netTb.port.game, netTb.SocketType.Game) 
--test End
end

function JoinRoomBox:reputRoomNum(  )
    self.roomNum = {}  --7位数
    self.nowNum = 0  --已输入的房间位数
    for i=1,7 do
        self.txts[i]:setVisible(false)
    end
end

function JoinRoomBox:startGame(ip, port)
    TTSocketClient:getInstance():startSocket(ip, port, netTb.SocketType.Game)

    local snd = DataSnd:create(1, 1)
    local dwPlazaVersion = 65536
    local dwFrameVersion = 65536
    local dwProcessVersion = 65536
    local szPassword = uid
    local szMachineID = uid
    local wKindID = 3
    
--关闭点击按钮
--test
     local wTable = self.readRoomNum % 65536
     local wChair = (self.readRoomNum - wTable)/ 65536    

   -- local wTable = 0
   -- local wChair = 0
--test end
    --为密码，实际总的tableId为：wChair * 65536 + wTable
    --创建房间发满的，加入房间发实际的

    snd:wrDWORD(dwPlazaVersion)
    snd:wrDWORD(dwFrameVersion)
    snd:wrDWORD(dwProcessVersion)
    snd:wrDWORD(dataMgr.myBaseData.dwUserID)
    snd:wrString(szPassword, 66) 
    snd:wrString(szMachineID, 66) 
    snd:wrWORD(wKindID) 
    snd:wrWORD(wTable)  
    snd:wrWORD(wChair) 
    snd:sendData(netTb.SocketType.Game)
    snd:release();
end


function JoinRoomBox.create(  )
    return JoinRoomBox.new()
end

return JoinRoomBox
