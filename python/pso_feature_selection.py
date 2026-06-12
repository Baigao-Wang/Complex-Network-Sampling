import numpy as np
import pyswarms as ps
from svm_eval import evaluate_feature_subset_svm


def run_pso_feature_selection(X: np.ndarray, y: np.ndarray, cfg):
    dim = X.shape[1]
    cache = {}

    def objective(particles: np.ndarray):
        costs = []
        for p in particles:
            mask = (p > 0.5).astype(int)
            num_feat = int(mask.sum())

            key = tuple(mask.tolist())
            if key in cache:
                costs.append(cache[key])
                continue

            if num_feat < cfg.pso.min_features or num_feat > cfg.pso.max_features:
                cost = 1.0
            else:
                acc = evaluate_feature_subset_svm(mask.astype(float), X, y, cv_folds=cfg.pso.cv_folds)
                cost = 1.0 - acc

            cache[key] = cost
            costs.append(cost)

        return np.array(costs)

    options = {"c1": cfg.pso.c1, "c2": cfg.pso.c2, "w": cfg.pso.w}
    optimizer = ps.single.GlobalBestPSO(
        n_particles=cfg.pso.num_particles,
        dimensions=dim,
        options=options,
        bounds=(np.zeros(dim), np.ones(dim)),
    )

    best_cost, best_pos = optimizer.optimize(objective, iters=cfg.pso.max_iter, verbose=True)
    best_mask = (best_pos > 0.5).astype(int)
    best_idx = np.where(best_mask > 0)[0]

    return {
        "best_cost": float(best_cost),
        "best_fitness": float(1.0 - best_cost),
        "best_mask": best_mask,
        "best_idx": best_idx,
        "cost_history": optimizer.cost_history,
    }