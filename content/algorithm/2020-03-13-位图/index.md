+++
title="位图"
tags=["算法","位图"]
categories=["算法"]
date="2020-03-13T06:42:00+08:00"
summary = '位图'
toc=false
+++

位图
----

所谓的BitMap就是用一个bit位来标记某个元素所对应的value，而key即是该元素，由于BitMap使用了bit位来存储数据，因此可以大大节省存储空间。

### 位操作

#### 移位

对于正整数，左移一位，就是将数值乘2；右移一位就运算数值除2；但是位操作的效率要比运算符高。

##### 判断奇偶

```go
func isOdd(n int) bool {
	return n&1 != 0
}
```

#### 异或操作

一个数和另一个数异或两次返回原来的数

```go
//不用临时变量，交换a,b两个数
a = a ^ b
b = a ^ b
a = a ^ b
```

#### n&(-n)

该操作返回n的最后0的个数k的2次方 计算机里整数使用源码表示，负数使用补码表示

```go
//int8(10)二进制为
1010
//int8(-10)二进制表示
//先求反码，原码取反
11110101
//再求补码，反码+1
11110110
//n&(-n)
00001010
11110110
00000010
```

#### n&(n-1)

该操作将n的最后一位变为0

##### 统计一个整数n的二进制中1的个数

```go
func count(n int) int {
	ret := 0
	for n > 0 {
		n = n & (n - 1)
		ret++
	}
	return ret
}
```

##### 判断一个整数是不是2的幂

```go
func Is2Pow(n int) bool {
	return n&(n-1) == 0
}
```

##### 判断一个整数是不是4的幂

```go
func Is4Pow(n int32) bool {
	if n&(n-1) != 0 {
		if (n & 0x55555555) == 0 {
			return true
		}
	}
	return false
}
```

##### 判断两个整数m和n，需要改变多少位使得m变为n

```go
func Count(m, n int) int {
	//异或，算出两个之间的不同位个数
	m = m ^ n
	//统计一下不同个数
	ret := 0
	for m > 0 {
		m = m & (m - 1)
		ret++
	}
	return ret
}
```

##### 不适用+,-,*,/完成整数相加

```go
func Add(n, m uint) uint {
	sum, c := 0, 0
	if m == 0 {
		return n
	}
	if n == 0 {
		return m
	}
	for m != 0 {
		sum = n ^ m
		c = (n & m) << 1
		n = sum
		m = c
	}
	return sum
}
```

### bitmap

