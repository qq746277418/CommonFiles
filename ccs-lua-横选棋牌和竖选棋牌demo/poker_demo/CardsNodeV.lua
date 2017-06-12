--[[
	*垂直手牌节点
	*层级越往上越低
]]

local Poker = import("..Poker")
local CardsNodeV = class("CardsNodeV", function() 
	return display.newNode()
	end)

function CardsNodeV:ctor(cardsNodeH)
	self.m_cCardsNodeH = cardsNodeH
	self.m_cPokers = {}
	self.m_dCardDis = 55
	self.m_dTouchRect = {}
	self.m_dCardWidth = 0
	self.m_dCardHeight = 0      	--存储一下单张牌的高度]

	self:_setupUi()
end

function CardsNodeV:_setupUi()
	--self:setInitData({5, 5, 5, 5, 5}
	
end

function CardsNodeV:setInitData(cardDatas)
	local twidth, theight = 0, 0
	for i,v in pairs(cardDatas) do
		local poker = Poker.new()
		poker:changeCardData(v)
		poker:addTo(self)
		poker:setLocalZOrder(-i)
		table.insert(self.m_cPokers, #self.m_cPokers + 1, poker)

		self.m_dCardWidth = poker:getCardWidth()
		self.m_dCardHeight = poker:getCardHeight()
		twidth = poker:getCardWidth()
			--theight = theight + 
		if i > 1 then
			theight = theight + self.m_dCardDis
		end
	end
	theight = theight + self.m_dCardHeight
	self.m_dTouchRect.width = twidth
	self.m_dTouchRect.height = theight

	self:_updatePokersPosition()
end

function CardsNodeV:setCardsNodeVPosition(pos)
	self:move(pos)
	self.m_dTouchRect.x = pos.x
	self.m_dTouchRect.y = pos.y
end

--触摸传进来的位置
function CardsNodeV:switchTouchCardsNode(eventName, tPos, beganPos)
	--摒弃不是这个区域的内容
	if tPos.x < self.m_dTouchRect.x or tPos.y < self.m_dTouchRect.y 
		or tPos.x > (self.m_dTouchRect.x + self.m_dTouchRect.width) 
		or tPos.y > (self.m_dTouchRect.y + self.m_dTouchRect.height) then
		return false
	end

	if eventName == "began" then
		self:_onCardVTouchBegan(tPos)
	elseif eventName == "moved" then
		self:_onCardVTouchMoved(tPos, beganPos)
	elseif eventName == "ended" then
		self:_onCardVTouchEnded(tPos)
	end
end

function CardsNodeV:_getCardIdxByTouch(tPos)
	--第几张牌
	local cardIdx = 0
	--ty： 牌区域的纵坐标点(相对坐标)
	local ty = tPos.y - self.m_dTouchRect.y
	if ty < self.m_dCardHeight then
		--第一张牌
		cardIdx = 1
	else
		ty = ty - self.m_dCardHeight
		cardIdx = math.floor(ty / self.m_dCardDis) + 2
	end
	return cardIdx
end

--检测ui在不在
function CardsNodeV:_checkCardByIdx(idx)
	if self.m_cPokers[idx] then
		return true
	end

	return false
end

function CardsNodeV:_onCardVTouchBegan(tPos)
	--第几张牌
	local cardIdx = self:_getCardIdxByTouch(tPos)
	if self:_checkCardByIdx(cardIdx) == false then
		return
	end

	local selected = not self.m_cPokers[cardIdx]:getSelected()
	self.m_cCardsNodeH:setFirstSelected(selected)
	self.m_cPokers[cardIdx]:setCardSelected(selected)
end

--获取第一张牌的状态
function CardsNodeV:getFirstPokerSelected()
	return self.m_cPokers[1]:getSelected()
end

--重置所有牌状态
function CardsNodeV:resetAllPokerSelected()
	for _,poker in pairs(self.m_cPokers) do
		poker:setCardSelected(false)
	end
end

--删除其中选中的牌 
function CardsNodeV:removeSelectedPokers()
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
	self.m_dTouchRect.height = self.m_dTouchRect.height - self.m_dCardDis * num
	self.m_cPokers = tmp
	self:_updatePokersPosition()
end

--[[
	*如果点到的第一张是选中的之后的都是设置为未选中状态
]]
function CardsNodeV:_onCardVTouchMoved(tPos, beganPos)
	--第几张牌
	local cardIdx = self:_getCardIdxByTouch(tPos)
	if not self:_checkCardByIdx(cardIdx) then
		return
	end
	--触摸偏移量判断
	local disOffset = cc.pGetDistance(beganPos, tPos)
	if disOffset < 13 then
		return
	end

	self.m_cPokers[cardIdx]:setCardSelected(self.m_cCardsNodeH:getFirstSelected())
end

function CardsNodeV:_onCardVTouchEnded()

end

function CardsNodeV:_updatePokersPosition()
	for _,poker in pairs(self.m_cPokers) do
		poker:move(cc.p(self.m_dCardWidth * 0.5, self:_getYBySortId(_)))
	end
end

function CardsNodeV:_getYBySortId(id)
	return self.m_dCardDis * (id - 1) + self.m_dCardHeight * 0.5
end

function CardsNodeV:getTouchRect()
	return self.m_dTouchRect
end

--单张牌宽
function CardsNodeV:getCardWidth()
	return self.m_dCardWidth
end

--
function CardsNodeV:getCardDisV()
	return self.m_dCardDis
end

function CardsNodeV:getCPokers()
	return self.m_cPokers
end

return CardsNodeV