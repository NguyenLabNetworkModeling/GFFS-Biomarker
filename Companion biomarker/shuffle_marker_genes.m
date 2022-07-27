
clear; clc; close all


%% LOADING DATASET
filename1='Explant_ResponseGroup_Allprot_DEGs.xlsx';
% note: duplicated gene removed from Allprot dat.

tbl_exp_dat=readtable(filename1,...
    'Sheet','DEG expression');

tbl_target_class=readtable(filename1,...
    'Sheet','Target labels');

tbl_deg_pval=readtable(filename1,...
    'Sheet','DEG pvals');


filename2='training_outcome_dat.xlsx';

tbl_markers_is=readtable(filename2,...
    'Sheet','High Ranked IS');


% expression data (to be normalized)
exp_dat_raw=table2array(tbl_exp_dat(:,2:end));
% gene names (input variable)
gene_name=tbl_exp_dat.GeneName(:);
% target lables (output labels)
class_label = table2array(tbl_target_class);
% p-value (just for inform)
p_val=tbl_deg_pval.DEGs_Pval(:);


%% Expression data normalization
%% predictor = expression data (normalized)

tmp_min = repmat(min(exp_dat_raw')',1,size(exp_dat_raw,2));
tmp_max = repmat(max(exp_dat_raw')',1,size(exp_dat_raw,2));
predictor = (exp_dat_raw -  tmp_min)./(tmp_max - tmp_min);
%predictor = exp_dat_raw;


% marker gene sets
marker_gene_id = find(ismember(tbl_exp_dat.GeneName,tbl_markers_is.tmp_xlabs));
% NCHOOSEk - choose a number of genes
marker_idx = nchoosek(marker_gene_id,2);


%% RUN THE SIMULATION

No_cross_val = 50;
No_sample = size(predictor(marker_idx(:,1),:),2);

% random sampling for train (80%) and test (20%)
for ii = 1:No_cross_val
    rng(ii); % random number seed for reproducibility
    [train_sample_idx(ii,:),~,test_sample_idx(ii,:)] = dividerand(No_sample,0.8,0.0,0.2);
end

FITPOSTERIOR = 0;

nd1 = No_cross_val;
nd2 = size(marker_idx,1);


parfor  masterIDX = 1:(nd1*nd2)
    
    disp(masterIDX)
    
    [idx1,idx2]=ind2sub([nd1,nd2],masterIDX);
    
    
    % copy variables for parfor
    %marker_idx_par = marker_idx;
    predictor_par = predictor(marker_idx(idx2,:),:);
    class_label_par = class_label;
    train_sample_idx_par = train_sample_idx;
    test_sample_idx_par = test_sample_idx;
    
    % random sampling for training an test
    train_idx = train_sample_idx_par(idx1,:);
    test_idx = test_sample_idx_par(idx1,:);
    
    % Train & Test data
    predictor_train = predictor_par(:,train_idx); % training input
    predictor_test = predictor_par(:,test_idx); % test input
    
    class_label_train = class_label_par(train_idx);
    class_label_true = class_label_par(test_idx);
    
    rng(masterIDX);
    % SVM options
    svmtemp=templateSVM('Standardize',1,...
        'KernelFunction','linear');
    Mdl = fitcecoc(predictor_train',class_label_train',...
        'Learners',svmtemp,...
        'ClassNames',{'NR', 'RD','PR'},...
        'FitPosterior',FITPOSTERIOR);
    % CVMdl = crossval(Mdl)
    % genError = kfoldLoss(CVMdl)
    
    % Model prediction
    if FITPOSTERIOR == 0
        class_label_pred_index(:,masterIDX) = predict(Mdl,predictor_test');
    else
        [class_label_pred_index(:,masterIDX),~,~,cnum(:,:,masterIDX)]=predict(Mdl,predictor_test');
    end
    class_label_true_index(:,masterIDX) = class_label_true';
    
end


[nrow1,~,~]=size(class_label_true_index);
class_label_true_index_cross = reshape(class_label_true_index,[nrow1,nd1,nd2]);
[nrow1,~,~]=size(class_label_pred_index);
class_label_pred_index_cross = reshape(class_label_pred_index,[nrow1,nd1,nd2]);


%%
% post-processing
for idx2 = 1:size(marker_idx,1)
    for idx1 = 1:nd1
        
        [cmat,~] = confusionmat(class_label_true_index_cross(:,idx1,idx2),...
            class_label_pred_index_cross(:,idx1,idx2));
        score_mat(idx1,idx2)= sum(diag(cmat)/length(class_label_true_index_cross(:,idx1,idx2)));
        
    end
end
% averaged prediction accuracy
avg_prediction_acc = mean(score_mat,1);

max(avg_prediction_acc)

tbl_pred_score = array2table([marker_idx avg_prediction_acc']);

filename = strcat(pwd,'\data.output\tmp_shuffling_result.xlsx');
writetable(tbl_pred_score,filename,...
    'Sheet',num2str(size(marker_idx,2)),...
    'WriteVariableNames',1,...
    'WriteRowNames',0)

% generate a box plot
try
    pre_ac_markers = 0.9225;
    [~,pval]=ttest(ones(size(avg_prediction_acc))*pre_ac_markers,avg_prediction_acc);
    
    figure('Position',[681   702   262   277]),
    boxplot([[ones(size(avg_prediction_acc))*pre_ac_markers]' avg_prediction_acc'],...
        'Notch','on','Labels',{'Markers','Random'})
    xtickangle(45)
    title(strcat('pval=',num2str(pval),' (N=',num2str(length(avg_prediction_acc)),')'))
    ylabel('Prediction accuracy')
    box off
catch
    close
end
% disp(strcat('Prediction = ',num2str(avg_prediction_acc)))


%% Plot a distribution of curve for prediction accuracy

figure('Position',[680   796   308   182])

pbaspect([4 3 1]/4)
edges = [0:0.1:1];
histogram(score_mat(:,end),edges)
title(strcat('prediction(avg)=',num2str(mean(score_mat(:,end)))))
xlabel('predicton accuracy'),ylabel('numbers of trials')
pbaspect([4 3 1]/4)
box off

% finename=strcat(pwd,'\Output-figs\Prediction Accuracy Bar_',date);
% savefig(finename);


%% confusion matrix

[cfm,order] = confusionmat(class_label_true_index(:),class_label_pred_index(:));
figure
cm = confusionchart(class_label_true_index(:),class_label_pred_index(:), ...
    'ColumnSummary','column-normalized', ...
    'RowSummary','row-normalized');
cm.Title = '17-AAG Drug Response Confusion Matrix - Marker genes';

% finename=strcat(pwd,'\Output-figs\ConfusionMatrix_',date);
% savefig(finename);

%% ROC curves
class_label_true_binary = zeros(3,size(class_label_true_index(:),1));
class_label_true_binary(1,ismember(class_label_true_index(:),{'NR'})) = 1;
class_label_true_binary(2,ismember(class_label_true_index(:),{'RD'})) = 1;
class_label_true_binary(3,ismember(class_label_true_index(:),{'PR'})) = 1;


if FITPOSTERIOR == 1
    
    class_label_pred_probability = [];
    for ii = 1:size(cnum,3)
        class_label_pred_probability = [class_label_pred_probability;cnum(:,:,ii)];
    end
    
    [tpr,fpr,thresholds] = roc(class_label_true_binary,class_label_pred_probability');
    figure('position',[610   599   249   291])
    plotroc(class_label_true_binary,class_label_pred_probability')
    axesUserData = get(gca, 'userdata');
    legend(axesUserData.lines, 'NR', 'RD','PR');
end