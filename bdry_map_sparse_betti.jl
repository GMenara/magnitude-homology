using PyCall
nx = pyimport("networkx")
np = pyimport("numpy")
alg = pyimport("numpy.linalg")
rdn = pyimport("random")
math = pyimport("math")

using SparseArrays

function random_select_nums(list, n)
        return rdn.sample(list, n)
end

function boundary(G,k,l)
    vtx=collect(G.nodes())
    #println(vtx)
    #println(random_select_nums(vtx, 3))
  
    MC_kl = Array{Int64}[] 
    #visited_kl = Array{Int64}[]
    possible_chains = collect(Iterators.product([vtx for i=1:k+1]...))
    chains = [chain for chain in possible_chains if length(chain)==length(Set(chain))]
    for chain in chains
      
        is_seq = true
        #for i in 1:k
        #    if possible_chain[i] == possible_chain[i+1]
        #        is_seq = false
        #    end  
        #end
        #for i in 2:k
        #    if possible_chain[i-1] == possible_chain[i+1]
        #        is_seq = false
        #    end  
        #end
        #for i in 2:k+1
        #    for j in 1:i-1
        #        if chain[i] == chain[j]
        #            is_seq = false
        #        end
        #    end
        #end  
        
        length = 0
        for i in 1:k
            try
                length = length + nx.shortest_path_length(G, chain[i], chain[i + 1])
            catch
                is_seq = false
            end

            #if length == 2
            #    path = nx.shortest_path(G, chain[i], chain[i + 1])
            #    if i == 1 && chain[i+2] in path
            #        is_seq = false
            #    elseif i == k && chain[i-1] in path
            #        is_seq = false
            #    #elseif try chain[i-1] in path catch chain[i-1] in path end
            #    #    is_seq = false
            #    end
            #end
                       
            if length > l
                break
            end 
            
            
        end
        
        if length == l && is_seq == true
            push!(MC_kl,chain)

            #subgraph = G.subgraph(chain)
            #unfrozen_subgraph = nx.Graph(subgraph)
            #unfrozen_subgraph.add_edge(chain[1],chain[k+1])
            #if nx.is_eulerian(unfrozen_subgraph) || unfrozen_subgraph.number_of_edges()==1
            #    push!(MC_kl,chain)
            #end
        end
                                       
    end
    sort!(MC_kl)
    println(length(MC_kl))

    MC_kminus1_l = Array{Int64}[]  
    possible_chains = collect(Iterators.product([vtx for i=1:k]...))
    chains = [chain for chain in possible_chains if length(chain)==length(Set(chain))]
    for chain in chains
       
        is_seq = true
        #for i in 1:k-1
        #    if possible_chain[i] == possible_chain[i + 1]
        #        is_seq = false
        #    end
        #end
        #for i in 2:k-1
        #    if possible_chain[i-1] == possible_chain[i+1]
        #        is_seq = false
        #    end  
        #end
        #for i in 2:k
        #    for j in 1:i-1
        #        if possible_chain[i] == possible_chain[j]
        #            is_seq = false
        #        end
        #    end
        #end

        length = 0
        for i in 1:k-1
            try
                length = length + nx.shortest_path_length(G, chain[i], chain[i + 1])
            catch
                is_seq = false
            end

            if length > l
                break
            end
        end

        if length == l && is_seq == true
            push!(MC_kminus1_l,chain)

            #subgraph = G.subgraph(chain)
            #unfrozen_subgraph = nx.Graph(subgraph)
            #unfrozen_subgraph.add_edge(chain[1],chain[k])
            #if nx.is_eulerian(unfrozen_subgraph) || unfrozen_subgraph.number_of_edges()==1
            #    push!(MC_kminus1_l,chain)
            #end  
        end
        
    end            
    sort!(MC_kminus1_l)
    println(length(MC_kminus1_l))

    row_vec_kl = Array{Int}(undef,0)
    col_vec_kl = Array{Int}(undef,0)
    data_kl = Array{Int}(undef,0)

    for k_chain_idx in 1:length(MC_kl)
        k_chain = MC_kl[k_chain_idx]
        is_seq = true
        #println(k_chain)
        for vertex_idx in 2:length(k_chain) - 1
    
            #if removing a vertex does not change the length of a path
            #if nx.shortest_path_length(G, k_chain[vertex_idx - 1], k_chain[vertex_idx + 1]) == nx.shortest_path_length(G,k_chain[vertex_idx - 1],k_chain[vertex_idx]) + nx.shortest_path_length(G, k_chain[vertex_idx], k_chain[vertex_idx + 1])
            try
                nx.shortest_path_length(G, k_chain[vertex_idx - 1], k_chain[vertex_idx + 1]) == nx.shortest_path_length(G,k_chain[vertex_idx - 1],k_chain[vertex_idx]) + nx.shortest_path_length(G, k_chain[vertex_idx], k_chain[vertex_idx + 1])
            catch
                is_seq = false
            end
    
            if is_seq == true

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
                    push!(data_kl,(-1)^vertex_idx)
                end
            end
        end
    end

    if length(col_vec_kl) > 0
        cols_of_sparse_kl = last(col_vec_kl)
    elseif length(col_vec_kl) == 0
        cols_of_sparse_kl = 0
    end

    if row_vec_kl == Array{Int}(undef,0) && col_vec_kl == Array{Int}(undef,0)
        bdry_mtx_kl = zeros((1, 1))
    else
        bdry_mtx_kl = sparse(row_vec_kl, col_vec_kl, data_kl)
    end

    return bdry_mtx_kl, col_vec_kl, cols_of_sparse_kl, length(MC_kl)
end

