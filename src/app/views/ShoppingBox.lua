--  商城弹出界面--
local CURRENT_MODULE_NAME = ...
local dataMgr     = import(".DataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()
local musicMgr = import(".MusicManager"):getInstance()




local ShoppingBox = class("ShoppingBox", display.newLayer)
function ShoppingBox:ctor()
--all Node
    local rootNode = cc.CSLoader:createNode("shopping.csb"):addTo(self)
    self.rootNode = rootNode
    rootNode:setPosition(display.center)
    layerMgr.LoginScene:addChild(self, 10000)


    local btnClose = rootNode:getChildByName("Button_close")
        btnClose:onClicked(
        function (  )
            musicMgr:playEffect("game_button_click.mp3", false)
            local mainlayer = layerMgr:getLayer(layerMgr.layIndex.MainLayer)
            mainlayer:refresh()
            self:removeSelf()
        end)

    local cardMoney = {3, 5, 15, 50, 100, 520}
    local btns = {}
    for i=1,6 do
        local tmpStr = "Button__"..i     --两个“-”
        btns[i] = rootNode:getChildByName(tmpStr)
        btns[i]:onClicked(
        function (  )
            --print("buyCount")
            --Helpers:callWechatShareJoin("/sdcard/headshot_example.png","http://101.37.20.36:8383/index.html", dataMgr.roomSet.dwRoomNum , 0) 
            musicMgr:playEffect("game_button_click.mp3", false)

--随机数
            local time10 = os.time()
            local strOrder = tostring(time10)..dataMgr.weChat.mch_id..tostring(dataMgr.myBaseData.dwUserID)  --订单号

            local dwUserID = dataMgr.myBaseData.dwUserID
            local GameID   = 1                         --游戏ID
            local ServerID = 1                         --服务器ID
            local GoodsID  = 10                         --商品ＩＤ    10 房卡
            local NUM      = cardMoney[i]                          --房卡数量
            local Money    = i                        --人民币数量
            local MchID    = dataMgr.weChat.mch_id                          --商户ID
            local dwTime   = os.time()                     --订单生成时间
            local plateID  = 1                           --平台ID

            local snd = DataSnd:create(3, 853)
            snd:wrString(strOrder, 32)
            snd:wrDWORD(dwUserID )
            snd:wrDWORD(GameID   )
            snd:wrDWORD(ServerID )
            snd:wrDWORD(GoodsID  )
            snd:wrDWORD(NUM      )
            snd:wrDWORD(Money    )
            snd:wrDWORD(MchID    )
            snd:wrDWORD(dwTime   )
            snd:wrWORD(plateID   )
            snd:wrWORD(0)

            snd:sendData(netTb.SocketType.Login)
            snd:release()

            --调用微信支付
            if(device.platform == "android") then 
                self:callPay(i)
            end

        end
        )
    end
end

function ShoppingBox:callPay(indexs )
    --随机数
    local time10 = os.time()
    local time20 = math.random(1, 1000)
    local strNonce_str  = tostring(time10 * 1000 + time20)
    print("Nonce_str "..strNonce_str)
    dataMgr.weChat.nonce_str = strNonce_str

   --test for xmlHttp
   --商户号
    
    --print(tostring(time10))
    --print(dataMgr.weChat.mch_id)
    print("dwUserID "..tostring(dataMgr.myBaseData.dwUserID))
   
    local strOrder = tostring(time10)..dataMgr.weChat.mch_id..tostring(dataMgr.myBaseData.dwUserID)
    dataMgr.weChat.out_trade_no = strOrder
    print("strOrder", strOrder)

    local xmlHttpReq = cc.XMLHttpRequest:new()
    xmlHttpReq.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xmlHttpReq:open("POST", "http://gamecrm.nettl.cn/rest/get-pre")
    xmlHttpReq:setRequestHeader("Content-Type","application/x-www-data-urlencoded")

    local indexMoney = {1, 1000, 3000, 8800, 16800, 88800}
    dataMgr.weChat.total_fee = indexMoney[indexs]

    local testTable =  {["appid"]=dataMgr.weChat.appid, ["mch_id"]=dataMgr.weChat.mch_id, ["nonce_str"]=dataMgr.weChat.nonce_str,
        ["body"]=dataMgr.weChat.body, ["out_trade_no"]=dataMgr.weChat.out_trade_no, ["total_fee"]=dataMgr.weChat.total_fee,
        ["spbill_create_ip"]= dataMgr.weChat.spbill_create_ip, ["trade_type"]=dataMgr.weChat.trade_type
    }

    -- encode
    local jsonData = json.encode(testTable)
    --print("user data json:\n" .. jsonData)


    local function onRespons(  )
        --print("xmlHttpReq.readyState "..xmlHttpReq.readyState.." xmlHttpReq.status "..xmlHttpReq.status)
        if xmlHttpReq.readyState == 4 and (xmlHttpReq.status >= 200 and xmlHttpReq.status < 207) then
            local response   = xmlHttpReq.response
                local output = json.decode(response,1)
                print("xmlHttpRespons\n")
                -- for k,v in pairs(output) do
                --     --print(k, v)
                -- end

                if output.prepay_id ~= nil then
                    Helpers:callWeChatPay(output.prepay_id, tostring(time10))  --启动支付
                end

        end
    end

    xmlHttpReq:registerScriptHandler(onRespons)
    --xmlHttpReq:send()
    xmlHttpReq:send(jsonData)
end



function ShoppingBox.create(  )
    return ShoppingBox.new()
end

return ShoppingBox
