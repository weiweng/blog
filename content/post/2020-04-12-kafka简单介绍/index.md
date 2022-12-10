+++
title="kafka简单介绍"
tags=["kafka","mq"]
categories=["mq"]
date="2020-04-12T07:42:00+08:00"
summary = 'kafka简单介绍'
toc=false
+++

kafka
=====

Kafka是最初由Linkedin公司开发，是一个分布式、支持分区的、多副本的，基于zookeeper协调的分布式消息系统，它的最大的特性就是可以实时的处理大量数据以满足各种需求场景：比如基于hadoop的批处理系统、低延迟的实时系统、storm/Spark流式处理引擎，web/nginx日志、访问日志，消息服务等等，用scala语言编写，Linkedin于2010年贡献给了Apache基金会并成为顶级开源项目。

特性
----

1.	高吞吐量、低延迟：kafka每秒可以处理几十万条消息，它的延迟最低只有几毫秒，每个topic可以分多个partition, consumer group 对partition进行consume操作。
2.	可扩展性：kafka集群支持热扩展
3.	持久性、可靠性：消息被持久化到本地磁盘，并且支持数据备份防止数据丢失
4.	容错性：允许集群中节点失败（若副本数量为n,则允许n-1个节点失败）
5.	高并发：支持数千个客户端同时读写

特点
----

1.	应用解耦
2.	流量削峰
3.	异步处理

使用场景
--------

1.	日志收集：一个公司可以用Kafka可以收集各种服务的log，通过kafka以统一接口服务的方式开放给各种consumer，例如hadoop、Hbase、Solr等。
2.	消息系统：解耦和生产者和消费者、缓存消息等。
3.	用户活动跟踪：Kafka经常被用来记录web用户或者app用户的各种活动，如浏览网页、搜索、点击等活动，这些活动信息被各个服务器发布到kafka的topic中，然后订阅者通过订阅这些topic来做实时的监控分析，或者装载到hadoop、数据仓库中做离线分析和挖掘。
4.	运营指标：Kafka也经常用来记录运营监控数据。包括收集各种分布式应用的数据，生产各种操作的集中反馈，比如报警和报告。
5.	流式处理：比如spark streaming和storm
6.	事件源

基本名词
--------

-	Broker：Kafka节点，一个Kafka节点就是一个broker，多个broker可以组成一个Kafka集群。
-	Topic：一类消息，消息存放的目录即主题，例如page view日志、click日志等都可以以topic的形式存在，Kafka集群能够同时负责多个topic的分发。
-	Partition：topic物理上的分组，一个topic可以分为多个partition，每个partition是一个有序的队列
-	Segment：partition物理上由多个segment组成，每个Segment存着message信息
-	Producer : 生产message发送到topic
-	Consumer : 订阅topic消费message, consumer作为一个线程来消费
-	Consumer Group：一个Consumer Group包含多个consumer, 这个是预先在配置文件中配置好的。

生产
====

Partition leader与follower
--------------------------

partition也有leader和follower之分。

leader是主partition，producer写kafka的时候先写partition leader，再由partition leader push给其他的partition follower。

partition leader与follower的信息受Zookeeper控制，一旦partition leader所在的broker节点宕机，zookeeper会冲其他的broker的partition follower上选择follower变为parition leader。

### Kakfa Broker Leader的选举

Kakfa Broker集群受Zookeeper管理。所有的Kafka Broker节点一起去Zookeeper上注册一个临时节点，因为只有一个Kafka Broker会注册成功，其他的都会失败，所以这个成功在Zookeeper上注册临时节点的这个Kafka Broker会成为Kafka Broker Controller，其他的Kafka broker叫Kafka Broker follower。

这个Controller会监听其他的Kafka Broker的所有信息，如果这个kafka broker controller宕机了，在zookeeper上面的那个临时节点就会消失，此时所有的kafka broker又会一起去Zookeeper上注册一个临时节点，因为只有一个Kafka Broker会注册成功，其他的都会失败，所以这个成功在Zookeeper上注册临时节点的这个Kafka Broker会成为Kafka Broker Controller，其他的Kafka broker叫Kafka Broker follower。

