-- local AniamtionNode = import(".view.controls.CocostudioNode", currentModuleName)

local Node = cc.Node


-- 暂停（包含children）
function Node:pauseAll()
	-- self:pause()
	-- local c = self:getChildren()
	-- for _,v in pairs(c) do
	-- 	v:pauseAll()
	-- end
	Helpers:pauseNode(self)
end


function Node:resumeAll()
	-- self:resume()
	-- local c = self:getChildren()
	-- for _,v in ipairs(c) do
	-- 	v:resumeAll()
	-- end
	Helpers:resumeNode(self)
end
--更换父结点
function Node:changeParent(parent,zorder)
	-- local exParent = self:getParent()
	-- self:addTo(parent,zorder)
	-- exParent:removeChild(self)
	self:setParent(parent)
	self:setLocalZOrder(zorder)
end

-- 设置ZOrder，包含所有的儿子
function Node:setGlobalZOrderAll(zorder)
	self:setGlobalZOrder(zorder)
	local c = self:getChildren()
	for _,v in ipairs(c) do
		v:setGlobalZOrderAll(zorder)
	end
	return self
end

-- 返回缩放过的size
function Node:getScaledContentSize()
	local bbox = self:getBoundingBox()
	return cc.size(bbox.width,bbox.height)
end


-- 映射UI元素
-- function Node:mapUiElement(name,func)
-- 	if not func then
-- 		self[name] = AniamtionNode.seek(self, name)
-- 	else
-- 		self[name] = func(self)
-- 	end

-- 	if not self[name] then
-- 		printError("Can't map ui element named:"..name)
-- 	end
-- 	return self
-- end

function Node:mapUiElements(names)
	for _,v in ipairs(names) do
		self:mapUiElement(v)
	end
	return self
end

-- 处理button的事件
function Node:onButtonClicked(btnname,callback)
	local btn = Helpers:seekNodeByName(self,btnname)
	if not btn then
		printError("Node:onButtonClicked - can't find button for name:"..btnname)
	else
		btn:onClicked(callback)
	end
	return btn
end

function Node:getCascadeBoundingBox(  )
	return Helpers:getCascadeBoundingBox(self)
end

function Node:scheduleEx(cb, dt)

    local param = {dt = (dt or (1 / 60.0))}

    if not self.schedulePool then
        self.schedulePool = {}
    end

    if cb then
        param.schedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(cb,param.dt,false)
        table.insert( self.schedulePool, param )
    end
    return param.schedule
end

function Node:unscheduleEx(schedule)

    local scheduler = cc.Director:getInstance():getScheduler()
    for i,v in ipairs(self.schedulePool) do
        -- 如果没有cb，就清空所有的
        if not schedule then
            scheduler:unscheduleScriptEntry(v.schedule)
            v.schedule = nil
            table.remove(self.schedulePool, 1)
        else
            if v.schedule == schedule then
                scheduler:unscheduleScriptEntry(v.schedule)
                v.schedule = nil
                table.remove(self.schedulePool, i)
                return
            end
        end
    end
end

--self:schedule(self,handler(self, self.checkAttackUpdate),2.0)
--self:unschedule(self.aiSchedule)
--[[
    self:schedule(self,function()
        self:updateAi(0.5)
    end,0.5)


    function BaseRole:updateAi(dt)
		if battleManager.mapW>0 then
			self:setShadowScale(self.bornPosY)
			--极端检测(地图尽头)
			if (self:getPositionX() > battleManager.mapW-display.width*0.2) then
	        	self:setPositionX(battleManager.mapW-display.width*0.2)
		    elseif (self:getPositionX() <=0) then
		        self:setPositionX(0)
		    end
		end
	end

	--停止定时器
	self:unschedule()

]]
function Node:schedule(node, callback, delay)
	if not self.actionPool then
        self.actionPool = {}
    end

    local delay = cc.DelayTime:create(delay or 1/60.0)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback,{delay = delay}))
    local action = cc.RepeatForever:create(sequence)
    table.insert(self.actionPool, action)
    node:runAction(action)
    return action
end

function Node:unschedule(schedule)

	for i,v in ipairs(self.actionPool) do
        -- 如果没有cb，就清空所有的
        if not schedule then
            table.remove(self.actionPool,1)
            self:stopAction(v)
        else
            if v == schedule then
                table.remove(self.actionPool,i)
                self:stopAction(v)
                return
            end
        end
    end
