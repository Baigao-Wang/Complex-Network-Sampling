function nbr_edge_count = compute_neighborhood_edge_count(A)
% 每个节点邻居诱导子图中的边数

N = size(A, 1);
nbr_edge_count = zeros(N, 1);

for i = 1:N
    nbr = find(A(i, :) > 0);

    if numel(nbr) < 2
        nbr_edge_count(i) = 0;
    else
        subA = A(nbr, nbr);
        nbr_edge_count(i) = sum(subA(:)) / 2; % 无向图边数
    end
end

end