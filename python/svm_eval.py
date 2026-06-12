import numpy as np
from sklearn.svm import SVC
from sklearn.model_selection import StratifiedKFold, cross_val_score


def evaluate_feature_subset_svm(mask: np.ndarray, X: np.ndarray, y: np.ndarray, cv_folds: int = 5) -> float:
    idx = np.where(mask > 0.5)[0]
    if idx.size == 0:
        return 0.0

    Xs = X[:, idx]
    clf = SVC(kernel="rbf", gamma="scale", C=1.0)

    cv = StratifiedKFold(n_splits=cv_folds, shuffle=True, random_state=42)
    scores = cross_val_score(clf, Xs, y, cv=cv, scoring="accuracy", n_jobs=1)
    return float(scores.mean())