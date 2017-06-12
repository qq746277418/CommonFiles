local Poker = import("..Poker")
local MyPokerList = class("MyPokerList", function() 
	return display.newNode()
	end)

function MyPokerList:ctor()
	self.m_dTouchRect = {x = 30, y = 10}
	self.m_cPokers = {}
	self.m_dCardDis = 55
	self.m_dCardWidth = 0
	self.m_dCardHeight = 0      	--存储一下单张牌的高度]
	self.m_dTotalWidth = 1000
	self.m_bFirstCardSelected = false  --第一张的状态
	self.m_bSendState = false          --处在发牌状态

	self:_setupUi()
end

function MyPokerList:_setupUi()
	self:addPokers(randData(28))
end

function MyPokerList:_sortPokersData()
	table.sort(self.m_cPokers, function(a, b) return a:getValue() > b:getValue() end)
end

function MyPokerList:addPokers(pokers)

	for k,v in pairs(pokers) do
		local poker = Poker.new()
		poker:addTo(self)
		poker:changeCardData(v)
		poker:setVisible(true)
		self.m_dCardWidth = poker:getCardWidth()
		self.m_dCardHeight = poker:getCardHeight()

		table.insert(self.m_cPokers, #self.m_cPokers + 1, poker)
	end

	self.m_dTouchRect.height = self.m_dCardHeight
	self:_sortPokersData()
	self:_updatePokersPosition()
	self:beganSendPokerAction()
end

--发牌动画
function MyPokerList:beganSendPokerAction()
	local time = 0
	self.m_bSendState = true
	for _,poker in pairs(self.m_cPokers) do
		time = time + 0.2
		local tPos = cc.p(X(poker), Y(poker))
		poker:move(display.cx, display.cy)
		poker:setOpacity(0)
		local seq = transition.sequence({
			cc.DelayTime:create(time),
			cc.Spawn:create(cc.FadeIn:create(0.3), cc.MoveTo:create(0.3, tPos)),
			cc.CallFunc:create(function() 
				if _ == #self.m_cPokers then
					self.m_bSendState = false
				end
				end)
			})
		poker:runAction(seq)
	end
end

--删除其中选中的牌 
function MyPokerList:removeSelectedPokers()
	local num = 0
	for k,poker in pairs(self.m_cPokers) do
		if poker:getSelected() then
			self.m_cPokers[k]:removeFromParent()
			self.m_cPokers[k] = nil
			num = num + 1
		end
	end

	local tmp = {}
	for _,val in pairs(self.m_cPokers) do
		if val then
			table.insert(tmp, #tmp + 1, val)
		end
	end
	--更新touchrect
	self.m_dTouchRect.width = self.m_dTouchRect.width - self.m_dCardDis * num
	self.m_cPokers = tmp
	self:_updatePokersPosition()
end

function MyPokerList:switchTouchCardsNode(eventName, tPos)
	if self.m_bSendState then
		return
	end
	if tPos.x < self.m_dTouchRect.x or tPos.x > self.m_dTouchRect.x + self.m_dTouchRect.width
		or tPos.y < self.m_dTouchRect.y 
		or tPos.y > (self.m_dTouchRect.y + self.m_dTouchRect.height + self.m_cPokers[1]:getMoveDis()) then
		return false
	end
	if eventName == "began" then
		self:_onCardVTouchBegan(tPos)
	elseif eventName == "moved" then
		self:_onCardVTouchMoved(tPos)
	elseif eventName == "ended" then
		self:_onCardVTouchEnded(tPos)
	end
end

function MyPokerList:_checkEffectIdx(idx)
	for i = 0, 3 do
		if self.m_cPokers[idx - i]:getSelected() then
			return idx - i
		end
	end
	return nil
end

function MyPokerList:_getCardIdxByTouch(tPos)
	--第几张牌
	local cardIdx = 0
	local tx = tPos.x - self.m_dTouchRect.x
	local ty = tPos.y - self.m_dTouchRect.y
	cardIdx = math.floor(tx / self.m_dCardDis) + 1
	--如果是移动的区域
	if ty > self.m_dCardHeight then
		cardIdx = self:_checkEffectIdx(cardIdx)
	end
	if cardIdx > #self.m_cPokers then
		cardIdx = #self.m_cPokers
	end
	return cardIdx
end

function MyPokerList:_onCardVTouchBegan(tPos)
	local idx = self:_getCardIdxByTouch(tPos)
	if idx then
		self.m_dtouchBegan = tPos
		self.m_bFirstCardSelected = not self.m_cPokers[idx]:getSelected()
		self.m_cPokers[idx]:setCardSelectMove(self.m_bFirstCardSelected)
	end
end

function MyPokerList:_onCardVTouchMoved(tPos)
	local idx = self:_getCardIdxByTouch(tPos)
	--触摸偏移量判断
	local disOffset = cc.pGetDistance(self.m_dtouchBegan, tPos)
	if disOffset < 13 then
		return
	end
	if idx then
		self.m_cPokers[idx]:setCardSelectMove(self.m_bFirstCardSelected)
	end
end

function MyPokerList:_onCardVTouchEnded(tPos)
	
end

function MyPokerList:_updatePokersPosition()
	for _,poker in pairs(self.m_cPokers) do
		poker:move(self:_getPosBySortId(_))
		poker:addBeganPos(self:_getPosBySortId(_))
		poker:setLocalZOrder(_)
	end
	self.m_dTouchRect.width = self.m_dCardDis * (#self.m_cPokers-1) + self.m_dCardWidth
end

function MyPokerList:_getPosBySortId(id)
	self.m_dCardDis = (self.m_dTotalWidth - self.m_dCardWidth) / (#self.m_cPokers - 1)
	if self.m_dCardDis > (self.m_dCardWidth-18) then
		self.m_dCardDis = self.m_dCardWidth - 18
	end

	return cc.p(self.m_dTouchRect.x + self.m_dCardDis * (id-1) + self.m_dCardWidth / 2, self.m_dCardHeight / 2 + self.m_dTouchRect.y)
end

return MyPokerList