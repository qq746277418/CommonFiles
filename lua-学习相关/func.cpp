#include "func.h"  

int l_Foo_constructor(lua_State *L) 
{
	const char *name = luaL_checkstring(L, 1);
	Foo **udata = (Foo**)lua_newuserdata(L, sizeof(Foo*));
	*udata = new Foo(name);

	luaL_getmetatable(L, "luaL_Foo");
	// stack:  
	// -1   metatable "luaL_Foo"  
	// -2   userdata  
	// -3   string param  
	lua_setmetatable(L, -2);

	return 1;
}

Foo* l_CheckFoo(lua_State *L, int n) {
	return *(Foo**)luaL_checkudata(L, n, "luaL_Foo");
}

int l_Foo_Add(lua_State *L) {
	Foo *foo = l_CheckFoo(L, 1);
	int a = luaL_checknumber(L, 2);
	int b = luaL_checknumber(L, 3);

	std::string s = foo->Add(a, b);
	lua_pushstring(L, s.c_str());

	// stack:  
	// -1 result string  
	// -2 metatable "luaL_Foo"  
	// -3 userdata  
	// -4 string param  

	return 1;
}

int l_Foo_destructor(lua_State *L) {
	Foo *foo = l_CheckFoo(L, 1);
	delete foo;

	return 0;
}

void register_foo(lua_State *L) {
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
}