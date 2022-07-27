
% load training data
filename        = strcat('Explant_ResponseGroup_Allprot_DEGs.xlsx');
tbl_pde_dat     = readtable(filename,'Sheet','DEG expression');
tbl_pde_label   = readtable(filename,'Sheet','Target labels');
tbl_deg_pval    = readtable(filename,'Sheet','DEG pvals');

feat_name_full = tbl_pde_dat.GeneName;

%% Composition of training data
sheets  = sheetnames('feature set list.xlsx');
% str_1 = strcat('(',num2str([1:length(sheets)]'),')');
% str_2 = sheets;
% disp([str_1 str_2]);  


% choose a feature set (to be trained)
feat_id         = task.feature;

model_name      = sheets(feat_id);
filename        = strcat('Explant_ResponseGroup_Allprot_DEGs.xlsx');
my_feat_names      = table2array(readtable('feature set list.xlsx','Sheet',model_name,...
    'ReadVariableNames',false));


% membering
tbl_pde_dat(~ismember(tbl_pde_dat.GeneName,my_feat_names),:)= [];


dat_set         = table2array(tbl_pde_dat(:,2:end));
% row: features 
% col: samples (n = 40)
class_label     = table2array(tbl_pde_label);
feat_name_2   = tbl_pde_dat.GeneName;


% ordering the gene names
[Lia,Locb]  = ismember(my_feat_names,tbl_pde_dat.GeneName);

% check the order of the gene name
disp([tbl_pde_dat(Locb,:).GeneName my_feat_names]);


hmo = clustergram(log10((dat_set)),...
    'Cluster','column',...
    'Standardize',2,...
    'RowLabels',feat_name_2,...
    'ColumnLabels',class_label,...
    'ColumnLabelsRotate',45);

fig_1 = plot(hmo);

fname = strcat(fullfile(workdir,'\Outcome'),'\heatmap_',model_name,'.jpeg');
saveas(fig_1,fname);

