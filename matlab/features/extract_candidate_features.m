function feat = extract_candidate_features(A)
% 20维候选特征

deg = sum(A, 2); deg = deg(:);
clu = compute_clustering_distribution(A); clu = clu(:);
avg_nbr_deg = compute_average_neighbor_degree(A); avg_nbr_deg = avg_nbr_deg(:);
ego_edges = compute_neighborhood_edge_count(A); ego_edges = ego_edges(:);

feat_deg      = safe_feature_stats(deg);         % 4
feat_clu      = safe_feature_stats(clu);         % 4
feat_nbr_deg  = safe_feature_stats(avg_nbr_deg); % 4
feat_ego      = safe_feature_stats(ego_edges);   % 4

apl       = compute_average_path_length_lcc(A);                    % 1
assort    = compute_degree_pearson_assortativity_undirected(A);    % 1
deg_ent   = compute_degree_entropy(deg);                           % 1
bet_stats = compute_betweenness_node_stats(A);                     % 1 (先取均值，后续可改)

feat = [ ...
    feat_deg, ...
    feat_clu, ...
    feat_nbr_deg, ...
    feat_ego, ...
    apl, assort, deg_ent, bet_stats ...
];

feat = feat(:)';
end