function vec = structure_2_vector(s, fields)
    
    v = zeros(length(fields), 1);
    for i = 1:length(fields)
        v(i,:) = s.(fields{i});
    end
    
    vec = v;

end