/* Lagakos & Waugh：固定参数模型复现
   原始出处：112608-V1/Code，readme 日期 2012-08-06。
   运行环境：Stata 16 或以上；使用其内置矩阵语言 Mata，无外部扩展包。
   此文件不读取 CPS；参数已由作者另行校准。每个情景重新使用相同种子。
   输出均保存到 Stata 当前工作目录。请先在菜单中将工作目录设为本文件所在目录。
   distribution = [非农形状倒数, 农业形状倒数, Kendall tau]，不能直接当论文 theta。
   采用等价的一维市场出清求解，逐项验证农业、非农、资本和土地市场。
*/
version 16.0
clear all
set more off
set varabbrev off
set seed 32878
mata:
/* 将 Kendall tau 转为 Frank copula 参数，Simpson 积分加二分法。 */
real scalar ftau(real scalar b)
{
    real scalar h, j, x, s, v, k
    if (b<1e-5) return(b/9)
    k=2000; h=min((b,40))/k; s=1
    for (j=1;j<=k;j++) {
        x=j*h; v=x/(exp(x)-1)
        s=s+v*(j==k ? 1 : (mod(j,2) ? 4 : 2))
    }
    return(1-4/b+4*(s*h/3)/(b*b))
}
real scalar frank(real scalar tau)
{
    real scalar lo,hi,b,j
    if (tau==0) return(0)
    lo=1e-6;hi=500
    for(j=1;j<=65;j++) {
        b=(lo+hi)/2
        if(ftau(b)<tau) lo=b
        else hi=b
    }
    return((lo+hi)/2)
}
/* 稳定计算 log(exp(x)+exp(y))，防止 tau=.99 时数值相消。 */
real colvector lse(real colvector x,real colvector y)
{
    real colvector m
    m=rowmax((x,y))
    return(m:+ln(exp(x:-m):+exp(y:-m)))
}
real matrix talents(real scalar tn,real scalar ta,real scalar tau,real scalar N,real scalar seed)
{
    real matrix U
    real colvector u,w,v,za,zn
    real scalar b
    rseed(seed); U=runiform(N,2); u=U[,1]; w=U[,2]; b=frank(tau)
    if (tau==0) v=w
    else v=(lse(ln(1:-w):-b:*u,ln(w))-lse(ln(1:-w):-b:*u,ln(w):-b)):/b
    za=exp(-ta:*ln(-ln(u)):-lngamma(1-ta))
    zn=exp(-tn:*ln(-ln(v)):-lngamma(1-tn))
    return((zn,za))
}
/* 输出：Ya,Yn,pa,Na,农业/非农劳动生产率,条件平均能力,工资比,
   两商品相对超额需求,资本租金,地租,K/Y,两要素相对残差,截断消费比例。 */
