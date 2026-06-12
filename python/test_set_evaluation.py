import numpy as np
from joblib import Parallel, delayed
from sklearn.svm import SVC
from sklearn.model_selection import cross_val_score, StratifiedKFold
from sklearn.preprocessing import StandardScaler, MinMaxScaler

from graph_generators import erdos_reyni_graph, ba_graph_undirected, ws_graph_undirected
from feature_extraction import extract_candidate_features


def normalize_features(X: np.ndarray, method: str):
    if method == "zscore":
        scaler = StandardScaler()
    elif method == "minmax":
        scaler = MinMaxScaler()
    else:
        raise ValueError(method)
    return scaler.fit_transform(X), scaler


def _build_one_graph_feature(model_name: str, n: int, cfg):
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


def build_one_classical_dataset_parallel(cfg, num_sizes: int):
    tasks = []

    for i in range(1, num_sizes + 1):
        n = cfg.classical.base_size * i
        tasks.append(("ER", n))
        tasks.append(("BA", n))
        tasks.append(("WS", n))

    results = Parallel(n_jobs=-1, verbose=10)(
        delayed(_build_one_graph_feature)(model_name, n, cfg)
        for model_name, n in tasks
    )

    X = np.asarray([r[0] for r in results], dtype=float)
    y = np.asarray([r[1] for r in results], dtype=int)

    return X, y


def evaluate_selected_features_on_testsets(cfg, selected_idx, X_train_raw, y_train):
    """
    Test Set I 直接复用主程序已经生成的训练特征，避免重复生成。
    Test Set II / III 重新生成，用于泛化测试。
    """

    # ---------- Test Set I ----------
    X1 = X_train_raw
    y1 = y_train

    # ---------- Test Set II ----------
    print("  Building Test Set II...")
    X2, y2 = build_one_classical_dataset_parallel(
        cfg, cfg.classical.num_test_set_2
    )

    # ---------- Test Set III ----------
    print("  Building Test Set III...")
    X3, y3 = build_one_classical_dataset_parallel(
        cfg, cfg.classical.num_test_set_3
    )

    # 统一用 Test Set I 拟合 scaler，再变换 II / III
    X1_norm, scaler = normalize_features(X1, cfg.similarity.norm_method)
    X2_norm = scaler.transform(X2)
    X3_norm = scaler.transform(X3)

    X1_sel = X1_norm[:, selected_idx]
    X2_sel = X2_norm[:, selected_idx]
    X3_sel = X3_norm[:, selected_idx]

    clf = SVC(kernel="rbf", gamma="scale", C=1.0)

    # Test Set I：交叉验证准确率
    cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
    acc1 = float(
        cross_val_score(
            clf,
            X1_sel,
            y1,
            cv=cv,
            scoring="accuracy",
            n_jobs=-1
        ).mean()
    )

    # 用 Test Set I 训练，再在 II / III 测试
    clf.fit(X1_sel, y1)

    pred2 = clf.predict(X2_sel)
    pred3 = clf.predict(X3_sel)

    acc2 = float((pred2 == y2).mean())
    acc3 = float((pred3 == y3).mean())

    avg_acc = (acc1 + acc2 + acc3) / 3.0

    return {
        "Test Set I": acc1,
        "Test Set II": acc2,
        "Test Set III": acc3,
        "Average": avg_acc,
    }