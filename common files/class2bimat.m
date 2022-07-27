function [out_mat] = class2bimat(classes,string1)
clabs = categorical(classes);
[class_idx,gN,gL] = grp2idx(clabs);

for ii = 1:length(string1)
    out_mat(:,ii)=ismember(gN,string1(ii))
end