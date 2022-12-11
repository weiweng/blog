+++
title="滑动窗口"
tags=["算法","滑动窗口"]
categories=["算法"]
date="2020-07-04T02:40:00+08:00"
summary = '滑动窗口'
toc=false
+++

框架
====

```c
int left = 0, right = 0;

while (right < s.size()) {`
    // 增大窗口
    window.add(s[right]);
    right++;

    while (window needs shrink) {
        // 缩小窗口
        window.remove(s[left]);
        left++;
    }
}
```

参考
====

1.	[滑动窗口](https://labuladong.gitbook.io/algo/suan-fa-si-wei-xi-lie/hua-dong-chuang-kou-ji-qiao-jin-jie)