[github上较为欢迎的bitmap实现](https://github.com/willf/bitset/blob/master/bitset.go)

```go
package bitset

import (
	"bufio"
	"bytes"
	"encoding/base64"
	"encoding/binary"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"strconv"
)

const wordSize = uint(64)

const log2WordSize = uint(6)

const allBits uint64 = 0xffffffffffffffff

var binaryOrder binary.ByteOrder = binary.BigEndian

var base64Encoding = base64.URLEncoding

func Base64StdEncoding() { base64Encoding = base64.StdEncoding }

func LittleEndian() { binaryOrder = binary.LittleEndian }

//bitset的结构
type BitSet struct {
	length uint
	set    []uint64
}

type Error string

func (b *BitSet) safeSet() []uint64 {
	if b.set == nil {
		b.set = make([]uint64, wordsNeeded(0))
	}
	return b.set
}

func From(buf []uint64) *BitSet {
	return &BitSet{uint(len(buf)) * 64, buf}
}

func (b *BitSet) Bytes() []uint64 {
	return b.set
}

//计算大小为i需要多少个64位存储
func wordsNeeded(i uint) int {
	if i > (Cap() - wordSize + 1) {
		return int(Cap() >> log2WordSize)
	}
	return int((i + (wordSize - 1)) >> log2WordSize)
}

func New(length uint) (bset *BitSet) {
	defer func() {
		if r := recover(); r != nil {
			bset = &BitSet{
				0,
				make([]uint64, 0),
			}
		}
	}()

	bset = &BitSet{
		length,
		make([]uint64, wordsNeeded(length)),
	}

	return bset
}

//返回最大值
func Cap() uint {
	return ^uint(0)
}

//返回bitset的存储长度
func (b *BitSet) Len() uint {
	return b.length
}

//扩展
func (b *BitSet) extendSetMaybe(i uint) {
	if i >= b.length {
		nsize := wordsNeeded(i + 1)
		if b.set == nil {
			b.set = make([]uint64, nsize)
		} else if cap(b.set) >= nsize {
			b.set = b.set[:nsize]
		} else if len(b.set) < nsize {
			newset := make([]uint64, nsize, 2*nsize) // increase capacity 2x
			copy(newset, b.set)
			b.set = newset
		}
		b.length = i + 1
	}
}

//测试bitset里面第i位是否为1
func (b *BitSet) Test(i uint) bool {
	if i >= b.length {
		return false
	}
	//i除以64得到set中的下标,接着应该取i%64的左移1的位置
	//i&(wordSize-1)即表示了i%64
	return b.set[i>>log2WordSize]&(1<<(i&(wordSize-1))) != 0
}

//设置第i位为1
func (b *BitSet) Set(i uint) *BitSet {
	b.extendSetMaybe(i)
	b.set[i>>log2WordSize] |= 1 << (i & (wordSize - 1))
	return b
}

//清除第i位，设置第i位为0
func (b *BitSet) Clear(i uint) *BitSet {
	if i >= b.length {
		return b
	}
	b.set[i>>log2WordSize] &^= 1 << (i & (wordSize - 1))
	return b
}

//设置第i位的值
func (b *BitSet) SetTo(i uint, value bool) *BitSet {
	if value {
		return b.Set(i)
	}
	return b.Clear(i)
}

//反转第i位，如果没有则视为0，扩容后设置为1
func (b *BitSet) Flip(i uint) *BitSet {
	if i >= b.length {
		return b.Set(i)
	}
	b.set[i>>log2WordSize] ^= 1 << (i & (wordSize - 1))
	return b
}

//缩放成length的长度bitset
func (b *BitSet) Shrink(length uint) *BitSet {
	idx := wordsNeeded(length + 1)
	if idx > len(b.set) {
		//已经小于length的长度，则直接返回
		return b
	}
	shrunk := make([]uint64, idx)
	copy(shrunk, b.set[:idx])
	b.set = shrunk
	b.length = length + 1
	//最后一个64位的几位必须保持不变
	b.set[idx-1] &= (allBits >> (uint64(64) - uint64(length&(wordSize-1)) - 1))
	return b
}

//idx的位置插入一位0值
func (b *BitSet) InsertAt(idx uint) *BitSet {
	insertAtElement := (idx >> log2WordSize)

	//查看bitset的长度是否64的整数倍，如果是，则没有多余的1位可以往后移动
	//需要加一个64位
	if b.isLenExactMultiple() {
		b.set = append(b.set, uint64(0))
	}

	var i uint
	//从后往前，移动
	//处理idx对应64位之前的64位
	for i = uint(len(b.set) - 1); i > insertAtElement; i-- {
		//左移一位
		b.set[i] <<= 1
		//前一个64位的最头上一位补在这个64位的最后
		b.set[i] |= (b.set[i-1] & 0x8000000000000000) >> 63
	} //生成掩码，idx对应位置之后的全为0 //i=5则对应oxfffffffffffffff0
	dataMask := ^(uint64(1)<<uint64(idx&(wordSize-1)) - 1)
	//拿到要处理的64位的idx之前的数据
	data := b.set[i] & dataMask
	//idx位置对应的后面数据不变化,前面的全部置为0
	b.set[i] &= ^dataMask
	//data左移一位，数据放回
	//处理完idx对应的64位
	b.set[i] |= data << 1
	//length+1因为idx位置插入了一位
	b.length++
	return b
}

//字符串化
func (b *BitSet) String() string {
	// follows code from https://github.com/RoaringBitmap/roaring
	var buffer bytes.Buffer
	start := []byte("{")
	buffer.Write(start)
	counter := 0
	i, e := b.NextSet(0)
	for e {
		counter = counter + 1
		//太多了用...代替，避免溢出
		if counter > 0x40000 {
			buffer.WriteString("...")
			break
		}
		buffer.WriteString(strconv.FormatInt(int64(i), 10))
		i, e = b.NextSet(i + 1)
		if e {
			buffer.WriteString(",")
		}
	}
	buffer.WriteString("}")
	return buffer.String()
}

func (b *BitSet) DeleteAt(i uint) *BitSet {
	//找到对应i处理的64位
	deleteAtElement := i >> log2WordSize //生成掩码，这里i对应位置之前的都是1 //i=5对应为oxffffffffffffffff0
	dataMask := ^((uint64(1) << (i & (wordSize - 1))) - 1)
	//获取原来的数据，去除i对应位置之后的
	data := b.set[deleteAtElement] & dataMask
	//i对应位置之后的不变其他都为0了
	b.set[deleteAtElement] &= ^dataMask
	//data右移，剔除i对应的数据，然后做或运算，数据回传
	//这里好像不用再&dataMask
	b.set[deleteAtElement] |= (data >> 1) & dataMask
	//处理后面的64位
	for i := int(deleteAtElement) + 1; i < len(b.set); i++ {
		//前一个64位的最高位设置成后一个64位的最低位
		b.set[i-1] |= (b.set[i] & 1) << 63
		//右移一位，因为最低的已经设置到前一个64位数据上了
		b.set[i] >>= 1
	}
	//长度减一
	b.length = b.length - 1
	return b
}

//返回下一个非0的位置
func (b *BitSet) NextSet(i uint) (uint, bool) {
	//确定数组下标
	x := int(i >> log2WordSize)
	//不存在，返回0,false
	if x >= len(b.set) {
		return 0, false
	}
	//拿出这个64位元素
	w := b.set[x]
	//右移，剔除i和i之前的位
	w = w >> (i & (wordSize - 1))
	if w != 0 {
		//不为0，则该元素上存在剩余不为0的数据
		//返回下一个不为0的位置，即w的末尾0的个数的2次方+i
		//求末尾0的个数的2次方，即n&(-n)
		return i + trailingZeroes64(w), true
	}
	//w等于0了，则说明下一位在下一个64元素上
	x = x + 1
	//for循环找下一个不为0的64位元素
	for x < len(b.set) {
		if b.set[x] != 0 {
			//返回下一个不为0的位置
			return uint(x)*wordSize + trailingZeroes64(b.set[x]), true
		}
		x = x + 1

	}
	//没有，返回0,false
	return 0, false
}

//一次获取多个位置
func (b *BitSet) NextSetMany(i uint, buffer []uint) (uint, []uint) {
	myanswer := buffer
	capacity := cap(buffer)
	//i对应的下标x
	x := int(i >> log2WordSize)
	//超出范围，直接返回空的
	if x >= len(b.set) || capacity == 0 {
		return 0, myanswer[:0]
	}
	//需要跳过的字节
	skip := i & (wordSize - 1)
	word := b.set[x] >> skip
	myanswer = myanswer[:capacity]
	size := int(0)
	for word != 0 {
		//r为末尾连续0的个数
		r := trailingZeroes64(word)
		//t = 2^r
		t := word & ((^word) + 1)
		//存入数组
		myanswer[size] = r + i
		size++
		if size == capacity {
			goto End
		}
		//清空最后一位1
		word = word ^ t
	}
	x++
	for idx, word := range b.set[x:] {
		for word != 0 {
			r := trailingZeroes64(word)
			t := word & ((^word) + 1)
			myanswer[size] = r + (uint(x+idx) << 6)
			size++
			if size == capacity {
				goto End
			}
			word = word ^ t
		}
	}
End:
	if size > 0 {
		return myanswer[size-1], myanswer[:size]
	}
	return 0, myanswer[:0]
}

//返回下一个清除位置，即返回下一个0的位置
func (b *BitSet) NextClear(i uint) (uint, bool) {
	//i对应的下标x
	x := int(i >> log2WordSize)
	//x不存在
	if x >= len(b.set) {
		return 0, false
	}
	//取出
	w := b.set[x]
	//移动i对应多余位
	w = w >> (i & (wordSize - 1))
	//判断是否剩余全是1
	wA := allBits >> (i & (wordSize - 1))
	//跳过连续的1后的位置
	index := i + trailingZeroes64(^w)
	//还在这个64位中，则返回
	if w != wA && index < b.length {
		return index, true
	}
	x++
	for x < len(b.set) {
		index = uint(x)*wordSize + trailingZeroes64(^b.set[x])
		if b.set[x] != allBits && index < b.length {
			return index, true
		}
		x++
	}
	return 0, false
}

//清空所有位置
func (b *BitSet) ClearAll() *BitSet {
	if b != nil && b.set != nil {
		for i := range b.set {
			b.set[i] = 0
		}
	}
	return b
}

//返回bitset的64字节的个数
func (b *BitSet) wordCount() int {
	return len(b.set)
}

//复制当前bitset
func (b *BitSet) Clone() *BitSet {
	c := New(b.length)
	if b.set != nil {
		copy(c.set, b.set)
	}
	return c
}

//拷贝c位图到当前bitset
func (b *BitSet) Copy(c *BitSet) (count uint) {
	if c == nil {
		return
	}
	if b.set != nil { // Copy should not modify current object
		copy(c.set, b.set)
	}
	count = c.length
	if b.length < c.length {
		count = b.length
	}
	return
}

//返回所有1的个数
func (b *BitSet) Count() uint {
	if b != nil && b.set != nil {
		return uint(popcntSlice(b.set))
	}
	return 0
}

//判断位图是否相等
func (b *BitSet) Equal(c *BitSet) bool {
	if c == nil {
		return false
	}
	if b.length != c.length {
		return false
	}
	if b.length == 0 {
		return true
	}
	for p, v := range b.set {
		if c.set[p] != v {
			return false
		}
	}
	return true
}

func panicIfNull(b *BitSet) {
	if b == nil {
		panic(Error("BitSet must not be null"))
	}
}

//&^操作，相异的保留，相同的清除
//compare中和当前bitset不同的位保留在新位图中返回
func (b *BitSet) Difference(compare *BitSet) (result *BitSet) {
	panicIfNull(b)
	panicIfNull(compare)
	result = b.Clone() // clone b (in case b is bigger than compare)
	//compare的64位数组大小
	l := int(compare.wordCount())
	//找两个之间的数组长度小的
	if l > int(b.wordCount()) {
		l = int(b.wordCount())
	}
	for i := 0; i < l; i++ {
		//清空compare中有1的，存入result
		result.set[i] = b.set[i] &^ compare.set[i]
	}
	return
}

//返回当前位图和其他位图之间不同位的个数
func (b *BitSet) DifferenceCardinality(compare *BitSet) uint {
	panicIfNull(b)
	panicIfNull(compare)
	l := int(compare.wordCount())
	if l > int(b.wordCount()) {
		l = int(b.wordCount())
	}
	cnt := uint64(0)
	cnt += popcntMaskSlice(b.set[:l], compare.set[:l])
	cnt += popcntSlice(b.set[l:])
	return uint(cnt)
}

//直接把compare中和当前bitset不同的保留，相同的清空
func (b *BitSet) InPlaceDifference(compare *BitSet) {
	panicIfNull(b)
	panicIfNull(compare)
	l := int(compare.wordCount())
	if l > int(b.wordCount()) {
		l = int(b.wordCount())
	}
	for i := 0; i < l; i++ {
		b.set[i] &^= compare.set[i]
	}
}

//按长度交换
func sortByLength(a *BitSet, b *BitSet) (ap *BitSet, bp *BitSet) {
	if a.length <= b.length {
		ap, bp = a, b
	} else {
		ap, bp = b, a
	}
	return
}

//两个位图相与操作，放回的新位图是两者中小的长度
func (b *BitSet) Intersection(compare *BitSet) (result *BitSet) {
	panicIfNull(b)
	panicIfNull(compare)
	b, compare = sortByLength(b, compare)
	result = New(b.length)
	for i, word := range b.set {
		result.set[i] = word & compare.set[i]
	}
	return
}

//两个位图相与后的1的个数
func (b *BitSet) IntersectionCardinality(compare *BitSet) uint {
	panicIfNull(b)
	panicIfNull(compare)
	b, compare = sortByLength(b, compare)
	cnt := popcntAndSlice(b.set, compare.set)
	return uint(cnt)
}

//当前位图直接和comapre相与操作，并且如果compare的长度比b大
//b对应扩展到compare的长度
func (b *BitSet) InPlaceIntersection(compare *BitSet) {
	panicIfNull(b)
	panicIfNull(compare)
	l := int(compare.wordCount())
	if l > int(b.wordCount()) {
		l = int(b.wordCount())
	}
	for i := 0; i < l; i++ {
		b.set[i] &= compare.set[i]
	}
	for i := l; i < len(b.set); i++ {
		b.set[i] = 0
	}
	if compare.length > 0 {
		b.extendSetMaybe(compare.length - 1)
	}
}

//两个位图或操作
func (b *BitSet) Union(compare *BitSet) (result *BitSet) {
	panicIfNull(b)
	panicIfNull(compare)
	b, compare = sortByLength(b, compare)
	result = compare.Clone()
	for i, word := range b.set {
		result.set[i] = word | compare.set[i]
	}
	return
}

func (b *BitSet) UnionCardinality(compare *BitSet) uint {
	panicIfNull(b)
	panicIfNull(compare)
	b, compare = sortByLength(b, compare)
	cnt := popcntOrSlice(b.set, compare.set)
	if len(compare.set) > len(b.set) {
		cnt += popcntSlice(compare.set[len(b.set):])
	}
	return uint(cnt)
}

func (b *BitSet) InPlaceUnion(compare *BitSet) {
	panicIfNull(b)
	panicIfNull(compare)
	l := int(compare.wordCount())
	if l > int(b.wordCount()) {
		l = int(b.wordCount())
	}
	if compare.length > 0 {
		b.extendSetMaybe(compare.length - 1)
	}
	for i := 0; i < l; i++ {
		b.set[i] |= compare.set[i]
	}
	if len(compare.set) > l {
		for i := l; i < len(compare.set); i++ {
			b.set[i] = compare.set[i]
		}
	}
}

//两个位图异或操作
func (b *BitSet) SymmetricDifference(compare *BitSet) (result *BitSet) {
	panicIfNull(b)
	panicIfNull(compare)
	b, compare = sortByLength(b, compare)
	// compare is bigger, so clone it
	result = compare.Clone()
	for i, word := range b.set {
		result.set[i] = word ^ compare.set[i]
	}
	return
}

func (b *BitSet) SymmetricDifferenceCardinality(compare *BitSet) uint {
	panicIfNull(b)
	panicIfNull(compare)
	b, compare = sortByLength(b, compare)
	cnt := popcntXorSlice(b.set, compare.set)
	if len(compare.set) > len(b.set) {
		cnt += popcntSlice(compare.set[len(b.set):])
	}
	return uint(cnt)
}

func (b *BitSet) InPlaceSymmetricDifference(compare *BitSet) {
	panicIfNull(b)
	panicIfNull(compare)
	l := int(compare.wordCount())
	if l > int(b.wordCount()) {
		l = int(b.wordCount())
	}
	if compare.length > 0 {
		b.extendSetMaybe(compare.length - 1)
	}
	for i := 0; i < l; i++ {
		b.set[i] ^= compare.set[i]
	}
	if len(compare.set) > l {
		for i := l; i < len(compare.set); i++ {
			b.set[i] = compare.set[i]
		}
	}
}

//长度是否是64的整数倍
func (b *BitSet) isLenExactMultiple() bool {
	return b.length%wordSize == 0
}

//位图最后一个64位，没有使用的置0
func (b *BitSet) cleanLastWord() {
	if !b.isLenExactMultiple() {
		b.set[len(b.set)-1] &= allBits >> (wordSize - b.length%wordSize)
	}
}

//位图取反操作
func (b *BitSet) Complement() (result *BitSet) {
	panicIfNull(b)
	result = New(b.length)
	for i, word := range b.set {
		result.set[i] = ^word
	}
	result.cleanLastWord()
	return
}

//是否所有的位都用到了
func (b *BitSet) All() bool {
	panicIfNull(b)
	return b.Count() == b.length
}

//是否全都是空的
func (b *BitSet) None() bool {
	panicIfNull(b)
	if b != nil && b.set != nil {
		for _, word := range b.set {
			if word > 0 {
				return false
			}
		}
		return true
	}
	return true
}

//是否存在使用位
func (b *BitSet) Any() bool {
	panicIfNull(b)
	return !b.None()
}

//判断当前位图是否是other位图的超集
//即other为1的b中必然为1
func (b *BitSet) IsSuperSet(other *BitSet) bool {
	for i, e := other.NextSet(0); e; i, e = other.NextSet(i + 1) {
		if !b.Test(i) {
			return false
		}
	}
	return true
}

//严格超集，b存在other没有的置1位
func (b *BitSet) IsStrictSuperSet(other *BitSet) bool {
	return b.Count() > other.Count() && b.IsSuperSet(other)
}

//bitset输出字符串
func (b *BitSet) DumpAsBits() string {
	if b.set == nil {
		return "."
	}
	buffer := bytes.NewBufferString("")
	i := len(b.set) - 1
	for ; i >= 0; i-- {
		fmt.Fprintf(buffer, "%064b.", b.set[i])
	}
	return buffer.String()
}

//返回序列化后的字节总数
func (b *BitSet) BinaryStorageSize() int {
	return binary.Size(uint64(0)) + binary.Size(b.set)
}

//写入stream
func (b *BitSet) WriteTo(stream io.Writer) (int64, error) {
	length := uint64(b.length)

	// Write length
	err := binary.Write(stream, binaryOrder, length)
	if err != nil {
		return 0, err
	}

	// Write set
	err = binary.Write(stream, binaryOrder, b.set)
	return int64(b.BinaryStorageSize()), err
}

//stream读取
func (b *BitSet) ReadFrom(stream io.Reader) (int64, error) {
	var length uint64
	err := binary.Read(stream, binaryOrder, &length)
	if err != nil {
		return 0, err
	}
	newset := New(uint(length))
	if uint64(newset.length) != length {
		return 0, errors.New("Unmarshalling error: type mismatch")
	}
	err = binary.Read(stream, binaryOrder, newset.set)
	if err != nil {
		return 0, err
	}
	*b = *newset
	return int64(b.BinaryStorageSize()), nil
}

//输出字节流
func (b *BitSet) MarshalBinary() ([]byte, error) {
	var buf bytes.Buffer
	writer := bufio.NewWriter(&buf)

	_, err := b.WriteTo(writer)
	if err != nil {
		return []byte{}, err
	}

	err = writer.Flush()

	return buf.Bytes(), err
}

//字节流输入还原bitset
func (b *BitSet) UnmarshalBinary(data []byte) error {
	buf := bytes.NewReader(data)
	reader := bufio.NewReader(buf)

	_, err := b.ReadFrom(reader)

	return err
}

//字节流编码后输出json处理
func (b *BitSet) MarshalJSON() ([]byte, error) {
	buffer := bytes.NewBuffer(make([]byte, 0, b.BinaryStorageSize()))
	_, err := b.WriteTo(buffer)
	if err != nil {
		return nil, err
	}
	return json.Marshal(base64Encoding.EncodeToString(buffer.Bytes()))
}

//json结构体解析bitset
func (b *BitSet) UnmarshalJSON(data []byte) error {
	// Unmarshal as string
	var s string
	err := json.Unmarshal(data, &s)
	if err != nil {
		return err
	}

	// URLDecode string
	buf, err := base64Encoding.DecodeString(s)
	if err != nil {
		return err
	}

	_, err = b.ReadFrom(bytes.NewReader(buf))
	return err
}
```

