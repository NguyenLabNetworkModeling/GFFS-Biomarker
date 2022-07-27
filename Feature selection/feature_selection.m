%% MODEL REBUILDING AND IDENTIFY MARKER GENES

%% load and sort the influence score

filename_2  = strcat('influence_score_',model_name,'.xlsx');
tbl_scores  = readtable(filename_2);
[BB,II]     = sort(tbl_scores.score,'descend');
        

% expression data sorted
dat_set_feat = dat_set(II,:);
gene_name_feat  =feat_name_2(II); %
g_seq   = 1:length(gene_name_feat);



% Expression data normalization
% Min_val = repmat(min(dat_set_feat')',1,size(dat_set_feat,2));
% Max_val = repmat(max(dat_set_feat')',1,size(dat_set_feat,2));
% predictor = (dat_set_feat -  Min_val)./(Max_val - Min_val);
predictor = data_normalization(dat_set_feat);

 
% preparing train and test set (for reproducibility)

cross_val   = 50;
num_samples = size(predictor,2);

% random sampling for train (80%) and test (20%)
for ii = 1:cross_val
    
    rng(ii);
    
    trainRatio  = 0.8;
    valRatio    = 0.0;
    testRatio   = 0.2;
    
    [train_idx(ii,:), ~, test_idx(ii,:)] = dividerand(num_samples,trainRatio,valRatio,testRatio);
end


%% simulation
% 1) perturbing the training data 2) train SVM

marker_id   = g_seq(1);
mk_score    = [];

tic
rr=1;
for kk=1:length(g_seq)
    
    if kk==1
        pred_dat=predictor(g_seq(1),:);
    else
        pred_dat=predictor([marker_id g_seq(kk)],:);
    end
    
    
    
    parfor idx1 = 1:cross_val
        
        % coping variables for parfor
        predictor_P     = pred_dat;
        class_label_P   = class_label;
        train_idx_P     = train_idx;
        test_idx_P      = test_idx;
        
        
        % random sampling for training an test
        train_idx_p = train_idx_P(idx1,:);
        test_idx_p  = test_idx_P(idx1,:);
                       
        % Train & Test data
        predictor_train     = predictor_P(:,train_idx_p); % training input
        predictor_test      = predictor_P(:,test_idx_p); % test input
        
        class_label_train   =class_label_P(train_idx_p);
        class_label_true    =class_label_P(test_idx_p);
        
        rng(idx1);
        
        svmtemp     =templateSVM('Standardize',1,'KernelFunction','linear');
        Mdl         = fitcecoc(predictor_train',class_label_train',...
                    'Learners',svmtemp,...
                    'ClassNames',{'NR','PR','RD'});
        
        % Model prediction
        class_pred  = predict(Mdl,predictor_test')';
        %score(idx1)=sum(arrayfun(@isequal,resp_type_test,pretarget))/length(resp_type_test);
        
        [cmat,~] = confusionmat(class_label_true,class_pred);
        score(idx1)= sum(diag(cmat)/length(class_label_true));
        
    end
    
    mk_score_tm=[mk_score mean(score)];
    
    
    if kk==1
        
        mk_score    = mk_score_tm;
        
    elseif mk_score_tm(end) > max(mk_score_tm(1:end-1))
        
        marker_id   = [marker_id g_seq(kk)];        
        mk_score    = [mk_score mean(score)];
        rr=rr+1;        
    end
    
        disp(mk_score)
end

toc

%% Plot Prediction accuracy

fig_1 = figure;
fig_1.Position = [680   641   341   337];

bar(mk_score,'BaseValue',min(mk_score)*0.9);
set(gca,'LineWidth',1)
xticks(1:length(mk_score))
xlabs = replace(gene_name_feat(marker_id),'_','-');
xticklabels(xlabs)
xtickangle(45)
ylabel('Prediction accuracy')
title(strcat('Max = ',num2str(mk_score(end))))
pbaspect([4 3 1]/4)
box off

fname = strcat(fullfile(workdir,'/Outcome/'),model_name,'_bar_selected_features.jpeg');
saveas(fig_1,fname)


% selected features and scores
tbl_features = [array2table(xlabs,'VariableNames',{'feature'})...
    array2table(mk_score','VariableNames',{'score'})];
fname = strcat(fullfile(workdir,'/Outcome/'),model_name,'_selected_features.xlsx');

writetable(tbl_features,fname)




% heatmap
featured_genes = tbl_pde_dat(ismember(feat_name_2,xlabs),:);

hmo = HeatMap(log10(table2array(featured_genes(:,2:end))),...
    'Standardize',2,...
    'RowLabels',xlabs,...
    'ColumnLabels',class_label,...
    'ColumnLabelsRotate',45);
% hmo.RowLabels = {};
hmo.addTitle('High Ranked Genes (Log10 transformed)')

fig_2 = plot(hmo);
fig_2.FontSize = 10;



fname = strcat(fullfile(workdir,'/Outcome/'),model_name,'_heatmap_selected_features.jpeg');
saveas(fig_2,fname)

