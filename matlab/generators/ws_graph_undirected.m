function A = ws_graph_undirected(N, k, p)
% 生成无向无权 WS 小世界网络（Watts-Strogatz）
%
% 输入:
%   N - 节点数
%   k - 每个节点初始连接的最近邻个数（必须为偶数）
%   p - 重连概率
%
% 输出:
%   A - N x N 对称邻接矩阵（double, 0/1）

if N <= 2
    error('N must be greater than 2.');
end

if mod(k, 2) ~= 0
    error('k must be even.');
end

if k < 2 || k >= N
    error('k must satisfy 2 <= k < N.');
end

if p < 0 || p > 1
    error('p must be in [0, 1].');
end

A = zeros(N, N);
half_k = k / 2;

% -------- Step 1: 构造环形规则网络 --------
for i = 1:N
    for d = 1:half_k
        j = mod(i - 1 + d, N) + 1;
        A(i, j) = 1;
        A(j, i) = 1;
    end
end

% -------- Step 2: 对“右侧边”做重连 --------
for i = 1:N
    for d = 1:half_k
        j = mod(i - 1 + d, N) + 1;

        % 只处理一个方向，避免重复
        if i < j || (i > j && (i + d > N))
            if rand() < p
                % 删除旧边
                A(i, j) = 0;
                A(j, i) = 0;

                % 候选新节点：不能是自己，不能已有边
                candidates = find((1:N)' ~= i & A(i, :)' == 0);

                if isempty(candidates)
                    % 极端保护：恢复原边
                    A(i, j) = 1;
                    A(j, i) = 1;
                else
                    new_j = candidates(randi(numel(candidates)));
                    A(i, new_j) = 1;
                    A(new_j, i) = 1;
                end
            end
        end
    end
end

A = double(A > 0);

end