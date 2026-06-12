function plot_realworld_single_network_figure(all_results, cfg, net_name)
% 一个 figure 对应一个真实网络
% 第一行：两个 KS 指标（居中）
% 第二行：三个 Spearman 指标（居中）

res = all_results.(net_name);

figure('Color', 'w', 'Position', [80, 80, 1500, 850]);

% 用 2x6 网格实现“居中”
tl = tiledlayout(2, 6, 'Padding', 'compact', 'TileSpacing', 'compact');

% ---------- 第一行：两个 KS 指标 ----------
ax1 = nexttile(tl, 2, [1 2]);   % 第1行第2-3列
plot_one_metric(ax1, res, cfg, 'ks_degree', ...
    'Degree Distribution (KS distance)', 'KS distance');

ax2 = nexttile(tl, 4, [1 2]);   % 第1行第4-5列
plot_one_metric(ax2, res, cfg, 'ks_clustering', ...
    'Clustering Coefficient (KS distance)', 'KS distance');

% ---------- 第二行：三个 Spearman 指标 ----------
ax3 = nexttile(tl, 7, [1 2]);   % 第2行第1-2列
plot_one_metric(ax3, res, cfg, 'spearman_degree', ...
    'Degree Centrality (Spearman)', 'Spearman');

ax4 = nexttile(tl, 9, [1 2]);   % 第2行第3-4列
plot_one_metric(ax4, res, cfg, 'spearman_closeness', ...
    'Closeness Centrality (Spearman)', 'Spearman');

ax5 = nexttile(tl, 11, [1 2]);  % 第2行第5-6列
plot_one_metric(ax5, res, cfg, 'spearman_betweenness', ...
    'Betweenness Centrality (Spearman)', 'Spearman');

sgtitle(sprintf('%s', net_name), 'FontWeight', 'bold', 'FontSize', 18);

if cfg.save_figures
    saveas(gcf, fullfile(cfg.figure_dir, sprintf('%s_all_metrics.png', lower(net_name))));
end

end