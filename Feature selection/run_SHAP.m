

predictor = data_normalization(dat_set);

X = predictor';
feat_names = feat_name_2;
y = class_label';
classNames = unique(y);

%% SHAPLEY
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

rng(2022); % For reproducibility 

explainer_shap = shapley(classificationEnsemble,X,'Method','interventional-kernel');

num_sample = size(X,1);
num_feats = size(X,2);

% querypoint = datasample(local_data,num_datasample,'replace',false);

figure;
tiledlayout(5,8)

NR = []; PR = []; RD = [];
for ii = 1:num_sample
        
    exp_shap{ii} = fit(explainer_shap,X(ii,:));

    nexttile
    plot(exp_shap{ii});
    
    if ismember(y(ii),{'NR'})
        NR = [NR; [exp_shap{ii}.ShapleyValues.NR X(ii,:)']];
    elseif ismember(y(ii),{'PR'})
        PR = [PR; [exp_shap{ii}.ShapleyValues.PR X(ii,:)']];
    elseif ismember(y(ii),{'RD'})
        RD = [RD; [exp_shap{ii}.ShapleyValues.RD X(ii,:)']];
    end

end


tbl_NR = [array2table(repmat(feat_names,sum(ismember(y,{'NR'})),1),"VariableNames",{'Feat'}) array2table(NR,'VariableNames',{'SHAP','Exp'})];
fname = fullfile(workdir,strcat('\Outcome\Shape_NR','.csv'));
writetable(tbl_NR,fname)
tbl_PR = [array2table(repmat(feat_names,sum(ismember(y,{'PR'})),1),"VariableNames",{'Feat'}) array2table(PR,'VariableNames',{'SHAP','Exp'})];
fname = fullfile(workdir,strcat('\Outcome\Shape_PR','.csv'));
writetable(tbl_PR,fname)
tbl_RD = [array2table(repmat(feat_names,sum(ismember(y,{'RD'})),1),"VariableNames",{'Feat'}) array2table(RD,'VariableNames',{'SHAP','Exp'})];
fname = fullfile(workdir,strcat('\Outcome\Shape_RD','.csv'));
writetable(tbl_RD,fname)






