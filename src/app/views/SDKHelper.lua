

local CURRENT_MODULE_NAME = ...
local dataMgr     = import(".DataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()



local s_inst = nil
local SDKHelper = class("SDKHelper", display.newNode)

function SDKHelper:getInstance()
    if nil == s_inst then
        s_inst = SDKHelper.new()
        s_inst:retain()
        s_inst:inits()    
    end
    return s_inst
end

function SDKHelper:inits()
    print("SDKHelper:inits OK")
    local listener = cc.EventListenerCustom:create("rcvSDKLogin", handler(self, self.handleSDKLogin))
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
end

function SDKHelper:handleSDKLogin( event)
    local sdkData = SDKLoginData:create(event)
    local openid = sdkData:readOpenid()
    local nickName = sdkData:readNickName()
    local sex = sdkData:readSex()
    local headimgurl = sdkData:readHeadimgurl()
    local city = sdkData:readCity()  --实际上是房间号

    local roomNum = tonumber(city)
    print("roomNum   in SDKHelper "..roomNum)
    if roomNum == 0 then   --非自动启动
        dataMgr.roomSet.autoJoin = 0
    else
        dataMgr.roomSet.autoJoin = 1  --自动启动
        dataMgr.roomSet.dwRoomNum = roomNum
    end

    dataMgr.myBaseData.uid = openid
    dataMgr.myBaseData.szNickName = nickName
    if sex == 0 then
        sex = math.random(2)   --随机性别
    end
    dataMgr.myBaseData.cbGender = sex


    dataMgr.myBaseData.headimgurl = headimgurl
    --dataMgr.myBaseData.city = city

        local xmlHttpReq = cc.XMLHttpRequest:new()
        dataMgr:getUrlImgByClientId(xmlHttpReq, 1, dataMgr.myBaseData.headimgurl,
        function ()
            if xmlHttpReq.readyState == 4 and (xmlHttpReq.status >= 200 and xmlHttpReq.status < 207) then
                local fileData = xmlHttpReq.response
                local fullFileName = cc.FileUtils:getInstance():getWritablePath()..xmlHttpReq._urlFileName
                print("LUA-print"..fullFileName)
                local file = io.open(fullFileName,"wb")
                file:write(fileData)
                file:close()
                layerMgr.LoginScene:startLogin(openid)
            end
        end
        )
    --dataMgr:getUrlImgByClientId(1, dataMgr.myBaseData.headimgurl)

    print("openid "..openid.."  nickName "..nickName.." sex "..sex.." headimgurl "..headimgurl.." roomNum "..city.." cbGender "..dataMgr.myBaseData.cbGender)


end





return SDKHelper