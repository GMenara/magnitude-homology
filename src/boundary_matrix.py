import numpy as np
import networkx as nx
import itertools
import matplotlib.pyplot as plt
from scipy.linalg import null_space
from src import all_shortest_paths

#
# NEEDS FIXING!!! (k-1) tuple does not remember the vertex that was taken off
#
#
#

def bdry(G, k, l, show=False, figwidth=15):
    vtx = list(G.nodes())

    adj = [[] for _ in range(len(vtx))]

    for e in G.edges:
        list(e)
        all_shortest_paths.add_edge(adj, e[0], e[-1])

    #find (k+1)-tuples generating MC_{k,l}
    MC_kl = []
    for possible_chain in itertools.product(vtx, repeat=k + 1):  # ineffecient, but f- it
        # the following line was taken off because we are working with tuples, not paths, and so (0,1,2) \neq (2,1,0)
        # if possible_chain[0]<=possible_chain[-1]: #start with smaller label if flipped
        is_seq = True
        for i in range(k):
            if possible_chain[i] == possible_chain[i + 1]:
                is_seq = False
                break
        if is_seq:
            length = 0
            for i in range(k):
                length += nx.shortest_path_length(G, possible_chain[i], possible_chain[i + 1])
                if length > l:
                    break
            if length == l:
                MC_kl.append(possible_chain)
                # add chain with multiplicity
                mult = []
                for i in range(k):
                    mult.append(all_shortest_paths.print_paths(adj, len(vtx), possible_chain[i], possible_chain[i + 1]))
                    if mult[i] != 1:
                        MC_kl.extend([possible_chain] * (mult[i]-1))

    MC_kl.sort()
    # print(MC_kl)

    # find k-tuples generating MC_{k-1,l}
    MC_k_1l = []
    for possible_chain in itertools.product(vtx, repeat=k):  # ineffecient, but f- it
        # if possible_chain[0]<=possible_chain[-1]: #start with smaller label if flipped
        is_seq = True
        for i in range(k - 1):
            if possible_chain[i] == possible_chain[i + 1]:
                is_seq = False
                break
        if is_seq:
            length = 0
            for i in range(k - 1):
                length += nx.shortest_path_length(G, possible_chain[i], possible_chain[i + 1])
                if length > l:
                    break
            if length == l:
                MC_k_1l.append(possible_chain)
                # add chain with multiplicity
                mult = []
                for i in range(k-1):
                    mult.append(all_shortest_paths.print_paths(adj, len(vtx), possible_chain[i], possible_chain[i + 1]))
                    if mult[i] != 1:
                        MC_k_1l.extend([possible_chain] * (mult[i]-1))
    MC_k_1l.sort()

    bdry_mtx = np.zeros((len(MC_k_1l), len(MC_kl)))
    for k_ch_idx in range(len(MC_kl)):
        k_ch = MC_kl[k_ch_idx] # index the columns with elements of MC_kl
        for v_idx in range(1, len(k_ch) - 1):
            if nx.shortest_path_length(G, k_ch[v_idx - 1], k_ch[v_idx + 1]) == nx.shortest_path_length(G,k_ch[v_idx - 1],k_ch[v_idx]) + nx.shortest_path_length(G, k_ch[v_idx], k_ch[v_idx + 1]):
                if tuple(np.delete(np.array(k_ch), v_idx)) in MC_k_1l:
                    bdry_mtx[MC_k_1l.index(tuple(np.delete(np.array(k_ch), v_idx))), k_ch_idx] = (-1) ** v_idx

    #find dimension of kernel
    kernel = null_space(bdry_mtx)
    dim_kernel = kernel.shape[1]
    print('The dimension of the kernel of d_k for k=',k,'is',dim_kernel)

    if show:
        show_mtx = bdry_mtx

        dim_ratio = show_mtx.shape[1] / show_mtx.shape[0]
        figure = plt.figure(figsize=(figwidth, figwidth / dim_ratio))
        axes = figure.add_subplot(111)
        axes.matshow(show_mtx, aspect=1)
        axes.set_xticks(np.arange(len(MC_kl)))
        axes.set_xticklabels(MC_kl, rotation=90)
        axes.set_yticks(np.arange(len(MC_k_1l)))
        axes.set_yticklabels(MC_k_1l)
        plt.show()
        return

    return bdry_mtx, MC_k_1l, MC_kl