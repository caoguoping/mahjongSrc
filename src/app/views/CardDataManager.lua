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

    self.handValues = {}  --手牌值（只有自己），打出去的去掉
    self.bankClient = 0  --庄家客户端
    self.currentClient = 0   --当前客户端
    self.totalOutNum = 0  --总打出的牌
    self.outType = 0     --抓牌打出 0,    碰牌打出 1。
    self.pengGangNum = {}  --碰与杠的和的个数，4家       都是客户端椅子Id
    self.pengNum = {}      --碰的个数， 4家
    self.gangNum = {}      --杠的个数， 4家
    self.pengValue = {}  --碰的值 4家，每家3个相同只取一个  
    self.gangValue = {}   --杠的值 4家
    self.pengGangValue = {}   --碰和杠的值的值，按顺序存的，每个只存一个   4家
    
    for i=1,4 do
        self.pengValue[i] = {}
        self.pengGangValue[i] = {}
    end
    self.outNum = {} --打出的牌的个数，4家
    
    self.huaNum = {}  --花牌个数, 客户端
    self.huaValue = {}  --花牌数组4家,客户端
    for i=1,4 do
        self.huaValue[i] = {}   --每家的花牌数组
    end

    self.cardUse = {}   --所有可看见的牌，（包括自己的手牌，所有人的碰杠打出, 下标为牌值,值为剩余个数)

    self:refresh()
end

--每局清空数据
function CardDataManager:refresh(  )
    for i=1,4 do
        self.outNum[i] = 0
        self.pengGangNum[i] = 0
        self.pengNum[i] = 0
        self.gangNum[i] = 0
        self.pengValue[i] = {}
        self.huaNum[i] = 0
        self.huaValue[i] = {}
        self.pengValue[i] = {}
        self.gangValue[i] = {}
    end
    self.totalOutNum = 0
    self.outType = 0



    --统计已经打出的牌
    for i=1,3 do      --万条饼 
        for j=1,16 do
            if j <= 9 then
                self.cardUse[(i - 1) * 16 + j] = 4      
            else
                 self.cardUse[(i - 1) * 16 + j] = 0
            end
        end
    end

    for i=49,52 do  --东南西北
        self.cardUse[i] = 4
    end
end





return CardDataManager
