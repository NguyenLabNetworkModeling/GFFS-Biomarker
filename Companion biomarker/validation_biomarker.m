% shuffling with a random 16 features

predictor   = data_normalization(dat_set);


parfor rr = 1:100

    disp(rr)

    % for reproducibility
    % rng(rr)

    rd_idx = randsample(size(predictor,1),16);
    predictor_par = predictor;

    pred_acc_avg(rr) = ML_unit(predictor_par(rd_idx,:),class_label)

end


fig_1 = figure('Position',[680   796   308   182]);
edges = 0:0.1:1;
histogram(pred_acc_avg,edges)
title(strcat('prediction(avg)=',num2str(mean(pred_acc_avg))))
xlabel('predicton accuracy'),ylabel('numbers of trials')
pbaspect([4 3 1]/4)
box off
saveas(fig_1,'histogram.fig');


fig_2 = figure;
boxchart(pred_acc_avg,'Notch','on');
ylabel('Prediction accuracy (%)')
tbl_pred = table(pred_acc_avg');
saveas(fig_2,'boxplot.fig');

% generate a result table
summary(tbl_pred)
% 
% if marker_type == 1
%     finename=strcat(workdir,'\Outcome\random 16 features.csv');
%     writetable(tbl_pred,finename);
% elseif marker_type == 2
%     finename=strcat(workdir,'\Outcome\signature 16 features.csv');
%     writetable(tbl_pred,finename);
% end


