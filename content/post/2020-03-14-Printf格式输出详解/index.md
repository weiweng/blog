+++
title="Printf格式输出详解 "
tags=["c","printf"]
categories=["c"]
date="2020-03-14T10:54:00+08:00"
summary = 'Printf格式输出详解 '
toc=false
+++

Printf格式输出详解
------------------

### 转换说明符

-	%a 浮点数、十六进制数
-	%c 字符
-	%d 有符号十进制整数
-	%f 浮点数(包括float和double)
-	%e 浮点数指数输出
-	%g 浮点数不显示无意义的零
-	%i 有符号十进制整数
-	%u 无符号十进制整数
-	%o 八进制整数
-	%x 十六进制整数
-	%p 指针
-	%s 字符串
-	%% 显示百分号%
-	l 对整型指long型，对实型指double型 - h 用于将整型的格式字符修正为short型 ### 标志 - \- 左对齐
-	\+ 右对齐
-	空格 若符号为正，则显示空格，负则显示-
-	\# 对c,s,d,u无影响；对o，在输出时加前缀0；对x，加前缀0X；对e,g,f当结果有小数时才给出小数点

### 格式字符串

```vim
格式字符串：[标志][输出最少宽度][.精度][长度]类型
```

-	%-md 左对齐，若m比实际少时，按实际输出
-	%m.ns 输出占用m位，实际输出字符为字符串左起n位，当n>m or m省略时m=n
-	%m.nf 输出浮点数，m为宽度，n为小数点右边数位

### 代码测试

```javascript
#include<stdio.h>
int main(){
	int a = 255;
	printf("%%d:%d\n",a);
	printf("%%o:%o\n",a);
	printf("%%#o:%#o\n",a);
	printf("%%x:%x\n",a);
	printf("%%#x:%#x\n",a);
	printf("%%-2d:%-2d\n",a);
	printf("%%-4d:%-4d\n",a);
	float c = 2345.6789;
	printf("%%f:%f\n",c);
	printf("%%a:%a\n",c);
	printf("%%3.3f:%3.3f\n",c);
	printf("%%5.5f:%5.5f\n",c);
	printf("%%3.5f:%3.5f\n",c);
	printf("%%5.3f:%5.3f\n",c);
	float b = 012345.67890000;
	printf("%%f:%f\n",b);
	printf("%%e:%e\n",b);
	printf("%%g:%g\n",b);
	unsigned int d = 25536;
	printf("%%u:%u\n",d);
	char e = 'a';
	printf("%%c:%c\n",e);
	char* f = "123456789";
	printf("%%s:%s\n",f);
	printf("%%p:%p\n",f);
	char* g1 = "123";
	char* g2 = "4567";
	char* g3 = "89101";
	printf("%%+s:%4s %4s %4s\n",g1,g2,g3);
	printf("%%-s:%-4s %-4s %-4s\n",g1,g2,g3);
	char* h = "12345";
	printf("string h : %s\n",h);
	printf("%%3.3s:%3.3s\n",h);
	printf("%%5.5s:%5.5s\n",h);
	printf("%%3.5s:%3.5s\n",h);
	printf("%%5.3s:%5.3s\n",h);
	return 0;
}
```

代码结果

```
%d:255
%o:377
%#o:0377
%x:ff
%#x:0xff
%-2d:255
%-4d:255 
%f:2345.678955
%a:0x1.2535bap+11
%3.3f:2345.679
%5.5f:2345.67896
%3.5f:2345.67896
%5.3f:2345.679
%f:12345.678711
%e:1.234568e+04
%g:12345.7
%u:25536
%c:a
%s:123456789
%p:0x400900
%+s: 123 4567 89101
%-s:123  4567 89101
string h : 12345
%3.3s:123
%5.5s:12345
%3.5s:12345
%5.3s:  123
```

