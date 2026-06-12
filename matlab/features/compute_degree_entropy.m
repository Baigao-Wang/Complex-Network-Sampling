function H = compute_degree_entropy(deg)

deg = deg(:);

if isempty(deg)
    H = 0;
    return;
end

k_vals = unique(deg);
p = zeros(numel(k_vals), 1);

for i = 1:numel(k_vals)
    p(i) = sum(deg == k_vals(i)) / numel(deg);
end

p = p(p > 0);

if isempty(p)
    H = 0;
else
    H = -sum(p .* log2(p));
end

end