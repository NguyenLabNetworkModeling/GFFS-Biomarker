function [cell_names, tissue_names]= splitter_cell_tissue_names(var_names)

% data 1: var_names
% 1 x m cell array containing {'_'}
% e.g., var_names = tbl_protein_Quant.Properties.VariableNames; 

var_names(~contains(var_names,'_')) = strcat(var_names(~contains(var_names,'_')),...
    '_',var_names(~contains(var_names,'_')));

tmp_spliter=cell(1,length(var_names));
tmp_spliter(:) ={'_'};
tmp_spliter=cellfun(@strsplit,var_names,tmp_spliter,'UniformOutput',false);

% getting first element of each cell array with different sizes
cell_names = cellfun(@(v)v(1),tmp_spliter);
tissue_names = cellfun(@(v)v(2),tmp_spliter);
