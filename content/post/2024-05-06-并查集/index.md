+++
title="算法专题|并查集"
date="2024-05-06T08:00:00+08:00"
categories=["算法专题"]
toc=true
draft=false
+++

并查集（Union-find Data Structure）是一种树型的数据结构。它的特点是由子结点找到父亲结点，用于处理一些不交集（Disjoint Sets）的合并及查询问题。

    Find：确定元素属于哪一个子集。它可以被用来确定两个元素是否属于同一子集。
    Union：将两个子集合并成同一个集合。

典型的代码模板

```go
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
```

## 初级练习

### **[1971. 寻找图中是否存在路径](https://leetcode.cn/problems/find-if-path-exists-in-graph/description/)**

**思路**

这题很经典，通过并查集检查两个点是否联通。

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

### **[959. 由斜杠划分区域](https://leetcode.cn/problems/regions-cut-by-slashes/description/)**

**思路**

这一题怎么处理斜线是关键点，我们把小方块划分4个部分，斜线划分的2块就把对应的小区域链接，其他方块的链接同理，这样最后联通分量就是答案。

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

### **[684. 冗余连接](https://leetcode.cn/problems/redundant-connection/description/)**

**思路**

逆向思维，做增边操作，如果增加的这条边的两个点已经联通了，那这个边就是多余的。

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

### **[1061. 按字典序排列最小的等效字符串](https://leetcode.cn/problems/lexicographically-smallest-equivalent-string/description/)**

**思路**

这一题的解法很简单，并查集将可以等价的字符关联，关联到最小的字符，而后对于base字符串的转换，只要每个字母转成最小关联字符即可。

**代码**
```go
func smallestEquivalentString(s1 string, s2 string, baseStr string) string {
	parent := make([]byte, 26)
	var i byte = 0
	for i = 0; i < 26; i++ {
		parent[i] = i
	}

	var find func(i byte) byte
	find = func(i byte) byte {
		if parent[i] != i {
			parent[i] = find(parent[i])
		}
		return parent[i]
	}

	var union func(from, to byte)
	union = func(from, to byte) {
		fromFind := find(from)
		toFind := find(to)
		// 总是将字典序较小的当为祖先
		if fromFind < toFind {
			parent[toFind] = fromFind
		} else {
			parent[fromFind] = toFind
		}
	}

	for i := 0; i < len(s1); i++ {
		union(s1[i]-97, s2[i]-97)
	}
    // 我们新建一个 byte 数组用来存储最终结果
	resStr := make([]byte, len(baseStr))

    // i 位置的结果就是其对应的祖先字符
	for i := 0; i < len(baseStr); i++ {
		resStr[i] = find(baseStr[i]- 'a') + 'a'
	}
	return string(resStr)
}
```



### **[连接所有点的最小费用](https://leetcode.cn/problems/min-cost-to-connect-all-points/description)**

**思路**

先计算两个节点之间的距离，然后排序，选边，利用并查集判断是否两个节点已经链接。

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


### **[399. 除法求值](https://leetcode.cn/problems/evaluate-division/description/)**

**思路**

思路还是并查集，但这一题明显需要记录额外的权重信息，这一题需要学习如何带上权重信息。

**代码**
```go
func calcEquation(equations [][]string, values []float64, queries [][]string) []float64 {
    // 给方程组中的每个变量编号
    id := map[string]int{}
    for _, eq := range equations {
        a, b := eq[0], eq[1]
        if _, has := id[a]; !has {
            id[a] = len(id)
        }
        if _, has := id[b]; !has {
            id[b] = len(id)
        }
    }

    fa := make([]int, len(id))
    w := make([]float64, len(id))
    for i := range fa {
        fa[i] = i
        w[i] = 1
    }
    var find func(int) int
    find = func(x int) int {
        if fa[x] != x {
            f := find(fa[x])
            w[x] *= w[fa[x]]
            fa[x] = f
        }
        return fa[x]
    }
    merge := func(from, to int, val float64) {
        fFrom, fTo := find(from), find(to)
        w[fFrom] = val * w[to] / w[from]
        fa[fFrom] = fTo
    }

    for i, eq := range equations {
        merge(id[eq[0]], id[eq[1]], values[i])
    }

    ans := make([]float64, len(queries))
    for i, q := range queries {
        start, hasS := id[q[0]]
        end, hasE := id[q[1]]
        if hasS && hasE && find(start) == find(end) {
            ans[i] = w[start] / w[end]
        } else {
            ans[i] = -1
        }
    }
    return ans
}
```