real rowvector state(real matrix T,real scalar t,real rowvector P)
{
    real scalar A,Aa,phi,abar,ak,al,nk,K,L,cap,Na,La,Ln,Ya,Yn,pa,r,pl,ka,kn,q
    real scalar wa,wn,gdp,totw,Da,Dn,ea,en,er,el,corner
    real colvector a,w,inc,ca,cn
    real rowvector z
    A=P[1];Aa=P[2];phi=P[3];abar=P[4];ak=P[5];al=P[6];nk=P[7];K=P[8];L=P[9];cap=P[10]
    a=T[,1]:<t:*T[,2];Na=mean(a)
    if (Na==0 | Na==1) {
        z=J(1,18,.)
        z[10]=(Na==0 ? 1 : -1)
        return(z)
    }
    La=mean(T[,2]:*a);Ln=mean(T[,1]:*(1:-a));r=0;pl=0;er=0;el=0
    if (!cap) {
        Ya=A*Aa*La;Yn=A*Ln;pa=t/Aa;wa=pa*A*Aa;wn=A
    }
    else {
        q=t*(1-nk)/(1-ak-al)*(ak/nk)*(La/Ln)
        ka=K*q/(1+q);kn=K/(1+q)
        Ya=A*Aa*ka^ak*L^al*La^(1-ak-al);Yn=A*kn^nk*Ln^(1-nk)
        pa=t*(1-nk)*Yn/Ln*La/((1-ak-al)*Ya)
        r=nk*Yn/kn;pl=al*pa*Ya/L
        wa=(1-ak-al)*pa*Ya/La;wn=(1-nk)*Yn/Ln
        er=(ak*pa*Ya/r+nk*Yn/r-K)/K
        el=(al==0 ? 0 : (al*pa*Ya/pl-L)/L)
    }
    w=a:*wa:*T[,2]:+(1:-a):*wn:*T[,1]
    gdp=pa*Ya+Yn;totw=mean(w)
    inc=w:*(gdp/totw)
    ca=rowmin((phi:*inc:/pa:+(1-phi)*abar,inc:/pa))
    cn=rowmax(((1-phi):*(inc:-abar*pa),J(rows(T),1,0)))
    Da=mean(ca);Dn=mean(cn);ea=(Da-Ya)/Ya;en=(Dn-Yn)/Yn
    corner=mean(inc:<abar*pa)
    return((Ya,Yn,pa,Na,Ya/Na,Yn/(1-Na),La/Na/mean(T[,2]),Ln/(1-Na)/mean(T[,1]),wa*La/Na/(wn*Ln/(1-Na)),ea,en,r,pl,(cap ? K/gdp : 0),er,el,corner,t))
}
real rowvector solve(real matrix T, real rowvector P)
{
    real scalar lo,hi,mid,j,bestgap
    real rowvector z,best
    lo=-10;hi=10;bestgap=.
    for(j=1;j<=48;j++) {
        mid=(lo+hi)/2;z=state(T,exp(mid),P)
        if (abs(z[10])<bestgap & z[1]<.) {
            best=z;bestgap=abs(z[10])
        }
        if (z[10]>0) lo=mid
        else hi=mid
    }
    if (bestgap>0.0002) {
        printf("Equilibrium residual too large: %g\n",bestgap)
        _error(3498)
    }
    return(best)
}
void putdata(real matrix X,string rowvector names,string scalar fname)
{
    stata("clear")
    st_addobs(rows(X));st_addvar("double",names);st_store(.,names,X)
    stata("save "+fname+", replace")
}
void main()
{
real matrix cases,T,E,ratios,grid,params
real rowvector P,u,r,p,mid
real scalar i,j,Ar,Ap,cap,tn,ta,tau,N
N=1000000
/* 列：情景号,tn,ta,tau,phi,abar,A穷国,Aa穷国。
   除情景3用于展示严格同质劳动外，均直接抄录相应 .m 驱动文件。 */
cases=(1,.3707,.1899,.3451,.0036,2.43,100/23.85,1\
       2,.3707,.1899,.3451,.0036,2.43,100/3.89,1\
       4,.3699,.2693,0,.004,4.08,100/19.45,1\
       5,.3696,.2314,.20,.0039,3.24,100/21.5,1\
       6,.3699,.2045,.30,.0037,2.74,100/23,1\
       7,.3711,.1791,.40,.0037,2.13,100/24.8,1\
       8,.3724,.1693,.50,.0034,1.85,100/25.45,1\
       9,.3767,.2874,.99,.004,.84,100/27.5,1\
       10,.3707,.1899,.3451,.0036,2.43,100/5.35,1\
       11,.01,.01,0,.004,2.82,100/5.35,1\
       12,.3707,.1899,.3451,.0036,2.43,100/10.3,.315\
       13,.01,.01,0,.0036,2.43,100/10.3,.315)
E=J(0,23,.);ratios=J(0,10,.);params=J(0,8,.)
for(i=1;i<=rows(cases);i++) {
    printf("Scenario %g / basic\n",cases[i,1])
    tn=cases[i,2];ta=cases[i,3];tau=cases[i,4]
    T=talents(tn,ta,tau,N,32878)
    P=(100,1,cases[i,5],cases[i,6],0,0,0,0,1,0)
    u=solve(T,P);E=E\(cases[i,1],1,P[1],P[2],tau,u)
    P[1]=100/1.26;r=solve(T,P);E=E\(cases[i,1],2,P[1],P[2],tau,r)
    P[1]=cases[i,7];P[2]=cases[i,8];p=solve(T,P);E=E\(cases[i,1],3,P[1],P[2],tau,p)
    ratios=ratios\(cases[i,1],r[5]/p[5],(u[3]*r[1]+r[2])/(u[3]*p[1]+p[2]),r[6]/p[6],(r[5]/p[5])/(r[6]/p[6]),(100/1.26)/P[1],r[7]/p[7],r[8]/p[8],u[9],tau)
    params=params\(cases[i,1],tn,ta,tau,frank(tau),cases[i,5],cases[i,6],N)
    if (i==1) {
        putdata(T,("zn","za"),"talent_check.dta")
        grid=J(0,21,.)
        for(j=1;j<=20;j++) {
            P[1]=100*exp(ln(.035)+(j-1)*(-ln(.035))/19);P[2]=1
            mid=solve(T,P)
            grid=grid\(j,P[1],(u[3]*mid[1]+mid[2])/(u[3]*u[1]+u[2]),mid)
        }
    }
}
/* 严格同质基准：za=zn=1，工资相等时两个部门都可生产，生产率均等于A。
   不用极小方差随机数假冒完全同质情景。固定基准的A差异保持不变。 */
Ar=(100/1.26)/(100/23.85)
ratios=ratios\(3,Ar,Ar,Ar,1,Ar,1,1,1,0)
/* 资本土地三组：保留源代码 al=.001 的近似无土地设置，并明确记录。 */
for(i=14;i<=16;i++) {
    printf("Scenario %g / capital and land\n",i)
    tn=(i==14 ? .3707 : .005);ta=(i==14 ? .1899 : .005);tau=(i==14 ? .3451 : 0)
    T=talents(tn,ta,tau,N,32878)
    P=(100,1,.0051,(i==16 ? 33.5 : 94.95),.36,(i==16 ? .001 : .18),.33,3812,3.405,1)
    u=solve(T,P);E=E\(i,1,P[1],P[2],tau,u)
    P[1]=85.5;P[8]=.94*.855*3812;r=solve(T,P);E=E\(i,2,P[1],P[2],tau,r)
    P[1]=17.5;P[8]=118;p=solve(T,P);E=E\(i,3,P[1],P[2],tau,p)
    ratios=ratios\(i,r[5]/p[5],(u[3]*r[1]+r[2])/(u[3]*p[1]+p[2]),r[6]/p[6],(r[5]/p[5])/(r[6]/p[6]),85.5/17.5,r[7]/p[7],r[8]/p[8],u[9],tau)
    params=params\(i,tn,ta,tau,frank(tau),P[3],P[4],N)
}
putdata(E,("scenario","economy","A","Aa","tau","Ya","Yn","pa","Na","prod_a","prod_n","ability_a","ability_n","wage_ratio","res_a","res_n","rent_k","rent_l","KY","res_k","res_l","corner","cutoff"),"model_economies_demo.dta")
putdata(ratios,("scenario","gap_a","gap_gdp","gap_n","gap_ratio","gap_A","selection_a","selection_n","us_wage_ratio","tau"),"model_ratios_demo.dta")
putdata(params,("scenario","theta_inv_n","theta_inv_a","kendall_tau","frank_alpha","phi","abar","N"),"model_parameters_demo.dta")
putdata(grid,("point","A","gdp_us","Ya","Yn","pa","Na","prod_a","prod_n","ability_a","ability_n","wage_ratio","res_a","res_n","rent_k","rent_l","KY","res_k","res_l","corner","cutoff"),"model_trends_demo.dta")
}
main()
end
use model_economies_demo.dta, clear
assert abs(res_a)<.0002 & abs(res_n)<.0002 & abs(res_k)<1e-8 & abs(res_l)<1e-8
assert Na>0 & Na<1
use model_ratios_demo.dta, clear
sort scenario
format gap* selection* us_wage_ratio %10.4f
list, noobs separator(0)
display "__MODEL_ALL_OK__"
