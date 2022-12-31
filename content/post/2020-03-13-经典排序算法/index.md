+++
title="经典排序算法"
date="2020-03-13T05:06:00+08:00"
categories=["算法&数据结构"]
summary = '经典排序算法'
toc=false
+++

### 经典排序算法学习

#### 算法|平均时间复杂度|最好时间复杂度|最坏时间复杂度|空间复杂度

#### 希尔排序|O(n^1.3)|O(n)|O(n^2)|O(1)

```
void ShellInsertSort(int a[], int n, int dk)  
{
    for(int i= dk; i<n; i+=dk){
        if(a[i] < a[i-dk]){      //若第i个元素大于i-1元素，直接插入。小于的话，移动有序表后插入
            int j = i-dk;     
            int x = a[i];//复制为哨兵，即存储待排序元素  
            a[i] = a[i-dk];//首先后移一个元素  
            while(j>=0&&x < a[j]){//查找在有序表的插入位置  
                a[j+dk] = a[j];  
                j -= dk;//元素后移  
            }  
            a[j+dk] = x;//插入到正确位置  
        }
    } 
}
/** 
 * 先按增量d（n/2,n为要排序数的个数进行希尔排序)
 * 
 */  
void shellSort(int a[], int n){
    int dk = n/2;  
    while(dk >= 1){  
        ShellInsertSort(a, n, dk);  
        dk = dk/2;  
    }
}
```

#### 简单选择排序|O(n^2)|O(n^2)|O(n^2)|O(1)

```
void selectSort(int a[], int n){  
    int key, tmp;  
    for(int i = 0; i< n; ++i) {  
        //选择最小的元素
		int key = i;  
		for(int j=i+1 ;j< n; ++j) {  
			if(a[key] > a[j]) key = j;  
		}
        if(key != i){  
            tmp = a[i];  
			a[i] = a[key]; 
			a[key] = tmp; //最小元素与第i位置元素互换  
        }
    }  
}
```

#### 堆排序|O(nlogn)|O(nlogn)|O(nlogn)|O(1)

```
void HeapAdjust(int H[],int s, int length)  
{  
    int tmp  = H[s];  
    int child = 2*s+1; //左孩子结点的位置。(i+1 为当前调整结点的右孩子结点的位置)  
    while(child < length){  
        if(child+1 <length && H[child]<H[child+1]) { // 如果右孩子大于左孩子(找到比当前待调整结点大的孩子结点)  
            ++child ;  
        }
        if(tmp<H[child]){  // 如果较大的子结点大于父结点  
            H[s] = H[child]; // 那么把较大的子结点往上移动，替换它的父结点
            s = child;       // 重新设置s ,即待调整的下一个结点的位置  
            child = 2*s+1;  
        }else{            // 如果当前待调整结点大于它的左右孩子，则不需要调整，直接退出
			break;  
        } } H[s]=tmp;
}  
  
  
/** 
 * 初始堆进行调整 
 * 将H[0..length-1]建成堆 复杂度O(N)
 * 调整完之后第一个元素是序列的最小的元素 
 */  
void BuildingHeap(int H[], int length)  
{   
    //最后一个有孩子的节点的位置 i=  (length -1) / 2  
    for (int i = (length -1) / 2 ; i >= 0; --i)  
        HeapAdjust(H,i,length);  
}  
/** 
 * 堆排序算法 
 */  
void HeapSort(int H[],int length)  
{  
    //初始堆  
    BuildingHeap(H, length);  
    //从最后一个元素开始对序列进行调整  
    for (int i = length - 1; i > 0; --i)  
    {  
        //交换堆顶元素H[0]和堆中最后一个元素  
        int temp = H[i]; H[i] = H[0]; H[0] = temp;  
        //每次交换堆顶元素和堆中最后一个元素之后，都要对堆进行调整  
        HeapAdjust(H,0,i);  
	}  
}
```

#### 快速排序|O(nlogn)|O(nlogn)|O(n^2)|O(nlogn)

```
void quick_sort(int s[], int l, int r)  
{  
    if (l < r)  
    {  
        int i = l, j = r, x = s[l];  
        while (i < j)  
        {  
            while(i < j && s[j] >= x) // 从右向左找第一个小于x的数  
                j--;    
            if(i < j)   
                s[i++] = s[j];  
              
            while(i < j && s[i] < x) // 从左向右找第一个大于等于x的数  
                i++;    
            if(i < j)   
                s[j--] = s[i];  
        }  
        s[i] = x;  
        quick_sort(s, l, i - 1); // 递归调用   
        quick_sort(s, i + 1, r);  
    }  
} 
```

