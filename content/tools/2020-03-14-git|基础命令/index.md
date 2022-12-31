+++
title="git|基础命令"
tags=["git"]
date="2020-03-14T10:59:00+08:00"
summary = 'git|基础命令'
toc=false
+++

### git多账户管理

1.	**ssh公钥生成**

	```c
	cd ~/.ssh
	ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
	# 你在公司用git，肯定已经生成了公私钥，id_rsa/id_rsa.pub
	# 所以这里就需要重新生成了，名字不能和原来重复，可以叫id_rsa_github
	Enter file in which to save the key (/Users/weiweng/.ssh/id_rsa): id_rsa_github
	# 然后就直接两次回车吧
	# 将生成的key加入 ssh-agent
	ssh-add ~/.ssh/id_rsa_github
	# 将公钥加入到github，参考：https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/

	```

2.	**配置不同git使用不同账户**

	```c
	# 配置使用固定的公钥去访问github
	vim ~/.ssh/config
	# 加入如下配置
	Host github
	HostName github.com
	User weiweng
	IdentityFile ~/.ssh/id_rsa_github
	```

### 初始化操作

1.	git init`当前目录新建一个Git代码库`

2.	git init \[project-name\]`新建目录，将其初始化为git代码库`

3.	git clone \[url\]`克隆远程项目url到本地`

### 配置操作

1.	git config \-\-list`显示当前配置`

2.	git config -e \[\-\-global\]`编辑配置`

3.	git config \[\-\-global\] user.naem \"\[name\]\"`设置用户信息-名称`

4.	git config \[\-\-global\] user.email \"\[email\]\"`设置用户信息-邮件`

### 基本文件操作

1.	git add \[file1\] \[file2\]`添加指定文件到暂存区`

2.	git add \[ dir\]`添加指定目录到暂存区，包括子目录`

3.	git add .`添加当前目录的所有文件到暂存区,提交新文件和被修改文件,不包括被删除文件`

4.	git add -A`提交所有变化`

5.	git add -u`提交被修改被删除文件变化,但不包括新文件`

6.	git rm \[file1\] \[file2\]`删除工作区文件，并且将这次删除放入暂存区`

7.	git rm \-\-cached \[file1\]`停止追踪指定文件，但该文件会保留在工作区`

8.	git mv \[file-original\] \[file-renamed\]`改名文件，并且将这个改名放入暂存区`

### 提交命令

1.	git commit -m \[message\]`提交暂存区到仓库区`

2.	git commit \[file1\] \[file2\] ... -m \[message\]`提交暂存区的指定文件到仓库区`

3.	git commit -a`提交工作区自上次commit之后的变化，直接到仓库区`

4.	git commit -v`提交时显示所有diff信息`

5.	git commit \-\-amend -m \[message\]`使用一次新的commit，替代上一次提交``如果代码没有任何新变化，则用来改写上一次commit的提交信息`

6.	git commit \-\-amend \[file1\] \[file2\] ...`重做上一次commit，并包括指定文件的新变化`

### 远程同步操作

1.	git fetch \[remote\]`下载远程仓库的所有变动`

2.	git remote -v`显示所有远程仓库`

3.	git remote show \[remote\]`显示某个远程仓库的信息`

4.	git remote add \[shortname\] \[url\]`增加一个新的远程仓库，并命名`

5.	git pull \[remote\] \[branch\]`取回远程仓库的变化，并与本地分支合并`

6.	git push \[remote\] \[branch\]`上传本地指定分支到远程仓库`

7.	git push \[remote\] \-\-force`强行推送当前分支到远程仓库，即使有冲突`

8.	git push \[remote\] \-\-all`推送所有分支到远程仓库`

9.	git push origin HEAD \-\-force`配合git reset --hard xxxx版本号，强制推送远端分支回退版本`

### 撤销操作

1.	git checkout \-\- \[file\]`放弃单个文件的修改，注意这里的文件是未add的文件，并且不是新文件，新文件自己删除就好了`

2.	git checkout \[commit\] \[file\]`恢复某个commit的指定文件到暂存区和工作区`

3.	git checkout .`放弃所有本地修改的文件，这里文件都是未add的文件，将暂存区的所有文件恢复到工作区`

