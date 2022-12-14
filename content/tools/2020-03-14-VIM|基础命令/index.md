+++
title="VIM|基础命令"
tags=["vim"]
date="2020-03-14T11:00:00+08:00"
summary = 'VIM|基础命令'
toc=false
+++

### 命令历史

以:和/开头的命令都有历史纪录，可以首先键入:或/然后按上下箭头来选择某个历史命令。

### 启动vim

在命令行窗口中输入以下命令即可 **`vim`** 直接启动vim **`vim filename`** 打开vim并创建名为filename的文件 **`vim filename +num`** 使用vim打开文件filename并跳转至num行

### vim的模式

-	普通模式（按Esc或Ctrl+[进入） 左下角显示文件名或为空
-	插入模式（按i键进入） 左下角显示--INSERT--
-	可视模式（不知道如何进入） 左下角显示--VISUAL--

### 普通模式

#### 文件命令

-	**`vim file`** 打开单个文件
-	**`vim file1 file2 file3...`** 同时打开多个文件

#### 导航命令

-	**`%`** 括号匹配
-	**`<C-o>`** 向后跳转文件
-	**`<C-i>`** 向前跳转文件

#### 插入命令

-	**`i`** 在当前位置生前插入
-	**`I`** 在当前行首插入
-	**`a`** 在当前位置后插入
-	**`A`** 在当前行尾插入
-	**`o`** 在当前行之后插入一行
-	**`O`** 在当前行之前插入一行

#### 编辑命令

-	**`gU`** 转为大写
-	**`gu`** 转为小写
-	**`ddp`** 交换光标所在行和其下紧邻的一行。

#### 移动命令

-	**`h`** 左移一个字符
-	**`l`** 右移一个字符，这个命令很少用，一般用w代替。
-	**`k`** 上移一个字符，移动的是实际行
-	**`gk`** 移动屏幕行
-	**`j`** 下移一个字符
-	**`gj`** 移动屏幕行 以上四个命令可以配合数字使用，比如20j就是向下移动20行，5h就是向左移动5个字符，在Vim中，很多命令都可以配合数字使用，比如删除10个字符10x，在当前位置后插入3个！，`3a<Esc>`，这里的Esc是必须的，否则命令不生效。
-	**`w`** 向前移动一个单词（光标停在单词首部），如果已到行尾，则转至下一行行首。此命令快，可以代替l命令。
-	**`b`** 向后移动一个单词 2b 向后移动2个单词
-	**`e`** 同w，只不过是光标停在单词尾部
-	**`ge`** 同b，光标停在单词尾部。 上述wbege，统统都是对应字符word的操作，而大写额W B E gE 是对应字符串的操作。
-	**`^`** 移动到本行第一个非空白字符上。
-	**`g^`** 移动到屏幕行第一个非空白字符上
-	**`0`**（数字0）移动到本行第一个字符上，
-	**`g0`** 移动到屏幕行第一个字符
-	\*\*`<HOME>` \**移动到本行第一个字符。同0健。
-	**`$`** 移动到行尾
-	**`3$`**移动到下面3行的行尾
-	**`g$`** 移动屏幕行行尾
-	**`gg`** 移动到文件头
-	**`G`**（shift + g） 移动到文件尾
-	**`f`**（find）命令用于行的字符查找，也可以用于移动，fx将找到光标后第一个为x的字符，3fd将找到第三个为d的字符。\**; \** 下一个移动， **\,**(逗号那个键)上一个移动
-	**`F`** 同f，反向查找。
-	**`T{char} t{char}`**同F 和 f的作用一样，但是让光标停留在寻找字符的前面 跳到指定行，冒号+行号，回车，比如跳到240行就是 :240回车。另一个方法是行号+G，比如230G跳到230行。
-	**`Ctrl + e`** 向下滚动一行
-	**`Ctrl + y`** 向上滚动一行
-	**`Ctrl + d`** 向下滚动半屏
-	**`Ctrl + u`** 向上滚动半屏
-	**`Ctrl + f`** 向下滚动一屏
-	**`Ctrl + b`** 向上滚动一屏

#### 撤销和重做

-	**`u`** 撤销（Undo）
-	**`U`** 撤销对整行的操作
-	**`<C-r>`** 重做（Redo），即撤销的撤销。

#### 删除命令

-	**`x`** 删除当前字符
-	**`3x`** 删除当前光标开始向后三个字符
-	**`X`** 删除当前字符的前一个字符。X=dh
-	**`dl`** 删除当前字符， dl=x
-	**`dh`** 删除前一个字符
-	**`dd`** 删除当前行
-	**`dj`** 删除上一行
-	**`dk`** 删除下一行
-	**`10d`** 删除当前行开始的10行。
-	**`D`** 删除当前字符至行尾。D=d$
-	**`d$`** 删除当前字符之后的所有字符（本行）
-	**`ddgg`** 删除当前行之前所有行（不包括当前行）
-	**`jdG`**（jd shift + g） 删除当前行之后所有行（不包括当前行）
-	**`J`**(shift + j)　　删除两行之间的空行，实际上是合并两行。
-	**`g/^$/d`** 刪除沒有內容的空行
-	**`g/^\s*$/d`** 刪除包含有空格組成的空行
-	**`g/^[ |\t]*$/d`** 除以空格或tab開頭到結尾的空行
-	**`g/pattern/d`** 是找到pattern, 删之
-	**`v/pattern/d`** 是找到非pattern,删之

#### 拷贝和粘贴

-	**`yy`** 拷贝当前行
-	**`nyy`** 拷贝当前后开始的n行，比如2yy拷贝当前行及其下一行。
-	**`p`** 在当前光标后粘贴,如果之前使用了yy命令来复制一行，那么就在当前行的下一行粘贴。
-	**`shift+p`** 在当前行前粘贴
-	**`xp`**交换当前字符和其后一个字符

#### 剪切命令

-	**`ndd`** 剪切当前行之后的n行。利用p命令可以对剪切的内容进行粘贴

#### 退出命令

-	**`ZZ`** 保存并退出

#### 折叠命令

-	**`zc`** 折叠
-	**`zC`** 对所在范围内所有嵌套的折叠点进行折叠
-	**`zo`** 展开折叠
-	**`zO`** 对所在范围内所有嵌套的折叠点展开
-	**`zf%`** `zf`创建折叠，`zf%`创建从当前行起到对应的匹配的括号上去
-	**`zd`** 删除在光标下的折叠(在`set fdm=manual` 或`set fdm=marker`下有作用)
-	**`zD`** 循环删除光标下的折叠，即嵌套删除折叠
-	**`ze`** 除去窗口里所有的折叠

#### 窗口命令

-	**`zz`** 重绘屏幕，并把当前行号显示在中央
-	**`<C-w>s`** 水平切分当前窗口
-	**`<C-w>v`** 垂直切分当前窗口
-	**`:sp[lit] {file}`** 水平切分当前窗口，并在新窗口中载入file
-	**`:vsp[lit] {file}`** 垂直切分当前窗口，并在新窗口中载入file
-	**\`<C-w>c** 关闭当前窗口
-	**\`<C-w>o** 只保留当前窗口
-	**\`<C-w>=** 使所有窗口等宽等高
-	**\`<C-w>\_** 最大化活动窗口高度
-	**`<C-w>|`** 最大化活动窗口宽度
-	**`Ctrl+ww`** 移动到下一个窗口
-	**`Ctrl+wj`** 移动到下方的窗口
-	**`Ctrl+wk`** 移动到上方的窗口
-	**`ZZ`** 保存并退出。

#### 录制宏

按q键加任意字母开始录制，再按q键结束录制（这意味着vim中的宏不可嵌套），使用的时候@加宏名，比如qa。。。q录制名为a的宏，@a使用这个宏。

#### 其他非编辑命令

-	**`.`** 重复前一次命令
-	**`\`*** 自动搜索光标所在单词
-	**`m{a-zA-Z}`** 选定字母标定当前光标所在位置
-	**`{mark}** 调回标记位置
-	**\`\`** 当前文件中上次跳转动作之前的位置
-	**`.** 上次修改的地方
-	**`^** 上次插入的位置
-	**\`\[** 上次修改或者复制的起始位置
-	**`]** 上次修改或复制的结束位置
-	**\`\<** 上次高亮选区的起始位置
-	**`>** 上次高亮选区的结束位置
-	**`Ctrl+i`** 跳转文件
-	**`Ctrl+o`** 跳转文件

