function plot_metric_grid(all_results, cfg, metric_name)
% 每个指标画一张 3x2 图：
% 左列 ER (k=10,20,30)
% 右列 BA (k=10,20,30)

figure('Color', 'w', 'Position', [100, 80, 1100, 1200]);
tiledlayout(3, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

graph_order = { ...
    'ER_k10', 'BA_k10'; ...
    'ER_k20', 'BA_k20'; ...
    'ER_k30', 'BA_k30'};

title_map = containers.Map();
title_map('ks_degree') = 'Degree Distribution (KS distance)';
title_map('ks_clustering') = 'Clustering Coefficient (KS distance)';
title_map('spearman_degree') = 'Degree Centrality (Spearman)';
title_map('spearman_closeness') = 'Closeness Centrality (Spearman)';
title_map('spearman_betweenness') = 'Betweenness Centrality (Spearman)';

for i = 1:3
    for j = 1:2
        nexttile;
        hold on;

        key_name = graph_order{i, j};
        res = all_results.(key_name);

        for method_idx = 1:numel(cfg.sample_methods)
            method = cfg.sample_methods{method_idx};
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
                y_std(r)  = std(vals, 'omitnan');
            end

            errorbar(cfg.sample_ratios, y_mean, y_std, '-o', ...
                'LineWidth', 1.2, 'MarkerSize', 4, 'DisplayName', upper(method));
        end

        xlabel('Sampling Ratio');
        ylabel(metric_name, 'Interpreter', 'none');

        avg_deg_list = [10 20 30];

        if j == 1
            title(sprintf('ER, <k>=%d', avg_deg_list(i)));
        else
            title(sprintf('BA, <k>=%d', avg_deg_list(i)));
        end

        grid on;
        box on;

        if i == 1 && j == 2
            legend('Location', 'best');
        end
    end
end

sgtitle(title_map(metric_name), 'FontWeight', 'bold');

if cfg.save_figures
    saveas(gcf, fullfile(cfg.figure_dir, [metric_name, '.png']));
end

end