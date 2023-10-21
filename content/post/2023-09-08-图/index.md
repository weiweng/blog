+++
title="算法专题|图"
date="2023-09-08T09:00:00+08:00"
categories=["算法专题"]
toc=true
draft=false
+++

图相关的算法练习，需要掌握图的基本数据结构，图的连通性，图的遍历，最短路径，最小生成树等问题。


## 初级练习

### **[找到小镇的法官](https://leetcode.cn/problems/find-the-town-judge/)**

**思路**

思路很简单，基于图的度，由于法官不信任其他人，因此他的出度是0，这样就可以找到了。

**代码**

```go
func findJudge(n int, trust [][]int) int {
    inDegrees := make([]int, n+1)
    outDegrees := make([]int, n+1)
    for _, t := range trust {
        inDegrees[t[1]]++
        outDegrees[t[0]]++
    }
    for i := 1; i <= n; i++ {
        if inDegrees[i] == n-1 && outDegrees[i] == 0 {
            return i
        }
    }
    return -1
}
```


### **[寻找图中是否存在路径](https://leetcode.cn/problems/find-if-path-exists-in-graph/)**

**思路**

能不能找到路径，很明显这是一个连通性问题，而图的连通性问题可以很自然想到并查集。

**代码**

```go
func validPath(n int, edges [][]int, source int, destination int) bool {
	p := make([]int, n)
	for i := range p {
		p[i] = i
	}
	var find func(x int) int
	find = func(x int) int {
		if p[x] != x {
			p[x] = find(p[x])
		}
		return p[x]
	}
	for _, e := range edges {
		p[find(e[0])] = find(e[1])
	}
	return find(source) == find(destination)
}
```

## 中级练习


### **[所有可能的路径]()**

**思路**

很明显这一题考察的是图的遍历。这里采用了回溯的算法，dfs遍历。

**代码**

```go
var res [][]int

func allPathsSourceTarget(graph [][]int) [][]int {
    var path []int
    // 全局变量需要重新初始化，否则会携带之前测试case的答案
    res = make([][]int, 0)
    travese(graph, 0, path)
    return res
}

func travese(graph [][]int, s int, path[]int) {
    // 记录路径
    path = append(path, s)
    if s == len(graph) - 1 {
        temp := make([]int, len(path))
        copy(temp, path)
        res = append(res, temp)
    }

    // 递归每个相邻节点
    for _, v := range graph[s] {
        travese(graph, v, path)
    }

    // 删除最后一个
    path = path[:len(path) - 1]
}
```

### **[由斜杠划分区域](https://leetcode.cn/problems/regions-cut-by-slashes/description/)**

**思路**

这一题比较抽象，但问题是问个数，很容易想到基于并查集的解法计算联通分量，那怎么把格子转换为图呢？

我们将一个各自对角线相连，化为4个部分，分别顺时针0、1、2、3，当左斜杠的时候0、3是联通的，1、2是联通的，当右斜杠的时候0、1联通，2、3联通。这样左右斜杠情况下格子的内部关联梳理清楚了。那相邻格子的情况如何处理，很明显水平相邻的各自a格子的1和b格子的3是联通的，上下相邻的格子，a格子的2和b格子的0是联通的。

并查集的个数设置为4*n*n，因为每个格子分为了4份。

**代码**

