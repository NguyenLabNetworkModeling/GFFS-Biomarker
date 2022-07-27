%% CALCULATION OF INFLUENCE SCORE


p_val       = tbl_deg_pval.DEGs_Pval;
predictor   = data_normalization(dat_set);


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
nd2 = num_feature + 1;  % perturbation (157 + Control)



parfor  masterIDX = 1:nd1*nd2
    
    disp(masterIDX)
    
    [idx1,idx2] = ind2sub([nd1,nd2],masterIDX);
    
    % copy variables for par
    predictor_P     = predictor;    
    class_label_P   = class_label;
    train_idx_P     = train_idx;
    test_idx_P      = test_idx;
    
    
    % remove a feature    
    try
        predictor_rm            = predictor_P;
        predictor_rm(idx2,:)    = [];
    catch
        disp(strcat('Gene ID = ',num2str(idx2),'is the control'))
        predictor_rm            = predictor_P;
    end
    
        
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
[nrow,~] = size(score_mat_c);
score_mat = reshape(score_mat_c,[nd1,nd2]);


% averaged prediction accuracy
pred_acc_avg    = mean(score_mat);



%%  Influence Score
%

IS_score = -(pred_acc_avg(1:end-1) - pred_acc_avg(end))/pred_acc_avg(end);

fig_1 = figure;
fig_1.Position = [680   717   341   261];

xx  = 1:num_feature;
yy  = IS_score;
plot(xx,yy,'LineWidth',1.5)
set(gca,'LineWidth',1)
xlabel('Input Variable')
ylabel('Influence Score')
pbaspect([4 3 1]/4)
box off


fname = strcat(fullfile(workdir,'\Outcome'),'\IS_plot',model_name,'.jpeg');
saveas(fig_1,fname);


%% Influence score (sorted)

[IS_sorted, IS_ii]  = sort(IS_score,'descend');

feat_name_2(IS_ii)


fig_2 = figure;
fig_2.Position = [681   797   205   182];

xx = 1:num_feature;
yy = IS_sorted;

plot(xx, yy, 'LineWidth',1.5)
set(gca,'LineWidth',1)
xlabel('Genes')
xtickangle(45)
ylabel('Influence score')
box off
grid on


fname = strcat(fullfile(workdir,'\Outcome'),'\IS_plot_sorted',model_name,'.jpeg');
saveas(fig_2,fname);



%% Influence score (top ranked) 
fig_3 = figure;
fig_3.Position = [893   797   560   182];
top_rank = 20;

xx = 1:top_rank;
yy = IS_sorted(1:top_rank);

plot(xx, yy, '-o', 'LineWidth',1.5)
set(gca,'LineWidth',1)

%xticks(1:20)
%xticklabels(feat_name_2(iid1(1:20)))
%xtickangle(45)
axis([0 top_rank min(IS_sorted(1:top_rank)) max(IS_sorted(1:top_rank))*1.1])
box off
grid on
xlabel('Genes')
ylabel('Influence score')

ht=text([1:top_rank]+0.001,IS_sorted(1:top_rank)+0.001,feat_name_2(IS_ii(1:top_rank)));
set(ht,'Rotation',45)
set(ht,'FontSize',8)

fname = strcat(fullfile(workdir,'\Outcome'),'\IS_plot_top_ranked',model_name,'.jpeg');
saveas(fig_3,fname);



%% correlation plot between p-value and prediction score

fig_4   = figure;

cmap    = colormap('jet');
stepcol = floor(size(cmap,1)/5);

scatter(p_val,IS_score,...
    'LineWidth',1,...
    'MarkerEdgeColor',rgb('Black'),...
    'MarkerFaceColor',rgb('Blue'))
set(gca,'LineWidth',1)
xlabel('p-value')
ylabel('influence score')


[r1,pp1]    = corr(p_val,IS_score');

title(strcat('Coeff. = ',num2str(r1),'/ p-val = ',num2str(pp1)))
pbaspect([1 1 1]/4)
xtickangle(45)



fname = strcat(fullfile(workdir,'\Outcome'),'\corr_IS_vs_pval',model_name,'.jpeg');
saveas(fig_4,fname);



% save data
tbl_influence_score = [array2table(feat_name_2,'VariableNames',{'feature'}) ...
    array2table(IS_score','VariableNames',{'score'})];


fname = strcat(fullfile(workdir,'\Outcome'),'\influence_score_',model_name,'.xlsx');
writetable(tbl_influence_score,fname,...    
    'WriteVariableNames',true,...
    'WriteRowNames',true)