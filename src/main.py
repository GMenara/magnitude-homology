import networkx as nx
from numpy.linalg import matrix_rank

from src import boundary_matrix, create_graph

# G=nx.cycle_graph(8)
# G.add_edge(2,6)
# create_graph.graph(G)

G = nx.erdos_renyi_graph(30, 0.1, seed=None, directed=False)
create_graph.graph(G)

k = 3
l = 3

d_kl= boundary_matrix.bdry(G, k, l, show=False, figwidth=15)
d_kplus1_l= boundary_matrix.bdry(G, k+1, l, show=False, figwidth=15)

#try:
#    dim_kernel = d_kl.shape[1]- matrix_rank(d_kl)
#except ValueError:
#    dim_kernel = d_kl.shape[1]

#try:
#    dim_image = matrix_rank(d_kplus1_l)
#except ValueError:
#    dim_image = 0

dim_kernel = d_kl.shape[1]- matrix_rank(d_kl)
dim_image = matrix_rank(d_kplus1_l)
betti = dim_kernel - dim_image
print('The dimension of the kernel of d_{k,l} for k,l=',k,l,'is',dim_kernel)
print('The dimension of the image of d_{k+1,l} for k,l=',k,l,'is',dim_image)
print('betti_{k,l} for k,l=',k,l,'is', betti)

## Examples taken from Hepworth - Willerton paper "Categorifying the magnitude of a graph" arXiv:1505.04125v2
#
# 1. C5 --> OK
# 2. C7 --> OK
# 3. C8 --> OK
# 4. C8 plus (2,6) --> OK
# 5. Petersen --> OK
# 6. Heawood --> OK
# 8. Moebius - Cantor --> OK
# 9. Pappus --> OK
# 10. Icosahedral --> OK
