%% CALCULATION OF INFLUENCE SCORE


function pred_acc_avg = IS_ffs_module(predictor,class_label)

% RUN THE SIMULATION

cross_val       = 50;
num_feature     = size(predictor,1);
num_samples     = size(predictor,2);


% random sampling for train (80%) and test (20%)
for ii = 1:cross_val

    rng(ii);

    trainRatio  = 0.8;
    valRatio    = 0.0;
    testRatio   = 0.2;

    [train_idx(ii,:),~,test_idx(ii,:)] = dividerand(num_samples, trainRatio, valRatio, testRatio);
end




% train ML
nd1 = cross_val;        % samples (n = 50)
nd2 = num_feature;  % perturbation (157 + Control)



parfor  masterIDX = 1:nd1*nd2

    disp(masterIDX)

    [idx1,idx2] = ind2sub([nd1,nd2],masterIDX);

    % copy variables for par
    predictor_P     = predictor;
    class_label_P   = class_label;
    train_idx_P     = train_idx;
    test_idx_P      = test_idx;


    % evaludate individual feature one by one
    predictor_rm            = predictor_P(idx2,:);

    % random sampling for training an test
    train_idx_p     = train_idx_P(idx1,:);
    test_idx_p      = test_idx_P(idx1,:);

    % Train & Test data
    predictor_train = predictor_rm(:,train_idx_p); % training input
    predictor_test  = predictor_rm(:,test_idx_p); % test input

    class_label_train = class_label_P(train_idx_p);
    class_label_true = class_label_P(test_idx_p);


    % SVM options
    svmtemp     = templateSVM('Standardize',1, 'KernelFunction','linear');
    Mdl         = fitcecoc(predictor_train',class_label_train',...
        'Learners',svmtemp,...
        'ClassNames',{'NR','PR','RD'});


    % Model prediction
    class_pred_c(:,masterIDX) = predict(Mdl,predictor_test')';
    class_true_c(:,masterIDX) = class_label_true';

end


% reshaping the parfor-result
[nrow,~]        = size(class_pred_c);
pred_class      = reshape(class_pred_c,[nrow,nd1,nd2]);

[nrow,~]        = size(class_true_c);
true_class      = reshape(class_true_c,[nrow,nd1,nd2]);




%% post-processing

parfor masterIDX = 1:nd1*nd2

    [idx1,idx2] = ind2sub([nd1,nd2],masterIDX);

    %     tmp_predicted_output(:,1) = predict_class(:,idx1,idx2);
    %     tmp_target_output_known(:,1)=known_class(:,idx1,idx2);

    group       = true_class(:,idx1,idx2);
    grouphat    = pred_class(:,idx1,idx2);


    [cmat,~]                = confusionmat(group, grouphat);
    score_mat_c(masterIDX)  = sum(diag(cmat)/length(true_class(:,idx1,idx2)));

end

% reshaping the parfor-result
score_mat = reshape(score_mat_c,[nd1,nd2]);

% averaged prediction accuracy
pred_acc_avg    = mean(score_mat);
