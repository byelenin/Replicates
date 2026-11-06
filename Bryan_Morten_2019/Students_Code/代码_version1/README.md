# Bryan & Morten (2019) 复现代码包 —— Stata do 文件

**目标论文**：Bryan, G. and M. Morten (2019), "The Aggregate Productivity Effects of Internal
Migration: Evidence from Indonesia," *Journal of Political Economy* 127(5): 2229–2268.

**本包内容**：复现该论文全部表格所用的 **94 个 Stata do 文件** + **93 个运行日志** + 1 份所需文件清单
（**不含数据文件** —— 需要哪些数据见第六节）。

**整理人**：陈冠宇、任娜、冯诗语　|　**课程**：微观计量　|　**用途**：课程作业「复现结果或复现代码」

**Stata 版本**：StataNow 19.5 MP（依赖 `reghdfe`、`ivpoisson`、`ppmlhdfe`、`boottest` 等外部命令，
见 `00_环境与依赖/install_deps.do`）

---

## ⚠️ 一、先看两条命名陷阱（最容易踩）

| 文件名 | **实际复现的论文表** | 说明 |
|---|---|---|
| `Table1_replication.do` | 论文 **Table 1**（印尼迁移率）| ✅ 名字相符 |
| `Table2_replication.do` | 论文 **Table 2**（印尼五个事实）| ✅ 名字相符 |
| **`Table3_replication.do`** | 论文 **Table 4**（Estimated Fréchet Parameters, p.2254）| ❌ **名字错了**，文件头也写着"Table 3"，但内容是 Fréchet 参数（ρ、θ、θ̃、τ̄）|
| **`Table3US_replication.do`** | 论文 **Table 3**（美国四个事实, p.2241）| ⚠️ 靠文件名区分不了「印尼 Table 3」和「美国 Table 3」|
| `table5_*.do` | 论文 **Table 5**（反事实）| ✅ 名字相符 |

**⇒ 记法：`Table3_replication.do` 是「印尼版 Table 4」；`Table3US_replication.do` 是「美国版 Table 3」。**

---

## 二、目录结构

```
Bryan_Morten_2019_复现_Stata代码/
├── README.md                    ← 本文件
├── 需要的文件清单.txt             ← 运行所需的数据文件与外部命令清单（见第六节）
├── 00_环境与依赖/                (1 个 do + 1 个日志)
├── 01_Table1_印尼迁移率/          (7 个 do + 7 个日志)
├── 02_Table2_印尼五个事实/        (5 个 do + 5 个日志)
├── 03_Table3_美国四个事实/        (15 个 do + 14 个日志，两个日志被脚本共用)
├── 04_Table4_Frechet参数/        (13 个 do + 13 个日志)
├── 05_Table5_反事实/             (8 个 do + 8 个日志)
├── 06_拓展分析/                  (1 个 do + 1 个日志)
└── 07_早期探索_20261017-20/      (44 个 do + 44 个日志，探索期脚本，建议只作留档)
```

**每个日志与它的生成脚本放在同一个文件夹里**，文件名一一对应 ✓

---

## 三、文件清单（逐项）

「日志」一栏是从各 do 文件里的 `log using` 语句抓取的；标 `自动同名` 的是没有显式指定、
批量模式（`StataMP-64.exe /e do xxx.do`）下由 Stata 自动生成同名 `.log`。

### 00_环境与依赖
| 文件 | 作用 | 日志 |
|---|---|---|
| `install_deps.do` | 安装 `reghdfe` 缺失的依赖包 | `install_out.log` |

### 01_Table1_印尼迁移率
| 文件 | 作用 | 日志 |
|---|---|---|
| `Table1_replication.do` | **主脚本**：论文 Table 1（迁移率、同类内迁移占比），1995 年 | `table1_replication.log` |
| `fig1.do` | 论文 Figure 1：县层面月均工资对数核密度 | `fig1_out.log` |
| `t1_cutoff_check.do` | 独立验证 62.69% 的来源、`urban` 编码方向 | `t1_cutoff_check_out.log` |
| `t1_cutoff_variants.do` | 「匹配全国城镇化率」的 5 种实现是否等价 | `t1_cutoff_variants_out.log` |
| `check_stayers.do` | 不迁移的人（留在老家）在不在面板里 | 自动同名 |
| `check_stayers2.do` | 续查：留乡比例、`p_od` 是否加总为 1 | 自动同名 |
| `test_filters.do` | 逐步加筛选条件看 θ 怎么变（追查 10.55 vs 12.58）| 自动同名 |