```go
type unionFind struct {
    parent, size []int
    setCount     int // 当前连通分量数目
}

func newUnionFind(n int) *unionFind {
    parent := make([]int, n)
    size := make([]int, n)
    for i := range parent {
        parent[i] = i
        size[i] = 1
    }
    return &unionFind{parent, size, n}
}

func (uf *unionFind) find(x int) int {
    if uf.parent[x] != x {
        uf.parent[x] = uf.find(uf.parent[x])
    }
    return uf.parent[x]
}

func (uf *unionFind) union(x, y int) {
    fx, fy := uf.find(x), uf.find(y)
    if fx == fy {
        return
    }
    if uf.size[fx] < uf.size[fy] {
        fx, fy = fy, fx
    }
    uf.size[fx] += uf.size[fy]
    uf.parent[fy] = fx
    uf.setCount--
}

func regionsBySlashes(grid []string) int {
    n := len(grid)
    uf := newUnionFind(4 * n * n)
    for i := 0; i < n; i++ {
        for j := 0; j < n; j++ {
            idx := i*n + j
            if i < n-1 {
                bottom := idx + n
                uf.union(idx*4+2, bottom*4)
            }
            if j < n-1 {
                right := idx + 1
                uf.union(idx*4+1, right*4+3)
            }
            if grid[i][j] == '/' {
                uf.union(idx*4, idx*4+3)
                uf.union(idx*4+1, idx*4+2)
            } else if grid[i][j] == '\\' {
                uf.union(idx*4, idx*4+1)
                uf.union(idx*4+2, idx*4+3)
            } else {
                uf.union(idx*4, idx*4+1)
                uf.union(idx*4+1, idx*4+2)
                uf.union(idx*4+2, idx*4+3)
            }
        }
    }
    return uf.setCount
}
```


### **[冗余连接](https://leetcode.cn/problems/redundant-connection/description/)**

**思路**

这题是减去一条边，让图变成树，我们通过并查集来做，新增加的两个点不是同一个联通分量，则可以加上这条边，不然就是重复链接边，因此可以得到答案。

**代码**

```go
func findRedundantConnection(edges [][]int) []int {
    parent := make([]int, len(edges)+1)
    for i := range parent {
        parent[i] = i
    }
    var find func(int) int
    find = func(x int) int {
        if parent[x] != x {
            parent[x] = find(parent[x])
        }
        return parent[x]
    }
    union := func(from, to int) bool {
        x, y := find(from), find(to)
        if x == y {
            return false
        }
        parent[x] = y
        return true
    }
    for _, e := range edges {
        if !union(e[0], e[1]) {
            return e
        }
    }
    return nil
}
```




### **[连通网络的操作次数](https://leetcode.cn/problems/number-of-operations-to-make-network-connected/description/)**

**思路**

还是并查集的使用，统计多少个联通分量，然后就可以知道需要剔除几根线路了。

**代码**

```go
type unionFind struct {
    parent, size []int
    setCount     int // 当前连通分量数目
}

func newUnionFind(n int) *unionFind {
    parent := make([]int, n)
    size := make([]int, n)
    for i := range parent {
        parent[i] = i
        size[i] = 1
    }
    return &unionFind{parent, size, n}
}

func (uf *unionFind) find(x int) int {
    if uf.parent[x] != x {
        uf.parent[x] = uf.find(uf.parent[x])
    }
    return uf.parent[x]
}

func (uf *unionFind) union(x, y int) {
    fx, fy := uf.find(x), uf.find(y)
    if fx == fy {
        return
    }
    if uf.size[fx] < uf.size[fy] {
        fx, fy = fy, fx
    }
    uf.size[fx] += uf.size[fy]
    uf.parent[fy] = fx
    uf.setCount--
}

func makeConnected(n int, connections [][]int) int {
    if len(connections) < n-1 {
        return -1
    }

    uf := newUnionFind(n)
    for _, c := range connections {
        uf.union(c[0], c[1])
    }

    return uf.setCount - 1
}
```



### **[省份数量](https://leetcode.cn/problems/number-of-provinces/)**

**思路**

思路很明显，并查集可解，但是也可以通过图的遍历区分联通分量。

**代码**

```go
func findCircleNum(isConnected [][]int) (ans int) {
    vis := make([]bool, len(isConnected))
    var dfs func(int)
    dfs = func(from int) {
        vis[from] = true
        for to, conn := range isConnected[from] {
            if conn == 1 && !vis[to] {
                dfs(to)
            }
        }
    }
    for i, v := range vis {
        if !v {
            ans++
            dfs(i)
        }
    }
    return
}
```



