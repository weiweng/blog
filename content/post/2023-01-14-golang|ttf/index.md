+++
title="Golang|truetype解析"
date="2023-01-07T09:43:00+08:00"
categories=["Golang"]
toc=true
+++

最近工作上遇到需要解析ttf字库的需求，判断给到的数据中是否有不存在ttf字库中的汉字，结果查询一遍之后发现，使用golang解析ttf做判定的代码基本没有，因此本文开始详细分析一波ttf字库文件，并尝试使用golang解析，实现相关需求。

## TTF

TrueType是由美国苹果公司和微软公司共同开发的一种电脑轮廓字体（曲线描边字）类型标准。这种类型字体文件的扩展名是`.ttf`。

早在1980年代末，苹果公司为了对抗Adobe公司的Type 1PostScript字体，设计开发了TrueType。之后微软加入了开发，Windows操作系统的字体格式基本上都统一成TrueType，TrueType后来也被Linux等系统使用，成为标准字体。TrueType的主要强项在于它能给开发者提供关于字体显示、不同字体大小的像素级显示等的高级控制。

### TrueType 字体文件

TrueType字体文件由一系列连接的表组成。表是单词的序列。每个表必须长对齐，并在必要时用零填充。所有的数据表中，第一重要的表是**字体目录**，这是一个特殊的表，便于访问字体中的其他表。该目录后面是一系列包含字体数据的表。这些表可以以任何顺序出现。有一些表格是所有字体都必须包含的，有些表是基于相关特殊功能可选择的包含对应数据表。

必备表单

|   tag    | Table |
|  ------  | ----  |
|  'camp'  | character to glyph mapping |
|  'glyf'  | glyph data |
|  'head'  | font header |
|  'hhea'  | horizontal header |
|  'hmtx'  | horizontal metrics |
|  'loca'  | index to location |
|  'maxp'  | maximum profile |
|  'name'  | naming |
|  'post'  | PostScript |

### 字体目录

字体目录是所有表中最重要的，它是字体文件内的指导手册。通过它可以指导其他表格的相关信息。目录由两部分组成：偏移子表和表目录，偏移子表记录了表格数量，以及每个表格的对应存储偏移量，表目录则存储了具体的条目内容。

偏移子表的格式如下：

|   type   |     name      |  description  |
|  ------  |  ----------   | ------------- |
|  uint32  | scaler type   | 一个标记，用于指示OFA缩放，重新定义字体大小 |
|  uint16  | numTables     | 表个数 |
|  uint16  | searchRange   | (maximum power of 2 <= numTables)*16 |
|  uint16  | entrySelector | log2(maximum power of 2 <= numTables) |
|  uint16  | rangeShift    | numTables*16-searchRange |

表目录跟在offset子表后面。表目录中的条目必须按标签升序排序。字体文件中的每个表必须有自己的表目录条目。具体格式如下：

|   type   |     name   |  description  |
|  ------  |  --------- | ------------- |
|  uint32  |    tag     | 4字节的标识符 |
|  uint32  |  checkSum  | 表的校验和 |
|  uint32  |    offset  | 从SFNT开始的偏移量 |
|  uint32  |    length  | 该表的长度(以字节为单位) |

从格式可以看出，具体表的内容存储在offset到offset+length之间。

### cmap

了解了ttf字体文件的大概后，我们重点看看cmap表，cmap表将字符代码映射到字形索引。需要注意的是如果一种字体想要在多个平台上使用不同的编码显示约定，就需要多个编码表，因此，cmap表可能包含多个子表，每个子表对应支持的编码方案。

在cmap表中，对于不可展示的字符，我们会将字符对应代码映射到字形索引0，通常0这个位置对应的字形是一个方框，，表示缺少的字符。需要注意的是，不应该将其映射到字形索引-1 (0xFFFF)，这是处理中保留的一个特殊值，用于指示从字形流中删除的字形的位置。

接下来看看cmap表的格式：

|   type   |     name         |  description  |
|  ------  |  ---------       | ------------- |
|  UInt16  |    version       | 版本号         |
|  UInt16  |  numberSubtables | 编码子表的个数   |

