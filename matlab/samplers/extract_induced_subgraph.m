function As = extract_induced_subgraph(A, sampled_nodes)

sampled_nodes = sampled_nodes(:);
As = A(sampled_nodes, sampled_nodes);

end