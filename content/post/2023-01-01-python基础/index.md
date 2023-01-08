+++
title="Python|基础知识"
date="2023-01-01T19:43:00+08:00"
categories=["Python"]
summary = 'python3的基础知识点'
toc=true
+++

## 变量

变量不需要使用任何特定类型声明，甚至可以在设置后更改其类型。同时允许在一行中为多个变量赋值。

```c
x = 5 # x is of type int
x = "Steve" # x is now of type str
print(x)

x, y, z = "Orange", "Banana", "Cherry"
print(x)
print(y)
print(z)
```

在函数外部创建的变量称为**全局变量**。全局变量可以被函数内部和外部的每个人使用。如果在函数内部创建具有相同名称的变量，则该变量将是局部变量，并且只能在函数内部使用。具有相同名称的全局变量将保留原样，并拥有原始值。

如果想要在函数内部创建全局变量，可以使用 global 关键字。

### 关键字

```c
and  as  assert  break
class  continue  def  del
elif  else  except  False
finally  for  from  global
if  import  in  is  lambda
None  nonlocal  not  or  
pass  raise  return  True  
try  while  with  yield
```

## 数据类型

- 文本类型: str
- 数值类型: int, float, complex
- 序列类型: list, tuple, range
- 映射类型: dict
- 集合类型: set, frozenset
- 布尔类型: bool
- 二进制类型: bytes, bytearray, memoryview

使用 type() 函数获取任何对象的数据类型。

```c
x = 10
print(type(x))
```

### 类型转换

- int() - 用整数字面量、浮点字面量构造整数，或者用表示完整数字的字符串字面量
- float() - 用整数字面量、浮点字面量，或字符串字面量构造浮点数
- str() - 用各种数据类型构造字符串，包括字符串，整数字面量和浮点字面量

```c
x = int(1)   # x 将是 1
y = int(2.5) # y 将是 2
z = int("3") # z 将是 3
```

## 运算

```c
加: +
减: -
乘: *
除: /
取整: %
幂: **
取整除: //
左移: <<
右移: >>
等于: ==
不等于: !=
大于: >
小于: <
大于等于: >=
小于等于: <=
逻辑与: and
逻辑或: or
逻辑非: not
两个变量是否同一个对象: is
两个变量是否不是同一个对象: is not
对象是否存在序列: in
对象是否不存在序列: not in
位运算与: &
位运算或: |
位运算非: ~
位运算异或: ^
```

## 列表

列表是一种有序和可更改的集合，允许重复的成员。

```c
thislist = ["apple", "banana", "cherry"]
print(thislist)

// 使用 list() 构造函数创建列表
thislist = list(("apple", "banana", "cherry")) # 请注意双括号
print(thislist)

// 负索引，从末尾开始，-1表示最后一个
thislist = ["apple", "banana", "cherry"]
print(thislist[-1])

// 通过索引取切片
thislist = ["apple", "banana", "cherry", "orange", "kiwi", "melon", "mango"]
print(thislist[2:5])
thislist = ["apple", "banana", "cherry", "orange", "kiwi", "melon", "mango"]
print(thislist[-4:-1])

// 更改数据
thislist = ["apple", "banana", "cherry"]
thislist[1] = "mango"
print(thislist)

// 列表长度
thislist = ["apple", "banana", "cherry"]
print(len(thislist))
```

### 遍历

```c
thislist = ["apple", "banana", "cherry"]
for x in thislist:
  print(x)
```

### 增加

```c
// append 最后位置增加
thislist = ["apple", "banana", "cherry"]
thislist.append("orange")
print(thislist)

// insert 指定位置增加
thislist = ["apple", "banana", "cherry"]
thislist.insert(1, "orange")
print(thislist)

// 合并列表
list1 = ["a", "b" , "c"]
list2 = [1, 2, 3]
list3 = list1 + list2
print(list3)

// extend 添加整个列表
list1 = ["a", "b" , "c"]
list2 = [1, 2, 3]
list1.extend(list2)
print(list1)
```

### 删除

```c
// remove 通过值删除
thislist = ["apple", "banana", "cherry"]
thislist.remove("banana")
print(thislist)

// pop 删除最后一个，拿到值
thislist = ["apple", "banana", "cherry"]
thislist.pop()
print(thislist)

// del 索引删除 or 删除整个列表
thislist = ["apple", "banana", "cherry"]
del thislist[0]
print(thislist)

thislist = ["apple", "banana", "cherry"]
del thislist

// 清空列表
thislist = ["apple", "banana", "cherry"]
thislist.clear()
print(thislist)
```