### **[移除最多的同行或同列石头](https://leetcode.cn/problems/most-stones-removed-with-same-row-or-column/)**

**思路**

思路很明显，并查集可解，但是也可以通过图的遍历区分联通分量。

**代码**

```go
func removeStones(stones [][]int) int {
    n := len(stones)
    graph := make([][]int, n)
    for i, p := range stones {
        for j, q := range stones {
            if p[0] == q[0] || p[1] == q[1] {
                graph[i] = append(graph[i], j)
            }
        }
    }
    vis := make([]bool, n)
    var dfs func(int)
    dfs = func(v int) {
        vis[v] = true
        for _, w := range graph[v] {
            if !vis[w] {
                dfs(w)
            }
        }
    }
    cnt := 0
    for i, v := range vis {
        if !v {
            cnt++
            dfs(i)
        }
    }
    return n - cnt
}
```



### **[连接所有点的最小费用](https://leetcode.cn/problems/min-cost-to-connect-all-points/)**

**思路**

很明显，这里需要使用最小生成树的算法。有两种基础算法，一种基于选点的Prim算法，一种基于选边的Kruskal算法。

**代码**

```go
type unionFind struct {
    parent, rank []int
}

func newUnionFind(n int) *unionFind {
    parent := make([]int, n)
    rank := make([]int, n)
    for i := range parent {
        parent[i] = i
        rank[i] = 1
    }
    return &unionFind{parent, rank}
}

func (uf *unionFind) find(x int) int {
    if uf.parent[x] != x {
        uf.parent[x] = uf.find(uf.parent[x])
    }
    return uf.parent[x]
}

func (uf *unionFind) union(x, y int) bool {
    fx, fy := uf.find(x), uf.find(y)
    if fx == fy {
        return false
    }
    if uf.rank[fx] < uf.rank[fy] {
        fx, fy = fy, fx
    }
    uf.rank[fx] += uf.rank[fy]
    uf.parent[fy] = fx
    return true
}

func dist(p, q []int) int {
    return abs(p[0]-q[0]) + abs(p[1]-q[1])
}

func minCostConnectPoints(points [][]int) (ans int) {
    n := len(points)
    type edge struct{ v, w, dis int }
    edges := []edge{}
    for i, p := range points {
        for j := i + 1; j < n; j++ {
            edges = append(edges, edge{i, j, dist(p, points[j])})
        }
    }

    sort.Slice(edges, func(i, j int) bool { return edges[i].dis < edges[j].dis })

    uf := newUnionFind(n)
    left := n - 1
    for _, e := range edges {
        if uf.union(e.v, e.w) {
            ans += e.dis
            left--
            if left == 0 {
                break
            }
        }
    }
    return
}

func abs(x int) int {
    if x < 0 {
        return -x
    }
    return x
}
```



### **[最大网络秩](https://leetcode.cn/problems/maximal-network-rank/)**

**思路**

这题的核心思路是计算节点的度，两个节点的度之和，如果两个节点联通则还要注意减一。

**代码**

```go
func maximalNetworkRank(n int, roads [][]int) int {
    connect := make([][]int, n)
    for i := range connect {
        connect[i] = make([]int, n)
    }
    degree := make([]int, n)
    for _, v := range roads {
        connect[v[0]][v[1]] = 1
        connect[v[1]][v[0]] = 1
        degree[v[0]]++
        degree[v[1]]++
    }

    maxRank := 0
    for i := 0; i < n; i++ {
        for j := i + 1; j < n; j++ {
            rank := degree[i] + degree[j] - connect[i][j]
            maxRank = max(maxRank, rank)
        }
    }
    return maxRank
}

func max(a, b int) int {
    if b > a {
        return b
    }
    return a
}
```


### **[找到最终的安全状态](https://leetcode.cn/problems/find-eventual-safe-states/)**

**思路**

拓补排序，这个可以学习一下。

**代码**

