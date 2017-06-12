local Poker = class("Poker", function() 
	return display.newSprite()
	end)

function Poker:ctor()
	self.m_dCardValue = 0			--扑克牌Id值
	self.m_dValue = 0 				--扑克牌实际值(1-13 15 16)
	self.m_dCardTexture = nil
	self.m_dCardBackTexture = nil
	self.m_dCardColor = 0
	self.m_dSelected = false
	self.m_dWidth = 128
	self.m_dHeight = 168

	self.m_dBeganPos = nil  --存储初始位置
	self.m_dMoveDis = 30    --选中移动距离
end

function Poker:changeCardData(cardData)
	self.m_dCardValue = cardData
	self.m_dValue = cardData % 13
	if cardData == 53 then
		self.m_dValue = 15
	elseif cardData == 54 then
		self.m_dValue = 16
	end
	if self.m_dValue == 0 then
		self.m_dValue = 13
	end

	self:setTexture(string.format("res/card/%d.png", cardData))
	--self.m_dWidth = W(self)
	--self.m_dWidth = H(self)
end

function Poker:addBeganPos(point)
	self.m_dBeganPos = point
end

--选中设置颜色
function Poker:setCardSelected(ret)
	self.m_dSelected = ret
	self:_selectedEffect(ret)
end

--选中移动
function Poker:setCardSelectMove(ret)
	self.m_dSelected = ret
	self:_selectedEffectMove(ret)
end

function Poker:showCardBack()
	self:setColor(cc.c3b(108, 108, 108))
end

function Poker:showCardTexture()
	self:setTexture(self.m_dCardTexture)
end

--选中效果
function Poker:_selectedEffect(ret)
	if ret then
		self:setColor(cc.c3b(255, 0, 0))
	else
		self:setColor(cc.c3b(255, 255, 255))
	end
end

--选中效果移动
function Poker:_selectedEffectMove(ret)
	if ret then
		self:setPositionY(self.m_dBeganPos.y + self.m_dMoveDis)
	else
		self:setPositionY(self.m_dBeganPos.y)
	end
end

--[[
	* get / set
]]

function Poker:getCardWidth()
	return self.m_dWidth
end

function Poker:getCardHeight()
	return self.m_dHeight
end

function Poker:getSelected()
	return self.m_dSelected
end

function Poker:getMoveDis()
	return self.m_dMoveDis
end

function Poker:getValue()
	return self.m_dValue
end

return Poker
