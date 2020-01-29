function WriteMLTable( fid, Condition_cell_array )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[num_textlines num_textcol ] = size(Condition_cell_array);
for m = 1:num_textlines
    for n = 1:num_textcol
        if n == num_textcol
            fprintf( fid, '%s\n', Condition_cell_array{ m, n } );
        elseif isa(Condition_cell_array{ m, n },'numeric')
            fprintf( fid, '%d\t', Condition_cell_array{ m, n } );
        elseif ~isa(Condition_cell_array{ m, n },'numeric')
            fprintf( fid, '%s\t', Condition_cell_array{ m, n } );
        end
    end
end

end