### **[785. 判断二分图](https://leetcode.cn/problems/is-graph-bipartite/description/)**

**思路**

思路还是并查集，核心是判断二分图，则与顶点相连接的临近节点应该都是一个集合里面的，完成链接后判断顶点是否和链接点归入了同一个和集合里面。

**代码**
```go
func isBipartite(graph [][]int) bool {
	parents := make([]int, len(graph))
	for i := range parents {
		parents[i] = i
	}
	var getFa func(x int) int
	getFa = func(x int) int {
		if parents[x] == x {
			return x
		}
		parents[x] = getFa(parents[x])
		return parents[x]
	}
	merge := func(x, y int) {
		fx := getFa(x)
		fy := getFa(y)
		parents[fx] = fy
	}
	for i := range graph {
		for j := 0; j < len(graph[i])-1; j++ {
			merge(graph[i][j], graph[i][j+1])
		}
		for j := range graph[i] {
			if getFa(i) == getFa(graph[i][j]) {
				return false
			}
		}
	}
	return true
}
```

### **[1631. 最小体力消耗路径](https://leetcode.cn/problems/path-with-minimum-effort/description/)**

**思路**

这一题本质好像是找最短路径问题，由于是从左上角到右下角，所以我们就选向下和向右的相邻点为边，计算边的权重，通过选边加上并查集判断是否有左上角到右下角的联通路径，有的话就得到最小的消耗了。

**代码**
```go
type unionFind struct {
    parent, size []int
}

func newUnionFind(n int) *unionFind {
    parent := make([]int, n)
    size := make([]int, n)
    for i := range parent {
        parent[i] = i
        size[i] = 1
    }
    return &unionFind{parent, size}
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
}

func (uf *unionFind) inSameSet(x, y int) bool {
    return uf.find(x) == uf.find(y)
}

type edge struct {
    v, w, diff int
}

func minimumEffortPath(heights [][]int) int {
    n, m := len(heights), len(heights[0])
    edges := []edge{}
    for i, row := range heights {
        for j, h := range row {
            id := i*m + j
            if i > 0 {
                edges = append(edges, edge{id - m, id, abs(h - heights[i-1][j])})
            }
            if j > 0 {
                edges = append(edges, edge{id - 1, id, abs(h - heights[i][j-1])})
            }
        }
    }
    sort.Slice(edges, func(i, j int) bool { return edges[i].diff < edges[j].diff })

    uf := newUnionFind(n * m)
    for _, e := range edges {
        uf.union(e.v, e.w)
        if uf.inSameSet(0, n*m-1) {
            return e.diff
        }
    }
    return 0
}

func abs(x int) int {
    if x < 0 {
        return -x
    }
    return x
}
```


### **[1202. 交换字符串中的元素](https://leetcode.cn/problems/smallest-string-with-swaps/description/)**

**思路**

这一题的思路是通过并查集将同一个可交换的集合找出来排序，最后重新整合

**代码**
```go
type Djset struct{
    Parent []int
    Rank []int
}
func newDjset(n int) Djset {
    parent := make([]int, n)
    rank := make([]int, n)
    for i := 0; i < n; i++ {
        parent[i] = i
        rank[i] = 0
    }
    return Djset{parent, rank}
}
func (ds Djset) Find(x int) int {
    if ds.Parent[x] != x {
        ds.Parent[x] = ds.Find(ds.Parent[x])
    }
    return ds.Parent[x]
}
func (ds Djset) Merge(x, y int) {
    rx := ds.Find(x)
    ry := ds.Find(y)
    if rx != ry {
        if ds.Rank[rx] < ds.Rank[ry] {
            rx, ry = ry,rx
        }
        ds.Parent[ry] = rx;
        if ds.Rank[rx] == ds.Rank[ry] {
            ds.Rank[rx] += 1
        }
    }
}
func smallestStringWithSwaps(s string, pairs [][]int) string {
    n := len(s)
    ds := newDjset(n)
    rs := make([]byte, n)
    for _, v := range(pairs) {
        ds.Merge(v[0], v[1])
    }
    
    um := make(map[int][]int)
    for i := 0; i < n; i++ {
        um[ds.Find(i)] = append(um[ds.Find(i)], i)
    }

    for _, v := range(um) {
        c := make([]int, len(v))
        copy(c, v)
        sort.Slice(v, func(i, j int) bool {
            return s[v[i]] < s[v[j]]
        })
        for i := 0; i < len(c); i++ {
            rs[c[i]] = s[v[i]]
        }
    }
    return string(rs)
}
```

