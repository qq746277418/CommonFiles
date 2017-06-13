local Bubble = import(".Bubble")
local _scheduler = cc.Director:getInstance():getScheduler()
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

	self.m_rewokeResult = {}
	self.m_dFills = {}  --填充列表

	self.m_dTouchRow = 0
	self.m_dTouchCol = 0
	self.m_dTouchAction = false

	self:initRule()

	xxl.registerTouchEvent(self, true)
end

function RuleLayer:initRule()
	-- local test = {
	-- 	{1,1,1,2,1,1,1},
	-- 	{1,1,1,2,1,1,1}
	-- }
	for row = 1, self.m_dRowCount do
		self.m_cBubbles[row] = {}
		for col = 1, self.m_dColCount do
			local x, y = self:_createBubble(row, col)

	        local grid = display.newSprite( display.newSpriteFrame("ItemBack.png"),x,y )
	        :addTo(self,0)
		end
	end

	self:_checkAndExpode()
end

--获得row、col对应的位置
function RuleLayer:getGridPosition(row, col)
	local x = self.m_dStartPos.x + self.m_buLen * (col - 1)
  	local y = self.m_dStartPos.y + self.m_buLen * (row - 1)
  	return x, y
end

function RuleLayer:_createBubble(row, col)
	local bubble = Bubble.new(self)
	bubble:setData(math.random(1,5))
	bubble:setRow(row)
	bubble:setCol(col)
  	local x, y = self:getGridPosition(row, col)
  	bubble:move(x, y)
  	self:addChild(bubble, 4)
  	self.m_cBubbles[row][col] = bubble

  	return x, y
end

function RuleLayer:_switchTouchPosToBubbleIdx(pos)
	local hafBulen = self.m_buLen / 2
	if pos.x < (self.m_dStartPos.x-hafBulen) or pos.x > (self.m_dStartPos.x + self.m_buLen * (self.m_dColCount-0.5)) then
		return false
	end

	if pos.y < (self.m_dStartPos.y-hafBulen) or pos.y > (self.m_dStartPos.y + self.m_buLen * (self.m_dRowCount-0.5)) then
		return false
	end

	local tx = pos.x - self.m_dStartPos.x + hafBulen
	local ty = pos.y - self.m_dStartPos.y + hafBulen
	local col = math.floor(tx / self.m_buLen) + 1
	local row = math.floor(ty / self.m_buLen) + 1

	return row, col
end

function RuleLayer:onTouchBegan(touch, event)
	self.m_dTouchRow, self.m_dTouchCol = self:_switchTouchPosToBubbleIdx(touch:getLocation())
	return true
end

function RuleLayer:onTouchMoved(touch, event)
	local row, col = self:_switchTouchPosToBubbleIdx(touch:getLocation())
	self:_swap(self.m_dTouchRow, self.m_dTouchCol, row, col)
end

function RuleLayer:onTouchEnded(touch, event)

end

function RuleLayer:_swap(row1, col1, row2, col2)
	if self.m_dTouchAction then return end
	--if (math.abs(row1-row2) == 1 or math.abs(col1-col2) == 1) and  then
	if (math.abs(row1-row2) == 1 and col1 == col2) or (math.abs(col1-col2) == 1 and row1 == row2) then
		--交换
		self.m_dTouchAction = true
		local bubble1 = self.m_cBubbles[row1][col1]
		local bubble2 = self.m_cBubbles[row2][col2]
		bubble1:moveToGrid(row2, col2)
		bubble2:moveToGrid(row1, col1)
		self.m_cBubbles[row2][col2] = bubble1
		self.m_cBubbles[row1][col1] = bubble2

		self:_delayCallback(0.35, function() 
			local ret = self:_checkAndExpode()
			if not ret then
				--第一次运动是有时间，不能马上运动回来
				bubble1:moveToGrid(row1, col1)
				bubble2:moveToGrid(row2, col2)
				self.m_cBubbles[row2][col2] = bubble2
				self.m_cBubbles[row1][col1] = bubble1
				self:_delayCallback(0.3, function() self.m_dTouchAction = false end)
			end
		end)
	end
end
	
