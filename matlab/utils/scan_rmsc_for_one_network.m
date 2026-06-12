function scan_result = scan_rmsc_for_one_network(A, net_name, cfg)

rows = {};
row_idx = 0;

best_score = -inf;
best_numSeeds = NaN;
best_Pc = NaN;
best_metrics = struct();

for s_idx = 1:numel(cfg.numSeeds_list)
    numSeeds = cfg.numSeeds_list(s_idx);

    for p_idx = 1:numel(cfg.Pc_list)
        Pc = cfg.Pc_list(p_idx);

        fprintf('  Testing numSeeds = %d, Pc = %.2f\n', numSeeds, Pc);

        ks_degree_vals = [];
        ks_clustering_vals = [];
        sp_degree_vals = [];
        sp_closeness_vals = [];
        sp_betweenness_vals = [];
        actual_ratio_vals = [];

        params.num_seeds = numSeeds;
        params.neighbor_select_prob = Pc;

        for r_idx = 1:numel(cfg.sample_ratios)
            ratio = cfg.sample_ratios(r_idx);

            for t = 1:cfg.num_trials
                sampled_nodes = sample_rmsc(A, ratio, params);
                As = extract_induced_subgraph(A, sampled_nodes);

                result = compute_all_basic_metrics(A, As, sampled_nodes);

                ks_degree_vals(end+1,1) = result.ks_degree; %#ok<AGROW>
                ks_clustering_vals(end+1,1) = result.ks_clustering; %#ok<AGROW>
                sp_degree_vals(end+1,1) = result.spearman_degree; %#ok<AGROW>
                sp_closeness_vals(end+1,1) = result.spearman_closeness; %#ok<AGROW>
                sp_betweenness_vals(end+1,1) = result.spearman_betweenness; %#ok<AGROW>
                actual_ratio_vals(end+1,1) = numel(sampled_nodes) / size(A,1); %#ok<AGROW>
            end
        end

        metrics.ks_degree = mean(ks_degree_vals, 'omitnan');
        metrics.ks_clustering = mean(ks_clustering_vals, 'omitnan');
        metrics.spearman_degree = mean(sp_degree_vals, 'omitnan');
        metrics.spearman_closeness = mean(sp_closeness_vals, 'omitnan');
        metrics.spearman_betweenness = mean(sp_betweenness_vals, 'omitnan');
        metrics.actual_ratio_mean = mean(actual_ratio_vals, 'omitnan');

        score = compute_rmsc_score(metrics, cfg);

        row_idx = row_idx + 1;
        rows(row_idx, :) = { ...
            net_name, numSeeds, Pc, score, ...
            metrics.ks_degree, metrics.ks_clustering, ...
            metrics.spearman_degree, metrics.spearman_closeness, metrics.spearman_betweenness, ...
            metrics.actual_ratio_mean};

        if score > best_score
            best_score = score;
            best_numSeeds = numSeeds;
            best_Pc = Pc;
            best_metrics = metrics;
        end
    end
end

scan_table = cell2table(rows, 'VariableNames', { ...
    'Network', 'numSeeds', 'Pc', 'Score', ...
    'KS_Degree', 'KS_Clustering', ...
    'Spearman_Degree', 'Spearman_Closeness', 'Spearman_Betweenness', ...
    'ActualRatioMean'});

scan_result.network = net_name;
scan_result.scan_table = scan_table;
scan_result.best_score = best_score;
scan_result.best_numSeeds = best_numSeeds;
scan_result.best_Pc = best_Pc;
scan_result.best_metrics = best_metrics;

end