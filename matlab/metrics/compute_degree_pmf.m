function [k_vals, pmf] = compute_degree_pmf(A, k_support)

deg = sum(A, 2);
deg = deg(:);

if nargin < 2 || isempty(k_support)
    k_vals = (0:max(deg))';
else
    k_vals = k_support(:);
end

pmf = zeros(numel(k_vals), 1);

for i = 1:numel(k_vals)
    pmf(i) = sum(deg == k_vals(i));
end

pmf = pmf / numel(deg);

end