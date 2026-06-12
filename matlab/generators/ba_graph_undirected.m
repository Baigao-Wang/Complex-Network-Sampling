function A = ba_graph_undirected(N, m)
% 生成无向无权 BA 图（Barabási-Albert preferential attachment）
%
% 输入:
%   N - 节点总数
%   m - 每个新节点连到 m 个已有节点
%
% 输出:
%   A - N x N 对称邻接矩阵（double, 0/1）

if N <= 1
    error('N must be greater than 1.');
end

if m < 1 || m >= N
    error('m must satisfy 1 <= m < N.');
end

% 常见做法：初始完全图大小取 m+1
m0 = m + 1;

A = zeros(N, N);

% 初始完全图
A(1:m0, 1:m0) = 1;
A(1:m0, 1:m0) = A(1:m0, 1:m0) - eye(m0);

% 逐个加入新节点
for new_node = (m0 + 1):N
    deg = sum(A(1:new_node-1, 1:new_node-1), 2);
    deg_sum = sum(deg);

    if deg_sum == 0
        % 极端保护：若度和为0，则均匀随机选
        probs = ones(new_node - 1, 1) / (new_node - 1);
    else
        probs = deg / deg_sum;
    end

    % 按概率无放回选 m 个节点
    targets = weighted_sample_without_replacement(probs, m);

    A(new_node, targets) = 1;
    A(targets, new_node) = 1;
end

A = double(A > 0);

end


function idx = weighted_sample_without_replacement(probs, k)
% 按权重无放回采样 k 个索引
n = numel(probs);

if k > n
    error('k cannot be larger than number of candidates.');
end

idx = zeros(1, k);
available = true(n, 1);
p = probs(:);

for t = 1:k
    p_now = p;
    p_now(~available) = 0;

    s = sum(p_now);
    if s <= 0
        candidates = find(available);
        chosen = candidates(randi(numel(candidates)));
    else
        p_now = p_now / s;
        cdf = cumsum(p_now);
        r = rand();
        chosen = find(cdf >= r, 1, 'first');
    end

    idx(t) = chosen;
    available(chosen) = false;
end

end