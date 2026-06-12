function rho = compute_spearman_rankcorr(x, y)

x = x(:);
y = y(:);

if numel(x) ~= numel(y)
    error('Spearman inputs must have the same length.');
end

valid = isfinite(x) & isfinite(y);
x = x(valid);
y = y(valid);

if numel(x) < 2
    rho = NaN;
    return;
end

if numel(unique(x)) < 2 || numel(unique(y)) < 2
    rho = NaN;
    return;
end

rho = corr(x, y, 'Type', 'Spearman');

end