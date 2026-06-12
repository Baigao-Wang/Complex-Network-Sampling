clear; clc; close all;

addpath(genpath(pwd));

cfg = config_rmsc_scan();
set_random_seed(cfg.seed);

if ~exist(cfg.results_dir, 'dir')
    mkdir(cfg.results_dir);
end

csv_dir = fullfile(cfg.results_dir, 'csv');
if ~exist(csv_dir, 'dir')
    mkdir(csv_dir);
end

all_scan_results = struct();
best_rows = {};

for i = 1:size(cfg.network_list, 1)
    net_name  = cfg.network_list{i, 1};
    file_path = cfg.network_list{i, 2};

    fprintf('\n========================================\n');
    fprintf('RMSC parameter scan for network: %s\n', net_name);
    fprintf('========================================\n');

    [A_full, A_lcc] = load_realworld_network(file_path, net_name); 
    A = A_lcc;

    scan_result = scan_rmsc_for_one_network(A, net_name, cfg);
    csv_dir = fullfile(cfg.results_dir, 'csv');
    if ~exist(csv_dir, 'dir')
        mkdir(csv_dir);
    end
    
    writetable(scan_result.scan_table, ...
        fullfile(csv_dir, sprintf('rmsc_scan_%s.csv', lower(net_name))));

    all_scan_results.(net_name) = scan_result;

    best_rows(end+1, :) = { ...
        net_name, ...
        scan_result.best_numSeeds, ...
        scan_result.best_Pc, ...
        scan_result.best_score, ...
        scan_result.best_metrics.ks_degree, ...
        scan_result.best_metrics.ks_clustering, ...
        scan_result.best_metrics.spearman_degree, ...
        scan_result.best_metrics.spearman_closeness, ...
        scan_result.best_metrics.spearman_betweenness, ...
        scan_result.best_metrics.actual_ratio_mean ...
        }; 
end

save(fullfile(cfg.results_dir, 'rmsc_param_scan_results.mat'), 'all_scan_results', '-v7.3');

best_table = cell2table(best_rows, 'VariableNames', { ...
    'Network', 'Best_numSeeds', 'Best_Pc', 'Best_Score', ...
    'KS_Degree', 'KS_Clustering', ...
    'Spearman_Degree', 'Spearman_Closeness', 'Spearman_Betweenness', ...
    'ActualRatioMean'});

disp(best_table);
writetable(best_table, fullfile(csv_dir, 'rmsc_best_params.csv'));

fprintf('\nRMSC parameter scan finished.\n');
fprintf('Best parameter table saved to: %s\n', fullfile(csv_dir, 'rmsc_best_params.csv'));