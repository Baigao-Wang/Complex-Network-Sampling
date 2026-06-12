function ks = compute_ks_distance(x, y)

x = x(:);
y = y(:);

x = sort(x);
y = sort(y);

vals = unique([x; y]);
Fx = zeros(size(vals));
Fy = zeros(size(vals));

for i = 1:numel(vals)
    Fx(i) = sum(x <= vals(i)) / numel(x);
    Fy(i) = sum(y <= vals(i)) / numel(y);
end

ks = max(abs(Fx - Fy));

end