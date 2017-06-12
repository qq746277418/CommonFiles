display.fileUtils = cc.FileUtils:getInstance()

local CardLayer = import(".CardLayer")

local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
      print("==================================隔断符================================")
    -- add background image
    -- local sp = display.newSprite("HelloWorld.png")
    --     :move(display.center)
    --     :addTo(self)

    -- -- add HelloWorld label
    -- cc.Label:createWithSystemFont("Hello World", "Arial", 40)
    --     :move(display.cx, display.cy + 200)
    --     :addTo(self)

  --   function Foo:speak()  
  --     print("hello, i am a Foo")  
  --   end  

  	local cardLayer = 


        
  --   local foo = Foo.new("adfan")  
  --   local m = foo:add(3, 4)  
  --   print(m)  
        
  --   foo:speak()  
  
  --   Foo.add_ = Foo.add  
  -- function Foo:add(a, b)  
  --   return "magic: " .. self:add_(a, b)  
  -- end  
    
  -- m = foo:add(9, 8)  
  -- print(m)  

    --[[
		*元表
		*任何table都可以作为任何值的元表
		*一组相关的table也可以共享一个通用的元表,此元表描述它们的一个共同行为,可任意搭配
		*在lua代码中,只能设置table的元表,若是要设置其他值的元表则要通过C代码完成
		*只有标准字符串库给所有字符串设置了一个元表
		*算数类元方法{__add, __mul, __sub, __div, __unm(相反数), __mod, __pow, __concat(连接符)}
		*关系类元方法{__eq, __lt(<), __le(<=), }
			*关系运算符不能作用于混合类型
		*库定义的元方法{__tostring, __metatable(字段设置后不能再设置元表)}
		*table元方法{__index(用于更新), __newindex(用于查询)}
			*访问一个table中不存在的字段时，解释器会去访问__index元方法,如果没有这个元方法,将返回nil,
			否则，最终结果将是调用__index的结果;
    ]]
 --    local t = {}
 --    local t1 = {}
 --    setmetatable(t, t1)
 --    print(getmetatable(t) == t1)

 --    local mt = {}  --准备用作集合的元表
 --    local Set = {}
 --    function Set.new(l)
 --    	local set = {}
 --    	--将mt设置为当前table的元表
 --    	setmetatable(set, mt)
 --    	for _,v in ipairs(l) do
 --    		set[v] = true
 --    	end
 --    	return set
 --   	end

 --   	function Set.union(a, b)
 --   		if(getmetatable(b) ~= mt or getmetatable(b) ~= mt) then
 --   			error("attemp to 'add' a set width a non-set value", 2)
 --   		end
 --   		local res = Set.new{}
 --   		for k in pairs(a) do res[k] = true end
 --   		for k in pairs(b) do res[k] = true end
 --   		return res
 --   	end

 --   	function Set.intersection(a, b)
 --   		local res = Set.new{}
 --   		for k in pairs(a) do
 --   			res[k] = b[k]
 --   		end
 --   		return res
 --   	end

 --   	function Set.toString(set)
 --   		local l = {}
 --   		for e in pairs(set) do
 --   			l[#l + 1] = e
 --   		end
 --   		return "{" .. table.concat(l, ",") .. "}"
 --   	end

 --   	function Set.print(s)
 --   		print(Set.toString(s))
 --   	end

 --   	local s1 = Set.new{10, 20, 50, 30}
 --   	local s2 = Set.new{1, 20, 3}
 --   	print(getmetatable(s1))
 --   	print(getmetatable(s2))

 --   	--加法
 --   	mt.__add = Set.union  --描述加法
 --   	local s3 = s1 + s2
 --   	Set.print(s3)

 --   	--乘法
 --   	mt.__mul = Set.intersection  --描述减法
 --   	Set.print((s1 + s2) * s1)

 --   	--[[
	-- 	关系类元方法
 --   	]]
 --   	mt.__le = function(a, b)
 --   		for k in pairs(a) do
 --   			if not b[k] then
 --   				return false
 --   			end
 --   		end
 --   		return true
 --   	end

 --   	mt.__lt = function(a, b)
 --   		return a <= b and not (b <= a)
 --    end

 --    mt.__eq = function(a, b)
	-- 	return a <= b and b <= a
	-- end

	-- --test
	-- s1 = Set.new{2, 4}
	-- s2 = Set.new{4, 10, 2}
	-- print(s1 <= s2)  	--true
	-- print(s1 < s2)		--true
	-- print(s1 >= s1)		--false
	-- print(s1 > s1)		--false
	-- print(s1 == s2 * s1)--true

	-- mt.__metatable = "not you business"
	-- print(getmetatable(s1))
	-- --setmetatable(s1, {})

	-- --[[
	-- 	继承
	-- ]]
	-- local Windows = {}
	-- --使用默认值创建一个原型
	-- Windows.prototype = {x = 0, y = 0, width = 100, height = 100}
	-- Windows.mt = {} --元表
	-- --构造函数
	-- function Windows.new(o)
	-- 	setmetatable(o, Windows.mt)
	-- 	return o
	-- end
	-- --定义__index元方法
	-- --* 函数形式定义__index方法(开销大\灵活性高)
	-- --* 通过函数形式可以来实现多重继承、缓存等功能
	-- Windows.mt.__index = function(table, key)
	-- 	return Windows.prototype[key]
	-- end
	-- --*不以函数形式实现__index，以table形式实现
	-- Windows.mt.__index = Windows.prototype

	-- --test
	-- local w = Windows.new{x = 10, y = 20}
	--??? rawget 字段
end

return MainScene
