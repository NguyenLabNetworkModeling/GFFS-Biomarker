
% normalize data across the sample
predictor   = data_normalization(dat_set);



% RUN THE SIMULATION 
%% 
% * 50 cross-validation
% * predictor : data used for the model training (train + text)
% * predictor_train : training data
% * predictor_test : test data
% * class_label_train : label for traning data
% * class_label_true : lavel for test data

cross_val       = 50;
num_samples     = size(predictor,2);

% Random spliting the data for training (80%) and test (20%)
for ii = 1:cross_val
    rng(ii); % random number seed for reproducibility
    
    trainRatio  = 0.8;
    valRatio    = 0.0;
    testRatio   = 0.2;
    
    [train_idx(ii,:),~,test_idx(ii,:)] = dividerand(num_samples, trainRatio, valRatio, testRatio);
end

%% 
% Training ML 

parfor  idx1 = 1:cross_val
    
    disp(idx1)
    
    % coping variables for parfor
    predictor_P     = predictor;
    class_label_P   = class_label;
    train_idx_P     = train_idx;
    test_idx_P      = test_idx;
    
    % random sampling for training an test
    train_idx_p       = train_idx_P(idx1,:);
    test_idx_p        = test_idx_P(idx1,:);
    
    % Train & Test data
    predictor_train = predictor_P(:,train_idx_p); % training input
    predictor_test  = predictor_P(:,test_idx_p); % test input
    
    class_label_train = class_label_P(train_idx_p);
    class_label_true(:,idx1) = class_label_P(test_idx_p);
    
    rng(idx1);
    
    % SVM training 
    svmtemp     = templateSVM('Standardize',1,'KernelFunction','linear');
    Mdl_1       = fitcecoc(predictor_train',class_label_train',...
                'Learners',svmtemp,...
                'ClassNames',{'NR', 'RD','PR'});
    % prediction
    class_pred_1(:,idx1) = predict(Mdl_1,predictor_test');
    
    % SVM training (for ROC curve)
    Mdl_2        = fitcecoc(predictor_train',class_label_train',...
                'Learners',svmtemp,...
                'ClassNames',{'NR', 'RD','PR'},...
                'FitPosterior',true);

    % prediction
    [class_pred_2(:,idx1),~,~,cnum2(:,:,idx1)] = predict(Mdl_2, predictor_test');
    
    
    trained_Mdl{idx1} = Mdl_1;
end

ML.model        = trained_Mdl;
ML.feat_names   = model_name;


fname = strcat(fullfile(workdir,'\Outcome'),'\SVM_Model_',model_name,'.mat');
save(fname,'ML');


