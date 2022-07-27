function Truth_table = truthTable(vect_len)
max_val = 2^vect_len - 1 ;
values  = 0 : max_val;  values  = values';
Truth_table = de2bi(values, vect_len, 'left-msb');
% disp(Truth_table)