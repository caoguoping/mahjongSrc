local CURRENT_MODULE_NAME = ...
require("src/cocos/cocos2d/json")

local dataMgr     = import(".DataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()
local netLogin = import(".NetWorkLogin"):getInstance()
local netGame = import(".NetWorkGame"):getInstance()
local sdkHelper = import(".SDKHelper"):getInstance()
local musicMgr = import(".MusicManager"):getInstance()


local LoginScene = class("LoginScene", cc.load("mvc").ViewBase)
LoginScene.RESOURCE_FILENAME = "LoginScene.csb"

function LoginScene:onCreate()
    printf("resource node = %s", tostring(self:getResourceNode()))
    --ContentManager:getInstance():test()
end
  
function LoginScene:onEnter()
    local rootNode = self:getResourceNode()
    local imgBg = rootNode:getChildByName("background")
    local imgHealth = rootNode:getChildByName("Image_health")

    local seq = cc.Sequence:create(
                --cc.DelayTime:create(1.0),   --广电测试
                cc.FadeOut:create(0.5),
                cc.CallFunc:create(
                function ()
                    imgBg:setVisible(true)
                    imgHealth:setVisible(false)
                end)
                )
    imgHealth:runAction(seq)


    imgBg:setVisible(false)
    layerMgr.LoginScene = self

    self.btnLoginWin = imgBg:getChildByName("Button_WindowsLogin")   --windows登录
    
    self.btnLoginWin:onClicked(
    function ()
        self:disableAllButtons()
        musicMgr:playEffect("game_button_click.mp3", false)
            local time1 = os.time()
            local time2 = math.random(1, 100)
            local strUid  = tostring(time1 * 100 + time2)
        dataMgr.myBaseData.uid = strUid
        print("strUid:"..strUid)
        self:startLogin(strUid)
    end
    )

    local btnLogin = imgBg:getChildByName("Button_login")   --微信登录
    btnLogin:onClicked(
    function ()
        musicMgr:playEffect("game_button_click.mp3", false)
        self:disableAllButtons()
        Helpers:callJavaLogin() 
    end
    )


    local txtUid = imgBg:getChildByName("TextField_uid")
    local txtPassword = imgBg:getChildByName("TextField_password")




    local btnLoginGD = imgBg:getChildByName("Button_loginGD")   --广电登录
    btnLoginGD:onClicked(
    function ()
        self:disableAllButtons()
        musicMgr:playEffect("game_button_click.mp3", false)
        local inputUid = txtUid:getString()
        local inputPassword = txtPassword:getString()
        local strUid = ""
        if inputUid == "ceshi1" and inputPassword == "ceshi1" then
            strUid = "ceshi1"
        end
        if inputUid == "ceshi2" and inputPassword == "ceshi2" then
            strUid = "ceshi2"
        end
        if inputUid == "ceshi3" and inputPassword == "ceshi3" then
            strUid = "ceshi3"
        end
        if inputUid == "ceshi4" and inputPassword == "ceshi4" then
            strUid = "ceshi4"
        end
        if strUid ~= "" then
            dataMgr.myBaseData.uid = strUid
            print("strUid:"..strUid)
            print(txtUid:getString())
            self:startLogin(strUid)
        else
            layerMgr:showSystemMessage("用户名或密码错误，请重新输入", 200, 0, cc.c4f(255,255,255,255), true)
            txtUid:setString("")
            txtPassword:setString("")
        end

        --
    end
    )


    local btnFast1 = imgBg:getChildByName("Button_1")
    local btnFast2 = imgBg:getChildByName("Button_2")
    local btnFast3 = imgBg:getChildByName("Button_3")
    local btnFast4 = imgBg:getChildByName("Button_4")
    btnFast1:onClicked(
     function (  )
        self:disableAllButtons()

        local strUid = "ceshi4"
        dataMgr.myBaseData.uid = strUid
        print("strUid:"..strUid)
        self:startLogin(strUid)
    end)

    btnFast2:onClicked(
    function (  )
        self:disableAllButtons()

        local strUid = "1819514032"
        -- local strUid = "1811514032"
        dataMgr.myBaseData.uid = strUid
        print("strUid:"..strUid)
        self:startLogin(strUid)
    end)

    btnFast3:onClicked(
    function (  )
        self:disableAllButtons()

        local strUid = "1811514033"
        dataMgr.myBaseData.uid = strUid
        print("strUid:"..strUid)
        self:startLogin(strUid)
    end)

    btnFast4:onClicked(
    function (  )
        self:disableAllButtons()
        
        local strUid = "1811514034"
        dataMgr.myBaseData.uid = strUid
        print("strUid:"..strUid)
        self:startLogin(strUid)
    end)

    self.btnLogin = btnLogin
    self.btnFast1 = btnFast1
    self.btnFast2 = btnFast2
    self.btnFast3 = btnFast3
    self.btnFast4 = btnFast4
  
    -- if(device.platform == "windows") then 
    -- --if true then        --广电测试
    --     local xmlHttpReq = cc.XMLHttpRequest:new()
    --     dataMgr:getUrlImgByClientId(xmlHttpReq, 1, "http://wx.qlogo.cn/mmopen/9r6A4jA1ibTQFTnZTABJGlfDj26ehcMc6GHq4L1krtwbwzmHLghzU2Kyw9UhqqktB6fdicwk5ianexFB89WNvyf8dZCY5NJUOPL/0",
    --     function ()
    --         if xmlHttpReq.readyState == 4 and (xmlHttpReq.status >= 200 and xmlHttpReq.status < 207) then
    --             local fileData = xmlHttpReq.response
    --             local fullFileName = cc.FileUtils:getInstance():getWritablePath()..xmlHttpReq._urlFileName
    --             print("LUA-print"..fullFileName)
    --             local file = io.open(fullFileName,"wb")
    --             file:write(fileData)
    --             file:close()
    --         end
    --     end
    --     )
    -- end

    --预加载MainLayer
    local mainLayer = layerMgr:getLayer(layerMgr.layIndex.MainLayer)  
    mainLayer:setVisible(false)




end


function LoginScene:startLogin(_uid)

    print("openid ".._uid)

    -- local fileName = "printScreen.png"
    --     -- 移除纹理缓存
    --     cc.Director:getInstance():getTextureCache():removeTextureForKey(fileName)
    --     self:removeChildByTag(1000)
    --     -- 截屏
    --     cc.utils:captureScreen(
    --         function(succeed, outputFile)
    --             if succeed then
    --               local winSize = cc.Director:getInstance():getWinSize()
    --               local sp = cc.Sprite:create(outputFile)
    --               self:addChild(sp, 0, 1000)
    --               sp:setPosition(winSize.width / 2, winSize.height / 2)
    --               sp:setScale(0.5) -- 显示缩放
    --                 print("\n\n\n\noutputFile \n\n\n\n")
    --                 print(outputFile)
    --             else
    --                 cc.showTextTips("截屏失败")
    --             end
    --         end, 
    --         fileName)

    
    TTSocketClient:getInstance():startSocket(netTb.ip, netTb.port.login, netTb.SocketType.Login)

    local snd = DataSnd:create(1, 2)
    local uid = _uid
    local dwPlazaVersion = 65536
    local szMachineID = uid
    local szPassword = uid
    local szAccounts = uid
    local cbValidateFlags = 3

    snd:wrDWORD(dwPlazaVersion)
    snd:wrString(szMachineID, 66)
    snd:wrString(szPassword, 64)
    snd:wrString(szAccounts, 66)
    snd:wrString(uid, 32)
    snd:wrDWORD(cbValidateFlags)
    snd:sendData(netTb.SocketType.Login)
    snd:release();

end

function LoginScene:disableAllButtons(  )
    self.btnLoginWin:setTouchEnabled(false)
    self.btnLogin:setTouchEnabled(false)
    self.btnFast1:setTouchEnabled(false)
    self.btnFast2:setTouchEnabled(false)
    self.btnFast3:setTouchEnabled(false)
    self.btnFast4:setTouchEnabled(false)
end


return LoginScene
