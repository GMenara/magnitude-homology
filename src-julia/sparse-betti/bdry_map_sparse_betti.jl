using PyCall
nx = pyimport("networkx")
np = pyimport("numpy")
alg = pyimport("numpy.linalg")

using SparseArrays

function boundary(G,k,l)
    vtx=collect(G.nodes())
    #println(vtx)
  
    MC_kl = Array{Int64}[] 
    for possible_chain in collect(Iterators.product([vtx for i=1:k+1]...))
        possible_chain = collect(possible_chain)   
        is_seq = true
        for i in 1:k
            if possible_chain[i] == possible_chain[i+1]
                is_seq = false
            end  
        end
        if is_seq == true   
            length = 0
            for i in 1:k
                length = length + nx.shortest_path_length(G, possible_chain[i], possible_chain[i + 1])
                if length > l
                    break
                end
            end
            if length == l
                push!(MC_kl,possible_chain)
            end
        end                                 
    end
    sort!(MC_kl)

    MC_kminus1_l = Array{Int64}[]  
    for possible_chain in collect(Iterators.product([vtx for i=1:k]...))
        possible_chain = collect(possible_chain)    
        is_seq = true
        for i in 1:k-1
            if possible_chain[i] == possible_chain[i + 1]
                is_seq = false
            end
        end
        if is_seq ==true
            length = 0
            for i in 1:k-1
                length = length + nx.shortest_path_length(G, possible_chain[i], possible_chain[i + 1])
                if length > l
                    break
                end
            end
            if length == l
                push!(MC_kminus1_l,possible_chain)
            end
        end
    end            
    sort!(MC_kminus1_l)

    row_vec_kl = Array{Int}(undef,0)
    col_vec_kl = Array{Int}(undef,0)

    for k_chain_idx in 1:length(MC_kl)
        k_chain = MC_kl[k_chain_idx]
        #println(k_chain)
        for vertex_idx in 2:length(k_chain) - 1
    
            #if removing a vertex does not change the length of a path
            if nx.shortest_path_length(G, k_chain[vertex_idx - 1], k_chain[vertex_idx + 1]) == nx.shortest_path_length(G,k_chain[vertex_idx - 1],k_chain[vertex_idx]) + nx.shortest_path_length(G, k_chain[vertex_idx], k_chain[vertex_idx + 1])
                
                #if the k-tuple with the vertex removed is part of MC_{k-1,l}
                kminus1_chain = collect(np.delete(k_chain, vertex_idx-1))
                #println(kminus1_chain)
    
                if kminus1_chain in MC_kminus1_l
                    #println(kminus1_chain)
    
                    #build vectors
                    row_index = findfirst(x->x==kminus1_chain,MC_kminus1_l)
                    
                    push!(row_vec_kl,row_index)
                    #println(row_vec_kl,row_index)
                    push!(col_vec_kl,k_chain_idx)
                    #println(col_vec_kl,k_chain_idx)
                end
            end
        end
    end

    if length(col_vec_kl) > 0
        values_vec_kl = ones(length(col_vec_kl))
        cols_of_sparse_kl = last(col_vec_kl)
    elseif length(col_vec_kl) == 0
        cols_of_sparse_kl = 0
    end

    if row_vec_kl == Array{Int}(undef,0) && col_vec_kl == Array{Int}(undef,0)
        bdry_mtx_kl = zeros((1, 1))
    else
        bdry_mtx_kl = sparse(row_vec_kl, col_vec_kl, values_vec_kl)
    end

    return bdry_mtx_kl, col_vec_kl, cols_of_sparse_kl, length(MC_kl)
end

