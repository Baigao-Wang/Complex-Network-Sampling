function [A, A_lcc] = load_realworld_network(file_path, network_name)
% 更贴近原论文 / 源代码风格的真实网络读取函数
%
% 输出:
%   A      - 全图无向无权邻接矩阵
%   A_lcc  - 最大连通子图邻接矩阵
%
% 设计原则:
%   1. 尽量贴近 Python 源代码“先读边、再建图、再取 LCC”的流程
%   2. 不在取 LCC 前做人为连续重编号
%   3. 仅做 MATLAB 必要的索引适配（如 0-based -> 1-based）
%   4. 不主动做复杂清洗，只保留最基本的无向图构造

    switch lower(network_name)
        case 'euroroad'
            edges = read_space_edgelist(file_path, '%');

        case 'usgrid'
            edges = read_space_edgelist(file_path, '%');

        case 'netscience'
            edges = read_netscience_csv(file_path);

        case 'yeast'
            edges = read_space_edgelist(file_path, '%');

        case 'facebook'
            edges = read_space_edgelist(file_path, '%');

        otherwise
            error('Unknown network name: %s', network_name);
    end

    if isempty(edges)
        error('No valid edges loaded from file: %s', file_path);
    end

    % ---- 只做 MATLAB 必要的索引适配 ----
    % 若节点编号包含 0，则整体 +1，使其可作为 MATLAB 索引
    min_id = min(edges(:));
    if min_id == 0
        edges = edges + 1;
    end

    % ---- 去除非法编号 ----
    edges = edges(all(isfinite(edges), 2), :);
    edges = edges(edges(:,1) > 0 & edges(:,2) > 0, :);

    % ---- 去自环 ----
    % Python 源代码没有显式去自环，但大多数这类网络中自环并不关键；
    % 这里保留去自环，避免影响邻接矩阵和后续统计。
    edges = edges(edges(:,1) ~= edges(:,2), :);

    if isempty(edges)
        error('All edges were removed after preprocessing: %s', file_path);
    end

    % ---- 构造全图 ----
    % 不做人为连续重编号，尽量保留原始编号结构
    n = max(edges(:));

    A = sparse(edges(:,1), edges(:,2), 1, n, n);
    A = A + A.';          % 无向图
    A = double(A > 0);    % 合并重复边

    % ---- 提取最大连通子图 ----
    G = graph(A);
    bins = conncomp(G);

    comp_ids = unique(bins);
    comp_sizes = zeros(numel(comp_ids), 1);
    for i = 1:numel(comp_ids)
        comp_sizes(i) = sum(bins == comp_ids(i));
    end

    [~, idx_max] = max(comp_sizes);
    largest_comp_id = comp_ids(idx_max);
    lcc_nodes = find(bins == largest_comp_id);

    A_lcc = A(lcc_nodes, lcc_nodes);

end