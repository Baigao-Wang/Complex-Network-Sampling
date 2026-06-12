function dc = compute_degree_centrality(A, node_idx)

N = size(A, 1);
deg = sum(A, 2) / max(N - 1, 1);

if nargin < 2 || isempty(node_idx)
    dc = deg(:);
else
    dc = deg(node_idx);
    dc = dc(:);
end

end