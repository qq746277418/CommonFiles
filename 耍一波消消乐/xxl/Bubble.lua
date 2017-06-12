local Bubble = class("Bubble", function()
    return display.newSprite()
end)

function Bubble:ctor(ruleLayer)
	self.m_dId = 0
	self.m_dPosX = 0
	self.m_dPosY = 0
	self.m_dRuleLayer = ruleLayer
end

function Bubble:setData(id)
	self.m_dId = id
	local frameName = string.format("Item%d.png", id)
	local frame = display.newSpriteFrame(frameName)
    self:setSpriteFrame(frame)
end

--[[移动到某个格子]]
function Bubble:moveToGrid(x , y)
	--目标的坐标
	local tarX = self.m_dRuleLayer.startPos.x + self.RuleLayer.bubbleLen * (y - 1)
	local tarY = self.m_dRuleLayer.startPos.y + self.RuleLayer.bubbleLen * (x - 1)

	--print(tarX,tarY)

	-- 移动动作
	local moveAction= cc.MoveTo:create(0.3,cc.p(tarX, tarY))

	self:runAction(moveAction)
end

--[[
	* get /set 方法
]]
function Bubble:getId()
	return self.m_dId
end

function Bubble:getPosX()
	return self.m_dPosX
end

function Bubble:setPosX(x)
	self.m_dPosX = x
end

function Bubble:getPosY()
	return self.m_dPosY
end

function Bubble:setPosY(y)
	self.m_dPosY = y
end

return Bubble

