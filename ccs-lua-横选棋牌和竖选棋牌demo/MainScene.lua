require("app.views.getVecP")
local CardsNodeH = import(".poker_demo.CardsNodeH")
local MyPokerList_ = import(".poker_common.MyPokerList_")
local MyPokerList = import(".poker_common.MyPokerList")
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
    -- add background image
    display.newSprite("res/bg.jpg")
        :move(display.center)
        :addTo(self)

    -- add HelloWorld label
    cc.Label:createWithSystemFont("Hello World", "Arial", 40)
        :move(display.cx, display.cy + 200)
        :addTo(self)

    self.state = 1   --竖直排列 2 = 横向排列
    

    ccui.Button:create("res/b1.png", "res/b2.png")
    :addTo(self)
    :setScale(0.5)
    :setTitleText("出牌")
    :setTitleFontSize(36)
    :move(cc.p(display.width - 70, display.top - 50))
    :addClickEventListener(function() 
    	if self.state == 1 then
	    	if not self.tt:removeSelectedPokers() then
	    		self:showTips()
	    	end
	    else
	    	if not self.clist:removeSelectedPokers() then
	    		self:showTips()
	    	end
	    end
    	end)

    ccui.Button:create("res/b1.png", "res/b2.png")
    :addTo(self)
    :setScale(0.5)
    :setTitleText("重置")
    :setTitleFontSize(36)
    :move(cc.p(display.width - 200, display.top - 50))
    :addClickEventListener(function()
    	if self.tt then
    		self.tt:removeFromParent()
    		self.tt = nil
    	end
    	if self.clist then
    		self.clist:removeFromParent()
    		self.clist = nil
    	end
    	self.tt = CardsNodeH.new()
    	self.tt:addTo(self)
    	self.state = 1
    	end)

    ccui.Button:create("res/b1.png", "res/b2.png")
    :addTo(self)
    :setScale(0.5)
    :setTitleText("牌列表")
    :setTitleFontSize(36)
    :move(cc.p(display.width - 330, display.top - 50))
    :addClickEventListener(function() 
    	if self.tt then
    		self.tt:removeFromParent()
    		self.tt = nil
    	end
    	if self.clist then
    		self.clist:removeFromParent()
    		self.clist = nil
    	end
    	self.clist = MyPokerList.new()
    	self.clist:addTo(self)
    	self.state = 2
    	end)

    self:registerTouchEvent(self, true)
end

--tips
function MainScene:showTips()
	local text = ccui.Text:create("您还有没有选牌呢！", "jiantizi.ttf", 36)
	text:setTextColor(cc.c3b(55, 168, 34))
	text:addTo(self, 2)
	text:move(display.cx, display.cy)
	text:setOpacity(0)
	local seq = transition.sequence({
		cc.FadeIn:create(0.8),
		cc.FadeOut:create(0.8),
		cc.CallFunc:create(function() text:removeFromParent() end)
		})
	text:runAction(seq)
end

function MainScene:registerTouchEvent( node, bSwallow )
	if nil == node then
		return false
	end
	local function onNodeEvent( event )
		if event == "enter" and nil ~= node.onEnter then
			node:onEnter()
		elseif event == "enterTransitionFinish" then
			--注册触摸
			local function onTouchBegan( touch, event )
				if nil == node.onTouchBegan then
					return false
				end
				return node:onTouchBegan(touch, event)
			end

			local function onTouchMoved(touch, event)
				if nil ~= node.onTouchMoved then
					node:onTouchMoved(touch, event)
				end
			end

			local function onTouchEnded( touch, event )
				if nil ~= node.onTouchEnded then
					node:onTouchEnded(touch, event)
				end       
			end

			local listener = cc.EventListenerTouchOneByOne:create()
			bSwallow = bSwallow or false
			listener:setSwallowTouches(bSwallow)
			node._listener = listener
		    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
		    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
		    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
		    local eventDispatcher = node:getEventDispatcher()
		    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)

			if nil ~= node.onEnterTransitionFinish then
				node:onEnterTransitionFinish()
			end
		elseif event == "exitTransitionStart" 
			and nil ~= node.onExitTransitionStart then
			node:onExitTransitionStart()
		elseif event == "exit" and nil ~= node.onExit then	
			if nil ~= node._listener then
				local eventDispatcher = node:getEventDispatcher()
				eventDispatcher:removeEventListener(node._listener)
			end			

			if nil ~= node.onExit then
				node:onExit()
			end
		elseif event == "cleanup" and nil ~= node.onCleanup then
			node:onCleanup()
		end
	end
	node:registerScriptHandler(onNodeEvent)
	return true
end


function MainScene:onTouchBegan(touch, event)
	if self.state == 1 then
		self.tt:switchTouchCardsNode("began", touch:getLocation())
	else
		self.clist:switchTouchCardsNode("began", touch:getLocation())
	end
	return true
end

function MainScene:onTouchMoved(touch, event)
	if self.state == 1 then
		self.tt:switchTouchCardsNode("moved", touch:getLocation())
	else
		self.clist:switchTouchCardsNode("moved", touch:getLocation())
	end
end

function MainScene:onTouchEnded(touch, event)
	if self.state == 1 then
		self.tt:switchTouchCardsNode("ended", touch:getLocation())
	else
		self.clist:switchTouchCardsNode("ended", touch:getLocation())
	end
end

return MainScene
