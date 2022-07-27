%% Identify the protein expression signatures 
% 1) 

for ii = 1:length(discrete_exp.lab)
    
    dat_part = discrete_exp.data{ii}';
    dat_pclass = discrete_exp.lab{ii};
    
    
    c_high_idx1 = bin2dec(reshape(char(dat_part + '0'),size(dat_part)));
    
    tb_pattern = array2table(tabulate(c_high_idx1),'VariableNames',{'Pattern_ID','Count','Percent'});
    
    tb_pattern(tb_pattern.Count == 0,:)=[];
    tb_pattern.Pattern = dec2bin(tb_pattern.Pattern_ID);
    
    
    file_name = strcat(fullfile(workdir,'Outcome'),'\counter_pattern','.xlsx');
    writetable(tb_pattern,file_name,'sheet',class_name{ii})
    
    
    
    % make truth table and minimization
    
    
    [uin_ptrn, ~, ~]  = unique(dat_part,'rows');
    high_idx1         = bin2dec(reshape(char(uin_ptrn + '0'),size(uin_ptrn)));
        
    tbl_truth    =   truthTable(num_markers);
    
    for jj = 1:length(high_idx1)
        
        tbl_truth(high_idx1(jj)+1,num_markers+1) = 1;
        
    end
    
    
    file_name = strcat(fullfile(workdir,'Outcome'),'\truth_table','.xlsx');
    writetable(tb_pattern,file_name,'sheet',class_name{ii})

    
    tbl_z = erase(num2str(tbl_truth(:,end)'),' ');
    
    [Bins,inps,Nums,~] = minTruthtable(tbl_z);
    
    
    file_name = strcat(fullfile(workdir,'Outcome'),'\signature_pattern','.xlsx');
    writetable(table(Bins),file_name,'sheet',class_name{ii})
    
    
end


