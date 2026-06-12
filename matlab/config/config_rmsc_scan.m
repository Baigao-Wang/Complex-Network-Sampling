function cfg = config_rmsc_scan()

cfg.seed = 42;
cfg.results_dir = fullfile(pwd, 'results_rmsc_scan');

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

% 扫描参数网格
cfg.numSeeds_list = [5, 10, 20, 30, 50, 80];
cfg.Pc_list       = [0.3, 0.5, 0.7, 0.8, 0.9];

% 扫描时用的采样比例
cfg.sample_ratios = 0.1:0.1:0.8;

% 每组参数重复次数
cfg.num_trials = 5;

% score 权重
cfg.weight_ks_degree = 0.5;
cfg.weight_ks_clustering = 0.5;
cfg.weight_spearman_degree = 1/3;
cfg.weight_spearman_closeness = 1/3;
cfg.weight_spearman_betweenness = 1/3;

end