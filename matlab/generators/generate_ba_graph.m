function A = generate_ba_graph(N, m0, m)
% 生成无向无权 BA 图邻接矩阵
% 简化版 preferential attachment

if m0 < 2 || m < 1 || m > m0 || N <= m0
    error('Invalid BA parameters.');
end

A = zeros(N, N);

% 初始完全图
A(1:m0, 1:m0) = 1;
A(1:m0, 1:m0) = A(1:m0, 1:m0) - eye(m0);

deg = sum(A, 2);

for new_node = (m0 + 1):N
    probs = deg(1:new_node-1);
    probs = probs / sum(probs);

    targets = zeros(1, m);
    chosen = false(1, new_node-1);

    count = 0;
    while count < m
        idx = randsample(new_node-1, 1, true, probs);
        if ~chosen(idx)
            count = count + 1;
            targets(count) = idx;
            chosen(idx) = true;
        end
    end

    A(new_node, targets) = 1;
    A(targets, new_node) = 1;

    deg = sum(A, 2);
end

A = double(A > 0);

end