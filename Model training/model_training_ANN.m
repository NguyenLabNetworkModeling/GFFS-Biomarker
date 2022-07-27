%% ANN model


% label --> binary
class_label_bin = zeros(3,size(class_label,2));
class_label_bin(1,ismember(class_label,{'NR'})) = 1;
class_label_bin(2,ismember(class_label,{'RD'})) = 1;
class_label_bin(3,ismember(class_label,{'PR'})) = 1;

% normalize data across the sample
predictor   = data_normalization(dat_set);


%% RUN THE SIMULATION

cross_val   = 50;
num_samples = size(predictor,2);


% Random spliting the data for training (80%) and test (20%)
for ii = 1:cross_val
    rng(ii); % random number seed for reproducibility
    
    trainRatio  = 0.8;
    valRatio    = 0.0;
    testRatio   = 0.2;
    
    [train_idx(ii,:),~,test_idx(ii,:)] = dividerand(num_samples, trainRatio, valRatio, testRatio);
end



parfor  idx1 =  1:cross_val
    
    disp(idx1)
    
    % copy variables for par
    predictor_P     = predictor;
    train_idx_P     = train_idx;
    test_idx_P      = test_idx;
    class_label_P   = class_label_bin;
    
    
    % random sampling for training an test
    train_idx_p     = train_idx_P(idx1,:);
    test_idx_p      = test_idx_P(idx1,:);
    
    
    % Train & Test data
    predictor_train     = predictor_P(:,train_idx_p); % training input
    predictor_test      = predictor_P(:,test_idx_p); % test input
    
    class_label_train   = class_label_P(:,train_idx_p);
    class_label_true    = class_label_P(:,test_idx_p);
    
    
    rng(idx1)
    
    % ANN training (architecture)
    net     = patternnet(10);
    net.trainParam.showWindow   = false;
    net.divideParam.trainRatio  = 100/100;
    net.divideParam.valRatio    = 0/100;
    net.divideParam.testRatio   = 00/100;
    net     = train(net,predictor_train,class_label_train,...
        'useGPU','no');
    
    class_prd   = sim(net,predictor_test);
    cnum2(:,:,idx1) = class_prd';
    
    
    
    [~,class_pred_c(:,idx1)] = max(class_prd);
    [~,class_true_c(:,idx1)] = max(class_label_true);
    
      trained_Mdl{idx1} = net;
      
end

ML.model        = trained_Mdl;
ML.feat_names   = feat_names;

fname = strcat(fullfile(workdir,'\Outcome'),'\ANN_Model_',model_name,'.mat');
save(fname,'ML');



% number to class

class_label_true = cell(size(class_true_c));
class_label_true(ismember(class_true_c,1)) = {'NR'};
class_label_true(ismember(class_true_c,2)) = {'RD'};
class_label_true(ismember(class_true_c,3)) = {'PR'};

class_pred_1 = cell(size(class_pred_c));
class_pred_1(ismember(class_pred_c,1)) = {'NR'};
class_pred_1(ismember(class_pred_c,2)) = {'RD'};
class_pred_1(ismember(class_pred_c,3)) = {'PR'};