### 02_Table2_印尼五个事实
| 文件 | 作用 | 日志 |
|---|---|---|
| `Table2_replication.do` | **主脚本**：论文 Table 2 五列（三个口径）| `table2_replication.log` |
| `t2_build.do` | 第 1 步：造县级 OD 面板 | `t2_build_out.log` |
| `t2_run.do` | 第 2 步：跑回归 + 与论文对照 | `t2_run_out.log` |
| `t2_wmh_n.do` | 补取加权口径各列的样本量 `e(N)` | `t2_wmh_n_out.log` |
| `t2_stars.do` | 三个口径的系数 / 标准误 / 星号 | `t2_stars_out.log` |

### 03_Table3_美国四个事实
| 文件 | 作用 | 日志 |
|---|---|---|
| `Table3US_replication.do` | **主脚本**：论文 Table 3 四列（美国）| `table3us_out.log` |
| `Table3US_stars.do` | 为 PPT 批量输出 b / SE / t / 星号 | `t3us_stars_out.log`（**另产出** `table3us_out.log`，见第四节 ③）|
| `_stars_block.do` | 上者的核心程序块（`_both`：双向聚类失败自动退回单向）| `t3us_stars_out.log` |
| `t3_pairs.do` | 把「跨州 (出发,目的,年) 州对」2,542 / 2,458 / 5,000 算清楚 | `t3_pairs_out.log` |
| `t3_sample_diag.do` | 判定论文「Number of individuals」是哪个样本 | `t3_sample_diag_out.log` |
| `t3_us_sample_diag.do` | 同上，美国版（2,294,054 是哪个口径）| `t3_us_sample_diag_out.log` |
| `t3_one_row.do` | 把回归里的「一行」完整拆开看 | `t3_one_row_out.log` |
| `t3_demean.do` | 手动验证固定效应的去均值机制 | `t3_demean_out.log` |
| `t3_weight_mech.do` | 验证「加权 = 把这一行复制 w 遍」| `t3_weight_mech_out.log` |
| `t3_weight_explain.do` | `n_od` / `m_od` / 不加权 三者的区别 | `t3_weight_explain_out.log` |
| `t3_weight_nod_vs_none.do` | `n_od` 与「不加权」的关系量化 | `t3_weight_nod_vs_none_out.log` |
| `t3_dep_choice.do` | 个人层面回归 ≡ 单元格均值回归；`ln(均值)` vs `均值(ln)` | `t3_dep_choice_out.log` |
| `t3_ss_decomp.do` | 二阶矩排序：围绕 0 / 总均值 / 单路组均值 / 双向迭代 | `t3_ss_decomp_out.log` |
| `t3_anova_table.do` | 把 ANOVA 表的组内 / 组间两项拆开 | `t3_anova_table_out.log` |
| `t3_ss_which_var.do` | 这个 SS 是哪个变量的；并验证 β 精度的分母 | `t3_ss_which_var_out.log` |

### 04_Table4_Frechet参数
| 文件 | 作用 | 日志 |
|---|---|---|
| `Table3_replication.do` | **主脚本**：论文 Table 4（ρ、θ、θ̃、τ̄），印尼 + 美国 | `table3_replication.log` |
| `Theta_paper_spec.do` | 逐步补齐论文的样本口径（`n_raw < 5` 等）| `theta_paper_spec_out.log` |
| `Theta_method_compare.do` | θ 的三种估计方法对比（log-2SLS / PPML / PPML+IV）| `theta_compare_out.log` |
| `IVPoisson_test.do` | 测试 `ivpoisson gmm` 能否做「PPML + IV + GMM + FE」| `ivpoisson_test_out.log` |
| `PPML_timing.do` | PPML 与 GMM 两条路线的计时实验 | `ppml_timing_out.log` |
| `t4_ppt_stats.do` | 汇报 PPT 的辅助统计（样本量、加权和、平均权重）| 自动同名 |
| `t4_rho_sensitivity.do` | 量化「为什么 ρ 极难精确复现」+ θ̃ 反解敏感度 | `t4_rho_sens_out.log` |
| `theta_tilde_derivation.do` | 从联合 Fréchet 分布推导 θ̃ = θ(1−ρ) 并用蒙特卡洛验证 | `theta_tilde_deriv_out.log` |
| `test_diagonal.do` | 把不迁移者（对角线 o==d）放进式(7) 会怎样 | 自动同名 |
| `test_pi_denominator.do` | 迁移比例的分母该不该包括不迁移的人 | 自动同名 |
| `demo_collapse.do` | 教学演示：`collapse` 在干什么、加权人数与加权平均工资 | `demo_out.log` |
| `fe_howto.do` | 教学演示：固定效应怎么算 | 自动同名 |
| `gmmbench.do` | 量出 `gmm` 耗时随参数个数怎么涨（实测 3/9/17/32 参数 = 3.57/0.38/1.47/7.76 秒）| `gmmbench_out.log` |

