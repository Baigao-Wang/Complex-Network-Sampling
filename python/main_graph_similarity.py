import json
import numpy as np
from joblib import Parallel, delayed
from sklearn.preprocessing import StandardScaler, MinMaxScaler

from config import CFG
from utils import set_seed
from graph_generators import erdos_reyni_graph, ba_graph_undirected, ws_graph_undirected
from feature_extraction import extract_candidate_features
from pso_feature_selection import run_pso_feature_selection
from realworld_similarity import run_realworld_similarity, export_similarity_csv, plot_realworld_similarity_bar
from test_set_evaluation import evaluate_selected_features_on_testsets


def _build_one_graph_feature(model_name, n, cfg):
    if model_name == "ER":
        G = erdos_reyni_graph(n, cfg.classical.er_p)
        y = 1
    elif model_name == "BA":
        G = ba_graph_undirected(n, cfg.classical.ba_m)
        y = 2
    elif model_name == "WS":
        G = ws_graph_undirected(n, cfg.classical.ws_k, cfg.classical.ws_p)
        y = 3
    else:
        raise ValueError(model_name)

    feat = extract_candidate_features(G, cfg)
    return feat, y


def build_classical_dataset(cfg):
    tasks = []

    for i in range(1, cfg.classical.num_sizes + 1):
        n = cfg.classical.base_size * i
        tasks.append(("ER", n))
        tasks.append(("BA", n))
        tasks.append(("WS", n))

    results = Parallel(n_jobs=-1, verbose=10)(
        delayed(_build_one_graph_feature)(model_name, n, cfg)
        for model_name, n in tasks
    )

    X_raw = np.asarray([r[0] for r in results], dtype=float)
    y = np.asarray([r[1] for r in results], dtype=int)

    if cfg.similarity.norm_method == "zscore":
        scaler = StandardScaler()
        X = scaler.fit_transform(X_raw)
    elif cfg.similarity.norm_method == "minmax":
        scaler = MinMaxScaler()
        X = scaler.fit_transform(X_raw)
    else:
        raise ValueError(cfg.similarity.norm_method)

    return X, y, X_raw


def main():
    cfg = CFG
    cfg.ensure_dirs()
    set_seed(cfg.seed)

    print("[1/3] Building classical network dataset...")
    X, y, X_train_raw = build_classical_dataset(cfg)

    print("[2/3] Running PSO feature selection...")
    pso_result = run_pso_feature_selection(X, y, cfg)

    selected_idx = pso_result["best_idx"].tolist()

    print("[2.5/3] Evaluating selected features on Test Set I / II / III...")
    test_results = evaluate_selected_features_on_testsets(
        cfg,
        np.array(selected_idx, dtype=int),
        X_train_raw,
        y
    )

    with open(cfg.results_dir / "pso_result.json", "w", encoding="utf-8") as f:
        json.dump(
            {
                "best_fitness": pso_result["best_fitness"],
                "best_idx": selected_idx,
                "test_accuracy": test_results,
            },
            f,
            ensure_ascii=False,
            indent=2,
        )

    print("Classification accuracy results:")
    for k, v in test_results.items():
        print(f"{k}: {v:.4f}")

    print("[3/3] Running real-world graph similarity...")
    df = run_realworld_similarity(cfg, np.array(selected_idx, dtype=int))
    summary = export_similarity_csv(df, cfg.results_dir / "csv")
    plot_realworld_similarity_bar(summary, cfg.results_dir / "figures")

    print("Done.")


if __name__ == "__main__":
    main()