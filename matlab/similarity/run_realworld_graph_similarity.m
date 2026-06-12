function all_results = run_realworld_graph_similarity(cfg)

all_results = struct();

for i = 1:size(cfg.network_list, 1)
    net_name  = cfg.network_list{i, 1};
    file_path = cfg.network_list{i, 2};

    fprintf('\nReal-world similarity: %s\n', net_name);

    [A_full, A] = load_realworld_network(file_path, net_name); %#ok<ASGLU>
    feat_full = extract_candidate_features(A);
    feat_full = feat_full(cfg.selected_feature_idx);

    graph_result = struct();
    graph_result.network_name = net_name;
    graph_result.feature_full = feat_full;
    graph_result.methods = cfg.sample_methods;
    graph_result.ratios = cfg.sample_ratios;

    params = cfg.rmsc_best.(net_name);

    for m_idx = 1:numel(cfg.sample_methods)
        method = cfg.sample_methods{m_idx};
        method_result = struct();
        method_result.name = method;
        method_result.per_ratio = cell(numel(cfg.sample_ratios), 1);

        for r_idx = 1:numel(cfg.sample_ratios)
            ratio = cfg.sample_ratios(r_idx);
            trial_results = cell(cfg.num_trials, 1);

            for t = 1:cfg.num_trials
                switch method
                    case 'bfs'
                        sampled_nodes = sample_bfs(A, ratio);
                    case 'rmsc'
                        sampled_nodes = sample_rmsc(A, ratio, params);
                    otherwise
                        error('Unknown method: %s', method);
                end

                As = extract_induced_subgraph(A, sampled_nodes);

                feat_sample = extract_candidate_features(As);
                feat_sample = feat_sample(cfg.selected_feature_idx);

                d = compute_graph_distance(feat_full, feat_sample, cfg.distance_type);

                one = struct();
                one.target_ratio = ratio;
                one.actual_ratio = numel(sampled_nodes) / size(A, 1);
                one.distance = d;
                one.sampled_num = numel(sampled_nodes);

                trial_results{t} = one;
            end

            method_result.per_ratio{r_idx}.ratio = ratio;
            method_result.per_ratio{r_idx}.trial_results = trial_results;
        end

        graph_result.method_results.(method) = method_result;
    end

    all_results.(net_name) = graph_result;
end
end