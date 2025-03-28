+++
title="mq|Kafka速度分析"
date="2020-04-17T11:52:00+08:00"
categories=["MQ"]
toc=false
+++


Kafka的消息是保存或缓存在磁盘上的，一般认为在磁盘上读写数据是会降低性能的，因为寻址会比较消耗时间，但是实际上，Kafka的特性之一就是高吞吐率。

即使是普通的服务器，Kafka也可以轻松支持每秒百万级的写入请求，超过了大部分的消息中间件，这种特性也使得Kafka在日志处理等海量数据场景广泛应用。

> 为什么写入速度快？

Kafka会把收到的消息都写入到硬盘中，它绝对不会丢失数据。为了优化写入速度Kafka采用了两个技术， 顺序写入和MMFile

#### 顺序写入

磁盘读写的快慢取决于你怎么使用它，也就是顺序读写或者随机读写。在顺序读写的情况下，磁盘的顺序读写速度和内存持平。

#### mmap

即便是顺序写入硬盘，硬盘的访问速度还是不可能追上内存。所以Kafka的数据并不是实时的写入硬盘 ，它充分利用了现代操作系统分页存储来利用内存提高I/O效率。

Memory Mapped Files(简称mmap)也译成 **内存映射文件** ，在64位操作系统中一般可以表示20G的数据文件，它的工作原理是直接利用操作系统的Page来实现文件到物理内存的直接映射。完成映射之后你对物理内存的操作会被操作系统在适当的时候同步到硬盘。

通过mmap，进程像读写硬盘一样读写内存(虚拟机内存)，也不必关心内存的大小，有虚拟内存兜底。使用这种方式可以获取很大的I/O提升，省去了用户空间到内核空间复制的开销，调用文件的read会把数据先放到内核空间的内存中，然后再复制到用户空间的内存中。

但也有一个很明显的缺陷——不可靠，写到mmap中的数据并没有被真正的写到硬盘，操作系统会在程序主动调用flush的时候才把数据真正的写到硬盘。

> 读取速度有什么优化？

#### 基于sendfile实现Zero Copy

传统模式下，当需要对一个文件进行传输的时候，其具体流程细节如下：

1.	调用read函数，文件数据被copy到内核缓冲区
2.	read函数返回，文件数据从内核缓冲区copy到用户缓冲区
3.	write函数调用，将文件数据从用户缓冲区copy到内核与socket相关的缓冲区
4.	数据从socket缓冲区copy到相关协议引擎

以上细节是传统read/write方式进行网络文件传输的方式，我们可以看到，在这个过程当中，文件数据实际上是经过了四次copy操作：

**硬盘—>内核buf—>用户buf—>socket相关缓冲区—>协议引擎**

而sendfile系统调用则提供了一种减少以上多次copy，提升文件传输性能的方法。

在内核版本2.1中，引入了sendfile系统调用，以简化网络上和两个本地文件之间的数据传输。sendfile的引入不仅减少了数据复制，还减少了上下文切换。

```c
sendfile(socket, file, len);
```

运行流程如下：

1.	sendfile系统调用，文件数据被copy至内核缓冲区
2.	再从内核缓冲区copy至内核中socket相关的缓冲区
3.	最后再socket相关的缓冲区copy到协议引擎

相较传统read/write方式，2.1版本内核引进的sendfile已经减少了内核缓冲区到user缓冲区，再由user缓冲区到socket相关缓冲区的文件copy，而在内核版本2.4之后，文件描述符结果被改变，sendfile实现了更简单的方式，再次减少了一次copy操作。

Kafka把所有的消息都存放在一个一个的文件中，当消费者需要数据的时候Kafka直接把文件发送给消费者，配合mmap作为文件读写方式，直接把它传给sendfile。

#### 批量压缩

如果每个消息都压缩，但是压缩率相对很低，所以Kafka使用了批量压缩，即将多个消息一起压缩而不是单个消息压缩

## 总结

Kafka速度的秘诀在于，它把所有的消息都变成一个批量的文件，并且进行合理的批量压缩，减少网络IO损耗，通过mmap提高I/O速度，写入数据的时候由于单个Partion是末尾添加所以速度最优；读取数据的时候配合sendfile直接暴力输出。

## 参考

1.	[Kafka凭什么速度那么快](https://zhuanlan.zhihu.com/p/66482461)

