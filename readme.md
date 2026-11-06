# Introduction

This project is all about presenting and replicating materials of a couple of papers for [Applied Microeconometrics:From Reduced Form to Structural Econometrics](https://byelenin.github.io/AME2026/) course taught by Zhaopeng Qu at Nanjing University. 


Every paper will be replicated in a separate repository.






## Structure 

The repositories will be structured as follows:

| Folder | Contents |
| --- | --- |
| `RawPaper` | The paper itself, the appendix, and other documents of the paper |
| `Original_code` | The original code provided by the paper author |
| `Student_code` | The replication code written by myself and students |

`Original_code` and `Student_code` each contain a `README.md` that explains the structure of that folder and the purpose of the code. Inside each of them:

| Folder | Contents |
| --- | --- |
| `data` | The data used in the paper |
| `code` | The code used to replicate the paper. In `original_code`, this is the code provided by the paper author |
| `results` | Tables and figures from the replication |

The code will be written in Stata/R/Matlab and will be used to replicate the paper.

## Reading List

The five readings below follow the order in the course [reading list and presentation schedule](https://byelenin.github.io/AME2026/readings/readings.html) (`AME2026/readings/readings.qmd`). Each presentation covers the model, identification, estimation, counterfactual, and replication. Bibliographic details refer to the published journal articles.

| # | Full citation | Reading and replication task | Presentation (2026) | Materials |
| --- | --- | --- | --- | --- |
| 1 | Lagakos, David, and Michael E. Waugh. 2013. “Selection, Agriculture, and Cross-Country Productivity Differences.” *American Economic Review* **103** (2): 948–980. [DOI: 10.1257/aer.103.2.948](https://doi.org/10.1257/aer.103.2.948). | Reproduce the selection share reported in the paper’s table. | W9 (October 22, 2026)<br>朱迅、赵佳琳、曲兆鹏. | [Repository folder](Lagakos_Waugh_2013/) · [Presentation slides](https://byelenin.github.io/AME2026/slides/Lagakos_Waugh_2013_Pre.pdf). |
| 2 | Bryan, Gharad, and Melanie Morten. 2019. “The Aggregate Productivity Effects of Internal Migration: Evidence from Indonesia.” *Journal of Political Economy* **127** (5): 2229–2268. [DOI: 10.1086/701810](https://doi.org/10.1086/701810). | Decompose productivity differences into selection and true productivity components. | W10 (October 29, 2026)<br>陈冠宇、任娜、冯诗语. | [Repository folder](Bryan_Morten_2019/) · [Presentation slides](https://byelenin.github.io/AME2026/slides/Bryan_Morten_2019_Pre.pdf). |
| 3 | Eaton, Jonathan, and Samuel Kortum. 2002. “Technology, Geography, and Trade.” *Econometrica* **70** (5): 1741–1779. [DOI: 10.1111/1468-0262.00352](https://doi.org/10.1111/1468-0262.00352). | Derive the sourcing probability $\pi_{ni}$; the course schedule pairs this with gravity estimation using workshop data. | W11 (November 5, 2026)<br>王猛、吴迪、卢禹翔. | No replication files are currently included in the local `Eaton_Kortum_2002/` directory. |
| 4 | Ahlfeldt, Gabriel M., Stephen J. Redding, Daniel M. Sturm, and Nikolaus Wolf. 2015. “The Economics of Density: Evidence From the Berlin Wall.” *Econometrica* **83** (6): 2127–2189. [DOI: 10.3982/ECTA10876](https://doi.org/10.3982/ECTA10876). | Explain the counting argument used for model inversion. | W12 (November 12, 2026)<br>刘雨洁、江逸慧、唐文森. | The course reading list points to the Econometrica archive; a dedicated repository folder has not yet been added. |
| 5 | Tombe, Trevor, and Xiaodong Zhu. 2019. “Trade, Migration, and Productivity: A Quantitative Analysis of China.” *American Economic Review* **109** (5): 1843–1872. [DOI: 10.1257/aer.20150811](https://doi.org/10.1257/aer.20150811). | Work through one step of hat algebra. | W13 (November 19, 2026)<br>任红阳、宋文琦、刘佳佳. | The [journal article page](https://www.aeaweb.org/articles?id=10.1257/aer.20150811) links to the replication package and supplemental appendix; a dedicated repository folder has not yet been added. |
