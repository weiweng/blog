+++
title="Alpha-Beta算法"
tags=["算法","alpha-beta"]
date="2020-03-13T05:00:00+08:00"
summary = 'Alpha-Beta算法'
toc=false
+++

### 引言

最近学习go语言，学习完基本语法后想实战以下，因此搜索到这篇文章——给GO语言新手:[8个实战教程](https://www.jianshu.com/p/226c80c481a1)。这其中发现一个2048的项目因此写此篇博客记录alpha-beta算法的学习过程。

### Minimax算法

Minimax算法，极小极大搜索方法，该算法通常用于博弈游戏的决策搜索中，例如五子棋，围棋，象棋等。该算法的核心思想是假定对手选择了最优策略的情况下我们做出最优决策。由于对手做出最优决策必然会使得我们的收益最少，因此该算法通过搜索当前最大值和搜索当前最小值（通过量化当前局势来给定一个评分数值）这两个步骤来模拟敌我双方互相博弈的过程。

具体详细讲解可见

1.	[极大极小算法有些不明白?](https://www.zhihu.com/question/27221568/answer/140874499)
2.	[Minimax维基百科](https://en.wikipedia.org/wiki/Minimax)

#### Minimax伪代码

```javascript
//node 结点，代表开始搜索的局面
//depth 搜索的深度，可以自定义调节，越深时间越长
//maximizingPlayer bool变量，判断该阶段是搜索最大值还是最小值
function minimax(node,depth,maximizingPlayer) //depth=0或者局面已经是最终结果则进行评分，给该策略进行打分
    if depth=0 or node is a terminal node
	    return the heuristic value of node
	if maximizingPlayer
		//玩家回合，搜索最大值结果作为我们的最优决策
	    bestValue := -9999999999
		//循环遍历当前局面展开的各个分支
		for each child of node
			//递归的求解每个分支的评分，选择最大值
		    v := minimax(child,depth-1,FALSE)
			bestValue := max(bestValue,v)
		//返回最优值
		return bestValue
	else 
		//敌方回合，我们需要搜索最小值以此来模拟敌方选择了最优策略
	    bestValue := +9999999999
		for each child of node
		    v := minimax(child,depth-1,TRUE)
			bestValue := min(bestValue,v)
		return bestValue
```

### Alpha-beta算法

上述的Minimax算法中，我们遍历了node局面中所有的分支情况，虽然这样做很全面，但如果分支很多假设搜索层数较大时，迭代的时间必然开销很大，因此大神提出了Alpha-beta算法来是实现部分剪枝，减少迭代次数。而Alpha-beta算法的核心思想是，我们提出两个数值alpha和beta，其中alpha是我们获取最优值的下限，即我们在当前局面下能获得的最少分数，而beta设定为我们能获得的最优值上限，即当前局面我们最大能获得的分数值。由此当我们迭代时出现alpha大于beta时，便可明显知道这个分支不必在迭代计算了。需要注意的是，alpha作为下限，当然是越大越好，这样就保证我们的收益至少越来越大，而beta作为上限，对于敌手而言，自然是越小越好，因此我们在算法中，玩家回合时只考虑alpha的变化，而敌方回合时则考虑beta的变化。不过两者都需要考虑alpha大于beta时的剪枝情况。

算法具体介绍：

1.	[Alpha-beta 维基百科](https://en.wikipedia.org/wiki/Alpha-beta_pruning)
2.	[Alpha-Beta剪枝 CSDN博客](https://blog.csdn.net/tangchenyi/article/details/22925957)

#### Alpha-beta伪代码

```javascript
// node 结点，代表开始搜索的局面
// depth 搜索的深度，可以自定义调节，越深时间越长
// maximizingPlayer bool变量，判断该阶段是搜索最大值还是最小值 
function alphabeta(node,depth,alpha,beta,maximizingPlayer) //depth=0或者局面已经是最终结果则进行评分，给该策略进行打分
    if depth=0 or node is a terminal node
	    return the heuristic value of node
	if maximizingPlayer
		//玩家回合，搜索最大值结果作为我们的最优决策
	    bestValue := -9999999999
		//循环遍历当前局面展开的各个分支
		for each child of node
			//递归的求解每个分支的评分，选择最大值
		    v := max(v,alphabeta(child,depth-1,alpha,beta,FALSE))
			//更新alpha，使得alpha尽量大
			alpha := max(alpha,v)
			//剪枝操作
			if beta<=alpha
			    berak
		//返回最优值
		return v 
	else 
		//敌方回合，我们需要搜索最小值以此来模拟敌方选择了最优策略
	    bestValue := +9999999999
		for each child of node
			v := min(v,alphabeta(child,depth-1,alpha,beta,TRUE))
			//更新beta，让beta最小
			beta := min(beta,v)
			if beta<=alpha
			    berak
		return v 
```

### 2048代码

有关2048的源码主要看以下三部分

1.	go语言实现的命令行窗口的2048 [shiyanlou/golang2048_game](https://github.com/shiyanlou/golang2048_game)
2.	js写的网页版2048并且带ai使用了alpha-beta算法 [ovolve/2048-AI](https://github.com/ovolve/2048-AI)
3.	[js的2048ai的设计思路](blog.jobbole.com/63888/)
4.	go语言实现的2048ai使用minimax算法[ xwjdsh/2048-ai](https://github.com/xwjdsh/2048-ai)

#### 代码分析

我自己修改的2048ai的go语言版本，加入了alpha-beta算法，不过没有引入js版本所谓的平滑以及单调性等考虑，只是加入了对空闲结点可移动的考虑，有时候很快到达2048，但也很容易死机。。。。 [源代码见此](https://github.com/Duke-wei/2048-ai-go/tree/alpha-beta)

```javascript
//核心代码2048-ai-go/ai/ai.go代码分析
//打包
package ai
//导入其他库
//grid已经写好了2048的基本操作
import (
	"github.com/xwjdsh/2048-ai/grid"
	"log"
	"math/rand"
)

type AI struct {
	// Grid is 4x4 grid.
	Grid *grid.Grid
	Active bool
}
//定义方向集合，为了后续搜索使展开遍历
var directions = []grid.Direction{
	grid.UP,
	grid.LEFT,
	grid.DOWN,
	grid.RIGHT,
}

// The chance is 10% about fill "4" into grid and 90% fill "2" in the 2048 game.
//由于更改原有代码，所以这里的map已经失去意义
var expectMap = map[int]float64{
	2: 0.9,
	4: 0.1,
}
//权重矩阵，为了给每个局面进行量化计分
var (
	// There are three model weight matrix, represents three formation for 2048 game, it from internet.
	// The evaluate function is simple and crude, so actually it's not stable.
	// If you feel interesting in evaluation function, you can read https://github.com/ovolve/2048-AI project source code.
	model1 = [][]int{
		{16, 15, 14, 13},
		{9, 10, 11, 12},
		{8, 7, 6, 5},
		{1, 2, 3, 4},
	}
	model2 = [][]int{
		{16, 15, 12, 4},
		{14, 13, 11, 3},
		{10, 9, 8, 2},
		{7, 6, 5, 1},
	}
	model3 = [][]int{
		{16, 15, 14, 4},
		{13, 12, 11, 3},
		{10, 9, 8, 2},
		{7, 6, 5, 1},
	}
)

// Search method compute each could move direction score result by expect search algorithm
func (a *AI) Search() grid.Direction {
	var (
		bestDire  = grid.NONE
		bestScore float64
	)
	// depth value depending on grid's max value.
	dept := a.deptSelect()
	//遍历4个方向的移动情况
	for _, dire := range directions {
		newGrid := a.Grid.Clone()
		if newGrid.Move(dire) {
			//可以移动，则展开深度的搜索
			newAI := &AI{Grid: newGrid, Active: false}
			//开始alpha-beta算法搜索，初始alpha和beta分别为最小值和最大值
			if newScore := newAI.expectSearch(dept,-999999999,999999999); newScore > bestScore {
				bestDire = dire
				bestScore = newScore
			}
		}
	}
	//已经无法移动了，基本已经游戏结束，随机传回一个方向的操作
	if bestDire==grid.NONE{
		bestDire = directions[rand.Intn(3)]
	}
	return bestDire
}

//加入alpha-beta算法，其中alpha是优化下限，即在选手操作期间我们的优化目标尽量搜索使得alpha最大，而beta优化上限，是敌方操作时我们的优化目标，即尽量使beta最小
func (a *AI) expectSearch(dept int,alpha,beta float64) float64 {
	if dept == 0 {
		//dept为0，开始局面的量化
		return float64(a.score())
	}
	var score float64
	if a.Active {
		//玩家操作回合，目标为了最大化alpha
		score = alpha
		for _, d := range directions {
			//对每个方向进行搜索,深入遍历
			newGrid := a.Grid.Clone()
			if newGrid.Move(d) {
				newAI := &AI{Grid: newGrid, Active: false}
				if newScore := newAI.expectSearch(dept - 1,score,beta); newScore > score {
					score = newScore
				}
				if score>beta{
					//alpha>beta，剪枝，返回beta值
					log.Println("player turn cut-off",alpha,"-",beta)
					return beta
				}
			}
		}
	} else {
		//敌方回合操作
		//原本应该是针对当前局面下每一个空格单独的填入2或者4(这里应该是2的出现概率更大的)，然后针对每个情况进行难度量化，选择困难度高的分支进行搜索的，这才符合算法的思想
		score = beta
		points := a.Grid.VacantPoints()
		//如果没有空格可以填充则返回alpha
		if len(points)==0{
			return alpha
		}
		for k,_ := range expectMap {
			for _, point := range points {
				newGrid := a.Grid.Clone()
				newGrid.Data[point.X][point.Y] = k
				// Change active, select a direction to move now.
				//加入这行代码，即填补位置周围都是空时跳过该预测，减少迭代次数，可以很快达到2048，不过也很容易game over
				if smt:=newGrid.Smoothness(point.X,point.Y,k);smt==0{
				    continue
				}
				newAI := &AI{Grid: newGrid, Active: true}
				if newScore := newAI.expectSearch(dept - 1,alpha,score);newScore<score{
					score = newScore
				}
				if alpha>score{
					log.Println("computer put cell,cut-off",alpha,"-",score)
					return alpha
				}
			}
		}
	}
	return score
}

// score method evaluate a grid
func (a *AI) score() int {
	result := make([]int, 24)
	for x := 0; x < 4; x++ {
		for y := 0; y < 4; y++ {
			if value := a.Grid.Data[x][y]; value != 0 {
				// get eight result(rotate and flip grid) for each model,
				modelScore(0, x, y, value, model1, &result)
				modelScore(1, x, y, value, model2, &result)
				modelScore(2, x, y, value, model3, &result)
			}
		}
	}
	// get max score in above 24 result, apply best formation
	var max int
	for _, v := range result {
		if v > max {
			max = v
		}
	}
	return max
}

// get eight result(rotate and flip grid) for each model
func modelScore(index, x, y, value int, model [][]int, result *[]int) {
	start := index * 8
	r := *result
	r[start] += value * model[x][y]
	r[start+1] += value * model[x][3-y]

	r[start+2] += value * model[y][x]
	r[start+3] += value * model[3-y][x]

	r[start+4] += value * model[3-x][3-y]
	r[start+5] += value * model[3-x][y]

	r[start+6] += value * model[y][3-x]
	r[start+7] += value * model[3-y][3-x]
}

// the return value is search depth, it depending on grid's max value
// the max value larger and depth larger, this will takes more calculations and make move became slowly but maybe have a better score result.
func (a *AI) deptSelect() int {
	dept := 4
	max := a.Grid.Max()
	if max >= 2048 {
		dept = 6
	} else if max >= 1024 {
		dept = 5
	}
	return dept
}

```