camp的编码子表格式：

|   type   |     name         |  description  |
|  ------  |  ---------       | ------------- |
|  UInt16  |    platformID       | 平台标识符         |
|  UInt16  |  platformSpecificID | 平台特定的编码标识符   |
|  UInt32  |  offset | 映射表的偏移量   |

子表必须先按平台标识符升序排序，然后再按平台特定标识符进行排序。platformID和platformSpecificID具体的枚举定义可以参考官方文档，这里我们关注的是platformID为0时，就是Unicode编码平台，随后platformSpecificID标识对应的相关Unicode版本。

### cmap formats

每个“cmap”子表都是当前可用的九种格式之一。它们是下一节中描述的格式0、格式2、格式4、格式6、格式8、格式10、格式12、格式13和格式14。其中格式2支持混合8/16位映射，适用于日语、中文和韩语。不过在阅读`github.com/golang/freetype/truetype`的源码时，发现只解析了4和12两种格式，因此我们重点关注格式4的具体定义。

格式4是一种双字节编码格式。当字体的字符代码落在几个连续的范围内时，允许存在一些空缺映射，即非密集的情况时，推荐使用格式4，密集映射的双字节字体时推荐使用格式6。

格式4的设计格式如下：

|   type   |     name         |  description  |
|  ------  |  ---------       | ------------- |
|  UInt16  |    format       | 固定数值4         |
|  UInt16  |  length | 长度(字节)   |
|  UInt32  |  language | 语言编码   |
|  UInt16  |    segCountX2       | 2 * segCount         |
|  UInt16  |    searchRange       | 2 * (2**FLOOR(log2(segCount)))         |
|  UInt16  |    entrySelector       | log2(searchRange/2)         |
|  UInt16  |    rangeShift       | (2 * segCount) - searchRange         |
|  UInt16  |    endCode\[segCount\]       |  每个段的结束位置，最后一个数值为0xFFFF        |
|  UInt16  |    reservedPad       | 理论上应该是0值         |
|  UInt16  |    startCode\[segCount\]	       | 每个段的起始位置         |
|  UInt16  |    idDelta\[segCount\]	       | 每个段的字符代码增量         |
|  UInt16  |    idRangeOffset\[segCount\]	       | 对应到glyph indexArray的偏移量，可能为0         |
|  UInt16  |    glyphIndexArray\[variable\]	       | 图形数据索引下标数组         |

段可以理解为一个映射码范围，其总的个数定义为segCount，但这个变量没有显示的在格式中标注体现，不过可以大略计算出来。

searchRange, entrySelector, rangeShift 这三个字段苹果平台上不使用，为了兼容其他平台需要正确设置数值。 

具体如何解析cmap的编码与图形映射关系表，我们之后看一下代码。

## 代码

