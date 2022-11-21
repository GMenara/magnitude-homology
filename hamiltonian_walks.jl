using PyCall
nx = pyimport("networkx")
np = pyimport("numpy")
alg = pyimport("numpy.linalg")

function hamiltonian_walks(G)
    ham_paths = Array{Int64}[] 
    #vtx=collect(G.nodes())
    walk = tournament.hamiltonian_path(G)
    while new_walk != walk
        
    
end