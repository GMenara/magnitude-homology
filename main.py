from sage.all import *

from sage.graphs.graph import Graph
from sage.graphs.distances_all_pairs import distances_all_pairs
from sage.homology.chain_complex import ChainComplex

from sage.graphs.graph_generators import GraphGenerators
graphs = GraphGenerators()

from sage.matrix.constructor import Matrix
matrix = Matrix()

from sage.rings.integer_ring import IntegerRing
from sage.rings.rational_field import RationalField
from sage.rings.finite_rings.finite_field_constructor import FiniteFieldFactory
BaseRing = IntegerRing()

from itertools import product

# define a function to compute magnitude homology groups.
# it will depend on the graph G and on the maximum path length lmax.

def magnitude_homology(g,lmax):

    kmax = lmax +1  

    d = distances_all_pairs(g)   # This function returns a double dictionary D of vertices, in which the distance between vertices u and v is D[u][v].

    # define a function to compute generators.
    # we use the fact that a chain group MC_{*,*}(G) breaks up into subgroups MC_{k,l}^{a,b}(G),
    # where a and b are the starting and ending vertices of the chain, l is the length of the chain and k is the degree.
    # thus "generators[a,b,k,l]" is a list of the degree k generators of a chain group.
    
    generators = dict(((a,b,k,l),[]) for a in g.vertices() for b in g.vertices() for k in range(kmax+2) for l in range(lmax+1)) #dictionary where values are lists
    
    # STEP 1: define a funciton to add generators.
    # we build add_generators as follows:
    # 1. the function takes in input a path p=(x0,...,xk=z), the length of the path l and the final vertex of the path z;
    # 2. it considers the tuple (p[0],p[len(p)-1],k,l) and it adds it to the list of generators of degree k;
    # 3. for every vertex v in G different from the final vertex z, the function checks if the path (x0,...,z,v) has to be added to the generators.
    
    def add_generators(p,l,z):
        k = len(p)-1
        if k<=kmax and l<=lmax:
            generators[(p[0],p[len(p)-1],k,l)].append(p)
            #print(type(generators[(p[0],p[len(p)-1],k,l)]))
            for v in g.vertices():
                if z != v:
                    #print(d[z][v])
                    add_generators(p+[v],l+d[z][v],v)
        
                    
    for v in g.vertices():
        add_generators([v],0,v)
    
    #print(type(generators))
    #print(generators)
    
    for a in g.vertices():
        for b in g.vertices():
            for l in range(lmax+1):
                for k in range(kmax+1):
                    generators[(a,b,k,l)] = dict((tuple(p),i) for (i,p) in enumerate(generators[(a,b,k,l)]))
    
    # STEP 2: define differentials (just like the usual definition)
    
    def differential(a,b,k,l):
        m = {}
        h = generators[(a,b,k-1,l)]
        for (p,i) in generators[(a,b,k,l)].items():
            for v in range(len(p)-2):
                if d[p[v]][p[v+1]] + d[p[v+1]][p[v+2]] == d[p[v]][p[v+2]]:
                    j = h[p[:v+1]+p[v+2:]]
                    if v%2:
                        m[(j,i)] = m.get((j,i),0) + 1
                    else:
                        m[(j,i)] = m.get((j,i),0) - 1
        return matrix(BaseRing, len(h), len(generators[(a,b,k,l)]), m)

    # STEP 3: define chain complex (usinf built in function ChainComplex)
    
    def chains(a,b,l):
        differentials = dict((k,differential(a,b,k,l)) for k in range(1,kmax+1) if generators[(a,b,k,l)] or generators[(a,b,k-1,l)])
        return ChainComplex(differentials, base_ring=BaseRing, degree=-1)


    def homology(a,b,l):
        return chains(a,b,l).homology(generators=False)

    return dict(((a,b,l),homology(a,b,l)) for a in g.vertices() for b in g.vertices() for l in range(lmax+1))

# STEP 4: pick a graph and compute magnitude homology

#g = Graph([(1,2),(2,3),(3,4),(4,1),(3,1)])
#g = graphs.CycleGraph(3)
g = graphs.PetersenGraph()
graph_name = "G"
g.show()

lmax = 6

print(graph_name)
print('lmax=', lmax)

homology = magnitude_homology(g,lmax)
print(homology)

total_rank = dict(((k,l),0) for k in range(0,lmax+1) for l in range(0, lmax+1))

print(total_rank)

for a in g.vertices():
    for b in g.vertices():
        for l in range(lmax+1):
            for degree, group in sorted(homology[a,b,l].items()): 
                total_rank[degree,l] += group.rank()


for l in range(0,lmax+1):
    print(l,':')
    for k in range(0,lmax+1):
        if total_rank[k,l] != 0:
            print(total_rank[k,l])
        #else:
        #    print('      ')  
