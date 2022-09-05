using PyCall
nx = pyimport("networkx")
np = pyimport("numpy")

using IterTools
using Eirene
using SparseArrays

function boundary(G, k, l)
    
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

    #println(typeof(MC_kl))
    #println(length(MC_kl))

    
    MC_k_1l = Array{Int64}[] 
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
                push!(MC_k_1l,possible_chain)
            end
        end
    end            
    sort!(MC_k_1l)

    outfile = "boundary.txt"
    f = open(outfile, "w")

    for i in MC_k_1l
	    println(f, i)
    end
    for i in MC_kl
        println(f,i)
    end
    
    #build vectors needed for sparse matrix 
    row_vec = Array{Int}(undef, 0)
    col_vec = Array{Int}(undef, 0)

    for k_chain_idx in 1:length(MC_kl)
        k_chain = MC_kl[k_chain_idx]
        #println(k_chain)
        for vertex_idx in 2:length(k_chain) - 1

            #if removing a vertex does not change the length of a path
            if nx.shortest_path_length(G, k_chain[vertex_idx - 1], k_chain[vertex_idx + 1]) == nx.shortest_path_length(G,k_chain[vertex_idx - 1],k_chain[vertex_idx]) + nx.shortest_path_length(G, k_chain[vertex_idx], k_chain[vertex_idx + 1])
                
                #if the k-tuple with the vertex removed is part of MC_{k-1,l}
                kminus1_chain = collect(np.delete(k_chain, vertex_idx-1))
                #println(kminus1_chain)

                if kminus1_chain in MC_k_1l
                    #println(kminus1_chain)

                    #build vectors
                    row_index = findfirst(x->x==kminus1_chain,MC_k_1l)
                    
                    push!(row_vec,row_index)
                    push!(col_vec,k_chain_idx+length(MC_k_1l))
                end
            end
        end
    end

    #println(row_vec)
    #println(col_vec)
    bdry_mtx = sparse(row_vec, col_vec, ones(length(row_vec)))
    println(bdry_mtx)

    #define dv
    dv = Array{Int}(undef,length(MC_kl)+length(MC_k_1l)) 
    for i in 1:length(MC_k_1l)
        dv[i]=k
    end
    for i in length(MC_k_1l)+1:length(MC_kl)+length(MC_k_1l)
        dv[i]=k+1
    end
    #println(dv, length(dv))

    #define fv
    fv = ones(length(MC_kl)+length(MC_k_1l))
    #println(fv,length(dv))

    return bdry_mtx, dv, fv
end

#graph=nx.icosahedral_graph()
graph=nx.cycle_graph(8)
graph.add_edge(2,6)

k = 2
l = 2

d_kl, dv, fv= boundary(graph, k, l)

#check dv
outfile = "dv.txt"
    f = open(outfile, "w")

    for i in 1:length(dv)
        println(f,dv[i])
        #println(f,typeof(dv[i]))
    end
    

rv = d_kl.rowval
println(rv)
cp = d_kl.colptr
println(cp)

C = eirene(rv=rv, cp=cp, dv=dv, fv=fv, maxdim=3)

#println(C)
println(barcode(C,dim=3))