+++
title="const"
tags=["c++","const"]
categories=["c++"]
date="2020-03-14T10:53:00+08:00"
summary = 'const'
toc=false
+++

CONST
-----

本文主要说明C++中const的相关使用注意事项，[原文地址见此](原文见此： http://www.cnblogs.com/xudong-bupt/p/3509567.html)

C++ const 允许指定一个语义约束，编译器会强制实施这个约束，允许程序员告诉编译器某值是保持不变的。如果在编程中确实有某个值保持不变，就应该明确使用const，这样可以获得编译器的帮助。

### const修饰成员变量

```c
using namespace std;
int main(){
    int a1=3;   ///non-const data
    const int a2=a1;    ///const data
 
    int * a3 = &a1;   ///non-const data,non-const pointer
    const int * a4 = &a1;   ///const data,non-const pointer
    int * const a5 = &a1;   ///non-const data,const pointer
    int const * const a6 = &a1;   ///const data,const pointer
    const int * const a7 = &a1;   ///const data,const pointer
 
    return 0;
}
```

const修饰指针变量时：

-	只有一个const，如果const位于*左侧，表示指针所指数据是常量，不能通过解引用修改该数据；指针本身是变量，可以指向其他的内存单元。

-	只有一个const，如果const位于*右侧，表示指针本身是常量，不能指向其他内存地址；指针所指的数据可以通过解引用修改。

-	两个const，*左右各一个，表示指针和指针所指数据都不能修改。

### const修饰函数参数

传递过来的参数在函数内不可改变，与上面修饰变量的性质一样。

### const修饰成员变量

-	const修饰的成员函数不能修改任何的成员变量(mutable修饰的变量除外)

-	const成员函数不能调用非const成员函数，因为非const成员函数可以会修改成员变量

	```c
	using namespace std;
	class Point{
	public :
	Point(int _x):x(_x){}
	 
	void testConstFunction(int _x) const{
	 
	    ///错误，在const成员函数中，不能修改任何类成员变量 x=_x;
	 
	    ///错误，const成员函数不能调用非onst成员函数，因为非const成员函数可以会修改成员变量
	    modify_x(_x);
	}
	 
	void modify_x(int _x){ x=_x;
	}
	 
	int x;
	};
	```

### const修饰函数返回值

-	指针传递 如果返回const data,non-const pointer，返回值也必须赋给const data,non-const pointer。因为指针指向的数据是常量不能修改。

	```c
	const int * mallocA(){  ///const data,non-const pointer
	int *a=new int(2);
	return a;
	}
	 
	int main()
	{
	const int *a = mallocA();
	///int *b = mallocA();  ///编译错误
	return 0;
	}
	```

-	值传递 如果函数返回值采用“值传递方式”，由于函数会把返回值复制到外部临时的存储单元中，加const 修饰没有任何价值。所以，对于值传递来说，加const没有太多意义。 所以注意一下几点：

	-	不要把函数int GetInt(void) 写成const int GetInt(void)。
	-	不要把函数A GetA(void) 写成const A GetA(void)，其中A 为用户自定义的数据类型。

在编程中要尽可能多的使用const，这样可以获得编译器的帮助，以便写出健壮性的代码。 更多资料参考：[http://www.cnblogs.com/yc_sunniwell/archive/2010/07/14/1777416.html](http://www.cnblogs.com/yc_sunniwell/archive/2010/07/14/1777416.html)

