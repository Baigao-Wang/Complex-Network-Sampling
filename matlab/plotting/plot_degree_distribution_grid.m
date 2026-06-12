function plot_degree_distribution_grid(all_results, cfg, method, ratio_list)
% 对指定方法，画 3x2 的 degree distribution 曲线图
% 黑线: original
% 彩色线: 不同采样比例

figure('Color', 'w', 'Position', [100, 80, 1100, 1200]);
tiledlayout(3, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

graph_order = { ...
    'ER_k10', 'BA_k10'; ...
    'ER_k20', 'BA_k20'; ...
    'ER_k30', 'BA_k30'};

avg_deg_list = [10 20 30];

for i = 1:3
    for j = 1:2
        nexttile;
        hold on;

        key_name = graph_order{i, j};
        res = all_results.(key_name);
        A = res.A;

        % 统一横轴
        max_deg_global = max(sum(A, 2));

        sampled_As = cell(numel(ratio_list), 1);
        actual_ratios = zeros(numel(ratio_list), 1);

        for rr = 1:numel(ratio_list)
            ratio = ratio_list(rr);

            switch lower(method)
                case 'random'
                    sampled_nodes = sample_random_nodes(A, ratio);
                case 'bfs'
                    sampled_nodes = sample_bfs(A, ratio);
                case 'rmsc'
                    sampled_nodes = sample_rmsc(A, ratio, cfg.rmsc);
                otherwise
                    error('Unknown method.');
            end

            As = extract_induced_subgraph(A, sampled_nodes);
            sampled_As{rr} = As;
            actual_ratios(rr) = numel(sampled_nodes) / size(A, 1);

            if ~isempty(As)
                max_deg_global = max(max_deg_global, max(sum(As, 2)));
            end
        end

        k_support = (0:max_deg_global)';
        [k_full, pmf_full] = compute_degree_pmf(A, k_support);

        plot(k_full, pmf_full, 'k-', 'LineWidth', 2.2, 'DisplayName', 'Original');

        for rr = 1:numel(ratio_list)
            [k_s, pmf_s] = compute_degree_pmf(sampled_As{rr}, k_support);

            plot(k_s, pmf_s, '-o', ...
                'LineWidth', 1.1, ...
                'MarkerSize', 3.5, ...
                'DisplayName', sprintf('%.1f', actual_ratios(rr)));
        end

        xlabel('Degree k');
        ylabel('P(k)');

        if j == 1
            title(sprintf('ER, <k>=%d', avg_deg_list(i)));
        else
            title(sprintf('BA, <k>=%d', avg_deg_list(i)));
        end

        grid on;
        box on;

        if i == 1 && j == 2
            legend('Location', 'northeast');
        end
    end
end

sgtitle(sprintf('Degree Distribution Comparison (%s)', upper(method)));

if cfg.save_figures
    saveas(gcf, fullfile(cfg.figure_dir, sprintf('degree_dist_%s.png', lower(method))));
end

end