### **[1391. 检查网格中是否存在有效路径](https://leetcode.cn/problems/check-if-there-is-a-valid-path-in-a-grid/description/)**

**思路**

这题第一感觉和划斜杆的题目差不多，不过这个仔细观察发现可以配对连接的情况就这两种，因此代码如下。

**代码**
```go
func hasValidPath(grid [][]int) bool {
    m := len(grid)
    n := len(grid[0])
    parents := make([]int,m*n)
    for i,_:=range parents{
        parents[i] = i
    }
    var find func(a int) int

    find = func(a int) int{
        if a!=parents[a]{
            parents[a] = find(parents[a])
        }
        return parents[a]
    }
    isUnion := func(a,b int) bool{
        return find(a)==find(b)
    }
    union := func(a,b int){
        parents[find(a)] = find(b)
    }
    for i:=0;i<m;i++{
        for j:=0;j<n;j++{
            if grid[i][j] == 1 ||grid[i][j] == 4 || grid[i][j] == 6{
                
                if j+1<n && (grid[i][j+1] == 1||grid[i][j+1] == 3 || grid[i][j+1] == 5){
                    union(i*n+j,i*n+j+1)
                } 
            }
            if grid[i][j] == 2||grid[i][j] == 3 || grid[i][j] == 4{
                if i+1<m &&( grid[i+1][j] == 2||grid[i+1][j] == 5 || grid[i+1][j] == 6){
                    union((i+1)*n+j,i*n+j)
                }
            }
        }
    }

    return isUnion(0,n*m-1)
}
```

### **[2812. 找出最安全路径](https://leetcode.cn/problems/find-the-safest-path-in-a-grid/description/)**

**思路**

核心思路是二分+并查集，基于二分得到一个预定的最大距离，用并查集判断这个距离限制下，能不能联通起点和终点，所以这里还需要一个前提，就是每个点到最近小偷的距离

**代码**
```go
func maximumSafenessFactor(grid [][]int) int {

	n := len(grid)

	type pair struct{ x, y int }

	q := []pair{}

	dis := make([][]int, n)

	for i, row := range grid {

		dis[i] = make([]int, n)

		for j, x := range row {

			if x > 0 {

				q = append(q, pair{i, j})

			} else {

				dis[i][j] = -1

			}

		}

	}



	dir4 := []pair{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}

	groups := [][]pair{q}

	for len(q) > 0 { // 多源 BFS

		tmp := q

		q = nil

		for _, p := range tmp {

			for _, d := range dir4 {

				x, y := p.x+d.x, p.y+d.y

				if 0 <= x && x < n && 0 <= y && y < n && dis[x][y] < 0 {

					q = append(q, pair{x, y})

					dis[x][y] = len(groups)

				}

			}

		}

		groups = append(groups, q) // 相同 dis 分组记录

	}



	// 并查集模板

	fa := make([]int, n*n)

	for i := range fa {

		fa[i] = i

	}

	var find func(int) int

	find = func(x int) int {

		if fa[x] != x {

			fa[x] = find(fa[x])

		}

		return fa[x]

	}



	for ans := len(groups) - 2; ans > 0; ans-- {

		for _, p := range groups[ans] {

			i, j := p.x, p.y

			for _, d := range dir4 {

				x, y := p.x+d.x, p.y+d.y

				if 0 <= x && x < n && 0 <= y && y < n && dis[x][y] >= dis[i][j] {

					fa[find(x*n+y)] = find(i*n + j)

				}

			}

		}

		if find(0) == find(n*n-1) { // 写这里判断更快些

			return ans

		}

	}

	return 0

}
```

