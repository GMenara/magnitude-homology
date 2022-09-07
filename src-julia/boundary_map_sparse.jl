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

    MC_kplus1_l = Array{Int64}[] 
    for possible_chain in collect(Iterators.product([vtx for i=1:k+2]...))
        possible_chain = collect(possible_chain)   
        is_seq = true
        for i in 1:k+1
            if possible_chain[i] == possible_chain[i+1]
                is_seq = false
            end  
        end
        if is_seq == true   
            length = 0
            for i in 1:k+1
                length = length + nx.shortest_path_length(G, possible_chain[i], possible_chain[i + 1])
                if length > l
                    break
                end
            end
            if length == l
                push!(MC_kplus1_l,possible_chain)
            end
        end                                 
    end
    sort!(MC_kplus1_l)

     
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

    outfile = "boundary.txt"
    f = open(outfile, "w")

    for i in MC_kminus1_l
	    println(f, i)
    end
    for i in MC_kl
        println(f,i)
    end
    for i in MC_kplus1_l
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

                if kminus1_chain in MC_kminus1_l
                    #println(kminus1_chain)

                    #build vectors
                    row_index = findfirst(x->x==kminus1_chain,MC_kminus1_l)
                    
                    push!(row_vec,row_index)
                    push!(col_vec,k_chain_idx+length(MC_kminus1_l))
                end
            end
        end
    end

    for kplus1_chain_idx in 1:length(MC_kplus1_l)
        kplus1_chain = MC_kplus1_l[kplus1_chain_idx]
        #println(k_chain)
        for vertex_idx in 2:length(kplus1_chain) - 1

            #if removing a vertex does not change the length of a path
            if nx.shortest_path_length(G, kplus1_chain[vertex_idx - 1], kplus1_chain[vertex_idx + 1]) == nx.shortest_path_length(G,kplus1_chain[vertex_idx - 1],kplus1_chain[vertex_idx]) + nx.shortest_path_length(G, kplus1_chain[vertex_idx], kplus1_chain[vertex_idx + 1])
                
                #if the k-tuple with the vertex removed is part of MC_{k-1,l}
                k_chain = collect(np.delete(kplus1_chain, vertex_idx-1))
                #println(kminus1_chain)

                if k_chain in MC_kl
                    #println(kminus1_chain)

                    #build vectors
                    row_index = findfirst(x->x==k_chain,MC_kl)
                    
                    push!(row_vec,row_index)
                    push!(col_vec,kplus1_chain_idx+length(MC_kminus1_l)+length(MC_kl))
                end
            end
        end
    end



    #println(row_vec)
    #println(col_vec)
    bdry_mtx = sparse(row_vec, col_vec, ones(length(col_vec)))
    #println(bdry_mtx)

    #define dv
    dv = Array{Int}(undef,length(MC_kl)+length(MC_kminus1_l)+length(MC_kplus1_l)) 
    for i in 1:length(MC_kminus1_l)
        dv[i]=k
    end
    for i in length(MC_kminus1_l)+1:length(MC_kl)+length(MC_kminus1_l)
        dv[i]=k+1
    end
    for i in length(MC_kminus1_l)+length(MC_kl)+1: length(MC_kl)+length(MC_kminus1_l)+length(MC_kplus1_l)
        dv[i]=k+2
    end 
    #println(dv, length(dv))

    #define fv
    fv = ones(length(MC_kl)+length(MC_kminus1_l)+length(MC_kplus1_l))
    #println(fv,length(dv))

    return bdry_mtx, dv, fv
end

#graph=nx.icosahedral_graph()
#graph=nx.cycle_graph(8)
#graph.add_edge(2,6)
graph = nx.erdos_renyi_graph(20,0.3,seed=false,directed=false)

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
#println(rv)
cp = d_kl.colptr
push!(cp,last(cp))
#println(cp, length(cp))

C = eirene(rv=rv, cp=cp, dv=dv, fv=fv, maxdim=3)
dim = 3

#println(C)
#println(barcode(C,dim=3), length(barcode(C,dim=3)))
println("homology in dim ",dim," is ",length(barcode(C,dim=dim)))