--[[
	* lua与c的互相调用解释

	C API
	*void lua_pushnil(lua_State *L);
	*void lua_pushboolean(lua_State *L);
	*void lua_pushnumber(lua_State *L);
	*void lua_pushinteger(lua_State *L);
	*void lua_pushlstring(lua_State *L);
	*void lua_pushstring(lua_State *L);
	
	//检查栈中是否有足够的空间
	*int lua_checkstack(lua_State *L, int sz);
	*索引存值： 1表示第一个压入栈中的元素 ...
		*-1表示栈顶元素(最后压入的元素)
	*对应以上压入类型,对于提供了检查函数
		* int lua_is*(lua_State *L, int index);<泛型>
		* lua_isnumber不会检查是否为数字类,而是检查是否可以转为数字类型<其他的亦是>；
	*从栈中获取值
		*int lua_to*(lua_State *L, int index);<泛型>
		*int lua_toboolean (lua_State *L, int index);
		*lua_Number lua_tonumber (lua_State *L, int index);
		*lua_Integer lua_tointeger (lua_State *L, int index);
		*const char* lua_tolstring (lua_State *L, int index, size_t *len);
		*size_t lua_objlen (lua_State *L, int index);
	*栈操作函数
		* int lua_gettop (lua_State *L);				//返回元素个数 
		* void lua_settop (lua_State *L, int index);	//重新设置栈顶,高出部分将丢弃
		* void lua_pushvalue (lua_State *L, int index);
		* void lua_remove (lua_State *L, int index);
		* void lua_insert (lua_State *L, int index);
		* void lua_replace (lua_State *L, int index);
	
	零碎的
		*luaL_checkstring
		*luaL_getmetatable
		*lua_newuserdata
		*lua_setmetatable
		*luaL_checkudata
		*lua_setglobal(L, "Foo"); 将元表luaL_Foo重命名为Foo并将它设为Lua的全局变量v
		[
		此函数是注册C++类到Lua和注册所有已绑定的C++函数到Lua。 sFooRegs 给每个已绑定
		的C++函数一个能被Lua访问的名字。 luaL_newmetatable 创建一个名为luaL_Foo的元表
		并压入栈定， luaL_register 将 sFooRegs 添加到luaL_Foo中。 lua_pushvalue 将luaL_Foo
		元表中元素的拷贝压入栈中。 lua_setfield 将luaL_Foo元表的index域设为 __index 。 
		lua_setglobal 将元表luaL_Foo重命名为Foo并将它设为Lua的全局变量，这样Lua可以通过识别
		Foo来访问元表luaL_Foo，并使Lua脚本能够覆盖元表Foo，即覆盖C++函数。如此一来，用户可以用
		Lua代码自定功能，覆盖掉C++类中函数的功能，极大地提高了代码灵活性。
			luaL_Reg sFooRefs[] = {
				{ "new", l_Foo_constructor },
				{ "add", l_Foo_Add },
				{ "__gc", l_Foo_destructor },
				{ NULL, NULL }
			};

			luaL_newmetatable(L, "luaL_Foo");
			luaL_register(L, NULL, sFooRefs);
			lua_pushvalue(L, -1);

			// stack:  
			// -1: metatable "luaL_Foo"  
			// -2: metatable "luaL_Foo"  

			// this pops the stack  
			lua_setfield(L, -1, "__index");

			lua_setglobal(L, "Foo");
		]
	*=====================================================================================	

	lua在c程序中可以以下方式调节
		#ifdef --cplusplus
		extern "C" {
		#dedif
		...
		#ifdef --cplusplus
		}
		#endif
	如果将lua作为c代码来编译，并在c++中使用，以lua.hpp来代替lua.h
	lua.hpp定义为以下形式
		extern "C" {
			#include "lua.h"
		}
	
















	* 从lua调用c/c++
		
]]

