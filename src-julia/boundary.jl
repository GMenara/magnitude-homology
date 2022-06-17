using PyCall
nx = pyimport("networkx")
np = pyimport("numpy")

using IterTools

function boundary(G, k, l)
    
    vtx=collect(G.nodes())
    MC_kl = [] 

    for possible_chain in collect(Iterators.product([vtx for i=1:k+1]...))
        # the following line was taken off because we are working with tuples, not paths, and so (0,1,2) \neq (2,1,0)
        # if possible_chain[0]<=possible_chain[-1]: #start with smaller label if flipped
        is_seq = True
        for i in 1:k
            if possible_chain[i] == possible_chain[i + 1]
                is_seq = False
                break
        if is_seq
            length = 0
            for i in 1:k
                length = length + nx.shortest_path_length(G, possible_chain[i], possible_chain[i + 1]) 
                if length > l
                    break
            if length == l
                append!(MC_kl,possible_chain)
                
    sort(MC_kl)

    MC_k_1l = []
    for possible_chain in collect(Iterators.product([vtx for i=1:k]...))
    #for possible_chain in np.array(vtx)[np.rollaxis(np.indices((len(vtx),)*k),0,k+1).reshape(-1,k)]:
        # if possible_chain[0]<=possible_chain[-1]: #start with smaller label if flipped
        is_seq = True
        for i in 1:k-1
            if possible_chain[i] == possible_chain[i + 1]
                is_seq = False
                break
        if is_seq
            length = 0
            for i in 1:k-1
                length = length + nx.shortest_path_length(G, possible_chain[i], possible_chain[i + 1])
                if length > l
                    break
            if length == l
                append!(MC_k_1l,possible_chain)
                
    sort(MC_k_1l)

    if len(MC_k_1l)==0
        bdry_mtx = np.zeros((1, len(MC_kl)))
    elseif len(MC_kl)==0
        bdry_mtx = np.zeros((len(MC_k_1l), 1))
    else
        bdry_mtx = np.zeros((len(MC_k_1l), len(MC_kl)))

    # index the columns with elements of MC_kl
    for k_ch_idx in 1:len(MC_kl)
        k_ch = MC_kl[k_ch_idx]
        for v_idx in 1:len(k_ch) - 1
            #if removing a vertex does not change the length of a path
            if nx.shortest_path_length(G, k_ch[v_idx - 1], k_ch[v_idx + 1]) == nx.shortest_path_length(G,k_ch[v_idx - 1],k_ch[v_idx]) + nx.shortest_path_length(G, k_ch[v_idx], k_ch[v_idx + 1])
                #if the k-tuple with the vertex removed is part of MC_{k-1,l}
                if tuple(np.delete(np.array(k_ch), v_idx)) in MC_k_1l
                    #set the matrix entry to be -1
                    bdry_mtx[MC_k_1l.index(tuple(np.delete(np.array(k_ch), v_idx))), k_ch_idx] = (-1) ^ v_idx
    
    return bdry_mtx
end

G=nx.icosahedral_graph()
#G=nx.cycle_graph(8)
#G.add_edge(2,6)

k = 2
l = 2

d_kl= boundary(G, k, l)
d_kplus1_l= boundary(G, k+1, l)
