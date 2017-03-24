local CURRENT_MODULE_NAME = ...

local dataMgr     = import(".DataManager"):getInstance()
local layerMgr = import(".LayerManager"):getInstance()

local CardNode = class("CardNode", display.newNode)

function CardNode:ctor(cardValue)
    self.sn = nil
    self.cardValue = cardValue
   -- self.value = 
    local rootNode = cc.CSLoader:createNode("buttonCard.csb"):addTo(self)
    self.rootNode = rootNode
    self.btnBg  = rootNode:getChildByName("Button_1")
    local imgFace = self.btnBg:getChildByName("Image_paiMian")
    local imgName = cardValue..".png"
    imgFace:loadTexture(imgName)

end
  
  --取牌值
-- function cardValueToValue( cardValue )
    
-- end

--取花色
-- function cardValueToHuase( cardValue )
    
-- end

function CardNode.create(cardValue)
    return CardNode.new(cardValue)
end




return CardNode