## 元组

元组是有序且不可更改的集合。

```c
thistuple = ("apple", "banana", "cherry")
print(thistuple)
```

其他操作和列表差不多

## 集合

集合是无序和无索引的集合。

```c
thisset = {"apple", "banana", "cherry"}
print(thisset)

// 使用 set() 构造函数来创建集合
thisset = set(("apple", "banana", "cherry")) # 请留意这个双括号
print(thisset)

// len()获取长度
thisset = {"apple", "banana", "cherry"}
print(len(thisset))
```

### 遍历

```c
thisset = {"apple", "banana", "cherry"}
for x in thisset:
  print(x)
```

### 新增

```c
// 使用add() 新增元素
thisset = {"apple", "banana", "cherry"}
thisset.add("orange")
print(thisset)

// update 批量更新
thisset = {"apple", "banana", "cherry"}
b = {"orange", "mango", "grapes"}
thisset.update(b)
print(thisset)

// union() 方法返回一个新集合，其中包含两个集合中的所有元素
set1 = {"a", "b" , "c"}
set2 = {1, 2, 3}
set3 = set1.union(set2)
print(set3)
```

### 删除

```c
// 使用 remove() 方法来删除，如果要删除的项目不存在，则 remove() 将引发错误。
thisset = {"apple", "banana", "cherry"}
thisset.remove("banana")
print(thisset)

// 使用 discard() 方法来删除，如果要删除的项目不存在，则 discard() 不会引发错误。
thisset = {"apple", "banana", "cherry"}
thisset.discard("banana")
print(thisset)

// clear() 方法清空集合
thisset = {"apple", "banana", "cherry"}
thisset.clear()
print(thisset)

// del 彻底删除集合
thisset = {"apple", "banana", "cherry"}
del thisset
print(thisset)
```

## 字典

字典是一个无序、可变和有索引的集合。

```c
thisdict =	{
  "brand": "Porsche",
  "model": "911",
  "year": 1963
}
print(thisdict)

// 修改值
thisdict =	{
  "brand": "Porsche",
  "model": "911",
  "year": 1963
}
thisdict["year"] = 2019
```

### 遍历

```c
// 逐个打印字典中的所有键名
for x in thisdict:
  print(x)

// 使用 values() 函数返回字典的值
for x in thisdict.values():
  print(x)

// 使用 items() 函数遍历键和值
for x, y in thisdict.items():
  print(x, y)
```

### 新增

```c
thisdict =	{
  "brand": "Porsche",
  "model": "911",
  "year": 1963
}
thisdict["color"] = "red"
print(thisdict)
```

### 删除

```c
// del 关键字删除具有指定键名的数据
thisdict =	{
  "brand": "Porsche",
  "model": "911",
  "year": 1963
}
del thisdict["model"]
print(thisdict)

// del 关键字也可以完全删除字典
thisdict =	{
  "brand": "Porsche",
  "model": "911",
  "year": 1963
}
del thisdict

// clear() 关键字清空字典
thisdict =	{
  "brand": "Porsche",
  "model": "911",
  "year": 1963
}
thisdict.clear()
```

## 字符串

字符串变量可以使用单引号或双引号进行声明

```go
x = "Bill"
# is the same as
x = 'Bill'
```

Python 中的字符串是表示 unicode 字符的字节数组。但是，Python 没有字符数据类型，单个字符就是长度为 1 的字符串。方括号可用于访问字符串的元素。

```c
a = "Hello, World!"
print(a[1])
```

### 拼接

串联或组合两个字符串，可以使用 + 运算符。

```c
a = "Hello"
b = "World"
c = a + b
print(c)
```

也可以使用`format()`函数

```c
age = 63 
txt = "My name is Bill, and I am {}"
print(txt.format(age))

quantity = 3
itemno = 567
price = 49.95
myorder = "I want {} pieces of item {} for {} dollars."
print(myorder.format(quantity, itemno, price))

quantity = 3
itemno = 567
price = 49.95
myorder = "I want to pay {2} dollars for {0} pieces of item {1}."
print(myorder.format(quantity, itemno, price))
```

### 字符串方法

