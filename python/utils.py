import random
import numpy as np


def set_seed(seed: int):
    random.seed(seed)
    np.random.seed(seed)


def safe_stats(x: np.ndarray):
    x = np.asarray(x, dtype=float).reshape(-1)
    if x.size == 0:
        return [0.0, 0.0, 0.0, 0.0]

    mean = float(np.nanmean(x))
    std = float(np.nanstd(x))

    valid = x[~np.isnan(x)]
    if valid.size <= 1 or np.unique(valid).size <= 1:
        skew = 0.0
        kurt = 0.0
    else:
        from scipy.stats import skew as sp_skew, kurtosis as sp_kurtosis
        skew = float(np.nan_to_num(sp_skew(valid, bias=False), nan=0.0))
        kurt = float(np.nan_to_num(sp_kurtosis(valid, bias=False, fisher=False), nan=0.0))

    return [mean, std, skew, kurt]