import networkx as nx
from numpy.linalg import matrix_rank

from src import boundary_matrix, create_graph

G=nx.cycle_graph(6)
G.add_edge(1,3)
create_graph.graph(G)

k = 3
l = 3

#boundary_matrix.bdry(G, k-1, l, show=True)
#boundary_matrix.bdry(G, k, l, show=True)


d_k_1l= boundary_matrix.bdry(G, k-1, l, show=True, figwidth=15)
print(type(d_k_1l))
d_kl= boundary_matrix.bdry(G, k, l, show=True, figwidth=15)

dim_kernel = d_k_1l.shape[1]- matrix_rank(d_k_1l)
dim_image = matrix_rank(d_kl)
betti = dim_kernel - dim_image
print('The dimension of the kernel of d_k-1 for k=',k,'is',dim_kernel)
print('The dimension of the rank of d_k for k=',k,'is',dim_image)
print('betti_k is', betti)

