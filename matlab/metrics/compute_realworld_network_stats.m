function stats = compute_realworld_network_stats(A)

% 全图统计
G = graph(A);
stats.N = numnodes(G);
stats.L = numedges(G);

% 最大连通子图
bins = conncomp(G);
comp_ids = unique(bins);
comp_sizes = zeros(numel(comp_ids), 1);

for i = 1:numel(comp_ids)
    comp_sizes(i) = sum(bins == comp_ids(i));
end

[~, idx_max] = max(comp_sizes);
largest_comp_id = comp_ids(idx_max);
lcc_nodes = find(bins == largest_comp_id);

A_lcc = A(lcc_nodes, lcc_nodes);
G_lcc = graph(A_lcc);

stats.NLCC = numnodes(G_lcc);
stats.LLCC = numedges(G_lcc);

% 直径
Dmat = distances(G_lcc);
stats.D = max(Dmat(~isinf(Dmat)));

% 聚类系数（平均局部聚类系数）
stats.C = mean(local_clustering_coefficients(A_lcc));

end