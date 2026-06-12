function sampled_nodes = sample_bfs(A, sample_ratio, start_node)
% 从随机起点或指定起点做 BFS，直到达到目标采样节点数

N = size(A, 1);
target_num = max(1, round(sample_ratio * N));

if nargin < 3 || isempty(start_node)
    start_node = randi(N);
end

visited = false(N, 1);
queue = start_node;
visited(start_node) = true;

order = zeros(N, 1);
count = 1;
order(count) = start_node;

head = 1;

while head <= numel(queue) && count < target_num
    u = queue(head);
    head = head + 1;

    neighbors = find(A(u, :) > 0);
    neighbors = neighbors(randperm(numel(neighbors))); % 打乱，避免固定顺序偏置

    for v = neighbors
        if ~visited(v)
            visited(v) = true;
            queue(end+1) = v; %#ok<AGROW>
            count = count + 1;
            order(count) = v;

            if count >= target_num
                break;
            end
        end
    end
end

% 如果图不连通，BFS 不足目标数量，则随机补齐
if count < target_num
    remaining = find(~visited);
    need = target_num - count;
    extra = remaining(randperm(numel(remaining), min(need, numel(remaining))));
    order(count+1:count+numel(extra)) = extra;
    count = count + numel(extra);
end

sampled_nodes = sort(order(1:count));

end