### 稳定算法——基冒插归

#### 基数排序

基数排序的方式可以采用LSD（Least sgnificant digital）或MSD（Most sgnificant digital），LSD的排序方式由键值的最右边开始，而MSD则相反，由键值的最左边开始。 以LSD为例，假设原来有一串数值如下所示：

```
73, 22, 93, 43, 55, 14, 28, 65, 39, 81 
```

首先根据个位数的数值，在走访数值时将它们分配至编号0到9的桶子中：

```
　　0 
　　1 81 
　　2 22 
　　3 73 93 43 
　　4 14 
　　5 55 65 
　　6 
　　7 
　　8 28 
　　9 39 
```

接下来将这些桶子中的数值重新串接起来，成为以下的数列： 81, 22, 73, 93, 43, 14, 55, 65, 28, 39 接着再进行一次分配，这次是根据十位数来分配：

```
　　0 
　　1 14 
　　2 22 28 
　　3 39 
　　4 43 
　　5 55 
　　6 65 
　　7 73 
　　8 81 
　　9 93 
```

接下来将这些桶子中的数值重新串接起来，成为以下的数列：

```
14, 22, 28, 39, 43, 55, 65, 73, 81, 93 
```

这时候整个数列已经排序完毕；如果排序的对象有三位数以上，则持续进行以上的动作直至最高位数为止。 　　LSD的基数排序适用于位数小的数列，如果位数多的话，使用MSD的效率会比较好，MSD的方式恰与LSD相反，是由高位数为基底开始进行分配，其他的演算方式则都相同。

#### 冒泡排序|O(n^2)|O(n)|O(n^2)|O(1)

```
void bubbleSort(int a[], int n){  
    for(int i =0 ; i< n-1; ++i) {  
        for(int j = 0; j < n-i-1; ++j) {  
            if(a[j] > a[j+1])  
            {  
                int tmp = a[j] ; 
				a[j] = a[j+1] ;  
				a[j+1] = tmp;  
            }  
        }  
    }  
}
```

#### 直接插入排序|O(n^2)|O(n)|O(n^2)|O(1)

```
void InsertSort(int a[], int n)  
{  
    for(int i= 1; i<n; i++){  
        if(a[i] < a[i-1]){               //若第i个元素大于i-1元素，直接插入。
		//小于的话，移动有序表后插入  
            int j= i-1;   
            int x = a[i];//复制为哨兵，即存储待排序元素  
            a[i] = a[i-1];//先后移一个元素  
            while(j>=0&&x < a[j]){//查找在有序表的插入位置  
                a[j+1] = a[j];  
                j--;//元素后移  
            }  
            a[j+1] = x;//插入到正确位置  
        }  
    }
}
```

#### 归并排序|O(nlogn)|O(nlogn)|O(nlogn)|O(n)

```
void mergearray(int a[], int first, int mid, int last, int temp[])  
{  
    int i = first, j = mid + 1;  
    int m = mid,   n = last;  
    int k = 0;  
      
    while (i <= m && j <= n)  
    {  
        if (a[i] <= a[j])  
            temp[k++] = a[i++];  
        else  
            temp[k++] = a[j++];  
    }  
      
    while (i <= m)  
        temp[k++] = a[i++];  
      
    while (j <= n)  
        temp[k++] = a[j++];  
      
    for (i = 0; i < k; i++)  
        a[first + i] = temp[i];  
}  
void mergesort(int a[], int first, int last, int temp[])  
{  
    if (first < last)  
    {  
        int mid = (first + last) / 2;  
        mergesort(a, first, mid, temp);    //左边有序  
        mergesort(a, mid + 1, last, temp); //右边有序  
        mergearray(a, first, mid, last, temp); 
        //再将二个有序数列合并  
    }  
}
bool MergeSort(int a[], int n)  
{  
    int *p = new int[n];  
    if (p == NULL)  
        return false;  
    mergesort(a, 0, n - 1, p);  
    delete[] p;  
    return true;  
} 
```

