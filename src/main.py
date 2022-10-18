import networkx as nx
from numpy.linalg import matrix_rank
import time

from src import boundary_matrix, boundary_matrix_sparse, create_graph

start_time = time.time()

#G=nx.petersen_graph()
G=nx.cycle_graph(5)
#G.add_edge(2,6)

#G=nx.erdos_renyi_graph(10,0.5,seed=1000,directed=False)
#create_graph.graph(G)
k = 6
l = 7

#d_kl= boundary_matrix.bdry(G, k, l, show=False, figwidth=15)
d_kl= boundary_matrix_sparse.bdry(G, k, l, show=False, figwidth=15)
print(d_kl.shape)
#d_kplus1_l= boundary_matrix.bdry(G, k+1, l, show=False, figwidth=15)
d_kplus1_l= boundary_matrix_sparse.bdry(G, k+1, l, show=False, figwidth=15)
print(d_kplus1_l.shape)

dim_kernel = d_kl.shape[1]- matrix_rank(d_kl)
print(matrix_rank(d_kl))
dim_image = matrix_rank(d_kplus1_l)
betti = dim_kernel - dim_image
print('The dimension of the kernel of d_{k,l} for k,l=',k,l,'is',dim_kernel)
print('The dimension of the image of d_{k+1,l} for k,l=',k,l,'is',dim_image)
print('betti_{k,l} for k,l=',k,l,'is', betti)
print('---%s seconds---' % (time.time() - start_time))

## Examples taken from Hepworth - Willerton paper "Categorifying the magnitude of a graph" arXiv:1505.04125v2
#
# 1. C5 --> OK
# 2. C7 --> OK
# 3. C8 --> OK
# 4. C8 plus (2,6) --> OK
# 5. Petersen --> OK
# 6. Heawood --> OK
# 7. Coxeter --> ? (nx does not generate it)
# 8. Moebius-Cantor --> OK
# 9. Pappus --> OK
# 10. Icosahedral --> OK