一旦有一个broker宕机了后的处理流程

1.	这个kafka broker controller会读取该宕机broker上所有的partition在zookeeper上的状态，并选取ISR(in-sync replica已同步的副本)列表中的一个replica作为partition leader。
2.	如果ISR列表中的replica全挂，选一个幸存的replica作为leader;
3.	如果该partition的所有的replica都宕机了，则将新的leader设置为-1，等待恢复，等待ISR中的任一个Replica“活”过来，并且选它作为Leader；
4.	或选择第一个“活”过来的Replica（不一定是ISR中的）作为Leader
5.	这个broker宕机的事情，kafka controller也会通知zookeeper，zookeeper就会通知其他的kafka broker。

Topic & Partition
-----------------

Topic相当于传统消息系统MQ中的一个队列queue，producer端发送的message必须指定是发送到哪个topic，但是不需要指定topic下的哪个partition，因为kafka会把收到的message进行load balance，均匀的分布在这个topic下的不同的partition上(hash(message) % (broker数量))。

物理上存储上，这个topic会分成一个或多个partition，每个partiton相当于是一个子queue。

在物理结构上，每个partition对应一个物理的目录（文件夹），文件夹命名是topicname/partition/序号，一个topic可以有无数多的partition，根据业务需求和数据量来设置。

在kafka配置文件中可随时更高num.partitions参数来配置更改topic的partition数量，在创建Topic时通过参数指定parittion数量。Topic创建之后通过Kafka提供的工具也可以修改partiton数量。

一般来说，一个Topic的Partition数量大于等于Broker的数量，可以提高吞吐率。同一个Partition的Replica尽量分散到不同的机器，高可用。

当add a new partition的时候，partition里面的message不会重新进行分配，原来的partition里面的message数据不会变，新加的这个partition刚开始是空的，随后进入这个topic的message就会重新参与所有partition的load balance

### Partition ack

1.	当ack=1，表示producer写partition leader成功后，broker就返回成功，无论其他的partition follower是否写成功。所以一旦有个broker宕机导致partition的follower和leader切换，会导致丢数据。
2.	当ack=2，表示producer写partition leader和其他一个follower成功的时候，broker就返回成功，无论其他的partition follower是否写成功。
3.	当ack=-1，表示只有producer全部写成功的时候，才算成功，kafka broker才返回成功信息。

### 消息投递可靠性

一个消息如何算投递成功，Kafka提供了三种模式：

1.	第一种是啥都不管，发送出去就当作成功，这种情况当然不能保证消息成功投递到broker；
2.	第二种是Master-Slave模型，只有当Master和所有Slave都接收到消息时，才算投递成功，这种模型提供了最高的投递可靠性，但是损伤了性能；
3.	第三种模型，只要Master确认收到消息就算投递成功；实际使用时，根据应用特性选择，绝大多数情况下都会中和可靠性和性能选择第三种模型

消息在broker上的可靠性，因为消息会持久化到磁盘上，所以如果正常stop一个broker，其上的数据不会丢失；但是如果不正常stop，可能会使存在页面缓存来不及写入磁盘的消息丢失，这可以通过配置flush页面缓存的周期、阈值缓解，但是同样会频繁的写磁盘会影响性能，又是一个选择题，根据实际情况配置。

### 生产幂等性

思路是这样的，为每个producer分配一个pid，作为该producer的唯一标识。producer会为每一个`<topic,partition>`维护一个单调递增的seq。类似的，broker也会为每个`<pid,topic,partition>`记录下最新的seq。当`req_seq == broker_seq+1`时，broker才会接受该消息。因为：

1.	消息的seq比broker的seq大，说明中间有数据还没写入，即乱序了。
2.	消息的seq不比broker的seq小，那么说明该消息已被保存。

Partition Replica
-----------------

每个partition可以在其他的kafka broker节点上存副本，以便某个kafka broker节点宕机不会影响这个kafka集群。

