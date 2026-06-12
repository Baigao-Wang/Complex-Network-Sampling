function classical_data = build_classical_network_dataset(cfg)

X = [];
y = [];

% -------- ER --------
for i = 1:cfg.classical.num_sizes
    N = cfg.classical.base_size * i;
    A = erdos_reyni_graph(N, cfg.classical.er_p);
    X = [X; extract_candidate_features(A)]; %#ok<AGROW>
    y = [y; 1]; %#ok<AGROW>
end

% -------- BA --------
for i = 1:cfg.classical.num_sizes
    N = cfg.classical.base_size * i;
    A = ba_graph_undirected(N, cfg.classical.ba_m);
    X = [X; extract_candidate_features(A)]; %#ok<AGROW>
    y = [y; 2]; %#ok<AGROW>
end

% -------- WS --------
for i = 1:cfg.classical.num_sizes
    N = cfg.classical.base_size * i;
    A = ws_graph_undirected(N, cfg.classical.ws_k, cfg.classical.ws_p);
    X = [X; extract_candidate_features(A)]; %#ok<AGROW>
    y = [y; 3]; %#ok<AGROW>
end

X_norm = normalize_feature_matrix(X, cfg.feature_norm_method);

classical_data.X = X_norm;
classical_data.X_raw = X;
classical_data.y = y;
end