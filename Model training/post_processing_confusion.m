%% Post-processing

for idx1 = 1:cross_val
    
    group       = class_label_true(:,idx1);
    grouphat    = class_pred_1(:,idx1);
    
    [cmat,~]        = confusionmat(group,grouphat);
    score_mat(idx1) = sum(diag(cmat)/length(class_label_true(:,idx1)));
    
end


% averaged prediction accuracy
pred_acc_avg    = mean(score_mat);
disp(strcat('prediction = ',num2str(pred_acc_avg)))





%% Plot a distribution of curve for prediction accuracy

fig_2 = figure;
fig_2.Position = [680   796   308   182];

bins = 0:0.1:1;
histogram(score_mat,bins)

title(strcat('pred(avg)=',num2str(mean(score_mat))))
xlabel('pred. acc.'),ylabel('trials')
pbaspect([4 3 1]/4)
box off


fname = strcat(fullfile(workdir,'\Outcome'),'\pred_hist_',model_name,'.jpeg');
saveas(fig_2,fname);



%% confusion matrix (across all trials)

fig_3 = figure;

trueLab           = class_label_true(:);
predLab        = class_pred_1(:);
[cfm, order]    = confusionmat(trueLab,predLab);



cm = confusionchart(trueLab,predLab, ...
    'ColumnSummary','column-normalized', ...
    'RowSummary','row-normalized');

cm.Title = {'17-AAG Drug Response'; 'Confusion Matrix'};



fname = strcat(fullfile(workdir,'\Outcome'),'\confusionmat_',model_name,'.jpeg');
saveas(fig_3,fname);



%% ROC curves

class_binary = zeros(3,size(class_label_true(:),1));
class_binary(1,ismember(class_label_true(:),{'NR'})) = 1;
class_binary(2,ismember(class_label_true(:),{'RD'})) = 1;
class_binary(3,ismember(class_label_true(:),{'PR'})) = 1;


class_prob = [];

for ii = 1:size(cnum2,3)
    
    class_prob = [class_prob;cnum2(:,:,ii)];
    
end

[tpr,fpr,thresholds] = roc(class_binary,class_prob');


fig_4 = plotroc(class_binary,class_prob');
fig_4.Position = [828   524   404   289];

axdata = get(gca, 'userdata');
legend(axdata.lines, 'NR', 'RD','PR');

fname = strcat(fullfile(workdir,'\Outcome'),'\roc_curve_',model_name,'.jpeg');
saveas(fig_4,fname);
