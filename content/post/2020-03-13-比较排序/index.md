+++
title="比较排序"
tags=["算法","比较排序"]
categories=["算法"]
date="2020-03-13T05:07:00+08:00"
summary = '比较排序'
toc=false
+++

不稳定排序算法
==============

希尔排序
--------

平均时间复杂度`O(n^1.3)` 最好时间复杂度`O(n)` 最坏时间复杂度`O(n^2)` 空间复杂度`O(1)`

```go
func ShellSort(a []int, n int) {
	dk := n / 2
	for dk >= 1 {
		shellInsertSort(a, n, dk)
		dk /= 2
	}
}
func shellInsertSort(a []int, n int, dk int) {
	for i := dk; i < n; i += dk {
		if a[i] < a[i-dk] {
			j := i - dk
			x := a[i]
			a[i] = a[i-dk]
			for j >= 0 && x < a[j] {
				a[j+dk] = a[j]
				j -= dk
			}
			a[j+dk] = x
		}
	}
}
```

简单选择排序
------------

平均时间复杂度`O(n^2)` 最好时间复杂度`O(n^2)` 最坏时间复杂度`O(n^2)` 空间复杂度`O(1)`

```go
func SelectSort(a []int, n int) {
	for i := 0; i < n; i++ {
		key := i
		for j := i + 1; j < n; j++ {
			if a[key] > a[j] {
				key = j
			}
		}
		if key != i {
			tmp := a[i]
			a[i] = a[key]
			a[key] = tmp
		}
	}
}
```

堆排序
------

平均时间复杂度`O(nlogn)` 最好时间复杂度`O(nlogn)` 最坏时间复杂度`O(nlogn)` 空间复杂度`O(1)`

```go
func HeapSort(a []int, n int) {
	buildingHeap(a, n)
	for i := n - 1; i > 0; i-- {
		a[0], a[i] = a[i], a[0]
		heapAdjust(a, 0, i)
	}
}

func heapAdjust(a []int, s int, n int) {
	child := 2*s + 1
	for child < n {
		if child+1 < n && a[child] > a[child+1] {
			child++
		}
		if a[s] > a[child] {
			a[s], a[child] = a[child], a[s]
			s = child
			child = 2*s + 1
		} else {
			break
		}
	}
}
func buildingHeap(a []int, n int) {
	for i := (n - 1) / 2; i >= 0; i-- {
		heapAdjust(a, i, n)
	}
}
```

快速排序
--------

平均时间复杂度`O(nlogn)` 最好时间复杂度`O(nlogn)` 最坏时间复杂度`O(n^2)` 空间复杂度`O(nlogn)`

```go
func QuickSort(a []int, l int, r int) {
	if l < r {
		i, j, x := l, r, a[l]
		for i < j {
			for i < j && a[j] >= x {
				j--
			}
			if i < j {
				a[i] = a[j]
				i++
			}
			for i < j && a[i] < x {
				i++
			}
			if i < j {
				a[j] = a[i]
				j--
			}
		}
		a[i] = x
		QuickSort(a, l, i-1)
		QuickSort(a, i+1, r)
	}
}
```

稳定排序算法
============

冒泡排序
--------

平均时间复杂度`O(n^2)` 最好时间复杂度`O(n)` 最坏时间复杂度`O(n^2)` 空间复杂度`O(1)`

```go
func BubbleSort(a []int, n int) {
	for i := 0; i < n-1; i++ {
		for j := 0; j < n-i-1; j++ {
			if a[j] > a[j+1] {
				tmp := a[j]
				a[j] = a[j+1]
				a[j+1] = tmp
			}
		}
	}
}
```

直接插入排序
------------

平均时间复杂度`O(n^2)` 最好时间复杂度`O(n)` 最坏时间复杂度`O(n^2)` 空间复杂度`O(1)`

```go
func InsertSort(a []int, n int) {
	for i := 1; i < n; i++ {
		if a[i] < a[i-1] {
			j := i - 1
			x := a[i]
			a[i] = a[i-1]
			for j >= 0 && x < a[j] {
				a[j+1] = a[j]
				j--
			}
			a[j+1] = x
		}
	}
}
```

归并排序
--------

平均时间复杂度`O(nlogn)` 最好时间复杂度`O(nlogn)` 最坏时间复杂度`O(nlogn)` 空间复杂度`O(n)`

```go
func MergeSort(a []int,f int,l int, tmp []int) {
	if f<l {
		mid := (f+l)/2
		MergeSort(a,f,mid,tmp)
		MergeSort(a,mid+1,l,tmp)
		mergeArray(a,f,mid,l,tmp)
	}
}
func mergeArray(a []int,f int, mid int,l int, tmp []int) { i:= f j:= mid+1
	m := mid
	n := l
	k := 0
	for i<=m && j<=n {
		if a[i]<=a[j]{
			tmp[k] = a[i]
			k++
			i++
		} else {
			tmp[k] = a[j]
			k++
			j++
		}
	}
	for i<=m{
		tmp[k] = a[i]
		k++
		i++
	}
	for j<=n{
		tmp[k] = a[j]
		k++
		j++
	}
	for i:=0;i<k;i++{
		a[f+i] = tmp[i]
	}
}
```

