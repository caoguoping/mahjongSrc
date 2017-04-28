local CURRENT_MODULE_NAME = ...

local s_inst = nil
local LayerManager = class("LayerManager")


function LayerManager:getInstance()
	if not s_inst then
		s_inst = LayerManager.new()
		s_inst:inits()
	end
	return s_inst
end

function LayerManager:inits( )
	self.LoginScene = nil
	self.NowLayer = nil
	self.Layers = {}
	self.boxes = {}

end

LayerManager.layIndex = table.enumTable({
	"MainLayer",
	"PlayLayer",
})

LayerManager.boxIndex = table.enumTable({
	"CreateRoomBox",
	"JoinRoomBox",
	"JiesuanBox",
	"RulesBox",
	"ZhanJiListBox",
	"ZhanJiListRecordsBox",
	"ZhanJiBox",
	"TuiGuangBox",
	"SettingBox",
	"RankShareBox",
	"ShoppingBox",
	"PersonInfoBox",

})


--all layers in here
do
	local function createMainLayer( params )
		return import(".MainLayer",CURRENT_MODULE_NAME).create(params)
	end

	local function createPlayLayer( params )
		return import(".PlayLayer",CURRENT_MODULE_NAME).create(params)
	end

	LayerManager.Creator = 
	{
		createMainLayer,
		createPlayLayer
  	}
end

function LayerManager:createLayer(panel,params)
	local creator = LayerManager.Creator[panel]
	if not creator then
		print("Can't find creator for Layer:"..panel)
		return nil
	else
		--cc.Director:getInstance():getTextureCache():removeUnusedTextures()
		local p = creator(params)
		return p
	end
end

function LayerManager:removeBoxes(boxIndex)
    if  self.boxes[boxIndex] then
	    self.boxes[boxIndex]:removeSelf()
	    self.boxes[boxIndex] = nil
	    print("removeBoxes "..boxIndex)
	end
end

function LayerManager:getLayer(panel,params)
	local _layer = self.Layers[panel]
	if not _layer then
		 _layer = self:createLayer(panel, params)
		self.LoginScene:addChild(_layer)
		self.Layers[panel] = _layer
	end	
	return _layer
end

function LayerManager:showLayer(panel, params)	
	if  self.NowLayer then	
		self.NowLayer:setVisible(false)
	end
	local _layer = self.Layers[panel]
	if _layer then
		_layer:setVisible(true)
		self.NowLayer = _layer
	else 
		self.Layers[panel] = self:createLayer(panel, params)
		self.NowLayer = self.Layers[panel]
		self.LoginScene:addChild(self.Layers[panel])
	end
end

function LayerManager:showSystemMessage( msg, x, y, color, isShowBg )
	local rootNode = cc.CSLoader:createNode("sysMsgTouming.csb"):addTo(self.LoginScene, 10001)
	local pos = cc.p(display.width * 0.5 + x, display.height * 0.5 + y)
    rootNode:setPosition(pos)
    local imgBg = rootNode:getChildByName("Image_1")
    if not isShowBg then
    	imgBg:setVisible(false)
    end
    local txtMsg = rootNode:getChildByName("Text_1")
    txtMsg:setString(msg)
    txtMsg:setColor(color)

    local seq = cc.Sequence:create(
    			cc.MoveBy:create(0.7, cc.p(0, 10)),
    			cc.DelayTime:create(0.5),
    			cc.FadeOut:create(0.5),
                cc.CallFunc:create(
                function ()
                	rootNode:removeFromParent()
                end)
                )
    rootNode:runAction(seq)
end


return LayerManager
