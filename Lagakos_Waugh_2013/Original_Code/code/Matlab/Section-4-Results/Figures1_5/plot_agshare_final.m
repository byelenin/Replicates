clear all
load ndata.mat
load modelnew.mat
load wage_data.mat
close all

i = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 2 in Lagakos and Waugh
axes1 = axes('Parent',figure,...
'XTickLabel',{'1/128','1/64','1/32','1/16','1/8','1/4','1/2','1','2','4'},...
'FontWeight','bold','FontSize',16);

hold('all');


plot(log2(ndata(:,2)./ndata(157,2)),ndata(:,3),'w*',log2(relgdp(i,:).^-1), 100.*empshr(i,:), 'r-','LineWidth',4)
text(log2(ndata(:,2)./ndata(157,2)),ndata(:,3),names(:,1),'Fontsize',11,'FontWeight','bold','Color','k')
xlabel('2000 PPP GDP Per Worker Data, U.S. = 1','FontWeight','bold','FontSize',16);
ylabel('Share of Employment in Agriculture','FontWeight','bold','FontSize',16);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 1 in Lagakos and Waugh

b = regress(rel_wages(:,2),[ones(length(rel_wages(:,2)),1), log2(rel_wages(:,1))]);

wfit = [ones(length(rel_wages(:,2)),1), sort(log2(rel_wages(:,1)))]*b;


axes1 = axes('Parent',figure,...
'XTickLabel',{'1/64','1/32','1/16','1/8','1/4','1/2','1','2'},...
'FontWeight','bold','FontSize',16);

hold('all');

plot(log2(rel_wages(:,1)),rel_wages(:,2),'w*',log2(relgdp(i,:).^-1),rel_wage_model, 'r-','LineWidth',4)
text(log2(rel_wages(:,1)),rel_wages(:,2),wage_names(:),'Fontsize',11,'FontWeight','bold','Color','k')
xlabel('PPP GDP Per Worker Data, U.S. = 1','FontWeight','bold','FontSize',16);
ylabel('W_a / W_n','FontWeight','bold','FontSize',16);

zzz = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



