%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creates Figure 4 in Lagakos and Waugh (2012). Associated data is in the
% .mat file wm_new_data.mat The paper details the construction of this
% data.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
load wm_new_data.mat

axes1 = axes('Parent',figure,...
'FontWeight','bold','FontSize',16);

hold('all');

plot(wm_new_data(:,1),wm_new_data(:,2),'w*')
text(wm_new_data(:,1),wm_new_data(:,2),wm_names(:),'Fontsize',11,'FontWeight','bold','Color','k')
xlabel('Share of Labor in Agriculture','FontWeight','bold','FontSize',16);
ylabel('Share of Agriculture Workers that are Women','FontWeight','bold','FontSize',16);

[b,bint] = regress(wm_new_data(:,2), [ones(length(wm_new_data(:,1)),1),wm_new_data(:,1)])

fit = [ones(length(wm_new_data(:,1)),1),sort(wm_new_data(:,1))]*b;

plot(sort(wm_new_data(:,1)),fit,'r--','LineWidth',4)