include("/home/gmenara/JuliaProjects/boundary_map.jl")

#graph=nx.icosahedral_graph()
graph=nx.cycle_graph(5)
#graph.add_edge(2,6)
#graph = nx.erdos_renyi_graph(20,0.3,seed=false,directed=false)

#graph = nx.petersen_graph()

#graph.add_node(3)
#graph.add_node(4)

#graph.add_edge(0, 3)
#graph.add_edge(0, 4)

k = 2
l = 3

d_kl = boundary(graph, k, l)
d_kplus1_l = boundary(graph, k+1, l)

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

dim_kernel = size_d_kl[2] - size_d_kl[1] - alg.matrix_rank(d_kl) #subtracting size_d_kl[1] may cause the result to be negative
                                                                 #(in cases when a chain is <0>).
                                                                 #Negative results should be considerend =0.
dim_image = alg.matrix_rank(d_kplus1_l)
betti = dim_kernel - dim_image
#println("The dimension of the kernel of d_{k,l} for k,l=",k,l,"is",dim_kernel)
#println("The dimension of the image of d_{k+1,l} for k,l=",k,l,"is",dim_image)
println("betti_{k,l} for k,l=",k,l,"is", betti)

S = sparse(d_kl)
#println(size(S),size(d_kl))
#println(d_kl,S)
rv = S.rowval
#println(rv)
cp = S.colptr
#println(length(rv),length(cp),length(dv),length(fv))

C = eirene(rv=rv, cp=cp, dv=dv, fv=fv, maxdim=k)

#println(C)
println(length(barcode(C,dim=k))) #this gives both birth time and death time 



