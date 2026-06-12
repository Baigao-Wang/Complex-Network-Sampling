function fit = evaluate_feature_subset_svm(mask, X, y, cfg)

idx = find(mask);
if isempty(idx)
    fit = 0;
    return;
end

Xs = X(:, idx);

cv = cvpartition(y, 'KFold', cfg.pso.cv_folds);
acc = zeros(cfg.pso.cv_folds, 1);

for k = 1:cfg.pso.cv_folds
    tr = training(cv, k);
    te = test(cv, k);

    mdl = fitcecoc(Xs(tr, :), y(tr));
    pred = predict(mdl, Xs(te, :));

    acc(k) = mean(pred == y(te));
end

fit = mean(acc);
end