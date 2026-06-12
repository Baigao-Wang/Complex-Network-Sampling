function cfg = config_graph_similarity()

cfg.seed = 42;

% -------- 1) 候选特征空间 --------
cfg.feature_dim_total = 20;

% 论文原文存在 20维 / 11维 / 13维表述不一致：
% - 候选空间先按20维实现
% - selected_feature_idx 在PSO完成后覆盖
cfg.selected_feature_idx = [];   % 为空表示后续由PSO生成

cfg.feature_norm_method = 'zscore';  % 'zscore' or 'minmax'
cfg.distance_type = 'euclidean';

% -------- 2) 经典网络数据集（用于PSO+SVM）--------
cfg.classical.num_sizes = 100;
cfg.classical.base_size = 100;
cfg.classical.er_p = 0.1;
cfg.classical.ba_m = 3;
cfg.classical.ws_k = 6;      % 你可以自行定一个合理值
cfg.classical.ws_p = 0.1;

cfg.classical.num_test_set_2 = 30;
cfg.classical.num_test_set_3 = 50;

% -------- 3) PSO参数 --------
cfg.pso.num_particles = 30;
cfg.pso.max_iter = 50;
cfg.pso.w = 0.7;
cfg.pso.c1 = 1.5;
cfg.pso.c2 = 1.5;
cfg.pso.min_features = 3;
cfg.pso.max_features = 20;
cfg.pso.cv_folds = 5;

% -------- 4) 真实网络相似性分析 --------
cfg.sample_methods = {'bfs', 'rmsc'};
cfg.sample_ratios = 0.1:0.1:0.8;
cfg.num_trials = 10;

root_dir = 'real_world_networks';
cfg.network_list = {
    'Euroroad',   fullfile(root_dir, 'subelj_euroroad', 'out.subelj_euroroad_euroroad');
    'Usgrid',     fullfile(root_dir, 'opsahl-powergrid', 'out.opsahl-powergrid');
    'Netscience', fullfile(root_dir, 'network.csv', 'edges.csv');
    'Yeast',      fullfile(root_dir, 'bio-yeast-protein-inter', 'bio-yeast-protein-inter.edges');
    'Facebook',   fullfile(root_dir, 'facebook', 'facebook_combined.txt');
};

cfg.rmsc_best.Euroroad.num_seeds = 3;
cfg.rmsc_best.Euroroad.neighbor_select_prob = 0.80;

cfg.rmsc_best.Usgrid.num_seeds = 3;
cfg.rmsc_best.Usgrid.neighbor_select_prob = 0.70;

cfg.rmsc_best.Netscience.num_seeds = 3;
cfg.rmsc_best.Netscience.neighbor_select_prob = 0.45;

cfg.rmsc_best.Yeast.num_seeds = 10;
cfg.rmsc_best.Yeast.neighbor_select_prob = 0.40;

cfg.rmsc_best.Facebook.num_seeds = 7;
cfg.rmsc_best.Facebook.neighbor_select_prob = 0.35;

cfg.results_dir = fullfile(pwd, 'results_graph_similarity');
cfg.figure_dir = fullfile(cfg.results_dir, 'figures');
cfg.csv_dir = fullfile(cfg.results_dir, 'csv');

if ~exist(cfg.results_dir, 'dir'); mkdir(cfg.results_dir); end
if ~exist(cfg.figure_dir, 'dir'); mkdir(cfg.figure_dir); end
if ~exist(cfg.csv_dir, 'dir'); mkdir(cfg.csv_dir); end

end