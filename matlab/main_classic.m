clear; clc; close all;

addpath(genpath(pwd));

cfg = config_classic();
set_random_seed(cfg.seed);

% 创建结果目录
if ~exist(cfg.results_dir, 'dir')
    mkdir(cfg.results_dir);
end

csv_dir = fullfile(cfg.results_dir, 'csv');
if ~exist(csv_dir, 'dir')
    mkdir(csv_dir);
end

all_results = struct();

for g_idx = 1:numel(cfg.graph_types)
    graph_type = cfg.graph_types{g_idx};

    for d_idx = 1:numel(cfg.avg_degrees)
        avg_deg = cfg.avg_degrees(d_idx);

        fprintf('\n========================================\n');
        fprintf('Graph Type: %s | Target Avg Degree: %d\n', graph_type, avg_deg);
        fprintf('========================================\n');

        % -------- 生成网络 --------
        switch graph_type
            case 'ER'
                p = avg_deg / (cfg.N - 1);
                A = generate_er_graph(cfg.N, p);

                graph_params = struct();
                graph_params.N = cfg.N;
                graph_params.avg_degree_target = avg_deg;
                graph_params.p = p;

            case 'BA'
                m = avg_deg / 2;
                if abs(m - round(m)) > 1e-10
                    error('For BA, avg degree must be even so that m=avg_deg/2 is integer.');
                end
                m = round(m);
                m0 = m + 1;

                A = generate_ba_graph(cfg.N, m0, m);

                graph_params = struct();
                graph_params.N = cfg.N;
                graph_params.avg_degree_target = avg_deg;
                graph_params.m = m;
                graph_params.m0 = m0;

            otherwise
                error('Unknown graph type.');
        end

        % 可选：仅保留最大连通子图
        if cfg.use_lcc
            A = largest_connected_component(A);
        end

        % 实际平均度
        graph_params.avg_degree_actual = mean(sum(A, 2));

        key_name = sprintf('%s_k%d', graph_type, avg_deg);

        graph_result = struct();
        graph_result.graph_type = graph_type;
        graph_result.graph_params = graph_params;
        graph_result.ratios = cfg.sample_ratios;
        graph_result.methods = cfg.sample_methods;
        graph_result.trials = cfg.num_trials;
        graph_result.A = A;   % 保存原网络，后续可用于度分布曲线

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
                            sampled_nodes = sample_rmsc(A, ratio, cfg.rmsc);

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

        all_results.(key_name) = graph_result;
    end
end

% 保存 mat
save_results_struct(all_results, fullfile(cfg.results_dir, 'classic_stage1_results.mat'));

% -------- 导出 CSV 数据 --------
export_metric_csvs(all_results, cfg);

% -------- 画五个指标的大图 --------
plot_metric_grid(all_results, cfg, 'ks_degree');
plot_metric_grid(all_results, cfg, 'ks_clustering');
plot_metric_grid(all_results, cfg, 'spearman_degree');
plot_metric_grid(all_results, cfg, 'spearman_closeness');
plot_metric_grid(all_results, cfg, 'spearman_betweenness');

% -------- 补充：度分布曲线图 --------
ratio_list_demo = [0.1, 0.3, 0.5, 0.7];
plot_degree_distribution_grid(all_results, cfg, 'random', ratio_list_demo);
plot_degree_distribution_grid(all_results, cfg, 'bfs', ratio_list_demo);
plot_degree_distribution_grid(all_results, cfg, 'rmsc', ratio_list_demo);

fprintf('\nClassic ER/BA batch experiment finished.\n');
fprintf('CSV files have been exported to: %s\n', fullfile(cfg.results_dir, 'csv'));