end

local Widget = ccui.Widget

function Widget:onClicked(callback)
	self:onTouch(function(event)
		if "ended" == event.name then
			--dump(callback)
			callback(event)
		end
	end)
end


local Layout = ccui.Layout

function Layout:setTexture(path)
	self:setBackGroundImage(path)
end

function Layout:setTextureByPlist(path)
	self:setBackGroundImage(path,1)
end

function Layout:loadTexture(path)
	self:setBackGroundImage(path,1)
end

local Sprite = cc.Sprite

function Sprite:setTextureByPlist(path, plist)
	if plist then
		cc.SpriteFrameCache:getInstance():addSpriteFrames(plist)
	end
	self:setTexture(cc.SpriteFrameCache:getInstance():getSpriteFrameByName(path):getTexture())
end

-- display.scene ex
function display.pushScene(newScene, transition, time, more)
	local director = cc.Director:getInstance()
    if transition then
        newScene = display.wrapScene(newScene, transition, time, more)
    end
    director:pushScene(newScene)
end

function display.popScene()
	cc.Director:getInstance():popScene()
end

function display.popToRootScene()
	cc.Director:getInstance():popToRootScene()
end

function display.createScene(sceneModule,param)
    local scene = display.newScene(sceneModule.name_)
    scene:addChild(sceneModule.create(param))
    return scene
end

function display.getRunningScene()
    local scene = cc.Director:getInstance():getRunningScene()
    return scene
end



--裁剪圆形
--[[
以上两个方法，区别是剪切后缩放到哪个图片的大小。第一个是缩放到模板图片大小，第二个方法是缩放到原始图片（比如头像）大小。
local sp = display.createMaskedSprite("head.png", "mask.png")
]]

function display.createMaskedSprite(srcFile, maskFile)  
    local src = display.newSprite(srcFile)  
    local mask = display.newSprite(maskFile)  
  
    local size_src = src:getContentSize()  
    local size_mask = mask:getContentSize()  
  
    local canva = cc.RenderTexture:create(size_src.width, size_src.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)  
      
    local ratiow = size_src.width / size_mask.width  
    local ratioh = size_src.height / size_mask.height  
    mask:setScaleX(ratiow)  
    mask:setScaleY(ratioh)  
  
    mask:setPosition(size_src.width / 2, size_src.height / 2)  
    src:setPosition(size_src.width / 2, size_src.height / 2)  
  
    local blendfunc_mask = cc.blendFunc(gl.ONE, gl.ZERO)  
    mask:setBlendFunc(blendfunc_mask)  
    local blendfunc_src = cc.blendFunc(gl.DST_ALPHA, gl.ZERO)  
    src:setBlendFunc(blendfunc_src)  
  
    canva:begin()  
    mask:visit()  
    src:visit()  
    canva:endToLua()  
  
    local masked_sprite = cc.Sprite:createWithTexture(canva:getSprite():getTexture())  
    masked_sprite:setFlippedY(true)  
    return masked_sprite  
end  
  
function display.createCircleSprite(srcFile, maskFile)  
    local src = display.newSprite(srcFile)  
    local mask = display.newSprite(maskFile)  
  
    local size_src = src:getContentSize()  
    local size_mask = mask:getContentSize()  
  
    local canva = cc.RenderTexture:create(size_mask.width, size_mask.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)  
      
    local ratiow = size_mask.width / size_src.width  
    local ratioh = size_mask.height / size_src.height  
    src:setScaleX(ratiow)  
    src:setScaleY(ratioh)  
  
    mask:setPosition(size_mask.width / 2, size_mask.height / 2)  
    src:setPosition(size_mask.width / 2, size_mask.height / 2)  
  
    local blendfunc_mask = cc.blendFunc(gl.ONE, gl.ZERO)  
    mask:setBlendFunc(blendfunc_mask)  
    local blendfunc_src = cc.blendFunc(gl.DST_ALPHA, gl.ZERO)  
    src:setBlendFunc(blendfunc_src)  
  
    canva:begin()  
    mask:visit()  
    src:visit()  
    canva:endToLua()  
  
    local masked_sprite = cc.Sprite:createWithTexture(canva:getSprite():getTexture())  
    masked_sprite:setFlippedY(true)  
    return masked_sprite  
end  