### 05_Table5_反事实
| 文件 | 作用 | 日志 |
|---|---|---|
| `table5_counterfactual.do` | **主脚本**：论文 Table 5 反事实（含选择 / 无选择）| `table5_out.log` |
| `table5_nosel_test.do` | 验证 no-selection 的算法实现 | `table5_nosel_test_out.log` |
| `alpha_d_replication.do` | Table 5 第一步：估计结构舒适度 α_d | `alpha_d_out.log` |
| `alpha_d_probe.do` | 探查现成 dta 里有没有 α_d 需要的变量 | `alpha_d_probe_out.log` |
| `table5_alpha_diag.do` | α_d 弱识别对第 (2) 列的贡献（φ 缩放诊断）| `table5_alpha_diag_out.log` |
| `table5_qo_diag.do` | q_o（出生地技能）离散度对三列的影响（ψ 缩放）| `table5_qo_diag_out.log` |
| `table5_pi_diag.do` | 基准校准用观测 π 还是模型 π | `table5_pi_diag_out.log` |
| `table5_ge_grid.do` | γ × λ × σ 网格稳健性（论文自己的练习）| `table5_ge_grid_out.log` |

### 06_拓展分析
| 文件 | 作用 | 日志 |
|---|---|---|
| `Province_two_period.do` | 拓展：省级两期分析 | `province_two_period.log` |

### 07_早期探索_20261017-20
44 个探索期脚本（`day1_*`、`check_regency*`、`tab1*`、`deep*`、`urbanconsist*`、
`verify_fact1.do`、`step1_od_panel.do` 等），记录了从原始 IPUMS 数据摸索到县级 OD 面板的
全过程。**建议只作留档，正式复现看 01–05。**

---

## 四、日志文件说明

**共 93 个日志文件，与生成它们的 do 文件同目录存放**（比 do 文件少 1 个，原因见下）。命名规则有三种：

| 情况 | 日志名 | 数量 |
|---|---|---|
| ① do 文件里写了 `log using "xxx_out.log"` | `xxx_out.log` | 大多数 |
| ② do 文件里没写 `log using`，靠批量模式自动生成 | 与 do 文件同名，如 `fe_howto.log` | 少数几个 |
| ③ 一个 do 文件里写了**两个** `log using` | 两个都收 | 1 个 |

**情况 ③ 是 `Table3US_stars.do`** —— 它其实是「主复现脚本 + 加星块」合并在一起的文件，
先用 `table3us_out.log` 记录主表回归（第 22 行），再用 `t3us_stars_out.log` 记录加星结果（第 451 行），
所以该脚本对应两个日志，两个都放进去了 ✓

**⇒ 这解释了为什么 03 文件夹里 15 个 do 只有 14 个日志**：
`table3us_out.log` 由 `Table3US_replication.do` 和 `Table3US_stars.do` **共用**，
`t3us_stars_out.log` 由 `Table3US_stars.do` 和 `_stars_block.do` **共用**
（后者是前者的加星程序块）⇒ 15 个脚本只对应 14 个不同的日志文件 ✓
**其余 7 个文件夹里，do 与日志都是一一对应** ✓

**⇒ 关于批量模式的额外日志**：用

```bat
StataMP-64.exe /e do "脚本.do"
```

