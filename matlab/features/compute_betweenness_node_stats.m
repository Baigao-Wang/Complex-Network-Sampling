function val = compute_betweenness_node_stats(A)
% 计算节点 betweenness centrality 的均值
%
% 输入:
%   A - 邻接矩阵（无向无权）
%
% 输出:
%   val - 节点 betweenness centrality 的均值

if isempty(A) || size(A,1) == 0
    val = 0;
    return;
end

A = double(A > 0);
A = triu(A,1) + triu(A,1)';

G = graph(A);

if numnodes(G) <= 1 || numedges(G) == 0
    val = 0;
    return;
end

bc = centrality(G, 'betweenness');

if isempty(bc)
    val = 0;
else
    val = mean(bc, 'omitnan');
    if isnan(val)
        val = 0;
    end
end

end