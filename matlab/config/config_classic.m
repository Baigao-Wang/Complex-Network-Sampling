function cfg = config_classic()

cfg.seed = 42;
cfg.results_dir = fullfile(pwd, 'results');

if ~exist(cfg.results_dir, 'dir')
    mkdir(cfg.results_dir);
end

% 网络规模
cfg.N = 1000;

% 目标平均度
cfg.avg_degrees = [10, 20, 30];

% 图类型
cfg.graph_types = {'ER', 'BA'};

% 采样方法
cfg.sample_methods = {'random', 'bfs', 'rmsc'};

% 采样比例
cfg.sample_ratios = 0.1:0.1:0.9;

% 每组重复次数
cfg.num_trials = 10;

% 是否使用最大连通子图
cfg.use_lcc = true;

% RMSC 参数（严格对应你找到的 Python 代码）
cfg.rmsc.num_seeds = 30;
cfg.rmsc.neighbor_select_prob = 0.7;

% 保存绘图
cfg.save_figures = true;
cfg.figure_dir = fullfile(cfg.results_dir, 'figures');
if ~exist(cfg.figure_dir, 'dir')
    mkdir(cfg.figure_dir);
end

end