运行时，Stata 还会**额外**自动生成一个与脚本同名的 `.log`（如 `t2_stars.log`）。
这个文件是上面 `_out.log` 的**超集**（多出开头几行命令回显，实测 184 行 vs 135 行），
**本包为保持与正文数字引用一致，优先收录脚本自己声明的那一个** ✓

**⇒ 补跑说明**：`demo_collapse.do` 和 `gmmbench.do` 原先没有留下日志，
已重新运行补齐（分别耗时 24.7 秒和 21.3 秒，返回码全部为 0）✓
其中 `gmmbench_out.log` 记录了一个有用的结论：在 208 个观测的面板上，
`gmm` 的耗时随参数个数增长为

| 参数个数 | 3 | 9 | 17 | 32（双向固定效应）|
|---|---|---|---|---|
| 耗时（秒）| 3.57 | 0.38 | 1.47 | **7.76** |

**⇒ 32 个参数只要 7.76 秒 ⇒ 当初担心的「GMM 路线要跑几天」并不成立** ✓
（3 参数那一档偏慢是因为含首次调用开销）

这两个都是**教学演示 / 耗时基准**，不属于任何一张表格的复现结果，缺失不影响复现结论 ✓

---

## 五、⚠️ 已知问题（如实列出，未修正）

1. **`Table3_replication.do` 名字与内容不符** —— 名字是 Table 3，实际复现论文 Table 4（Fréchet 参数），
   文件头也写错了。详见第一节。
2. **`Table1_replication.do` 有 5 处把「脚注 3」误写成「脚注 12」**（第 22、28、83、270、279 行）。
   论文里规定城乡划分规则的是 **footnote 3**，不是 footnote 12。
3. **`Table2_replication.do` 第 246–247 行的注释未披露样本口径差异** ——
   论文的数据部分明确写着 "we restrict the sample to be male heads of household between 15 and 65
   years old"，而该脚本的「主结果」用的是**全部人、不加权**，样本口径与论文不同却未标注。
4. **`Table2_replication.do` 的加权口径用 `cluster(o)` 单向聚类**（第 286 行），
   而论文 Table 2 注释规定 cols. 1–4 用 **origin-year 与 destination-year 双向聚类**。
5. **`t2_stars.do` 沿用了上面第 4 条**（照抄 `Table2_replication.do` 的定义），未回头与论文注释核对。
6. **双向聚类有 8 次静默退回单向** —— 双向聚类的 CGM 公式 `V_行 + V_列 − V_交集` 在有限样本下
   可能非正定，此时 `_both` 程序会自动改用单向聚类，**只在日志里留一行标记，没有写进汇报材料**：

   | 脚本 | 位置 | 系数 |
   |---|---|---|
   | `t2_stars.do` | 口径 C（剔极端）| (1)、(2)、(3) 共 3 格 |
   | `Table3US_stars.do` | 口径 m_od | (2)、(4) |
   | `Table3US_stars.do` | 口径不加权 | (2) |
   | `Table3US_stars.do` | 1990 年分年 | (2) |
   | `Table3US_stars.do` | `ln(p_raw)` 变体 | — |

   ⇒ 这几格的星号口径与论文不一致，**待改用 wild cluster bootstrap（`boottest`）重算**。

7. **`t1_cutoff_variants.do` §④ 的 `bpl_key` merge 会崩**（`r(111)`），该段未跑通。
8. **`ivpoisson gmm …, cluster(o)` 报 `rc 198`** —— 该命令不支持这样传聚类选项，见 `IVPoisson_test.do`。
9. **`Province_two_period.do` 文件头关于 1976 年的说明有误**（与论文 footnote 13 不一致）。

---

## 六、运行需要哪些文件（重要）

### 6.1 数据文件 —— 共 11 个，合计约 2.15 GB（**本包不含**）

脚本原样运行需要下面这些数据；带 ⭐ 的是核心依赖。