```go
func eventualSafeNodes(graph [][]int) (ans []int) {
    n := len(graph)
    rg := make([][]int, n)
    inDeg := make([]int, n)
    for x, ys := range graph {
        for _, y := range ys {
            rg[y] = append(rg[y], x)
        }
        inDeg[x] = len(ys)
    }

    q := []int{}
    for i, d := range inDeg {
        if d == 0 {
            q = append(q, i)
        }
    }
    for len(q) > 0 {
        y := q[0]
        q = q[1:]
        for _, x := range rg[y] {
            inDeg[x]--
            if inDeg[x] == 0 {
                q = append(q, x)
            }
        }
    }

    for i, d := range inDeg {
        if d == 0 {
            ans = append(ans, i)
        }
    }
    return
}
```



### **[判断二分图](https://leetcode.cn/problems/is-graph-bipartite/)**

**思路**

二分图的判断，简单的方法就是给节点上色，相邻节点不同的染色，判断是否可二分。

**代码**

```go
var (
    UNCOLORED, RED, GREEN = 0, 1, 2
    color []int
    valid bool
)

func isBipartite(graph [][]int) bool {
    n := len(graph)
    valid = true
    color = make([]int, n)
    for i := 0; i < n && valid; i++ {
        if color[i] == UNCOLORED {
            dfs(i, RED, graph)
        }
    }
    return valid
}

func dfs(node, c int, graph [][]int) {
    color[node] = c
    cNei := RED
    if c == RED {
        cNei = GREEN
    }
    for _, neighbor := range graph[node] {
        if color[neighbor] == UNCOLORED {
            dfs(neighbor, cNei, graph)
            if !valid {
                return 
            }
        } else if color[neighbor] != cNei {
            valid = false
            return
        }
    }
}
```



### **[树上最大得分和路径](https://leetcode.cn/problems/most-profitable-path-in-a-tree/)**

**思路**

这题很硬核，直接模拟计算。

**代码**

```go
func mostProfitablePath(edges [][]int, bob int, amount []int) int {
	n := len(edges) + 1
	g := make([][]int, n)
	for _, e := range edges {
		x, y := e[0], e[1]
		g[x] = append(g[x], y)
		g[y] = append(g[y], x) // 建树
	}

	bobTime := make([]int, n) // bobTime[x] 表示 bob 访问节点 x 的时间
	for i := range bobTime {
		bobTime[i] = n // 也可以初始化成 inf
	}
	var dfsBob func(int, int, int) bool
	dfsBob = func(x, fa, t int) bool {
		if x == 0 {
			bobTime[x] = t
			return true
		}
		for _, y := range g[x] {
			if y != fa && dfsBob(y, x, t+1) {
				bobTime[x] = t // 只有可以到达 0 才标记访问时间
				return true
			}
		}
		return false
	}
	dfsBob(bob, -1, 0)

	g[0] = append(g[0], -1) // 防止把根节点当作叶子
	ans := math.MinInt32
	var dfsAlice func(int, int, int, int)
	dfsAlice = func(x, fa, aliceTime, sum int) {
		if aliceTime < bobTime[x] {
			sum += amount[x]
		} else if aliceTime == bobTime[x] {
			sum += amount[x] / 2
		}
		if len(g[x]) == 1 { // 叶子
			ans = max(ans, sum) // 更新答案
			return
		}
		for _, y := range g[x] {
			if y != fa {
				dfsAlice(y, x, aliceTime+1, sum)
			}
		}
	}
	dfsAlice(0, -1, 0, 0)
	return ans
}

func max(a, b int) int { if b > a { return b }; return a }
```

### **[可能的二分法](https://leetcode.cn/problems/possible-bipartition/)**

**思路**

解题思路很简单，将不可链接关系作为边，整个图进行染色，如果不能实现ab染色则就是不可分割的。

**代码**

