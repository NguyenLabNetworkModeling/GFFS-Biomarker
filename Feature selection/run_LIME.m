

predictor = data_normalization(dat_set);

X = predictor';
feat_names = feat_name_2;
y = class_label';
classNames = unique(y);



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


% lime object (synthetic data set)
explainer_lime = lime(classificationEnsemble,X,'SimpleModelType','tree');
% option: 'linear'

num_sample = size(X,1);
num_feats = size(X,2);


for ii = 1:num_sample
    exp_lime{ii} = fit(explainer_lime,X(ii,:),num_feats,'KernelWidth',0.1);
end


%% 
figure;
tiledlayout(5,8)

NR = []; PR = []; RD = [];
for ii = 1:num_sample

    feat_importance = zeros(5,1);

    nexttile
    plot(exp_lime{ii});

    %     [~,I] = sort(abs(exp_lime{ii}.SimpleModel.Beta),'descend');
    %     table(exp_lime{ii}.SimpleModel.ExpandedPredictorNames(I)',exp_lime{ii}.SimpleModel.Beta(I))

    % % for RF
    iscore  = exp_lime{ii}.SimpleModel.predictorImportance;    
    
    ft_idx = ismember(feat_names,exp_lime{ii}.SimpleModel.PredictorNames);
    
    % %check
    %[feat_names(ft_idx) exp_lime{ii}.SimpleModel.PredictorNames']

    feat_importance(ft_idx,1) = iscore;

    if ismember(y(ii),{'NR'})
        NR = [NR; [feat_importance X(ii,:)']+rand(1)*1e-4];
    elseif ismember(y(ii),{'PR'})
        PR = [PR; [feat_importance X(ii,:)']+rand(1)*1e-4];
    elseif ismember(y(ii),{'RD'})
        RD = [RD; [feat_importance X(ii,:)']+rand(1)*1e-4];
    end
end

tbl_NR = [array2table(repmat(feat_names,sum(ismember(y,{'NR'})),1),"VariableNames",{'Feat'}) array2table(NR,'VariableNames',{'LIME','Exp'})];
fname = fullfile(workdir,strcat('\Outcome\LIME_NR','.csv'));
writetable(tbl_NR,fname)
tbl_PR = [array2table(repmat(feat_names,sum(ismember(y,{'PR'})),1),"VariableNames",{'Feat'}) array2table(PR,'VariableNames',{'LIME','Exp'})];
fname = fullfile(workdir,strcat('\Outcome\LIME_PR','.csv'));
writetable(tbl_PR,fname)
tbl_RD = [array2table(repmat(feat_names,sum(ismember(y,{'RD'})),1),"VariableNames",{'Feat'}) array2table(RD,'VariableNames',{'LIME','Exp'})];
fname = fullfile(workdir,strcat('\Outcome\LIME_RD','.csv'));
writetable(tbl_RD,fname)




% saveas(fig6,fullfile(workdir,strcat('\Outcome\FS_LIME_', ...
%     classificationEnsemble.ClassNames{pred_id},'.fig')));