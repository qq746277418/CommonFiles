--[[
	* 函数传递(主要是栈的顺序取)
]]	
1.栈顺序
 3   top  -1  top: 获得栈元素个数(不包括自己)
 2   args -2  args:参数部分，按栈规则获取，先进后出
 1   obj  -3  obj: 对象数据
 
test:
  1.c++方法定义： CirCleBy *CirCleBy::create(float t, cocos2d::Vec2 circleCenter, float radius)
  2.第一步函数中有三个参数,类型分别是 float、Vec2 和 float
  tolua写入：  
	1.获取栈中top的数据
		int argc = lua_gettop(tolua_S);  --存储的是除此元素外的元素个数
	2.第一个元素当前对象处理（根据需要处理）
		CirCleBy* by = (CircleBY*)tolua_tousertype(tolua_S, 1, nullptr);
	3.获取余下参数
		double arg0 = lua_tonumber(tolua_S, 2)
		cocos2d::Vec2 arg1;  --特殊类型(不属于lua中的数据类型)
		luaval_to_vec2(tolua_S, 3, &arg1, "tolua_CircleBy_create");
		double arg2 = lua_tonumber(tolua_S, 4)
	4.需要返回对象?
		toluafix_pushusertype_ccobject(tolua_S,nID,pLuaID,(void*)obj, "cc.CircleBy");
		nID\pLuaID\obj