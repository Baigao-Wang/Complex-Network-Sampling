function apl = compute_average_path_length_lcc(A)
% 计算图的最大连通子图上的平均最短路径长度
%
% 输入:
%   A - 无向无权邻接矩阵
%
% 输出:
%   apl - average path length on LCC

if isempty(A) || size(A,1) == 0
    apl = 0;
    return;
end

% 保证是0/1无向图
A = double(A > 0);
A = triu(A,1) + triu(A,1)';

G = graph(A);

% 找连通分量
bins = conncomp(G);

if isempty(bins)
    apl = 0;
    return;
end

comp_ids = unique(bins);
comp_sizes = zeros(numel(comp_ids), 1);

for i = 1:numel(comp_ids)
    comp_sizes(i) = sum(bins == comp_ids(i));
end

[~, idx_max] = max(comp_sizes);
largest_comp_id = comp_ids(idx_max);
lcc_nodes = find(bins == largest_comp_id);

% 如果LCC只有1个节点，平均路径长度定义为0
if numel(lcc_nodes) <= 1
    apl = 0;
    return;
end

A_lcc = A(lcc_nodes, lcc_nodes);
G_lcc = graph(A_lcc);

D = distances(G_lcc);

% 只取非对角线、有限值
mask = ~isinf(D) & ~eye(size(D));
vals = D(mask);

if isempty(vals)
    apl = 0;
else
    apl = mean(vals, 'omitnan');
end

end