# Report templates

Translate headings into the user's language and script. Fill every section with verified facts; delete sections that do not apply rather than leaving placeholders.

## 技术说明.md (audit)

```
# 技术说明：<Author (Year)> 复现与求解的技术要点
日期：<YYYY-MM-DD>
<一段话结论：复现覆盖什么、是否一致、最大的问题是什么>

## 一、版本与覆盖范围
  版本核对表；原版 driver → 复现脚本/情景 的对照表；缺口与新增
## 二、代码对照
  参数逐项核对表（含原始文件名）；改写的数学等价性证明；需要保留的原作者行为；原代码 bug；论文与代码不一致
## 三、运行与验证
  运行方式与结果（哨兵、assert、耗时）；重跑一致性；与论文表格的对照摘要（详见 复现对照表.md）
## 四、技术难点
  数据端 / 模拟端 / 求解端 / 验证端
## 总结
---
## 附一：<数据矩的构造>（例如 CPS 协方差的含义）
## 附二：模型的求解
## 附三：参数的估计/校准方法（GMM/SMM/MLE…）
## 附N：不一致清单
```

## 复现对照表.md

```
# 复现对照表：<Author (Year)>
数据来源：论文版本 <…>；复现输出 <文件、运行时间>
图例：✅ 四舍五入后一致　🟡 小偏差　❌ 实质偏差

## 校准目标（应按构造一致）
| 目标 | 论文 | 复现 | 状态 |

## 表 X：<标题>（对应 情景 …）
| 行 | 列 | 论文 | 复现 | 状态 | 备注 |

## 偏差汇总与可能原因
```

## PPT修改建议.md

See `slide-review.md` → Output.

## 技术笔记.md (teaching notes)

Self-contained, for students. Explain from first principles; prefer derivations, toy numeric examples and short code excerpts over prose.

```
# 技术笔记：<Author (Year)> 的模型、估计与求解
## 1. 研究问题与核心机制（一页）
## 2. 模型：环境、个体最优、加总、均衡定义
## 3. 均衡求解：化简为最少的方程 → 闭式特例 → 为何无显式解 → 数值算法（原版 vs 复现代码节选）
## 4. 参数从哪里来：分层校准/估计
   4.1 数据矩如何构造（含玩具例子）
   4.2 模型矩 m(β) 如何计算
   4.3 目标函数与算法
   4.4 识别直觉与闭式检验
   4.5 与 GMM / SMM / MLE 理论的关系；标准误如何补上
## 5. 定量实验与结果（复现 vs 论文）
## 6. 局限与后续文献
## 附：课堂练习
```

## Teaching deck

One slide per message, following the notes' sections. Each estimation slide should show: the moment/likelihood, the model counterpart, and the identification intuition. Each solution slide: the reduced equation, the closed-form special case, the algorithm. Results slides: paper vs replication tables with status marks.
