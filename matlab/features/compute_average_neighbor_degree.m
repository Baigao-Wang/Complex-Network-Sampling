function avg_nbr_deg = compute_average_neighbor_degree(A)

N = size(A, 1);
deg = sum(A, 2);
avg_nbr_deg = zeros(N, 1);

for i = 1:N
    nbr = find(A(i, :) > 0);

    if isempty(nbr)
        avg_nbr_deg(i) = 0;
    else
        avg_nbr_deg(i) = mean(deg(nbr), 'omitnan');
    end
end

end