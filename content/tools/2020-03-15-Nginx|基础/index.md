+++
title="Nginx|基础"
tags=["nginx"]
date="2020-03-15T06:14:00+08:00"
summary = 'Nginx|基础'
toc=false
+++

NGINX
-----

Nginx（发音同“engine X”）是异步框架的网页服务器，也可以用作反向代理、负载平衡器和HTTP缓存。

概念
----

### 正向代理

客户端主动使用代理服务器连接目标服务器

### 反向代理

客户端无感知，目标服务器使用代理，将请求分发，提高服务的并发性能

### 三板斧

1.	反向代理
2.	负载均衡
3.	动静分离

配置
----

### 配置结构

1.	全局配置块:配置影响nginx全局的指令。一般有运行nginx服务器的用户组，nginx进程pid存放路径，日志存放路径，配置文件引入，允许生成worker process数等
2.	event配置块:配置影响nginx服务器或与用户的网络连接。有每个进程的最大连接数，选取哪种事件驱动模型处理连接请求，是否允许同时接受多个网路连接，开启多个网络连接序列化等
3.	http配置块:可以嵌套多个server，配置代理，缓存，日志定义等绝大多数功能和第三方模块的配置
4.	server配置块:配置虚拟主机的相关参数，一个http中可以有多个server
5.	location配置块:配置请求的路由，以及各种页面的处理情况

	```shell
	...              #全局块

	events {         #events块
	...
	}

	http      #http块
	{
	...   #http全局块
	server        #server块
	{
	    ...       #server全局块
	    location [PATTERN]   #location块
	    {
	        ...
	    }
	    location [PATTERN]
	    {
	        ...
	    }
	}
	server
	{
	  ...
	}
	...     #http全局块
	}
	```

### location

#### 配置语法

1.	`location [ = | ~ | ~* | ^~ ] uri { ... }`
2.	`location @name { ... }`

#### 配置注意

1.	location 是在 server 块中配置。
2.	可以根据不同的 URI 使用不同的配置（location 中配置），来处理不同的请求。
3.	location 是有顺序的，会被第一个匹配的location 处理。

#### 配置demo

1.	**=**:精确匹配

	```shell
	    location = / {
	        #规则
	    }
	    # 则匹配到 `http://www.example.com/` 这种请求。
	```

2.	**~**:大小写敏感

	```shell
	    location ~ /Example/ {
	           #规则
	    }
	    #请求示例
	    #http://www.example.com/Example/  [成功]
	    #http://www.example.com/example/  [失败]
	```

3.	**~\***:大小写忽略

	```shell
	    location ~* /Example/ {
	                #规则
	    }
	    # 则会忽略 uri 部分的大小写
	    #http://www.example.com/Example/  [成功]
	    #http://www.example.com/example/  [成功]
	```

4.	**^~**:只匹配以 uri 开头

	```shell
	    location ^~ /img/ {
	            #规则
	    }
	    #以 /img/ 开头的请求，都会匹配上
	    #http://www.example.com/img/a.jpg   [成功]
	    #http://www.example.com/img/b.mp4 [成功]
	```

5.	**@**:nginx内部跳转

	```shell
	    location /img/ {
	        error_page 404 @img_err;
	    }

	    location @img_err {
	        # 规则
	    }
	    #以 /img/ 开头的请求，如果链接的状态为 404。则会匹配到 @img_err 这条规则上。
	```

### 使用示例

1.	反向代理

	```shell
	## Start www.redis.com.cn ##
	server {
	listen 80;
	server_name  www.redis.com.cn;
	access_log  logs/redis.access.log  main;
	error_log  logs/redis.error.log;
	root   html;
	index  index.html index.htm index.php;

	## send request back to apache ##
	location / {
	    proxy_pass  http://apachephp;

	    #Proxy Settings
	    proxy_redirect     off;
	    proxy_set_header   Host             $host;
	    proxy_set_header   X-Real-IP        $remote_addr;
	    proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
	    proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
	    proxy_max_temp_file_size 0;
	    proxy_connect_timeout      90;
	    proxy_send_timeout         90;
	    proxy_read_timeout         90;
	    proxy_buffer_size          4k;
	    proxy_buffers              4 32k;
	    proxy_busy_buffers_size    64k;
	    proxy_temp_file_write_size 64k;
	}
	}
	## End www.redis.com.cn ##
	```

2.	负载均衡

	```shell
	# 把www.domain.com均衡到本机不同的端口，也可以改为均衡到不同的地址上。
	http {
	    upstream myproject {
	        server 127.0.0.1:8000 weight=3;
	        server 127.0.0.1:8001;
	        server 127.0.0.1:8002;
	        server 127.0.0.1:8003;
	    }

	    server {
	        listen 80;
	        server_name www.domain.com;
	        location / {
	            proxy_pass http://myproject;
	        }
	    }
	}
	```

3.	动静分离

	```shell
	server {
	    listen 80;
	    server_name 192.168.25.35; 
	    # 当接收到http请求时，首先host和这里的server_name进行匹配，如果匹配上，则走这个虚拟主机的location路由

	    # 静态资源则路由到这里
	    location /static/~(.*)(\.jpg|\.png|\.gif|\.jepg|\.css|\.js|\.css){
	        alias html;
	    }
	    # 其他的url则转发到 http://192.168.25.35:8080
	    location / {
	        proxy_pass http://192.168.25.35:8080;
	    }
	}
	```

参考
----

1.	[Nginx](https://zh.wikipedia.org/wiki/Nginx)
2.	[Nginx配置详解](https://www.runoob.com/w3cnote/nginx-setup-intro.html)