## 高级练习

### **[765. 情侣牵手](https://leetcode.cn/problems/couples-holding-hands/description/)**

**思路**

这道题目虽然归类为困难，但核心思想还是理解并查集，这道题里面我们通过关联相邻位置的两个单元合并为一个连通分量，注意需要进行除2处理，因为0和1，2和3已经是联通的，需要缩减，最后计算联通分量，而需要交换的次数就是`n/2`减去联通分量的个数。

一个连通分量重包含k组成员，我们只要进行k-1次交换，就可以完成k组的牵手，因此有之前说的结论。


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

func minSwapsCouples(row []int) int {
    n := len(row)
    uf := newUnionFind(n / 2)
    for i := 0; i < n; i += 2 {
        uf.union(row[i]/2, row[i+1]/2)
    }
    return n/2 - uf.setCount
}
```

### **[1489. 找到最小生成树里的关键边和伪关键边](https://leetcode.cn/problems/find-critical-and-pseudo-critical-edges-in-minimum-spanning-tree/description/)**


**思路**

这一题如何确定关键边，一个核心点就是剔除这条边，整个生成树的总和变大了，则这条边就是关键边。

那如何确定伪关键边，核心就是包含这条边，能够构建出最小生成树，那就是伪关键边了。


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

func (uf *unionFind) union(x, y int) bool {
    fx, fy := uf.find(x), uf.find(y)
    if fx == fy {
        return false
    }
    if uf.size[fx] < uf.size[fy] {
        fx, fy = fy, fx
    }
    uf.size[fx] += uf.size[fy]
    uf.parent[fy] = fx
    uf.setCount--
    return true
}

func findCriticalAndPseudoCriticalEdges(n int, edges [][]int) [][]int {
    for i, e := range edges {
        edges[i] = append(e, i)
    }
    sort.Slice(edges, func(i, j int) bool { return edges[i][2] < edges[j][2] })

    calcMST := func(uf *unionFind, ignoreID int) (mstValue int) {
        for i, e := range edges {
            if i != ignoreID && uf.union(e[0], e[1]) {
                mstValue += e[2]
            }
        }
        if uf.setCount > 1 {
            return math.MaxInt64
        }
        return
    }

    mstValue := calcMST(newUnionFind(n), -1)

    var keyEdges, pseudokeyEdges []int
    for i, e := range edges {
        // 是否为关键边
        if calcMST(newUnionFind(n), i) > mstValue {
            keyEdges = append(keyEdges, e[3])
            continue
        }

        // 是否为伪关键边
        uf := newUnionFind(n)
        uf.union(e[0], e[1])
        if e[2]+calcMST(uf, i) == mstValue {
            pseudokeyEdges = append(pseudokeyEdges, e[3])
        }
    }

    return [][]int{keyEdges, pseudokeyEdges}
}

```


### **[1697. 检查边长度限制的路径是否存在](https://leetcode.cn/problems/checking-existence-of-edge-length-limited-paths/description/)**


**思路**

题目要求给定query，回答是否满足给定limit下的两点联通情况，很明显用到并查集，但每次query都去从新构建肯定很浪费性能，我们需要考虑一下构建一次就能满足查询的情况，从限制出发，我们可以让每次查询的限制内的边都链接，这样查询并查集，就自动满足每条边的限制，因此将边的权重和query排序，边查询边链接。


**代码**
```go
func distanceLimitedPathsExist(n int, edgeList [][]int, queries [][]int) []bool {
    sort.Slice(edgeList, func(i, j int) bool { return edgeList[i][2] < edgeList[j][2] })

    // 并查集模板
    fa := make([]int, n)
    for i := range fa {
        fa[i] = i
    }
    var find func(int) int
    find = func(x int) int {
        if fa[x] != x {
            fa[x] = find(fa[x])
        }
        return fa[x]
    }
    merge := func(from, to int) {
        fa[find(from)] = find(to)
    }

    for i := range queries {
        queries[i] = append(queries[i], i)
    }
    // 按照 limit 从小到大排序，方便离线
    sort.Slice(queries, func(i, j int) bool { return queries[i][2] < queries[j][2] })

    ans := make([]bool, len(queries))
    k := 0
    for _, q := range queries {
        for ; k < len(edgeList) && edgeList[k][2] < q[2]; k++ {
            merge(edgeList[k][0], edgeList[k][1])
        }
        ans[q[3]] = find(q[0]) == find(q[1])
    }
    return ans
}
```

