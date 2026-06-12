function s = safe_feature_stats(x)
% 对输入向量返回 [mean, std, skewness, kurtosis]
% 并对常数向量 / 空向量 / NaN 做安全处理

x = x(:);

if isempty(x)
    s = [0, 0, 0, 0];
    return;
end

m = mean(x, 'omitnan');
sd = std(x, 'omitnan');

if isnan(m),  m = 0; end
if isnan(sd), sd = 0; end

if numel(unique(x(~isnan(x)))) <= 1
    sk = 0;
    ku = 0;
else
    sk = skewness(x, 0, 'omitnan');
    ku = kurtosis(x, 0, 'omitnan');

    if isnan(sk), sk = 0; end
    if isnan(ku), ku = 0; end
end

s = [m, sd, sk, ku];

end