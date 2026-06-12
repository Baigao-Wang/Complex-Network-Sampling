function X_norm = normalize_feature_matrix(X, method)
% X: n_samples x n_features

if nargin < 2 || isempty(method)
    method = 'zscore';
end

switch lower(method)
    case 'zscore'
        mu = mean(X, 1, 'omitnan');
        sigma = std(X, 0, 1, 'omitnan');
        sigma(sigma == 0) = 1;
        X_norm = (X - mu) ./ sigma;

    case 'minmax'
        xmin = min(X, [], 1);
        xmax = max(X, [], 1);
        span = xmax - xmin;
        span(span == 0) = 1;
        X_norm = (X - xmin) ./ span;

    otherwise
        error('Unknown normalization method: %s', method);
end

end