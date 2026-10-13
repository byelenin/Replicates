clear all
load papn_data
load p05mat.mat
load modelnew.mat

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 3 in Lagkos and Waugh
axes1 = axes('Parent',figure,...
'XTickLabel',{'1/128','1/64','1/32','1/16','1/8','1/4','1/2','1','2'},...
'YTick',[-1 0 1 2],...
'YTickLabel',{'1/2','1','2','4'},...
'FontWeight','bold','FontSize',16);

hold('all');


plot(log2(price05k(:,2)./price05k(140,2)),log2(price05k(:,1)),'w*',log2(relgdp.^-1),log2(price./price(end)),'r-','LineWidth',4)
text(log2(price05k(:,2)./price05k(140,2)),log2(price05k(:,1)),price05_name(:,1),'Fontsize',11,'FontWeight','bold','Color','k')
xlabel('PPP GDP Per Worker Data, U.S. = 1','FontWeight','bold','FontSize',16);
ylabel('Pa / Pn,  U.S. = 1','FontWeight','bold','FontSize',16);

fff = isnan(price05k(:,2)); 

[b,bint,r,rint,stats] = regress(log2(price05k(~fff,1)), [ones(length(price05k(~fff,1)),1),log2(price05k(~fff,2)./price05k(140,2))]);
disp(b)
disp(bint)

disp(prctile(price05k(:,1),90))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 5 in the appendix of Lagakos and WAugh

load pp85mat.mat


axes1 = axes('Parent',figure,...
'XTickLabel',{'1/64','1/32','1/16','1/8','1/4','1/2','1'},...
'YTick',[-1 0 1 2 3],...
'YTickLabel',{'1/2','1','2','4','6'},...
'FontWeight','bold','FontSize',16);

hold('all');


plot(log2(pp_price(:,2)./pp_price(1,2)),log2(pp_price(:,1)./pp_price(1,1)),'w*',log2(relgdp.^-1),log2(price./price(end)),'r-','LineWidth',4)
text(log2(pp_price(:,2)./pp_price(1,2)),log2(pp_price(:,1)./pp_price(1,1)),pp_names(:,1),'Fontsize',11,'FontWeight','bold','Color','k')
xlabel('1985 PPP GDP Per Worker Data, U.S. = 1','FontWeight','bold','FontSize',16);
ylabel('Pa / Pn,  U.S. = 1','FontWeight','bold','FontSize',16);

fff = isnan(pp_price(:,2)); 

[b,bint,r,rint,stats] = regress(log2(pp_price(:,1)./pp_price(1,1)), [ones(length(pp_price(~fff,1)),1),log2(pp_price(:,2)./pp_price(1,2))]);
disp(b)
disp(bint)

disp(prctile(pp_price(:,1),90))


