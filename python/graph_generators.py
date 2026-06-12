import networkx as nx


def erdos_reyni_graph(n: int, p: float) -> nx.Graph:
    return nx.erdos_renyi_graph(n=n, p=p, seed=None, directed=False)


def ba_graph_undirected(n: int, m: int) -> nx.Graph:
    return nx.barabasi_albert_graph(n=n, m=m, seed=None)


def ws_graph_undirected(n: int, k: int, p: float) -> nx.Graph:
    return nx.watts_strogatz_graph(n=n, k=k, p=p, seed=None)