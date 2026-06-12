function export_realworld_metric_csvs(all_results, cfg)

csv_dir = fullfile(cfg.results_dir, 'csv');
if ~exist(csv_dir, 'dir')
    mkdir(csv_dir);
end

network_keys = fieldnames(all_results);

summary_rows = {};
trial_rows = {};

summary_header = { ...
    'Network', 'Method', 'TargetRatio', 'ActualRatioMean', 'ActualRatioStd', ...
    'KS_Degree_Mean', 'KS_Degree_Std', ...
    'KS_Clustering_Mean', 'KS_Clustering_Std', ...
    'Spearman_Degree_Mean', 'Spearman_Degree_Std', ...
    'Spearman_Closeness_Mean', 'Spearman_Closeness_Std', ...
    'Spearman_Betweenness_Mean', 'Spearman_Betweenness_Std'};

trial_header = { ...
    'Network', 'Method', 'TargetRatio', 'TrialID', 'ActualRatio', 'SampledNum', ...
    'KS_Degree', 'KS_Clustering', ...
    'Spearman_Degree', 'Spearman_Closeness', 'Spearman_Betweenness'};

for i = 1:numel(network_keys)
    net_name = network_keys{i};
    res = all_results.(net_name);

    for m_idx = 1:numel(cfg.sample_methods)
        method = cfg.sample_methods{m_idx};
        method_res = res.method_results.(method);

        for r = 1:numel(cfg.sample_ratios)
            ratio = cfg.sample_ratios(r);
            trials = method_res.per_ratio{r}.trial_results;

            ks_degree_vals = zeros(numel(trials), 1);
            ks_clustering_vals = zeros(numel(trials), 1);
            sp_degree_vals = zeros(numel(trials), 1);
            sp_closeness_vals = zeros(numel(trials), 1);
            sp_betweenness_vals = zeros(numel(trials), 1);
            actual_ratio_vals = zeros(numel(trials), 1);

            for t = 1:numel(trials)
                tr = trials{t};

                ks_degree_vals(t) = tr.ks_degree;
                ks_clustering_vals(t) = tr.ks_clustering;
                sp_degree_vals(t) = tr.spearman_degree;
                sp_closeness_vals(t) = tr.spearman_closeness;
                sp_betweenness_vals(t) = tr.spearman_betweenness;
                actual_ratio_vals(t) = tr.actual_ratio;

                trial_rows(end+1, :) = { ...
                    net_name, method, ratio, t, tr.actual_ratio, tr.sampled_num, ...
                    tr.ks_degree, tr.ks_clustering, ...
                    tr.spearman_degree, tr.spearman_closeness, tr.spearman_betweenness}; %#ok<AGROW>
            end

            summary_rows(end+1, :) = { ...
                net_name, method, ratio, ...
                mean(actual_ratio_vals, 'omitnan'), std(actual_ratio_vals, 'omitnan'), ...
                mean(ks_degree_vals, 'omitnan'), std(ks_degree_vals, 'omitnan'), ...
                mean(ks_clustering_vals, 'omitnan'), std(ks_clustering_vals, 'omitnan'), ...
                mean(sp_degree_vals, 'omitnan'), std(sp_degree_vals, 'omitnan'), ...
                mean(sp_closeness_vals, 'omitnan'), std(sp_closeness_vals, 'omitnan'), ...
                mean(sp_betweenness_vals, 'omitnan'), std(sp_betweenness_vals, 'omitnan')}; %#ok<AGROW>
        end
    end
end

summary_table = cell2table(summary_rows, 'VariableNames', summary_header);
trial_table = cell2table(trial_rows, 'VariableNames', trial_header);

writetable(summary_table, fullfile(csv_dir, 'realworld_metric_summary.csv'));
writetable(trial_table, fullfile(csv_dir, 'realworld_trial_details.csv'));

fprintf('Real-world CSV export finished: %s\n', csv_dir);