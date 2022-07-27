function  newStr = cell_string_split(cell_str,delim_char)

delimiter = cell(size(cell_str));
delimiter(:) = {delim_char};
newStr = cellfun(@strsplit,cell_str,delimiter,'UniformOutput',false);



