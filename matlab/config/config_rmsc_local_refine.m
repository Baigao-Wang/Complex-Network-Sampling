function cfg = config_rmsc_local_refine()

cfg.seed = 42;
cfg.results_dir = fullfile(pwd, 'results_rmsc_local_refine');

if ~exist(cfg.results_dir, 'dir')
    mkdir(cfg.results_dir);
end

root_dir = 'real_world_networks';

cfg.network_list = {
    'Euroroad',   fullfile(root_dir, 'subelj_euroroad', 'out.subelj_euroroad_euroroad');
    'Usgrid',     fullfile(root_dir, 'opsahl-powergrid', 'out.opsahl-powergrid');
    'Netscience', fullfile(root_dir, 'network.csv', 'edges.csv');
    'Yeast',      fullfile(root_dir, 'bio-yeast-protein-inter', 'bio-yeast-protein-inter.edges');
    'Facebook',   fullfile(root_dir, 'facebook', 'facebook_combined.txt');
};

% 你当前粗扫描得到的最优参数
cfg.coarse_best_params.Euroroad.numSeeds = 5;
cfg.coarse_best_params.Euroroad.Pc = 0.7;

cfg.coarse_best_params.Usgrid.numSeeds = 5;
cfg.coarse_best_params.Usgrid.Pc = 0.7;

cfg.coarse_best_params.Netscience.numSeeds = 5;
cfg.coarse_best_params.Netscience.Pc = 0.5;

cfg.coarse_best_params.Yeast.numSeeds = 10;
cfg.coarse_best_params.Yeast.Pc = 0.5;

cfg.coarse_best_params.Facebook.numSeeds = 5;
cfg.coarse_best_params.Facebook.Pc = 0.3;

% 局部细扫的偏移范围
cfg.numSeeds_offsets = [-5, -2, 0, 2, 5];
cfg.Pc_offsets = [-0.10, -0.05, 0, 0.05, 0.10];

cfg.Pc_min = 0.05;
cfg.Pc_max = 0.95;

% 扫描时使用的采样比例
cfg.sample_ratios = 0.1:0.1:0.8;

% 每组参数重复次数
cfg.num_trials = 8;   % 比粗扫略高一点

% 评分权重
cfg.weight_ks_degree = 0.5;
cfg.weight_ks_clustering = 0.5;
cfg.weight_spearman_degree = 1/3;
cfg.weight_spearman_closeness = 1/3;
cfg.weight_spearman_betweenness = 1/3;

% 是否对 actual ratio 偏差做轻微惩罚
cfg.use_actual_ratio_penalty = false;
cfg.actual_ratio_penalty_weight = 0.0;
% 惩罚项示意： score = score - w * mean(max(target_ratio - actual_ratio, 0))

end