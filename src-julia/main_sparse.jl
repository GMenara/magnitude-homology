include("/home/gmenara/JuliaProjects/boundary_map_sparse.jl")

for runs in 1:20
    
    basename_output = "output"
    basename_graph = "graph"
    basename_mst = "mst"
    extension  = "txt"
    dirpath_output = "/home/gmenara/JuliaProjects/output"
    dirpath_graph= "/home/gmenara/JuliaProjects/graphs"
    dirpath_graph_mst= "/home/gmenara/JuliaProjects/mst"

    function nextfile(basename,ext,dir)
        newcount = runs
        newfile = string(basename, "_", newcount, ".", ext) 
        return joinpath(dir,newfile)
    end


    #graph=nx.icosahedral_graph()
    #graph=nx.cycle_graph(8)
    #graph.add_edge(2,6)
    #n=10
    #graph=nx.random_tree(10, seed=nothing, create_using=nothing)
    graph = nx.erdos_renyi_graph(20,0.3,directed=false)
    minimum_spanning_tree = nx.minimum_spanning_tree(graph)

    outfile_g = nextfile(basename_graph,extension,dirpath_graph)
    f = open(outfile_g, "w")
    println(f,collect(graph.edges()))

    outfile_mst = nextfile(basename_mst,extension,dirpath_graph_mst)
    f = open(outfile_mst, "w")
    println(f,collect(minimum_spanning_tree.edges()))
        
    k = 4
    l = 4

    outfile_out = nextfile(basename_output,extension,dirpath_output)
    out = open(outfile_out, "w")
    
    for value_of_k in 2:k

        value_of_l=value_of_k

        d_kl_g, dv_g, fv_g = boundary(graph, value_of_k, value_of_l)
        d_kl_mst, dv_mst, fv_mst = boundary(minimum_spanning_tree, value_of_k, value_of_l)
        #d_kl, dv, fv = boundary(graph, k, l)

        rv_g = d_kl_g.rowval
        #println(rv)
        cp_g = d_kl_g.colptr
        
        #correction factor cp_g 
        size_d_kl_g = size(d_kl_g)
        cols_of_sparse = size_d_kl_g[2]  

        if cols_of_sparse != length(dv_g) #length(dv) = length(MC_kl)+length(MC_kminus1_l)+length(MC_kplus1_l)
            entries_to_add = length(dv_g) - cols_of_sparse
            #println(entries_to_add)
            for runs in 1:entries_to_add
                #println(runs)
                push!(cp_g,last(cp_g)) 
            end
                
        end

        #println(cp_g, length(cp_g))

        rv_mst = d_kl_mst.rowval
        #println(rv)
        cp_mst = d_kl_mst.colptr
        
        #correction factor cp_mst
        size_d_kl_mst = size(d_kl_mst)
        cols_of_sparse = size_d_kl_mst[2]  

        if cols_of_sparse != length(dv_mst) #length(dv) = length(MC_kl)+length(MC_kminus1_l)+length(MC_kplus1_l)
            entries_to_add = length(dv_mst) - cols_of_sparse
            #println(entries_to_add)
            for runs in 1:entries_to_add
                #println(runs)
                push!(cp_mst,last(cp_mst)) 
            end
                
        end

        #println(cp_mst, length(cp_mst))

        C_g = eirene(rv=rv_g, cp=cp_g, dv=dv_g, fv=fv_g, maxdim=value_of_k)
        C_mst = eirene(rv=rv_mst, cp=cp_mst, dv=dv_mst, fv=fv_mst, maxdim=value_of_k)
        #println(barcode(C,dim=3), length(barcode(C,dim=3)))
        println("homology of G for k=",value_of_k," and l=", value_of_l, " is ",length(barcode(C_g,dim=value_of_k)))
        println("homology for MST_G k=",value_of_k," and l=", value_of_l, " is ",length(barcode(C_mst,dim=value_of_k)))

        println(out, "homology of G for k=",value_of_k," and l=", value_of_l, " is ",length(barcode(C_g,dim=value_of_k)))
        println(out, "homology for MST_G k=",value_of_k," and l=", value_of_l, " is ",length(barcode(C_mst,dim=value_of_k)))
        println(out, "\n")
    end
end