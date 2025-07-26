+++
title="spark|参数配置"
date="2025-07-20T10:45:00+08:00"
categories=["spark"]
toc=true
+++

Spark提供三个位置用来配置系统：

- Spark属性：控制大部分的应用程序参数，可以用SparkConf对象或者Java系统属性设置
- 环境变量：可以通过每个节点的conf/spark-env.sh脚本设置。例如IP地址、端口等信息
- 日志配置：可以通过log4j.properties配置

Spark属性控制大部分的应用程序设置，并且为每个应用程序分别配置它。
这些属性可以直接在SparkConf上配置，然后传递给SparkContext。
SparkConf允许你配置一些通用的属性（如master URL、应用程序名称等等）以及通过set()方法设置的任意键值对。

通常我们会在spark-submit脚本中配置Spark属性，或者在SparkConf对象中配置。按照最近工作常写的一些spark任务，总结一下常用的参数配置。

## 配置参数

- spark.driver.cores：驱动程序的CPU核心数
- spark.driver.memory：驱动程序的内存大小
- spark.executor.cores：每个执行器的CPU核心数
- spark.executor.memory：每个执行器的内存大小
- spark.executor.instances：执行器的数量
- spark.default.parallelism：默认的并行度
- spark.default.shuffle.parallelism：默认的 shuffle 并行度
- spark.executor.memoryOverhead：每个执行器的内存 overhead 大小
- spark.executor.extraJavaOptions：每个执行器的额外Java选项，配置每个执行器的JVM参数
- spark.dynamicAllocation.enabled：是否开启动态资源分配
- spark.dynamicAllocation.minExecutors：动态资源分配的最小执行器数量
- spark.dynamicAllocation.maxExecutors：动态资源分配的最大执行器数量
- spark.dynamicAllocation.initialExecutors：动态资源分配的初始执行器数量
- spark.files.maxPartitionBytes：每个文件的最大分区字节数
- spark.files.minPartitionBytes：每个文件的最小分区字节数
- spark.files.ignoreMissingFiles：忽略缺失的文件
- spark.files.openCostInBytes：打开文件的成本字节数
- spark.memory.fraction：Apache Spark 中用于配置内存分配的关键参数，它定义了堆内存（扣除 300MB 预留空间后）中可用于执行（如计算任务）和存储（如缓存数据）的内存占比。其默认值通常为 0.6，意味着 60% 的可用堆内存会分配给执行和存储，剩余部分则用于内部元数据、用户数据结构等。该值若调得过高，可能导致预留内存不足，引发 OOM（内存溢出）；若过低，则会增加任务溢出到磁盘的频率，影响性能。
- spark.memory.storageFraction：Spark 中用于划分执行与存储内存的参数，它表示在 spark.memory.fraction 所分配的内存区域中，固定保留给存储（如缓存数据）且不被执行任务抢占的比例，默认值为 0.5。


## 配置经验

**处理超大数据集任务**

- 通过调整 spark.files.maxPartitionBytes 来控制每个文件的分区大小，确定合适的分区数量，配合 spark.default.parallelism 一起使用。

**处理多小文件数据集**

- 通过调整 spark.files.minPartitionBytes 来控制每个文件的分区大小，确定合适的分区数量
- 通过spark.files.openCostInBytes来控制每个文件的打开成本字节数，确定合适的分区数量
- 可以使用 coalesce 方法减少分区数量，提高并行度。

**处理数据慢**

- 提高spark.executor.cores和spark.executor.instances，增加资源处理能力

**处理oom**

- 提高spark.executor.memory 增加worker的内存配置，注意提高后还是oom需要考虑数据倾斜，有异常数据的case


## 参考
- [spark官网参数配置](https://spark.apache.org/docs/latest/configuration.html)
- [spark参数配置](https://blog.csdn.net/Camu7s/article/details/50586763)
