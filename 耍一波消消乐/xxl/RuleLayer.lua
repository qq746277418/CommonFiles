local Bubble = import(".Bubble")
local RuleLayer = class("RuleLayer", function()
    return display.newLayer()
end)

function RuleLayer:ctor()
	math.randomseed(os.time()) 

	 --泡泡的行列个数
	self.m_dRowCount = 9 
	self.m_dColCount = 7
	--泡泡的排列位置
	self.m_dStartPos=cc.p(45,100)
	self.m_buLen = 65 

	self.m_cBubbles = {}

	self:initRule()
end

function RuleLayer:initRule()
	for row = 1, self.m_dRowCount do
		self.m_cBubbles[row] = {}
		for col = 1, self.m_dColCount do
			local bubble = Bubble.new(self)
			bubble:setData(math.random(1,5))
		    bubble:setPosX(row)
		    bubble:setPosY(col)

  			local x = self.m_dStartPos.x + self.m_buLen * (col-1)
  			local y = self.m_dStartPos.y + self.m_buLen * (row-1)
  			bubble:move(x, y)
  			self:addChild(bubble, 4)
  			--table.insert(self.bubbleList, bubble)

	        local grid = display.newSprite( display.newSpriteFrame("ItemBack.png"),x,y )
	        :addTo(self,0)

	        self.m_cBubbles[row][col] = bubble
		end
	end
end



return RuleLayer