```go
func possibleBipartition(n int, dislikes [][]int) bool {
    g := make([][]int, n)
    for _, d := range dislikes {
        x, y := d[0]-1, d[1]-1
        g[x] = append(g[x], y)
        g[y] = append(g[y], x)
    }
    color := make([]int, n) // color[x] = 0 表示未访问节点 x
    var dfs func(int, int) bool
    dfs = func(x, c int) bool {
        color[x] = c
        for _, y := range g[x] {
            if color[y] == c || color[y] == 0 && !dfs(y, 3^c) {
                return false
            }
        }
        return true
    }
    for i, c := range color {
        if c == 0 && !dfs(i, 1) {
            return false
        }
    }
    return true
}
```
### **[课程表](https://leetcode.cn/problems/course-schedule/)**

**思路**

拓扑排序的基础使用。

**代码**

```go
func canFinish(numCourses int, prerequisites [][]int) bool {
    var (
        edges = make([][]int, numCourses)
        indeg = make([]int, numCourses)
        result []int
    )

    for _, info := range prerequisites {
        edges[info[1]] = append(edges[info[1]], info[0])
        indeg[info[0]]++
    }

    q := []int{}
    for i := 0; i < numCourses; i++ {
        if indeg[i] == 0 {
            q = append(q, i)
        }
    }

    for len(q) > 0 {
        u := q[0]
        q = q[1:]
        result = append(result, u)
        for _, v := range edges[u] {
            indeg[v]--
            if indeg[v] == 0 {
                q = append(q, v)
            }
        }
    }
    return len(result) == numCourses
}
```

### **[课程表 II](https://leetcode.cn/problems/course-schedule-ii/)**

**思路**

很明显是一道拓扑排序的问题，我们倒转给的的依赖数对，遍历入度为0的点，找到答案。

**代码**

```go
func findOrder(numCourses int, prerequisites [][]int) []int {
    var (
        edges = make([][]int, numCourses)
        indeg = make([]int, numCourses)
        result []int
    )

    for _, info := range prerequisites {
        edges[info[1]] = append(edges[info[1]], info[0])
        indeg[info[0]]++
    }

    q := []int{}
    for i := 0; i < numCourses; i++ {
        if indeg[i] == 0 {
            q = append(q, i)
        }
    }

    for len(q) > 0 {
        u := q[0]
        q = q[1:]
        result = append(result, u)
        for _, v := range edges[u] {
            indeg[v]--
            if indeg[v] == 0 {
                q = append(q, v)
            }
        }
    }
    if len(result) != numCourses {
        return []int{}
    }
    return result
}
```


### **[课程表 IV](https://leetcode.cn/problems/course-schedule-iv/)**

**思路**

核心思路还是拓扑排序，不过如何记录两个节点直接的前后关系呢？这里使用数组在拓扑排序遍历的时候统计，这个技巧可以学习。

**代码**

```go
func checkIfPrerequisite(numCourses int, prerequisites [][]int, queries [][]int) []bool {
    g := make([][]int, numCourses)
    indgree := make([]int, numCourses)
    isPre := make([][]bool, numCourses)
    for i, _ := range isPre {
        isPre[i] = make([]bool, numCourses)
        g[i] = []int{}
    }
    for _, p := range prerequisites {
        indgree[p[1]]++
        g[p[0]] = append(g[p[0]], p[1])
    }

    q := []int{}
    for i := 0; i < numCourses; i++ {
        if indgree[i] == 0 {
            q = append(q, i)
        }
    }
            
    for len(q) > 0 {
        cur := q[0]
        q = q[1:]
        for _, ne:= range g[cur] {
            isPre[cur][ne] = true
            for i := 0; i < numCourses; i++ {
                isPre[i][ne] = isPre[i][ne] || isPre[i][cur]
            }
            indgree[ne]--
            if indgree[ne] == 0 {
                q = append(q, ne)
            }
        }
    }
    res := []bool{}
    for _, query := range queries {
        res = append(res, isPre[query[0]][query[1]])
    }
    return res
}
```