存replica副本的方式是按照kafka broker的顺序存。例如有5个kafka broker节点，某个topic有3个partition，每个partition存2个副本，那么partition1存broker1,broker2，partition2存broker2,broker3。。。以此类推（replica副本数目不能大于kafka broker节点的数目，否则报错。这里的replica数其实就是partition的副本总数，其中包括一个leader，其他的就是copy副本）。

这样如果某个broker宕机，其实整个kafka内数据依然是完整的。但是，replica副本数越高，系统虽然越稳定，但是回来带资源和性能上的下降；replica副本少的话，也会造成系统丢数据的风险。

### 怎样处理某个Replica不工作的情况

如果这个部工作的partition replica不在ack列表中，就是producer在发送消息到partition leader上，partition leader向partition follower发送message没有响应而已，这个不会影响整个系统，也不会有什么问题。如果这个不工作的partition replica在ack列表中的话，producer发送的message的时候会等待这个不工作的partition replca写message成功，但是会等到time out，然后返回失败因为某个ack列表中的partition replica没有响应，此时kafka会自动的把这个部工作的partition replica从ack列表中移除，以后的producer发送message的时候就不会有这个ack列表下的这个部工作的partition replica了。

### 怎样处理Failed Replica恢复回来的情况

如果这个partition replica之前不在ack列表中，那么启动后重新受Zookeeper管理即可，之后producer发送message的时候，partition leader会继续发送message到这个partition follower上。如果这个partition replica之前在ack列表中，此时重启后，需要把这个partition replica再手动加到ack列表中。ack列表是手动添加的，出现某个不工作的partition replica的时候自动从ack列表中移除的。

消费
====

ConsumerGroup
-------------

各个consumer线程可以组成一个组ConsumerGroup，partition中的每个message只能被ConsumerGroup中的一个consumer线程消费，如果一个message可以被多个consumer线程消费的话，那么这些consumer必须在不同的组。

Kafka不支持一个partition中的message由两个或两个以上的同一个consumer group下的consumer thread来处理，除非再启动一个新的consumer group。所以如果想同时对一个topic做消费的话，启动多个consumer group就可以了，但是要注意的是，这里的多个consumer的消费都必须是顺序读取partition里面的message，新启动的consumer默认从partition队列最头端最新的地方开始阻塞的读message。

它不能像AMQ那样可以多个BET作为consumer去互斥的（for update悲观锁）并发处理message，这是因为多个BET去消费一个Queue中的数据的时候，由于要保证不能多个线程拿同一条message，所以就需要行级别悲观锁（for update）,这就导致了consume的性能下降，吞吐量不够。而kafka为了保证吞吐量，只允许同一个consumer group下的一个consumer线程去访问一个partition。如果觉得效率不高的时候，可以加partition的数量来横向扩展，那么再加新的consumer thread去消费。如果想多个不同的业务都需要这个topic的数据，起多个consumer group就好了，大家都是顺序的读取message，offsite的值互不影响。这样没有锁竞争，充分发挥了横向的扩展性，吞吐量极高。这也就形成了分布式消费的概念。

当启动一个consumer group去消费一个topic的时候，无论topic里面有多个少个partition，无论我们consumer group里面配置了多少个consumer thread，这个consumer group下面的所有consumer thread一定会消费全部的partition；即便这个consumer group下只有一个consumer thread，那么这个consumer thread也会去消费所有的partition。因此，最优的设计就是，consumer group下的consumer thread的数量等于partition数量，这样效率是最高的。

一个consumer group下，无论有多少个consumer，这个consumer group一定回去把这个topic下所有的partition都消费了。

1.	当consumer group里面的consumer数量小于这个topic下的partition数量的时候，就会出现一个conusmer thread消费多个partition的情况。
2.	如果consumer group里面的consumer数量等于这个topic下的partition数量的时候，此时效率是最高的，每个partition都有一个consumer thread去消费。
3.	当consumer group里面的consumer数量大于这个topic下的partition数量的时候，就会有consumer thread空闲。

因此，我们在设定consumer group的时候，只需要指明里面有几个consumer数量即可，无需指定对应的消费partition序号，consumer会自动进行rebalance。

### Consumer Rebalance的触发条件：

