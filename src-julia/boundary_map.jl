using PyCall
nx = pyimport("networkx")
np = pyimport("numpy")

using IterTools
using Eirene
using SparseArrays

function boundary(G, k, l)
    
    vtx=collect(G.nodes())
      
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
       
    #println(typeof(MC_k_1l))
    #println(length(MC_k_1l))

    if length(MC_k_1l)==0
        bdry_mtx = zeros((1, length(MC_kl)))
    elseif length(MC_kl)==0
        bdry_mtx = zeros((length(MC_k_1l), 1))
    else
        bdry_mtx = zeros((length(MC_k_1l), length(MC_k_1l)+length(MC_kl)))
    end

    # index the columns with elements of MC_kl
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

                    #set the matrix entry to be 1
                    row_index = findfirst(x->x==kminus1_chain,MC_k_1l)
                    #println("want to change row:", row_index)
                    #println("want to change clmn:", k_chain_idx)
                    bdry_mtx[row_index, k_chain_idx + length(MC_k_1l)] = 1
                end
            end
        end
    end

        
    return bdry_mtx
end

#graph=nx.icosahedral_graph()
graph=nx.cycle_graph(8)
graph.add_edge(2,6)

k = 2
l = 2

d_kl = boundary(graph, k, l)

#define dv
size_d_kl = size(d_kl)
dv = Array{Int64}(undef,size_d_kl[2]) 
for i in 1:size_d_kl[1]
    dv[i]=k
end
for i in size_d_kl[1]+1:size_d_kl[2]
    dv[i]=k+1
end


#check dv
outfile = "dv.txt"
    f = open(outfile, "w")

    for i in 1:length(dv)
        println(f,dv[i])
        #println(f,typeof(dv[i]))
    end
    

#define fv
fv = ones(Int8,(1,size_d_kl[2]))

S = sparse(d_kl)
println(S)
rv = S.rowval
println(rv)
cp = S.colptr
println(cp)

C = eirene(rv=rv, cp=cp, dv=dv, fv=fv, maxdim=3)

#println(C)
println(barcode(C,dim=3))