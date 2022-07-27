function [duplicates] = find_duplicated_names(cell_names)

% data 1: col_labels 
%  m x 1 cell array 
% e.g., col_labels = table2array(tbl_deg_label_dat); 

tmp_var = tabulate(cell_names);
tbl_cell = cell2table(tmp_var,'VariableNames', ...
    {'Value','Count','Percent'});
tbl_cell = sortrows(tbl_cell,'Count','descend');
duplicates = tbl_cell.Value(tbl_cell.Count >1);