1.	Consumer增加或删除会触发Rebalance
2.	Broker的增加或者减少都会触发Rebalance

消息传输一致
------------

Kafka提供3种消息传输一致性语义：最多1次，最少1次，恰好1次。

1.	最少1次：可能会重传数据，有可能出现数据被重复处理的情况;
2.	最多1次：可能会出现数据丢失情况;
3.	恰好1次：并不是指真正只传输1次，只不过有一个机制。确保不会出现“数据被重复处理”和“数据丢失”的情况。

at most once: 消费者fetch消息,然后保存offset,然后处理消息;当client保存offset之后,但是在消息处理过程中consumer进程失效(crash),导致部分消息未能继续处理.那么此后可能其他consumer会接管,但是因为offset已经提前保存,那么新的consumer将不能fetch到offset之前的消息(尽管它们尚没有被处理),这就是"at most once".

at least once: 消费者fetch消息,然后处理消息,然后保存offset.如果消息处理成功之后,但是在保存offset阶段zookeeper异常或者consumer失效,导致保存offset操作未能执行成功,这就导致接下来再次fetch时可能获得上次已经处理过的消息,这就是"at least once".

"Kafka Cluster"到消费者的场景中可以采取以下方案来得到“恰好1次”的一致性语义：最少1次＋消费者的输出中额外增加已处理消息最大编号：由于已处理消息最大编号的存在，不会出现重复处理消息的情况。

原理
====

持久化
------

kafka使用文件存储消息(append only log),这就直接决定kafka在性能上严重依赖文件系统的本身特性.且无论任何OS下,对文件系统本身的优化是非常艰难的.文件缓存/直接内存映射等是常用的手段.因为kafka是对日志文件进行append操作,因此磁盘检索的开支是较小的;同时为了减少磁盘写入的次数,broker会将消息暂时buffer起来,当消息的个数(或尺寸)达到一定阀值时,再flush到磁盘,这样减少了磁盘IO调用的次数.对于kafka而言,较高性能的磁盘,将会带来更加直接的性能提升.

性能
----

除磁盘IO之外,我们还需要考虑网络IO,这直接关系到kafka的吞吐量问题.kafka并没有提供太多高超的技巧;对于producer端,可以将消息buffer起来,当消息的条数达到一定阀值时,批量发送给broker;对于consumer端也是一样,批量fetch多条消息.不过消息量的大小可以通过配置文件来指定.对于kafka broker端,似乎有个sendfile系统调用可以潜在的提升网络IO的性能:将文件的数据映射到系统内存中,socket直接读取相应的内存区域即可,而无需进程再次copy和交换(这里涉及到"磁盘IO数据"/"内核内存"/"进程内存"/"网络缓冲区",多者之间的数据copy).

其实对于producer/consumer/broker三者而言,CPU的开支应该都不大,因此启用消息压缩机制是一个良好的策略;压缩需要消耗少量的CPU资源,不过对于kafka而言,网络IO更应该需要考虑.可以将任何在网络上传输的消息都经过压缩.kafka支持gzip/snappy等多种压缩方式.

负载均衡
--------

kafka集群中的任何一个broker,都可以向producer提供metadata信息,这些metadata中包含"集群中存活的servers列表"/"partitions leader列表"等信息(请参看zookeeper中的节点信息). 当producer获取到metadata信息之后, producer将会和Topic下所有partition leader保持socket连接;消息由producer直接通过socket发送到broker,中间不会经过任何"路由层".

异步发送，将多条消息暂且在客户端buffer起来,并将他们批量发送到broker;小数据IO太多,会拖慢整体的网络延迟,批量延迟发送事实上提升了网络效率;不过这也有一定的隐患,比如当producer失效时,那些尚未发送的消息将会丢失。

参考
====

1.	[Kafka史上最详细原理总结上](https://www.jianshu.com/p/734cf729d77b)
2.	[Kafka史上最详细原理总结下](https://www.jianshu.com/p/acf010e67a19)
3.	[震惊了！原来这才是kafka！](https://www.jianshu.com/p/d3e963ff8b70)