### 插入模式

#### 编辑命令

-	**`<C-h>`** 删除前一个字符
-	**`<C-w>`** 删除前一个单词
-	**`<C-u>`** 删除到行首
-	**`<Esc>`** 切换到普通模式
-	**`<C-[>`** 切换到普通模式
-	**`<C-o>`** 切换到插入-普通模式
-	**`<C-r>{register}`** 引入寄存器功能
-	**`<C-v>{code}`** 插入code字符

### 可视模式

#### 编辑命令

-	**`v`** 激活面向字符的可视模式
-	**`V`** 激活面向行的可视模式
-	**`<C-v>`** 激活面向列块的可视模式
-	**`gv`** 重选上次的高亮选区
-	**`o`** 切换高亮选取的活动端
-	**`vi}`** 快熟选取选取
-	**`vi{`**
-	**`vi[`**
-	**`vi]`**
-	**`vi'`**
-	**`vi"`**
-	**`vi(`**
-	**`vi)`**
-	**`vi<`**
-	**`vi>`**
-	**`vit`**
-	**`vat`** 快熟选取选取
-	列式批量操作小技巧:取列区域+移动操作/插入操作+ESC

### 命令模式

#### 编辑命令

-	**`:[range]delete [x]`** 删除指定范围内的行[到寄存器x中]
-	**`:[range]yank [x]`** 复制指定范围内的行[到寄存器x中]
-	**`:[line]put [x]`** 指定行后粘贴寄存器x中的内容
-	**`:[range]copy {address}`** 指定范围内的行拷贝到{address}指定的行下
-	**`:[range]move {address}`** 指定范围内的行移动到{address}指定的行下
-	**`:[range]join`** 连接指定范围内的行
-	**`:[range]normal {commands}`** 对指定范围内的行执行{commands}命令
-	**`:[range]substitute/{pattern}/{string}/[flags]`** 对指定范围内的行出现{pattern}的字符替换为{string}
-	**`:[range]global/{pattern}/[cmd]`** 对指定范围内的匹配{pattern}的行执行cmd
-	**`:.`** 当前行的位置
-	**`:{start},{end}`** 表示start到end的所有行
-	**`:%`** 当前文件的所有行
-	**`:1`** 文件第一行
-	**`:$`** 文件最后一行
-	**`:0`** 虚拟行，位于文件第一行上方
-	**`:'m`** 包含位置标记m的行
-	**`:'<`** 高亮选中区的开头
-	**`:'>`** 高亮选中区的结尾
-	**`:t`** 等同于:copy
-	**`:m`** 移动
-	**`:%normal A;`** 全文最后添加；
-	**`@:`** 重复ex命令
-	**`<C-o>`** 回退@:命令
-	**`:xxx<C-d>`** 自动补全ex命令
-	**`:h <C-r><C-w>`** 读取光标所在单词
-	**`:h <C-r><C-a>`** 读取光标所在字符串
-	**`q:`** 调出vim命令行窗口
-	**`<C-f>`** 从命令行模式切换到命令行窗口
-	**`:open file`** 在vim窗口中打开一个新文件
-	**`:split file`** 在新窗口中打开文件
-	**`:bn`** 切换到下一个文件
-	**`:bp`** 切换到上一个文件
-	**`:args`** 查看当前打开的文件列表，当前正在编辑的文件会用[]括起来。
-	**`:e ftp://192.168.10.76/abc.txt`** 打开远程文件，比如ftp或者share folder
-	**`:e \\qadrive\test\1.txt`**
-	**`:G[number]`** goto line [number]

