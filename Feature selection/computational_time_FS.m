% computational time (Big-O)

clear 
close all
clc

n(:,1) = 1:10:209;


y(:,1) = 2*n;
y(:,2) = n.*(n+1)/2;

plot(n,y)

tbl = array2table([n y],'VariableNames',{'Feat','GFFS','RFE'});
writetable(tbl,strcat('.\Outcome\','computational_time_FS.xlsx'))