### **[重新规划路线](https://leetcode.cn/problems/reorder-routes-to-make-all-paths-lead-to-the-city-zero/)**

**思路**

基本就是考虑从0出发，遍历整颗树，计算正向边数量（因为要从其他顶点到0） 那么就需要建无向图，并记录每条边的方向，遍历的时候计数即可 本题可以进行空间优化，不需要额外的空间保存边的方向：

- 建图时，如果是逆向，则保存为负数（因为顶点0是起点，保证了可行性）
- 遍历时，先判断边是否为正向边，是则加一；同时记得遍历时转为正数

**代码**

```go
func minReorder(n int, connections [][]int) int {
    adj := map[int][]int{}
    for _, conn := range connections {
        adj[conn[0]] = append(adj[conn[0]], conn[1])
        adj[conn[1]] = append(adj[conn[1]], -conn[0])
    }
    ans := 0
    var dfs func(u, p int)
    dfs = func(u, p int) {
        for _, v := range adj[u] {
            if v != p && -v != p {
                if v > 0 {
                    ans++
                } else {
                    v = -v
                }
                dfs(v, u)
            }
        }
    }
    dfs(0, n)
    return ans
}
```


### **[前往目标的最小代价](https://leetcode.cn/problems/minimum-cost-of-a-path-with-special-roads/)**

**思路**

最短路径的考察。

**代码**

```go
func minimumCost(start, target []int, specialRoads [][]int) int {
	type pair struct{ x, y int }
	t := pair{target[0], target[1]}
	dis := make(map[pair]int, len(specialRoads)+2)
	dis[t] = math.MaxInt
	dis[pair{start[0], start[1]}] = 0
	vis := make(map[pair]bool, len(specialRoads)+1) // 终点不用记
	for {
		v, dv := pair{}, -1
		for p, d := range dis {
			if !vis[p] && (dv < 0 || d < dv) {
				v, dv = p, d
			}
		}
		if v == t { // 到终点的最短路已确定
			return dv
		}
		vis[v] = true
		dis[t] = min(dis[t], dv+t.x-v.x+t.y-v.y) // 更新到终点的最短路
		for _, r := range specialRoads {
			w := pair{r[2], r[3]}
			d := dv + abs(r[0]-v.x) + abs(r[1]-v.y) + r[4]
			if dw, ok := dis[w]; !ok || d < dw {
				dis[w] = d
			}
		}
	}
}

func abs(x int) int { if x < 0 { return -x }; return x }
func min(a, b int) int { if b < a { return b }; return a }
```

### **[网络空闲的时刻]()**

**思路**

我们可以将整个计算机网络视为一个无向图，服务器为图中的节点。根据图中的边对应的关系 edges 即可求出图中任意节点之间的最短距离。利用广度优先搜索求出节点 0 到其他节点的最短距离，然后依次求出每个节点变为空闲的时间，当所有节点都变为空闲时，整个网络即变空闲状态，因此网络的最早空闲时间即为各个节点中最晚的空闲时间。定义节点的空闲状态定义为该节点不再发送和接收消息。

求各个节点与 0 号服务器的最短路径，直接利用广度优先搜索即可。

设节点 v 与节点 0 之间的最短距离为 dist，则此时当节点 v 接收到主服务器节点 0 的最后一个回复后的下一秒，则节点 v 变为空闲状态。节点 v 发送一个消息经过 dist 秒到达节点 0，节点 0 回复消息又经过 dist 秒到达节点 v，因此节点 v 每发送一次消息后，经过 2×dist 秒才能收到回复。由于节点 v 在未收到节点 0 的回复时，会周期性每 `patience[v]` 秒发送一次消息，一旦收到来自节点 0 的回复后就停止发送消息，需要分以下两种情况进行讨论：

当 `2×dist≤patience[v]` 时，则此时节点 v 还未开始发送第二次消息就已收到回复，因此节点 v 只会发送一次消息，则此时节点 v 变为空闲的时间为 2×dist+1。

