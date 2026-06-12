function export_metric_csvs(all_results, cfg)

csv_dir = fullfile(cfg.results_dir, 'csv');
if ~exist(csv_dir, 'dir')
    mkdir(csv_dir);
end

graph_keys = fieldnames(all_results);

summary_rows = {};
trial_rows = {};

summary_header = { ...
    'GraphKey', 'GraphType', 'AvgDegreeTarget', 'AvgDegreeActual', ...
    'Method', 'TargetRatio', 'ActualRatioMean', 'ActualRatioStd', ...
    'KS_Degree_Mean', 'KS_Degree_Std', ...
    'KS_Clustering_Mean', 'KS_Clustering_Std', ...
    'Spearman_Degree_Mean', 'Spearman_Degree_Std', ...
    'Spearman_Closeness_Mean', 'Spearman_Closeness_Std', ...
    'Spearman_Betweenness_Mean', 'Spearman_Betweenness_Std'};

trial_header = { ...
    'GraphKey', 'GraphType', 'AvgDegreeTarget', 'AvgDegreeActual', ...
    'Method', 'TargetRatio', 'TrialID', 'ActualRatio', 'SampledNum', ...
    'KS_Degree', 'KS_Clustering', ...
    'Spearman_Degree', 'Spearman_Closeness', 'Spearman_Betweenness'};

for g = 1:numel(graph_keys)
    key_name = graph_keys{g};
    res = all_results.(key_name);

    graph_type = res.graph_type;
    avg_deg_target = res.graph_params.avg_degree_target;
    avg_deg_actual = res.graph_params.avg_degree_actual;

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
                    key_name, graph_type, avg_deg_target, avg_deg_actual, ...
                    method, ratio, t, tr.actual_ratio, tr.sampled_num, ...
                    tr.ks_degree, tr.ks_clustering, ...
                    tr.spearman_degree, tr.spearman_closeness, tr.spearman_betweenness}; %#ok<AGROW>
            end

            summary_rows(end+1, :) = { ...
                key_name, graph_type, avg_deg_target, avg_deg_actual, ...
                method, ratio, ...
                mean(actual_ratio_vals, 'omitnan'), std(actual_ratio_vals, 'omitnan'), ...
                mean(ks_degree_vals, 'omitnan'), std(ks_degree_vals, 'omitnan'), ...
                mean(ks_clustering_vals, 'omitnan'), std(ks_clustering_vals, 'omitnan'), ...
                mean(sp_degree_vals, 'omitnan'), std(sp_degree_vals, 'omitnan'), ...
                mean(sp_closeness_vals, 'omitnan'), std(sp_closeness_vals, 'omitnan'), ...
                mean(sp_betweenness_vals, 'omitnan'), std(sp_betweenness_vals, 'omitnan')}; %#ok<AGROW>
        end
    end
end

% 转为 table
summary_table = cell2table(summary_rows, 'VariableNames', summary_header);
trial_table = cell2table(trial_rows, 'VariableNames', trial_header);

% 写出总表
writetable(summary_table, fullfile(csv_dir, 'metric_summary.csv'));
writetable(trial_table, fullfile(csv_dir, 'trial_details.csv'));

% -------- 再按单个指标分别导出，方便 Origin 直接读取 --------
export_single_metric_table(summary_table, csv_dir, ...
    'KS_Degree_Mean', 'KS_Degree_Std', 'ks_degree.csv');

export_single_metric_table(summary_table, csv_dir, ...
    'KS_Clustering_Mean', 'KS_Clustering_Std', 'ks_clustering.csv');

export_single_metric_table(summary_table, csv_dir, ...
    'Spearman_Degree_Mean', 'Spearman_Degree_Std', 'spearman_degree.csv');

export_single_metric_table(summary_table, csv_dir, ...
    'Spearman_Closeness_Mean', 'Spearman_Closeness_Std', 'spearman_closeness.csv');

export_single_metric_table(summary_table, csv_dir, ...
    'Spearman_Betweenness_Mean', 'Spearman_Betweenness_Std', 'spearman_betweenness.csv');

fprintf('CSV export finished: %s\n', csv_dir);

end


function export_single_metric_table(summary_table, csv_dir, mean_col, std_col, filename)

T = summary_table(:, {'GraphKey', 'GraphType', 'AvgDegreeTarget', 'AvgDegreeActual', ...
    'Method', 'TargetRatio', 'ActualRatioMean', 'ActualRatioStd', mean_col, std_col});

writetable(T, fullfile(csv_dir, filename));

end