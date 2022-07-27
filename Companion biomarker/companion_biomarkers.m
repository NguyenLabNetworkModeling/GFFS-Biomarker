


%% LOADING DATASET

file_name   = 'FEAT_157_selected_features.xlsx';

tbl_feature_score   = readtable(file_name);
feat_names_1        = tbl_feature_score.feature;
feat_names_2        = tbl_pde_dat.GeneName;

[Lia,Locb] = ismember(feat_names_1,feat_names_2);

% check the order
disp([feat_names_1 feat_names_2(Locb)])

tbl_pde_feat = [tbl_pde_dat(Locb,:) tbl_feature_score];
dat_set     = table2array(tbl_pde_feat(:,2:end-2));



% Expression data normalization
predictor = data_normalization(dat_set);


% marker gene sets
% marker_gene_id = find(ismember(tbl_pde_dat.GeneName,tbl_feature_score.tmp_xlabs));


% choose a number of features (trained)
num_combo = 5;
marker_idx = nchoosek(1:length(feat_names_1),num_combo);




%% RUN THE SIMULATION

cross_val   = 50;
num_samples = size(predictor,2);
% num_samples = size(predictor(marker_idx(:,1),:),2);

% random sampling for train (80%) and test (20%)
for ii = 1:cross_val
    
    rng(ii); % random number seed for reproducibility
    
    trainRatio  = 0.8;
    valRatio    = 0.0;
    testRatio   = 0.2;
    
    [train_idx(ii,:),~,test_idx(ii,:)] = dividerand(num_samples,trainRatio,valRatio,testRatio);
end

FPTR = 0; % FPTR

nd1 = cross_val;
nd2 = size(marker_idx,1);

class_pred_c  = {};
class_true_c  = {};

parfor  masterIDX = 1:(nd1*nd2)
    
    disp(masterIDX)
    
    [idx1,idx2] = ind2sub([nd1,nd2],masterIDX);
    
    % copying variables for parfor
    predictor_P     = predictor;
    marker_idx_P    = marker_idx;
    predictor_P2    = predictor_P(marker_idx_P(idx2,:),:);
    class_label_P   = class_label;
    train_idx_P     = train_idx;
    test_idx_P      = test_idx;
    
    % random sampling for training an test
    train_idx_p = train_idx_P(idx1,:);
    test_idx_p = test_idx_P(idx1,:);
    
    % Train & Test data
    predictor_train = predictor_P2(:,train_idx_p); % training input
    predictor_test = predictor_P2(:,test_idx_p); % test input
    
    class_label_train = class_label_P(train_idx_p);
    class_label_true = class_label_P(test_idx_p);
    
    rng(masterIDX);
    
    % SVM options
    svmtemp     = templateSVM('Standardize',1,'KernelFunction','linear');
    Mdl         = fitcecoc(predictor_train',class_label_train',...
        'Learners',svmtemp,...
        'ClassNames',{'NR', 'RD','PR'},...
        'FitPosterior',FPTR);
    
    % Model prediction
    class_pred_c(:,masterIDX)     = predict(Mdl,predictor_test');
    class_true_c(:,masterIDX) = class_label_true';
    
end


[nrow1,~,~]     = size(class_true_c);
class_true      = reshape(class_true_c,[nrow1,nd1,nd2]);

[nrow1,~,~]     = size(class_pred_c);
class_pred      = reshape(class_pred_c,[nrow1,nd1,nd2]);


%% confusion matrix
for idx2 = 1:nd2
    for idx1 = 1:nd1
        
        group   = class_true(:,idx1,idx2);
        grouphat = class_pred(:,idx1,idx2);
        
        [cmat,~] = confusionmat(group, grouphat);
        score_mat(idx1,idx2)= sum(diag(cmat)/length(class_true(:,idx1,idx2)));
        
    end
end


% averaged prediction accuracy
scoore_avg(:,1)  = mean(score_mat,1);
max(scoore_avg)




% feaure id --> name
for ii = 1:size(marker_idx,1)
    for jj = 1:num_combo
        
        feat_combo{ii,jj} = feat_names_1{marker_idx(ii,jj)};
        
    end
end


tbl_feat_combo  = [array2table(feat_combo) ...
    array2table(scoore_avg,'VariableNames',{'score'})];


fname = strcat(fullfile(workdir,'\Outcome\'),'companion_biomarker_combinations','.xlsx');
writetable(tbl_feat_combo,fname,...
    'Sheet',num2str(num_combo),...
    'WriteVariableNames',1,...
    'WriteRowNames',0);