#### 查找命令

-	**`/text`**　　查找text，按n健查找下一个，按N健查找前一个。
-	**`?text`**　　查找text，反向查找，按n健查找下一个，按N健查找前一个。
-	vim中有一些特殊字符在查找时需要转义　　`.*[]^%/?~$`
-	**`:set ignorecase`**　　忽略大小写的查找
-	**`:set noignorecase`**　　不忽略大小写的查找,查找很长的词，如果一个词很长，键入麻烦，可以将光标移动到该词上，按*或#键即可以该单词进行搜索，相当于/搜索。而#命令相当于?搜索。
-	**`:set hlsearch`**　　高亮搜索结果，所有结果都高亮显示，而不是只显示一个匹配。
-	**`:set nohlsearch`**　　关闭高亮搜索显示
-	**`:set nohls`** 取消高亮显示
-	**`:nohlsearch`**　　关闭当前的高亮显示，如果再次搜索或者按下n或N键，则会再次高亮。
-	**`:set incsearch`**　　逐步搜索模式，对当前键入的字符进行搜索而不必等待键入完成。
-	**`:set wrapscan`**　　重新搜索，在搜索到文件头或尾时，返回继续搜索，默认开启。

#### 替换命令

-	**`ra`** 将当前字符替换为a，当期字符即光标所在字符。
-	**`:s/old/new/`** 用old替换new，替换当前行的第一个匹配
-	**`:s/old/new/g`** 用old替换new，替换当前行的所有匹配
-	**`:%s/old/new/`** 用old替换new，替换所有行的第一个匹配
-	**`:%s/old/new/g`** 用old替换new，替换整个文件的所有匹配
-	**`:10,20 s/^/    /g`** 在第10行知第20行每行前面加四个空格，用于缩进。
-	**`:s/old/\r/`** 用old替换换行,替换当前行所有匹配

