function A_lcc = largest_connected_component(A)

G = graph(A);
bins = conncomp(G);

num_comp = max(bins);
sizes = zeros(num_comp, 1);

for i = 1:num_comp
    sizes(i) = sum(bins == i);
end

[~, idx] = max(sizes);
nodes = find(bins == idx);

A_lcc = A(nodes, nodes);

end