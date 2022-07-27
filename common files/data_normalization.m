function predictor = data_normalization(dat_set)

% data: variable x sample

Min_val     = repmat(min(dat_set')',1,size(dat_set,2));
Max_val     = repmat(max(dat_set')',1,size(dat_set,2));
predictor   = (dat_set -  Min_val)./(Max_val - Min_val);