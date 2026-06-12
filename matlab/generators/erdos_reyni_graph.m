function A = erdos_reyni_graph(N, p)
% 生成无向无权 ER 随机图
%
% 输入:
%   N - 节点数
%   p - 任意两节点连边概率
%
% 输出:
%   A - N x N 对称邻接矩阵（double, 0/1）

if N <= 0
    error('N must be positive.');
end

if p < 0 || p > 1
    error('p must be in [0, 1].');
end

% 只生成上三角，再对称化
U = rand(N);
U = triu(U, 1);

A = double(U < p);
A = A + A.';
A = double(A > 0);

end