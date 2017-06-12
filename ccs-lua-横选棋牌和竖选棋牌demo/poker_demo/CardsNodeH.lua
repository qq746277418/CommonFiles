--[[
	* CardsNodeV节点的集合体，横向控制器
]]
local CardsNodeV = import(".CardsNodeV")
local CardsNodeH = class("CardsNodeH", function() 
	return display.newNode()
	end)

function CardsNodeH:ctor()
	self.m_cCardsNodeVs = {}     --纵向节点集合
	self.m_dTouchRect = {x = 30, y = 3}
	self.m_bHoriztalDir = false    --是否横向移动
	self.m_dCardDis = 65         --横向间距 
	self.m_dCardTotalDis = display.width - 160   --通过总排距来计算
	self.m_dTouchPoint = nil
	self.m_bFirstSelected = false   --在CardsNodeV里面设置

	self:_setupUi()
end

function CardsNodeH:_setupUi()
	--模拟数据
	local testTb = {
		randData1(54,2),
		randData1(53,1),
		randData1(2,4),
		randData1(1, 6),
		randData1(13,1),
		randData1(12,2),
		randData1(11,3),
		randData1(9,8),
		randData1(8,3),
		randData1(7,5),
		randData1(6,2),
		randData1(5,3),
		randData1(4,1),
		randData1(3,2),
	}

	self:setInitData(testTb)
	self:_updatePokersPosition()
end

function CardsNodeH:setInitData(cardDatas)
	for i,ctb in pairs(cardDatas) do
		local cardsV = CardsNodeV.new(self)
		cardsV:addTo(self)
		cardsV:setInitData(ctb)
		table.insert(self.m_cCardsNodeVs, #self.m_cCardsNodeVs + 1, cardsV)

	end
end

function CardsNodeH:_updatePokersPosition()
	local pokerWidth = self.m_cCardsNodeVs[1]:getCardWidth()
	self.m_dCardDis = (self.m_dCardTotalDis - pokerWidth) / (#self.m_cCardsNodeVs - 1)
	--间距有最大值
	if self.m_dCardDis > (pokerWidth - 18) then
		self.m_dCardDis = pokerWidth - 18
	end
	for _,cNode in pairs(self.m_cCardsNodeVs) do
		local pos = cc.p(self:_getXBySortId(_), self.m_dTouchRect.y)
		cNode:setCardsNodeVPosition(pos)
	end

	self.m_dTouchRect.width = self.m_dCardDis * (#self.m_cCardsNodeVs - 1) + self.m_cCardsNodeVs[1]:getCardWidth()
end

function CardsNodeH:_getXBySortId(id)
	return self.m_dCardDis * (id - 1) + self.m_dTouchRect.x
end

--删除选中的牌
function CardsNodeH:removeSelectedPokers()
	local ret = false  --有没有可处理项目
	for k,val in pairs(self.m_cCardsNodeVs) do
		val:removeSelectedPokers()
		if #val:getCPokers() == 0 then
			self.m_cCardsNodeVs[k]:removeFromParent()
			self.m_cCardsNodeVs[k] = nil
			ret = true
		end
	end
	local tmp = {}
	for k,val in pairs(self.m_cCardsNodeVs) do
		if val then
			table.insert(tmp, #tmp + 1, val)
		end
	end
	self.m_cCardsNodeVs = tmp
	self:_updatePokersPosition()
	return ret
end
--[[
	* touch
]]

--触摸传进来的位置
function CardsNodeH:switchTouchCardsNode(eventName, tPos)
	--摒弃不是这个区域的内容(纵向未做判断)
	if tPos.x < self.m_dTouchRect.x or tPos.x > (self.m_dTouchRect.x + self.m_dTouchRect.width)
		or tPos.y < self.m_dTouchRect.y then
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

function CardsNodeH:_getCardIdxByTouch(tPos)
	--第几张牌
	local cardIdx = 0
	--tx： 牌区域的横坐标点(相对坐标)
	local tx = tPos.x - self.m_dTouchRect.x
	local ty = tPos.y - self.m_dTouchRect.y
	cardIdx = math.floor(tx / self.m_dCardDis) + 1
	if cardIdx > #self.m_cCardsNodeVs then
		--点击到最后一张的后半部分了
		cardIdx = cardIdx - 1
	end
	--删除部分之后这里要坐判断
	print("============", cardIdx)
	if not self.m_cCardsNodeVs[cardIdx] then
		return nil
	end
	--TODO：这里已经通过横坐标的测试
	print("----touch-----", tPos.y, self.m_cCardsNodeVs[cardIdx]:getTouchRect().height)
	local ret = ty > self.m_cCardsNodeVs[cardIdx]:getTouchRect().height
	if ret then
		print("-----11------", cardIdx, tx / self.m_dCardDis)
		if self.m_cCardsNodeVs[cardIdx-1] then
			return cardIdx-1
		end
	else
		print("-----22------", cardIdx-1, tx / self.m_dCardDis)
		if self.m_cCardsNodeVs[cardIdx] then
			return cardIdx
		end
	end
	return nil
end

--遍历所有的V节点，取消选中
function CardsNodeH:_resetAllCardsNodeSelected()
	for _,node in pairs(self.m_cCardsNodeVs) do
		node:resetAllPokerSelected()
	end
end

function CardsNodeH:_onCardVTouchBegan(tPos)
	local cardVIdx = self:_getCardIdxByTouch(tPos)
	if cardVIdx then
		self.m_cCardsNodeVs[cardVIdx]:switchTouchCardsNode("began", tPos)
	end
	self.m_dTouchPoint = tPos
end

local test = false
function CardsNodeH:_onCardVTouchMoved(tPos)
	--1. 横坐标偏移量的判断
	local cardVIdx = self:_getCardIdxByTouch(tPos)
	if not cardVIdx then return end

	self.m_cCardsNodeVs[cardVIdx]:switchTouchCardsNode("moved", tPos, self.m_dTouchPoint)
end

function CardsNodeH:_onCardVTouchEnded(tPos)
	-- self.m_bHoriztalDir = false
	-- test = false
	-- for _,node in pairs(self.m_cCardsNodeVs) do
	-- 	node:switchTouchCardsNode("ended", tPos)
	-- end
end

function CardsNodeH:setFirstSelected(ret)
	self.m_bFirstSelected = ret
end

function CardsNodeH:getFirstSelected()
	return self.m_bFirstSelected
end

return CardsNodeH