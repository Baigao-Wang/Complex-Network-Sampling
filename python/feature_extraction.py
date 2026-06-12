import math
import random
import numpy as np
import networkx as nx
from collections import Counter
from utils import safe_stats


def average_neighbor_degree_per_node(G: nx.Graph) -> np.ndarray:
    """
    计算每个节点邻居平均度
    """
    deg = dict(G.degree())
    nodes = list(G.nodes())
    node_to_idx = {u: i for i, u in enumerate(nodes)}
    out = np.zeros(len(nodes), dtype=float)

    for u in nodes:
        nbrs = list(G.adj[u])
        i = node_to_idx[u]
        if nbrs:
            out[i] = np.mean([deg[v] for v in nbrs])
        else:
            out[i] = 0.0
    return out


def egonet_edge_count_per_node(G: nx.Graph) -> np.ndarray:
    """
    计算每个节点 egonet 中的边数
    """
    nodes = list(G.nodes())
    node_to_idx = {u: i for i, u in enumerate(nodes)}
    out = np.zeros(len(nodes), dtype=float)

    for u in nodes:
        ego_nodes = set(G.neighbors(u))
        ego_nodes.add(u)
        H = G.subgraph(ego_nodes)
        out[node_to_idx[u]] = H.number_of_edges()
    return out


def degree_entropy(G: nx.Graph) -> float:
    """
    度分布熵
    """
    deg = [d for _, d in G.degree()]
    if not deg:
        return 0.0

    cnt = Counter(deg)
    total = len(deg)
    probs = np.array([c / total for c in cnt.values()], dtype=float)
    probs = probs[probs > 0]

    return float(-(probs * np.log2(probs)).sum()) if probs.size > 0 else 0.0


def largest_connected_component_graph(G: nx.Graph) -> nx.Graph:
    """
    返回最大连通子图
    """
    if G.number_of_nodes() == 0:
        return G.copy()

    if nx.is_connected(G):
        return G

    largest_cc = max(nx.connected_components(G), key=len)
    return G.subgraph(largest_cc).copy()


def average_path_length_lcc_exact(G: nx.Graph) -> float:
    """
    精确计算 LCC 上的 average shortest path length
    """
    H = largest_connected_component_graph(G)

    if H.number_of_nodes() <= 1:
        return 0.0

    try:
        return float(nx.average_shortest_path_length(H))
    except Exception:
        return 0.0


def average_path_length_lcc_approx(G: nx.Graph, num_sources: int = 32) -> float:
    """
    用少量源点近似 average shortest path length
    """
    H = largest_connected_component_graph(G)

    n = H.number_of_nodes()
    if n <= 1:
        return 0.0

    nodes = list(H.nodes())
    k = min(num_sources, n)
    sources = random.sample(nodes, k)

    vals = []
    for s in sources:
        dist = nx.single_source_shortest_path_length(H, s)
        vals.extend([d for v, d in dist.items() if v != s])

    return float(np.mean(vals)) if vals else 0.0


def degree_assortativity(G: nx.Graph) -> float:
    """
    度 Pearson 相关系数（assortativity）
    """
    try:
        val = nx.degree_pearson_correlation_coefficient(G)
        if math.isnan(val):
            return 0.0
        return float(val)
    except Exception:
        return 0.0


def betweenness_mean_exact(G: nx.Graph) -> float:
    """
    精确计算节点 betweenness centrality 的均值
    """
    n = G.number_of_nodes()
    if n <= 1:
        return 0.0

    try:
        bc = nx.betweenness_centrality(G, normalized=True)
    except Exception:
        return 0.0

    vals = np.array(list(bc.values()), dtype=float)
    return float(vals.mean()) if vals.size > 0 else 0.0


def betweenness_mean_approx(G: nx.Graph, k: int = 32) -> float:
    """
    近似计算节点 betweenness centrality 的均值
    """
    n = G.number_of_nodes()
    if n <= 1:
        return 0.0

    kk = min(k, n)
    try:
        bc = nx.betweenness_centrality(G, k=kk, normalized=True, seed=42)
    except TypeError:
        bc = nx.betweenness_centrality(G, k=kk, normalized=True)
    except Exception:
        return 0.0

    vals = np.array(list(bc.values()), dtype=float)
    return float(vals.mean()) if vals.size > 0 else 0.0


def compute_average_path_length_feature(G: nx.Graph, cfg) -> float:

    mode = cfg.features.apl_mode.lower()

    if mode == "exact":
        return average_path_length_lcc_exact(G)
    elif mode == "approx":
        return average_path_length_lcc_approx(G, num_sources=cfg.features.apl_num_sources)
    else:
        raise ValueError(f"Unknown apl_mode: {cfg.features.apl_mode}")


def compute_betweenness_feature(G: nx.Graph, cfg) -> float:

    mode = cfg.features.betweenness_mode.lower()

    if mode == "exact":
        return betweenness_mean_exact(G)
    elif mode == "approx":
        return betweenness_mean_approx(G, k=cfg.features.betweenness_k)
    else:
        raise ValueError(f"Unknown betweenness_mode: {cfg.features.betweenness_mode}")


def extract_candidate_features(G: nx.Graph, cfg) -> np.ndarray:
    """
    提取 20 维候选特征

    顺序约定：
    0-3   : degree [mean, std, skewness, kurtosis]
    4-7   : clustering [mean, std, skewness, kurtosis]
    8-11  : average neighbor degree [mean, std, skewness, kurtosis]
    12-15 : egonet edge count [mean, std, skewness, kurtosis]
    16    : average path length
    17    : assortativity
    18    : degree entropy
    19    : betweenness mean
    """
    # 1) degree
    deg = np.array([d for _, d in G.degree()], dtype=float)

    # 2) clustering
    clu_dict = nx.clustering(G)
    clu = np.array(list(clu_dict.values()), dtype=float)

    # 3) average neighbor degree
    avg_nbr_deg = average_neighbor_degree_per_node(G)

    # 4) egonet edge count
    ego_edges = egonet_edge_count_per_node(G)

    feat_deg = safe_stats(deg)             # 4
    feat_clu = safe_stats(clu)             # 4
    feat_nbr = safe_stats(avg_nbr_deg)     # 4
    feat_ego = safe_stats(ego_edges)       # 4

    # 全局特征：支持精确/近似切换
    apl = compute_average_path_length_feature(G, cfg)   # 1
    assort = degree_assortativity(G)                    # 1
    deg_ent = degree_entropy(G)                         # 1
    bet_mean = compute_betweenness_feature(G, cfg)      # 1

    feat = np.array(
        feat_deg + feat_clu + feat_nbr + feat_ego + [apl, assort, deg_ent, bet_mean],
        dtype=float
    )
    return feat