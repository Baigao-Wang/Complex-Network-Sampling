function result = compute_all_basic_metrics(A, As, sampled_nodes)

result = struct();

% 基本信息
result.num_nodes_original = size(A, 1);
result.num_nodes_sampled = size(As, 1);
result.sampled_nodes = sampled_nodes(:);

% ---------- 分布类 ----------
deg_full = compute_degree_distribution(A);
deg_sub  = compute_degree_distribution(As);

clu_full = compute_clustering_distribution(A);
clu_sub  = compute_clustering_distribution(As);

result.degree_distribution_original = deg_full;
result.degree_distribution_sampled  = deg_sub;
result.clustering_distribution_original = clu_full;
result.clustering_distribution_sampled  = clu_sub;

result.ks_degree = compute_ks_distance(deg_full, deg_sub);
result.ks_clustering = compute_ks_distance(clu_full, clu_sub);

% ---------- 中心性类 ----------
% 对“采样节点集合”分别在原图和采样子图中计算，再做 Spearman
deg_cent_full = compute_degree_centrality(A, sampled_nodes);
deg_cent_sub  = compute_degree_centrality(As);

clo_cent_full = compute_closeness_centrality(A, sampled_nodes);
clo_cent_sub  = compute_closeness_centrality(As);

bet_cent_full = compute_betweenness_centrality(A, sampled_nodes);
bet_cent_sub  = compute_betweenness_centrality(As);

result.degree_centrality_original = deg_cent_full;
result.degree_centrality_sampled  = deg_cent_sub;
result.closeness_centrality_original = clo_cent_full;
result.closeness_centrality_sampled  = clo_cent_sub;
result.betweenness_centrality_original = bet_cent_full;
result.betweenness_centrality_sampled  = bet_cent_sub;

result.spearman_degree = compute_spearman_rankcorr(deg_cent_full, deg_cent_sub);
result.spearman_closeness = compute_spearman_rankcorr(clo_cent_full, clo_cent_sub);
result.spearman_betweenness = compute_spearman_rankcorr(bet_cent_full, bet_cent_sub);

end