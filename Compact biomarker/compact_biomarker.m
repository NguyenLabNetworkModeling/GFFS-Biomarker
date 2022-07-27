%% optimal marker proteins (heatmap and box plot, trueth table)
%% Biomarker proteins



% Number of Marker Genes
num_markers     =  5;
file_name       = strcat('companion_biomarker_combinations_final.xlsx');
tbl_markers     = readtable(file_name,'Sheet',num2str(num_markers));

% Marker genes
markers         = table2array(tbl_markers(1,1:end-1));

% marker gene set
tbl_pde_dat(~ismember(tbl_pde_dat.GeneName,markers),:)= [];



%% Heatmap of marker genes
dat_exp     = table2array(tbl_pde_dat(:,2:end));
dat_class   = table2array(tbl_pde_label);
dat_genes   = tbl_pde_dat.GeneName;


% exp_values=(exp_values((biomarkers(1:cutoff)),:));
heatmap1    = HeatMap(log10(dat_exp),'Standardize',2,...
    'ColumnLabels',dat_class,...
    'RowLabels',dat_genes,...
    'ColumnLabelsRotate',45);

fig_1 = plot(heatmap1);
file_name = strcat(fullfile(workdir,'Outcome'),'\heatmap_compact_marker');
saveas(fig_1,file_name,'jpeg')
saveas(fig_1,file_name,'fig')


%% Heatmap of marker genes for RD, NR, PD
%
%
% class_name = {'RD','NR','PR'};
% for ii = 1:length(class_name)
% class_idx = ismember(dat_class,class_name{ii});
%
% % exp_values=(exp_values((biomarkers(1:cutoff)),:));
% heatmap1=HeatMap(log10(dat_exp(:,class_idx)),'Standardize',2,...
%     'ColumnLabels',dat_class(class_idx),...
%     'RowLabels',dat_genes,...
%     'ColumnLabelsRotate',45);
% end
%% Box plot

fig_2           = figure;
fig_2.Position  = [333         753        1188         226];

for ii = 1:size(dat_exp,1)
    
    subplot(1,size(dat_exp,1),ii)
    boxplot(log10(dat_exp(ii,:)),dat_class,'Notch','on')
    xtickangle(45)
    ylabel('Expression (log10)')
    title(dat_genes(ii))
    pbaspect([2 4 1]/4)
    box off
    
end


file_name = strcat(fullfile(workdir,'Outcome'),'\bar_graph_compact_marker');
saveas(fig_2,file_name,'jpeg')
saveas(fig_2,file_name,'fig')





%% unpaired t-test



for ii=1:size(dat_exp,1)
    
    RP_set = dat_exp(ii,strcmp(dat_class,'RD'));
    NR_set = dat_exp(ii,strcmp(dat_class,'NR'));
    PR_set = dat_exp(ii,strcmp(dat_class,'PR'));
    
    [~,pvalue(ii,1),~,~] = ttest2(RP_set,NR_set);
    [~,pvalue(ii,2),~,~] = ttest2(NR_set,PR_set);
    [~,pvalue(ii,3),~,~] = ttest2(RP_set,PR_set);
end

tbl_pvalue  =  table(pvalue(:,1),pvalue(:,2),pvalue(:,3));
tbl_pvalue.Properties.VariableNames     = {'RD_vs_NR','NR_vs_PR','RD_vs_PR'};
tbl_pvalue.Properties.RowNames          = dat_genes;

file_name = strcat(fullfile(workdir,'Outcome'),'\biomarker_pvalue.xlsx');
writetable(tbl_pvalue,file_name,'WriteRowNames',true)




%% Normalize and discretize expression data
%% to generate binary level (high and low)

% median value in a sample wide
med_val = median(dat_exp,2);


class_name = {'RD','NR','PR'};

for ii = 1:length(class_name)
    c_idx    = ismember(dat_class,class_name{ii});
    c_exp    = dat_exp(:,c_idx);
    c_exp_nl = c_exp./repmat(med_val,1,size(c_exp,2));
    
    c_exp_bin   =c_exp_nl;
    c_exp_bin(c_exp_nl >= 1) = 1;
    c_exp_bin(c_exp_nl < 1) = 0;
    
    % exp_cutoff_ternary = double(exp_val_nm >= repmat(median(exp_val_nm,2),1,size(exp_val_nm,2)));
    bin_exp{ii} = c_exp_bin;
    
    discrete_exp.data{ii}    = c_exp_bin;
    discrete_exp.lab{ii}     = class_name{ii};
    
    heatmap2=HeatMap(c_exp_bin,...
        'ColumnLabels',dat_class(c_idx),...
        'RowLabels',dat_genes,...
        'ColumnLabelsRotate',45);
    
    
    fig_3 = plot(heatmap2);
    
    file_name = strcat(fullfile(workdir,'Outcome'),'\heatmap_bin_',class_name{ii});
    saveas(fig_3,file_name,'jpeg')
end



