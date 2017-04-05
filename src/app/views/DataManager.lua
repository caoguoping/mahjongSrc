local CURRENT_MODULE_NAME = ...
-- classes
--local HeroData      = import(".information.HeroData", CURRENT_MODULE_NAME)

local s_inst = nil
local DataManager = class("DataManager")

function DataManager:getInstance()
    if nil == s_inst then
        s_inst = DataManager.new()
        s_inst:init()
    end
    return s_inst
end

function DataManager:init()
--数组下标拷贝
    --[[
    [1 ]  = 
    [2 ]  = 
    [3 ]  = 
    [4 ]  = 
    [5 ]  = 
    [6 ]  = 
    [7 ]  = 
    [8 ]  = 
    [9 ]  = 
    [10] = 
    [11] = 
    [12] = 
    [13] = 
    [14] = 
    [15] = 
    [16] = 
    [17] = 
    [18] = 
    [19] = 
    [20] = 
    [21] = 
    ]]

--playerStatus
    --0, 游戏前，   1, 游戏中，    2，   游戏结束
    self.playerStatus = 0

--myBaseData
    self.myBaseData = {}
    --[[
        uid
        wFaceID           
        dwUserID          
        dwGameID          
        dwGroupID         
        dwCustomID        
        dwUserMedal       
        dwExperience      
        dwLoveLiness      
        lUserScore        
        lUserInsure       
        cbGender          
        cbMoorMachine     
        szAccounts        
        szNickName        
        szGroupName       
        cbShowServerStatus
        isFirstLogin      
        rmb               
    ]]
--onDeskData
    --下标为serverChairId
    self.onDeskData = {}
    for i=1,4 do
        self.onDeskData[i] = {}
    end
    --[[
        dwGameID     
        dwUserID     
        dwGroupID    
        wFaceID      
        dwCustomID   
        cbGender     
        cbMemberOrder
        cbMasterOrder
        cbUserStatus 
        wTableID             
        wChairID     
        lScore       
        lGrade       
        lInsure      
        dwWinCount   
        dwLostCount  
        dwDrawCount  
        dwFleeCount  
        dwUserMedal  
        dwExperience 
        lLoveLiness  
        nick1        
        nick2        
        szNickName
        -- szGroupName;szUnderWrite; isClear; 暂时不用
    ]]
--chair  
    --下标为服务器Id, 值为客户端ID  chair下标传入1， 4，即服务器chairId + 1
    --[[
    server
            2
        1        3
            0
    client（固定不变)
            3
        2        4
            1

    direction(每局都变),  --下标为客户端ID ， 值为方位
              1(东)
        2(南)        4
              3

    

    ]]
    self.chair = {}  
    self.direction = {}  --东南西北（1， 2， 3， 4) 东为庄家
--roomSet
    self.roomSet = {} 
     --[[
    比下胡： 连庄(0bit)，包牌，花杠，        对对胡，杠后开花， 黄庄，
            天胡， 地胡， 全求独钓，     对对胡，杠后开花， 黄庄(11bit)
    wScore;                                         //总分数    100， 200， 300
    wJieSuanLimit;                          //单局结算上限      0：无限制，    100 ：100翻
    wBiXiaHu;                                       //比下胡 12bit
    bGangHouKaiHua;                                 //杠后开花  0：翻倍        1：加20花
    bZaEr;                                          //砸二      0：不砸2，     1：砸2
    bFaFeng;                                        //罚分      0：不罚分，    1：罚
    bYaJue;                                         //压绝    3bit  自己对的牌(0bit), 别人对的牌，  已打出的牌(2bit)  
    bJuShu;                                         //局数     1：1圈，   2:2圈，   4:4圈
    bIsJinyunzi                                     //是否进园子 1：进园子   ，   0:敞开头   

    以下不在发送数组里面
    wChair   高位，
    wTable
    bIsCreate     1:创建 0:加入
    dwRoomNum     输入的房间号或算好的房间号
    ]] 

    self.gameEnd = {}
    --[[
    
    ]]
    self.timeLeft = 0     --出牌剩余时间
    self.schedulerID = 0   --出牌剩余时间定时器

end

function DataManager:getServiceChairId( clientId )
    for i=1,4 do
        if self.chair[i] == clientId then
            return i - 1  --服务器为0, 3
        end
    end
end

return DataManager
