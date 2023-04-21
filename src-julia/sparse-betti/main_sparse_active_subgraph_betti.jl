include("/home/gmenara/JuliaProjects/bdry_map_sparse_betti.jl")
include("/home/gmenara/JuliaProjects/active_subgraph.jl")

graph = nx.DiGraph([(1,2),(2,3),(3,4),(4,1),(1,3),(2,4)])
state_vector = ones(Int,length(graph.nodes()))
active_subgraph, new_state_vector = subgraph(graph,state_vector)
time_step = 0

#for time_step in 1:13
while new_state_vector != zeros(Int,length(graph.nodes()))

    global time_step = time_step + 1
    println("state vector is: ", new_state_vector)

    basename_output = "output"
    basename_graph = "graph"
    basename_active_subgraph = "active_subgraph"
    basename_mst = "mst"    
    extension  = "txt"
    dirpath_output = "/home/gmenara/JuliaProjects/exp_networks/toy/output"
    dirpath_graph= "/home/gmenara/JuliaProjects/exp_networks/toy/graph"
    dirpath_active_subgraph= "/home/gmenara/JuliaProjects/exp_networks/toy/active_subgraph"
    dirpath_graph_mst= "/home/gmenara/JuliaProjects/exp_networks/toy/mst"

    function nextfile(basename,ext,dir)
        newcount = time_step
        newfile = string(basename, "_", newcount, ".", ext) 
        return joinpath(dir,newfile)
    end
  
    outfile_g = nextfile(basename_graph,extension,dirpath_graph)
    f = open(outfile_g, "w")
    println(f,collect(graph.edges()))

    outfile_as = nextfile(basename_active_subgraph,extension,dirpath_active_subgraph)
    f = open(outfile_as, "w")
    println(f,collect(active_subgraph.edges()))
   
    k = 2
    l = 2

    outfile_out = nextfile(basename_output,extension,dirpath_output)
    out = open(outfile_out, "w")
    
    for value_of_k in 0:k

        value_of_l=value_of_k

        bdry_mtx_kl, col_vec_kl, cols_of_sparse_kl, len_kl = boundary(active_subgraph, value_of_k, value_of_l)
        bdry_mtx_kplus1l, col_vec_kplus1l, cols_of_sparse_kplus1l, len_kplus1l = boundary(active_subgraph, value_of_k + 1, value_of_l)

        if cols_of_sparse_kl>0 && cols_of_sparse_kl == len_kl
            dim_kernel = size(bdry_mtx_kl)[2] -  alg.matrix_rank(bdry_mtx_kl)
        elseif cols_of_sparse_kl == 0
            dim_kernel = len_kl
        else
            entries_to_add = len_kl - cols_of_sparse_kl
            dim_kernel = size(bdry_mtx_kl)[2] + entries_to_add - alg.matrix_rank(bdry_mtx_kl)
        end

        if cols_of_sparse_kplus1l == len_kplus1l
            dim_image = alg.matrix_rank(bdry_mtx_kplus1l)
        else
            entries_to_add = len_kplus1l - cols_of_sparse_kplus1l
            dim_image = alg.matrix_rank(bdry_mtx_kplus1l)
        end

        betti = dim_kernel - dim_image
        println("betti_{k,l} for k,l=",value_of_k,value_of_l," is ", betti)

        println(out, "homology of active subgraph of G at time step ", time_step, "for k=",value_of_k," and l=", value_of_l, " is ",betti)

    end
    
    global active_subgraph, new_state_vector = subgraph(graph, new_state_vector)
end




