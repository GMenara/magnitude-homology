import numpy as np
import networkx as nx
import itertools
import matplotlib.pyplot as plt

from numpy.linalg import matrix_rank

def bdry(G,
         k: int,
         l: int,
         show=True,
         figwidth=15):
    vtx = list(G.nodes())

    #find (k+1)-tuples generating MC_{k,l}
    MC_kl = []
    for possible_chain in itertools.product(vtx, repeat=k + 1):
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
                ## not really necessary
                #mult = []
                #for i in range(k):
                #    mult.append(len(list(nx.all_shortest_paths(G, source=possible_chain[i], target=possible_chain[i + 1]))))
                #    if mult[i] != 1:
                #        MC_kl.extend([possible_chain] * (mult[i]-1))

    MC_kl.sort()

    # find k-tuples generating MC_{k-1,l}
    MC_k_1l = []
    for possible_chain in itertools.product(vtx, repeat=k):
    #for possible_chain in np.array(vtx)[np.rollaxis(np.indices((len(vtx),)*k),0,k+1).reshape(-1,k)]:
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
                #mult = []
                #for i in range(k-1):
                #    mult.append(len(list(nx.all_shortest_paths(G, source=possible_chain[i], target=possible_chain[i + 1]))))
                #    if mult[i] != 1:
                #        MC_k_1l.extend([possible_chain] * (mult[i] - 1))

            MC_k_1l.sort()

    if len(MC_k_1l)==0:
        bdry_mtx = np.zeros((1, len(MC_kl)))
    elif len(MC_kl)==0:
        bdry_mtx = np.zeros((len(MC_k_1l), 1))
    else:
        bdry_mtx = np.zeros((len(MC_k_1l), len(MC_kl)))

    # index the columns with elements of MC_kl
    for k_ch_idx in range(len(MC_kl)):
        k_ch = MC_kl[k_ch_idx]
        for v_idx in range(1, len(k_ch) - 1):
            #if removing a vertex does not change the length of a path
            if nx.shortest_path_length(G, k_ch[v_idx - 1], k_ch[v_idx + 1]) == nx.shortest_path_length(G,k_ch[v_idx - 1],k_ch[v_idx]) + nx.shortest_path_length(G, k_ch[v_idx], k_ch[v_idx + 1]):
                #if the k-tuple with the vertex removed is part of MC_{k-1,l}
                if tuple(np.delete(np.array(k_ch), v_idx)) in MC_k_1l:
                    #set the matrix entry to be -1
                    bdry_mtx[MC_k_1l.index(tuple(np.delete(np.array(k_ch), v_idx))), k_ch_idx] = (-1) ** v_idx

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

    return bdry_mtx #, MC_k_1l, MC_kl
