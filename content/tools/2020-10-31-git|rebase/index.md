+++
title="git|rebase"
tags=["git","rebase"]
categories=["git"]
date="2020-10-31T03:04:00+08:00"
summary = 'git rebase的简介以及使用方法'
toc=false
+++

rebase，字面意思就是从新奠定基础，能够将分叉的分支重新接入合并，形成同一路径，而不是新开链路，如图所示

```c
          A---B---C topic
         /
    D---E---F---G master
```

执行`git rebase master`命令后

```c
                  A'--B'--C' topic
                 /
    D---E---F---G master
```

注意如果目标分支已经包含了相同节点，则会自动通过，如图所示，`A`和`A'`是同一提交节点

```c
          A---B---C topic
         /
    D---E---A'---F master
```

执行`git rebase master`命令后

```c
                   B'---C' topic
                  /
    D---E---A'---F master
```

### 使用方法

- 在当前分支上执行 `git rebase xxx` 命令，目的是将当前分支接入 `xxx` 分支上。或者执行 `git rebase -i $commit_id` 命令，将当前分支接入 `$commit_id` 节点。

- 如果有冲突，会中断流程，提示解决冲突，没有冲突则进入commit选择页面

- 解决冲突后，执行 `git rebase --continue` ，继续合并，没有冲突后，进入commit选择页面

- 分支选择页面提交后，即合并成功

- 如果不想合并了，则执行 `git rebase --abort` ，中断流程


### 与git merge区别

1. git merge 合并分支后，与目标分支产生一个合并commit节点
2. git rebase 合并后，会嫁接在目标分支后之后


## 参考

1. [官方git rebase文档](https://git-scm.com/docs/git-rebase)