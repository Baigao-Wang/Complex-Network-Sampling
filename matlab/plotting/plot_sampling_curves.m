function plot_sampling_curves(all_results, cfg)

graph_names = fieldnames(all_results);

for g = 1:numel(graph_names)
    gname = graph_names{g};
    res = all_results.(gname);

    fprintf('\n[Plotting] %s ...\n', gname);

    % 示例：先只统计 ks_degree 均值
    figure('Name', ['Stage1 - ' gname], 'Color', 'w');
    tiledlayout(2, 3, 'Padding', 'compact', 'TileSpacing', 'compact');

    metric_names = {'ks_degree', 'ks_clustering', ...
                    'spearman_degree', 'spearman_closeness', 'spearman_betweenness'};

    titles = {'Degree Distribution (KS)', ...
              'Clustering Coefficient (KS)', ...
              'Degree Centrality (Spearman)', ...
              'Closeness Centrality (Spearman)', ...
              'Betweenness Centrality (Spearman)'};

    for m = 1:numel(metric_names)
        nexttile;
        hold on;

        for method_idx = 1:numel(cfg.sample_methods)
            method = cfg.sample_methods{method_idx};
            method_res = res.method_results.(method);

            y = zeros(numel(cfg.sample_ratios), 1);

            for r = 1:numel(cfg.sample_ratios)
                trials = method_res.per_ratio{r}.trial_results;
                vals = zeros(numel(trials), 1);

                for t = 1:numel(trials)
                    vals(t) = trials{t}.(metric_names{m});
                end
                y(r) = mean(vals, 'omitnan');
            end

            plot(cfg.sample_ratios, y, '-o', 'LineWidth', 1.2, 'DisplayName', method);
        end

        xlabel('Sampling Ratio');
        ylabel(metric_names{m}, 'Interpreter', 'none');
        title(titles{m});
        legend('Location', 'best');
        grid on;
    end
end

end