function cfg = config_realworld()

cfg.seed = 42;
cfg.results_dir = fullfile(pwd, 'results_realworld');

if ~exist(cfg.results_dir, 'dir')
    mkdir(cfg.results_dir);
end

cfg.sample_methods = {'random', 'bfs', 'rmsc'};
cfg.sample_ratios = 0.1:0.1:1.0;
cfg.num_trials = 10;

root_dir = 'real_world_networks';

cfg.network_list = {
    'Euroroad',   fullfile(root_dir, 'subelj_euroroad', 'out.subelj_euroroad_euroroad');
    'Usgrid',     fullfile(root_dir, 'opsahl-powergrid', 'out.opsahl-powergrid');
    'Netscience', fullfile(root_dir, 'network.csv', 'edges.csv');
    'Yeast',      fullfile(root_dir, 'bio-yeast-protein-inter', 'bio-yeast-protein-inter.edges');
    'Facebook',   fullfile(root_dir, 'facebook', 'facebook_combined.txt');
};

% -------- 每个网络各自最优的 RMSC 参数 --------
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

cfg.figure_dir = fullfile(cfg.results_dir, 'figures');
if ~exist(cfg.figure_dir, 'dir')
    mkdir(cfg.figure_dir);
end

cfg.save_figures = true;

end