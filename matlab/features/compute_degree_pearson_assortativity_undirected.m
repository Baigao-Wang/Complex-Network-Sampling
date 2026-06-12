function r = compute_degree_pearson_assortativity_undirected(A)
% 计算无向无权图的 degree assortativity（Pearson相关系数）
%
% 输入:
%   A - 邻接矩阵（无向无权）
%
% 输出:
%   r - 度相关系数

if isempty(A) || size(A,1) == 0
    r = 0;
    return;
end

A = double(A > 0);
A = triu(A,1) + triu(A,1)';

deg = sum(A, 2);

[i, j] = find(triu(A, 1));

if isempty(i)
    r = 0;
    return;
end

x = deg(i);
y = deg(j);

% 如果边两端度没有变化，Pearson 无法正常算，直接记为0
if numel(unique(x)) <= 1 && numel(unique(y)) <= 1
    r = 0;
    return;
end

C = corrcoef(x, y);

if numel(C) < 4 || isnan(C(1,2))
    r = 0;
else
    r = C(1,2);
end

end