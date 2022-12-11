+++
title="CURL简单使用"
tags=["linux","curl"]
categories=["linux"]
date="2020-03-14T02:36:00+08:00"
summary = 'CURL简单使用'
toc=false
+++

CURL简介
--------

在Linux中curl是一个利用URL规则在命令行下工作的文件传输工具，可以说是一款很强大的http命令行工具。它支持文件的上传和下载，是综合传输工具，但按传统，习惯称url为下载工具。它支持http,https,ftp,ftps,telnet等多种协议，常被用来抓取网页和监控Web服务器状态。

CURL使用
--------

### 基础用法

```
curl [option] [url]
# 示例
curl http://www.linux.com
```

### 常用示例

**普通下载**

```
curl -m 30 --retry 3 https://proxy.mimvp.com/ip.php
```

**Get请求**

```
curl https://proxy.mimvp.com/login?user=admin&passwd=12345678  
```

**Post请求**

```
curl -d "key1=value1&key2=value2&key3=value3" protocol://ip:port/path
```

**Post请求+传输文件**

```
curl -H "Content-Type:application/json" -X POST -d 'json data' URL
```

### 常用参数

**设置用户代理发送给服务器**

```
-A/--user-agent <string>
curl -A "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.0)" http://www.linux.com 
```

**cookie字符串或文件读取位置**

```
-b/--cookie <name=string/file>
curl -b cookiec.txt http://www.linux.com
```

**操作结束后把cookie写入到这个文件中**

```
-c/--cookie-jar <file>    
```

**断点续转**

```
-C/--continue-at <offset>
curl -C -O http://www.linux.com/dodo1.JPG
```

**把header信息写入到该文件中**

```
-D/--dump-header <file>
curl -D cookied.txt http://www.linux.com
```

**来源网址**

```
-e/--referer
curl -e "www.linux.com" http://mail.linux.com  #让服务器其以为你是从www.linux.com点击某个链接过来的
```

**连接失败时不显示http错误**

```
-f/--fail
curl -f http://www.linux.com/error
```

**把输出写到该文件**

```
-o/--output
curl -o linux.html http://www.linux.com
curl -o dodo1.jpg http:www.linux.com/dodo1.JPG
curl -o #1_#2.JPG http://www.linux.com/{hello,bb}/dodo[1-5].JPG #循环下载，不覆盖
```

**把输出写到该文件中，保留远程文件的文件名**

```
-O/--remote-name
curl -O http://www.linux.com/hello.sh
curl -O http://www.linux.com/dodo[1-5].JPG  #循环下载，这里会下载覆盖
```

**检索来自HTTP/1.1或FTP服务器字节范围**

```
-r/--range <range>
curl -r 0-100 -o dodo1_part1.JPG http://www.linux.com/dodo1.JPG
curl -r 100-200 -o dodo1_part2.JPG http://www.linux.com/dodo1.JPG
curl -r 200- -o dodo1_part3.JPG http://www.linux.com/dodo1.JPG
cat dodo1_part* > dodo1.JPG
```

**静音模式,不显示进度**

```
-s/--silent
```

**上传文件**

```
-T/--upload-file <file>
curl -T dodo1.JPG -u 用户名:密码 ftp://www.linux.com/img/
```

**设置服务器的用户和密码**

```
-u/--user <user[:password]>
```

**输出完成后格式**

```
-w/--write-out [format]
curl -o /dev/null -s -w %{http_code} www.linux.com  #测试网页返回值
```

**在给定的端口上使用HTTP代理**

```
-x/--proxy <host[:port]>
curl -x 192.168.100.100:1080 http://www.linux.com
```

**进度条显示当前的传送状态**

```
-#/--progress-bar
curl -# -O http://www.linux.com/dodo1.JPG
```

### 其他参数