参考标准库[字符串方法](https://docs.python.org/3.11/library/stdtypes.html#string-methods)

## 控制

### if语句

```c
a = 200
b = 66
if b > a:
  print("b is greater than a")
elif a == b:
  print("a and b are equal")
else:
  print("a is greater than b")
```

### for循环

```c
fruits = ["apple", "banana", "cherry"]
for x in fruits:
  print(x)

// range函数生成下标
for x in range(10):
  print(x)

for x in range(10):
  print(x)
else:
  print("Finally finished!")

// for 语句不能为空，但是可以使用 pass 语句来避免错误。
for x in [0, 1, 2]:
  pass
```

循环少不了`break`和`continue`语句，和其他语言一样。

### while循环

```c
i = 1
while i < 6:
  print(i)
  i += 1
else:
  print("i is no longer less than 6")
```

## 函数

```c
// 无参数函数
def my_function():
  print("Hello from a function")

my_function()

// 带参数函数
def my_function(fname):
  print(fname + " Gates")

my_function("Bill")

// 带默认参数
def my_function(country = "China"):
  print("I am from " + country)

my_function("Sweden")
my_function()

// 任意参数
// 这样函数将接收一个参数元组，并可以相应地访问各项
def my_function(*kids):
  print("The youngest child is " + kids[2])

my_function("Phoebe", "Jennifer", "Rory")

// 任意参数
// 这样函数将接收一个参数字典，并可以相应地访问各项
def my_function(first,**others):
  print("The youngest child is " + others.get('k'))

my_function("Phoebe", k="Jennifer")

// pass避免空函数报错
def myfunction:
  pass

// 带返回值
def my_function(x):
  return 5 * x

print(my_function(3))
```

## lambda函数

```c
x = lambda a : a + 10
print(x(5))

x = lambda a, b : a * b
print(x(5, 6))
```

## 类

Python 是一种面向对象的编程语言。Python 中的几乎所有东西都是对象，拥有属性和方法。

类（Class）类似对象构造函数，或者是用于创建对象的“蓝图”。每次使用类创建新对象时，都会自动调用 `__init__()` 函数。

```c
// self 参数是对类的当前实例的引用，用于访问属于该类的变量。
class Person:
  def __init__(self, name, age):
    self.name = name
    self.age = age

  def myfunc(self):
    print("Hello my name is " + self.name)

p1 = Person("Bill", 63)
p1.myfunc()
print(p1.name)

// 删除 p1 对象的 age 属性
del p1.age

// 使用 del 关键字删除对象
del p1
```

### 继承

继承允许我们定义继承另一个类的所有方法和属性的类。

父类是继承的类，也称为基类。

子类是从另一个类继承的类，也称为派生类。

```c
class Person:
  def __init__(self, fname, lname):
    self.firstname = fname
    self.lastname = lname

  def printname(self):
    print(self.firstname, self.lastname)

# 使用 Person 来创建对象，然后执行 printname 方法：

x = Person("Bill", "Gates")
x.printname()

class Student(Person):
  def __init__(self, fname, lname):
    super().__init__(fname, lname)

  // 子类中添加一个与父类中的函数同名的方法，则将覆盖父方法的继承。
  def printname(self):
    print(self.firstname+"子类", self.lastname)

  def printname(self, disk):
    print(self.firstname+"子类", self.lastname+disk)
```

## 模块

模块是包含一组函数的文件，希望在应用程序中引用。

### 创建

创建模块，只需将所需代码保存在文件扩展名为 .py 的文件中

```c
// 函数编辑再文件 mymodule.py 文件中
def greeting(name):
  print("Hello, " + name)
```

### 使用

用 import 语句来使用模块

```c
import mymodule

mymodule.greeting("Bill")

// 使用 as 关键字创建别名
import mymodule as mx

a = mx.person1["age"]
print(a)
```

使用 from 关键字选择仅从模块导入部件。

```c
from mymodule import person1

print (person1["age"])
```

## 异常

try 块允许测试代码块以查找错误。

except 块允许处理错误。

else 如果没有引发错误，那么可以使用 else 关键字来定义要执行的代码块。

finally 块允许执行代码，无论 try 和 except 块的结果如何。

raise 主动抛出异常。

```c
try:
  print(x)
  if x<0:
    raise Exception("Sorry, no numbers below zero")
except NameError:
  print("Variable x is not defined")
except:
  print("Something else went wrong")
else:
  print("ok,else do")
finally:
  print("i'm finally.")
```
