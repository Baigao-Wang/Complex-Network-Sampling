function result = pso_feature_selection(classical_data, cfg)

X = classical_data.X;
y = classical_data.y;

D = size(X, 2);
P = cfg.pso.num_particles;
T = cfg.pso.max_iter;

pop = rand(P, D) > 0.5;   % 二进制特征选择
vel = zeros(P, D);

pbest = pop;
pbest_fit = -inf(P, 1);

gbest = pop(1, :);
gbest_fit = -inf;

history = zeros(T, 1);

for i = 1:P
    fit = evaluate_feature_subset_svm(pop(i, :), X, y, cfg);
    pbest_fit(i) = fit;
    if fit > gbest_fit
        gbest_fit = fit;
        gbest = pop(i, :);
    end
end

for iter = 1:T
    for i = 1:P
        r1 = rand(1, D);
        r2 = rand(1, D);

        vel(i, :) = cfg.pso.w * vel(i, :) ...
            + cfg.pso.c1 * r1 .* (double(pbest(i, :)) - double(pop(i, :))) ...
            + cfg.pso.c2 * r2 .* (double(gbest) - double(pop(i, :)));

        prob = 1 ./ (1 + exp(-vel(i, :)));
        pop(i, :) = rand(1, D) < prob;

        % 约束特征数量
        idx = find(pop(i, :) > 0);
        if numel(idx) < cfg.pso.min_features
            order = randperm(D, cfg.pso.min_features);
            pop(i, :) = false(1, D);
            pop(i, order) = true;
        elseif numel(idx) > cfg.pso.max_features
            keep = idx(randperm(numel(idx), cfg.pso.max_features));
            pop(i, :) = false(1, D);
            pop(i, keep) = true;
        end

        fit = evaluate_feature_subset_svm(pop(i, :), X, y, cfg);

        if fit > pbest_fit(i)
            pbest(i, :) = pop(i, :);
            pbest_fit(i) = fit;
        end

        if fit > gbest_fit
            gbest_fit = fit;
            gbest = pop(i, :);
        end
    end

    history(iter) = gbest_fit;
    fprintf('PSO iter %d/%d, best fitness = %.4f, selected = %d\n', ...
        iter, T, gbest_fit, nnz(gbest));
end

result.best_mask = gbest;
result.best_idx = find(gbest);
result.best_fitness = gbest_fit;
result.history = history;
end