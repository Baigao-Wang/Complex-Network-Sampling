import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from joblib import Parallel, delayed
from sklearn.preprocessing import StandardScaler, MinMaxScaler

from feature_extraction import extract_candidate_features
from realworld_loader import load_realworld_network
from sampling_methods import bfs_sampling_fixed_size, rmsc_sampling_fixed_size, induced_subgraph_by_nodes


def normalize_features(X: np.ndarray, method: str):
    if method == "zscore":
        scaler = StandardScaler()
    elif method == "minmax":
        scaler = MinMaxScaler()
    else:
        raise ValueError(method)
    return scaler.fit_transform(X), scaler


def compute_distance(f1: np.ndarray, f2: np.ndarray, distance_type: str = "euclidean") -> float:
    if distance_type == "euclidean":
        return float(np.linalg.norm(f1 - f2, ord=2))
    elif distance_type == "manhattan":
        return float(np.linalg.norm(f1 - f2, ord=1))
    elif distance_type == "cosine":
        n1 = np.linalg.norm(f1)
        n2 = np.linalg.norm(f2)
        if n1 == 0 or n2 == 0:
            return 1.0
        return float(1 - np.dot(f1, f2) / (n1 * n2))
    else:
        raise ValueError(distance_type)


def _one_similarity_trial(G, net_name, method, ratio, trial_id, cfg):
    if method == "bfs":
        sampled_nodes = bfs_sampling_fixed_size(G, ratio)
    elif method == "rmsc":
        params = cfg.rmsc_best[net_name]
        sampled_nodes = rmsc_sampling_fixed_size(
            G,
            num_seeds=params["num_seeds"],
            pc=params["neighbor_select_prob"],
            target_ratio=ratio,
        )
    else:
        raise ValueError(method)

    Gs = induced_subgraph_by_nodes(G, sampled_nodes)
    feat_sample = extract_candidate_features(Gs, cfg)

    return {
        "network": net_name,
        "method": method,
        "ratio": ratio,
        "trial_id": trial_id,
        "actual_ratio": len(sampled_nodes) / G.number_of_nodes(),
        "sampled_num": len(sampled_nodes),
        "feat_sample_raw": feat_sample,
    }


def run_realworld_similarity(cfg, selected_feature_idx):
    raw_feature_bank = []
    cache = {}

    network_specs = [
        ("Euroroad",   str(cfg.realworld_root / "subelj_euroroad" / "out.subelj_euroroad_euroroad")),
        ("Usgrid",     str(cfg.realworld_root / "opsahl-powergrid" / "out.opsahl-powergrid")),
        ("Netscience", str(cfg.realworld_root / "network.csv" / "edges.csv")),
        ("Yeast",      str(cfg.realworld_root / "bio-yeast-protein-inter" / "bio-yeast-protein-inter.edges")),
        ("Facebook",   str(cfg.realworld_root / "facebook" / "facebook_combined.txt")),
    ]

    # 先加载原图和原图特征
    for net_name, file_path in network_specs:
        G_full, G = load_realworld_network(file_path, net_name)
        cache[net_name] = (G_full, G)
        feat_full = extract_candidate_features(G, cfg)
        raw_feature_bank.append(feat_full)

    # 并行 trial
    tasks = []
    for net_name, _ in network_specs:
        _, G = cache[net_name]
        for method in cfg.similarity.sample_methods:
            for ratio in cfg.similarity.sample_ratios:
                for trial_id in range(cfg.similarity.num_trials):
                    tasks.append((G, net_name, method, ratio, trial_id, cfg))

    results = Parallel(n_jobs=-1, verbose=10)(
        delayed(_one_similarity_trial)(*task) for task in tasks
    )

    # 所有 sample 特征加入 bank
    for rec in results:
        raw_feature_bank.append(rec["feat_sample_raw"])

    X = np.vstack(raw_feature_bank)
    X_norm, _ = normalize_features(X, cfg.similarity.norm_method)

    # 前 len(network_specs) 行是 full graph
    full_feat_norm = {}
    for i, (net_name, _) in enumerate(network_specs):
        full_feat_norm[net_name] = X_norm[i, :]

    # 后面是 trials
    offset = len(network_specs)
    for idx, rec in enumerate(results):
        rec["feat_sample_norm"] = X_norm[offset + idx, :]
        f1 = full_feat_norm[rec["network"]][selected_feature_idx]
        f2 = rec["feat_sample_norm"][selected_feature_idx]
        rec["distance"] = compute_distance(f1, f2, cfg.similarity.distance_type)

        # 这两列如果后面要导出原始特征，可保留；否则可删
        del rec["feat_sample_raw"]
        del rec["feat_sample_norm"]

    return pd.DataFrame(results)


def export_similarity_csv(df: pd.DataFrame, out_dir):
    out_dir.mkdir(parents=True, exist_ok=True)

    # trial 明细
    df.to_csv(out_dir / "graph_similarity_trials.csv", index=False)

    # 汇总
    summary = (
        df.groupby(["network", "method", "ratio"], as_index=False)
        .agg(
            distance_mean=("distance", "mean"),
            distance_std=("distance", "std"),
            actual_ratio_mean=("actual_ratio", "mean"),
            actual_ratio_std=("actual_ratio", "std"),
            sampled_num_mean=("sampled_num", "mean"),
        )
    )
    summary.to_csv(out_dir / "graph_similarity_summary.csv", index=False)
    return summary


def plot_realworld_similarity_bar(summary: pd.DataFrame, out_dir):
    out_dir.mkdir(parents=True, exist_ok=True)
    networks = ["Euroroad", "Usgrid", "Netscience", "Yeast", "Facebook"]

    for method in ["bfs", "rmsc"]:
        sub = summary[summary["method"] == method].copy()

        pivot = sub.pivot(index="ratio", columns="network", values="distance_mean")
        pivot = pivot.reindex(columns=networks)

        ax = pivot.plot(kind="bar", figsize=(11, 6))
        ax.set_xlabel("Sampling Ratio")
        ax.set_ylabel("Similarity Distance")
        ax.set_title(f"Sampling results of five real-world networks using {method.upper()} method")
        ax.grid(True, axis="y")
        plt.tight_layout()
        plt.savefig(out_dir / f"realworld_similarity_{method}.png", dpi=300)
        plt.close()