```
-a/--append                        上传文件时，附加到目标文件
--anyauth                            可以使用“任何”身份验证方法
--basic                                使用HTTP基本验证
-B/--use-ascii                      使用ASCII文本传输
-d/--data <data>                  HTTP POST方式传送数据
--data-ascii <data>            以ascii的方式post数据
--data-binary <data>          以二进制的方式post数据
--negotiate                          使用HTTP身份验证
--digest                        使用数字身份验证
--disable-eprt                  禁止使用EPRT或LPRT
--disable-epsv                  禁止使用EPSV
--egd-file <file>              为随机数据(SSL)设置EGD socket路径
--tcp-nodelay                  使用TCP_NODELAY选项
-E/--cert <cert[:passwd]>      客户端证书文件和密码 (SSL)
--cert-type <type>              证书文件类型 (DER/PEM/ENG) (SSL)
--key <key>                    私钥文件名 (SSL)
--key-type <type>              私钥文件类型 (DER/PEM/ENG) (SSL)
--pass  <pass>                  私钥密码 (SSL)
--engine <eng>                  加密引擎使用 (SSL). "--engine list" for list
--cacert <file>                CA证书 (SSL)
--capath <directory>            CA目   (made using c_rehash) to verify peer against (SSL)
--ciphers <list>                SSL密码
--compressed                    要求返回是压缩的形势 (using deflate or gzip)
--connect-timeout <seconds>    设置最大请求时间
--create-dirs                  建立本地目录的目录层次结构
--crlf                          上传是把LF转变成CRLF
--ftp-create-dirs              如果远程目录不存在，创建远程目录
--ftp-method [multicwd/nocwd/singlecwd]    控制CWD的使用
--ftp-pasv                      使用 PASV/EPSV 代替端口
--ftp-skip-pasv-ip              使用PASV的时候,忽略该IP地址
--ftp-ssl                      尝试用 SSL/TLS 来进行ftp数据传输
--ftp-ssl-reqd                  要求用 SSL/TLS 来进行ftp数据传输
-F/--form <name=content>        模拟http表单提交数据
-form-string <name=string>      模拟http表单提交数据
-g/--globoff                    禁用网址序列和范围使用{}和[]
-G/--get                        以get的方式来发送数据
-h/--help                      帮助
-H/--header <line>              自定义头信息传递给服务器
--ignore-content-length        忽略的HTTP头信息的长度
-i/--include                    输出时包括protocol头信息
-I/--head                      只显示文档信息
-j/--junk-session-cookies      读取文件时忽略session cookie
--interface <interface>        使用指定网络接口/地址
--krb4 <level>                  使用指定安全级别的krb4
-k/--insecure                  允许不使用证书到SSL站点
-K/--config                    指定的配置文件读取
-l/--list-only                  列出ftp目录下的文件名称
--limit-rate <rate>            设置传输速度
--local-port<NUM>              强制使用本地端口号
-m/--max-time <seconds>        设置最大传输时间
--max-redirs <num>              设置最大读取的目录数
--max-filesize <bytes>          设置最大下载的文件总量
-M/--manual                    显示全手动
-n/--netrc                      从netrc文件中读取用户名和密码
--netrc-optional                使用 .netrc 或者 URL来覆盖-n
--ntlm                          使用 HTTP NTLM 身份验证
-N/--no-buffer                  禁用缓冲输出
-p/--proxytunnel                使用HTTP代理
--proxy-anyauth                选择任一代理身份验证方法
--proxy-basic                  在代理上使用基本身份验证
--proxy-digest                  在代理上使用数字身份验证
--proxy-ntlm                    在代理上使用ntlm身份验证
-P/--ftp-port <address>        使用端口地址，而不是使用PASV
-Q/--quote <cmd>                文件传输前，发送命令到服务器
--range-file                    读取（SSL）的随机文件
-R/--remote-time                在本地生成文件时，保留远程文件时间
--retry <num>                  传输出现问题时，重试的次数
--retry-delay <seconds>        传输出现问题时，设置重试间隔时间
--retry-max-time <seconds>      传输出现问题时，设置最大重试时间
-S/--show-error                显示错误
--socks4 <host[:port]>          用socks4代理给定主机和端口
--socks5 <host[:port]>          用socks5代理给定主机和端口
-t/--telnet-option <OPT=val>    Telnet选项设置
--trace <file>                  对指定文件进行debug
--trace-ascii <file>            Like --跟踪但没有hex输出
--trace-time                    跟踪/详细输出时，添加时间戳
--url <URL>                    Spet URL to work with
-U/--proxy-user <user[:password]>  设置代理用户名和密码
-V/--version                    显示版本信息
-X/--request <command>          指定什么命令
-y/--speed-time                放弃限速所要的时间。默认为30
-Y/--speed-limit                停止传输速度的限制，速度时间'秒
-z/--time-cond                  传送时间设置
-0/--http1.0                    使用HTTP 1.0
-1/--tlsv1                      使用TLSv1（SSL）
-2/--sslv2                      使用SSLv2的（SSL）
-3/--sslv3                      使用的SSLv3（SSL）
--3p-quote                      like -Q for the source URL for 3rd party transfer
--3p-url                        使用url，进行第三方传送
--3p-user                      使用用户名和密码，进行第三方传送
-4/--ipv4                      使用IP4
-6/--ipv6                      使用IP6
```

### 参考

1.	[Linux curl命令详解](http://www.linuxdiyf.com/linux/2800.html)

