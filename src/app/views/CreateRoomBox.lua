--  创建房间弹出界面--
local CURRENT_MODULE_NAME = ...
local dataMgr     = import(".DataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()
local musicMgr = import(".MusicManager"):getInstance()


local createRoomBox = class("createRoomBox", display.newLayer)
function createRoomBox:ctor()
     print("createRoomBox1:")
--all Node
    local rootNode = cc.CSLoader:createNode("createRoom.csb"):addTo(self)
    self.rootNode = rootNode
    rootNode:setPosition(display.center)
    --创建房间、关闭、帮助按钮
    local btnCreate = rootNode:getChildByName("Button_create")
    local btnClose = rootNode:getChildByName("Button_close")
    local btnhelp = rootNode:getChildByName("Button_help")

    --触屏点击关闭界面
    local imgMask = rootNode:getChildByName("Image_mask")

    --局数选择按钮
    local Check_btn1 = rootNode:getChildByName("CheckBox_3")
    local Check_btn2 = rootNode:getChildByName("CheckBox_3_0")
    local Check_btn3 = rootNode:getChildByName("CheckBox_3_1")

    --进园子、敞开怀模式选择
    local Check_btn4 = rootNode:getChildByName("CheckBox_yuanzi")
    local Check_btn5 = rootNode:getChildByName("CheckBox_cangkaiihuai")

----***房间配置表**********
    --房间配置表总节点
    local cnfNode = rootNode:getChildByName("ScrollView_1")
    --总分按钮
       ---总分节点
    local zonfenNode = cnfNode:getChildByName("Sprite_zongfen")
       ---下拉按钮
    local btnzongfen = zonfenNode:getChildByName("Button_zongfen")
       ---分数显示text
    local txtzongfen = zonfenNode:getChildByName("Text_3_0")
    --上限按钮
         --上限节点
    local shangxianNode = cnfNode:getChildByName("Sprite_shangxian")
         --下拉按钮
    local btnshangxian = shangxianNode:getChildByName("Button_shangxian")
         --限数显示text
    local txtshangxian = shangxianNode:getChildByName("Text_4_0")
    --杠后开花：翻倍按钮
    local btnfanbei = cnfNode:getChildByName("Button_1")
    --杠后开花：加20个花按钮
    local btnjiahua = cnfNode:getChildByName("Button_2")
    --比下胡：修改按钮
    local btnxiugai = cnfNode:getChildByName("Button_xiugai")
    --比下胡显示text
    local bixiahutxt = cnfNode:getChildByName("Sprite_8"):getChildByName("Text_6")
    --砸2按钮
    local btnzaer = cnfNode:getChildByName("Button_3")
    --罚分按钮
    local btnfafen = cnfNode:getChildByName("Button_4")
    --压绝按钮
    local btnyajue = cnfNode:getChildByName("Button_5")
       --自己对的牌
    local tbYaJue1 = cnfNode:getChildByName("Button_6")
       --别人对的牌
    local tbYaJue2 = cnfNode:getChildByName("Button_7")
       --自己出的牌
    local tbYaJue3 = cnfNode:getChildByName("Button_8")
-----******比下胡修改配置表，总节点****
    ---总节点
    local bixiahuNode = rootNode:getChildByName("Sprite_15")
    --关闭按钮
    local btnclosebixiahu = bixiahuNode:getChildByName("Button_17")
    --按钮组节点
    local btnlist = bixiahuNode:getChildByName("ListView_3")
    ---必下胡修改按钮组
    local tbBiaxiahu1  = btnlist:getChildByName("Button_8_0")
    local tbBiaxiahu2  = btnlist:getChildByName("Button_8_1")
    local tbBiaxiahu3  = btnlist:getChildByName("Button_8_2")
    local tbBiaxiahu4  = btnlist:getChildByName("Button_8_3")
    local tbBiaxiahu5  = btnlist:getChildByName("Button_8_4")
    local tbBiaxiahu6  = btnlist:getChildByName("Button_8_5")
    local tbBiaxiahu7  = btnlist:getChildByName("Button_8_6")
    local tbBiaxiahu8  = btnlist:getChildByName("Button_8_7")
    local tbBiaxiahu9  = btnlist:getChildByName("Button_8_8")
    local tbBiaxiahu10  = btnlist:getChildByName("Button_8_9")
    local tbBiaxiahu11  = btnlist:getChildByName("Button_8_10")
----********总分下拉列表
    ---总节点
    local zonfenlist = rootNode:getChildByName("ListView_1")
    local btnzf1 = zonfenlist:getChildByName("Button_18")
    local btnzf2 = zonfenlist:getChildByName("Button_18_0")
    local btnzf3 = zonfenlist:getChildByName("Button_18_1") 
    local btnzf5 = zonfenlist:getChildByName("Button_18_2")
----********上限下拉列表
    ---总节点
    local shangxianlist = rootNode:getChildByName("ListView_2")
    local btnsxno = shangxianlist:getChildByName("Button_19")
    local btnsx1 = shangxianlist:getChildByName("Button_19_0")
    local btnsx2 = shangxianlist:getChildByName("Button_19_1")
    local btnsx3 = shangxianlist:getChildByName("Button_19_2")

--*******房间配置表初始化，即默认值***************************************************
   --动态显示比下胡修改信息
    local txtstring = {}
    txtstring[1]  = "连庄后"
    txtstring[2]  = "包牌后"
    txtstring[3]  = "花杠后"
    txtstring[4]  = "对对胡后"
    txtstring[5]  = "杠后开花后"
    txtstring[6]  = "黄庄后"
    txtstring[7]  = "天胡后"
    txtstring[8]  = "地胡后"
    txtstring[9]  = "全球独钓后"
    txtstring[10]  = "混一色后"
    txtstring[11]  = "清一色后"    
    
    local function TextBXH()
         --local strtxt = "无"
         local strtxt = nil
         local txt = "、"

         --记录4个字符串空行
         local  num = 0
         for key,value in ipairs(txtstring) 
             do
                if num < 3 then
                      if value ~= '0' then
                            --if strtxt ~='无' then
                            if strtxt ~=nil then
                               strtxt = strtxt..txt..value
                            else
                                strtxt = value
                            end
                      num = num + 1                
                      end
                elseif num >= 3 then
                      if value ~= '0' then
                      strtxt = strtxt..txt.."\n"..value
                      end
                       num = 0
                end


             --if num == 4 then
                --strtxt = strtxt..txt..value..txtt
               -- num = 0
             --else 
                --strtxt = strtxt..txt..value
             --end 
         end
         return strtxt
    end
    bixiahutxt:setString(TextBXH())

    local tbBiaxiahu = {}
    --选中1，未选中0
    tbBiaxiahu[1]  = 1 --连庄
    tbBiaxiahu[2]  = 1 --包牌
    tbBiaxiahu[3]  = 1 --花杠
    tbBiaxiahu[4]  = 1 --对对胡
    tbBiaxiahu[5]  = 1 --杠后开花
    tbBiaxiahu[6]  = 1 --黄庄
    tbBiaxiahu[7]  = 1 --天胡
    tbBiaxiahu[8]  = 1 --地胡
    tbBiaxiahu[9]  = 1 --全球独钓
    tbBiaxiahu[10]  = 1 --混一色
    tbBiaxiahu[11]  = 1 --清一色
    --bixiahutxt:setString("连庄后、包牌后、花杠后、对对胡后、\n杠后开花后、黄庄后、天胡后、地胡后、\n全球独钓后、混一色后、清一色后")
    local tbYaJue = {}
       --自己对的牌
    tbYaJue[1] = 1
       --别人对的牌
    tbYaJue[2] = 1
       --自己出的牌
    tbYaJue[3] = 1

    local c_wScore = 100  --100\200\300\400 
    local c_wJieSuanLimit = 0  --0无限制、100\200\300
    
    local c_bGangHouKaiHua = 0  --0翻倍\1加200花
    local c_bZaEr  = 1          --0不砸2、1砸二-
    local c_bFaFeng = 1    --0不罚、1罚-
    local c_bIsYaJue = 1    --0不压绝、1压
    local c_bJuShu = 1   --1:1圈、2:2圈、4:4圈 
    local c_bIsJinyunzi = 1  --1：进园子、2：敞开怀

--局数选择按钮
    Check_btn1:getChildByName("label_rule1_1_61"):setVisible(true)
    Check_btn2:getChildByName("label_rule1_1_61"):setVisible(false)
    Check_btn3:getChildByName("label_rule1_1_61"):setVisible(false)
    
    --进园子、敞开怀模式选择
     Check_btn4:getChildByName("label_rule1_2_62"):setVisible(true)
     Check_btn5:getChildByName("label_rule1_2_62"):setVisible(false)

       ---分数显示text
    txtzongfen:setString("100")
         --限数显示text
    txtshangxian:setString("无限制")  
    --杠后开花：翻倍按钮
     btnfanbei:getChildByName("radio_selected_3"):setVisible(true)
    --杠后开花：加20个花按钮
     btnjiahua:getChildByName("radio_selected_3"):setVisible(false)  
    --比下胡显示text
    --local btnxiugai = cnfNode:getChildByName("Button_xiugai")
    --砸2按钮
    btnzaer:getChildByName("radio_selected_3"):setVisible(true)
    --罚分按钮
    btnfafen:getChildByName("radio_selected_3"):setVisible(true)
    --压绝按钮
    btnyajue:getChildByName("radio_selected_3"):setVisible(true)
       --自己对的牌
    tbYaJue1:getChildByName("radio_selected_3"):setVisible(true)
       --别人对的牌
    tbYaJue2:getChildByName("radio_selected_3"):setVisible(true)
       --自己出的牌
    tbYaJue3:getChildByName("radio_selected_3"):setVisible(true)
-----******比下胡修改配置表****
    ---必下胡修改按钮组
    tbBiaxiahu1:getChildByName("radio_selected_3"):setVisible(true)
    tbBiaxiahu2:getChildByName("radio_selected_3"):setVisible(true)
    tbBiaxiahu3:getChildByName("radio_selected_3"):setVisible(true)
    tbBiaxiahu4:getChildByName("radio_selected_3"):setVisible(true)
     tbBiaxiahu5:getChildByName("radio_selected_3"):setVisible(true)
     tbBiaxiahu6:getChildByName("radio_selected_3"):setVisible(true)
     tbBiaxiahu7:getChildByName("radio_selected_3"):setVisible(true)
     tbBiaxiahu8:getChildByName("radio_selected_3"):setVisible(true)
     tbBiaxiahu9:getChildByName("radio_selected_3"):setVisible(true)
     tbBiaxiahu10:getChildByName("radio_selected_3"):setVisible(true)
     tbBiaxiahu11:getChildByName("radio_selected_3"):setVisible(true)

--********************按钮功能*****************************
    ----***主界面关闭功能-------
    imgMask:onClicked(
        function (  )
            musicMgr:playEffect("game_button_click.mp3", false)
            TTSocketClient:getInstance():closeMySocket(netTb.SocketType.Game)
            self:removeSelf()
        end
        )
    btnClose:onClicked(
        function (  )
            musicMgr:playEffect("game_button_click.mp3", false)
             TTSocketClient:getInstance():closeMySocket(netTb.SocketType.Game)
            self:removeSelf()
        end)
    --局数选择
    Check_btn1:onClicked(
        function (  )
            c_bJuShu = 1
               Check_btn1:getChildByName("label_rule1_1_61"):setVisible(true)
               Check_btn2:getChildByName("label_rule1_1_61"):setVisible(false)
               Check_btn3:getChildByName("label_rule1_1_61"):setVisible(false)
        end)
    Check_btn2:onClicked(
        function (  )
        c_bJuShu = 2
               Check_btn1:getChildByName("label_rule1_1_61"):setVisible(false)
               Check_btn2:getChildByName("label_rule1_1_61"):setVisible(true)
               Check_btn3:getChildByName("label_rule1_1_61"):setVisible(false)         
        end)
    Check_btn3:onClicked(
        function (  )
        c_bJuShu = 4
               Check_btn1:getChildByName("label_rule1_1_61"):setVisible(false)
               Check_btn2:getChildByName("label_rule1_1_61"):setVisible(false)
               Check_btn3:getChildByName("label_rule1_1_61"):setVisible(true)      
        end)

   --进园子、敞开怀模式选择
     Check_btn4:onClicked(
        function (  )
        c_bIsJinyunzi = 1 
        Check_btn4:getChildByName("label_rule1_2_62"):setVisible(true)
        Check_btn5:getChildByName("label_rule1_2_62"):setVisible(false)

        local posX, posY = zonfenlist:getPosition()
        if posX ==2000 and posY ==  200 then
           zonfenNode:setPosition(cc.p(113, 465))
        end

      
        end)

     Check_btn5:onClicked(
        function (  )
         c_bIsJinyunzi = 2
        Check_btn4:getChildByName("label_rule1_2_62"):setVisible(false)
        Check_btn5:getChildByName("label_rule1_2_62"):setVisible(true) 
        --敞开怀没有总分选项
        zonfenNode:setPosition(cc.p(2000, 200)) 
       
        end)
    shangxianlist:setPosition(cc.p(2000, 200))
    zonfenlist:setPosition(cc.p(2000, 200)) 
    bixiahuNode:setPosition(cc.p(2000, 200))
----***房间配置表**********
       ---下拉按钮
       btnzongfen:onClicked(
        function (  )
        local posX, posY = zonfenlist:getPosition()
        if posX == -165 and posY == 15 then
        zonfenlist:setPosition(cc.p(2000, 200))     
        elseif posX ==2000 and posY ==  200 then
        zonfenlist:setPosition(cc.p(-165, 15))
        end
        end)
         --下拉按钮
       btnshangxian:onClicked(
        function (  )
        local posX, posY = shangxianlist:getPosition()
        if posX ==230 and posY ==  17 then
        shangxianlist:setPosition(cc.p(2000, 200))
     
        elseif posX ==2000 and posY ==  200 then
        shangxianlist:setPosition(cc.p(230, 17))  

        end 
        end)
    --杠后开花：翻倍按钮
     btnfanbei:onClicked(
        function (  )
        c_bGangHouKaiHua = 0 
        btnfanbei:getChildByName("radio_selected_3"):setVisible(true)
        btnjiahua:getChildByName("radio_selected_3"):setVisible(false)    
        end)
    --杠后开花：加20个花按钮
     btnjiahua:onClicked(
        function (  )
       c_bGangHouKaiHua = 1
       btnjiahua:getChildByName("radio_selected_3"):setVisible(true)
       btnfanbei:getChildByName("radio_selected_3"):setVisible(false)
        end)
    --比下胡：修改按钮
     btnxiugai:onClicked(
        function (  )
        bixiahuNode:setPosition(cc.p(0, 0))    
        end)
    --砸2按钮
     btnzaer:onClicked(
        function (  )
         
        if c_bZaEr == 0 then
        c_bZaEr = 1
        btnzaer:getChildByName("radio_selected_3"):setVisible(true)
        elseif c_bZaEr == 1 then
        c_bZaEr = 0
        btnzaer:getChildByName("radio_selected_3"):setVisible(false)
        end

        end)
    --罚分按钮
     btnfafen:onClicked(
        function (  )
    
        if c_bFaFeng  == 0 then
        c_bFaFeng  = 1
        btnfafen:getChildByName("radio_selected_3"):setVisible(true)
        elseif c_bFaFeng  == 1 then
        c_bFaFeng  = 0
        btnfafen:getChildByName("radio_selected_3"):setVisible(false)
        end

        end)
    --压绝按钮
     btnyajue:onClicked(
        function (  )
        
        if c_bIsYaJue   == 0 then
        c_bIsYaJue   = 1
        btnyajue:getChildByName("radio_selected_3"):setVisible(true)
        tbYaJue[1]  = 1
        tbYaJue1:setVisible(true)
        tbYaJue1:setTouchEnabled(true)
        tbYaJue1:getChildByName("radio_selected_3"):setVisible(true)
        tbYaJue[2]  = 1
        tbYaJue2:setVisible(true)
        tbYaJue2:setTouchEnabled(true)
        tbYaJue2:getChildByName("radio_selected_3"):setVisible(true)
        tbYaJue[3]  = 1
        tbYaJue3:setVisible(true)
        tbYaJue3:setTouchEnabled(true)
        tbYaJue3:getChildByName("radio_selected_3"):setVisible(true)
        elseif c_bIsYaJue   == 1 then
        c_bIsYaJue   = 0
        btnyajue:getChildByName("radio_selected_3"):setVisible(false)
        tbYaJue[1]  = 0
        tbYaJue1:setVisible(false)
        tbYaJue1:setTouchEnabled(false)
        tbYaJue1:getChildByName("radio_selected_3"):setVisible(false)
        tbYaJue[2]  = 0
        tbYaJue2:setVisible(false)
        tbYaJue2:setTouchEnabled(false)
        tbYaJue2:getChildByName("radio_selected_3"):setVisible(false)
        tbYaJue[3]  = 0
        tbYaJue3:setVisible(false)
        tbYaJue3:setTouchEnabled(false)
        tbYaJue3:getChildByName("radio_selected_3"):setVisible(false)
        end 
        end)
    --local tbYaJue = {}
       --自己对的牌
    tbYaJue1:onClicked(
        function (  )

        if tbYaJue[1]   == 0 then
        tbYaJue[1]   = 1
        tbYaJue1:getChildByName("radio_selected_3"):setVisible(true)
        elseif tbYaJue[1]   == 1 then
        tbYaJue[1]   = 0
        tbYaJue1:getChildByName("radio_selected_3"):setVisible(false)
        end  

        end)
       --别人对的牌
    tbYaJue2:onClicked(
        function (  )
        
        if tbYaJue[2] == 0 then
        tbYaJue[2]  = 1
        tbYaJue2:getChildByName("radio_selected_3"):setVisible(true)
        elseif tbYaJue[2]  == 1 then
        tbYaJue[2]  = 0
        tbYaJue2:getChildByName("radio_selected_3"):setVisible(false)
        end           
        end)
       --自己出的牌
    tbYaJue3:onClicked(
        function (  )
        
        if tbYaJue[3]   == 0 then
        tbYaJue[3]   = 1
        tbYaJue3:getChildByName("radio_selected_3"):setVisible(true)
        elseif tbYaJue[3]   == 1 then
        tbYaJue[3]   = 0
        tbYaJue3:getChildByName("radio_selected_3"):setVisible(false)
        end           
        end)
--------关闭按钮功能-------
    imgMask:onClicked(
        function (  )
            self:removeSelf()
        end
        )
    btnClose:onClicked(
        function (  )
            self:removeSelf()
        end)
-----******比下胡修改配置表，总节点****

    --关闭按钮
     btnclosebixiahu:onClicked(
        function (  )
        bixiahutxt:setString(TextBXH())
        bixiahuNode:setPosition(cc.p(2000, 200))    
        end)
    ---必下胡修改按钮组
    tbBiaxiahu1:onClicked(
        function (  )
        if tbBiaxiahu[1] == 0 then
        tbBiaxiahu[1] = 1
        txtstring[1]  = "连庄后"
        tbBiaxiahu1:getChildByName("radio_selected_3"):setVisible(true)
        elseif tbBiaxiahu[1]   == 1 then
        tbBiaxiahu[1] = 0
        txtstring[1]  = '0'
        tbBiaxiahu1:getChildByName("radio_selected_3"):setVisible(false)
        end
        end)

    tbBiaxiahu2:onClicked(
        function (  )
        if tbBiaxiahu[2] == 0 then
        tbBiaxiahu[2] = 1
        txtstring[2]  = "包牌后"
        tbBiaxiahu2:getChildByName("radio_selected_3"):setVisible(true)
        elseif tbBiaxiahu[2]   == 1 then
        tbBiaxiahu[2] = 0
        txtstring[2]  = '0'
        tbBiaxiahu2:getChildByName("radio_selected_3"):setVisible(false)
        end           
        end)

    tbBiaxiahu3:onClicked(
        function (  )
        if tbBiaxiahu[3] == 0 then
        tbBiaxiahu[3] = 1
        txtstring[3]  = "花杠后"
        tbBiaxiahu3:getChildByName("radio_selected_3"):setVisible(true)
        elseif tbBiaxiahu[3]   == 1 then
        tbBiaxiahu[3] = 0
        txtstring[3]  = '0'
        tbBiaxiahu3:getChildByName("radio_selected_3"):setVisible(false)
        end
        end)

    tbBiaxiahu4:onClicked(
        function (  )
        if tbBiaxiahu[4] == 0 then
        tbBiaxiahu[4] = 1
        txtstring[4]  = "对对胡后"
        tbBiaxiahu4:getChildByName("radio_selected_3"):setVisible(true)
        elseif tbBiaxiahu[4]   == 1 then
        tbBiaxiahu[4] = 0
        txtstring[4]  = '0'
        tbBiaxiahu4:getChildByName("radio_selected_3"):setVisible(false)
        end   
        end)

    tbBiaxiahu5:onClicked(
        function (  )
        if tbBiaxiahu[5] == 0 then
        tbBiaxiahu[5] = 1
        txtstring[5]  = "杠后开花后"
        tbBiaxiahu5:getChildByName("radio_selected_3"):setVisible(true)
        elseif tbBiaxiahu[5]   == 1 then
        tbBiaxiahu[5] = 0
        txtstring[5]  = '0'
        tbBiaxiahu5:getChildByName("radio_selected_3"):setVisible(false)
        end  
        end)

    tbBiaxiahu6:onClicked(
        function (  )
        if tbBiaxiahu[6] == 0 then
        tbBiaxiahu[6] = 1
        txtstring[6]  = "黄庄后"
        tbBiaxiahu6:getChildByName("radio_selected_3"):setVisible(true)
        elseif tbBiaxiahu[6]   == 1 then
        tbBiaxiahu[6] = 0
        txtstring[6]  = '0'
        tbBiaxiahu6:getChildByName("radio_selected_3"):setVisible(false)
        end   
        end)

    tbBiaxiahu7:onClicked(
        function (  )
         if tbBiaxiahu[7] == 0 then
        tbBiaxiahu[7] = 1
        txtstring[7]  = "天胡后"
        tbBiaxiahu7:getChildByName("radio_selected_3"):setVisible(true)
        elseif tbBiaxiahu[7]   == 1 then
        tbBiaxiahu[7] = 0
        txtstring[7]  = '0'
        tbBiaxiahu7:getChildByName("radio_selected_3"):setVisible(false)
        end    
        end)

    tbBiaxiahu8:onClicked(
        function (  )
        if tbBiaxiahu[8] == 0 then
        tbBiaxiahu[8] = 1
        txtstring[8]  = "地胡后"
        tbBiaxiahu8:getChildByName("radio_selected_3"):setVisible(true)
        elseif tbBiaxiahu[8]   == 1 then
        tbBiaxiahu[8] = 0
        txtstring[8]  = '0'
        tbBiaxiahu8:getChildByName("radio_selected_3"):setVisible(false)
        end    
        end)

    tbBiaxiahu9:onClicked(
        function (  )
        if tbBiaxiahu[9] == 0 then
        tbBiaxiahu[9] = 1
        txtstring[9]  = "全球独钓后"
        tbBiaxiahu9:getChildByName("radio_selected_3"):setVisible(true)
        elseif tbBiaxiahu[9] == 1 then
        tbBiaxiahu[9] = 0
        txtstring[9]  = '0'
        tbBiaxiahu9:getChildByName("radio_selected_3"):setVisible(false)
        end  
        end)
    tbBiaxiahu10:onClicked(
        function (  )
        if tbBiaxiahu[10] == 0 then
        tbBiaxiahu[10] = 1
        txtstring[10]  = "混一色后"
        tbBiaxiahu10:getChildByName("radio_selected_3"):setVisible(true)
        elseif tbBiaxiahu[10] == 1 then
        tbBiaxiahu[10] = 0
        txtstring[10]  = '0'
        tbBiaxiahu10:getChildByName("radio_selected_3"):setVisible(false)
        end  
        end)
    tbBiaxiahu11:onClicked(
        function (  )
        if tbBiaxiahu[11] == 0 then
        tbBiaxiahu[11] = 1
        txtstring[11]  = "清一色后"
        tbBiaxiahu11:getChildByName("radio_selected_3"):setVisible(true)
        elseif tbBiaxiahu[11] == 1 then
        tbBiaxiahu[11] = 0
        txtstring[11]  = '0'
        tbBiaxiahu11:getChildByName("radio_selected_3"):setVisible(false)
        end  
        end)

----********总分下拉列表
    ---总节点
   -- local zonfenlist = rootNode:getChildByName("ListView_1")
     btnzf1:onClicked(
        function (  )
        c_wScore = 100
         txtzongfen:setString("100")
         zonfenlist:setPosition(cc.p(2000, 200))     
        end)
     btnzf2:onClicked(
        function (  )
        c_wScore = 200
         txtzongfen:setString("200")
         zonfenlist:setPosition(cc.p(2000, 200))   
        end)
     btnzf3:onClicked(
        function (  )
        c_wScore = 300
         txtzongfen:setString("300")
         zonfenlist:setPosition(cc.p(2000, 200))   
        end)
     btnzf5:onClicked(
        function (  )
        c_wScore = 500
         txtzongfen:setString("500")
         zonfenlist:setPosition(cc.p(2000, 200))   
        end)
----********上限下拉列表
    ---总节点
    --local shangxianlist = rootNode:getChildByName("ListView_2")
     btnsxno:onClicked(
        function (  )
        c_wJieSuanLimit = 0
        txtshangxian:setString("无限制")
        shangxianlist:setPosition(cc.p(2000, 200))      
        end)
     btnsx1:onClicked(
        function (  )
        c_wJieSuanLimit = 100
         txtshangxian:setString("100")
         shangxianlist:setPosition(cc.p(2000, 200))  
        end)
     btnsx2:onClicked(
        function (  )
        c_wJieSuanLimit = 200
         txtshangxian:setString("200")
         shangxianlist:setPosition(cc.p(2000, 200))   
        end)
     btnsx3:onClicked(
        function (  )
        c_wJieSuanLimit = 300
         txtshangxian:setString("300")
         shangxianlist:setPosition(cc.p(2000, 200))  
        end)


    layerMgr.LoginScene:addChild(self, 10000)

    btnCreate:onClicked(


        function (  )
            musicMgr:playEffect("game_button_click.mp3", false)
				--***************数据获取——汇总*************
			dataMgr.roomSet.wScore        = c_wScore --200  --c_wScore
			dataMgr.roomSet.wJieSuanLimit = c_wJieSuanLimit --0    --c_wJieSuanLimit
			dataMgr.roomSet.wBiXiaHu      = girl.getAllBitValue(tbBiaxiahu)
			dataMgr.roomSet.bGangHouKaiHua= c_bGangHouKaiHua --1    --c_bGangHouKaiHua 
			dataMgr.roomSet.bZaEr         = c_bZaEr --0    --c_bZaEr  
			dataMgr.roomSet.bFaFeng       = c_bFaFeng --1    --c_bFaFeng 
			dataMgr.roomSet.bYaJue        = girl.getAllBitValue(tbYaJue)
			dataMgr.roomSet.bJuShu        = c_bJuShu --1    --c_bJuShu	
			dataMgr.roomSet.bIsJinyunzi   = c_bIsJinyunzi --1    --c_bIsJinyunzi 

            local cardNum = girl.juToFang[dataMgr.roomSet.bJuShu]
           
--房卡不够，弹出
            if dataMgr.prop[10] < cardNum then
                local popupbox =  import(".popUpBox",CURRENT_MODULE_NAME).create() 
                popupbox:setInfo(Strings.noRoomCard)
                local btnOk, btnCancel  = popupbox:getBtns()
                btnOk:onClicked(function (  )    --确定
                    popupbox:remove()
                    musicMgr:playEffect("game_button_click.mp3", false)
                    layerMgr.boxes[layerMgr.boxIndex.TuiGuangBox] = import(".ShoppingBox",CURRENT_MODULE_NAME).create()
                end)
                btnCancel:onClicked(function (  )
                    popupbox:remove()
                end)
                return
            end

            local mainlayer = layerMgr:getLayer(layerMgr.layIndex.MainLayer)
            mainlayer:startGame(netTb.ip, netTb.port.game, netTb.SocketType.Game)  
            
        end
    )
end

function createRoomBox:sendCreateRoom()
    --cgpTest
    print("\ncreateRoomBox")
    
    local snd = DataSnd:create(1, 4)
    snd:wrWORD(dataMgr.roomSet.wScore        )
    snd:wrWORD(dataMgr.roomSet.wJieSuanLimit )
    snd:wrWORD(dataMgr.roomSet.wBiXiaHu      )
    snd:wrByte(dataMgr.roomSet.bGangHouKaiHua)
    snd:wrByte(dataMgr.roomSet.bZaEr         )
    snd:wrByte(dataMgr.roomSet.bFaFeng       )
    snd:wrByte(dataMgr.roomSet.bYaJue        )
    snd:wrByte(dataMgr.roomSet.bJuShu        )
	print("dataMgr.roomSet.bJuShu:"..dataMgr.roomSet.bJuShu)
    snd:wrByte(dataMgr.roomSet.bIsJinyunzi   )
    --snd:wrByte(dataMgr.roomSet.bIsYaJue   )

    print("setroomSet "..dataMgr.roomSet.wScore.."  "..dataMgr.roomSet.bJuShu.."  "..dataMgr.roomSet.bIsJinyunzi)


    snd:sendData(netTb.SocketType.Game)
    snd:release();
end

function createRoomBox:init(  )
    -- body
end

function createRoomBox.create(  )
    return createRoomBox.new()
end

return createRoomBox
