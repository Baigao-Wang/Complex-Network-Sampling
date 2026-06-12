function cc = compute_closeness_centrality(A, node_idx)

G = graph(A);
N = numnodes(G);

if nargin < 2 || isempty(node_idx)
    sources = 1:N;
else
    sources = node_idx(:)';
end

D = distances(G, sources);
cc = zeros(numel(sources), 1);

for i = 1:numel(sources)
    di = D(i, :);
    valid = isfinite(di) & di > 0;

    if any(valid)
        cc(i) = sum(1 ./ di(valid)) / max(N - 1, 1);
    else
        cc(i) = 0;
    end
end

cc = cc(:);

end