#### 全项目快速搜索

**vimgrep** `vimgrep /匹配模式/[g][j] 要搜索的文件/范围`

```
g：表示是否把每一行的多个匹配结果都加入
j：表示是否搜索完后定位到第一个匹配位置
vimgrep /pattern/ %           在当前打开文件中查找
vimgrep /pattern/ *           在当前目录下查找所有
vimgrep /pattern/ **          在当前目录及子目录下查找所有
vimgrep /pattern/ *.c         查找当前目录下所有.c文件
vimgrep /pattern/ **/*        只查找子目录
:cn                            查找下一个
:cp                            查找上一个
:copen                         打开quickfix
:cw                            打开quickfix
:cclose                        关闭qucikfix
```

#### 执行shell命令

-	**`:!{command}`** 执行一次shell命令
-	**`:!ls`** 列出当前目录下文件
-	**`:ls`** 显示缓冲区列表
-	**`%`** 在:!命令行中表示当前文件名
-	**`:shell`** 将vim挂起，回到一个交互的bash shell中(通过$jobs 查看当前挂起的命令)
-	**`:suspend`或`Ctrl - Z`**挂起vim，回到shell，按fg可以返回vim。
-	**`:read !{cmd}`** 将cmd执行结果从定向到vim中
-	**`:write !{cmd}`** 同理，将文件内容写入指定cmd的标准输出

#### 退出命令

-	**`:wq`** 保存并退出
-	**`:q!`** 强制退出并忽略所有更改
-	**`:e!`** 放弃所有修改，并打开原来文件。

#### 参数命令

-	**`:args`** ==:ls 显示vim缓冲内容
-	**`:q!`** 强制退出并忽略所有更改
-	**`:e!`** 放弃所有修改，并打开原来文件。

#### 窗口命令

-	**`:split`或`new`** 打开一个新窗口，光标停在顶层的窗口上
-	**`:split file`或`:new file`** 用新窗口打开文件
-	**`:close`** 最后一个窗口不能使用此命令，可以防止意外退出vim。
-	**`:q`** 如果是最后一个被关闭的窗口，那么将退出vim。
-	**`:only`** 关闭所有窗口，只保留当前窗口
-	**`Ctrl+w+r`** 相左或向下交互窗口
-	**`Ctrl+w+R`** 同上，反方向
-	**`Ctrl+w+x`** 交互同列或同行的窗口位置
-	**`Ctrl+w+h`** 向左移动窗口
-	**`Ctrl+w+j`** 向下移动窗口
-	**`Ctrl+w+k`** 向上移动窗口
-	**`Ctrl+w+l`** 向右移动窗口
-	**`Ctrl+w+=`** 让所有窗口同尺寸
-	**`Ctrl+w+i`** 让当前窗口宽度最大
-	**`Ctrl+w+q`** 离开当前窗口
-	**`Ctrl+w+c`** 关闭当前窗口
-	**`Ctrl+w+o`** 关闭当前窗口之外的所有窗口

#### 帮助命令

-	**`:help or F1`** 显示整个帮助
-	**`:help xxx`** 显示xxx的帮助，比如 `:help i`, `:help CTRL-[`（即Ctrl+[的帮助）。
-	**`:help 'number'`** Vim选项的帮助用单引号括起
-	**`:help <Esc>`** 特殊键的帮助用&lt;&gt;扩起
-	**`:help -t`** Vim启动参数的帮助用
-	**`:help i_<Esc>`** 插入模式下Esc的帮助，某个模式下的帮助用模式主题的模式
-	帮助文件中位于||之间的内容是超链接，可以用**Ctrl+]**进入链接，**Ctrl+o**或者**Ctrl+t**返回

### 寄存器

-	**`""`**

-	**`"0`**

-	**`"a-"z`**

-	**`"_`**

-	**`"+(<C-r>+)`**

-	**`"*`**

-	**`".`**

-	**`":`**

-	**`"/`**

-	**`"%`**

-	**`p{char}xxxp`**

-	**`@{char}`**

-	**`@@`**