**[1579. 保证图可完全遍历](https://leetcode.cn/problems/remove-max-number-of-edges-to-keep-graph-fully-traversable/)**

**思路**

这一题核心还是并查集判断是否联通，我们先处理公共边，因为公共边的收益最大，其次再考虑单边的情况。

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

func (uf *unionFind) union(x, y int) bool {
    fx, fy := uf.find(x), uf.find(y)
    if fx == fy {
        return false
    }
    if uf.size[fx] < uf.size[fy] {
        fx, fy = fy, fx
    }
    uf.size[fx] += uf.size[fy]
    uf.parent[fy] = fx
    uf.setCount--
    return true
}

func (uf *unionFind) inSameSet(x, y int) bool {
    return uf.find(x) == uf.find(y)
}

func maxNumEdgesToRemove(n int, edges [][]int) int {
    ans := len(edges)
    alice, bob := newUnionFind(n), newUnionFind(n)
    for _, e := range edges {
        x, y := e[1]-1, e[2]-1
        if e[0] == 3 && (!alice.inSameSet(x, y) || !bob.inSameSet(x, y)) {
            // 保留这条公共边
            alice.union(x, y)
            bob.union(x, y)
            ans--
        }
    }
    uf := [2]*unionFind{alice, bob}
    for _, e := range edges {
        if tp := e[0]; tp < 3 && uf[tp-1].union(e[1]-1, e[2]-1) {
            // 保留这条独占边
            ans--
        }
    }
    if alice.setCount > 1 || bob.setCount > 1 {
        return -1
    }
    return ans
}
```

**[778. 水位上升的泳池中游泳](https://leetcode.cn/problems/swim-in-rising-water/description/)**

**思路**

核心思路是二分+并查集连通查询

**代码**
```go

func swimInWater(grid [][]int) int {
	n := len(grid)
	total := n * n
	left, right := 0, total
	for left <= right {
		mid := left + (right-left)/2
		if validateMid(grid, total, mid) {
			right = mid - 1
		} else {
			left = mid + 1
		}
	}
	return left
}

func validateMid(grid [][]int, total, mid int) bool {
	union := Constructor778(total)
	for i := range grid {
		for j := range grid[i] {
			if i == 0 && j == 0 {
				continue
			}
			if grid[i][j] > mid {
				continue
			}
			ni, nj := i, j-1
			//左
			if 0 <= nj && nj < len(grid) && grid[ni][nj] <= mid {
				union.union(getIndex(ni, nj, len(grid)), getIndex(i, j, len(grid)))
			}

			ni, nj = i-1, j
			//上
			if 0 <= ni && ni < len(grid) && grid[ni][nj] <= mid {
				union.union(getIndex(ni, nj, len(grid)), getIndex(i, j, len(grid)))
			}
		}
	}
	return union.find(0) == union.find(total-1)
}

func getIndex(i, j, n int) int {
	return i*n + j
}

type UnionFind778 struct {
	parent []int
}

func Constructor778(total int) *UnionFind778 {
	p := make([]int, total)
	for i := range p {
		p[i] = i
	}
	return &UnionFind778{parent: p}
}

func (u *UnionFind778) union(x, y int) {
	xp := u.find(x)
	yp := u.find(y)
	if xp == yp {
		return
	}
	u.parent[xp] = yp
}

func (u *UnionFind778) find(x int) int {
	root := x
	for root != u.parent[root] {
		root = u.parent[root]
	}
	//compress
	i, j := x, 0
	for root != u.parent[i] {
		j = u.parent[i]
		u.parent[i] = root
		i = j
	}
	return root
}
```

### **[1632. 矩阵转换后的秩](https://leetcode.cn/problems/rank-transform-of-a-matrix/description/)**

**思路**

这一题的翻译不太对，应该是排名，矩阵的秩有固定含义的。

这一题最开始的思路肯定是每个元素排序，最小的元素用1，后面递增，然后考虑第二小的元素能不能也用1，如果他们之间没有行和列的交集，并且第二小的元素在行和列中也是排最小的，就可以使用1，这里我们就需要记录行和列的当前最大的序列了。此外考虑多个相同值的行列影响，我们需要用并查集来构建连通，查询到最大的序列可用数。

**代码**
```go
type unionFind struct {
	p, size []int
}

func newUnionFind(n int) *unionFind {
	p := make([]int, n)
	size := make([]int, n)
	for i := range p {
		p[i] = i
		size[i] = 1
	}
	return &unionFind{p, size}
}

func (uf *unionFind) find(x int) int {
	if uf.p[x] != x {
		uf.p[x] = uf.find(uf.p[x])
	}
	return uf.p[x]
}

func (uf *unionFind) union(a, b int) {
	pa, pb := uf.find(a), uf.find(b)
	if pa != pb {
		if uf.size[pa] > uf.size[pb] {
			uf.p[pb] = pa
			uf.size[pa] += uf.size[pb]
		} else {
			uf.p[pa] = pb
			uf.size[pb] += uf.size[pa]
		}
	}
}

func (uf *unionFind) reset(x int) {
	uf.p[x] = x
	uf.size[x] = 1
}

func matrixRankTransform(matrix [][]int) [][]int {
	m, n := len(matrix), len(matrix[0])
	type pair struct{ i, j int }
	d := map[int][]pair{}
	for i, row := range matrix {
		for j, v := range row {
			d[v] = append(d[v], pair{i, j})
		}
	}
	rowMax := make([]int, m)
	colMax := make([]int, n)
	ans := make([][]int, m)
	for i := range ans {
		ans[i] = make([]int, n)
	}
	vs := []int{}
	for v := range d {
		vs = append(vs, v)
	}
	sort.Ints(vs)
	uf := newUnionFind(m + n)
	rank := make([]int, m+n)
	for _, v := range vs {
		ps := d[v]
		for _, p := range ps {
			uf.union(p.i, p.j+m)
		}
		for _, p := range ps {
			i, j := p.i, p.j
			rank[uf.find(i)] = max(rank[uf.find(i)], max(rowMax[i], colMax[j]))
		}
		for _, p := range ps {
			i, j := p.i, p.j
			ans[i][j] = 1 + rank[uf.find(i)]
			rowMax[i], colMax[j] = ans[i][j], ans[i][j]
		}
		for _, p := range ps {
			uf.reset(p.i)
			uf.reset(p.j + m)
		}
	}
	return ans
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}
```

### **[2382. 删除操作后的最大子段和](https://leetcode.cn/problems/maximum-segment-sum-after-removals/description/)**

**思路**

很明显，删除不好处理，我们就逆向思维，添加处理

这样就有一个问题，如何用并查集关联2个子段，这里我们选择向右看齐，一个原因是可以利用初始化并查集的数组大小加1来提供一个虚拟的右边头结点方便关联

**代码**
```go
func maximumSegmentSum(nums []int, removeQueries []int) (ans []int64) {
	n := len(nums)
	fa := make([]int, n+1)
	for i := range fa {
		fa[i] = i
	}
	sum := make([]int64, n+1)
	var find func(int) int
	find = func(x int) int {
		if fa[x] != x {
			fa[x] = find(fa[x])
		}
		return fa[x]
	}

	ans = make([]int64, n)
	for i := n - 1; i > 0; i-- {
		x := removeQueries[i]
		to := find(x + 1)
		fa[x] = to // 合并 x 和 x+1
		sum[to] += sum[x] + int64(nums[x])
		ans[i-1] = max(ans[i], sum[to])
	}
	return
}

func max(a, b int64) int64 { if b > a { return b }; return a }
```

### **[928. 尽量减少恶意软件的传播 II](https://leetcode.cn/problems/minimize-malware-spread-ii/description/)**

**思路**

硬破解的思路很简单，就是从初始污染节点一个个试试，看看去除哪个会导致污染最少，但这样的时间复杂度很高，如何快速实现判断？

思路是用并查集，将污染节点无关的节点都连接起来，然后针对每个污染节点去看看每个污染节点可以链接的连通分量个数和数量，最后判断影响最大的就是结果了

**代码**

```go
type unionFind struct {
	p, size []int
}

func newUnionFind(n int) *unionFind {
	p := make([]int, n)
	size := make([]int, n)
	for i := range p {
		p[i] = i
		size[i] = 1
	}
	return &unionFind{p, size}
}

func (uf *unionFind) find(x int) int {
	if uf.p[x] != x {
		uf.p[x] = uf.find(uf.p[x])
	}
	return uf.p[x]
}

func (uf *unionFind) union(a, b int) bool {
	pa, pb := uf.find(a), uf.find(b)
	if pa == pb {
		return false
	}
	if uf.size[pa] > uf.size[pb] {
		uf.p[pb] = pa
		uf.size[pa] += uf.size[pb]
	} else {
		uf.p[pa] = pb
		uf.size[pb] += uf.size[pa]
	}
	return true
}

func (uf *unionFind) getSize(root int) int {
	return uf.size[root]
}

func minMalwareSpread(graph [][]int, initial []int) int {
	n := len(graph)
	s := make([]bool, n)
	for _, i := range initial {
		s[i] = true
	}
	uf := newUnionFind(n)
	for i := range graph {
		if !s[i] {
			for j := i + 1; j < n; j++ {
				if graph[i][j] == 1 && !s[j] {
					uf.union(i, j)
				}
			}
		}
	}
	g := make([]map[int]bool, n)
	for _, i := range initial {
		g[i] = map[int]bool{}
	}
	cnt := make([]int, n)
	for _, i := range initial {
		for j := 0; j < n; j++ {
			if !s[j] && graph[i][j] == 1 {
				g[i][uf.find(j)] = true
			}
		}
		for root := range g[i] {
			cnt[root]++
		}
	}
	ans, mx := 0, -1
	for _, i := range initial {
		t := 0
		for root := range g[i] {
			if cnt[root] == 1 {
				t += uf.getSize(root)
			}
		}
		if t > mx || t == mx && i < ans {
			ans, mx = i, t
		}
	}
	return ans
}
```

### **[1970. 你能穿过矩阵的最后一天](https://leetcode.cn/problems/last-day-where-you-can-still-cross/description/)**

**思路**

首先明确核心思路就是逆向的从最后一天开始判断是否存在联通，这里有一个小技巧就是增加top和bottom两个虚拟节点，方便判断是否上下联通了。


**代码**

```go
var dir4 = []struct{ x, y int }{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}

func latestDayToCross(row, col int, cells [][]int) int {
	top := row * col
	bottom := top + 1
	uf := newUnionFind(bottom + 1)
	land := make([][]bool, row)
	for i := range land {
		land[i] = make([]bool, col)
	}
	// 倒序遍历天数，如果最上和最下连通了，这一天就是答案
	for day := len(cells) - 1; ; day-- {
		p := cells[day]
		r, c := p[0]-1, p[1]-1
		v := r*col + c
		for _, d := range dir4 {
			if x, y := r+d.x, c+d.y; 0 <= x && x < row && 0 <= y && y < col && land[x][y] { // 与四周的陆地相连
				uf.merge(v, x*col+y)
			}
		}
		land[r][c] = true // 将该位置标记为陆地
		if r == 0 {
			uf.merge(v, top) // 与最上面相连
		} else if r == row-1 {
			uf.merge(v, bottom) // 与最下面相连
		}
		if uf.same(top, bottom) {
			return day // 最上和最下连通了，返回答案
		}
	}
}

// 并查集模板
type uf struct {
	fa []int
}

func newUnionFind(n int) uf {
	fa := make([]int, n)
	for i := range fa {
		fa[i] = i
	}
	return uf{fa}
}

func (u uf) find(x int) int {
	if u.fa[x] != x {
		u.fa[x] = u.find(u.fa[x])
	}
	return u.fa[x]
}

func (u uf) merge(from, to int) {
	x, y := u.find(from), u.find(to)
	if x != y {
		u.fa[x] = y
	}
}

func (u uf) same(x, y int) bool {
	return u.find(x) == u.find(y)
}
```