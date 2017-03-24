local CURRENT_MODULE_NAME = ...

local dataMgr     = import(".DataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()
local netLogin = import(".NetWorkLogin"):getInstance()
local netGame = import(".NetWorkGame"):getInstance()

local LoginScene = class("LoginScene", cc.load("mvc").ViewBase)
LoginScene.RESOURCE_FILENAME = "LoginScene.csb"


function LoginScene:onCreate()
    printf("resource node = %s", tostring(self:getResourceNode()))
    ContentManager:getInstance():test()
end
  
function LoginScene:onEnter()
    local rootNode = self:getResourceNode()


    layerMgr.LoginScene = self

    local txUid = rootNode:getChildByName("TextField_uid")
    local btnLogin = rootNode:getChildByName("Button_login")
    btnLogin:onClicked(
    function ()
        self:disableAllButtons()
        local strUid = txUid:getString()
        if #strUid == 0 then
            strUid = tostring(1711514050 + math.random(1000000, 9000000))

        end
        dataMgr.myBaseData.uid = strUid
        print("strUid:"..strUid)
        self:startLogin(strUid)
    end
    )

    local btnFast1 = rootNode:getChildByName("Button_1")
    local btnFast2 = rootNode:getChildByName("Button_2")
    local btnFast3 = rootNode:getChildByName("Button_3")
    local btnFast4 = rootNode:getChildByName("Button_4")
    btnFast1:onClicked(
     function (  )
        self:disableAllButtons()

        local strUid = "1811514031"
        dataMgr.myBaseData.uid = strUid
        print("strUid:"..strUid)
        self:startLogin(strUid)
    end)

    btnFast2:onClicked(
    function (  )
        self:disableAllButtons()

        local strUid = "1811514032"
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

    --cgpTest
    -- local strUid = "1711514223"
    -- dataMgr.myBaseData.uid = strUid
    -- print("strUid:"..strUid)
    
    -- self:startLogin(strUid)
    --layerMgr:showLayer(layerMgr.layIndex.MainLayer)

--testBegin



    -- print("\n\n#####                      test start               #####\n\n")
    -- local test = girl.getBitTable(131)
    -- for i=1,8 do
    --     print(" "..i.." "..test[i])
    -- end

 --testEnd 


end

function LoginScene:startLogin(_uid)

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
    self.btnLogin:setVisible(false)
    self.btnFast1:setVisible(false)
    self.btnFast2:setVisible(false)
    self.btnFast3:setVisible(false)
    self.btnFast4:setVisible(false)
end


return LoginScene
