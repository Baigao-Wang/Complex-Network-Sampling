function bc = compute_betweenness_centrality(A, node_idx)

G = graph(A);
all_bc = centrality(G, 'betweenness');

if nargin < 2 || isempty(node_idx)
    bc = all_bc(:);
else
    bc = all_bc(node_idx);
    bc = bc(:);
end

end