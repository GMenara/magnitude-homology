import networkx as nx

from src import boundary_matrix, create_graph

G=nx.cycle_graph(4)
G.add_edge(1,3)
create_graph.graph(G)

boundary_matrix.bdry(G, 2, 2, show=True)

