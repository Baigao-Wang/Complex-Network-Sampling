clear; clc; close all;

addpath(genpath(pwd));

root_dir = 'real_world_networks';
out_dir = fullfile('results_realworld', 'csv');

if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

network_list = {
    'Euroroad',  fullfile(root_dir, 'subelj_euroroad', 'out.subelj_euroroad_euroroad');
    'Usgrid',    fullfile(root_dir, 'opsahl-powergrid', 'out.opsahl-powergrid');
    'Netscience',fullfile(root_dir, 'network.csv', 'edges.csv');
    'Yeast',     fullfile(root_dir, 'bio-yeast-protein-inter', 'bio-yeast-protein-inter.edges');
    'Facebook',  fullfile(root_dir, 'facebook', 'facebook_combined.txt');
};

results = cell(size(network_list,1), 7);

for i = 1:size(network_list,1)
    net_name = network_list{i,1};
    file_path = network_list{i,2};

    fprintf('\nProcessing %s ...\n', net_name);

    [A, A_lcc] = load_realworld_network(file_path, net_name);
    stats = compute_realworld_network_stats(A);

    results{i,1} = net_name;
    results{i,2} = stats.N;
    results{i,3} = stats.L;
    results{i,4} = stats.NLCC;
    results{i,5} = stats.LLCC;
    results{i,6} = stats.D;
    results{i,7} = stats.C;
end

T = cell2table(results, 'VariableNames', ...
    {'Name','N','L','NLCC','LLCC','D','C'});

disp(T);

writetable(T, fullfile(out_dir, 'realworld_network_stats.csv'));

fprintf('\nSaved to: %s\n', fullfile(out_dir, 'realworld_network_stats.csv'));