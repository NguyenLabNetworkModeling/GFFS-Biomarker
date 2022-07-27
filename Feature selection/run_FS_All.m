
%% data preparation

% X (row): sample/observation
% X (column): variable/feature
% y: a response vectro

% % just for a test
% load fisheriris
% X = randn(150,10);
% X(:,[1 3 5 7])= meas;
% tblX = array2table(X);
% y = species;



%%  PDE samples
predictor = data_normalization(dat_set);

X = predictor';
feat_names = feat_name_2;
y = class_label';


%% Dividing data into a training and a test

num_samples = length(y);
num_feats = size(X,2);
classNames = unique(y);
[train_idx,~,test_idx] = dividerand(num_samples, 0.8, 0, 0.2);

% training data
Xr = X(train_idx,:);
yr = y(train_idx);

% test data
Xt = X(test_idx,:);
yt = y(test_idx);


%% relieff
% estimate the quality of attributes (features) on the basis of 
% how well the attribute (feature) can distinguish between instances 
% (samples) that are near to each other.
% caution: the weight have the same order as the predictor in X

[idx,weights] = relieff(X,y,10,'method','classification');


tbl_FS_ReliefF = [array2table(feat_names(idx),'VariableNames',{'Feat'}) ...
array2table(weights(idx)','VariableNames',{'Weights'})];

writetable(tbl_FS_ReliefF,fullfile(workdir,'\Outcome\tbl_FS_ReliefF.xlsx'))


fig1 = figure;
bar(tbl_FS_ReliefF.Weights)
xlabel('Predictor rank')
ylabel('Predictor importance weight')
set(gca,'XTickLabel',tbl_FS_ReliefF.Feat,'XTick',1:length(tbl_FS_ReliefF.Feat),'XTickLabelRotation',45)
title('Feature selection: ReliefF')
box off

saveas(fig1,fullfile(workdir,'\Outcome\FS_ReliefF.fig'));

%% MRMR (miminum redundancy maximum relevance algorithm)

[idx,weights] = fscmrmr(X,y);

score = weights(idx);

% score = score(score>0);
% idx = idx(score>0);


tbl_FS_MRMR = [array2table(feat_names(idx),'VariableNames',{'Feat'}) ...
array2table(score','VariableNames',{'Weights'})];

writetable(tbl_FS_MRMR,fullfile(workdir,'\Outcome\tbl_FS_MRMR.xlsx'))

fig2 = figure;
bar(score)
xlabel('Predictor rank')
ylabel('Predictor importance score')
set(gca,'XTickLabel',feat_names(idx),'XTick',1:length(feat_names(idx)),'XTickLabelRotation',45)
box off
title('Feature selection: MRMR')

saveas(fig2,fullfile(workdir,'\Outcome\FS_MRMR.fig'));

%% Sequential FS (FFS)

% 10 fold partion
c = cvpartition(y,'k',10);
opts = statset('Display','iter','UseParallel',true);

% forward fs
tic
[fs_fwd,history_fwd] = sequentialfs(@loss_fun,X,y,'cv',c,...
    'options',opts,...
    'nfeatures',num_feats,...
    'direction','forward');
toc

% process data and save it
idx0 = [];
inmat = history_fwd.In;
for ii = 1:size(inmat,1)
    idx1 = find(inmat(ii,:));
     im_sorted(ii) = idx1(~ismember(idx1,idx0));    
     idx0 = idx1;
end

tbl_FS_ffs = [array2table(feat_names(im_sorted)','VariableNames',{'Feat'}) ...
    array2table(history_fwd.Crit','VariableNames',{'Crit'})];

writetable(tbl_FS_ffs,fullfile(workdir,'\Outcome\tbl_FS_ffs.xlsx'))



%% Sequential FS (RFE)
% backward fs
tic
[fs_bwd,history_bwd] = sequentialfs(@loss_fun,X,y,'cv',c,...
    'options',opts,...
    'nfeatures',0,...
    'direction','backward');
toc

% process data and save it
idx0 = [];
im_sorted = [];
inmat = 1 - history_bwd.In(2:end,:);
for ii = 1:size(inmat,1)
    idx1 = find(inmat(ii,:));
     im_sorted(ii) = idx1(~ismember(idx1,idx0));    
     idx0 = idx1;
end

% Initial columns included:  all
im_sorted(end+1) = find(~ismember(1:num_feats,im_sorted));

tbl_FS_rfe = [array2table(feat_names(flip(im_sorted))','VariableNames',{'Feat'}) ...
    array2table(flip(history_bwd.Crit)','VariableNames',{'Crit'})];

writetable(tbl_FS_rfe,fullfile(workdir,'\Outcome\tbl_FS_rfe.xlsx'))


% plot
tiledlayout(1,2)
nexttile

plot(tbl_FS_ffs.Crit,'-o')
xlabel('Features')
ylabel('Criterion')
set(gca,'XTickLabel',tbl_FS_ffs.Feat,'XTickLabelRotation',45)
box off
title('Feature selection: FFS')


nexttile
plot(tbl_FS_rfe.Crit,'-o')
xlabel('Features')
ylabel('Criterion')
set(gca,'XTickLabel',tbl_FS_rfe.Feat,'XTickLabelRotation',45)
box off
title('Feature selection: FRE')


%% LASSO 

Lambda = logspace(-8, -0.2,11);

temp = templateLinear('Regularization','lasso', 'Lambda', Lambda);
rng(2022); % For reproducibility 
Mdl_1 = fitcecoc(X,y,'Learners',temp);

importance = [];
for ii = 1:length(Mdl_1.BinaryLearners)
    [BB,II]=sort(mean(abs(Mdl_1.BinaryLearners{ii}.Beta),2),'descend');

    odr = [1:num_feats]';
    [Lia,Lib]=ismember(odr,II);
    importance(:,ii) = 1./Lib;
end


[imp_lasso,Ii]=sort(mean(importance,2),'descend');

tbl_FS_lasso = [array2table(feat_names(Ii),'VariableNames',{'Feat'}) ...
    array2table(imp_lasso,'VariableNames',{'Importance'})];

writetable(tbl_FS_lasso,fullfile(workdir,'\Outcome\tbl_FS_lasso.xlsx'))


fig3 = figure;
bar(tbl_FS_lasso.Importance)
set(gca,'XTickLabel',tbl_FS_lasso.Feat,'XTick',1:length(tbl_FS_lasso.Feat))
xlabel('Feature')
ylabel('Predictor importance')
xtickangle(45)
title('Feature selection: LASSO')
box off

saveas(fig3,fullfile(workdir,'\Outcome\FS_lasso.fig'));



%% Boosting (AdaBoostM2)

% Train a classifier
% This code specifies all the classifier options and trains the classifier.
template = templateTree(...
    'MaxNumSplits', 5, ...
    'Surrogate','on');

rng(2022); % For reproducibility 
classificationEnsemble = fitcensemble(...
    X, ...
    y, ...
    'Method', 'AdaBoostM2', ...
    'Learners', template, ...
    'ClassNames', classNames);

[imp, ma] = predictorImportance(classificationEnsemble);

[BB,II] = sort(imp,'descend');

tbl_RF_Ada = [array2table(feat_names(II),'VariableNames',{'Feat'}) ...
    array2table(imp(II)','VariableNames',{'Importance'})];

writetable(tbl_RF_Ada,fullfile(workdir,'\Outcome\tbl_RF_Ada.xlsx'))


fig4 = figure;
bar(tbl_RF_Ada.Importance);
ylabel('Predictor Importance');
xlabel('Predictors');
title('Feature selection: Boosting')
h=gca;
h.XTick = 1:length(II);
h.XTickLabel = tbl_RF_Ada.Feat;
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
box off

saveas(fig4,fullfile(workdir,'\Outcome\FS_Boosting.fig'));




%% Random Forest (bagging)

% Train a classifier
% This code specifies all the classifier options and trains the classifier.

rng(2022); % For reproducibility 
classificationBagged = fitcensemble(...
    X, ...
    y, ...
    'Method', 'bag', ...
    'NumLearningCycles', 30, ...
    'ClassNames', classNames);

imp = oobPermutedPredictorImportance(classificationBagged);

[BB,II] = sort(imp,'descend');


tbl_RF_Bagged = [array2table(feat_names(II),'VariableNames',{'Feat'}) ...
    array2table(imp(II)','VariableNames',{'Importance'})];

writetable(tbl_RF_Bagged,fullfile(workdir,'\Outcome\tbl_RF_Bagged.xlsx'))


fig5 = figure;
bar(tbl_RF_Bagged.Importance);
title('Feature selection: Bagging');
ylabel('Predictor Importance');
xlabel('Predictors');
h=gca;
h.XTick = 1:length(II);
h.XTickLabel = tbl_RF_Bagged.Feat;
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
box off

saveas(fig5,fullfile(workdir,'\Outcome\FS_Bagging.fig'));

%% LIME 
template = templateTree(...
    'MaxNumSplits', 5, ...
    'Surrogate','on');

rng(2022); % For reproducibility 
classificationEnsemble = fitcensemble(...
    X, ...
    y, ...
    'Method', 'AdaBoostM2', ...
    'Learners', template, ...
    'ClassNames', classNames,...
    'PredictorNames',feat_names);


% classificationEnsemble = fitcensemble(...
%     X, ...
%     y, ...
%     'Method', 'bag', ...
%     'NumLearningCycles', 30, ...
%     'ClassNames', classNames);


pred_id = 3;
local_data = X(strcmp(y,classificationEnsemble.ClassNames{pred_id}),:);

Xs = X(ismember(y,classificationEnsemble.ClassNames{pred_id}),:);

% lime object (synthetic data set)
explainer_lime = lime(classificationEnsemble,Xs,'SimpleModelType','tree');
% option: 'linear'


num_datasample = 4;
querypoint = datasample(local_data,num_datasample,'replace',false);

num_feats = size(X,2);
for ii = 1:num_datasample
    exp_lime{ii} = fit(explainer_lime,querypoint(ii,:),num_feats,'KernelWidth',0.1);
end


fig6 = figure;
tiledlayout(2,2)

for ii = 1:num_datasample
    nexttile
    plot(exp_lime{ii})

    %     [~,I] = sort(abs(exp_lime{ii}.SimpleModel.Beta),'descend');
    %     table(exp_lime{ii}.SimpleModel.ExpandedPredictorNames(I)',exp_lime{ii}.SimpleModel.Beta(I))

    % % for RF
    % exp_lime{ii}.SimpleModel.predictorImportance

end


saveas(fig6,fullfile(workdir,strcat('\Outcome\FS_LIME_', ...
    classificationEnsemble.ClassNames{pred_id},'.fig')));


%% SHAPLEY

% pred_id = 1;
local_data = X(strcmp(y,classificationEnsemble.ClassNames{pred_id}),:);

rng(2022); % For reproducibility 
explainer_shap = shapley(classificationEnsemble,local_data,'Method','interventional-kernel');

num_datasample = 4;
querypoint = datasample(local_data,num_datasample,'replace',false);

for ii = 1:num_datasample
    exp_shap{ii} = fit(explainer_shap,querypoint(ii,:));
end


fig7 = figure;
tiledlayout(2,2)

for ii = 1:num_datasample
    nexttile
    plot(exp_shap{ii})
    exp_shap{ii}.ShapleyValues
end

saveas(fig7,fullfile(workdir,strcat('\Outcome\FS_SHAP_', ...
    classificationEnsemble.ClassNames{pred_id},'.fig')));

%% Partial Dependence Plot (PDP)

pred_id = 3;


feat_id_1 = 3;
feat_id_2 = 4;
fea1 = feat_names{feat_id_1};
fea2 = feat_names{feat_id_2};

fig8 = figure;
tiledlayout(1,2)
nexttile
plotPartialDependence(classificationEnsemble,fea1,classificationEnsemble.ClassNames{pred_id},local_data);
nexttile
plotPartialDependence(classificationEnsemble,fea2,classificationEnsemble.ClassNames{pred_id},local_data);

saveas(fig8,fullfile(workdir,'\Outcome\FS_PD_1.fig'));



[pd,x] = partialDependence(classificationEnsemble,fea1,classificationEnsemble.ClassNames);


fig9 = figure;
tiledlayout(1,2)
nexttile
bar(x,pd)
legend(classificationEnsemble.ClassNames)
title('Partial Dependence Plot');
ylabel('Score');
xlabel(fea1);
box off

nexttile
plotPartialDependence(classificationEnsemble,fea1,classificationEnsemble.ClassNames)
box off

saveas(fig9,fullfile(workdir,'\Outcome\FS_PD_2.fig'));



% {'setosa'    }
% {'versicolor'}
% {'virginica' }

fea1
fea2

tic
clear pd Xx Yy
[pd,Xx,Yy] = partialDependence(classificationEnsemble,["RBM17","TRIM47"],classificationEnsemble.ClassNames);
toc

disp(strcat('elapsed time = ',num2str(toc/60),' [min]'))


fig10 = figure;
surfc(Xx,Yy,squeeze(pd(pred_id,:,:)))
xlabel(fea1)
ylabel(fea2)
zlabel(classificationEnsemble.ClassNames{pred_id})
view([130 30])

saveas(fig10,fullfile(workdir,'\Outcome\FS_PD_3D.fig'));
