cc.exports.SIZE = function(node)
	if not node then return nil end
	local size = node:getContentSize()
	if size.width == 0 and size.height == 0 then
		local w,h = node:getLayoutSize()
		return cc.size(w,h)
	else
		return size
	end
end
--获取坐标位置函数
cc.exports.X = function (node) if not node then return nil end return node:getPositionX(); end
cc.exports.Y = function (node) if not node then return nil end return node:getPositionY(); end
cc.exports.W = function(node) if not node then return nil end  return SIZE(node).width; end
cc.exports.H = function(node) if not node then return nil end  return SIZE(node).height; end

cc.exports.randData = function(num)
	local tmp = {}
	for i = 1, num do
		local vl = math.random(1, 54)
		table.insert(tmp, #tmp + 1, vl)
	end
	return tmp
end

cc.exports.randData1 = function(v, num)
	local tmp = {}
	for i = 1, num do
		table.insert(tmp, #tmp + 1, v)
	end

	return tmp
end