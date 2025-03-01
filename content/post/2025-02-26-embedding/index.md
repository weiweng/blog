+++
title="大模型专题|embedding"
date="2025-02-26T22:00:00+08:00"
categories=["大模型专题"]
toc=true
draft=false
+++

文本是一种非结构化的数据信息，是不可以直接被计算的。

文本表示的作用就是将这些非结构化的信息转化为结构化的信息，这样就可以针对文本信息做计算，来完成我们日常所能见到的文本分类，情感判断等任务。

文本表示的方法有很多种，下面只介绍 3 类方式：

- 独热编码 | one-hot representation
- 整数编码
- 词嵌入 | word embedding

词嵌入（Word Embedding）是自然语言处理（NLP）中的核心技术，旨在将词语映射到低维稠密的实数向量空间中，以捕捉词与词之间的语义和语法关系。传统的符号化表示（如One-Hot编码）因高维稀疏和语义缺失等问题逐渐被分布式表示取代。本文将深入解析词嵌入的核心思想，并重点探讨Google提出的经典模型——**Word2Vec**。

## 一、传统词表示方法的局限性
### 1. One-Hot编码
One-Hot编码将每个词表示为长度为词典大小的向量，其中仅有一个位置为1，其余为0。

例如，“猫”表示为`[1,0,0,0]`，而“狗”为`[0,1,0,0]`。

其缺点包括：

- **高维稀疏性**：词典规模大时向量维度极高，且99%以上的元素为0。
- **语义鸿沟**：任意两个词的余弦相似度均为0，无法表达语义关联。

### 2. TF-IDF
TF-IDF通过词频和逆文档频率加权，试图衡量词的重要性。但它仍无法解决以下问题：
- **位置信息缺失**：忽略词在文本中的位置权重。
- **语义表达不足**：仅依赖统计信息，无法捕捉上下文关联。


## 二、词嵌入的优势
词嵌入通过**分布式表示**（Distributed Representation）将词映射到向量空间，其核心思想基于**分布假说**：上下文相似的词，其语义也相似。优势包括：

1. **低维稠密**：向量维度可控，计算效率高
2. **语义关联**：相似词在向量空间中距离更近（如“国王-王后≈男人-女人”）
3. **迁移学习**：预训练的词向量可直接用于下游任务（如情感分析、命名实体识别）


## 三、Word2Vec模型详解
Word2Vec是2013年Google提出的经典词嵌入工具，Word2vec 将单词表示为高维数字向量，这些向量捕捉了单词之间的关系。特别是，在相似上下文中出现的单词被映射到通过余弦相似度测量的邻近向量。

包含两种模型架构和两种优化方法：

**Skip-gram跳字模型**假设基于某个词来生成它在文本序列周围的词。举个例子，假设文本序列是“the”“man”“loves”“his”“son”。以“loves”作为中心词，设背景窗口大小为2。如图10.1所示，跳字模型所关心的是，给定中心词“loves”，生成与它距离不超过2个词的背景词“the”“man”“his”“son”的条件概率

**Continuous Bag of Words (CBOW)连续词袋模型**与跳字模型类似。与跳字模型最大的不同在于，连续词袋模型假设基于某中心词在文本序列前后的背景词来生成该中心词。在同样的文本序列“the”“man”“loves”“his”“son”里，以“loves”作为中心词，且背景窗口大小为2时，连续词袋模型关心的是，给定背景词“the”“man”“his”“son”生成中心词“loves”的条件概率


## 四、应用场景
1. **语义相似度计算**：通过余弦相似度衡量词间关系（如“手机”与“电话”）
2. **文本分类**：将词向量加权平均作为文本特征输入分类器
3. **推荐系统**：用用户行为序列的嵌入向量进行物品推荐
4. **机器翻译**：跨语言词向量对齐实现语义迁移


## 五、总结与展望
Word2Vec通过简单的神经网络结构解决了词向量表示的核心问题，但其局限性（如静态向量无法处理一词多义）催生了后续模型如GloVe、BERT等。未来，词嵌入技术将更多结合上下文动态表示和多模态信息，推动NLP迈向更深层的语义理解。

## 参考资料
1. [词向量 — word2vec（CSDN博客）](https://blog.csdn.net/lizzy05/article/details/88653163)  
2. [Word2Vec的优化算法（CSDN博客）](https://blog.csdn.net/yyhhlancelot/article/details/100005022)  
3. [词嵌入方法解析（CSDN博客）](https://blog.csdn.net/weixin_40651515/article/details/109963179)  
4. [One-Hot与Embedding对比（CSDN博客）](https://blog.csdn.net/tototuzuoquan/article/details/113059788)  
5. [Word2Vec的应用（CSDN博客）](https://blog.csdn.net/qq_37457202/article/details/108697461)  
6. [nlp 中 embedding综述论文](https://ieeexplore.ieee.org/document/10098736)
7. [Word2Vec 训练方法](https://paddlepedia.readthedocs.io/en/latest/tutorials/sequence_model/word_representation/word2vec.html)
8. [理解word2vec的训练过程](https://blog.csdn.net/dn_mug/article/details/69852740)