4.	git reset \[file\]`add file 的撤销，重置暂存区的指定文件，与上一次commit保持一致，但工作区不变即保存本地的相关更改`

5.	git reset \-\-hard`重置暂存区与工作区，与上一次commit保持一致`

6.	git reset \[commit\]`add file 的撤销，重置当前分支的指针为指定commit，同时重置暂存区，但工作区不变`

7.	git reset \-\-hard \[commit\]`重置当前分支的HEAD为指定commit，同时重置暂存区和工作区，与指定commit一致`

8.	git reset \-\-keep \[commit\]`重置当前HEAD为指定commit，但保持暂存区和工作区不变`

9.	git reset \-\-soft HEAD\^`git commit 的整体撤销，撤销暂存区的代码到上一次的commit，仅仅是撤回commit操作，工作区的已改动代码仍然保留`

10.	暂时将未提交的变化移除，稍后再移入

	1.	git stash
	2.	git stash pop

### 分支管理操作

1.	git branch`列出所有本地分支`

2.	git branch -r`列出所有远程分支`

3.	git branch -a`列出所有本地分支和远程分支`

4.	git branch \[branch-name\]`新建一个分支，但依然停留在当前分支`

5.	git checkout -b \[branch\]`新建一个分支，并切换到该分支`

6.	git branch \-\-track \[branch\] \[remote-branch\]`新建一个分支，与指定的远程分支建立追踪关系`

7.	git checkout \[branch-name\]`切换到指定分支，并更新工作区`

8.	git branch \-\-set-upstream-to \[branch\] \[remote-branch\]`建立追踪关系，在现有分支与指定的远程分支之间`

9.	git merge \[branch\]`合并指定分支到当前分支`

10.	git cherry-pick \[commit\]`选择一个commit，合并进当前分支`

11.	git branch -d \[branch-name\]`删除分支`

12.	删除远程分支

	1.	git push origin \-\-delete \[branch-name\]
	2.	git branch -dr \[remote/branch\]

### 标签操作

1.	git tag`列出所有tag`

2.	git tag \[tag\]`新建一个tag在当前commit`

3.	git tag \[tag\] \[commit\]`新建一个tag在指定commit`

4.	git tag -d \[tag\]`删除本地tag`

5.	git push origin :refs/tags/\[tagName\]`删除远程tag`

6.	git show \[tag\]`查看tag信息`

7.	git push \[remote\] \[tag\]`提交指定tag`

8.	git push \[remote\] \-\-tags`提交所有tag`

9.	git checkout -b \[branch\] \[tag\]`新建一个分支，指向某个tag`

### 查看信息操作

#### 显示有变更的文件

git status

#### 显示当前分支的版本历史

git log

#### 显示commit历史，以及每次commit发生变更的文件

git log \-\-stat

#### 搜索提交历史，根据关键词

git log -S \[keyword\]

#### 显示某个commit之后的所有变动，每个commit占据一行

git log \[tag\] HEAD \-\-pretty=format:%s

#### 显示某个commit之后的所有变动，其"提交说明"必须符合搜索条件

git log \[tag\] HEAD \-\-grep feature

#### 显示某个文件的版本历史，包括文件改名

git log \-\-follow \[file\] git whatchanged \[file\]

#### 显示指定文件相关的每一次diff

git log -p \[file\]

#### 显示过去5次提交

git log -5 \-\-pretty \-\-oneline

#### 显示所有提交过的用户，按提交次数排序

git shortlog -sn

#### 显示指定文件是什么人在什么时间修改过

git blame \[file\]

#### 显示暂存区和工作区的差异

git diff

#### 显示暂存区和上一个commit的差异

git diff \-\-cached \[file\]

#### 显示工作区与当前分支最新commit之间的差异

git diff HEAD

#### 显示两次提交之间的差异

git diff \[first-branch\]...\[second-branch\]

#### 显示今天你写了多少行代码

git diff \-\-shortstat "@{0 day ago}"

#### 显示某次提交的元数据和内容变化

git show \[commit\]

#### 显示某次提交发生变化的文件

git show \-\-name-only \[commit\]

#### 显示某次提交时，某个文件的内容

git show \[commit\]:\[filename\]

#### 显示当前分支的最近几次提交

git reflog

