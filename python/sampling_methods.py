import random
import networkx as nx


def induced_subgraph_by_nodes(G: nx.Graph, sampled_nodes):
    return G.subgraph(sampled_nodes).copy()


def bfs_sampling_fixed_size(G: nx.Graph, target_ratio: float):
    nodes = list(G.nodes())
    n = len(nodes)
    target_size = max(1, round(n * target_ratio))

    seed = random.choice(nodes)
    visited = set([seed])
    queue = [seed]

    while queue and len(visited) < target_size:
        u = queue.pop(0)
        nbrs = list(G.neighbors(u))
        random.shuffle(nbrs)
        for v in nbrs:
            if v not in visited:
                visited.add(v)
                queue.append(v)
                if len(visited) >= target_size:
                    break

    if len(visited) < target_size:
        remaining = [x for x in nodes if x not in visited]
        extra = random.sample(remaining, target_size - len(visited))
        visited.update(extra)

    return list(visited)


def rmsc_sampling_fixed_size(G: nx.Graph, num_seeds: int, pc: float, target_ratio: float):
    nodes = list(G.nodes())
    n = len(nodes)
    target_size = max(1, round(n * target_ratio))
    target_size = min(target_size, n)

    num_seeds = min(num_seeds, target_size)
    sampled = set(random.sample(nodes, num_seeds))
    frontier = list(sampled)

    while len(sampled) < target_size:
        new_frontier = []

        for u in frontier:
            nbrs = [v for v in G.neighbors(u) if v not in sampled]
            random.shuffle(nbrs)

            for v in nbrs:
                if len(sampled) >= target_size:
                    break
                if random.random() < pc:
                    sampled.add(v)
                    new_frontier.append(v)

        if not new_frontier:
            remaining = [x for x in nodes if x not in sampled]
            if not remaining:
                break
            new_seed = random.choice(remaining)
            sampled.add(new_seed)
            new_frontier = [new_seed]

        frontier = list(dict.fromkeys(new_frontier))

    return list(sampled)