function plot_degree_distribution_compare(A, method, ratio_list, cfg)
% 画原网络与不同采样比例下的度分布曲线（单次采样）

deg_full = sum(A, 2);
max_deg_global = max(deg_full);

sampled_graphs = cell(numel(ratio_list), 1);
actual_ratios = zeros(numel(ratio_list), 1);

% 先完成采样，并统一最大度范围
for i = 1:numel(ratio_list)
    ratio = ratio_list(i);

    switch lower(method)
        case 'random'
            sampled_nodes = sample_random_nodes(A, ratio);
        case 'bfs'
            sampled_nodes = sample_bfs(A, ratio);
        case 'rmsc'
            sampled_nodes = sample_rmsc(A, ratio, cfg.rmsc);
        otherwise
            error('Unknown method: %s', method);
    end

    As = extract_induced_subgraph(A, sampled_nodes);
    sampled_graphs{i} = As;
    actual_ratios(i) = numel(sampled_nodes) / size(A, 1);

    if ~isempty(As)
        deg_s = sum(As, 2);
        if ~isempty(deg_s)
            max_deg_global = max(max_deg_global, max(deg_s));
        end
    end
end

k_support = (0:max_deg_global)';

[k_full, pmf_full] = compute_degree_pmf(A, k_support);

figure('Color', 'w');
hold on;

plot(k_full, pmf_full, 'k-', 'LineWidth', 2.2, 'DisplayName', 'Original');

for i = 1:numel(ratio_list)
    As = sampled_graphs{i};
    [k_s, pmf_s] = compute_degree_pmf(As, k_support);

    plot(k_s, pmf_s, '-o', ...
        'LineWidth', 1.2, ...
        'MarkerSize', 4, ...
        'DisplayName', sprintf('%s target=%.2f actual=%.2f', ...
        upper(method), ratio_list(i), actual_ratios(i)));
end

xlabel('Degree k');
ylabel('P(k)');
title(sprintf('Degree Distribution Comparison - %s', upper(method)));
legend('Location', 'northeast');
grid on;
box on;

end