function plot_realworld_all_networks_figures(all_results, cfg)

network_keys = fieldnames(all_results);

for i = 1:numel(network_keys)
    net_name = network_keys{i};
    plot_realworld_single_network_figure(all_results, cfg, net_name);
end

end