+++
title="Golang|go-snowflake"
date="2020-07-11T03:06:00+08:00"
toc=false
+++

[go-snowflake](https://github.com/GUAIK-ORG/go-snowflake)
=========================================================

在单机系统中我们会使用自增id作为数据的唯一id，自增id在数据库中有利于排序和索引，但是在分布式系统中如果还是利用数据库的自增id会引起冲突，自增id非常容易被爬虫爬取数据。在分布式系统中有使用uuid作为数据唯一id的，但是uuid是一串随机字符串，所以它无法被排序。

Twitter设计了`Snowflake算法`为分布式系统生成ID,Snowflake的id是int64类型，它通过datacenterId和workerId来标识分布式系统，下面看下它的组成：

| 符号位（保留字段） | 时间戳(当前时间-纪元时间) | 数据中心id | 机器id | 自增序列 |
|:------------------:|:-------------------------:|:----------:|:------:|:--------:|
|        1bit        |           41bit           |    5bit    |  5bit  |  12bit   |

算法简介
========

在使用Snowflake生成id时关键点:

-	计算时间戳`timestamp（当前时间 - 纪元时间）`，如果timestamp数据超过41bit则异常
-	判断datacenterId和workerId不能超过5bit(0-31)
-	处理自增序列时，如果发现自增序列超过12bit时需要等待，因为当前毫秒下12bit的自增序列被用尽，需要进入下一毫秒后自增序列继续从0开始递增

核心代码
========

```go
package snowflake

import (
	"fmt"
	"sync"
	"time"

	"github.com/golang/glog"
)

const (
	epoch             = int64(1577808000000)                           // 设置起始时间(时间戳/毫秒)：2020-01-01 00:00:00，有效期69年
	timestampBits     = uint(41)                                       // 时间戳占用位数
	datacenteridBits  = uint(5)                                        // 数据中心id所占位数
	workeridBits      = uint(5)                                        // 机器id所占位数
	sequenceBits      = uint(12)                                       // 序列所占的位数
	timestampMax      = int64(-1 ^ (-1 << timestampBits))              // 时间戳最大值    -1的二进制表示是64位全是1
	datacenteridMax   = int64(-1 ^ (-1 << datacenteridBits))           // 支持的最大数据中心id数量
	workeridMax       = int64(-1 ^ (-1 << workeridBits))               // 支持的最大机器id数量
	sequenceMask      = int64(-1 ^ (-1 << sequenceBits))               // 支持的最大序列id数量
	workeridShift     = sequenceBits                                   // 机器id左移位数
	datacenteridShift = sequenceBits + workeridBits                    // 数据中心id左移位数
	timestampShift    = sequenceBits + workeridBits + datacenteridBits // 时间戳左移位数
)

type Snowflake struct {
	sync.Mutex   //加锁，防止并发碰撞
	timestamp    int64
	workerid     int64
	datacenterid int64
	sequence     int64
}

func NewSnowflake(datacenterid, workerid int64) (*Snowflake, error) {
	if datacenterid < 0 || datacenterid > datacenteridMax {
		return nil, fmt.Errorf("datacenterid must be between 0 and %d", datacenteridMax-1)
	}
	if workerid < 0 || workerid > workeridMax {
		return nil, fmt.Errorf("workerid must be between 0 and %d", workeridMax-1)
	}
	return &Snowflake{
		timestamp:    0,
		datacenterid: datacenterid,
		workerid:     workerid,
		sequence:     0,
	}, nil
}

func (s *Snowflake) NextVal() int64 {
	s.Lock()
	now := time.Now().UnixNano() / 1000000 // 转毫秒
	if s.timestamp == now {
		// 当同一时间戳（精度：毫秒）下多次生成id会增加序列号
		s.sequence = (s.sequence + 1) & sequenceMask
		if s.sequence == 0 {
			// 如果当前序列超出12bit长度，则需要等待下一毫秒
			// 下一毫秒将使用sequence:0
			for now <= s.timestamp {
				now = time.Now().UnixNano() / 1000000
			}
		}
	} else {
		// 不同时间戳（精度：毫秒）下直接使用序列号：0
		s.sequence = 0
	}
	t := now - epoch
	if t > timestampMax {
		s.Unlock()
		glog.Errorf("epoch must be between 0 and %d", timestampMax-1)
		return 0
	}
	s.timestamp = now
	r := int64((t)<<timestampShift | (s.datacenterid << datacenteridShift) | (s.workerid << workeridShift) | (s.sequence))
	s.Unlock()
	return r
}

// 获取数据中心ID和机器ID
func GetDeviceID(sid int64) (datacenterid, workerid int64) {
	datacenterid = (sid >> datacenteridShift) & datacenteridMax
	workerid = (sid >> workeridShift) & workeridMax
	return
}

// 获取时间戳
func GetTimestamp(sid int64) (timestamp int64) {
	timestamp = (sid >> timestampShift) & timestampMax
	return
}

// 获取创建ID时的时间戳
func GetGenTimestamp(sid int64) (timestamp int64) {
	timestamp = GetTimestamp(sid) + epoch
	return
}

// 获取创建ID时的时间字符串(精度：秒)
func GetGenTime(sid int64) (t string) {
	// 需将GetGenTimestamp获取的时间戳/1000转换成秒
	t = time.Unix(GetGenTimestamp(sid)/1000, 0).Format("2006-01-02 15:04:05")
	return
}

// 获取时间戳已使用的占比：范围（0.0 - 1.0）
func GetTimestampStatus() (state float64) {
	state = float64((time.Now().UnixNano()/1000000 - epoch)) / float64(timestampMax)
	return
}
```

参考
====

-	[go-snowflake](https://github.com/GUAIK-ORG/go-snowflake)
-	[原码、反码、补码](https://www.cnblogs.com/zhangziqiu/archive/2011/03/30/ComputerCode.html)

