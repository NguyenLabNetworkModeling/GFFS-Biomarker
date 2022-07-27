%% (Recursive/Sequential) Forward Feature Selection (FFS)

% data preparation
predictor   = data_normalization(dat_set);
feat_name = feat_name_2;

% just for a test
predictor = predictor(21:30,:);
feat_name = feat_name(21:30);


% Step 1: calculate importance of individual feature
pred_acc_avg = IS_ffs_module(predictor,class_label);

% ordering the features according to its importance
[BB,II] = sort(pred_acc_avg,'descend');

% the most important feature
new_feats_ids = II(1);
new_feats_names =  feat_name(new_feats_ids);
new_feats_perfor = BB(1);

tic
while length(new_feats_names) < length(feat_name)

    % Step 2: adding a new feat and evaludate the performance

    % compose new predictor
    tmp_feat_id  = find(~ismember(feat_name,new_feats_names));
    tmp_feat_name = feat_name(tmp_feat_id);


    % evaludate the performance of all combinations
    part_acc_avg = [];
    for ii = 1:length(tmp_feat_id)
        disp(ii)
        parPredictor = predictor([new_feats_ids tmp_feat_id(ii)],:);
        part_acc_avg(ii) = ML_unit(parPredictor,class_label);
    end


    % find the best combination
    [BB,II] = sort(part_acc_avg,'descend');
    new_feats_ids = [new_feats_ids tmp_feat_id(II(1))];
    new_feats_names =  feat_name(new_feats_ids);
    new_feats_perfor = [new_feats_perfor BB(1)];
end

disp(strcat('elapsed time = ',num2str(toc/60),' [min]'))



% plot
fig1 = figure;
plot(new_feats_perfor)
set(gca,'XTick',1:length(new_feats_names),'XTickLabel',new_feats_names)
grid on


% save
tbl_FS_FFS= [array2table(new_feats_perfor','VariableNames',{'Pred'}) ...
    array2table(new_feats_names,'VariableNames',{'Feature'})];

writetable(tbl_FS_FFS,fullfile(workdir,'\Outcome\tbl_FS_FFS.xlsx'));

saveas(fig1,fullfile(workdir,'\Outcome\FS_FFS.fig'));

