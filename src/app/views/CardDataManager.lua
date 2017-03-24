local CURRENT_MODULE_NAME = ...


local s_inst = nil
local CardDataManager = class("CardDataManager")

function CardDataManager:getInstance()
    if nil == s_inst then
        s_inst = CardDataManager.new()
        s_inst:init()
    end
    return s_inst
end

--[[
        笔记
--总剩余牌    


]]

function CardDataManager:init()
    self.cardSend = {}
    self.cardSend.cbCardData = {}
    self.cardSend.cbHuaCardData = {}
    --[[
        wBankerUser             
        wCurrentUser
        wReplaceUser
        bLianZhuangCount;  
        bHuaCount
        bSice1
        bSice2
        cbUserAction
        cbCardData[14];    
        cbHuaCardData[14];

     ]]

    --self.cardZhua = {}
     --[[
        抓牌
        struct CMD_S_SendCard
        {
            WORD                            wCurrentUser        ;                       //当前用户
            WORD                            wReplaceUser                 ;                       //补牌用户
            WORD                            wSendCardUser          ;                      //发牌用户
            BYTE                            cbCardData               ;                         //扑克数据
            BYTE                            cbActionMask               ;                       //动作掩码
            BYTE                            cbHuaCount                ;                        //花牌数量
            BYTE                            cbHuaCardData[MAX_HUA_CARD];            //花牌

        };
      ]]

    self.handValues = {}  --手牌值（只有自己），打出去的去掉
    self.bankClient = 0  --庄家客户端
    self.totalOutNum = 0  --总打出的牌
    self.outType = 0     --抓牌打出 0,    碰牌打出 1。
    self.pengNum = {}  --碰的个数，4家
    self.pengValue = {}  --碰的值 4家，每家3个相同只取一个  
    for i=1,4 do
        self.pengValue[i] = {}
    end
    self.outNum = {} --打出的牌的个数，4家

--test
    self:refresh()
end

--每局清空数据
function CardDataManager:refresh(  )
    for i=1,4 do
        self.outNum[i] = 0
        self.pengNum[i] = 0
    end
    self.totalOutNum = 0
end





return CardDataManager
