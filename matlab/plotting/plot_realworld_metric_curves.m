function plot_realworld_metric_curves(all_results, cfg, metric_name)

network_keys = fieldnames(all_results);

figure('Color', 'w', 'Position', [100, 100, 1200, 800]);
tiledlayout(2, 3, 'Padding', 'compact', 'TileSpacing', 'compact');

title_map = containers.Map();
title_map('ks_degree') = 'Degree Distribution (KS distance)';
title_map('ks_clustering') = 'Clustering Coefficient (KS distance)';
title_map('spearman_degree') = 'Degree Centrality (Spearman)';
title_map('spearman_closeness') = 'Closeness Centrality (Spearman)';
title_map('spearman_betweenness') = 'Betweenness Centrality (Spearman)';

for i = 1:numel(network_keys)
    nexttile;
    hold on;

    net_name = network_keys{i};
    res = all_results.(net_name);

    for m_idx = 1:numel(cfg.sample_methods)
        method = cfg.sample_methods{m_idx};
        method_res = res.method_results.(method);

        y_mean = zeros(numel(cfg.sample_ratios), 1);
        y_std  = zeros(numel(cfg.sample_ratios), 1);

        for r = 1:numel(cfg.sample_ratios)
            trials = method_res.per_ratio{r}.trial_results;
            vals = zeros(numel(trials), 1);

            for t = 1:numel(trials)
                vals(t) = trials{t}.(metric_name);
            end

            y_mean(r) = mean(vals, 'omitnan');
            y_std(r) = std(vals, 'omitnan');
        end

        errorbar(cfg.sample_ratios, y_mean, y_std, '-o', ...
            'LineWidth', 1.2, ...
            'MarkerSize', 4, ...
            'DisplayName', upper(method));
    end

    title(net_name);
    xlabel('Sampling Ratio');
    ylabel(metric_name, 'Interpreter', 'none');
    grid on;
    box on;

    if i == 2
        legend('Location', 'best');
    end
end

if isKey(title_map, metric_name)
    sgtitle(title_map(metric_name), 'FontWeight', 'bold');
else
    sgtitle(metric_name, 'Interpreter', 'none', 'FontWeight', 'bold');
end

if cfg.save_figures
    saveas(gcf, fullfile(cfg.figure_dir, [metric_name, '.png']));
end