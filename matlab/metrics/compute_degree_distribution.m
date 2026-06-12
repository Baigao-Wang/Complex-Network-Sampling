function deg = compute_degree_distribution(A)

deg = sum(A, 2);
deg = deg(:);

end