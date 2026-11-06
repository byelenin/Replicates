# EK2002

复现 Eaton & Kortum (2002), *Technology, Geography, and Trade*（Econometrica）的论文结果。

复现所需的原始数据与代码放在 [`Technology, Geography and Trade/`](Technology,%20Geography%20and%20Trade/) 目录下，主体代码为 Jupyter Notebook `code.ipynb`，按论文的实证与反事实部分依次排列。

## 目录与文件说明

| 文件 | 功能 |
| --- | --- |
| `code.ipynb` | 复现代码，覆盖数据读取、描述性统计、回归估计与反事实模拟，按章节顺序执行 |
| `trade1.fmt` | 原始二进制数据：双边贸易额、距离分档、是否接壤，以及研发、人力资本、人口密度、劳动力与工资等国家特征 |
| `trade2.fmt` | 原始二进制数据：教育年限、国内贸易额、进口额、制造业支出等 |
| `trade3.fmt` | 原始二进制数据：各国总进口、总出口、名义工资、研发存量、劳动力、人口密度 |
| `datafe.fmt` | 原始二进制数据：汇率、制造业劳动力、名义工资、19×19 贸易矩阵、GDP，以及由回归系数合成的地理障碍矩阵 |
| `getdist.dat` | 双边距离数据（单位：千英里） |
| `pppdat1.prn` | 18 国 50 种制造业商品的价格数据（美国为基准，代码中补零） |
| `country_code.csv` | 19 个样本国的编号、缩写与国名对照表 |
| `regression_data.csv` | 整理好的回归样本：在原始数据基础上补充 `common_language`、`both_in_EU`、`both_in_EFTA` 等虚拟变量与距离变量，并含论文已计算好的因变量 `trade_prime`，供回归部分直接读取 |

其中 `.fmt` 文件为不带格式说明的 Fortran 二进制文件，由 notebook 中的 `read_ek_data` 按固定字节偏移与 `float64` 类型读入。

## 环境与依赖

- Python 版本：3.13.5
- 依赖版本：

```text
pandas==3.0.5
numpy==2.5.2
matplotlib==3.11.1
scipy==1.18.1
statsmodels==0.15.0
```

运行 notebook 还需要 Jupyter Notebook 或 JupyterLab。

## 复现流程

notebook 自上而下分为四块，依次对应论文的各个部分：

1. **数据读取与整理**：读取上述原始文件，拼接为各国信息表、双边贸易表与价格表，并完成工资、劳动力的人力资本调整及少数缺失/异常值的修正。
2. **描述性统计**：
   - Table I / Figure I：样本国的进口占制造业支出比重、工资、劳动力、制造业占 GDP 比重，以及标准化进口份额与距离的关系。
   - Table II / Figure II：用价格数据构造的价格度量，及其与标准化进口份额的关系。
3. **回归与参数估计**：贸易方程的 OLS 与 GLS、用工资和价格数据估计 `θ`、各国技术水平与地理障碍估计，对应 Table III–Table VII。
4. **反事实模拟**：先求解基准均衡（工资、价格、贸易份额），再依次模拟自给自足、零地理障碍、贸易翻倍、提高美国/德国技术水平、移除关税、移除 EC 内关税等情形，对应 Table VIII–Table XII 与 Figure III。每个情形均区分劳动力可流动与不可流动两种设定。

## 表格与代码位置

下表给出论文各表/图在 `code.ipynb` 中对应的输出单元格。单元格序号按当前 notebook 从上到下、从 0 开始（与 `.ipynb` JSON 顺序一致），`In [n]` 为 notebook 中保存的执行编号；增删单元格或重新运行后编号会变化，可用「小节标题」列的文字搜索定位。

| 论文表/图 | 小节标题 | 输出单元格（序号 / In [n]） | 内容 |
| --- | --- | --- | --- |
| Table I | `### Table I` | 13 / In [10] | 各国进口、工资、劳动力、制造业占 GDP 比重等描述统计 |
| Figure I | `### Figure I` | 20 / In [15] | 标准化进口份额与距离 |
| Table II | `### Table II` | 26 / In [19] | 价格度量及其与标准化进口份额的关系 |
| Figure II | `### Figure II` | 28 / In [20] | 横轴为价格度量 `Dni`、纵轴为标准化进口份额对数的散点图 |
| Table III | `#### Table III` | 45 / In [27] | GLS 回归结果；基准 OLS 输出在 38 / In [25]，未单独编号 |
| Table IV | `#### Table IV` | 48 / In [29] | 研发存量、教育、劳动力、密度的描述统计 |
| Table V | `#### Table V` | 52 / In [31]、55 / In [34] | 工资数据的 OLS 与 IV 估计；价格数据的对照估计在 58 / In [36]、59 / In [37]，未单独编号 |
| Table VI | `#### Table VI` | 64 / In [39] | 各国技术水平 |
| Table VII | `#### Table VII` | 68 / In [40]、69 / In [41] | 地理参数与目的地参数 |
| Table VIII | 无单独标题 | 无汇总输出（参数见 60、75–76、82、85–87） | 反事实所用参数汇总（`θ`、`β`、`α`、`T`、`d_ni`） |
| Table IX | `#### Table IX` | 98 / In [56] | 自给自足的福利效应 |
| Table X | `#### Table X` | 106 / In [60] | 零地理障碍与贸易翻倍 |
| Figure III | `#### Figure III` | 109 / In [63]、111 / In [64] | 全样本与丹麦/德国两张图 |
| Table XI | `#### Table XI` | 125 / In [75] | 提高技术水平 |
| Table XII | `#### Table XII` | 149 / In [94] | 移除 EC 内关税 |

## 如何使用

1. 按上一节安装 Python 与依赖。
2. 在 `Technology, Geography and Trade/` 目录下启动 Jupyter，打开 `code.ipynb`。
   notebook 使用相对路径读取数据，工作目录必须为该目录。
3. 从头依次运行全部单元格。表格与图形在对应单元格输出，反事实部分会先求解基准均衡，再逐个场景求解，运行时间主要花在这一部分。

各段落的 markdown 单元格写有论文公式、变量口径与实现上的取舍说明，可与代码对照阅读。