--既然有了三个,那消除一定成立				
function RuleLayer:_insertRewokeResult(bubbles, idx, idValue)
	local tmp = {}
	for i = idx, #bubbles do
		if bubbles[i]:getId() == idValue then
			local dw = {}
			dw.row = bubbles[i]:getRow()
			dw.col = bubbles[i]:getCol()
			table.insert(tmp, #tmp + 1, dw)
		else
			table.insert(self.m_rewokeResult, #self.m_rewokeResult + 1, tmp)
			return i
		end
	end
	table.insert(self.m_rewokeResult, #self.m_rewokeResult + 1, tmp)
	return #bubbles
end

function RuleLayer:_checkAndExpode()
	--row检测
	self.m_rewokeResult = {}
	local function checkBubbles(tb)
		for _, bubbles in pairs(tb) do
			local testIdx = 1
			local tbLen = #bubbles
			local idx = 1
			while(idx <= tbLen - 2) do
				local id1 = bubbles[idx]:getId()
				local id2 = bubbles[idx+1]:getId()
				local id3 = bubbles[idx+2]:getId()
				if id1 == id2 and id2 == id3 then
					idx = self:_insertRewokeResult(bubbles, idx, id1)
				else
					idx = idx + 1
				end
			end
		end
	end
	local tmpRows = {}
	local tmpCols = {}
	for row,brows in pairs(self.m_cBubbles) do
		table.insert(tmpRows, #tmpRows + 1, brows)
		for col, bcol in pairs(brows) do
			if not tmpCols[col] then
				tmpCols[col] = {}
			end
			table.insert(tmpCols[col], #tmpCols[col] + 1, bcol)
		end
	end
	checkBubbles(tmpRows)
	checkBubbles(tmpCols)

	self:_rewokeBubbles()
	self.m_dTouchAction = #self.m_rewokeResult > 0
	return #self.m_rewokeResult > 0
end

--消除
function RuleLayer:_rewokeBubbles()
	if #self.m_rewokeResult == 0 then return end
	self.m_dFills = {}
	for _,tables in pairs(self.m_rewokeResult) do
		for _,val in pairs(tables) do
			local row = val.row
			local col = val.col
			local bubble = self.m_cBubbles[row][col]
			if bubble then
				self:_playerBoomQuad(X(bubble), Y(bubble))
				bubble:removeFromParent()
				self.m_cBubbles[row][col] = nil

				table.insert(self.m_dFills, #self.m_dFills + 1, {row = row, col = col})
			end
		end
	end
	--需要记录填充的列且个数
	self:_delayCallback(0.3, handler(self, self._beganDown))
end

--开启下落过程
function RuleLayer:_beganDown()
	self.m_dTouchAction = true
	local function addFills(lrow, crow, ccol)
		for k,val in pairs(self.m_dFills) do
			if val.row == lrow and val.col == ccol then
				table.remove(self.m_dFills, k)
				break
			end
		end
		table.insert(self.m_dFills, #self.m_dFills + 1, {row = crow, col = ccol})
	end

	local function moveGrid(row, col)
		for idx = row + 1, self.m_dRowCount do
			local bubble = self.m_cBubbles[idx][col]
			if bubble then
				--3.存在把这个泡泡移动过去
				self.m_cBubbles[idx][col] = nil
				self.m_cBubbles[row][col] = bubble
				bubble:moveToGrid(row, col)
				bubble:setRow(row)
				bubble:setCol(col)

				addFills(row, idx, col)
				return 
			end
		end
	end
	--1.一列一列的检测 从下往上检测
	for col = 1, self.m_dColCount do
		for row = 1, self.m_dRowCount do
			--1.检测当前位置存在不存在
			if self.m_cBubbles[row][col] == nil then
				--2.从这个往上查一个存在的值，移动过来
				moveGrid(row, col)
			end
		end
	end

	self:_delayCallback(0.5, handler(self, self._beanFill))
end

--开启填充过程
function RuleLayer:_beanFill()
	for _,val in pairs(self.m_dFills) do
		self:_createBubble(val.row, val.col)
	end

	self:_delayCallback(0.6, handler(self, self._checkAndExpode))
end

function RuleLayer:_delayCallback(time, callback)
	local seq = transition.sequence({
		cc.DelayTime:create(time),
		cc.CallFunc:create(callback)
		})
	self:runAction(seq)
end

--播放爆炸特效 
function RuleLayer:_playerBoomQuad(x, y)
	local explodePati=cc.ParticleSystemQuad:create("bubbleExplode.plist")
    explodePati:move(x, y)
    explodePati:setAutoRemoveOnFinish(true)
    self:addChild(explodePati, 6)
end

--row\col都不可越界
function RuleLayer:_checkRowAndColEffect(row, col)
	if row < 1 or row > self.m_dRowCount then
		return false
	end

	if col < 1 or col > self.m_dColCount then
		return false
	end
	return true
end

return RuleLayer