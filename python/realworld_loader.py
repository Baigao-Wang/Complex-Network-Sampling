from pathlib import Path
import networkx as nx
import pandas as pd


def _load_space_edgelist(path: Path, comment_prefix: str = "%") -> nx.Graph:
    G = nx.Graph()
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if comment_prefix and line.startswith(comment_prefix):
                continue
            parts = line.split()
            if len(parts) >= 2:
                G.add_edge(parts[0], parts[1])
    return G


def _load_netscience_csv(path: Path) -> nx.Graph:
    df = pd.read_csv(path, comment="#")
    src = df.iloc[:, 0].astype(str)
    dst = df.iloc[:, 1].astype(str)

    G = nx.Graph()
    for u, v in zip(src, dst):
        if u != v:
            G.add_edge(u, v)
    return G


def load_realworld_network(file_path: str, network_name: str) -> tuple[nx.Graph, nx.Graph]:
    path = Path(file_path)

    if network_name.lower() == "netscience":
        G = _load_netscience_csv(path)
    else:
        G = _load_space_edgelist(path)

    if G.number_of_nodes() == 0:
        raise ValueError(f"Empty graph loaded from {file_path}")

    largest_cc = max(nx.connected_components(G), key=len)
    G_lcc = G.subgraph(largest_cc).copy()
    return G, G_lcc