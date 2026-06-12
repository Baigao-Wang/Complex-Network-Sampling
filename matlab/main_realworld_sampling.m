clear; clc; close all;

addpath(genpath(pwd));

cfg = config_realworld();
set_random_seed(cfg.seed);

if ~exist(cfg.results_dir, 'dir')
    mkdir(cfg.results_dir);
end

csv_dir = fullfile(cfg.results_dir, 'csv');
if ~exist(csv_dir, 'dir')
    mkdir(csv_dir);
end

all_results = struct();

for i = 1:size(cfg.network_list, 1)
    net_name  = cfg.network_list{i, 1};
    file_path = cfg.network_list{i, 2};

    fprintf('\n========================================\n');
    fprintf('Processing real-world network: %s\n', net_name);
    fprintf('========================================\n');

    % 读取真实网络：A_full 为全图，A 为 LCC
    [A_full, A] = load_realworld_network(file_path, net_name);

    graph_result = struct();
    graph_result.network_name = net_name;
    graph_result.file_path = file_path;
    graph_result.A_full = A_full;
    graph_result.A = A;   % 这里抽样统一在 LCC 上做
    graph_result.ratios = cfg.sample_ratios;
    graph_result.methods = cfg.sample_methods;
    graph_result.trials = cfg.num_trials;
    graph_result.num_nodes_full = size(A_full, 1);
    graph_result.num_nodes_lcc  = size(A, 1);
    graph_result.num_edges_full = nnz(triu(A_full));
    graph_result.num_edges_lcc  = nnz(triu(A));

    % 如果是 RMSC，记录当前网络使用的最优参数
    if isfield(cfg.rmsc_best, net_name)
        graph_result.rmsc_params = cfg.rmsc_best.(net_name);
        params = cfg.rmsc_best.(net_name);
        fprintf('Using RMSC params for %s: numSeeds = %d, Pc = %.2f\n', ...
            net_name, params.num_seeds, params.neighbor_select_prob);
    else
        error('No best RMSC parameters configured for network: %s', net_name);
    end

    for m_idx = 1:numel(cfg.sample_methods)
        method = cfg.sample_methods{m_idx};
        fprintf('\nMethod: %s\n', method);

        method_result = struct();
        method_result.name = method;
        method_result.per_ratio = cell(numel(cfg.sample_ratios), 1);

        for r_idx = 1:numel(cfg.sample_ratios)
            ratio = cfg.sample_ratios(r_idx);
            fprintf('  Ratio = %.2f\n', ratio);

            trial_results = cell(cfg.num_trials, 1);

            for t = 1:cfg.num_trials
                switch method
                    case 'random'
                        sampled_nodes = sample_random_nodes(A, ratio);

                    case 'bfs'
                        sampled_nodes = sample_bfs(A, ratio);

                    case 'rmsc'
                        params = cfg.rmsc_best.(net_name);
                        sampled_nodes = sample_rmsc(A, ratio, params);

                    otherwise
                        error('Unknown method: %s', method);
                end

                As = extract_induced_subgraph(A, sampled_nodes);

                metric_result = compute_all_basic_metrics(A, As, sampled_nodes);
                metric_result.target_ratio = ratio;
                metric_result.actual_ratio = numel(sampled_nodes) / size(A, 1);
                metric_result.sampled_num = numel(sampled_nodes);
                metric_result.trial_id = t;

                trial_results{t} = metric_result;
            end

            method_result.per_ratio{r_idx}.ratio = ratio;
            method_result.per_ratio{r_idx}.trial_results = trial_results;
        end

        graph_result.method_results.(method) = method_result;
    end

    all_results.(net_name) = graph_result;
end

save_results_struct(all_results, fullfile(cfg.results_dir, 'realworld_sampling_results.mat'));

export_realworld_metric_csvs(all_results, cfg);

% 一个网络一张图，包含五个指标
plot_realworld_all_networks_figures(all_results, cfg);

fprintf('\nReal-world sampling experiment finished.\n');
fprintf('CSV files saved to: %s\n', csv_dir);