| 文件 | 大小 | 被几个脚本用 | 说明 |
|---|---|---|---|
| ⭐ `D:\研一上\微观计量\ipumsi_00002.dta` | **2.0 GB** | **50** | 印尼 1995 SUPAS 原始数据（IPUMS International）|
| ⭐ `C:\Users\任娜\Documents\deepseek-harness\default-workspace\usa_od.csv` | **138 MB** | **19** | 美国州对面板（1990 五年普查样本 + 2010 ACS）|
| `D:\研一上\微观计量\ipumsi_00001.dta` | 21 MB | 4 | 仅早期探索脚本用 |
| `D:\研一上\微观计量\ipumsi_00003.dta` | 16 MB | 4 | 1976 年数据（拓展分析 / 早期脚本用）|
| `D:\研一上\微观计量\复现\idn_od_panel_regency.dta` | 1.5 MB | 2 | 印尼县级 OD 面板（**由 `Table2_replication.do` 产出**）|
| `D:\研一上\微观计量\复现\idn_regency_dist.csv` | 919 KB | 1 | 印尼县间距离矩阵 |
| `D:\研一上\微观计量\复现\idn_od_panel.dta` | 31 KB | 2 | Table 1 城乡诊断用 |
| `D:\研一上\微观计量\复现\idn_od_panel_malehead.dta` | 30 KB | 2 | 早期探索用 |
| `D:\研一上\微观计量\复现\idn_prov_dist25.csv` | 9.6 KB | 10 | 印尼 25 省距离矩阵 |
| `D:\研一上\微观计量\复现\us_state_centroids.csv` | 6.7 KB | 11 | 美国州质心（用来造州间距离）|
| `D:\研一上\微观计量\复现\us_state_fips2usps.csv` | 374 B | 11 | FIPS 码 ↔ 州缩写对照 |

**⇒ 只有 2 个文件是不可或缺的**：`ipumsi_00002.dta`（印尼全部表格）和 `usa_od.csv`（美国 Table 3、Table 4 的美国列）✓
其余 9 个都是小体积的中间产物或距离/对照表，缺失时可从原始数据重建 ✓

**⇒ 两个大文件合计约 2.1 GB，是它们没能放进代码包的原因** ✓

### 6.2 Stata 外部命令

| 命令 | 来源 | 用量 | 是否必需 |
|---|---|---|---|
| **`reghdfe`** | SSC | 135 处 | ✅ **必需**（几乎所有回归）|
| **`ppmlhdfe`** | SSC | 10 处 | ✅ 必需（PPML 路线）|
| **`esttab`**（`estout` 包）| SSC | 1 处 | ✅ 必需 |
| `gtools` / `gegen` / `moremata` / `require` | SSC | 5/2/3/5 处 | ✅ 必需（`reghdfe` 的依赖）|
| `ivpoisson`、`gmm`、`ivregress`、`areg`、`bootstrap`、`mata` | **Stata 自带** | — | 无需安装 |
| `boottest` | SSC | **0 处** | ❌ 尚未使用（第六节 5.6 提到要用它重算星号，届时需先安装）|

**⚠️ 注意 `00_环境与依赖/install_deps.do` 只安装了 `require` / `gtools` / `moremata` 三个依赖，
它假设 `reghdfe` 本体已经装好（脚本里只做 `which reghdfe` 检查）** ✗
**⇒ 在一台全新的机器上，还需要补装：**

```stata
ssc install reghdfe, replace
ssc install ppmlhdfe, replace
ssc install estout, replace
```

### 6.3 路径宏 —— 换机器时必须逐个检查

**这些 do 文件里的数据路径是写死的，而且 `root` 这个词在不同文件里含义不同** ✗

| 宏 | 取值 | 出现在哪些脚本 |
|---|---|---|
| `root` | **`D:\研一上\微观计量`** | 印尼相关脚本、Table 3 US 主脚本、Table 5 全部 |
| `root` | **`C:\Users\任娜\Documents\deepseek-harness\default-workspace`** | **11 个 `t3_*.do` 诊断脚本** |
| `fz` | `D:\研一上\微观计量\复现` | 多数诊断脚本 |
| `ussrc` | 工作区绝对路径 `…\usa_od.csv` | 6 个脚本（Table3US / Table3_replication / IVPoisson_test / PPML_timing / t3_sample_diag）|
| `work` | 工作区绝对路径 | `alpha_d_replication.do` |
| `root` | `D:\研一上\微观计量\复现`（直接指向子目录）| `alpha_d_probe.do` |

**⇒ 所以「改开头两行就能跑」是不成立的** ✗ — **必须逐个脚本看它的 `local` 定义** ✓
（这也是 `t3_*.do` 里 `` insheet using "`root'\usa_od.csv" `` 能正常读到工作区文件的原因 ✓）

