include("/home/gmenara/JuliaProjects/bdry_map_sparse_betti.jl")

for runs in 1:1
    
    basename_output = "output"
    basename_graph = "graph"
    basename_mst = "mst"
    extension  = "txt"
    dirpath_output = "/home/gmenara/JuliaProjects/experiments/hamiltonian_walks/erdos_reniy_20_0.3/output"
    dirpath_graph= "/home/gmenara/JuliaProjects/experiments/hamiltonian_walks/erdos_reniy_20_0.3/graphs"
    dirpath_graph_mst= "/home/gmenara/JuliaProjects/experiments/hamiltonian_walks/erdos_reniy_20_0.3/mst"

    function nextfile(basename,ext,dir)
        newcount = runs
        newfile = string(basename, "_", newcount, ".", ext) 
        return joinpath(dir,newfile)
    end

    graph = nx.Graph([(0,1),(0,2),(0,3),(1,2),(1,3),(2,3),(2,4),(4,5),(4,8),(5,6),(5,8),(6,7)])
    #graph = nx.icosahedral_graph()
    #println(graph.edges())
    #graph = nx.petersen_graph()
    #graph = nx.heawood_graph()
    #graph = nx.cycle_graph(runs+1)
    #graph = nx.complete_graph(5)
    #graph = nx.random_geometric_graph(20, 0.2, dim=2, p=2)
    #graph = nx.erdos_renyi_graph(20,0.3,directed=false)
    #minimum_spanning_tree = nx.minimum_spanning_tree(graph)

    #outfile_g = nextfile(basename_graph,extension,dirpath_graph)
    #f = open(outfile_g, "w")
    #println(f,collect(graph.edges()))
    #println(f,"diameter = ",nx.diameter(graph))

    #outfile_mst = nextfile(basename_mst,extension,dirpath_graph_mst)
    #f = open(outfile_mst, "w")
    #println(f,collect(minimum_spanning_tree.edges()))
        
    k = 3
    l = 3

    #outfile_out = nextfile(basename_output,extension,dirpath_output)
    #out = open(outfile_out, "w")
    
    for value_of_k in 2:k

        value_of_l=value_of_k +1

        bdry_mtx_kl, col_vec_kl, cols_of_sparse_kl, len_kl = boundary(graph, value_of_k, value_of_l)
        bdry_mtx_kplus1l, col_vec_kplus1l, cols_of_sparse_kplus1l, len_kplus1l = boundary(graph, value_of_k + 1, value_of_l)

        if cols_of_sparse_kl>0 && cols_of_sparse_kl == len_kl
        #if cols_of_sparse_kl == len_kl
            dim_kernel = size(bdry_mtx_kl)[2] -  alg.matrix_rank(bdry_mtx_kl)
        elseif cols_of_sparse_kl == 0
            dim_kernel = len_kl
        else
            entries_to_add = len_kl - cols_of_sparse_kl
            dim_kernel = size(bdry_mtx_kl)[2] + entries_to_add - alg.matrix_rank(bdry_mtx_kl)
        end

        if cols_of_sparse_kplus1l>0 && cols_of_sparse_kplus1l == len_kplus1l
            dim_image = alg.matrix_rank(bdry_mtx_kplus1l)
        else
            entries_to_add = len_kplus1l - cols_of_sparse_kplus1l
            dim_image = alg.matrix_rank(bdry_mtx_kplus1l)
        end

        betti = dim_kernel - dim_image
        println("betti_{k,l} for k,l=",value_of_k,value_of_l," is ", betti)

        #bdry_mtx_kl_mst, col_vec_kl_mst, cols_of_sparse_kl_mst, len_kl_mst = boundary(minimum_spanning_tree, value_of_k, value_of_l)
        #bdry_mtx_kplus1l_mst, col_vec_kplus1l_mst, cols_of_sparse_kplus1l_mst, len_kplus1l_mst = boundary(minimum_spanning_tree, value_of_k + 1, value_of_l)

        #if cols_of_sparse_kl_mst == len_kl_mst
        #    dim_kernel_mst = size(bdry_mtx_kl_mst)[2] -  alg.matrix_rank(bdry_mtx_kl_mst)
        #elseif cols_of_sparse_kl_mst == 0
        #    dim_kernel_mst = len_kl_mst
        #else
        #    entries_to_add_mst = len_kl_mst - cols_of_sparse_kl_mst
        #    dim_kernel_mst = size(bdry_mtx_kl_mst)[2] + entries_to_add_mst - alg.matrix_rank(bdry_mtx_kl_mst)
        #end

        #if cols_of_sparse_kplus1l_mst == len_kplus1l_mst
        #    dim_image_mst = alg.matrix_rank(bdry_mtx_kplus1l_mst)
        #else
        #    entries_to_add_mst = len_kplus1l_mst - cols_of_sparse_kplus1l_mst
        #    dim_image_mst = alg.matrix_rank(bdry_mtx_kplus1l_mst)
        #end

        #betti_mst = dim_kernel_mst - dim_image_mst
        #println("betti_{k,l} of MST for k,l=",value_of_k, value_of_l," is ", betti_mst)
        #println(out, "homology of G for k=",value_of_k," and l=", value_of_l, " is ",betti)
        #println(out, "homology for MST_G k=",value_of_k," and l=", value_of_l, " is ",betti_mst)
        #println(out, "\n")


    end
end


        


