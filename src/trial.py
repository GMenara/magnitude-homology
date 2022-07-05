import networkx as nx
from src import boundary_matrix, create_graph
import itertools

#n=4
#G=nx.cycle_graph(n)
#G.add_edge(1,3)
#G.add_edge(2,4)

G = nx.erdos_renyi_graph(10, 0.15, seed=None, directed=False)
create_graph.graph(G)

#for component in nx.connected_components(G):
#    print(component.nodes())

vtx_connected_component = []
for v in nx.connected_components(G):
    vtx = list(v)
    vtx_connected_component.append(vtx)

print(vtx_connected_component)

for component in vtx_connected_component:
    possible_chain = itertools.product(component, repeat=3)
    print(possible_chain)



