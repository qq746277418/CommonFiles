local Bubble = class("Bubble", function()
    return display.newSprite()
end)

function Bubble:ctor(ruleLayer)
	self.m_dId = 0
	self.m_dRow = 0
	self.m_dCol = 0
	self.m_bAction = false   --正在执行运动
	self.m_dRuleLayer = ruleLayer
end

function Bubble:setData(id)
	self.m_dId = id
	local frameName = string.format("Item%d.png", id)
	local frame = display.newSpriteFrame(frameName)
    self:setSpriteFrame(frame)
end

--[[移动到某个格子]]
function Bubble:moveToGrid(row , col)
	--目标的坐标
	local x, y = self.m_dRuleLayer:getGridPosition(row, col)	
	self.m_dRow = row
	self.m_dCol = col
	-- 移动动作
	if not self.m_bAction then
		self.m_bAction = true
		local moveAction= cc.MoveTo:create(0.3, cc.p(x, y))
		local seq = transition.sequence({moveAction, cc.CallFunc:create(function() 
			self.m_bAction = false
			end)})
		self:runAction(seq)
	end
end

--[[
	* get /set 方法
]]
function Bubble:getId()
	return self.m_dId
end

function Bubble:getRow()
	return self.m_dRow
end

function Bubble:setRow(row)
	self.m_dRow = row
end

function Bubble:getCol()
	return self.m_dCol
end

function Bubble:setCol(col)
	self.m_dCol = col
end

return Bubble

