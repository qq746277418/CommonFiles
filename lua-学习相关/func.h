#pragma once  

#include <iostream>  
#include <sstream>  

extern "C"
{
#include <lua.h>  
#include <lauxlib.h>  
#include <lualib.h>  
}

class Foo
{
public:
	Foo(const std::string & name) : name(name)
	{
		std::cout << "Foo is born" << std::endl;
	}

	std::string Add(int a, int b)
	{
		std::stringstream ss;
		ss << name << ": " << a << " + " << b << " = " << (a + b);
		return ss.str();
	}

	~Foo()
	{
		std::cout << "Foo is gone" << std::endl;
	}

private:
	std::string name;
};

void register_foo(lua_State *L);