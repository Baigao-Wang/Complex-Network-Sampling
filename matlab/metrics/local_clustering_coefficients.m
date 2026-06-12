function c = local_clustering_coefficients(A)

N = size(A, 1);
c = zeros(N, 1);

for i = 1:N
    nbr = find(A(i, :) > 0);
    k = numel(nbr);

    if k < 2
        c(i) = 0;
        continue;
    end

    subA = A(nbr, nbr);
    e = sum(subA(:)) / 2;  % 无向图边数
    c(i) = 2 * e / (k * (k - 1));
end
end