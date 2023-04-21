using PyCall
nx = pyimport("networkx")
fun = pyimport("functools")

#define activation function as xor of incoming nodes
function subgraph(G,state_vector::Vector{Int})

    vtx_list = collect(G.nodes())    
    active_nodes_list = zeros(Int,0)  
    new_state_vector = zeros(Int,0)

    for vtx in vtx_list
        vtx_index = indexin(vtx,vtx_list)[1] 
        predecessors = collect(G.predecessors(vtx))
        #println(predecessors)

        if length(predecessors) == 0
            updated_state_vtx = state_vector[vtx_index] 
        elseif length(predecessors) == 1
            index_pred = indexin(predecessors[1],vtx_list)[1] 
            updated_state_vtx = xor(state_vector[vtx_index],state_vector[index_pred])
        elseif length(predecessors) > 1
            values = map(x->state_vector[indexin(x,vtx_list)[1]],predecessors)
            xor_pred = fun.reduce(xor, values)
            updated_state_vtx = xor(state_vector[vtx_index],xor_pred)
        end

        #println(vtx,",",state_updated_vtx)

        if updated_state_vtx == 1
            append!(active_nodes_list,vtx) 
        end
        #println(active_nodes_list)
        append!(new_state_vector,updated_state_vtx)
    end 

    active_subgraph = nx.induced_subgraph(G, active_nodes_list)
    
    return active_subgraph, new_state_vector
end