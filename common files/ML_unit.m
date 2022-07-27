%% ML unit

function pred_acc_avg = ML_unit(predictor,class_label)


% RUN THE SIMULATION
cross_val       = 50;
num_feature     = size(predictor,1);
num_samples     = size(predictor,2);


% random sampling for train (80%) and test (20%)
for ii = 1:cross_val

    %rng(ii);

    trainRatio  = 0.8;
    valRatio    = 0.0;
    testRatio   = 0.2;

    [train_idx(ii,:),~,test_idx(ii,:)] = dividerand(num_samples, trainRatio, valRatio, testRatio);
end


parfor  ii = 1:cross_val

    % copy variables for par
    predictor_P     = predictor;
    class_label_P   = class_label;
    train_idx_P     = train_idx;
    test_idx_P      = test_idx;

    % random sampling for training an test
    train_idx_p     = train_idx_P(ii,:);
    test_idx_p      = test_idx_P(ii,:);

    % Train & Test data
    predictor_train = predictor_P(:,train_idx_p); % training input
    predictor_test  = predictor_P(:,test_idx_p); % test input

    class_label_train = class_label_P(train_idx_p);
    class_label_true = class_label_P(test_idx_p);


    % SVM options
    svmtemp     = templateSVM('Standardize',1, 'KernelFunction','linear');
    Mdl         = fitcecoc(predictor_train',class_label_train',...
        'Learners',svmtemp,...
        'ClassNames',{'NR','PR','RD'});


    % Model prediction
    class_pred_c(:,ii) = predict(Mdl,predictor_test')';
    class_true_c(:,ii) = class_label_true';

end

% reshaping the parfor-result
[nrow,~]        = size(class_pred_c);
pred_class      = reshape(class_pred_c,[nrow,cross_val]);

[nrow,~]        = size(class_true_c);
true_class      = reshape(class_true_c,[nrow,cross_val]);


%% post-processing

parfor ii = 1:cross_val


    group       = true_class(:,ii);
    grouphat    = pred_class(:,ii);


    [cmat,~]                = confusionmat(group, grouphat);
    score_mat_c(ii)  = sum(diag(cmat)/length(true_class(:,ii)));

end


% averaged prediction accuracy
pred_acc_avg    = mean(score_mat_c);
