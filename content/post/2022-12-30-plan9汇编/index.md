+++
title="Golang|plan9汇编"
date="2022-12-30T19:56:00+08:00"
categories=["Golang"]
toc=false
+++

当我们使用`go tool compile -S -N -l xxx.go`命令，查看go语言对应的汇编代码时，生成的一行行汇编指令可能让人困惑，由于Go 使用了plan9 汇编，因此这篇文章接下来记录一下基础的plan9汇编知识。

## 基础指令

### 栈调整

plan9 的栈的调整大多是通过对硬件 SP 寄存器进行运算来实现的

```c
SUBQ $0x18, SP // 对 SP 做减法，为函数分配函数栈帧
...               // 省略无用代码
ADDQ $0x18, SP // 对 SP 做加法，清除函数栈帧
```

### 数据常量

常数在 plan9 汇编用 `$num` 表示，可以为负数，默认情况下为十进制，可以用 $0x123 的形式来表示十六进制数。

### 搬运指令

搬运的长度是由 MOV 的后缀决定的，操作方向上左边是数据源，右边是要搬运的寄存器

```c
MOVB $1, DI      // 1 byte
MOVW $0x10, BX   // 2 bytes
MOVD $1, DX      // 4 bytes
MOVQ $-10, AX    // 8 bytes
```

### 计算指令

类似数据搬运指令，同样可以通过修改指令的后缀来对应不同长度的操作数。例如 ADDQ/ADDW/ADDL/ADDB。

```c
ADDQ  AX, BX   // BX += AX
SUBQ  AX, BX   // BX -= AX
IMULQ AX, BX   // BX *= AX
```

### 跳转指令

```c
// 无条件跳转
JMP addr   // 跳转到地址，地址可为代码中的地址，不过实际上手写不会出现这种东西
JMP label  // 跳转到标签，可以跳转到同一函数内的标签位置
JMP 2(PC)  // 以当前指令为基础，向前/后跳转 x 行
JMP -2(PC) // 同上

// 有条件跳转
JZ target // 如果 zero flag 被 set 过，则跳转
```

## 寄存器

### 通用寄存器

plan9汇编里可使用的通用寄存器

AX、BX、CX、DX、DI、SI、BP、SP、R8、R9、R10、R11、R12、R13、R14、PC

### 伪寄存器

- FP: 使用形如 `symbol+offset(FP)` 的方式，引用函数的输入参数。例如 `arg0+0(FP)`，`arg1+8(FP)`，使用 FP 不加 `symbol` 时，无法通过编译，在汇编层面来讲，`symbol` 并没有什么用，加 `symbol` 主要是为了提升代码可读性。
- PC: 实际上就是在体系结构的知识中常见的 pc 寄存器。
- SB: 全局静态基指针，一般用来声明函数或全局变量，在之后的函数知识和示例部分会看到具体用法。
- SP: plan9 的这个 SP 寄存器指向当前栈帧的局部变量的开始位置，使用形如 `symbol+offset(SP)` 的方式，引用函数的局部变量。offset 的合法取值是 `[-framesize, 0)`，注意是个左闭右开的区间。假如局部变量都是 8 字节，那么第一个局部变量就可以用 `localvar0-8(SP)` 来表示。这也是一个词不表意的寄存器。与硬件寄存器 SP 是两个不同的东西，在栈帧 size 为 0 的情况下，伪寄存器 SP 和硬件寄存器 SP 指向同一位置。手写汇编代码时，如果是 `symbol+offset(SP)` 形式，则表示伪寄存器 SP。如果是 `offset(SP)` 则表示硬件寄存器 SP。务必注意。对于编译输出`(go tool compile -S / go tool objdump)`的代码来讲，目前所有的 SP 都是硬件寄存器 SP，无论是否带 `symbol`。

## 变量声明

在汇编里所谓的变量，一般是存储在 .rodata 或者 .data 段中的只读值。对应到应用层的话，就是已初始化过的全局的 const、var、static 变量/常量。

使用 DATA 结合 GLOBL 来定义一个变量。

DATA 的用法为: `DATA    symbol+offset(SB)/width, value`， offset 需要稍微注意。其含义是该值相对于符号 symbol 的偏移。

GLOBL 的用法为: `GLOBL divtab(SB), RODATA, $64`，GLOBL 必须跟在 DATA 指令之后。

下面是一个定义了多个 readonly 的全局变量的完整例子:

```c
DATA age+0x00(SB)/4, $18  // forever 18
GLOBL age(SB), RODATA, $4

DATA pi+0(SB)/8, $3.1415926
GLOBL pi(SB), RODATA, $8

DATA birthYear+0(SB)/4, $1988
GLOBL birthYear(SB), RODATA, $4

// 全局变量中定义字符串数组
DATA bio<>+0(SB)/8, $"oh yes i"
DATA bio<>+8(SB)/8, $"am here "
GLOBL bio<>(SB), RODATA, $16 // RODATA 是只读flag
```

