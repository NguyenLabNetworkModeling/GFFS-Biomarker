%% Recursive Feature Elemination (RFE)

% data preparation
% predictor (variables x samples) - note
predictor   = data_normalization(dat_set);
feat_name = feat_name_2;

% just for a test
predictor = predictor(21:30,:);
feat_name = feat_name(21:30);
num_feats = size(predictor,1);


% run the model with the full features
pred_val_cnt = ML_unit(predictor,class_label);

% a temporary prediction
tmp_predictor = predictor;


tic
for rr = 1:num_feats-1

    disp(rr)
 
    % Step 1: calculate an importance of individual feature
    % by removing each one by one
    pred_acc_avg = IS_rfe_module(tmp_predictor,class_label);


    % Step 2: Find and eliminate the worst feature
    [BB,II] = sort(pred_acc_avg,'descend');

    worst_feat_idx = II(1);
    worst_feat_names(rr,1) = feat_name(worst_feat_idx);

    % eliminating the worst feature
    tmp_predictor(worst_feat_idx,:) = [];
    feat_name(worst_feat_idx) = [];


    % Step 3: evaludate the prediction peformance
    pred_val(rr,1) = ML_unit(tmp_predictor,class_label);
end

disp(strcat('elapsed time = ',num2str(toc/60),' [min]'))


% for the last remains
worst_feat_names(num_feats,1) = feat_name;
pred_val(num_feats,1) = NaN;


% plot
fig1 = figure;
plot(pred_val)
set(gca,'XTick',1:length(worst_feat_names),'XTickLabel',worst_feat_names)
grid on


% save
tbl_FS_RFE= [array2table(pred_val,'VariableNames',{'Pred'}) ...
    array2table(worst_feat_names,'VariableNames',{'Feature'})];

writetable(tbl_FS_RFE,fullfile(workdir,'\Outcome\tbl_FS_RFE.xlsx'));

saveas(fig1,fullfile(workdir,'\Outcome\FS_RFE.fig'));
