


if task.valid == 1
    % load training data
    filename        = strcat('valid_rnaseq_feat.xlsx');
    tbl_pde_dat     = readtable(filename,'Sheet','predictor');
    tbl_pde_label   = readtable(filename,'Sheet','target');
    
    % load trained models
    load('SVM_Model_val_rnaseq.mat')

elseif task.valid == 2
    % load training data
    filename        = strcat('valid_protein_feat.xlsx');
    tbl_pde_dat     = readtable(filename,'Sheet','predictor');
    tbl_pde_label   = readtable(filename,'Sheet','target');

    % load trained models
    load('SVM_Model_val_protein.mat')


elseif task.valid == 3
    % load training data
    filename        = strcat('valid_maggie_feat.xlsx');
    tbl_pde_dat     = readtable(filename,'Sheet','predictor');
    tbl_pde_label   = readtable(filename,'Sheet','target');

    % load trained models
    load('SVM_Model_val_maggie.mat')
end



%% Composition of training data
sheets  = sheetnames('feature_file.xlsx');
% str_1 = strcat('(',num2str([1:length(sheets)]'),')');
% str_2 = sheets;
% disp([str_1 str_2]);  


% choose a feature set (to be trained)
feat_id         = task.feature;

model_name      = sheets(feat_id);
filename        = strcat('Explant_ResponseGroup_Allprot_DEGs.xlsx');
my_feat_names      = table2array(readtable('feature_file.xlsx','Sheet',model_name,...
    'ReadVariableNames',false));


% membering
tbl_pde_dat(~ismember(tbl_pde_dat.Gene,my_feat_names),:)= [];


predictor         = table2array(tbl_pde_dat(:,2:end));
% row: features 
% col: samples (n = 40)
class_label     = table2array(tbl_pde_label);
feat_names   = tbl_pde_dat.Gene;


% ordering the gene names
[Lia,Locb]  = ismember(my_feat_names,tbl_pde_dat.Gene);

% check the order of the gene name
disp([tbl_pde_dat(Locb,:).Gene my_feat_names]);


