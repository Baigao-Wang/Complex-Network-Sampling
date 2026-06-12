function sampled_nodes = sample_rmsc(A, sample_ratio, params)
% Multi-seed probabilistic crawling with fixed sample size

N = size(A, 1);
targetSize = max(1, round(N * sample_ratio));
targetSize = min(targetSize, N);

Pc = params.neighbor_select_prob;
numSeeds = min(params.num_seeds, targetSize);

sampledMask = false(N, 1);

seedNodes = randperm(N, numSeeds);
sampledMask(seedNodes) = true;
frontier = seedNodes(:)';

while sum(sampledMask) < targetSize

    newFrontier = [];

    for u = frontier
        neighbors = find(A(u, :) > 0);
        neighbors = neighbors(~sampledMask(neighbors));

        if isempty(neighbors)
            continue;
        end

        neighbors = neighbors(randperm(numel(neighbors)));

        for v = neighbors
            if sum(sampledMask) >= targetSize
                break;
            end

            if rand < Pc
                sampledMask(v) = true;
                newFrontier(end+1) = v; %#ok<AGROW>
            end
        end
    end

    % 如果本轮没有扩展出新节点，重新从未采样节点中补一个种子
    if isempty(newFrontier)
        remaining = find(~sampledMask);

        if isempty(remaining)
            break;
        end

        newSeed = remaining(randi(numel(remaining)));
        sampledMask(newSeed) = true;
        newFrontier = newSeed;
    end

    frontier = unique(newFrontier, 'stable');
end

sampled_nodes = find(sampledMask);
sampled_nodes = sampled_nodes(:);

end