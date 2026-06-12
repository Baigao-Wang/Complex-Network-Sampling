clear; clc; close all;
addpath(genpath(pwd));

cfg = config_graph_similarity();
set_random_seed(cfg.seed);

% ========= Part 1: 构造经典网络数据集 =========
fprintf('\n[1/3] Building classical network dataset...\n');
classical_data = build_classical_network_dataset(cfg);

% ========= Part 2: PSO + SVM 选特征 =========
fprintf('\n[2/3] Running PSO-based feature selection...\n');
pso_result = pso_feature_selection(classical_data, cfg);

% 如果想先手动固定论文列出的11个关键指标，也可以在这里覆盖
cfg.selected_feature_idx = pso_result.best_idx;

save(fullfile(cfg.results_dir, 'pso_feature_selection.mat'), 'pso_result', 'cfg');

% ========= Part 3: 真实网络 graph similarity =========
fprintf('\n[3/3] Running real-world graph similarity...\n');
all_results = run_realworld_graph_similarity(cfg);

save(fullfile(cfg.results_dir, 'graph_similarity_realworld.mat'), 'all_results', 'cfg', '-v7.3');

export_graph_similarity_csv(all_results, cfg);
plot_graph_similarity_bar(all_results, cfg);

fprintf('\nGraph similarity pipeline finished.\n');