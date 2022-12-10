+++
title="红黑树实现"
tags=["算法","红黑树"]
categories=["算法"]
date="2020-03-13T06:25:00+08:00"
summary = '红黑树实现'
toc=false
+++

### 红黑树

具体红黑树的基本概念见[博客](http://blog.csdn.net/eric491179912/article/details/6179908)

上述博客中，由于是各处粘贴合成的，所以我只参考了开头一篇，仔细研读研读，插入和删除总结为一下两个图和代码: ![红黑树添加删除节点流程图](http://pf76mu410.bkt.clouddn.com/20170428-red-black-tree.jpeg)

### 具体代码

```javascript
/*************************************************************************
    > File Name: rdt.cpp
    > Author: Duke-wei
    > Mail: 13540639584@163.com 
    > Created Time: 2017年04月19日 星期三 20时21分57秒
 ************************************************************************/
 
#include<iostream>
#include<vector>
#include<queue>
#include<string>
 
#define DE_BUG 0
 
using namespace std;
 
//红黑树本质是一颗二叉查找树，又由于带红黑色，所以接近平衡。
//红黑树5个性质：
//1.每个结点要么是红的要么是黑的。
//2.根节点是黑的。
//3.每个叶子结点都是黑的。这里的叶子结点是指树尾结点的NULL结点。
//4.如果一个结点是红的，那么它的两个儿子都是黑的。
//5.对于任意结点而言，其到叶结点树尾端NIL指针的每条路劲都包含相同数目的黑结点。
//上述性质让红黑树的查找、插入、删除的时间复杂度最坏也是O(log n)。
 
//define struct rdt : red black tree
struct rdt{
	bool isred;
	int value;
	rdt* ln;
	rdt* rn;
	rdt* pa;
	rdt():isred(true),value(0),ln(NULL),rn(NULL),pa(NULL){}
	rdt(int x):isred(true),value(x),ln(NULL),rn(NULL),pa(NULL){}
	rdt(bool f,int x):isred(f),value(x),ln(NULL),rn(NULL),pa(NULL){}
};
 
rdt* search(rdt* root,int value);
bool rdt_add_adjust(rdt* root,rdt* p);
rdt* add_node(rdt* root,int value);
void rdt_del_adjust(rdt* root,rdt* p);
rdt* del_node(rdt* root,int value);
rdt* rdt_init(vector<int> &nums);
rdt* rdt_head(rdt* root);
void rdt_delete(rdt* root);
void rdt_bfs(vector<pair<int,int> >& data,rdt* root);
void rdt_print(rdt* root); //=================================================下面是寻找插入节点的函数================
//在红黑树中搜索value值，如果找到则返回nullptr，否则返回带插入的位置的父节点指针。
rdt* search(rdt* root,int value){
	rdt* p = root; while(root!=NULL){
		if(root->value>value){
			p = root;
			root = root->ln;
		}else if(root->value<value){
			p = root;
			root = root->rn;
		}else{
			return NULL;
		}
	}
	return p;
} //=================================================下面是插入节点时的函数================
//调整红黑树，root为p的父节点，p为需要更新的结点。
bool rdt_add_adjust(rdt* root,rdt* p){ if(root==NULL){
		p->isred = false;
		return true;
	}
	if(!root->isred){
		//黑父，直接插入,无需更新
		return true;
	}else{
		//p_root是root的父节点，是p的祖父结点
		rdt* p_root = root->pa; //注意这里的祖父结点不会NULL，如果没有祖父结点则这个红黑树根节点是红的，所以违背原理。 if(root==p_root->ln){
			//root 是p_root的左结点
			if(p_root->rn!=NULL&&p_root->rn->isred){
				//叔父结点是红的
				root->isred = false;
				p_root->rn->isred = false;
				p_root->isred = true;
				rdt_add_adjust(p_root->pa,p_root); }else{ //叔父结点是黑的 if(p==root->ln){
					//p是root的左结点,LL旋转
					//先记录root的右结点和p_root的父节点。
					rdt* rrn = root->rn; //记录兄弟结点。可能为NULL
					rdt* pp_root = p_root->pa; //记录祖父结点的父节点。可能为NULL
 
					root->rn = p_root;
					root->pa = p_root->pa;
					p_root->ln = rrn;
					p_root->pa = root; if(rrn!=NULL) rrn->pa = p_root;
					root->isred = false;
					p_root->isred = true; if(pp_root==NULL){
						return true; }else{ if(p_root==pp_root->ln){
							pp_root->ln = root;
						}else{
							pp_root->rn = root;
						}
					}
				}else{
					//p是root的右结点,LR旋转 并且父节点是祖父结点的左结点。
					rdt* pp_root = p_root->pa; //记录祖父结点的父节点，可能为NULL
 
					if(p->ln!=NULL){
						root->rn = p->ln;
						root->rn->pa = root;
					}else{
						root->rn = NULL;
					}
					root->pa = p;
					if(p->rn!=NULL){
						p_root->ln = p->rn;
						p_root->ln->pa = p_root;
					}else{
						p_root->ln = NULL;
					}
					p_root->pa = p;
					p->ln = root;
					p->rn = p_root;
					p->pa = pp_root;
					p->isred = false;
					p_root->isred = true; if(pp_root==NULL){
						return true; } if(p_root==pp_root->ln){
						pp_root->ln = p;
					}else{
						pp_root->rn = p;
					}
				}
			}
		}else{
			//root 是p_root的右结点
			if(p_root->ln!=NULL&&p_root->ln->isred){
				//叔父结点是红的
				root->isred = false;
				p_root->ln->isred = false;
				p_root->isred = true;
				rdt_add_adjust(p_root->pa,p_root); }else{ //叔父结点是黑的 if(p==root->ln){
					//p是root的左结点,RL旋转
					rdt* pp_root = p_root->pa;
					if(p->ln!=NULL){
						p_root->rn = p->ln;
						p_root->rn->pa = p_root;
					}else{
						p_root->rn = NULL;
					}
					p_root->pa = p;
					if(p->rn!=NULL){
						root->ln = p->rn;
						root->ln->pa = root;
					}else{
						root->ln = NULL;
					}
					root->pa = p;
					p->ln = p_root;
					p->rn = root;
					p->pa = pp_root;
					p->isred = false;
					p_root->isred = true; if(pp_root==NULL){
						return true; } if(p_root==pp_root->ln){
						pp_root->ln = p;
					}else{
						pp_root->rn = p;
					}
				}else{
					//p是root的右结点,RR旋转
					//rln root left node
					rdt* rln = root->ln; //记录p的兄弟结点，可能为NULL
					//pp_root is parent of p_root which is parent of root;
					rdt* pp_root = p_root->pa; //记录祖父结点的父结点，可能为NULL
 
					root->ln = p_root;
					root->pa = pp_root;
					p_root->rn = rln;
					p_root->pa = root; if(rln!=NULL) rln->pa = p_root;
					root->isred = false;
					p_root->isred = true; if(pp_root==NULL){
						return true; }else{ if(p_root==pp_root->ln){
							pp_root->ln = root;
						}else{
							pp_root->rn = root;
						}
					}
				}
			}
		}
	}
	return true;
}
 
 
//插入一个值到红黑树并调整树
rdt* add_node(rdt* root,int value){
	//先加入该结点（新插入结点默认都是红的）
	rdt* new_node = new rdt(value); if(root==NULL){
		new_node->isred = false;
		return new_node;
	}
	rdt* p = search(root,value); if(p==NULL){
		delete new_node;
		return NULL;
	}
	if(p->value > value) 
		p->ln = new_node;
	else
		p->rn = new_node;
	new_node->pa = p;
	rdt_add_adjust(p,new_node);
	rdt* head = rdt_head(p);
	return head;
} //==========================================以下是删除节点的函数======================
//这个函数处理删除节点后的树的调节
//参数是带调节的点P和P的父节点root
//该函数需要调节的有一下情况：
//--1.p的兄弟结点是红的：
//-----通过变换，继续迭代修正。
//--2.p的兄弟结点是黑的：
//-----2.1.黑兄弟有两个黑色侄子
//--------2.1.1.红色的父亲
//--------2.1.2.黑色的父亲
//-----2.2.黑兄弟有左红侄子
//-----2.3.黑兄弟有右红侄子
void rdt_del_adjust(rdt* root,rdt* p){ if(p==root->ln){
		//注意p的兄弟结点一定不会是空的，通过红黑树的性质和删除节点前的情况可知。
		rdt* pu = root->rn;
		if(pu->isred){
		//p的兄弟结点是红的,通过红黑树的性质可知，p的父节点一定是黑的。p的兄弟结点的子节点一定也是黑的或是空
		//此时，只需要RR旋转，构造成红父黑兄的情况。
		//处理后降低了一层，继续迭代。
			rdt* pul = pu->ln;
			root->rn = pul; //这里的pul其实可以推导出，它一定不会为空的。 if(pul!=NULL) pul->pa = root;
			pu->ln = root;
			pu->pa = root->pa;
			root->pa = pu;
			//这里注意root是根结点的情况
			if(pu->pa!=NULL){
				if(pu->pa->ln==root){
					pu->pa->ln = pu;
				}else{
					pu->pa->rn = pu;
				}
			}
			pu->isred = false;
			root->isred = true;
			rdt_del_adjust(root,p);
		}else{
		//p的兄弟结点是黑的
			if(pu->rn!=NULL&&pu->rn->isred){
				//结点p有右红侄子
				//实行RR旋转
				rdt* pul = pu->ln;
				root->rn = pul; if(pul!=NULL) pul->pa = root;
				pu->ln = root;
				pu->pa = root->pa;
				root->pa = pu;
				//这里注意root是根结点的情况
				if(pu->pa!=NULL){ if(root==pu->pa->ln){
						pu->pa->ln = pu;
					}else{
						pu->pa->rn = pu;
					}
				}
				pu->isred = root->isred;
				root->isred = false;
				pu->rn->isred = false;
			}else if(pu->ln!=NULL&&pu->ln->isred){
				//结点p有左红侄子
				//进行RL旋转
				//pul是p兄弟的左节点
				rdt* pul = pu->ln;
				//pul是p兄弟的左节点的左节点
				rdt* pull = pul->ln;
				//pul是p兄弟的左节点的右节点
				rdt* pulr = pul->rn;
				root->rn = pull; if(pull!=NULL) pull->pa = root;
				pu->ln = pulr; if(pulr!=NULL) pulr->pa = pu;
				pul->pa = root->pa;
				root->pa = pul;
				pul->ln = root;
				pul->rn = pu;
				pu->pa = pul;
				//这里注意root是根结点的情况
				if(pul->pa!=NULL){ if(root==pul->pa->ln){
						pul->pa->ln = pul;
					}else{
						pul->pa->rn = pul;
					}
				}
				pul->isred = root->isred;
				root->isred = false;
			}else{
				//结点p有两个黑的侄子
				if(root->isred){
					//红父
					root->isred = false;
					pu->isred = true; if(p!=NULL) p->isred = false; }else{ //黑父 if(p!=NULL){
						root->isred = p->isred;
					}else{
						root->isred = false;
					}
					pu->isred = true; if(p!=NULL) p->isred = false;
				}
			}
		}
	}else{
		rdt* pu = root->ln;
		if(pu->isred){
		//p的兄弟结点是红的
		//进行LL旋转
		//处理后降低了一层，继续迭代。
			rdt* pur = pu->rn;
			root->ln = pur; //其实这里的pur不会为空 if(pur!=NULL) pur->pa = root;
			pu->rn = root;
			pu->pa = root->pa;
			root->pa = pu;
			//这里注意root是根结点的情况
			if(pu->pa!=NULL){
				if(pu->pa->ln==root){
					pu->pa->ln = pu;
				}else{
					pu->pa->rn = pu;
				}
			}
			pu->isred = false;
			root->isred = true;
			rdt_del_adjust(root,p);
		}else{
		//p的兄弟结点是黑的
			if(pu->ln!=NULL&&pu->ln->isred){
				//结点p有左红侄子
				//实行LL旋转
				rdt* pur = pu->rn;
				root->ln = pur; if(pur!=NULL) pur->pa = root;
				pu->rn = root;
				pu->pa = root->pa;
				root->pa = pu;
				//这里注意root是根结点的情况
				if(pu->pa!=NULL){ if(root==pu->pa->ln){
						pu->pa->ln = pu;
					}else{
						pu->pa->rn = pu;
					}
				}
				pu->isred = root->isred;
				root->isred = false;
				pu->ln->isred = false;
			}else if(pu->rn!=NULL&&pu->rn->isred){
				//结点p有右红侄子
				//进行LR旋转
				//pur是p兄弟的右节点
				rdt* pur = pu->rn;
				//purl是p兄弟的右节点的左节点
				rdt* purl = pur->ln;
				//purr是p兄弟的右节点的右节点
				rdt* purr = pur->rn;
				root->rn = purr; if(purr!=NULL) purr->pa = root;
				pu->ln = purl; if(purl!=NULL) purl->pa = pu;
				pur->pa = root->pa;
				root->pa = pur;
				pur->ln = pu;
				pur->rn = root;
				pu->pa = pur;
				//这里注意root是根结点的情况
				if(pur->pa!=NULL){ if(root==pur->pa->ln){
						pur->pa->ln = pur;
					}else{
						pur->pa->rn = pur;
					}
				}
				pur->isred = root->isred;
				root->isred = false;
			}else{
				//结点p有两个黑的侄子
				if(root->isred){
					//红父
					root->isred = false;
					pu->isred = true; if(p!=NULL) p->isred = false; }else{ //黑父 if(p!=NULL){
						root->isred = p->isred;
					}else{
						root->isred = false;
					}
					pu->isred = true; if(p!=NULL) p->isred = false;
				}
			}
		}
	}
}
 
rdt* del_node(rdt* root,int value){ //首先找到需要删除的点。 while(root!=NULL){
		if(root->value > value) root = root->ln;
		else if(root->value < value) root = root->rn;
		else break; } //没找到，返回false if(root==NULL) return NULL;
 
	if(root->ln==NULL&&root->rn==NULL){
		if(root->isred){
		//找到需要删除的结点，如果是红色的叶子节点，直接删除。
			rdt* rp = root->pa;
			if(rp->ln==root){
				rp->ln = NULL;
			}else{
				rp->rn = NULL;
			}
			rdt_delete(root);
			return rp;
		}
		//找到需要删除的结点，如果是黑色叶子结点，看它的父节点，如果是空，则该节点是根结点。
		//这里特殊处理一下，删根节点直接将它置为红色结点，放回空。
		if(root->pa==NULL){
			root->isred = true;
			return NULL;
		}
	}
	//如果是黑的单支结点或者是黑的叶子结点，如下处理。
	//存在情况：
	//1.纯黑色叶子结点,这个情况合并在3中。
	//2.黑色单支结点，左右中有一个红色叶子结点。
	//3.黑色单支结点，左或右是一个黑色结点(包括哨兵结点)
	if(root->ln==NULL||root->rn==NULL){
		if(root->ln!=NULL&&root->ln->isred){
			//左节点非空，而且是红色的,直接将值赋给root。
				root->value = root->ln->value;
				rdt_delete(root->ln);
				root->ln = NULL;
		}else if(root->ln!=NULL&&!root->ln->isred){
			//否则为黑色单支结点，子节点是黑色的。
				root->value = root->ln->value;
				rdt_delete(root->ln);
				root->ln = NULL;
				rdt_del_adjust(root->pa,root);
		}else if(root->rn!=NULL&&root->rn->isred){
			//右节点非空且为红色。直接将值赋给root。
				root->value = root->rn->value;
				rdt_delete(root->rn);
				root->rn = NULL;
		}else if(root->rn!=NULL&&!root->rn->isred){
			//否则为黑色单支结点，子节点是黑色的。
				root->value = root->rn->value;
				rdt_delete(root->rn);
				root->rn = NULL;
				rdt_del_adjust(root->pa,root);
		}else{
			//纯黑色叶子结点处理
			rdt* pr = root->pa; if(root==pr->ln){
				pr->ln = NULL;
			}else{
				pr->rn = NULL;
			}
			rdt_delete(root);
			root = NULL;
			rdt_del_adjust(pr,root);
			return pr;
		}
	}else{
		//如果都不是，则找root左子树的最大值结点A，替换root，然后递归删除该结点A。
		rdt* p = root->ln;
		while(p->rn!=NULL){
			p = p->rn;
		}
		root->value = p->value;
		return del_node(p,p->value);
	}
	return root; } //==========================================以下是删除节点的内存的函数==================
//删除结点
void rdt_delete(rdt* root){ if(root==NULL) return ;
	rdt_delete(root->ln);
	rdt_delete(root->rn);
	delete root;
	root = NULL;
} //==========================================以下是返回头结点的函数======================
rdt* rdt_head(rdt* p){ if(p==NULL) return NULL;
	while(p->pa!=NULL){ p= p->pa;
	}
	return p;
} //==========================================以下是通过数组构建红黑树的函数==============
//给定一个vector<int> 构建一个红黑树，放回开始结点。
rdt* rdt_init(vector<int> &nums){
	if(nums.empty()) return NULL;
	rdt* root = new rdt(false,nums[0]);
	rdt* old_root=root; if(nums.size()==1){
		return root;
	}else{
		for(int i=1;i<(int)nums.size();++i){
			root = add_node(old_root,nums[i]);
			if(DE_BUG) cout<<"value: "<<nums[i]<<" root: "<<(root==NULL?-1:old_root->value)<<endl; if(root==NULL) continue; 
			if(DE_BUG) rdt_print(root);
			if(DE_BUG) cout<<endl;
			old_root = root;
		}
	}
	rdt* head = rdt_head(old_root);
	return head;
} //==========================================以下是打印红黑树的函数======================
//广度遍历整个树，将数据存在data中。
void rdt_bfs(vector<pair<int,int> >& data,rdt* root){
	queue<rdt*> rdt_q;
	rdt_q.push(root);
	rdt* p;
	data.push_back(pair<int,int>(root->value,root->isred));
	while(!rdt_q.empty()){
		p = rdt_q.front();
		rdt_q.pop();
		if(p->ln!=NULL){
			rdt_q.push(p->ln);
			data.push_back(pair<int,int>(p->ln->value,p->ln->isred));
		}else{
			data.push_back(pair<int,int>(-1,-1));
		}
		if(p->rn!=NULL){
			rdt_q.push(p->rn);
			data.push_back(pair<int,int>(p->rn->value,p->rn->isred));
		}else{
			data.push_back(pair<int,int>(-1,-1));
		}
	}
}
 
//打印红黑树，通过广度遍历后打印数据。
void rdt_print(rdt* root){
	vector<pair<int,int> > data;
	rdt_bfs(data,root);
	if(DE_BUG) cout<<"bfs rdt ,data is "<<data.size()<<endl;
	int layer=1,tt = 1,t=0,sum=1;
	while(sum<=(int)data.size()-1){
		tt<<=1;
		sum += tt;
		layer++;
	}
	int count = 1;
	while(layer>=0){
		for(int i=0;i<layer;++i) cout<<"  ";
		for(int i=0;i<count;++i){
			cout<<to_string(data[t].first)<<","<<to_string(data[t].second)<<"  ";
			t++;
			if(t>=(int)data.size()) return ;
		}
		cout<<endl;
		layer--;
		count <<= 1;
	}
} //====================================main函数=================================
int main(){
	//rdt root(false,2);
	//rdt t1(false,1);
	//rdt t2(false,3);
	//root.ln = &t1;
	//root.rn = &t2;
	//t1.pa = &root;
	//t2.pa = &root;
	//rdt_print(&root);
	//return 0;
	int nm[10] = {1,3,5,6,8,9,10,4,7,2};
	vector<int> nums(nm,nm+10);
	rdt* root = rdt_init(nums);
	rdt_print(root);
	int va;
	rdt* p;
	cout<<"\ninput value for del: ";
	while(cin>>va){ if(va==-1) break;
		p = del_node(root,va); if(p!=NULL){
			rdt* head = rdt_head(p);
			root = head;
			cout<<endl;
			rdt_print(head);
		}else{
			if(root->isred){
				cout<<"the rdt is empty"<<endl;
				break;
			}else{
				cout<<"\nerror ,no such value"<<endl;
			}
		}
		cout<<"\ninput value for del: ";
	}
	rdt* h = rdt_head(root); if(h!=NULL) rdt_delete(h);
	return 0;
}
```