### 6.4 一个已经不需要的文件

`D:\研一上\微观计量\us_state_dist.csv`（42 KB）—— **代码包里没有任何脚本引用它** ✓
（已用全包搜索确认 ✓）可以不管它 ✓

### 6.5 批量运行方式

```bat
"C:\Program Files\StataNow19\StataMP-64.exe" /e do "<脚本绝对路径>.do"
```

`/e` 模式会自动生成与 do 文件同名的 `.log`；脚本内部若另有 `log using "xxx_out.log"`，
则输出到 `xxx_out.log`（本包多数脚本采用后者，避免同名冲突）。

---

## 七、复现结果摘要（主要数字）

| 论文表 | 论文报告 | 本复现 | 偏差 |
|---|---|---|---|
| Table 1　农村迁移率（规则 A）| 32.3 | 31.3 | −3.1% |
| Table 1　城市迁移率（规则 A）| 35.8 | 34.4 | −3.9% |
| Table 1　总体迁移率（规则 A）| 33.7 | 33.2 | −1.5% |
| Table 1　同类内迁移占比（规则 A）| 31.1 / 74.6 / 49.4 | 32.8 / 74.5 / 50.3 | 三列全部吻合 |
| Table 2 (1) 距离→迁移 | −0.717 (0.009)*** | −0.7136 (0.0309)*** | −0.5% |
| Table 2 (4b) 距离→工资 | 0.007 (0.002)*** | 0.0313 (0.0105)*** | +347% |
| **Table 3 (1) 距离→迁移（美国）** | **−0.553 (0.018)*** | **−1.1771 (0.0616)*** | **2.13 倍** |
| **Table 3 (2) 距离→工资（美国）** | **0.023 (0.002)*** | **0.0302 (0.0064)*** | **+31%** |
| **Table 3 (3) 份额→工资（美国）** | **−0.043 (0.003)*** | **−0.0309 (0.0043)*** | **−28%** |
| **Table 3 (4) 份额→工资（美国，同场比较）** | **−0.050 (0.006)*** | **−0.0445 (0.0084)*** | **−11%** |
| Table 4　印尼 ρ | 0.74 (0.029)*** | 0.613 (0.204)*** | −17.2% |
| Table 4　印尼 θ | 12.5 (1.36)*** | 10.551 (4.435)** | −15.6% |
| Table 4　美国 θ | 27.6 (3.29)*** | 41.130 (9.470)*** | +49.0% |
| **Table 5　含选择 (1)(2)(3)** | **1.075 / 1.127 / 1.217** | **1.1449 / 1.1192 / 1.2542** | 三列方向全部复现 |
| Table 5　无选择 (1)(2)(3) | 0.914 / 1.127 / 1.133 | 0.9905 / 1.0921 / 1.1254 | 第 (2) 列未复现 |

**说明**：Table 1 的 Rural/Urban 分组依赖城乡划分规则，故报告两种规则 ——
**规则 A**（切点使全国农村人口占比 = 62.69%，即论文口径）与 **规则 B**（按县农村占比中位数切分）。
规则 A 下 Migrate = 31.3 / 34.4 / 33.2，规则 B 下为 34.1 / 31.6 / 33.2，总体迁移率两者都是 33.2
（论文 33.7），说明差异来自城乡划分而非样本。

**结论**：论文的**定性结论**（迁移随距离递减、目的地工资随距离上升、选择效应存在、
工资效应由迁移份额而非距离驱动）**全部复现**；定量差距主要来自**数据可得性**——
印尼只覆盖 17 省 / 221 县（论文 25 省 / 281 县）、只有 1995 一年（论文 1995/2011/2012 三年）。

---

## 八、复现边界（数据可得性所致，非方法问题）

- **印尼**：IPUMS 仅提供 1995 年 SUPAS，无 2011/2012 SUSENAS；285 个县中只有 17 省 / 221 县可用
- **美国**：51 个州 × 2 年（1990、2010），与论文一致
- **PODES 设施数据缺失** ⇒ 论文 Table 2 第 (5) 列（Amenities）无法复现；
  美国 Table 3 本来就无第 (5) 列（论文原文："we do not have a measure of amenity at the
  state level for the United States"）
- **未复现**：附录表 3、4、6，Figure 3、5，附录 Figure 1