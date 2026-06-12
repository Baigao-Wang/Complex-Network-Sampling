function plot_one_metric(ax, res, cfg, metric_name, plot_title, y_label)

axes(ax); %#ok<LAXES>
hold(ax, 'on');

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
        y_std(r)  = std(vals, 'omitnan');
    end

    errorbar(ax, cfg.sample_ratios, y_mean, y_std, '-o', ...
        'LineWidth', 1.2, ...
        'MarkerSize', 4, ...
        'DisplayName', upper(method));
end

xlabel(ax, 'Sampling Ratio');
ylabel(ax, y_label, 'Interpreter', 'none');
title(ax, plot_title, 'FontWeight', 'bold');
grid(ax, 'on');
box(ax, 'on');

legend(ax, 'Location', 'best');

end