## 函数

一个典型的 plan9 的汇编函数的定义，在 plan9 中 TEXT 是一个指令，用来定义一个函数。

```c
// func add(a, b int) int
//   => 该声明定义在同一个 package 下的任意 .go 文件中
//   => 只有函数头，没有实现
TEXT pkgname·add(SB), NOSPLIT, $0-8
    MOVQ a+0(FP), AX
    MOVQ b+8(FP), BX
    ADDQ AX, BX
    MOVQ BX, ret+16(FP)
    RET


                              参数及返回值大小
                                  | 
 TEXT pkgname·add(SB),NOSPLIT,$32-32
       |        |               |
      包名     函数名         栈帧大小(局部变量+可能需要的额外调用函数的参数空间的总大小，但不包括调用其它函数时的 ret address 的大小)
```

## 栈结构

```c
                                                                                   
                       -----------------                                           
                       current func arg0                                           
                       ----------------- <----------- FP(pseudo FP)                
                        caller ret addr                                            
                       +---------------+                                           
                       | caller BP(*)  |                                           
                       ----------------- <----------- SP(pseudo SP，实际上是当前栈帧的 BP 位置)
                       |   Local Var0  |                                           
                       -----------------                                           
                       |   Local Var1  |                                           
                       -----------------                                           
                       |   Local Var2  |                                           
                       -----------------                -                          
                       |   ........    |                                           
                       -----------------                                           
                       |   Local VarN  |                                           
                       -----------------                                           
                       |               |                                           
                       |               |                                           
                       |  temporarily  |                                           
                       |  unused space |                                           
                       |               |                                           
                       |               |                                           
                       -----------------                                           
                       |  call retn    |                                           
                       -----------------                                           
                       |  call ret(n-1)|                                           
                       -----------------                                           
                       |  ..........   |                                           
                       -----------------                                           
                       |  call ret1    |                                           
                       -----------------                                           
                       |  call argn    |                                           
                       -----------------                                           
                       |   .....       |                                           
                       -----------------                                           
                       |  call arg3    |                                           
                       -----------------                                           
                       | call arg2 |
                       | --------- |
                       | call arg1 |
                       -----------------   <------------  hardware SP 位置           
                         return addr                                               
                       +---------------+                                                 
```

从原理上来讲，如果当前函数调用了其它函数，那么 return addr 也是在 caller 的栈上的，不过往栈上插 return addr 的过程是由 CALL 指令完成的，在 RET 时，SP 又会恢复到图上位置。我们在计算 SP 和参数相对位置时，可以认为硬件 SP 指向的就是图上的位置。

## 调用流程

函数调用过程中栈帧发生了哪些变化？

- 执行 CALL 指令，调用
  - 入栈函数调用后的返回地址 return address（callee 返回到 caller 后，执行的 caller 的后续指令的地址 addr）
  - 跳转到 PC 寄存器指向的指令地址
- 分配好 callee 栈帧
  - 函数调用头部，编译器会插入 3 指令
    - 第一条：SUBQ $16, SP 分配 callee 的栈帧空间，将 sp 向下移动 16 字节，这个就是 callee 的栈顶
    - 第二条：MOVQ BP, 8(SP) 将 caller 的 BP 栈基备份到 return address 下面（低地址处)
    - 第三条：LEAQ 8(SP), BP 将 BP 寄存器指向 callee 的栈基（对 0x8(SP) 取地址，这个位置就是 callee 的栈基）
- 执行完 callee 函数代码段 TEXT 后续的指令
- 恢复 caller 的栈帧
  - 函数返回前，需要恢复 caller 的栈帧，编译器会插入 2 条指令到 函数的尾部
    - 第一条：MOVQ 8(SP), BP 恢复 caller 的 BP 栈基地址
    - 第二条：ADDQ $16, SP 释放 callee 的栈空间，SP 寄存器自然就恢复到了 caller 当初的位置
- 执行 RET 指令，返回
  - 出栈返回地址 return address
  - PC 寄存器跳转到 return address
  - 执行 return address 处的指令，caller 得以恢复执行

## 参考

- [plan9 assembly 完全解析](https://github.com/cch123/golang-notes/blob/master/assembly.md)
- [Go 汇编概述](https://hopehook.com/post/golang_assembly/)
- [肝了一上午的Golang之Plan9入门](https://mp.weixin.qq.com/s/8wnMvROFQkVTKZ-qe4_eqw)
