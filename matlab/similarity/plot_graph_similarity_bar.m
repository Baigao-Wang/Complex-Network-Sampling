function plot_graph_similarity_bar(all_results, cfg)

network_keys = fieldnames(all_results);

for m_idx = 1:numel(cfg.sample_methods)
    method = cfg.sample_methods{m_idx};

    Y = zeros(numel(cfg.sample_ratios), numel(network_keys));

    for i = 1:numel(network_keys)
        net_name = network_keys{i};
        res = all_results.(net_name);
        method_res = res.method_results.(method);

        for r = 1:numel(cfg.sample_ratios)
            trials = method_res.per_ratio{r}.trial_results;
            vals = zeros(numel(trials), 1);
            for t = 1:numel(trials)
                vals(t) = trials{t}.distance;
            end
            Y(r, i) = mean(vals, 'omitnan');
        end
    end

    figure('Color', 'w', 'Position', [120, 100, 1050, 650]);
    bar(Y, 'grouped');
    set(gca, 'XTick', 1:numel(cfg.sample_ratios), ...
             'XTickLabel', string(cfg.sample_ratios));
    xlabel('Sampling Ratio');
    ylabel('Similarity Distance');
    title(sprintf('Sampling results of five real-world networks using %s method', upper(method)));
    legend(network_keys, 'Location', 'northeast');
    grid on; box on;

    saveas(gcf, fullfile(cfg.figure_dir, sprintf('realworld_similarity_%s.png', lower(method))));
end
end