import networkx as nx
from numpy.linalg import matrix_rank

from src import boundary_matrix, create_graph

G=nx.cycle_graph(12)
G.add_edge(1,3)
G.add_edge(2,5)
G.add_edge(3,7)
G.add_edge(4,9)

k = 3
l = 3

d_k_1l= boundary_matrix.bdry(G, k-1, l, show=True, figwidth=15)
d_kl= boundary_matrix.bdry(G, k, l, show=True, figwidth=15)

dim_kernel = d_k_1l.shape[1]- matrix_rank(d_k_1l)
dim_image = matrix_rank(d_kl)
betti = dim_kernel - dim_image
print('The dimension of the kernel of d_{k-1,l} for k,l=',k,l,'is',dim_kernel)
print('The dimension of the rank of d_{k,l} for k,l=',k,l,'is',dim_image)
print('betti_{k,l} for k,l=',k,l,'is', betti)

