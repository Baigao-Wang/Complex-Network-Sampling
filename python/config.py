from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class ClassicalConfig:
    # 训练集规模
    num_sizes: int = 50
    base_size: int = 100

    er_p: float = 0.1
    ba_m: int = 3
    ws_k: int = 6
    ws_p: float = 0.1

    # 测试集
    num_test_set_2: int = 30
    num_test_set_3: int = 50


@dataclass
class FeatureConfig:
    # 路径长度：approx / exact
    apl_mode: str = "exact"

    # betweenness：approx / exact
    betweenness_mode: str = "exact"

    # 近似 average shortest path 时采样源点数
    apl_num_sources: int = 32

    # 近似 betweenness 时采样源点数
    betweenness_k: int = 32

@dataclass
class PSOConfig:
    # 比调试版略增强，但仍控制在中等规模
    num_particles: int = 24
    max_iter: int = 40

    c1: float = 1.5
    c2: float = 1.5
    w: float = 0.7

    cv_folds: int = 5
    min_features: int = 3
    max_features: int = 20


@dataclass
class SimilarityConfig:
    sample_methods: tuple = ("bfs", "rmsc")
    sample_ratios: tuple = (0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8)
    num_trials: int = 10

    norm_method: str = "zscore"      # zscore / minmax
    distance_type: str = "euclidean"


@dataclass
class AppConfig:
    seed: int = 42

    classical: ClassicalConfig = field(default_factory=ClassicalConfig)
    features: FeatureConfig = field(default_factory=FeatureConfig)
    pso: PSOConfig = field(default_factory=PSOConfig)
    similarity: SimilarityConfig = field(default_factory=SimilarityConfig)

    root_dir: Path = Path(".")
    realworld_root: Path = Path("real_world_networks")
    results_dir: Path = Path("results_graph_similarity_py")

    # 候选特征总维数
    total_feature_dim: int = 20

    # 当前真实网络最优 RMSC 参数
    rmsc_best: dict = field(default_factory=lambda: {
        "Euroroad":   {"num_seeds": 3,  "neighbor_select_prob": 0.80},
        "Usgrid":     {"num_seeds": 3,  "neighbor_select_prob": 0.70},
        "Netscience": {"num_seeds": 3,  "neighbor_select_prob": 0.45},
        "Yeast":      {"num_seeds": 10, "neighbor_select_prob": 0.40},
        "Facebook":   {"num_seeds": 7,  "neighbor_select_prob": 0.35},
    })

    def ensure_dirs(self):
        self.results_dir.mkdir(parents=True, exist_ok=True)
        (self.results_dir / "csv").mkdir(parents=True, exist_ok=True)
        (self.results_dir / "figures").mkdir(parents=True, exist_ok=True)


CFG = AppConfig()