当 `2×dist>patience[v]` 时，则此时节点还在等待第一次发送消息的回复时，就会开始再次重发消息，经过计算可以知道在 `[1,2×dist)` 时间范围内会最多再次发送 `⌊(2×dist−1)/patience[i]⌋` 次消息，最后一次发送消息的时间为 `patience[v]×⌊(2×dist−1)/patience[v]⌋`，而节点 v 每发送一次消息就会经过 2×dist[v] 收到回复，因此节点 v 最后一次收到回复的时间为 `patience[v]×⌊(2×dist−1)/patience[v]⌋+2×dist`，则此时可知节点 v 变为空闲的时间为 `patience[v]×⌊(2×dist−1)/patience[v]⌋+2×dist+1`

当 `2×dist≤patience[v]` 时，`⌊(2×dist−1)/patience[v]⌋=0`，因此以上两种情况可以进行合并，即节点 v 变为空闲的时间为 `patience[v]×⌊(2×dist−1)/patience[v]⌋+2×dist+1`

依次求出每个节点变为空闲的时间，返回最大值即为答案。

**代码**

```go
func networkBecomesIdle(edges [][]int, patience []int) (ans int) {
    n := len(patience)
    g := make([][]int, n)
    for _, e := range edges {
        x, y := e[0], e[1]
        g[x] = append(g[x], y)
        g[y] = append(g[y], x)
    }

    vis := make([]bool, n)
    vis[0] = true
    q := []int{0}
    for dist := 1; q != nil; dist++ {
        tmp := q
        q = nil
        for _, x := range tmp {
            for _, v := range g[x] {
                if vis[v] {
                    continue
                }
                vis[v] = true
                q = append(q, v)
                ans = max(ans, (dist*2-1)/patience[v]*patience[v]+dist*2+1)
            }
        }
    }
    return
}

func max(a, b int) int {
    if b > a {
        return b
    }
    return a
}
```

### **[颜色交替的最短路径](https://leetcode.cn/problems/shortest-path-with-alternating-colors/description/)**

**思路**

广度优先遍历，一层一层的交替查找最短路径，代码值得学习。

**代码**

```go
func shortestAlternatingPaths(n int, redEdges [][]int, blueEdges [][]int) []int {
	g := [2][][]int{}
	for i := range g {
		g[i] = make([][]int, n)
	}
	for _, e := range redEdges {
		g[0][e[0]] = append(g[0][e[0]], e[1])
	}
	for _, e := range blueEdges {
		g[1][e[0]] = append(g[1][e[0]], e[1])
	}
	type pair struct{ i, c int }
	q := []pair{pair{0, 0}, pair{0, 1}}
	ans := make([]int, n)
	vis := make([][2]bool, n)
	for i := range ans {
		ans[i] = -1
	}
	d := 0
	for len(q) > 0 {
		for k := len(q); k > 0; k-- {
			p := q[0]
			q = q[1:]
			i, c := p.i, p.c
			if ans[i] == -1 {
				ans[i] = d
			}
			vis[i][c] = true
			c ^= 1
			for _, j := range g[c][i] {
				if !vis[j][c] {
					q = append(q, pair{j, c})
				}
			}
		}
		d++
	}
	return ans
}
```
## 高级训练

### **[破解保险箱](https://leetcode.cn/problems/cracking-the-safe/description/)**

**思路**

这一题考察Hierholzer 算法，这个可以学习一下。

**代码**

```go
func crackSafe(n int, k int) string {
    seen := map[int]bool{}
    ans := ""
    highest := int(math.Pow(10, float64(n - 1)))
    
    var dfs func(int)
    dfs = func(node int) {
        for x := 0; x < k; x++ {
            nei := node * 10 + x
            if !seen[nei] {
                seen[nei] = true
                dfs(nei % highest)
                ans += strconv.Itoa(x)
            }
        }
    }
    dfs(0)
    for i := 1; i < n; i++ {
        ans += "0"
    }
    return ans
}
```