truetype解析代码，我们看一下相关[开源库](https://github.com/golang/freetype/blob/master/truetype/truetype.go)，这里贴一下关键代码。

```c
// 首先是基础的读取字节数据

// u32函数，在i位置后面读取32bit，返回uint32
// u32 returns the big-endian uint32 at b[i:].
func u32(b []byte, i int) uint32 {
	return uint32(b[i])<<24 | uint32(b[i+1])<<16 | uint32(b[i+2])<<8 | uint32(b[i+3])
}

// u16 returns the big-endian uint16 at b[i:].
func u16(b []byte, i int) uint16 {
	return uint16(b[i])<<8 | uint16(b[i+1])
}

// 读取表字节数据
// readTable returns a slice of the TTF data given by a table's directory entry.
func readTable(ttf []byte, offsetLength []byte) ([]byte, error) {
    // 偏移量获取
	offset := int(u32(offsetLength, 0))
	if offset < 0 {
		return nil, FormatError(fmt.Sprintf("offset too large: %d", uint32(offset)))
	}
    // 长度获取
	length := int(u32(offsetLength, 4))
	if length < 0 {
		return nil, FormatError(fmt.Sprintf("length too large: %d", uint32(length)))
	}
	end := offset + length
	if end < 0 || end > len(ttf) {
		return nil, FormatError(fmt.Sprintf("offset + length too large: %d", uint32(offset)+uint32(length)))
	}
    // 返回字节内容
	return ttf[offset:end], nil
}

// parse ttf文件解析核心函数，offset初始为0
func parse(ttf []byte, offset int) (font *Font, err error) {
	if len(ttf)-offset < 12 {
		err = FormatError("TTF data is too short")
		return
	}
	originalOffset := offset
    // 获取scaler type
	magic, offset := u32(ttf, offset), offset+4
	switch magic {
	case 0x00010000:
		// No-op.
	case 0x74746366: // "ttcf" as a big-endian uint32.
		if originalOffset != 0 {
			err = FormatError("recursive TTC")
			return
		}
		ttcVersion, offset := u32(ttf, offset), offset+4
		if ttcVersion != 0x00010000 && ttcVersion != 0x00020000 {
			err = FormatError("bad TTC version")
			return
		}
		numFonts, offset := int(u32(ttf, offset)), offset+4
		if numFonts <= 0 {
			err = FormatError("bad number of TTC fonts")
			return
		}
		if len(ttf[offset:])/4 < numFonts {
			err = FormatError("TTC offset table is too short")
			return
		}
		// TODO: provide an API to select which font in a TrueType collection to return,
		// not just the first one. This may require an API to parse a TTC's name tables,
		// so users of this package can select the font in a TTC by name.
		offset = int(u32(ttf, offset))
		if offset <= 0 || offset > len(ttf) {
			err = FormatError("bad TTC offset")
			return
		}
		return parse(ttf, offset)
	default:
		err = FormatError("bad TTF version")
		return
	}
    // 读取表个数n
	n, offset := int(u16(ttf, offset)), offset+2
	offset += 6 // Skip the searchRange, entrySelector and rangeShift.
	if len(ttf) < 16*n+offset {
		err = FormatError("TTF data is too short")
		return
	}
	f := new(Font)
	// Assign the table slices.
	for i := 0; i < n; i++ {
		x := 16*i + offset
		switch string(ttf[x : x+4]) {
        // 读取cmap表字节数据
		case "cmap":
			f.cmap, err = readTable(ttf, ttf[x+8:x+16])
            ...
		}
		if err != nil {
			return
		}
	}
    ...
    // 解析cmap表
	if err = f.parseCmap(); err != nil {
		return
	}
    ...
	font = f
	return
}

func (f *Font) parseCmap() error {
	const (
		cmapFormat4         = 4
		cmapFormat12        = 12
		languageIndependent = 0
	)
    // cmap子表解析，返回最佳的使用子表
	offset, _, err := parseSubtables(f.cmap, "cmap", 4, 8, nil)
	if err != nil {
		return err
	}
	offset = int(u32(f.cmap, offset+4))
	if offset <= 0 || offset > len(f.cmap) {
		return FormatError("bad cmap offset")
	}
    // 读取cmap 格式类型
	cmapFormat := u16(f.cmap, offset)
	switch cmapFormat {
    // format4 格式解析
	case cmapFormat4:
		language := u16(f.cmap, offset+4)
		if language != languageIndependent {
			return UnsupportedError(fmt.Sprintf("language: %d", language))
		}
		segCountX2 := int(u16(f.cmap, offset+6))
		if segCountX2%2 == 1 {
			return FormatError(fmt.Sprintf("bad segCountX2: %d", segCountX2))
		}
        // 计算段个数
		segCount := segCountX2 / 2
		offset += 14
		f.cm = make([]cm, segCount)
        // 读取end数组
		for i := 0; i < segCount; i++ {
			f.cm[i].end = uint32(u16(f.cmap, offset))
			offset += 2
		}
        // 跳过字段
		offset += 2
        // 读取start数组
		for i := 0; i < segCount; i++ {
			f.cm[i].start = uint32(u16(f.cmap, offset))
			offset += 2
		}
        // 读取delta数组
		for i := 0; i < segCount; i++ {
			f.cm[i].delta = uint32(u16(f.cmap, offset))
			offset += 2
		}
        // 读取offset数组
		for i := 0; i < segCount; i++ {
			f.cm[i].offset = uint32(u16(f.cmap, offset))
			offset += 2
		}
        // 字形下标数组
		f.cmapIndexes = f.cmap[offset:]
		return nil

	case cmapFormat12:
		if u16(f.cmap, offset+2) != 0 {
			return FormatError(fmt.Sprintf("cmap format: % x", f.cmap[offset:offset+4]))
		}
		length := u32(f.cmap, offset+4)
		language := u32(f.cmap, offset+8)
		if language != languageIndependent {
			return UnsupportedError(fmt.Sprintf("language: %d", language))
		}
		nGroups := u32(f.cmap, offset+12)
		if length != 12*nGroups+16 {
			return FormatError("inconsistent cmap length")
		}
		offset += 16
		f.cm = make([]cm, nGroups)
		for i := uint32(0); i < nGroups; i++ {
			f.cm[i].start = u32(f.cmap, offset+0)
			f.cm[i].end = u32(f.cmap, offset+4)
			f.cm[i].delta = u32(f.cmap, offset+8) - f.cm[i].start
			offset += 12
		}
		return nil
	}
	return UnsupportedError(fmt.Sprintf("cmap format: %d", cmapFormat))
}
// 子表选择，规定如下
// 优先使用unicode编码表
// 优先使用非BMP限制的unicode表
// 如果有4、12格式的unicode表，则优先使用
func parseSubtables(table []byte, name string, offset, size int, pred func([]byte) bool) (
	bestOffset int, bestPID uint32, retErr error) {

	if len(table) < 4 {
		return 0, 0, FormatError(name + " too short")
	}
    // 表个数读取
	nSubtables := int(u16(table, 2))
	if len(table) < size*nSubtables+offset {
		return 0, 0, FormatError(name + " too short")
	}
	ok := false
	for i := 0; i < nSubtables; i, offset = i+1, offset+size {
		if pred != nil && !pred(table[offset:]) {
			continue
		}
		// We read the 16-bit Platform ID and 16-bit Platform Specific ID as a single uint32.
		// All values are big-endian.
		pidPsid := u32(table, offset)
		// We prefer the Unicode cmap encoding. Failing to find that, we fall
		// back onto the Microsoft cmap encoding.
		if pidPsid == unicodeEncodingBMPOnly || pidPsid == unicodeEncodingFull {
			bestOffset, bestPID, ok = offset, pidPsid>>16, true
			break

		} else if pidPsid == microsoftSymbolEncoding ||
			pidPsid == microsoftUCS2Encoding ||
			pidPsid == microsoftUCS4Encoding {

			bestOffset, bestPID, ok = offset, pidPsid>>16, true
			// We don't break out of the for loop, so that Unicode can override Microsoft.
		}
	}
	if !ok {
		return 0, 0, UnsupportedError(name + " encoding")
	}
	return bestOffset, bestPID, nil
}

// cmap数据使用
// Index returns a Font's index for the given rune.
func (f *Font) Index(x rune) Index {
	c := uint32(x)
    // 二分查找，找打x所在范围的cm
	for i, j := 0, len(f.cm); i < j; {
		h := i + (j-i)/2
		cm := &f.cm[h]
		if c < cm.start {
			j = h
		} else if cm.end < c {
			i = h + 1
		} else if cm.offset == 0 {
            // offset为0，则直接返回delta+c
			return Index(c + cm.delta)
		} else {
            // offset不是0 ，则offset+ ？ +c在cm里的偏移量
			offset := int(cm.offset) + 2*(h-len(f.cm)+int(c-cm.start))
			return Index(u16(f.cmapIndexes, offset))
		}
	}
	return 0
}
```

## 参考

- [TTF字体格式入门](https://juejin.cn/post/7010064099027451912)
- [TrueType Typography](https://www.truetype-typography.com/)
- [TrueType Wiki](https://zh.m.wikipedia.org/zh-hans/TrueType)
- [MAC TrueType Reference Manual](https://developer.apple.com/fonts/TrueType-Reference-Manual/)
- [Microsoft TrueType overview](https://learn.microsoft.com/en-us/typography/truetype/)
