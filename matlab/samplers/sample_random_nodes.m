function sampled_nodes = sample_random_nodes(A, sample_ratio)

N = size(A, 1);
k = max(1, round(sample_ratio * N));

sampled_nodes = randperm(N, k);
sampled_nodes = sort(sampled_nodes(:));

end