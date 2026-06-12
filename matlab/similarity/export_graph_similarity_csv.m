function export_graph_similarity_csv(all_results, cfg)

summary_rows = {};
network_keys = fieldnames(all_results);

for i = 1:numel(network_keys)
    net_name = network_keys{i};
    res = all_results.(net_name);

    for m_idx = 1:numel(cfg.sample_methods)
        method = cfg.sample_methods{m_idx};
        method_res = res.method_results.(method);

        for r = 1:numel(cfg.sample_ratios)
            ratio = cfg.sample_ratios(r);
            trials = method_res.per_ratio{r}.trial_results;

            vals = zeros(numel(trials), 1);
            ar = zeros(numel(trials), 1);

            for t = 1:numel(trials)
                vals(t) = trials{t}.distance;
                ar(t) = trials{t}.actual_ratio;
            end

            summary_rows(end+1, :) = { ...
                net_name, method, ratio, ...
                mean(vals, 'omitnan'), std(vals, 'omitnan'), ...
                mean(ar, 'omitnan'), std(ar, 'omitnan')}; %#ok<AGROW>
        end
    end
end

T = cell2table(summary_rows, 'VariableNames', ...
    {'Network','Method','Ratio','DistanceMean','DistanceStd','ActualRatioMean','ActualRatioStd'});

writetable(T, fullfile(cfg.csv_dir, 'graph_similarity_summary.csv'));
end