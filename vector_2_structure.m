function struc = vector_2_structure(v, fields)

    n = length(fields);
    for i = 1:n
        xS.(fields{i}) = v(i,:);
    end

    struc = xS;

end